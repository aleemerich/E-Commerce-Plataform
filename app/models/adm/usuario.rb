# encoding: UTF-8
class Adm::Usuario < ActiveRecord::Base
  belongs_to :status
  has_many :log_usuario, :class_name => "LogUsuario"
  has_many :log_cliente, :class_name => "LogCliente"
  has_many :log_produto, :class_name => "LogProduto"
  has_many :log_pedido, :class_name => "LogPedido"

  validates_presence_of :nome_completo, :message => "Deve ser preenchido"
  validates_presence_of :permissao, :message => "Deve ser preenchido"
  validates_presence_of :email, :message => "Deve ser preenchido"
  validates_presence_of :senha, :message => "Deve ser preenchido"

  validates_length_of :nome_completo, :within => 6..250, :too_short => "O nome deve ter mais que 6 caracteres"
  validates_length_of :senha, :within => 6..250, :too_short => "A senha deve ter mais que 6 caracteres"

  validates_uniqueness_of :email, 
                      :message => "Esse e-mail ja foi cadastrado."
  validates_format_of :email,
                        :with => /\A[\w\._%-]+@[\w\.-]+\.[a-zA-Z]{2,4}\z/,
                        :if => Proc.new { |u| !u.email.nil? && !u.email.blank? },
                        :message => "Esse e-mail não e valido."
end
