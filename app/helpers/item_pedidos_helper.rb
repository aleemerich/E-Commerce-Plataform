# encoding: UTF-8
module ItemPedidosHelper
  # para entender melhor essa ação, vide explicação no arquivo pedido_itens_controller
  def montaInputs(tipo, id, valor)
    case tipo
    when 'file'
      strHtml = '<input id="adm_item_pedido_extra_item_' + id + '_dado_fornecido_arquivo_0" name="adm_item_pedido_extra[item' + id + '[dado_fornecido[arquivo[0]]]" type="file" />&nbsp; <br />Descricao:'
      strHtml += '<input size="30" id="adm_item_pedido_extra_item_' + id + '_dado_fornecido_descricao_0" name="adm_item_pedido_extra[item' + id + '[dado_fornecido[descricao[0]]" type="text" />&nbsp; &nbsp;'
      strHtml += '<input class="button" type="button" onclick="adicionarCampos(' + id + ')" value=" + Arquivos " />'
    when 'select'
      strHtml = '<select id="adm_item_pedido_extra_item_' + id + '_dado_fornecido" name="adm_item_pedido_extra[item' + id + '[dado_fornecido]]">'
      itens = valor.split("|")
      itens.each do |i|
        item = i.split(";")
        if item[1].include? "%"
          strHtml += '<option value="' + i + '">' + item[0] + ' (' + number_to_percentage((item[1].sub('%', '').to_f * 100), :precision => 2) + ')</option>'
        else
          strHtml += '<option value="' + i + '">' + item[0] + ' (' + number_to_currency(item[1], :separator => ",", :delimiter => ".", :unit => "R$ ") + ')</option>'
        end
      end
      strHtml += '</select>'
    when 'checkbox'
      strHtml = ''
      itens = valor.split("|")
      itens.each do |i|
        item = i.split(";")
        if item[1].include? "%"
          strHtml += '<input id="adm_item_pedido_extra_item_' + id + '_dado_fornecido" name="adm_item_pedido_extra[item' + id + '[dado_fornecido[' + itens.index(i).to_s + ']]]" type="checkbox" value="' + i + '" /> &nbsp;' + item[0] + ' (' + number_to_percentage((item[1].sub('%', '').to_f * 100), :precision => 2) + ') <br />'
        else
          strHtml += '<input id="adm_item_pedido_extra_item_' + id + '_dado_fornecido" name="adm_item_pedido_extra[item' + id + '[dado_fornecido[' + itens.index(i).to_s + ']]]" type="checkbox" value="' + i + '" /> &nbsp;' + item[0] + ' (' + number_to_currency(item[1], :separator => ",", :delimiter => ".", :unit => "R$ ") + ') <br />'
        end
      end
    else
      strHtml = '<input id="adm_item_pedido_extra_item_' + id + '_dado_fornecido" name="adm_item_pedido_extra[item' + id + '[dado_fornecido]]" type="text" value="' + valor + '" />&nbsp; &nbsp;'
   end
   return strHtml.html_safe
  end
end
