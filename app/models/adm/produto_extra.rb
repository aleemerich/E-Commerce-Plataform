class Adm::ProdutoExtra < ActiveRecord::Base
  belongs_to :produto
  belongs_to :produto_extra_tipo
  belongs_to :produto_extra_fator_calculo
  belongs_to :status
  has_many :item_pedido_extra
end
