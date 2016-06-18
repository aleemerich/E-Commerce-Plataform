# encoding: UTF-8
class Arquivo < ActiveRecord::Base
  belongs_to :produtos, :class_name => "Adm::Produto"
  belongs_to :status
end
