# encoding: UTF-8
class Adm::PagamentoPedido < ActiveRecord::Base
  belongs_to :pagamento_pedido_empresa
  belongs_to :parcela_pedido
  belongs_to :status
  has_many :pagamento_pedido_historico
end
