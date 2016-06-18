# encoding: UTF-8
module ArquivosHelper
 def mostraFoto(produto)
    arquivos = Arquivo.where(['fl_sistema = 1 AND produto_id = ? AND status_id = ?', produto.id, Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id]).order('RAND()').all
    arquivos.shuffle!
    if arquivos.length == 0
      str ='<img width="80" height="80" style="vertical-align:top; margin: 0px 20px 0px 0px; padding: 0 0 0 0; float:left;" src="/images/sem_foto.gif" />'
     else
      str ='<img width="80" height="80" style="vertical-align:top; margin: 0px 20px 0px 0px; padding: 0 0 0 0; float:left;" src="/temp/' + arquivos[0].nome + '" />'
    end
    return str.html_safe
 end
 
 def mostraFotos(produto, qtde)
    arquivos = Arquivo.where(['fl_sistema = 1 AND produto_id = ? AND status_id = ?', produto.id, Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id]).order('RAND()').all
    arquivos.shuffle!
    
    str = '' 
    i = 0
    while i < qtde
      if arquivos[i].nil?
        str +='<img width="160" height="160" style="vertical-align:top; margin: 0px 0px 0px 20px; padding: 0 0 0 0;" src="/images/sem_foto.gif" /><br /><br />'
      else
        str +='<img width="160" height="160" style="vertical-align:top; margin: 0px 0px 0px 20px; padding: 0 0 0 0;" src="/temp/' + arquivos[i].nome + '" /><br /><br />'
      end
      i +=1
    end
    return str.html_safe
 end

 def mostra_foto_publico(produto)
    arquivos = Arquivo.where(['fl_sistema = 1 AND produto_id = ? AND status_id = ?', produto.id, Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id]).order('RAND()').all
    arquivos.shuffle!
    
    if arquivos.length == 0
      str = '<img width="160" height="160" src="/images/sem_foto.gif" alt="' + produto.nome + '" />'
     else
      str = '<img width="160" height="160" src="/temp/' + arquivos[0].nome + '" alt="' + produto.nome + '" />'
    end
    return str.html_safe
 end

end
