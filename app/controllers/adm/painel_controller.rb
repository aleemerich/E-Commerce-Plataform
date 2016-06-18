# encoding: UTF-8
class Adm::PainelController < ApplicationController
  before_filter :permissao
  before_filter :verificacao_muda_status, :only => [:andamentos, :despacho, :duvida]
  layout "adm"
  
  def index
    # config de layout     
    @layout = Array.new()
    @layout[0] = "painel" # menu     
    @layout[1] = "Painel" # titulos     
    @layout[2] = "slogan" # subtitulo_css     
    @layout[3] = "As lista de pedido é atualizada automaticamente" # subtitulo_css     
    @layout[4] = "" #subtitulo_url
    @layout[5] = "/adm/painel/search" #busca_url

    # paginacao
    if params[:pag]
      @offset = params[:pag].to_i
    else
      @offset = 0
    end
    
    # criando a lista
    @adm_pedidos = Adm::Pedido.limit(100).order("updated_at DESC").offset(@offset).all
    # TODO: Verificar se haverá status que só a Arich poderá ver
    # filtrando pela permissao do usuário os registros que ele pode ver
    
    if @adm_pedidos.length == 0 and params[:pag]
        redirect_to(adm_pedidos_path, :notice => 'Não ha mais pedidos')
    else
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @adm_pedidos }
      end    
    end
  end
  
  def index_ajax_tabela
    # Obtendo os dados atuais
    @adm_pedidos = Adm::Pedido.limit(100).order("updated_at DESC").offset(@offset).all
    render :layout => false
  end
  
  def show
    @adm_pedido = Adm::Pedido.find(params[:id])

    # config de layout     
    @layout = Array.new     
    @layout[0] = "painel" # menu     
    @layout[1] = "Detalhe do pedido"   
    @layout[2] = "sloganD"     
    apoio = '<a target="_blank" href="' + impressao_pedido_path(@adm_pedido) + '">[Imprimir esse pedido]</a> | '
    apoio += '<a href="mailto:' + @adm_pedido.cliente.email + '">[Enviar um e-mail ao cliente]</a> | ' 
    apoio += '<a href="/adm/clientes/' + @adm_pedido.cliente.id.to_s + '">[Ficha do cliente]</a>' 
    @layout[3] = apoio
    @layout[4] = ""
    @layout[5] = "/adm/painel/search"
    
    # Controla campos extra no HTML
    @andamento = 'sem_acao'
    
    # Etapas do pedido 
    # legenda: (DESCRIÇÃO DO STATUS(código))

    # Etapa 1 - O cliente está montando o pedido (PRÉ-PEDIDO (0))
    # então o funcionário não pode intervir
    
    # Etapa 2 - O cliente solicita uma análise de desconto (AGUARDANDO ANÁLISE DE DESCONTO(5))
    # e quando a análise for feita, um e-mail será enviado dizendo que a análise está pronta
    if  @adm_pedido.status.codigo == '5'
      @andamento = 'orcamento'
      # permite a ação de CANCELAR (1)
      # LEMBRETE Essa ação foi retirada por causa do filtro de validação nas mudanças de STATUS
      #@adm_pedido_status = Status.where(["codigo IN('1') and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).all

    # Etapa 3 - O cliente fechou o pedido e está fazendo pagamento (AGUARDANDO PAGAMENTO(4))
    # mas o funcionário pode intervir no pedido para cancelá-lo (em caso de problemas)
    # ou dar prosseguimento com as execuções
    
    elsif  @adm_pedido.status.codigo == '3'
      # permite a ação de CANCELAR(1), EM EXECUÇÃO(6), AGUARDANDO EXECUÇÃO(4)
      @adm_pedido_status = Status.where(["codigo IN('1', '4', '6') and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).all

    # Etapa 4 - O pedido teve a parcela 1 paga (no caso de pagamento a vista) ou
    # ja foi liberado para execução (no caso de não ter parcelas com pagamento a vista)
    # e um e-mail foi enviado ao cliente informando (AGUARDANDO EXECUÇÃO(4))
    
    elsif  @adm_pedido.status.codigo == '4'
      # permite a ação de CANCELAR(1), DUVIDA(10), AGUARDANDO FORNECEDOR(11), EM EXECUÇÃO(6)
      @adm_pedido_status = Status.where(["codigo IN('1', '10', '11', '6') and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).all
    

    # Etapa 5 - O pedido está sendo atendido e um e-mail foi enviado ao cliente
    # informando que seu pedido está em execução (EM EXECUÇÃO(6))
    
    elsif  @adm_pedido.status.codigo == '6'
      # Essa análise indentifica se o pedido precisa ser despachado
      if @adm_pedido.valor_envio > 0
        # em caso de necessidade de despacho, o sistema pedirá ao funcionario
        # que insira o código de rastreio, quando houver
        @andamento = 'despacho'
        # permite a ação de CANCELAR(1), DUVIDA(10), AGUARDANDO FORNECEDOR(11), DESPACHADO(7)
        @adm_pedido_status = Status.where(["codigo IN('1', '10', '11', '7') and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).all
      else
        # permite a ação de CANCELAR(1), DUVIDA(10), AGUARDANDO FORNECEDOR(11), CONCLUIDO(9)
        @adm_pedido_status = Status.where(["codigo IN('1', '10', '11', '9') and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).all
      end  

    # Etapa 5A - Caso o pedido esteja como DUVIDA(10) o sistema possibilitará que o 
    # funcionário envie a dúvida ou dê andamento no pedido
    elsif @adm_pedido.status.codigo == '10' 
      # em caso de dúvida, o sistema pedirá ao funcionario
      # que forneça a dúvida para enviar ao cliente.
      @andamento = 'duvida'
      # permite a ação de CANCELAR(1), EM EXECUÇÃO(6), AGUARDANDO EXECUÇÃO(4)
      @adm_pedido_status = Status.where(["codigo IN('1', '4', '6') and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).all

    # Etapa 5B - Caso o pedido esteja como AGUARDANDO FORNECEDOR(11)
    # o sistema possibilitará que o funcionário dê andamento no pedido
    elsif @adm_pedido.status.codigo == '11' 
      # permite a ação de CANCELAR(1), EM EXECUÇÃO(6), AGUARDANDO EXECUÇÃO(4)
      @adm_pedido_status = Status.where(["codigo IN('1', '4', '6') and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).all


    # Etapa 6 - Caso o pedido tenha sido DESPACHADO(7), o sistema 
    # aguardará o funcionário dar baixa como entregue

    elsif  @adm_pedido.status.codigo == '7'
      # permite a ação de CANCELAR(1), ENTREGE(8)
      @adm_pedido_status = Status.where(["codigo IN('1', '8') and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).all

    # Etapa EXTRA 1 - Caso o haja necessidade, o funcionário poderá 
    # recolocar o pedido em EM EXECUÇÃO(6) ou em AGUARDANDO EXECUÇÃO(4)
    # por problemas no pedido ou cancelamento indevido

    elsif  @adm_pedido.status.codigo == '8' or @adm_pedido.status.codigo == '9'
      # permite a ação de CANCELADO(1), EM EXECUÇÃO(6), AGUARDANDO EXECUÇÃO(4)
      @adm_pedido_status = Status.where(["codigo IN('1', '4', '6') and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).all

    # Etapa EXTRA 2 - Caso o haja necessidade, o funcionário poderá 
    # recolocar um pedido CANCELADO(1) em PRE-PEDIDO(0) novamente, reiniciando
    # o ciclo do projeto, inclusive das parcelas e pagamentos

    elsif  @adm_pedido.status.codigo == '1'
      # permite a ação de  PRE-PEDIDO(0)
      @adm_pedido_status = Status.where(["codigo IN('0') and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).all
    end
  end
  
  def andamentos
    @adm_pedido = Adm::Pedido.find(params[:id])
    @adm_pedido.status_id = params[:id_status]
    
    # O cliente é notificado quando o status é
    # CANCELADO(1), EM EXECUÇÃO(6), AGUARDANDO FORNECEDOR(11), DESPACHADO(7), CONCLUIDO(9) ou ENTREGE(8)
    if ['1','6','11','7','9','8'].include?(Status.find(params[:id_status]).codigo)
      begin  
        Notificacao.cliente_status(@adm_pedido, params[:id_status]).deliver
      rescue
        logger.fatal "painel_controller => desconto -> Notificacao.cliente_desconto = ERRO: " + $!.to_s
      end
    end

    # Analizar se é um cancelamento, pois isso envolve
    # cancelar todas as parcelas pendentes (não pagas)
    # e cancelar todos os pagamentos (não pagos)
    if Status.find(params[:id_status]).codigo == '1'
      @adm_pedido.parcela_pedido.each do |parcela|
        # verificando se parcela não é PAGA(1) ou PAGA DIRETAMENTE (3)
        # porque parcelas assim não podem ser alteradas
        if parcela.status.codigo != '1' and parcela.status.codigo != '3'
          # cancelando as parcelas pendentes
          parcela.status_id = Status.where(["codigo = '4' and area_id = ?", Area.select('id').where(["codigo = 8"]).first]).first.id
          parcela.save
          # Lembrete: Não ha sentido em cancelar pagamentos internos, uma vez
          # que estes geralmente já estão em andamento ou já se encerraram,
          # com exceção dos pagamentos com o status de PRÉ-PAGAMENTO(0)
          if !parcela.pagamento_pedido.nil?
            # cancelando os pagamentos pendentes com o status de PRÉ-PAGAMENTO(0)
            if parcela.pagamento_pedido.status.codigo == '0'
              pagamento = parcela.pagamento_pedido
              pagamento.status_id = Status.where(["codigo = '5' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id
              pagamento.save
            end
          end
        end 
      end
    end
    
    if @adm_pedido.save
      logPedido(request.remote_ip, @adm_pedido.id, session[:usuario].id, "O status do pedido foi motificado para " + @adm_pedido.status.descricao)
      redirect_to(show_adm_painel_path(@adm_pedido), :notice => 'Status modificado com sucesso')
    else
      logPedido(request.remote_ip, @adm_pedido.id, session[:usuario].id, "[I] Problemas para modificar o status do pedido")
      redirect_to(show_adm_painel_path(@adm_pedido), :notice => 'Problemas ao modificado o status')
    end
  end

  def desconto
    @adm_pedido = Adm::Pedido.find(params[:id])
    # Atualizando o pedido com os dados enviados
    @adm_pedido.valor_desconto = params[:valor_desconto]
    @adm_pedido.justificativa_desconto = params[:justificativa_desconto]
    
    # Efetuando o desconto
    # TODO: Duvida! Como o Rails reconhece a função se não chamei o
    # mudulo e nem a Adm::ItemPedido (onde tem o módulo)
    calculoTotal(@adm_pedido)
    
    # Voltando o pedido a PRE-PEDIDO(0)
    @adm_pedido.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id

    if @adm_pedido.save
      begin  
        Notificacao.cliente_desconto(@adm_pedido).deliver
        redirect_to(show_adm_painel_path(@adm_pedido), :notice => 'A análise de desconto foi feita e um e-mail de notificação ao cliente foi enviado.')
        logPedido(request.remote_ip, @adm_pedido.id, session[:usuario].id, "A análise de desconto foi feita e um e-mail de notificação ao cliente foi enviado.")
      rescue
        logger.fatal "painel_controller => desconto -> Notificacao.cliente_desconto = ERRO: " + $!.to_s
        redirect_to(show_adm_painel_path(@adm_pedido), :notice => 'A análise de desconto foi feita mas o e-mail de notificação ao cliente não foi enviado.')
        logPedido(request.remote_ip, @adm_pedido.id, session[:usuario].id, "painel_controller => desconto -> Notificacao.cliente_desconto = ERRO: " + $!.to_s)
      end
    else
      redirect_to(adm_painel_path, :notice => 'Problemas ao gravar os dados de desconto')
      logPedido(request.remote_ip, params[:id], session[:usuario].id, "painel_controller => desconto = ERRO: Problemas ao gravar um desconto")
   end
  end
    
  def despacho
    @adm_pedido = Adm::Pedido.find(params[:id])
    @adm_pedido.cod_rastreio = params[:cod_rastreio]
    @adm_pedido.status_id = Status.where(["codigo = '7' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id

    # Voltando o pedido a DESPACHADO(7)
    @adm_pedido.status_id = Status.where(["codigo = '7' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id

    if @adm_pedido.save
      begin  
        Notificacao.cliente_despachado(@adm_pedido).deliver
        redirect_to(show_adm_painel_path(@adm_pedido), :notice => 'O status do pedido foi alterado para DESPACHADO e um e-mail de notificação ao cliente foi enviado.')
        logPedido(request.remote_ip, @adm_pedido.id, session[:usuario].id, "O status do pedido foi alterado para DESPACHADO e um e-mail de notificação ao cliente foi enviado.")
      rescue
        logger.fatal "painel_controller => despacho -> Notificacao.cliente_despachado = ERRO: " + $!.to_s
        redirect_to(show_adm_painel_path(@adm_pedido), :notice => 'O status do pedido foi alterado para DESPACHADO mas o e-mail de notificação ao cliente não foi enviado.')
        logPedido(request.remote_ip, @adm_pedido.id, session[:usuario].id, "[I] O status do pedido foi alterado para DESPACHADO mas o e-mail de notificação ao cliente não foi enviado.")
      end
    else
      redirect_to(adm_painel_path, :notice => 'Problemas ao gravar os dados de despacho')
      logPedido(request.remote_ip, @adm_pedido.id, session[:usuario].id, "[I] painel_controller => desconto = ERRO: Problemas ao gravar os dados de despacho")
   end
  end

  def duvida
    begin  
      @adm_pedido = Adm::Pedido.find(params[:id])
      Notificacao.cliente_duvida(@adm_pedido, params[:duvida]).deliver
      redirect_to(show_adm_painel_path(@adm_pedido), :notice => 'Sua dúvida foi enviada ao cliente e será respondida no e-mail "duvida@rmgraficarapida.com.br".')
    rescue
      logCritico("painel_controller => duvida -> Notificacao.cliente_duvida = ERRO: " + $!.to_s)
      redirect_to(adm_painel_path, :notice => 'Problemas ao enviar a dúvida ao cliente.')
    end
  end
  
  def search
    # config de layout     
    @layout = Array.new()
    @layout[0] = "painel" # menu     
    @layout[1] = "Busca de Pedido" # titulos     
    @layout[2] = "slogan" # subtitulo_css     
    @layout[3] = 'Resultado da busca por "' + params[:busca] + '"'    
    @layout[4] = "" #subtitulo_url
    @layout[5] = "/adm/painel/search" #busca_url

    # criando a lista
    @adm_pedidos = Adm::Pedido.where('id LIKE "%' + params[:busca] + '%"').all

    # TODO: Verificar se haverá status que só a Arich poderá ver
    # filtrando pela permissao do usuário os registros que ele pode ver
    
    if @adm_pedidos.length == 0 and params[:pag]
        redirect_to(adm_pedidos_path, :notice => 'Não há pedidos com esses critérios.')
    else
      respond_to do |format|
        format.html # search.html.erb
        format.xml  { render :xml => @adm_pedidos }
      end    
    end
  end



  def verificacao_muda_status
    if Adm::Pedido.find(params[:id]).parcela_pedido.length != 0 
      true
    else
      redirect_to(adm_pedidos_path, :notice => 'Ação não permitida porque esse pedido não tem parcelas ou pagamentos.')
    end
  end
end
