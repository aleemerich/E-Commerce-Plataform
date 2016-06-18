# encoding: UTF-8
class Status < ActiveRecord::Base
  belongs_to :area
  has_many :arquivo
  has_many :adm_usuario
  has_many :adm_cliente
  has_many :adm_telefone
  has_many :adm_endereco
  has_many :adm_produto
  has_many :adm_produto_extra
  has_many :adm_pedido
  has_many :adm_item_pedido
  has_many :adm_item_pedido_extra
  has_many :adm_pagamento_pedido
  has_many :adm_pagamento_pedido_historico
  has_many :adm_parcela_pedido
end
