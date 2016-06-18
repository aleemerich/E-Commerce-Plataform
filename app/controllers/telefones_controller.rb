# encoding: UTF-8
class TelefonesController < ApplicationController
  before_filter :permissao_publico #está em application_controller.rb
  layout "publico"

  def new
    @telefone = Adm::Telefone.new
    logCliente(request.remote_ip, session[:cliente].id, -1, "Acessando tela de NOVO telefone")
  end

  def create
    @telefone = Adm::Telefone.new(params[:adm_telefone])
    @telefone.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 2"]).first]).first.id
    if @telefone.save
      logCliente(request.remote_ip, session[:cliente].id, -1, "Novo telefone cadastrado (ID telefone = " + @telefone.id.to_s + " )")
      redirect_to(cliente_path, :notice => 'Seu cadastro foi efetuado com sucesso!')
    else
      logCliente(request.remote_ip, session[:cliente].id, -1, "[I] Problemas ao cadastrar um novo telefone")
      render :new
    end
  end
  
  # TODO: Há repetição de formulário para NEW e EDIT. Como os nomes de ROTAS não podem ser usados
  # dado a estrutura do sistema, fiz isso provisoriamente. É preciso rever isso.

  def edit
    @telefone = Adm::Telefone.where('id = ? and cliente_id = ?', params[:id], session[:cliente].id).first
    if @telefone
       logCliente(request.remote_ip, session[:cliente].id, -1, "Acessando tela de EDICAO de telefone")
    else
       logCliente(request.remote_ip, session[:cliente].id, -1, "Cliente acessando registro de telefone que não é dele. (ID telefone = " + params[:id] + ")")
       redirect_to(cliente_path, :notice => 'Você tentou acessar dados que não são seus! Uma notificação de segurança foi feita aos Administradores.')
    end
  end
  
  def update
    @telefone = Adm::Telefone.find(params[:id])
    if @telefone.update_attributes(params[:adm_telefone])
      logCliente(request.remote_ip, session[:cliente].id, -1, "Telefone editado (ID telefone = " + @telefone.id.to_s + " )")
      redirect_to(cliente_path, :notice => 'Seu cadastro foi atualizado com sucesso!')
    else
      logCliente(request.remote_ip, session[:cliente].id, -1, "[I] Problemas ao editar o telefone (ID telefone = " + @telefone.id.to_s + " )")
      render :edit
    end
  end
end
