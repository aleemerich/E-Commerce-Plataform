# encoding: UTF-8
class PagamentoPedidosController < ApplicationController
  # as checagens estão limitadas porque as funções :retorno_pagamento_digital e:retorno_pag_seguro
  # precisam serem acessar externamente pelas empresas de pagamento sem estarem autenticadas.
  # Esta função está declarada em application_controller.rb
  before_filter :permissao_publico, :only => [:new, :create, :edit, :update] 
  # Impede que mude o status de um pagamento que já está sendo processado
  before_filter :check_status_pagamento, :only => [:edit, :update]
  # Esse SKIP é devido as empresa de pagamento necessitarem postar informações e não
  # possuirem o TOKEN do Rails, que é criado por padrão e por segurança.
  skip_before_filter :verify_authenticity_token, :only => [:retorno_pagamento_digital, :retorno_pag_seguro]
  layout "publico"


  # LEMBRETE: Como regra de negócio foi definido que um pagamento sempre estará atrelado a uma parcela. Não haverá
  # mais que um pagamento para uma mesma parcela. Para que um novo pagamento seja criado, é sempre nessário que
  # uma parcela sem pagamento seja informada, caso contrário o cliente apenas editará o modo de pagamento se
  # o pagamento estiver apto a isso (status = PRÉ-PAGAMENTO)
  #
  # OBS: Essa regra não permite que um cliente page novamente uma parcela no PAGAMENTO DIGITAL, caso ele
  # ja tenha dado incio ao pagamento e este seja cencelado. Não foram feitos teste no PAG SEGURO. Caso o
  # cliente tenha que conseguir realizar um pagamento mesmo já tendo tentado e esse tenha sido cancelado,
  # a regra geral de pagamento deve ser modificada.

  def new
    # TODO: Não consegui colocar essa checagem como before_filter dado que os parâmetros de entrada
    # são diferente. É preciso pensar em como isso pode ser feito e melhorar isso.
    if check_parcela_n_pagamento(params[:parcela_id])
      @parcela_pedido = Adm::ParcelaPedido.find(params[:parcela_id])
      @pagamento_pedido = Adm::PagamentoPedido.new
      logCliente(request.remote_ip, session[:cliente].id, -1, "Acessando tela de NOVO pagamento")
    else
      redirect_to(edit_pagamento_pedido_path(Adm::ParcelaPedido.find(params[:adm_pagamento_pedido][:parcela_pedido_id]).pagamento_pedido), :notice => 'Jah foi iniciado um pagamento para essa parcela, mas voce pode modifica-lo.')
    end
  end

  def create
    # TODO: Não consegui colocar essa checagem como before_filter dado que os parâmetros de entrada
    # são diferente. É preciso pensar em como isso pode ser feito e melhorar isso.
    if check_parcela_n_pagamento(params[:adm_pagamento_pedido][:parcela_pedido_id])
      @pagamento_pedido = Adm::PagamentoPedido.new(params[:adm_pagamento_pedido]) 
      @pagamento_pedido.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id
      if @pagamento_pedido.save
        gravaHistoricoPagamento(@pagamento_pedido)
        logPedido(request.remote_ip, @pagamento_pedido.parcela_pedido.pedido_id, -1, "Criando pagamento (ID do Pagamento = " + @pagamento_pedido.id.to_s + ")")
        logCliente(request.remote_ip, session[:cliente].id, -1, "Criando pagamento (ID do Pagamento = " + @pagamento_pedido.id.to_s + ")")
        case @pagamento_pedido.pagamento_pedido_empresa.parcial
        when 'pagseguro'
          @order = PagSeguro::Order.new(@pagamento_pedido.id)
          @order.add :id => @pagamento_pedido.id, :price => @pagamento_pedido.valor, :description => 'Pagamento da parcela ' + @pagamento_pedido.parcela_pedido.nro_parcela.to_s + ' do pedido ' + "%05d" % @pagamento_pedido.parcela_pedido.pedido_id.to_s 
        when 'pagamentodigital'
          # integração via HTML simples
        else
          redirect_to(:back, :notice => 'A forma de pagamento solicitada é inválida')
        end
      else
        logPedido(request.remote_ip, @pagamento_pedido.parcela_pedido.pedido_id, -1, "[I] Problemas ao criar um pagamento ao pedido)")
        logCliente(request.remote_ip, session[:cliente].id, -1, "Criando pagamento (ID do Pagamento = " + @pagamento_pedido.id.to_s + ")")
        redirect_to(:back, :notice => 'Problemas ao atribuir um pagamento a esse pedido')
      end
    else
      redirect_to(edit_pagamento_pedido_path(Adm::ParcelaPedido.find(params[:adm_pagamento_pedido][:parcela_pedido_id]).pagamento_pedido), :notice => 'Já foi iniciado um pagamento para essa parcela, mas você pode modificá-lo.')
    end
  end

  def edit
    @pagamento_pedido = Adm::PagamentoPedido.find(params[:id])
    logCliente(request.remote_ip, session[:cliente].id, -1, "Acessando tela de EDICAO de pagamento")
  end

  def update
    @pagamento_pedido = Adm::PagamentoPedido.find(params[:id])
    if @pagamento_pedido.update_attributes(params[:adm_pagamento_pedido])
      gravaHistoricoPagamento(@pagamento_pedido)
      # TODO: Esse pedaço está igual ao do CREATE. É preciso rever essa duplicidade
      logPedido(request.remote_ip, @pagamento_pedido.parcela_pedido.pedido_id, -1, "Modificando pagamento (ID do Pagamento = " + @pagamento_pedido.id.to_s + ")")
      logCliente(request.remote_ip, session[:cliente].id, -1, "Editando pagamento (ID do Pagamento = " + @pagamento_pedido.id.to_s + ")")
      case @pagamento_pedido.pagamento_pedido_empresa.parcial
      when 'pagseguro'
        @order = PagSeguro::Order.new(@pagamento_pedido.id)
        @order.add :id => @pagamento_pedido.id, :price => @pagamento_pedido.valor, :description => 'Pagamento da parcela ' + @pagamento_pedido.parcela_pedido.nro_parcela.to_s + ' do pedido ' + "%05d" % @pagamento_pedido.parcela_pedido.pedido_id.to_s 
      when 'pagamentodigital'
        # integração via HTML simples
      else
        redirect_to(:back, :notice => 'A forma de pagamento solicitada é inválida')
      end
      render 'create'
    else
      redirect_to(:back, :notice => 'Houve problemas ao modificar o pagamento')
    end
  end

  def retorno_pagamento_digital
    begin
      @pagamento = Adm::PagamentoPedido.find(params[:id_pedido])
      @parcela = @pagamento.parcela_pedido
      @pedido = @pagamento.parcela_pedido.pedido
      # Faz checagem de conferência para ver se os valores locais
      # e o enviado pelo Pagamento Digital são os mesmos
      if @pagamento.valor == params[:valor_original].to_f
        gravaHistoricoPagamento(@pagamento)
        logPedido(request.remote_ip, @pedido.id, -1, "Retorno de pagamento PAGAMENTO DIGITAL = Modificacao de STATUS para '" + params[:status] + "'")
        @pagamento.cod_transacao = params[:id_transacao]
        # Grava tudo que vem do Pagamento Digital
        @pagamento.retorno_completo = params
        
        # Analiza o status de retorno para ver
        # o que deve ser feito
        case params[:cod_status]
        when '0' # Status = Em andamento
          # LEMBRETE: Regra do Pagamento digital diz que se um pagamento estava como concluido
          # e volta a 'em andamento' significa que o pagamento foi congelado por contestação
          if @pagamento.status_id == Status.where(["codigo = '3' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id
            @pagamento.status_id = Status.where(["codigo = '1' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id
            # Muda o status da parcela para BLOQUEADO
            @parcela.status_id = Status.where(["codigo = '5' and area_id = ?", Area.select('id').where(["codigo = 8"]).first]).first.id
            # Muda o status do pedido para PROBLEMAS COM PAGAMENTO
            @pedido.status_id = Status.where(["codigo = '13' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
          else
            # Muda o status da parcela para AGUARDANDO PAGAMENTO
            @parcela.status_id = Status.where(["codigo = '6' and area_id = ?", Area.select('id').where(["codigo = 8"]).first]).first.id
            # Muda o status do pagamento para AGUARDANDO
            @pagamento.status_id = Status.where(["codigo = '1' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id
            # Não mexe no pedido porque: Se ele vem de um pedido novo, já está bloqueado
            # e não precisa bloqueá-lo. Se vem de um pedido já finalizado, não precisa mexer
            # no status do pedido
          end
          # Não há envio de e-mail dado que o cliente será redirecionado.
        when '1' # Status = Concluído
          # Muda o status do pagamento para APROVADO
          @pagamento.status_id = Status.where(["codigo = '3' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id
          # Muda o status da parcela para PAGO
          @parcela.status_id = Status.where(["codigo = '1' and area_id = ?", Area.select('id').where(["codigo = 8"]).first]).first.id
          # Se o pedido está esperando pagamento, libera o pedido
          if @pedido.status_id = Status.where(["codigo = '3' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
            # Muda status para AGUARDANDO PRODUCAO
            @pedido.status_id = Status.where(["codigo = '4' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
          end
          # Esse tratamento evita que um simples erro de envio de e-mail pare o
          # processo como um todo (não salvando as alterações)
          begin
            # Envio de e-mail para cliente
            Notificacao.cliente_pagamento_concluido(@pagamento).deliver
          rescue
            logCritico("pagamento_pedido_controller => retorno_pagamento_digital -> Notificacao.cliente_pagamento_concluido = ERRO: " + $!.to_s)
          end         
        when '2' # Status = Cancelado
          # Muda o status do pagamento para CANCELADO
          @pagamento.status_id = Status.where(["codigo = '2' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id
          if @parcela.dt_vencimento < DateTime.now
            # Muda o status da parcela para ATRASADO
            @parcela.status_id = Status.where(["codigo = '2' and area_id = ?", Area.select('id').where(["codigo = 8"]).first]).first.id
          else
            # Muda o status da parcela para EM DIA
            @parcela.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 8"]).first]).first.id
          end
          # Não mexe no pedido porque: Se ele vem de um pedido novo, já está bloqueado
          # e não precisa bloqueá-lo. Se vem de um pedido já finalizado, não precisa mexer
          # no status do pedido
          #-------------------
          # Esse tratamento evita que um simples erro de envio de e-mail pare o
          # processo como um todo (não salvando as alterações)
          begin
            # Envio de e-mail para cliente
            Notificacao.cliente_pagamento_cancelado(@pagamento).deliver
          rescue
            logCritico("pagamento_pedido_controller => retorno_pagamento_digital -> Notificacao.cliente_pagamento_cancelado = ERRO: " + $!.to_s)
          end         
        else
          logPedido(request.remote_ip, @pedido.id, -1, "[I] Retorno de pagamento PAGAMENTO DIGITAL = STATUS não previsto! (" + params[:status] + ")")
        end
        # Salva as modificações
        @pagamento.save
        @parcela.save
        @pedido.save
        redirect_to final_pedido_path(@pedido)
     else
        # Validação de dados incorreta! Os valores não estão batendo!
        gravaHistoricoPagamento(@pagamento)
        logPedido(request.remote_ip, @pedido.id, -1, "[I] Retorno de pagamento PAGAMENTO DIGITAL = Divergencia nos valores informados (valor informado pelo PAGAMENTO DIGITAL = " + params[:valor_original] + ")")
        # Muda o status da pagamento para BLOQUEADO
        @pagamento.status_id = Status.where(["codigo = '4' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id
        # Muda o status da parcela para BLOQUEADO
        @parcela.status_id = Status.where(["codigo = '5' and area_id = ?", Area.select('id').where(["codigo = 8"]).first]).first.id
        # Muda o status do pedido para PROBLEMAS COM PAGAMENTO
        @pedido.status_id = Status.where(["codigo = '13' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
        # Salva as modificações
        @pagamento.save
        @parcela.save
        @pedido.save
        redirect_to pedido_path(@pedido, :notify => 'ERRO!!! Houve divergencia entre o valor do pagamento registrado e o informado pelo PAGAMENTO DIGITAL. Acesse novamente o PAGAMENTO DIGITAL para confirir os valores.')
     end
   rescue
    logCritico("pagamento_pedido_controller => retorno_pagamento_digital = ERRO: " + $!.to_s)
   end
 end

  def retorno_pag_seguro
    begin
      pagseguro_notification do |notification|
          #logger.debug '==> Entrou no LOOP de notificacao'
          # Usa-se o indice ZERO fixo porque não há mais que um produto
          # ao se parar uma parcela porquestão de regra de negocio, ou seja,
          # cada parcela só tem um pagamento atrelado.
          # OBS: Esse objeto é um HASH, não um model.
          produto = notification.products[0]
          @pagamento = Adm::PagamentoPedido.find(produto[:id])
          @parcela = @pagamento.parcela_pedido
          @pedido = @pagamento.parcela_pedido.pedido
    
          if @pagamento.valor == produto[:price]
            gravaHistoricoPagamento(@pagamento)
            logPedido(request.remote_ip, @pedido.id, -1, "Retorno de pagamento PAG SEGURO = Modificacao de STATUS para '" + notification.status.to_s + "'")
            @pagamento.cod_transacao = params[:TransacaoID]
            @pagamento.retorno_completo = params
            case notification.status
            when :verifying, :pending # Status = Em andamento
              #logger.debug '==> Opcao EM ANDAMENTO'
              # Muda o status da parcela para AGUARDANDO PAGAMENTO
              @parcela.status_id = Status.where(["codigo = '6' and area_id = ?", Area.select('id').where(["codigo = 8"]).first]).first.id
              # Muda o status do pagamento para AGUARDANDO
              @pagamento.status_id = Status.where(["codigo = '1' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id
              # Não mexe no pedido porque: Se ele vem de um pedido novo, já está bloqueado
              # e não precisa bloqueá-lo. Se vem de um pedido já finalizado, não precisa mexer
              # no status do pedido
            when :completed, :approved # Status = Completo
              #logger.debug '==> Opcao CONCLUIDO'
              # Muda o status do pagamento para APROVADO
              @pagamento.status_id = Status.where(["codigo = '3' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id
              # Muda o status da parcela para PAGO
              @parcela.status_id = Status.where(["codigo = '1' and area_id = ?", Area.select('id').where(["codigo = 8"]).first]).first.id
              # Se o pedido está esperando pagamento, libera o pedido
              if @pedido.status_id == Status.where(["codigo = '3' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
                # Muda status para AGUARDANDO PRODUCAO
                @pedido.status_id = Status.where(["codigo = '4' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
              end
              # Esse tratamento evita que um simples erro de envio de e-mail pare o
              # processo como um todo (não salvando as alterações)
              begin
                # Envio de e-mail para cliente
                Notificacao.cliente_pagamento_concluido(@pagamento).deliver
              rescue
                logCritico("pagamento_pedido_controller => retorno_pag_seguro -> Notificacao.cliente_pagamento_concluido = ERRO: " + $!.to_s)
              end         
           when :canceled, :refunded # Status = Cancelado
              #logger.debug '==> Opcao CANCELADO'
              # Muda o status do pagamento para CANCELADO
              @pagamento.status_id = Status.where(["codigo = '2' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id
              if @parcela.dt_vencimento < DateTime.now
                # Muda o status da parcela para ATRASADO
                @parcela.status_id = Status.where(["codigo = '2' and area_id = ?", Area.select('id').where(["codigo = 8"]).first]).first.id
              else
                # Muda o status da parcela para EM DIA
                @parcela.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 8"]).first]).first.id
              end
              # Não mexe no pedido porque: Se ele vem de um pedido novo, já está bloqueado
              # e não precisa bloqueá-lo. Se vem de um pedido já finalizado, não precisa mexer
              # no status do pedido
              #-------------------
              # Esse tratamento evita que um simples erro de envio de e-mail pare o
              # processo como um todo (não salvando as alterações)
              begin
                # Envio de e-mail para cliente
                Notificacao.cliente_pagamento_cancelado(@pagamento).deliver
              rescue
                logCritico("pagamento_pedido_controller => retorno_pag_seguro -> Notificacao.cliente_pagamento_cancelado = ERRO: " + $!.to_s)
              end
           else
              logPedido(request.remote_ip, @pedido.id, -1, "[I] Retorno de pagamento PAG SEGURO = STATUS não pervisto! (" + notification.status.to_s + ")")
           end
            # Salva as modificações
            @pagamento.save
            @parcela.save
            @pedido.save
            #redirect_to final_pedido_path(@pedido)
          else
            # Validação de dados incorreta! Os valores não estão batendo!
            gravaHistoricoPagamento(@pagamento)
            logPedido(request.remote_ip, @pedido.id, -1, "[I]Retorno de pagamento PAG SEGURO = Divergencia nos valores informados (valor informado pelo PAG SEGURO = " + produto[:price].to_s + ")")
            # Muda o status da pagamento para BLOQUEADO
            @pagamento.status_id = Status.where(["codigo = '4' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id
            # Muda o status da parcela para BLOQUEADO
            @parcela.status_id = Status.where(["codigo = '5' and area_id = ?", Area.select('id').where(["codigo = 8"]).first]).first.id
            # Muda o status do pedido para PROBLEMAS COM PAGAMENTO
            @pedido.status_id = Status.where(["codigo = '13' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
            # Salva as modificações
            @pagamento.save
            @parcela.save
            @pedido.save
            #redirect_to pedido_path(@pedido), :notify => 'ERRO!!! Houve divergencia entre o valor do pagamento registrado e o informado pelo PAGAMENTO DIGITAL. Acesse novamente o PAGAMENTO DIGITAL para confirir os valores.'
          end
       end
    rescue
      logger.fatal '==> ERRO: '+ $!.to_s
      logCritico("pagamento_pedido_controller => retorno_pag_seguro = ERRO: " + $!.to_s)
      logPedido(request.remote_ip, -1, -1, "[I] ERRO no Retorno de pagamento PAG SEGURO: " + $!.to_s)
    end
  end


  # =================
  # FUNÇÕES DE APOIO
  # =================

  # Verifica se a parcela contem um pagamento
  def check_parcela_n_pagamento(parcela_id)
    # Checa se já existe pagamento para essa parcela. Se existir o cliente não pode criar um novo pagamento,
    # caso contrário, o pagamento é criado.
    if Adm::ParcelaPedido.find(parcela_id).pagamento_pedido.nil?
      return true
    else
      return false
    end
  end  

  # cria um novo registro na tabela adm_pagamento_pedido_historico  
  def gravaHistoricoPagamento(pagamento)
    historico = Adm::PagamentoPedidoHistorico.new(:pagamento_pedido_id => pagamento.id,
    :pagamento_pedido_empresa_id => pagamento.pagamento_pedido_empresa_id,
    :parcela_pedido_id => pagamento.parcela_pedido_id,
    :valor => pagamento.valor,
    :status_id => pagamento.status_id,
    :retorno_completo => pagamento.retorno_completo,
    :cod_transacao => pagamento.cod_transacao)
    historico.save
  end

  # ====================
  # FUNÇÕES DE VALIDAÇÃO
  # ====================

  protected

  # Verifica se um pagamento está em codições de ser modificado
  def check_status_pagamento
    # Só é possível modificar o pagamento se ele for PRÉ-PAGAMENTO ou for NÃO APROVADO.
    # Lembrando que pagamentos CANCELADOS não podem voltar porque tiveram suas parcelas
    # canceladas
    status_id = Adm::PagamentoPedido.find(params[:id]).status_id
    if (status_id == Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id) or (status_id == Status.where(["codigo = '1' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id) or (status_id == Status.where(["codigo = '2' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id)
      return true
    else
      logPedido(request.remote_ip, @pagamento_pedido.parcela_pedido.pedido_id, -1, "O pagamento foi bloqueado por estar com STATUS incompativel (ID do Pagamento = " + params[:id] + ")")
      redirect_to(:back, :notice => 'O pagamento não foi permitido')
    end
  end  
end
