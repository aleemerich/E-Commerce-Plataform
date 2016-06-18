# encoding: UTF-8
class Adm::Telefone < ActiveRecord::Base
  belongs_to :status
  belongs_to :cliente

  validates_presence_of :telefone, :message => "Deve ser preenchido"
  validates_presence_of :ddd, :message => "Deve ser preenchido"
  
  validates_length_of :telefone, :within => 8..10, :too_short => "Deve conter minimo de 8 digitos e somente numeros"
  validates_length_of :ddd, :within => 2..3, :too_short => "Deve conter 2 digitos e somente numeros"
end
