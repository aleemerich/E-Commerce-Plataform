# encoding: UTF-8
class Adm::FormaPagamento < ActiveRecord::Base
  has_and_belongs_to_many :cliente
  has_many :parcela_pedido
end
