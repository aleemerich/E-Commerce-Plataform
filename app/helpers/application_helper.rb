# encoding: UTF-8
module ApplicationHelper
  def carga_js
    if @adm_endereco
      if !@adm_endereco.new_record?
        return "abrirFormEndereco(); document.getElementById('btn_endereco_fechar').style.visibility = \"hidden\";"
      end
    end
    if @adm_telefone
      if !@adm_telefone.new_record?
        return "abrirFormTelefone(); document.getElementById('btn_telefone_fechar').style.visibility = \"hidden\";"
      end
    end
    if @adm_produto_extra
      if !@adm_produto_extra.new_record?
        return "abrirFormProdutoExtra(); document.getElementById('btn_produto_extra_fechar').style.visibility = \"hidden\";"
      end
    end
 end
end
