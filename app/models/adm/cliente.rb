# encoding: UTF-8
class Adm::Cliente < ActiveRecord::Base
  belongs_to :status
  has_many :endereco
  has_many :telefone
  has_many :log_cliente, :class_name => "LogCliente"
  has_and_belongs_to_many :forma_pagamento
  has_many :pedido
  has_many :parcela_pedido
  
  validates_presence_of :nome_completo, :message => "Deve ser preenchido"
  validates_presence_of :cpf_cnpj, :message => "Deve ser preenchido"
  validates_presence_of :email, :message => "Deve ser preenchido"
  validates_presence_of :senha, :message => "Deve ser preenchido"

  validates_length_of :nome_completo, :within => 6..250, :too_short => "O nome deve ter mais que 6 caracteres"
  validates_length_of :senha, :within => 6..250, :too_short => "A senha deve ter mais que 6 caracteres"
  validates_length_of :cpf_cnpj, :within => 11..14, :too_short => "CPF/CNPJ invalido! Use somente numeros."

  validates_uniqueness_of :cpf_cnpj, 
                      :message => "Esse CPF/CNPJ ja foi cadastrado."
  validates_uniqueness_of :email, 
                      :message => "Esse e-mail ja foi cadastrado."
  validates_format_of :email,
                        :with => /\A[\w\._%-]+@[\w\.-]+\.[a-zA-Z]{2,4}\z/,
                        :if => Proc.new { |u| !u.email.nil? && !u.email.blank? },
                        :message => "Esse e-mail não e valido."
end
