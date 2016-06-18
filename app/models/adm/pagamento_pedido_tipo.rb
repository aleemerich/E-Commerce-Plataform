class Adm::PagamentoPedidoTipo < ActiveRecord::Base
  has_many :pagamento_pedido
  belongs_to :pagamento_pedido_empresa
end
