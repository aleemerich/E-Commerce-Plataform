# encoding: UTF-8
class Adm::PagamentoPedidosController < ApplicationController
  before_filter :permissao
  layout "adm"

  def index
    # config de layout     
    @layout = Array.new()
    @layout[0] = "pagamento" # menu     
    @layout[1] = "Pagamento" # titulos     
    @layout[2] = "slogan" # subtitulo_css     
    @layout[3] = "Lista dos pagamentos efetuados" # subtitulo_css     
    @layout[4] = "" #subtitulo_url
    @layout[5] = "/adm/pagamento_pedidos/search" #busca_url

    # paginacao
    if params[:pag]
      @offset = params[:pag].to_i
    else
      @offset = 0
    end
    
    # criando a lista
    @adm_pagamento_pedidos_full = Adm::PagamentoPedido.limit(20).order("updated_at DESC").offset(@offset).all

    # TODO: Verificar se haverá status que só a Arich poderá ver
    # filtrando pela permissao do usuário os registros que ele pode ver
    
    #if session[:usuario].status.area.codigo != '0'
      #@adm_pagamento_pedidos = @adm_pagamento_pedidos_full.find_all {|p|  p.status.codigo == '0' or p.status.codigo == '1' }
    #else
    @adm_pagamento_pedidos = @adm_pagamento_pedidos_full
    #end

    if @adm_pagamento_pedidos.length == 0 and params[:pag]
        redirect_to(adm_pagamento_pedidos_path, :notice => 'Não há mais pagamentos')
    else
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @adm_pagamento_pedidos }
      end    
    end
  end
  
  def search
    # config de layout     
    @layout = Array.new()
    @layout[0] = "pagamento" # menu     
    @layout[1] = "Busca de Pagamento" # titulos     
    @layout[2] = "slogan" # subtitulo_css     
    @layout[3] = 'Resultado da busca por "' + params[:busca] + '"'     
    @layout[4] = "" #subtitulo_url
    @layout[5] = "/adm/pagamento_pedidos/search" #busca_url

    # criando a lista
    @adm_pagamento_pedidos_full = Adm::PagamentoPedido.where('id LIKE "%' + params[:busca] + '%"').all

    # TODO: Verificar se haverá status que só a Arich poderá ver
    # filtrando pela permissao do usuário os registros que ele pode ver
    
    #if session[:usuario].status.area.codigo != '0'
      #@adm_pagamento_pedidos = @adm_pagamento_pedidos_full.find_all {|p|  p.status.codigo == '0' or p.status.codigo == '1' }
    #else
    @adm_pagamento_pedidos = @adm_pagamento_pedidos_full
    #end

    if @adm_pagamento_pedidos.length == 0 and params[:pag]
        redirect_to(adm_pagamento_pedidos_path, :notice => 'Não há mais pagamentos')
    else
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @adm_pagamento_pedidos }
      end    
    end
  end

=begin  
  ##################################################################################################  
  ==> Essas ações foram criadas no incio do projeto visando simular e testar ações de clientes, 
  ==>  contudo não foi visto sentido em deixá-las aqui para serem usadas pelos pelo ADM do sistema
  ##################################################################################################  

  def new
    @adm_parcela_pedido = Adm::ParcelaPedido.find(params[:parcela_id])
    @adm_pagamento_pedido = Adm::PagamentoPedido.new
    # config de layout     
    @layout = Array.new()
    @layout[0] = "pagamento" # menu     
    @layout[1] = "Forma de pagamento"# titulos     
    @layout[2] = "slogan" # subtitulo_css     
    @layout[3] = "Pedido de Compra " + "%05d" % @adm_parcela_pedido.pedido.id  # subtitulo_css     
    @layout[4] = "" #subtitulo_url
    @layout[5] = "/adm/pagamentos/search" #busca_url
  end
  
  def edit
    @adm_pagamento_pedido = Adm::PagamentoPedido.find(params[:id])
    if !checkPagamento(@adm_pagamento_pedido.status_id)
      redirect_to(session[:ultima_url], :notice => 'Essa operação foi bloqueada')
    end
    # config de layout     
    @layout = Array.new()
    @layout[0] = "pagamento" # menu     
    @layout[1] = "Forma de pagamento"# titulos     
    @layout[2] = "slogan" # subtitulo_css     
    @layout[3] = "Pedido de Compra " + "%05d" % @adm_pagamento_pedido.parcela_pedido.pedido.id  # subtitulo_css     
    @layout[4] = "" #subtitulo_url
    @layout[5] = "/adm/pagamentos/search" #busca_url
  end
  
  def create
    if Adm::ParcelaPedido.find(params[:adm_pagamento_pedido][:parcela_pedido_id]).pagamento_pedido.nil?
      @adm_pagamento_pedido = Adm::PagamentoPedido.new(params[:adm_pagamento_pedido]) 
      @adm_parcela_pedido = @adm_pagamento_pedido.parcela_pedido
      # config de layout     
      @layout = Array.new()
      @layout[0] = "pagamento" # menu     
      @layout[1] = "Confirme os dados" # titulos     
      @layout[2] = "slogan" # subtitulo_css     
      @layout[3] = "Pedido de compra "  + "%05d" % @adm_pagamento_pedido.parcela_pedido.pedido_id# subtitulo_css     
      @layout[4] = "" #subtitulo_url
      @layout[5] = "/adm/pagamento_pedidos/search" #busca_url
      
      @adm_pagamento_pedido.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id
      if @adm_pagamento_pedido.save
        #
      else
        redirect_to(session[:ultima_url], :notice => 'Problemas ao atribuir um pagamento a esse pedido')
      end
    else
      redirect_to(edit_adm_pagamento_pedido_path(Adm::ParcelaPedido.find(params[:adm_pagamento_pedido][:parcela_pedido_id]).pagamento_pedido.id), :notice => 'Já foi iniciado um pagamento para essa parcela, mas você pode modificá-lo.')
    end
  end
  
  def update
    @adm_pagamento_pedido = Adm::PagamentoPedido.find(params[:id])
    if checkPagamento(@adm_pagamento_pedido.status_id)
      if @adm_pagamento_pedido.update_attributes(params[:adm_pagamento_pedido])
        # config de layout     
        @layout = Array.new()
        @layout[0] = "pagamento" # menu     
        @layout[1] = "Confirme os dados" # titulos     
        @layout[2] = "slogan" # subtitulo_css     
        @layout[3] = "Pedido de compra "  + "%05d" % @adm_pagamento_pedido.parcela_pedido.pedido_id# subtitulo_css     
        @layout[4] = "" #subtitulo_url
        @layout[5] = "/adm/pagamento_pedidos/search" #busca_url
        render "create"
      else
        redirect_to(session[:ultima_url], :notice => 'Houve problemas ao modificar o pagamento')
      end
    else
      redirect_to(session[:ultima_url], :notice => 'O pagamento não foi permitido')
    end
  end
  
  #def show
    # LEMBRETE: Não foi lembrando de nenhuma aplicação para a implementação do
    # SHOW aja vista que a parte de pagamento é totalmente dependente de ação
    # dos agentes pagadores externos e que um PAGAMENTO é atrelado a uma parcela
    # logo não tem sentido agir no pagamento porque prejudica todo o fluxo
    # sistêmico de pedido. Pagamentos extras são baixados nas parcelas e não aqui.
  #end

  
  # Verifica se um pagamento está em codições de ser modificado
  def checkPagamento(status_id)
    # Só é possível modificar o pagamento se ele for PRÉ-PAGAMENTO ou for NÃO APROVADO.
    # Lembrando que pagamentos CANCELADOS não podem voltar porque tiveram suas parcelas
    # canceladas
    if (status_id == Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id) or (status_id == Status.where(["codigo = '1' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id) or (status_id == Status.where(["codigo = '2' and area_id = ?", Area.select('id').where(["codigo = 4"]).first]).first.id)
      return true
    else
      return false
    end
  end 
=end 
end