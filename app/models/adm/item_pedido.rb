# encoding: UTF-8
class Adm::ItemPedido < ActiveRecord::Base
  belongs_to :pedido
  belongs_to :produto
  belongs_to :status
  has_many :item_pedido_extra
  has_one :comissao
  
  validates_presence_of :quantidade, :message => "Deve ser preenchido"
  validates_presence_of :pedido_id, :message => "Deve ser preenchido"
end
