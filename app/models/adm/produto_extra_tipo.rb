# encoding: UTF-8
class Adm::ProdutoExtraTipo < ActiveRecord::Base
  has_many :produto_extra
end
