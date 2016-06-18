# encoding: UTF-8
class Adm::FormaPagamentosController < ApplicationController
  before_filter :permissao
  
  def add
    @clientes_pagamentos = ClientesFormaPagamentos.new(params[:clientes_forma_pagamentos])
    @clientes_pagamentos.save
    redirect_to "/adm/clientes/" + @clientes_pagamentos.cliente_id.to_s, :notice => 'Pagamento adicionado'   
  end
  
  def remove
    @forma_pagamento = Adm::FormaPagamento.find(params[:id_pagamento])
    @adm_cliente = Adm::Cliente.find(params[:id_cliente])
    @adm_cliente.forma_pagamento.delete(@forma_pagamento)
    @adm_cliente.save
    redirect_to "/adm/clientes/" + params[:id_cliente], :notice => 'Pagamento removido'
  end
end
