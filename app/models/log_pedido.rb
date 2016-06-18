# encoding: UTF-8
class LogPedido < ActiveRecord::Base
  belongs_to :usuario, :class_name => "Adm::Usuario"
  belongs_to :pedido, :class_name => "Adm::Pedido"
end
