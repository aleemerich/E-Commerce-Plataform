module Adm::CategoriasHelper
  def imprimir_filhos(categorias, nivel)
    str = ''
    categorias.each do |categoria|
      str += '<br /><input id="adm_categorias_categoria' + categoria.id.to_s + '_categoria_pai_id" name="adm_categorias[categoria' + categoria.id.to_s + '[categoria_pai_id]]" type="hidden" value="' + categoria.categoria_pai_id.to_s + '" />
      <input id="adm_categorias_categoria' + categoria.id.to_s + '_id" name="adm_categorias[categoria' + categoria.id.to_s + '[id]]" type="hidden" value="' + categoria.id.to_s + '" />
        ' + ('.....' * nivel) + ' <span style="font-size:large">( </span><input id="adm_categorias_categoria' + categoria.id.to_s + '_ordem" name="adm_categorias[categoria' + categoria.id.to_s + '[ordem]]" size="1" type="text" value="' + categoria.ordem.to_s + '" /><span style="font-size:large"> )</span> 
        <input id="adm_categorias_categoria' + categoria.id.to_s + '_descricao" name="adm_categorias[categoria' + categoria.id.to_s + '[descricao]]" size="30" type="text" value="' + categoria.descricao + '" />
         <a href="' + destroy_adm_categorias_path(categoria.id) + '">[excluir]</a>'
      if categoria.filhos.length > 0
        str += imprimir_filhos(categoria.filhos.order(:ordem), nivel + 2)
      end
    end
    return str
  end
  
  def select_filhos(categorias, nivel)
    str = ''
    categorias.each do |categoria|
      str += '<option value="' + categoria.id.to_s + '">' + ('...' * nivel) + categoria.descricao + '</option>'
      if categoria.filhos.length > 0
        str += select_filhos(categoria.filhos.order(:ordem), nivel + 2)
      end
    end
    return str
  end

  def checkbox_filhos(categorias, produto, nivel)
    str = ''
    categorias.each do |categoria|
      str += ('&nbsp; &nbsp;' * nivel) + ' <input id="categorias_' + categoria.id.to_s + '" name="categorias[' + categoria.id.to_s + ']" type="checkbox" value="' + categoria.id.to_s + '"'
      if produto.categoria.include? categoria
        str += 'checked="checked" /> '
      else
        str += ' /> '
      end
      str += categoria.descricao + '<br />'
      if categoria.filhos.length > 0
        str += checkbox_filhos(categoria.filhos.order(:ordem), produto, nivel + 2)
      end
    end
    return str
  end
end
