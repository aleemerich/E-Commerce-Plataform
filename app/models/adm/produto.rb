# encoding: UTF-8
class Adm::Produto < ActiveRecord::Base
  belongs_to :status
  has_many :item_pedido
  has_many :arquivo, :class_name => "Arquivo"
  has_many :produto_extra
  has_many :log_produto, :class_name => "LogProduto"
  has_many :comissao
  has_and_belongs_to_many :categoria, :class_name => "Adm::Categoria"
end
