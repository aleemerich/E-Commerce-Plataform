# encoding: UTF-8
class Adm::PagamentoPedidoHistorico < ActiveRecord::Base
  belongs_to :pagamento_pedido
  belongs_to :pagamento_pedido_empresa
  belongs_to :parcela_pedido
  belongs_to :status
end
