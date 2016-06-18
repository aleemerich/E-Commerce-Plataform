# encoding: UTF-8
class Adm::Categoria < ActiveRecord::Base
  has_many :filhos, :class_name => 'Adm::Categoria', :foreign_key => 'categoria_pai_id'
  belongs_to :categoria_pai, :class_name => 'Adm::Categoria'
  
  has_and_belongs_to_many :produto
end
