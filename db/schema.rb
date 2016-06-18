# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110919195707) do

  create_table "adm_clientes", :force => true do |t|
    t.string   "nome_completo"
    t.string   "cpf_cnpj"
    t.date     "dt_nasc_abertura"
    t.string   "email"
    t.string   "senha"
    t.string   "chave_autenticacao"
    t.integer  "status_id"
    t.text     "obs"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adm_comissaos", :force => true do |t|
    t.integer  "pedido_id"
    t.integer  "produto_id"
    t.integer  "item_pedido_id"
    t.decimal  "quantidade",     :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "perc_comissao",  :precision => 10, :scale => 4, :default => 0.0
    t.decimal  "valor_comissao", :precision => 10, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "valor_unitario", :precision => 10, :scale => 2, :default => 0.0
  end

  create_table "adm_enderecos", :force => true do |t|
    t.integer  "cliente_id"
    t.string   "logradouro"
    t.string   "numero"
    t.string   "complemento"
    t.string   "cidade"
    t.string   "estado"
    t.string   "cep"
    t.integer  "status_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adm_forma_envios", :force => true do |t|
    t.string   "empresa"
    t.string   "descricao"
    t.string   "codigo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "funcao_envio"
  end

  create_table "adm_forma_pagamentos", :force => true do |t|
    t.string   "descricao"
    t.integer  "intervalo_dias"
    t.integer  "parcelas"
    t.decimal  "perc_pgto_avista", :precision => 10, :scale => 4
    t.decimal  "perc_juros_mes",   :precision => 10, :scale => 4
    t.decimal  "perc_desconto",    :precision => 10, :scale => 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adm_item_pedido_extras", :force => true do |t|
    t.integer  "item_pedido_id"
    t.integer  "produto_extra_id"
    t.string   "dado_fornecido"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_id"
    t.string   "codigo_fator_calculo"
    t.decimal  "valor",                :precision => 10, :scale => 2, :default => 0.0
  end

  create_table "adm_item_pedidos", :force => true do |t|
    t.integer  "pedido_id"
    t.integer  "produto_id"
    t.decimal  "quantidade",     :precision => 10, :scale => 2
    t.decimal  "valor_unitario", :precision => 10, :scale => 2
    t.text     "obs"
    t.integer  "status_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "valor_total",    :precision => 10, :scale => 2
  end

  create_table "adm_pagamento_pedido_empresas", :force => true do |t|
    t.string   "nome"
    t.string   "url_post"
    t.string   "url_retorno"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url_site"
    t.string   "url_logo"
    t.string   "parcial"
  end

  create_table "adm_pagamento_pedido_historicos", :force => true do |t|
    t.integer  "pagamento_pedido_id"
    t.integer  "pagamento_pedido_empresa_id"
    t.integer  "pagamento_pedido_tipo_id"
    t.integer  "cliente_id"
    t.integer  "pedido_id"
    t.decimal  "valor",                       :precision => 10, :scale => 2, :default => 0.0
    t.integer  "status_id"
    t.text     "retorno_completo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adm_pagamento_pedidos", :force => true do |t|
    t.integer  "pagamento_pedido_empresa_id"
    t.integer  "parcela_pedido_id"
    t.decimal  "valor",                       :precision => 10, :scale => 2, :default => 0.0
    t.integer  "status_id"
    t.text     "retorno_completo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adm_parcela_pedidos", :force => true do |t|
    t.integer  "pedido_id"
    t.date     "dt_vencimento"
    t.decimal  "valor",             :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "perc_juros_atraso", :precision => 10, :scale => 4, :default => 0.0
    t.integer  "nro_parcela"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_id"
    t.integer  "pagamento_id"
    t.decimal  "perc_juros",        :precision => 10, :scale => 4, :default => 0.0
  end

  create_table "adm_pedidos", :force => true do |t|
    t.integer  "cliente_id"
    t.integer  "endereco_id"
    t.decimal  "total",                  :precision => 10, :scale => 2
    t.integer  "status_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "valor_envio",            :precision => 10, :scale => 2, :default => 0.0
    t.integer  "forma_envio_id"
    t.decimal  "valor_desconto",         :precision => 10, :scale => 2, :default => 0.0
    t.string   "justificativa_desconto"
    t.string   "cod_rastreio"
  end

  create_table "adm_produto_extra_fator_calculos", :force => true do |t|
    t.string   "nome"
    t.string   "descricao"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "codigo"
  end

  create_table "adm_produto_extra_tipos", :force => true do |t|
    t.string   "nome"
    t.string   "descricao"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "codigo"
    t.string   "tag"
  end

  create_table "adm_produto_extras", :force => true do |t|
    t.integer  "produto_id"
    t.string   "nome"
    t.integer  "produto_extra_tipo_id"
    t.string   "valor_cobrado"
    t.integer  "produto_extra_fator_calculo_id"
    t.text     "txt_ajuda"
    t.integer  "status_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adm_produtos", :force => true do |t|
    t.string   "nome"
    t.text     "descricao"
    t.decimal  "valor_max",       :precision => 10, :scale => 3
    t.decimal  "perc_comissao",   :precision => 10, :scale => 3
    t.decimal  "peso",            :precision => 10, :scale => 3
    t.decimal  "largura",         :precision => 10, :scale => 3
    t.decimal  "comprimento",     :precision => 10, :scale => 3
    t.decimal  "altura",          :precision => 10, :scale => 3
    t.integer  "status_id"
    t.boolean  "fl_oculta_qtde"
    t.string   "txt_oculta_qtde"
    t.boolean  "fl_ajuda_qtde"
    t.string   "txt_ajuda"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "fl_desconto",                                    :null => false
    t.decimal  "valor_min",       :precision => 10, :scale => 3
  end

  create_table "adm_telefones", :force => true do |t|
    t.integer  "cliente_id"
    t.string   "ddd"
    t.string   "telefone"
    t.integer  "status_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adm_usuarios", :force => true do |t|
    t.string   "nome_completo"
    t.string   "email"
    t.string   "senha"
    t.string   "permissao",     :default => "0.0"
    t.integer  "status_id"
    t.text     "obs"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "areas", :force => true do |t|
    t.string   "descricao"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "codigo"
  end

  create_table "arquivos", :force => true do |t|
    t.string   "caminho"
    t.string   "nome"
    t.integer  "produto_id"
    t.integer  "status_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "descricao"
    t.boolean  "fl_sistema", :default => false
  end

  create_table "clientes_forma_pagamentos", :id => false, :force => true do |t|
    t.integer  "cliente_id"
    t.integer  "forma_pagamento_id"
    t.date     "dt_inicio"
    t.date     "dt_fim"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "log_clientes", :force => true do |t|
    t.string   "ip"
    t.integer  "cliente_id"
    t.integer  "usuario_id"
    t.string   "acao"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "log_produtos", :force => true do |t|
    t.string   "ip"
    t.integer  "produto_id"
    t.integer  "usuario_id"
    t.string   "acao"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "log_usuarios", :force => true do |t|
    t.string   "ip"
    t.integer  "usuario_id"
    t.string   "acao"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissao_items", :force => true do |t|
    t.string   "cod_acesso"
    t.integer  "area_id"
    t.string   "descricao"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "status", :force => true do |t|
    t.string   "descricao"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "area_id"
    t.string   "codigo"
  end

end
