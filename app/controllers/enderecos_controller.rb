# encoding: UTF-8
class EnderecosController < ApplicationController
  before_filter :permissao_publico
  layout "publico"

  def new
    @endereco = Adm::Endereco.new
    logCliente(request.remote_ip, session[:cliente].id, -1, "Acessando tela de NOVO endereco")
  end

  def create
    @endereco = Adm::Endereco.new(params[:adm_endereco])
    @endereco.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 2"]).first]).first.id
    if @endereco.save
      logCliente(request.remote_ip, session[:cliente].id, -1, "Novo endereco cadastrado (ID telefone = " + @endereco.id.to_s + " )")
      redirect_to(cliente_path, :notice => 'Seu cadastro foi efetuado com sucesso!')
    else
      logCliente(request.remote_ip, session[:cliente].id, -1, "[I] Problemas ao cadastrar um novo endereco")
      render :new
    end
  end
  
  # TODO: Há repetição de formulário para NEW e EDIT porque os nomes de ROTAS não podem ser usados
  # dado a estrutura do sistema, fiz isso provisoriamente. É preciso rever isso.

  def edit
    @endereco = Adm::Endereco.where('id = ? and cliente_id = ?', params[:id], session[:cliente].id).first
    if @endereco
       logCliente(request.remote_ip, session[:cliente].id, -1, "Acessando tela de EDIÇÃO de endereço")
    else
       logCliente(request.remote_ip, session[:cliente].id, -1, "Cliente acessando registro de endereço que não é dele. (ID endereço = " + params[:id] + ")")
       redirect_to(cliente_path, :notice => 'Você tentou acessar dados que não são seus! Uma notificação de segurança foi feita aos Administradores.')
    end
 end
  
  def update
    @endereco = Adm::Endereco.find(params[:id])
    if @endereco.update_attributes(params[:adm_endereco])
      logCliente(request.remote_ip, session[:cliente].id, -1, "Endereco editado (ID endereco = " + @endereco.id.to_s + " )")
      redirect_to(cliente_path, :notice => 'Seu cadastro foi atualizado com sucesso!')
    else
      logCliente(request.remote_ip, session[:cliente].id, -1, "[I] Problemas ao editar o endereco (ID endereco = " + @endereco.id.to_s + " )")
      render :edit
    end
  end
end
