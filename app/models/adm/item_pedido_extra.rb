# encoding: UTF-8
class Adm::ItemPedidoExtra < ActiveRecord::Base
  belongs_to :item_pedido
  belongs_to :produto_extra
  belongs_to :status
end
