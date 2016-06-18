# encoding: UTF-8
class PedidosController < ApplicationController
  # Verifica se o usuário está autenticado. Essa função está
  # declarada em application_controller.rb
  before_filter :permissao_publico 
  skip_before_filter :permissao_publico, :only => [:impressao]

  # Valida se um pedido não está com valor minimo
  before_filter :valida_se_minimo, :only => [:envio, :envio_rec, :parcela, :parcela_rec, :final]
  
  # Valida se um pedido esta com o STATUS de PRÉ-PEDIDO, status esse que permite
  # realizar as ações previstas nese filtro.
  before_filter :valida_se_prepedido, :only => [:destroy, :envio, :envio_rec, :parcela, :parcela_rec]

  layout "publico"
  
  def index
    # Produtos em lançamento
    @publico_produtos_recentes = Adm::Produto.limit(5).order('created_at DESC').all

    @cliente = Adm::Cliente.find(session[:cliente].id)
    logCliente(request.remote_ip, session[:cliente].id, -1, "Acessando tela de LISTA de Pedidos")
  end
  
  def show
    @pedido = Adm::Pedido.find(params[:id])
    logCliente(request.remote_ip, session[:cliente].id, -1, "Acessando tela de DETALHE de Pedidos")
  end

  def new
    @pedido = Adm::Pedido.new
    @pedido.cliente_id = session[:cliente].id
    @pedido.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
    @pedido.total = 0.0 # TODO: Ajustar isso no banco como DEFAULT, quando der
    if @pedido.save
      logPedido(request.remote_ip, @pedido.id, -1, "Novo pedido criado")
      logCliente(request.remote_ip, session[:cliente].id, -1, "Novo pedido criado (ID pedido = " + @pedido.id.to_s + " )")
      redirect_to(pedido_path(@pedido))
    else
      logPedido(request.remote_ip, -1, -1, "[I] Problemas ao criar um novo pedido")
      logCliente(request.remote_ip, session[:cliente].id, -1, "[I] Problemas ao criar um novo pedido")
      redirect_to(pedidos_path, :notice => 'Não foi possivel criar um novo pedido')
    end
  end

  def destroy
    @pedido = Adm::Pedido.find(params[:id])
    @pedido.status_id = Status.where(["codigo = '1' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
    if @pedido.save
      logPedido(request.remote_ip, @pedido.id, -1, "Pedido cancelado")
      logCliente(request.remote_ip, session[:cliente].id, -1, "Pedido cancelado (ID pedido = " + @pedido.id.to_s + " )")
      redirect_to(pedidos_path, :notice => 'O pedido esta cancelado')
    else
      logPedido(request.remote_ip, @pedido.id, -1, "[I] Problemas para cancelar um pedido")
      logCliente(request.remote_ip, session[:cliente].id, -1, "[I] Problemas ao cancelar um novo pedido")
      redirect_to(:back, :notice => 'Não foi possivel cancelar o pedido')
    end
  end

  def envio
    @pedido = Adm::Pedido.find(params[:id])
    @enderecos = Adm::Endereco.all(:conditions => ['cliente_id = ? AND status_id = ?', @pedido.cliente_id, Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 2"]).first]).first.id])
    @forma_envios = Adm::FormaEnvio.all
    logCliente(request.remote_ip, session[:cliente].id, -1, "Acessando tela de CALCULO DE FRETE de Pedidos")
  end
  
  def envio_rec
    @pedido = Adm::Pedido.find(params[:id])
    
    if @pedido.update_attributes(params[:adm_pedido])
      calculoTotal(@pedido)
      logPedido(request.remote_ip, @pedido.id, -1, "Pedido atualizado com o valor do frete")
      logCliente(request.remote_ip, session[:cliente].id, -1, "Calculo de frete adicionado (ID pedido = " + @pedido.id.to_s + " )")
      redirect_to(parcela_pedido_path(@pedido))
    else
      logPedido(request.remote_ip, @pedido.id, -1, "[I] Problemas ao atualizar o pedido com o valor do frete")
      logCliente(request.remote_ip, session[:cliente].id, -1, "[I] Problemas ao inserir o valor de em um novo pedido")
      redirect_to(pedido_path(@pedido), :notice => 'Problemas ao atribuir um endereco a esse pedido')
    end
  end

  def parcela
    @pedido = Adm::Pedido.find(params[:id])

    # caso seja verificado qe não há parcelas
    # geradas, inicia o processo de geração das parcelas
    @parcela_pedidos = Array.new
    @forma_pagamentos = Array.new
    
    # calula todas as parcelas possíveis dentro do prazo permitido
    # vigente para cada atribuição. 
    # LEMBRETE: O "+1" na formula se deve ao fato do sistema não considerar horas
    # no armazenamento, então sem o "+1" o dia do vencimento em sí seria perdido
    @pedido.cliente.forma_pagamento.select{|f| f if f.dt_inicio <= DateTime.now and (f.dt_fim.blank? or (f.dt_fim+1) >= DateTime.now)}.each do |forma_pagamento|
      @parcela_pedidos << calcParcelas(forma_pagamento, @pedido.id, @pedido.total)
      @forma_pagamentos << forma_pagamento
    end 
    logCliente(request.remote_ip, session[:cliente].id, -1, "Acessando tela de PARCELAS de um pedido")
  end

  def parcela_rec
    @pedido = Adm::Pedido.find(params[:id])

    #calcula as parcelas novamente com o pagamento escolhido
    @parcelas = calcParcelas(Adm::FormaPagamento.find(params[:forma_pagamento_id]), @pedido.id, @pedido.total)
  
    #grava as parcelas geradas 
    parcela_id_temp = nil
    @parcelas.each do |parcela| 
      parcela.save
      if parcela.dt_vencimento <= DateTime.now
        parcela_id_temp = parcela.id
      end
    end 

    logPedido(request.remote_ip, @pedido.id, -1, "Parcelas criadas para esse pedido")
    logCliente(request.remote_ip, session[:cliente].id, -1, "Registrando as PARCELAS de um pedido")

    # Esse tratamento evita que um simples erro de envio de 
    # e-mail pare o processo como um todo
    begin
      # Envio de e-mail para cliente
      Notificacao.cliente_pedido_final(@pedido).deliver
    rescue
      logCritico("pedidos_controller => parcela_rec -> Notificacao.cliente_pedido_final = ERRO: " + $!.to_s)
    end    
      
    if parcela_id_temp.nil?
      # Pedido liberado para produção porque
      # não há dividas pendentes
      @pedido.status_id = Status.where(["codigo = '4' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
      @pedido.save
      logPedido(request.remote_ip, @pedido.id, -1, "Pedido LIBERADO, sem pagamentos a vista")
      logCliente(request.remote_ip, session[:cliente].id, -1, "Pedido LIBERADO, sem pagamentos a vista")
      redirect_to(final_pedido_path(@pedido))
    else
      # Pedido bloqueado para produção porque
      # há necessidade de se quitar dividas pendentes
      @pedido.status_id = Status.where(["codigo = '3' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
      @pedido.save
      logPedido(request.remote_ip, @pedido.id, -1, "Direcionando para o pagamento de uma parcela (ID parcela = " + parcela_id_temp.to_s + " )")
      logCliente(request.remote_ip, session[:cliente].id, -1, "Direcionando para o pagamento de uma parcela (ID parcela = " + parcela_id_temp.to_s + " )")
      redirect_to(new_pagamento_pedido_path(parcela_id_temp))
    end
  end

  def final
    @pedido = Adm::Pedido.find(params[:id])
    logPedido(request.remote_ip, @pedido.id, -1, "Fim do processo de parcelamento e pagamento de um pedido")
    logCliente(request.remote_ip, session[:cliente].id, -1, "Acessando tela FINAL de pedido")
  end

  def impressao
    @pedido = Adm::Pedido.find(params[:id])
    render :layout => false
  end


  # =================
  # FUNÇÕES DE APOIO
  # =================

  # Esta função é uma cópia da função original contida em adm/parcela_pedidos_controller.rb
  # TODO: É preciso revistar e modificar isso para não haver cópia de códigos
  def calcParcelas(pagamento, pedido_id, total)
    parcelas = Array.new
    juro_atraso = 0.05 #TODO: Está HARD, precisa ser atribuido pelo sistema
    if pagamento.perc_pgto_avista == 1.00
      #parcela única com pagamento A VISTA
      parcela = Adm::ParcelaPedido.new
      parcela.pedido_id = pedido_id
      parcela.pagamento_id = pagamento.id
      parcela.dt_vencimento = DateTime.now
      parcela.valor = (total * (1 - pagamento.perc_desconto))
      parcela.perc_juros_atraso = juro_atraso
      parcela.perc_juros = 0.0000
      parcela.nro_parcela = 1
      parcela.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 8"]).first]).first.id
      parcelas << parcela
    else
      i = 1
      while i <= pagamento.parcelas
          parcela = Adm::ParcelaPedido.new
          parcela.pedido_id = pedido_id
          parcela.pagamento_id = pagamento.id
          parcela.perc_juros_atraso = juro_atraso
          parcela.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 8"]).first]).first.id
  
          if pagamento.perc_pgto_avista > 0.00 and i == 1
            #parcela A VISTA
            parcela.perc_juros = 0.0000
            parcela.dt_vencimento = DateTime.now
            parcela.valor = (total * pagamento.perc_pgto_avista)
            total -= parcela.valor
            parcela.nro_parcela = i
            parcelas << parcela
          else
            #demais parcelas
            parcela.perc_juros = pagamento.perc_juros_mes
            parcela.dt_vencimento = DateTime.now + (30 * (pagamento.perc_pgto_avista > 0.00 ? i-1 : i))
            parcela.valor = total / (pagamento.perc_pgto_avista > 0.00 ? pagamento.parcelas - 1 : pagamento.parcelas)
            parcela.valor += parcela.valor * pagamento.perc_juros_mes
            parcela.nro_parcela = i
            parcelas << parcela
          end
          i += 1
      end
    end
    return parcelas
  end

  # ====================
  # FUNÇÕES DE VALIDAÇÃO
  # ====================

  protected

  # Verifica se o pedido está como PRÉ-PEDIDO. Essa condição
  # é necessária para que os pedidos não possam ser alterados
  # editados ou cancelados após estarem fechados.
  def valida_se_prepedido
    if Adm::Pedido.find(params[:id]).status.codigo == '0'
      true
    else
      logPedido(request.remote_ip, params[:id], -1, "[I] Tentativa de acesso a acao referente a pedido negada. Essa tentiva mostra que o cliente esta acessando acoes de pedido via URL e precisa de atencao")
      logCliente(request.remote_ip, session[:cliente].id, -1, "[I] Este cliente esta tentando acessar uma acao para pedido de forma indireta e precisa de atencao")
      logCritico("pedidos_controller => valida_se_prepedido -> AVISO: Tentativa de acesso a acao referente a pedido negada. Essa tentiva mostra que o cliente esta acessando acoes de pedido via URL e precisa de atencao.")
      redirect_to(pedido_path(params[:id]), :notice => 'Acesso negado! Essa tentativa de acesso e considerada como amenaca e um comunicado ao ADM do sistema foi emitido.')
    end
  end

  def valida_se_minimo
    if Adm::Pedido.find(params[:id]).total > 30.0 #TODO: Está HARD CODE, precisa ser substituido por config
      true
    else
      redirect_to(pedido_path(params[:id]), :notice => 'Você não pode realizar essa operação com um pedido cujo total não seja superior a R$ 30,00.')
    end
  end
end
