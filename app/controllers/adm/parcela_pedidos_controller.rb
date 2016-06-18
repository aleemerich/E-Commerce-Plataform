# encoding: UTF-8
class Adm::ParcelaPedidosController < ApplicationController
  before_filter :permissao
  layout "adm"

  def index
    # config de layout     
    @layout = Array.new()
    @layout[0] = "parcela" # menu     
    @layout[1] = "Parcelas" # titulos     
    @layout[2] = "slogan" # subtitulo_css     
    @layout[3] = "" # subtitulo_css     
    @layout[4] = "" #subtitulo_url
    @layout[5] = "/adm/parcela_pedidos/search" #busca_url

    # paginacao
    if params[:pag]
      @offset = params[:pag].to_i
    else
      @offset = 0
    end
    
    # criando a lista
    @adm_parcela_pedidos_full = Adm::ParcelaPedido.limit(20).order('id DESC').offset(@offset).all

    # TODO: Verificar se haverá status que só a Arich poderá ver
    # filtrando pela permissao do usuário os registros que ele pode ver
    
    #if session[:usuario].status.area.codigo != '0'
      #@adm_parcela_pedidos = @adm_parcela_pedidos_full.find_all {|p|  p.status.codigo == '0' or p.status.codigo == '1' }
    #else
    @adm_parcela_pedidos = @adm_parcela_pedidos_full
    #end

    if @adm_parcela_pedidos.length == 0 and params[:pag]
        redirect_to(adm_parcela_pedidos_path, :notice => 'Não há mais parcelas')
    else
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @adm_parcela_pedidos }
      end    
    end
  end

  def cancel
    @adm_parcela_pedido = Adm::ParcelaPedido.find(params[:id])
    # verificando se parcela não é PAGA(1), PAGA DIRETAMENTE (3), AGUARDANDO PAGAMENTO (5) ou BLOQUEADO (6)
    # porque parcelas assim não podem ser alteradas
    if @adm_parcela_pedido.pedido.parcela_pedido.select{|p| p if p.status.codigo == '1' or p.status.codigo == '3' or p.status.codigo == '5' or p.status.codigo == '6'}.length == 0
      @adm_parcela_pedido.pedido.parcela_pedido.each do |parcela|
          # cancelando as parcelas pendentes
          parcela.status_id = Status.where(["codigo = '4' and area_id = ?", Area.select('id').where(["codigo = 8"]).first]).first.id
          parcela.save
          # Lembrete: Não ha sentido em cancelar pagamentos internos, uma vez
          # que estes geralmente já estão em andamento, com exceção dos pagamentos
          # com o status de PRÉ-PAGAMENTO(0)
          if !parcela.pagamento_pedido.nil?
            # cancelando os pagamentos com o status de PRÉ-PAGAMENTO(0)
            if parcela.pagamento_pedido.status.codigo == '0'
              pagamento = parcela.pagamento_pedido
              pagamento.status_id = Status.where(["codigo = '5' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id
              pagamento.save
            end
          end
      end
      # voltando o pedido a pré-pedido para que o cliente possa
      # fazer novamente os parcelamento e pagamentos
      pedido = @adm_parcela_pedido.pedido
      pedido.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
      pedido.save

      logPedido(request.remote_ip, @adm_parcela_pedido.pedido_id, session[:usuario].id, "As parcelas desse pedido foram canceladas")
      redirect_to(adm_parcela_pedidos_path, :notice => 'Parcelas canceladas')
    else
      logPedido(request.remote_ip, @adm_parcela_pedido.pedido_id, session[:usuario].id, "As parcelas não forma canceladas porque ha pagamentos pendentes")
      redirect_to(adm_parcela_pedidos_path, :notice => 'As parcelas não podem ser canceladas porque algumas ja estão pagas ou em processo de pagamento')
    end
  end
  
  def show
    @adm_parcela_pedido = Adm::ParcelaPedido.find(params[:id])
    # config de layout     
    @layout = Array.new()
    @layout[0] = "parcela" # menu     
    @layout[1] = "Parcelas"# titulos     
    @layout[2] = "slogan" # subtitulo_css     
    @layout[3] = "Pedido de Compra " + "%05d" % @adm_parcela_pedido.pedido_id.to_s  # subtitulo_css     
    @layout[4] = "" #subtitulo_url
    @layout[5] = "/adm/parcela_pedidos/search" #busca_url
    
    # Analisa quais ações serão permitidas ao usuário
    # Situação 1 - Parcela EM DIA(0) ou EM ATRASO(1) e nenhum pagamento atrelado
    if (@adm_parcela_pedido.status.codigo == '0' or @adm_parcela_pedido.status.codigo == '2') and @adm_parcela_pedido.pagamento_pedido.nil?
      # permite a ação de PAGO DIRETAMENTE(3) e CANCELAMENTO(4)
      @adm_parcela_pedido_status = Status.where(["codigo IN('3', '4') and area_id = ?", Area.select('id').where(["codigo = '8'"]).first]).all
    end
    # LEMBRETE: Não foi lembrando de outras situações
  end
  
  def andamentos
    @adm_parcela_pedido = Adm::ParcelaPedido.find(params[:id])
    @adm_parcela_pedido.status_id = params[:id_status]
    if @adm_parcela_pedido.save
      # Se o status da parcela é "PAGO DIRETAMENTE(3)" e
      # o pedido está esperando pagamento, libera o pedido
      if @adm_parcela_pedido.status.codigo == '3' and @adm_parcela_pedido.pedido.status_id = Status.where(["codigo = '3' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
        # Muda status para AGUARDANDO PRODUCAO
        @adm_parcela_pedido.pedido.status_id = Status.where(["codigo = '4' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
        @adm_parcela_pedido.pedido.save
      end
      redirect_to(adm_parcela_pedidos_path, :notice => 'Status modificado com sucesso')
    else
      redirect_to(adm_parcela_pedidos_path, :notice => 'Problemas ao modificado o status')
    end
  end

  def search
    # config de layout     
    @layout = Array.new()
    @layout[0] = "parcela" # menu     
    @layout[1] = "Busca de Parcelas" # titulos     
    @layout[2] = "slogan" # subtitulo_css     
    @layout[3] = 'Resultado da busca por "' + params[:busca] + '"'    
    @layout[4] = "" #subtitulo_url
    @layout[5] = "/adm/parcela_pedidos/search" #busca_url

    # criando a lista
    @adm_parcela_pedidos_full = Adm::ParcelaPedido.where('id LIKE "%' + params[:busca] + '%" OR pedido_id LIKE "%' + params[:busca] + '%"').all
    
    # TODO: Verificar se haverá status que só a Arich poderá ver
    # filtrando pela permissao do usuário os registros que ele pode ver
    
    #if session[:usuario].status.area.codigo != '0'
      #@adm_parcela_pedidos = @adm_parcela_pedidos_full.find_all {|p|  p.status.codigo == '0' or p.status.codigo == '1' }
    #else
    @adm_parcela_pedidos = @adm_parcela_pedidos_full
    #end

    if @adm_parcela_pedidos.length == 0 and params[:pag]
        redirect_to(adm_parcela_pedidos_path, :notice => 'Não foram encontrados parcelas com esse critério')
    else
      respond_to do |format|
        format.html # search.html.erb
        format.xml  { render :xml => @adm_parcela_pedidos }
      end    
    end
  end
  
=begin  
  ##################################################################################################  
  ==> Essas ações foram criadas no incio do projeto visando simular e testar ações de clientes, 
  ==>  contudo não foi visto sentido em deixá-las aqui para serem usadas pelos pelo ADM do sistema
  ##################################################################################################  
  before_filter :pedido_aberto, :only => [:new]  

  def new
    @adm_pedido = Adm::Pedido.find(params[:pedido_id])

    # caso seja verificado que não há parcelas
    # geradas, inicia o processo de geração das parcelas
    @adm_parcela_pedidos = Array.new
    @adm_forma_pagamentos = Array.new
    
    # calula todas as parcelas possíveis dentro do prazo permitido
    # vigente para cada atribuição. 
    # LEMBRETE: O "+1" na formula se deve ao fato do sistema não considerar horas
    # no armazenamento, então sem o "+1" o dia do vencimento em sí seria perdido
    @adm_pedido.cliente.forma_pagamento.select{|f| f if f.dt_inicio <= DateTime.now and (f.dt_fim.blank? or (f.dt_fim+1) >= DateTime.now)}.each do |forma_pagamento|
      @adm_parcela_pedidos << calcParcelas(forma_pagamento, @adm_pedido.id, @adm_pedido.total)
      @adm_forma_pagamentos << forma_pagamento
    end 

    # config de layout     
    @layout = Array.new()
    @layout[0] = "parcela" # menu     
    @layout[1] = "Parcelas"# titulos     
    @layout[2] = "slogan" # subtitulo_css     
    @layout[3] = "Pedido de Compra " + "%05d" % params[:pedido_id]  # subtitulo_css     
    @layout[4] = "" #subtitulo_url
    @layout[5] = "/adm/parcela_pedidos/search" #busca_url
    
  end

  def create
    @adm_pedido = Adm::Pedido.find(params[:pedido_id])

    #calcula as parcelas novamente com o pagamento escolhido
    @adm_parcelas = calcParcelas(Adm::FormaPagamento.find(params[:forma_pagamento_id]), @adm_pedido.id, @adm_pedido.total)
  
    #grava as parcelas geradas 
    parcela_id_temp = nil
    @adm_parcelas.each do |parcela| 
      parcela.save
      if parcela.dt_vencimento <= DateTime.now
        parcela_id_temp = parcela.id
      end
    end 

    if parcela_id_temp.nil?
      # Pedido liberado para produção porque
      # não há dividas pendentes
      @adm_pedido.status_id = Status.where(["codigo = '4' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
      @adm_pedido.save
      redirect_to(finally_adm_pedido_path(@adm_pedido))
    else
      # Pedido bloqueado para produção porque
      # há necessidade de se quitar dividas pendentes
      @adm_pedido.status_id = Status.where(["codigo = '3' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
      @adm_pedido.save
      redirect_to(new_adm_pagamento_pedido_path(parcela_id_temp))
    end
  end
  
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

  # verifica se o pedido já tem parcelas geradas
  # ou sejam, se ele ja foi processado
  def pedido_aberto
    pedido = Adm::Pedido.find(params[:pedido_id])
    #antiga análise => if pedido.parcela_pedido.length > 0 
    if pedido.status.codigo != '0' and pedido.status.codigo != '5'
      redirect_to(show_adm_painel_path(pedido), :notice => 'Esse pedido já foi processado')
    end  
  end
=end
end
