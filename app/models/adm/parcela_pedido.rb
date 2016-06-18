# encoding: UTF-8
class Adm::ParcelaPedido < ActiveRecord::Base
  has_one :pagamento_pedido
  has_many :pagamento_pedido_historico
  belongs_to :pedido
  belongs_to :status
  belongs_to :pagamento
end
