# encoding: UTF-8
class Adm::Comissao < ActiveRecord::Base
  belongs_to :pedido
  belongs_to :produto
  belongs_to :item_pedido
end
