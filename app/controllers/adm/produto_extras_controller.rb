# encoding: UTF-8
class Adm::ProdutoExtrasController < ApplicationController
  before_filter :permissao
  
  def create
    @produto_extra = Adm::ProdutoExtra.new(params[:adm_produto_extra])
    @produto_extra.status_id = Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id
    @produto_extra.save
    logProduto(request.remote_ip, @produto_extra.produto_id, session[:usuario].id, "Novo produto extra criado (ID " + @produto_extra.id.to_s + ")")
    redirect_to "/adm/produtos/" + @produto_extra.produto_id.to_s, :notice => 'Produto Extra cadastrado' 
  end

  def update
    @produto_extra = Adm::ProdutoExtra.find(params[:id])
    @produto_extra.update_attributes(params[:adm_produto_extra])
    @produto_extra.status_id = Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id
    @produto_extra.save
    logProduto(request.remote_ip, @produto_extra.produto_id, session[:usuario].id, "Produto extra editado (ID " + @produto_extra.id.to_s + ")")
    redirect_to "/adm/produtos/" + @produto_extra.produto_id.to_s, :notice => 'Item de Produto Extra alterado' 
  end

  def destroy
    @produto_extra = Adm::ProdutoExtra.find(params[:id])
    @produto_extra.status_id = Status.where(["codigo = '2'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id
    @produto_extra.save
    logProduto(request.remote_ip, @produto_extra.produto_id, session[:usuario].id, "Produto extra deletado (ID " + @produto_extra.id.to_s + ")")
    redirect_to "/adm/produtos/" + @produto_extra.produto_id.to_s, :notice => 'Item de Produto Extra deletado' 
  end

  def active
    @produto_extra = Adm::ProdutoExtra.find(params[:id])
    @produto_extra.status_id = Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id
    @produto_extra.save
    logProduto(request.remote_ip, @produto_extra.produto_id, session[:usuario].id, "Produto extra ativado (ID " + @produto_extra.id.to_s + ")")
    redirect_to "/adm/produtos/" + @produto_extra.produto_id.to_s, :notice => 'Item de Produto Extra ativado' 
  end
end
