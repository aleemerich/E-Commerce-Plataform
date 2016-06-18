# encoding: UTF-8
class LogProduto < ActiveRecord::Base
  belongs_to :usuario, :class_name => "Adm::Usuario"
  belongs_to :produto, :class_name => "Adm::Produto"
end
