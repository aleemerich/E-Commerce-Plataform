# encoding: UTF-8
class Adm::EnderecosController < ApplicationController
  before_filter :permissao
  # POST /adm/endereco
  def create
    @adm_endereco = Adm::Endereco.new(params[:adm_endereco])
    @adm_endereco.status_id = Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '2'"]).first]).first.id
    @adm_endereco.save
    logCliente(request.remote_ip, @adm_endereco.cliente_id, session[:usuario].id, "Novo endereco criado (ID " + @adm_endereco.id.to_s + ")")
    redirect_to "/adm/clientes/" + @adm_endereco.cliente_id.to_s, :notice => 'Endereço cadastrado' 
  end

  # PUT /adm/endereco/:id
  def update
    @adm_endereco = Adm::Endereco.find(params[:id])
    @adm_endereco.update_attributes(params[:adm_endereco])
    @adm_endereco.status_id = Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '2'"]).first]).first.id
    @adm_endereco.save
    logCliente(request.remote_ip, @adm_endereco.cliente_id, session[:usuario].id, "Endereco editado (ID " + @adm_endereco.id.to_s + ")")
    redirect_to "/adm/clientes/" + @adm_endereco.cliente_id.to_s, :notice => 'Endereço alterado' 
  end

  # GET /adm/:id/delete
  def destroy
    @adm_endereco = Adm::Endereco.find(params[:id])
    @adm_endereco.status_id = Status.where(["codigo = '2'and area_id = ?", Area.select('id').where(["codigo = '2'"]).first]).first.id
    @adm_endereco.save
    logCliente(request.remote_ip, @adm_endereco.cliente_id, session[:usuario].id, "Exdereco excluido (ID " + @adm_endereco.id.to_s + ")")
    redirect_to "/adm/clientes/" + @adm_endereco.cliente_id.to_s, :notice => 'Endereço deletado' 
  end
end
