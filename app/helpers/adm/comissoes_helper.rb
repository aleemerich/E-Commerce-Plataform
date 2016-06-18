# encoding: UTF-8
module Adm::ComissoesHelper
  def receita_empresa(pedidos)
    soma = 0.0
    pedidos.each do |p|
      soma += p['valor_total'].to_f
    end
    return soma
  end
end
