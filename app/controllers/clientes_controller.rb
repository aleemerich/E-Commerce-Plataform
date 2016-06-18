# encoding: UTF-8
class ClientesController < ApplicationController
  before_filter :cliente_novo, :only => [:new, :create]
  before_filter :permissao_publico, :only => [:show, :edit, :update]
  layout "publico"
  
  def new
    @cliente = Adm::Cliente.new
    logCliente(request.remote_ip, -1, -1, "Acessando tela de CADASTRO de um novo Cliente")
  end
  
  def create
    begin
      @cliente = Adm::Cliente.new(params[:adm_cliente])
      @cliente.chave_autenticacao = SecureRandom.hex(14)
      @cliente.status_id = Status.where(["codigo = '3' and area_id = ?", Area.select('id').where(["codigo = 2"]).first]).first.id
      if @cliente.save
        begin
          Notificacao.cliente_validacao(@cliente).deliver
        rescue
          logCritico("clientes_controller => create -> Notificacao.cliente_validacao = ERRO: " + $!.to_s)
        end
        @adm_telefone = Adm::Telefone.new(params[:adm_telefone])
        @adm_telefone.cliente_id = @cliente.id
        @adm_telefone.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 2"]).first]).first.id
        @adm_telefone.save
        @adm_endereco = Adm::Endereco.new(params[:adm_endereco])
        @adm_endereco.cliente_id = @cliente.id
        @adm_endereco.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 2"]).first]).first.id
        @adm_endereco.save
        @clientes_pagamentos = ClientesFormaPagamentos.new
        @clientes_pagamentos.cliente_id = @cliente.id
        @clientes_pagamentos.forma_pagamento_id = 2 #TODO: Isso está fixo e precisa ser modificado
        @clientes_pagamentos.dt_inicio = Time.now
        @clientes_pagamentos.save
        logCliente(request.remote_ip, @cliente.id, -1, "Novo cliente cadastrado")
        redirect_to(:index_publico, :notice => 'Seu cadastro foi efetuado com sucesso! Por favor, veja seu e-mail e valide seu cadastro.')
      else
        logCliente(request.remote_ip, -1, -1, "Problemas ao cadastrar um novo cliente")
        render :action => "new"
      end
    rescue
      logCritico("clientes_controller => creare -> Falha no cadastro = ERRO: " + $!.to_s)
      redirect_to index_publico_path, :notice => 'Ocorreram problemas ao registrarmos seu cadastro. Nossos técnicos já foram notificados. Por favor, tente mais tarde.'
    end
  end

  def show
    @cliente = Adm::Cliente.find(session[:cliente].id)
    logCliente(request.remote_ip, session[:cliente].id, -1, "Acessando tela de DADOS de um cliente")
  end

  def edit
    @cliente = Adm::Cliente.find(session[:cliente].id)
    logCliente(request.remote_ip, session[:cliente].id, -1, "Acessando tela de EDICAO de um cliente")
  end

  def update
    @cliente = Adm::Cliente.find(session[:cliente].id)
    if @cliente.update_attributes(params[:adm_cliente])
      redirect_to(cliente_path(@cliente), :notice => 'Seu cadastro foi atualizado com sucesso!')
      logCliente(request.remote_ip, @cliente.id, -1, "Dados do cliente editado")
    else
      logCliente(request.remote_ip, @cliente.id, -1, "Cliente com problemas para editar seus dados")
      render :edit
    end
  end

  
  # ====================
  # FUNÇÕES DE VALIDAÇÃO
  # ====================

  protected
  def cliente_novo
    if session[:cliente]
      logCliente(request.remote_ip, session[:cliente].id, -1, "[I] Cliente tentou criar um novo cadastro de cliente")
      redirect_to index_publico_path, :notice => 'Clientes já autenticados não podem se cadastrar novamente.'
      false
    else
      true
    end
  end
end
