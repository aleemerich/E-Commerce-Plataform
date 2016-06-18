# encoding: UTF-8
class Area < ActiveRecord::Base
  has_many :status
  has_many :pemissao_item
end
