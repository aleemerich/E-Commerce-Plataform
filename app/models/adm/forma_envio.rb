# encoding: UTF-8
class Adm::FormaEnvio < ActiveRecord::Base
  has_many :pedido
end
