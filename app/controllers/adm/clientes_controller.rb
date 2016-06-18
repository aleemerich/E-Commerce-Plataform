# encoding: UTF-8
class Adm::ClientesController < ApplicationController
  before_filter :permissao
  
  layout "adm"
  # GET /adm/clientes(/pag/:pag)
  # GET /adm/clientes.xml(/pag/:pag)
  def index
    # config de layout     
    @layout = Array.new()
    @layout[0] = "cliente" # menu     
    @layout[1] = "Clientes" # titulos     
    @layout[2] = "sloganD2" # subtitulo_css     
    @layout[3] = "Adicionar um cliente" # subtitulo_css     
    @layout[4] = "clientes/new" #subtitulo_url
    @layout[5] = "clientes/search" #busca_url

    # paginacao
    if params[:pag]
      @offset = params[:pag].to_i
    else
      @offset = 0
    end

    # criando a lista
    @adm_clientes_full = Adm::Cliente.limit(20).order('id DESC').offset(@offset).all
    
    # filtrando pela permissao do usuário os registros que ele pode ver
    if session[:usuario].status.area.codigo != '0'
      @adm_clientes = @adm_clientes_full.find_all {|c|  c.status.codigo == '0' or c.status.codigo == '1' }
    else
      @adm_clientes = @adm_clientes_full
    end
    
    #fazendo o encaminhamento
    if @adm_clientes.length == 0 and params[:pag]
      redirect_to(adm_clientes_path, :notice => 'Não há mais clientes')
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @adm_clientes }
      end
    else
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @adm_clientes }
      end
    end
  end

  # GET /adm/clientes/1
  # GET /adm/clientes/1.xml
  def show
    # config de layout     
    @layout = Array.new()
    @layout[0] = "cliente" # menu     
    @layout[1] = "Ficha do Clientes" # titulos     
    @layout[2] = "sloganD3" # subtitulo_css     
    @layout[3] = 'COD: ' + "%07d" % params[:id]    
    @layout[4] = "" #subtitulo_url
    @layout[5] = "/adm/clientes/search" #busca_url

    @adm_cliente = Adm::Cliente.find(params[:id])
    
    # TODO: Atualizar essa ação, uma vez que o relacionamento
    # já traz esses dados
    
    # obtendo registros
    @adm_enderecos_full = Adm::Endereco.where(['cliente_id = ?', @adm_cliente.id]).all
    @adm_telefones_full = Adm::Telefone.where(['cliente_id = ?', @adm_cliente.id]).all
    
    # LEMBRETE
    # Para a edicao dos modelos endereco e telefone funcione, eh preciso 
    # criar uma funcao do application_helper que possibilita ativar ou
    # não o java script que abre o form de edicao.
    # Inclusive eh tb por isso que o DIV que faz o efeito light box fica
    # criado na pagina e não dinamicamente como o de costume.
    
    # filtrando pela permissao do usuário os registros que ele pode ver
    if session[:usuario].status.area.codigo == '0'
      @adm_enderecos = @adm_enderecos_full
      @adm_telefones = @adm_telefones_full
    else
      @adm_enderecos = @adm_enderecos_full.find_all {|e|  e.status.codigo == '0' }
      @adm_telefones = @adm_telefones_full.find_all {|t|  t.status.codigo == '0' }
    end
    
    # verificando se é uma edição de Endereco
    if params[:id_endereco]
      @adm_endereco = Adm::Endereco.find(params[:id_endereco])
    else
      @adm_endereco = Adm::Endereco.new
    end
    
    # verificando se é uma edição de Telefone
    if params[:id_telefone]
      @adm_telefone = Adm::Telefone.find(params[:id_telefone])
    else
      @adm_telefone = Adm::Telefone.new
    end
    
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @adm_cliente }
    end
  end

  # GET /adm/clientes/new
  # GET /adm/clientes/new.xml
  def new
    # config de layout     
    @layout = Array.new     
    @layout[0] = "cliente"     
    @layout[1] = "Novo Cliente"     
    @layout[2] = "slogan"     
    @layout[3] = "Cadastro de novo cliente"     
    @layout[4] = ""
    @layout[5] = "/adm/clientes/search" #busca_url

    @adm_cliente = Adm::Cliente.new
  end

  # GET /adm/clientes/1/edit
  def edit
    # config de layout     
    @layout = Array.new     
    @layout[0] = "cliente"     
    @layout[1] = "Ficha do Cliente"    
    @layout[2] = "slogan"     
    @layout[3] = "COD: " + "%07d" % params[:id]    
    @layout[4] = ""
    @layout[5] = "/adm/clientes/search" 

    @adm_cliente = Adm::Cliente.find(params[:id])
    
    #TODO: Criar resumos para informações adicionais
  end

  # GET /adm/usuarios/1/block   
  # GET /adm/usuarios/1/block.xml 
  def block     
    @adm_cliente = Adm::Cliente.find(params[:id])
    @adm_cliente.status_id = Status.where(["codigo = '1' and area_id = ?", Area.select('id').where(["codigo = 2"]).first]).first.id
    @adm_cliente.save
    logCliente(request.remote_ip, @adm_cliente.id, session[:usuario].id, "Cliente bloqueado")
    respond_to do |format|
      format.html { redirect_to(@adm_cliente, :notice => 'O cliente foi bloqueado') }      
      format.xml  { render :xml => @adm_cliente } 
    end
  end
  
  # POST /adm/clientes
  # POST /adm/clientes.xml
  def create
    @adm_cliente = Adm::Cliente.new(params[:adm_cliente])
    if @adm_cliente.save
      @adm_telefone = Adm::Telefone.new(params[:adm_telefone])
      @adm_telefone.cliente_id = @adm_cliente.id
      @adm_telefone.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 2"]).first]).first.id
      @adm_telefone.save
      @adm_endereco = Adm::Endereco.new(params[:adm_endereco])
      @adm_endereco.cliente_id = @adm_cliente.id
      @adm_endereco.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 2"]).first]).first.id
      @adm_endereco.save
      @clientes_pagamentos = ClientesFormaPagamentos.new
      @clientes_pagamentos.cliente_id = @adm_cliente.id
      @clientes_pagamentos.forma_pagamento_id = params[:forma_pagamento_id]
      @clientes_pagamentos.dt_inicio = Time.now
      @clientes_pagamentos.save
      logCliente(request.remote_ip, @adm_cliente.id, session[:usuario].id, "Novo cliente criado")
      logUsuario(request.remote_ip, session[:usuario].id, "Novo cliente criado (ID Cliente = " + @adm_cliente.id.to_s + ")") 
      begin
        Notificacao.adm_cliente_novo(@adm_cliente).deliver
        redirect_to adm_clientes_path, :notice => 'Um novo cliente foi criado e um e-mail foi disparado para ele, notificando-o'
      rescue
        logCritico("adm/clientes_controller => create -> Notificacao.adm_cliente_novo = ERRO: " + $!.to_s)
        redirect_to adm_clientes_path, :notice => 'Um novo cliente foi criado, mas ocorreu um erro ao enviar o e-mail de notificação a ele.'
      end
    else
      logCliente(request.remote_ip, -1, session[:usuario].id, "Problemas ao criar um cliente")
      logUsuario(request.remote_ip, session[:usuario].id, "Problemas ao criar um cliente") 
      redirect_to :back, :notice => 'Os dados não foram salvos. Revise-os e tente novamente.'
    end
  end

  # PUT /adm/clientes/1
  # PUT /adm/clientes/1.xml
  def update
    @adm_cliente = Adm::Cliente.find(params[:id])

    if @adm_cliente.update_attributes(params[:adm_cliente])
      logUsuario(request.remote_ip, session[:usuario].id, "Cliente editado (ID Cliente = " + @adm_cliente.id.to_s + ")") 
      logCliente(request.remote_ip, @adm_cliente.id, session[:usuario].id, "Cliente editado")
      redirect_to(:adm_clientes, :notice => 'Os novos dados do cliente foram salvos') 
    else
      logUsuario(request.remote_ip, session[:usuario].id, "Problemas ao editar dos dados do Cliente (ID Cliente = " + params[:id] + ")") 
      logCliente(request.remote_ip, params[:id], session[:usuario].id, "Problemas ao editar os dados")
      redirect_to :back, :notice => 'Os dados não foram salvos. Revise-os e tente novamente.' 
    end
  end

  # DELETE /adm/clientes/1
  # DELETE /adm/clientes/1.xml
  def destroy
    @adm_cliente = Adm::Cliente.find(params[:id])
    @adm_cliente.status_id = Status.where(["codigo = '2'and area_id = ?", Area.select('id').where(["codigo = '2'"]).first]).first.id
    if @adm_cliente.save
      logCliente(request.remote_ip, @adm_cliente.id, session[:usuario].id, "Cliente excluido")
      logUsuario(request.remote_ip, session[:usuario].id, "Cliente bloqueado (ID Cliente = " + @adm_cliente.id.to_s + ")") 
      redirect_to(adm_clientes_path, :notice => 'O cliente foi bloqueado')
    else
      logCliente(request.remote_ip, @adm_cliente.id, session[:usuario].id, "Problemas ao bloquear o cliente")
      logUsuario(request.remote_ip, session[:usuario].id, "Problemas ao bloquear o cliente") 
      redirect_to(adm_clientes_path, :notice => 'Problemas ao bloquear o cliente')
    end
  end
  
  # GET /adm/clientes/search
  def search
    # config de layout     
    @layout = Array.new()
    @layout[0] = "cliente" # menu     
    @layout[1] = "Busca de Clientes" # titulos     
    @layout[2] = "sloganD3" # subtitulo_css     
    @layout[3] = 'Resultado da busca por "' + params[:busca] + '"'     
    @layout[4] = "" #subtitulo_url
    @layout[5] = "/adm/clientes/search" #busca_url


    # criando a lista
    @adm_clientes_full = Adm::Cliente.where('nome_completo LIKE "%' + params[:busca] + '%" OR email LIKE "%' + params[:busca] + '%"').all
    
    # filtrando pela permissao do usuário os registros que ele pode ver
    if session[:usuario].status.area.codigo != '0'
      @adm_clientes = @adm_clientes_full.find_all {|c|  c.status.codigo == '0' or c.status.codigo == '1' }
    else
      @adm_clientes = @adm_clientes_full
    end
    
    #fazendo o encaminhamento
    if @adm_clientes.length > 0
      # search.html.erb
    else
      redirect_to(adm_clientes_path, :notice => 'A busca não retornou nenhum resultado')
    end
  end
  
  # GET /adm/clientes/:id/resend
  def resend
    @adm_cliente = Adm::Cliente.find(params[:id])
    
    if @adm_cliente
      begin
        Notificacao.adm_cliente_novo(@adm_cliente).deliver
        redirect_to :back, :notice => 'Um novo e-mail foi disparado para o cliente'
      rescue
        logCritico("adm/clientes_controller => resend -> Notificacao.adm_cliente_novo = ERRO: " + $!.to_s)
        redirect_to :back, :notice => 'Não foi possível reenviar o e-mail de cadastro ao cliente.'
      end
    else
      redirect_to :back, :notice => 'O cliente não foi encontrado'
    end
  end
end
