# encoding: UTF-8
class LogUsuario < ActiveRecord::Base
  belongs_to :usuario, :class_name => "Adm::Usuario"
end
