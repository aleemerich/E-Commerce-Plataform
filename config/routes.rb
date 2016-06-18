GraficaArichComBr::Application.routes.draw do
  # =============
  # Publico
  # =============
  
  # Área Pùblica
  get "/", :action => "index", :as => 'index_publico', :controller => "publico", :layout => "index" 
  get "/quem_somos", :action => "quem_somos", :as => 'quem_somos_publico', :controller => "publico", :layout => "quem_somos" 
  post "/produtos/busca", :action => "busca", :as => 'produto', :controller => "publico", :layout => "produtos" 
  get "/produtos/:id", :action => "show", :as => 'produto', :controller => "publico", :layout => "produtos" 
  get "/produtos(/categoria/:id_categoria)", :action => "show_all", :as => 'produtos', :controller => "publico", :layout => "produtos" 
  get "/contato", :action => "contato", :as => 'contato', :controller => "publico", :layout => "contato" 

  # Autenticacao
  post "/autenticacao", :action => "login", :as => 'login', :controller => "autenticacao"
  get "/logoff", :action => "logoff", :as => 'logoff', :controller => "autenticacao" 
  get "/validacao/:chave", :action => "validacao", :controller => "autenticacao" 
  
  # Cliente
  post "/clientes", :action => "create", :controller => "clientes"
  put "/clientes/", :action => "update", :controller => "clientes"
  get "/clientes/", :action => "show", :controller => "clientes", :as => 'cliente'
  get "/clientes/new", :action => "new", :controller => "clientes", :as => 'new_cliente', :layout => 'cadastro'
  get "/clientes/edit", :action => "edit", :controller => "clientes", :as => 'edit_cliente'

  # Endereco (cliente)
  get "/enderecos/new", :action => "new", :controller => "enderecos", :as => 'new_endereco'
  post "/enderecos", :action => "create", :controller => "enderecos"
  get "/enderecos/:id/edit", :action => "edit", :controller => "enderecos", :as => 'edit_endereco'
  put "/enderecos/:id", :action => "update", :controller => "enderecos"
  get "/enderecos/:id/delete", :action => "destroy", :controller => "enderecos", :as => 'delete_endereco'

  # Telefone (cliente)
  get "/telefones/new", :action => "new", :controller => "telefones", :as => 'new_telefone'
  post "/telefones", :action => "create", :controller => "telefones"
  get "/telefones/:id/edit", :action => "edit", :controller => "telefones", :as => 'edit_telefone'
  put "/telefones/:id", :action => "update", :controller => "telefones"
  get "/telefones/:id/delete", :action => "destroy", :controller => "telefones", :as => 'delete_telefone'

  # Pedidos
  get "/pedidos/", :action => "index", :controller => "pedidos", :as => 'pedidos', :layout => "pedido"
  get "/pedidos/new", :action => "new", :controller => "pedidos", :as => 'new_pedido'
  get "/pedidos/:id", :action => "show", :controller => "pedidos", :as => 'pedido', :layout => "pedido"
  get "/pedidos/:id/destroy", :action => "destroy", :controller => "pedidos", :as => 'destroy_pedido'
  get "/pedidos/:id/envio", :action => "envio", :controller => "pedidos", :as => 'envio_pedido', :layout => "pedido"
  put "/pedidos/:id/envio", :action => "envio_rec", :controller => "pedidos"
  get "/pedidos/:id/parcelas", :action => "parcela", :controller => "pedidos", :as => 'parcela_pedido', :layout => "pedido"
  get "/pedidos/:id/parcelas/:forma_pagamento_id", :action => "parcela_rec", :controller => "pedidos", :as => 'parcela_rec_pedido'
  get "/pedidos/:id/final", :action => "final", :controller => "pedidos", :as => 'final_pedido', :layout => "pedido"
  get "/pedidos/:id/print", :action => "impressao", :controller => "pedidos", :as => 'impressao_pedido'
  
  # Pagamento de parcelas
  get "/pagamento_pedidos/new/:parcela_id", :action => "new", :controller => "pagamento_pedidos", :as => 'new_pagamento_pedido', :layout => "pedido"
  post "/pagamento_pedidos/", :action => "create", :controller => "pagamento_pedidos"
  get "/pagamento_pedidos/:id", :action => "destroy", :controller => "pagamento_pedidos", :as => 'destroy_pagamento_pedido'
  get "/pagamento_pedidos/:id/edit", :action => "edit", :controller => "pagamento_pedidos", :as => 'edit_pagamento_pedido', :layout => "pedido"
  put "/pagamento_pedidos/:id", :action => "update", :controller => "pagamento_pedidos", :as => 'update_pagamento_pedido'

  post "/url_retorno/pagamento_digital", :action => "retorno_pagamento_digital", :controller => "pagamento_pedidos"
  post "/url_retorno/pag_seguro", :action => "retorno_pag_seguro", :controller => "pagamento_pedidos"
  get "/url_retorno/pag_seguro", :action => "retorno_pag_seguro", :controller => "pagamento_pedidos"


  # Item dos Pedidos
  get "/item_pedidos/new/:id_produto", :action => "new", :controller => "item_pedidos", :as => 'new_item_pedido', :layout => "pedido"
  post "/item_pedidos/", :action => "create", :controller => "item_pedidos"
  get "/item_pedidos/:id", :action => "destroy", :controller => "item_pedidos", :as => 'destroy_item_pedido'
  
  # Servicos
  get "/services/check_parcelas_vencidas", :action => "check_parcelas_vencidas", :controller => "adm/servicos"
  get "/services/envio_demonstrativo_pedido/:id", :action => "envio_demonstrativo_pedido", :controller => "adm/servicos"
  get "/services/reenvio_autenticacao_cliente", :action => "reenvio_autenticacao_cliente", :controller => "adm/servicos"

  # =============
  # Administracao
  # =============

  # ADM - Autenticacao
  get "/adm/", :action => "index", :controller => "adm/autenticacao", :as => 'adm_autenticacao'
  get "/adm/logoff", :action => "logoff", :controller => "adm/autenticacao", :as => 'log_off_adm_autenticacao'
  post "/adm/", :action => "login", :controller => "adm/autenticacao"
  
  # ADM - Usuarios
  get "/adm/usuarios(.:format)(/pag/:pag)", :action => "index", :controller => "adm/usuarios", :as => 'adm_usuarios', :cod_acesso => '1.1'
  post "/adm/usuarios(.:format)", :action => "create", :controller => "adm/usuarios", :cod_acesso => '1.3'
  get "/adm/usuarios/new(.:format)", :action => "new", :controller => "adm/usuarios", :as => 'new_adm_usuario', :cod_acesso => '1.3'
  get "/adm/usuarios/:id/edit(.:format)", :action => "edit", :controller => "adm/usuarios", :as => 'edit_adm_usuario', :cod_acesso => '1.4'
  get "/adm/usuarios/:id(.:format)", :action => "show", :controller => "adm/usuarios", :as => 'adm_usuario', :cod_acesso => '1.5'
  put "/adm/usuarios/:id(.:format)", :action => "update", :controller => "adm/usuarios", :cod_acesso => '1.4'
  get "/adm/usuarios/:id(.:format)/delete", :action => "destroy", :controller => "adm/usuarios", :as => 'delete_adm_usuario', :cod_acesso => '1.7'
  get "/adm/usuarios/:id/block", :action => "block", :controller => "adm/usuarios", :as => 'block_adm_usuario', :cod_acesso => '1.8'
  post "/adm/usuarios/search", :action => "search", :controller => "adm/usuarios", :as => 'search_adm_usuario', :cod_acesso => '1.9'

  # ADM - Cliente
  get "/adm/clientes(.:format)(/pag/:pag)", :action => "index", :controller => "adm/clientes", :as => 'adm_clientes', :cod_acesso => '2.1'
  post "/adm/clientes(.:format)", :action => "create", :controller => "adm/clientes", :cod_acesso => '2.3'
  get "/adm/clientes/new(.:format)", :action => "new", :controller => "adm/clientes", :as => 'new_adm_cliente', :cod_acesso => '2.3'
  get "/adm/clientes/:id/edit(.:format)", :action => "edit", :controller => "adm/clientes", :as => 'edit_adm_cliente', :cod_acesso => '2.4'
  get "/adm/clientes/:id(.:format)", :action => "show", :controller => "adm/clientes", :as => 'adm_cliente', :cod_acesso => '2.5'
  put "/adm/clientes/:id(.:format)", :action => "update", :controller => "adm/clientes", :cod_acesso => '2.4'
  get "/adm/clientes/:id(.:format)/delete", :action => "destroy", :controller => "adm/clientes", :as => 'delete_adm_cliente', :cod_acesso => '2.7'
  get "/adm/clientes/:id/block", :action => "block", :controller => "adm/clientes", :as => 'block_adm_cliente', :cod_acesso => '2.8'
  post "/adm/clientes/search", :action => "search", :controller => "adm/clientes", :as => 'search_adm_cliente', :cod_acesso => '2.9'
  get "/adm/clientes/:id/resend", :action => "resend", :controller => "adm/clientes", :as => 'resend_adm_cliente', :cod_acesso => '2.3'

  # ADM - Apoio para Cliente/Endereco/Telefone
  get "/adm/clientes/:id/endereco/:id_endereco", :action => "show", :controller => "adm/clientes", :as => 'adm_cliente_endereco', :cod_acesso => '3.2' #só usado no momento de edicao
  get "/adm/clientes/:id/telefone/:id_telefone", :action => "show", :controller => "adm/clientes", :as => 'adm_cliente_telefone', :cod_acesso => '4.2' #só usado no momento de edicao

  # ADM - Endereco (cliente)
  post "/adm/enderecos(.:format)", :action => "create", :controller => "adm/enderecos", :as => 'adm_enderecos', :cod_acesso => '3.1'
  put "/adm/enderecos/:id(.:format)", :action => "update", :controller => "adm/enderecos", :as => 'adm_endereco', :cod_acesso => '3.2'
  get "/adm/enderecos/:id(.:format)/delete", :action => "destroy", :controller => "adm/enderecos", :as => 'delete_adm_endereco', :cod_acesso => '3.3'

  # ADM - Telefone(cliente)
  post "/adm/telefones(.:format)", :action => "create", :controller => "adm/telefones", :as => 'adm_telefones', :cod_acesso => '4.1'
  put "/adm/telefones/:id(.:format)", :action => "update", :controller => "adm/telefones", :as => 'adm_telefone', :cod_acesso => '4.2'
  get "/adm/telefones/:id(.:format)/delete", :action => "destroy", :controller => "adm/telefones", :as => 'delete_adm_telefone', :cod_acesso => '4.3'

  # ADM - Forma de Pagamento (cliente)
  #TODO: Essas funções deverão ser reanalisadas
  post "/adm/forma_pagamentos(.:format)", :action => "add", :controller => "adm/forma_pagamentos", :as => 'add_adm_forma_pagamento', :cod_acesso => '8.1'
  get "/adm/forma_pagamentos/:id_cliente/:id_pagamento/remove", :action => "remove", :controller => "adm/forma_pagamentos", :as => 'remove_adm_forma_pagamento', :cod_acesso => '8.2'

  # ADM - Produto
  get "/adm/produtos(.:format)(/pag/:pag)", :action => "index", :controller => "adm/produtos", :as => 'adm_produtos', :cod_acesso => '5.1'
  post "/adm/produtos(.:format)", :action => "create", :controller => "adm/produtos", :cod_acesso => '5.3'
  get "/adm/produtos/new(.:format)", :action => "new", :controller => "adm/produtos", :as => 'new_adm_produto', :cod_acesso => '5.3'
  get "/adm/produtos/:id/edit(.:format)", :action => "edit", :controller => "adm/produtos", :as => 'edit_adm_produto', :cod_acesso => '5.4'
  get "/adm/produtos/:id(.:format)", :action => "show", :controller => "adm/produtos", :as => 'adm_produto', :cod_acesso => '5.5'
  put "/adm/produtos/:id(.:format)", :action => "update", :controller => "adm/produtos", :cod_acesso => '5.4'
  get "/adm/produtos/:id(.:format)/delete", :action => "destroy", :controller => "adm/produtos", :as => 'delete_adm_produto', :cod_acesso => '5.7'
  get "/adm/produtos/:id/block", :action => "block", :controller => "adm/produtos", :as => 'block_adm_produto', :cod_acesso => '5.8'
  post "/adm/produtos/search", :action => "search", :controller => "adm/produtos", :as => 'search_adm_produto', :cod_acesso => '5.9'

  # ADM - Apoio para Produto/Produto Extra
  get "/adm/produtos/:id/produto_extras/:id_produto_extras", :action => "show", :controller => "adm/produtos", :as => 'adm_produto_produto_extras', :cod_acesso => '6.2' #só usado no momento de edicao

  # ADM - Produto(extras)
  post "/adm/produto_extras(.:format)", :action => "create", :controller => "adm/produto_extras", :as => 'adm_produto_extras', :cod_acesso => '6.1'
  put "/adm/produto_extras/:id(.:format)", :action => "update", :controller => "adm/produto_extras", :as => 'adm_produto_extra', :cod_acesso => '6.2'
  get "/adm/produto_extras/:id(.:format)/delete", :action => "destroy", :controller => "adm/produto_extras", :as => 'delete_adm_produto_extra', :cod_acesso => '6.3'
  get "/adm/produto_extras/:id(.:format)/active", :action => "active", :controller => "adm/produto_extras", :as => 'active_adm_produto_extra', :cod_acesso => '6.3'

  # ADM - Produto(arquivos)
  post "/arquivos", :action => "create", :controller => "arquivos", :as => 'arquivos', :cod_acesso => '7.1'
  get "/arquivos/:id/delete", :action => "destroy", :controller => "arquivos", :as => 'delete_arquivos', :cod_acesso => '7.2'
  get "/arquivos/:id/active", :action => "active", :controller => "arquivos", :as => 'active_arquivos', :cod_acesso => '7.3'

  # ADM - Pedidos
  get "/adm/pedidos(.:format)(/pag/:pag)", :action => "index", :controller => "adm/pedidos", :as => 'adm_pedidos', :cod_acesso => '9.1'
  post "/adm/pedidos(.:format)", :action => "create", :controller => "adm/pedidos", :cod_acesso => '9.3'
  get "/adm/pedidos/new(.:format)", :action => "new", :controller => "adm/pedidos", :as => 'new_adm_pedido', :cod_acesso => '9.3'
  get "/adm/pedidos/:id(.:format)", :action => "show", :controller => "adm/pedidos", :as => 'adm_pedido', :cod_acesso => '9.5'
  #put "/adm/pedidos/:id(.:format)", :action => "update", :controller => "adm/pedidos", :cod_acesso => '9.4'
  get "/adm/pedidos/:id/block", :action => "block", :controller => "adm/pedidos", :as => 'block_adm_pedido', :cod_acesso => '9.8'
  post "/adm/pedidos/search", :action => "search", :controller => "adm/pedidos", :as => 'search_adm_pedido', :cod_acesso => '9.9'
  get "/adm/pedidos/:id/calc", :action => "calc", :controller => "adm/pedidos", :cod_acesso => '9.10'
  get "/adm/pedidos/:id/services/:funcao/:cepDestino/:codigo", :action => "services", :controller => "adm/pedidos", :as => 'services_adm_pedido'
  # Essas funções foram usadas só para desenvolvimento
  #get "/adm/pedidos/:id/formaEnvio", :action => "envio", :controller => "adm/pedidos", :as => 'envio_adm_pedido'
  #get "/adm/pedidos/:id/finally(/:pagamento_pedido_id)", :action => "finally", :controller => "adm/pedidos", :as => 'finally_adm_pedido'

  # ADM - Item de Pedido
  get "/adm/pedidos/:id_pedido/item_pedidos(/pag/:pag)", :action => "index", :controller => "adm/pedido_itens", :as => 'adm_item_pedidos', :cod_acesso => '10.1'
  post "/adm/pedidos/:id_pedido/item_pedidos", :action => "create", :controller => "adm/pedido_itens", :as => 'adm_item_pedido', :cod_acesso => '10.3'
  get "/adm/pedidos/:id_pedido/item_pedidos/:id_produto/new", :action => "new", :controller => "adm/pedido_itens", :as => 'new_adm_item_pedido', :cod_acesso => '10.3'
  get "/adm/pedidos/:id_pedido/item_pedidos/:id(.:format)/delete", :action => "destroy", :controller => "adm/pedido_itens", :as => 'delete_adm_item_pedido', :cod_acesso => '10.4'

  # ADM - Parcelas de Pedidos
  #TODO: Essas funções deverão ser reanalisadas
  get "/adm/parcela_pedidos(/pag/:pag)", :action => "index", :controller => "adm/parcela_pedidos", :as => 'adm_parcela_pedidos', :cod_acesso => '11.1'
  #get "/adm/:pedido_id/parcela_pedidos/create/:forma_pagamento_id", :action => "create", :controller => "adm/parcela_pedidos", :as => 'create_adm_parcela_pedido', :cod_acesso => '11.3'
  #get "/adm/:pedido_id/parcela_pedidos/new(.:format)", :action => "new", :controller => "adm/parcela_pedidos", :as => 'new_adm_parcela_pedido', :cod_acesso => '11.3'
  get "/adm/parcela_pedidos/:id(.:format)", :action => "show", :controller => "adm/parcela_pedidos", :as => 'adm_parcela_pedido', :cod_acesso => '11.5'
  get "/adm/parcela_pedidos/:id/andamentos/:id_status", :action => "andamentos", :controller => "adm/parcela_pedidos", :as => 'andamentos_adm_parcela_pedido',:cod_acesso => '11.6'
  get "/adm/parcela_pedidos/:id/cancel", :action => "cancel", :controller => "adm/parcela_pedidos", :as => 'cancel_adm_parcela_pedido',:cod_acesso => '11.7'
  post "/adm/parcela_pedidos/search", :action => "search", :controller => "adm/parcela_pedidos", :as => 'search_adm_parcela_pedidos', :cod_acesso => '11.1'

  # ADM - Pagamentos de Pedidos
  #TODO: Essas funções deverão ser reanalisadas
  get "/adm/pagamento_pedidos(/pag/:pag)", :action => "index", :controller => "adm/pagamento_pedidos", :as => 'adm_pagamento_pedidos', :cod_acesso => '12.1'
  #post "/adm/pagamento_pedidos", :action => "create", :controller => "adm/pagamento_pedidos", :cod_acesso => '12.3'
  #get "/adm/pagamento_pedidos/new/:parcela_id", :action => "new", :controller => "adm/pagamento_pedidos", :as => 'new_adm_pagamento_pedido', :cod_acesso => '12.3'
  #get "/adm/pagamento_pedidos/:id/edit(.:format)", :action => "edit", :controller => "adm/pagamento_pedidos", :as => 'edit_adm_pagamento_pedido', :cod_acesso => '12.4'
  #put "/adm/pagamento_pedidos/:id(.:format)", :action => "update", :controller => "adm/pagamento_pedidos", :cod_acesso => '12.4'
  post "/adm/pagamento_pedidos/search", :action => "search", :controller => "adm/pagamento_pedidos", :as => 'search_adm_pagamento_pedido', :cod_acesso => '12.1'

  # ADM - Painel
  get "/adm/painel(.:format)(/pag/:pag)", :action => "index", :controller => "adm/painel", :as => 'adm_painel', :cod_acesso => '13.1'
  get "/adm/painel/ajax/tabela", :action => "index_ajax_tabela", :controller => "adm/painel", :as => 'adm_painel_ajax_tabela', :cod_acesso => '13.1'
  get "/adm/painel/:id(.:format)", :action => "show", :controller => "adm/painel", :as => 'show_adm_painel', :cod_acesso => '13.2'
  get "/adm/painel/:id/andamentos/:id_status", :action => "andamentos", :controller => "adm/painel", :as => 'andamentos_adm_painel',:cod_acesso => '13.3'
  post "/adm/painel/:id/andamentos", :action => "desconto", :controller => "adm/painel", :as => 'desconto_adm_painel',:cod_acesso => '13.4'
  post "/adm/painel/:id/despacho", :action => "despacho", :controller => "adm/painel", :as => 'despacho_adm_painel',:cod_acesso => '13.3'
  post "/adm/painel/:id/duvida", :action => "duvida", :controller => "adm/painel", :as => 'duvida_adm_painel',:cod_acesso => '13.3'
  post "/adm/painel/search", :action => "search", :controller => "adm/painel", :as => 'search_adm_painel', :cod_acesso => '13.1'

  # ADM - Extrato
  get "/adm/comissoes(/:id_ano/:id_mes)", :action => "index", :controller => "adm/comissoes", :as => 'adm_comissoes', :cod_acesso => '14.1'

  # ADM - Categorias
  get "/adm/categorias", :action => "index", :controller => "adm/categorias", :as => 'adm_categorias', :cod_acesso => '15.1'
  post "/adm/categorias", :action => "create", :controller => "adm/categorias", :as => 'create_adm_categorias', :cod_acesso => '15.2'
  post "/adm/categorias/update", :action => "update", :controller => "adm/categorias", :as => 'update_adm_categorias', :cod_acesso => '15.3'
  get "/adm/categorias/:id", :action => "destroy", :controller => "adm/categorias", :as => 'destroy_adm_categorias', :cod_acesso => '15.4'

end
