# encoding: UTF-8
class Adm::TelefonesController < ApplicationController
  before_filter :permissao
  # POST /adm/telefones
  def create
    @adm_telefone = Adm::Telefone.new(params[:adm_telefone])
    @adm_telefone.status_id = Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '2'"]).first]).first.id
    @adm_telefone.save
    logCliente(request.remote_ip, @adm_telefone.cliente_id, session[:usuario].id, "Novo telefone criado (ID " + @adm_telefone.id.to_s + ")")
    redirect_to "/adm/clientes/" + @adm_telefone.cliente_id.to_s, :notice => 'Telefone cadastrado' 
  end

  # PUT /adm/endereco/:id
  def update
    @adm_telefone = Adm::Telefone.find(params[:id])
    @adm_telefone.update_attributes(params[:adm_telefone])
    @adm_telefone.status_id = Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '2'"]).first]).first.id
    @adm_telefone.save
    logCliente(request.remote_ip, @adm_telefone.cliente_id, session[:usuario].id, "Telefone editado (ID " + @adm_telefone.id.to_s + ")")
    redirect_to "/adm/clientes/" + @adm_telefone.cliente_id.to_s, :notice => 'Telefone modificado' 
  end

  # GET /adm/:id/delete
  def destroy
    @adm_telefone = Adm::Telefone.find(params[:id])
    @adm_telefone.status_id = Status.where(["codigo = '2'and area_id = ?", Area.select('id').where(["codigo = '2'"]).first]).first.id
    @adm_telefone.save
    logCliente(request.remote_ip, @adm_telefone.cliente_id, session[:usuario].id, "Telefone excluido (ID " + @adm_telefone.id.to_s + ")")
    redirect_to "/adm/clientes/" + @adm_telefone.cliente_id.to_s, :notice => 'Telefone excluido' 
  end
end
