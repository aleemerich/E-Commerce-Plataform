# encoding: UTF-8
class Adm::Endereco < ActiveRecord::Base
  belongs_to :status
  belongs_to :cliente
  has_many :pedido

  validates_presence_of :logradouro, :message => "Deve ser preenchido"
  validates_presence_of :numero, :message => "Deve ser preenchido"
  validates_presence_of :cidade, :message => "Deve ser preenchido"
  validates_presence_of :estado, :message => "Deve ser preenchido"
  validates_presence_of :cep, :message => "Deve ser preenchido"

  validates_length_of :cep, :within => 8..9, :too_short => "Deve conter 8 digitos e somente numeros"
end
