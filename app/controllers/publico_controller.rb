# encoding: UTF-8
class PublicoController < ApplicationController
  layout "publico"
  
  def index
    @publico_produtos_exibicao = Adm::Produto.limit(3).order('RAND()').where('status_id = ?', Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id).all
    @publico_produtos_recentes = Adm::Produto.limit(3).order('created_at DESC').where('status_id = ?', Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id).all
  end
  
  def quem_somos
    @publico_produtos_recentes = Adm::Produto.limit(3).order('created_at DESC').where('status_id = ?', Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id).all
  end
  
  def show
    @publico_produto = Adm::Produto.find(params[:id])
    @publico_produtos_recentes = Adm::Produto.limit(3).order('created_at DESC').where('status_id = ?', Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id).all
  end
  
  def show_all
    if params[:id_categoria]
      @publico_produtos_exibicao = Adm::Categoria.find(params[:id_categoria]).produto
    else
      @publico_produtos_exibicao = Adm::Produto.order('nome DESC').where('status_id = ?', Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id).all
    end
  end

  def busca
    @publico_produtos_exibicao = Adm::Produto.order('nome DESC').where('(nome LIKE "%' + params[:parametro] + '%" OR descricao LIKE "%' + params[:parametro] + '%") AND status_id = ?', Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id).all
  end

  def contato
    @publico_produtos_exibicao = Adm::Produto.limit(3).order('RAND()').where('status_id = ?', Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id).all
  end
end
