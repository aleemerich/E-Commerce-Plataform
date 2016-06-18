# encoding: UTF-8
class Adm::Pedido < ActiveRecord::Base
  belongs_to :cliente
  belongs_to :endereco
  belongs_to :status
  belongs_to :forma_envio
  has_many :parcela_pedido
  has_many :item_pedido
  has_many :comissao
  has_many :log_pedido, :class_name => "LogPedido"
end
