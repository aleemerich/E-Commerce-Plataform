# encoding: UTF-8
module PedidosHelper
  def montaExtrato(pedido)
    strHTML = '____________________________________________<br />'
    strHTML += '.: RM GRÁFICA RÁPIDA :.<br />'
    strHTML += '<br />'
    strHTML += 'Rua Guaraú, 92 - Mirandópolis<br />'
    strHTML += 'São Paulo/SP  CEP 04052-000<br />'
    strHTML += '(ao lado do metrô "Praça da Árvore")<br />'
    strHTML += '<br />'
    strHTML += 'Fone: (11)5589-1512 / (11)5583-2651<br />'
    strHTML += 'E-mail: contato@rmgraficarapida.com.br<br />'
    strHTML += 'Site: www.rmgraficarapida.com.br<br />'
    strHTML += '____________________________________________<br />'
    strHTML += '<br /><br />DEMONSTRATIVO DO PEDIDO ' + "%05d" % pedido.id.to_s
    strHTML += '<br /><br />Cliente: ' + pedido.cliente.nome_completo[0..30] + '<br />'
    strHTML += 'Código do cliente: ' + pedido.cliente.id.to_s + '<br />'
    strHTML += 'Desde: ' + pedido.cliente.created_at.strftime("%d/%m/%Y") + '<br />'
    strHTML += '<br /><br />'
    strHTML += 'Número do Pedido: ' + "%05d" % pedido.id.to_s + '<br />'
    strHTML += 'Data do Pedido: ' + pedido.created_at.strftime("%d/%m/%Y %H:%M") + '<br />'
    strHTML += 'Status do Pedido: ' + pedido.status.descricao + '<br />'
    strHTML += '<br /><br />Detalhes do Pedido:<br />'
    pedido.item_pedido.select{|i| i if i.status.codigo == 'IP-0'}.each do |item_pedido| 
      strHTML += '<br />====================================<br /><br />'
      strHTML += 'Código: ' + item_pedido.id.to_s + '<br />'
      strHTML += item_pedido.produto.nome + '<br /><br />'
      strHTML += '- Valor Individual: ' + number_to_currency(item_pedido.valor_unitario, :separator => ",", :delimiter => ".", :unit => "R$ ") + '<br />'
      strHTML += '- Quantidade: ' + item_pedido.quantidade.to_s + '<br />'
      strHTML += '- Observação: ' + item_pedido.obs + '<br />'
      strHTML += '<br />----> ITENS EXTRAS<br />'
      strHTML += montaExtratoSubItem(item_pedido)
    end
    strHTML += '<br />====================================<br /><br />'
    strHTML += 'Frete: ' + number_to_currency(pedido.valor_envio, :separator => ",", :delimiter => ".", :unit => "R$ ") + '<br /><br />'
    if pedido.valor_desconto > 0
      strHTML += '<br />====================================<br /><br />'
      strHTML += 'Desconto: ' + number_to_currency(pedido.valor_desconto, :separator => ",", :delimiter => ".", :unit => "R$ ") + '<br /><br />'
    end
    strHTML += '====================================<br /><br /><br />'
    strHTML += 'TOTAL DO PEDIDO: ' + number_to_currency(pedido.total, :separator => ",", :delimiter => ".", :unit => "R$ ") + '<br /><br />'
    return strHTML.html_safe
  end
  
  def montaExtratoSubItem(item)
    strHTML = ''
    item.item_pedido_extra.each do |subItem|
      # TODO: Pensar na possibilidade de inserir esse campo em ITEM_PEDIDOS
      # para não depender da tabela PRODUTO_EXTRA. Se alguém a PRODUTO_EXTRA
      # Essa descrição será afetada
      strHTML += subItem.produto_extra.nome + '<br />'
      case subItem.produto_extra.produto_extra_tipo.codigo
      when 'arquivo'
        apoio = subItem.dado_fornecido.split(';')
        strHTML += '- <a href="/temp/'+ File.basename(Arquivo.find(apoio[0]).caminho) + '">' + apoio[1] + '</a><br />'
        strHTML += '- valor: ' + number_to_currency((subItem.valor.nil? ? '0.00' : subItem.valor), :separator => ",", :delimiter => ".", :unit => "R$ ") + '<br />'
      when 'inteiro'
        strHTML += '- informado: ' + ((subItem.dado_fornecido.blank? or subItem.dado_fornecido.nil?) ? '0.0' : subItem.dado_fornecido) + '<br />'
      else
        strHTML += '- informado: ' + subItem.dado_fornecido + '<br />'
        if subItem.produto_extra.produto_extra_fator_calculo.codigo == 'perc_total' or subItem.produto_extra.produto_extra_fator_calculo.codigo == 'perc_individual'
          strHTML += '- ' + number_to_percentage((subItem.valor * 100), :precision => 2) + '<br />'
        else
          strHTML += '- valor: ' + number_to_currency(subItem.valor, :separator => ",", :delimiter => ".", :unit => "R$ ") + '<br />'
        end
        #strHTML += '- valor: ' + number_to_currency(subItem.valor, :separator => ",", :delimiter => ".", :unit => "R$ ") + '<br />'
      end
      # O fator de calculo é buscado baseado no que está gravado para não correr risco de
      # alterações dentro do PRODUTO_EXTRA e isso inpactar a exibição de dados.
      strHTML += '- fator de calculo: ' + Adm::ProdutoExtraFatorCalculo.first(:conditions => ['codigo = ?', subItem.codigo_fator_calculo]).nome + '<br />'
      strHTML += '<br />'
    end
    strHTML += '------------------------------------<br /><br />'
    strHTML += 'SUBTOTAL: ' + number_to_currency(item.valor_total.to_s, :separator => ",", :delimiter => ".", :unit => "R$ ") + '<br /><br />'
    return strHTML
  end
end
