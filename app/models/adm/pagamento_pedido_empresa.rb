# encoding: UTF-8
class Adm::PagamentoPedidoEmpresa < ActiveRecord::Base
  has_many :pagamento_pedido
  has_many :pagamento_pedido_historico
end
