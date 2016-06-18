# encoding: UTF-8
class LogCliente < ActiveRecord::Base
  belongs_to :usuario, :class_name => "Adm::Usuario"
  belongs_to :cliente, :class_name => "Adm::Cliente"
end
