# encoding: UTF-8
class ArquivosController < ApplicationController
  # Verifica se o usuário está autenticado, tanto como usuário ADM
  # ou como um cliente no PUBLICO
  before_filter :permissao_arquivo

  def create
    @arquivo = Arquivo.new(params[:arquivo])
    @arquivo.nome = SecureRandom.hex(14) + File.extname(params[:arquivo][:caminho].original_filename) 
    @arquivo.caminho = File.join(Rails.root, "public/temp/", @arquivo.nome)
    @arquivo.status_id = Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id
    @arquivo.fl_sistema = true
    
    arquivo_up = File.open(@arquivo.caminho, "wb")
    if arquivo_up
      arquivo_up.write(params[:arquivo][:caminho].read)
      arquivo_up.close
      @arquivo.save
      logProduto(request.remote_ip, @arquivo.produto_id, session[:usuario].id, "Um arquivo foi enviado (ID " + @arquivo.id.to_s + ")")
      redirect_to "/adm/produtos/" + @arquivo.produto_id.to_s, :notice => 'Seu arquivo foi gravado com sucesso' 
    else
      arquivo_up.close
      logProduto(request.remote_ip, @arquivo.produto_id, session[:usuario].id, "Problemas ao enviar o arquivo")
      redirect_to "/adm/produtos/" + @arquivo.produto_id.to_s, :notice => 'Houve problemas e seu arquivo não foi gravado'
    end
  end
  
  def destroy
    @arquivo = Arquivo.find(params[:id])
    @arquivo.status_id = Status.where(["codigo = '2'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id
    @arquivo.save
    logProduto(request.remote_ip, @arquivo.produto_id, session[:usuario].id, "Um arquivo foi excluido (ID " + @arquivo.id.to_s + ")")
    redirect_to "/adm/produtos/" + @arquivo.produto_id.to_s, :notice => 'Arquivo apagado'
  end

  def active
    @arquivo = Arquivo.find(params[:id])
    @arquivo.status_id = Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id
    @arquivo.save
    logProduto(request.remote_ip, @arquivo.produto_id, session[:usuario].id, "Um arquivo foi ativado (ID " + @arquivo.id.to_s + ")")
    redirect_to "/adm/produtos/" + @arquivo.produto_id.to_s, :notice => 'Status do arquivo modificado'
  end



  # ===============
  #   VALIDACAO
  # ===============
  
  protected

  def permissao_arquivo
    # Essa funcao é necessária porque o sistema trabalha com os dois
    # tipos de usuarios acessando esse mesmo controle
    if permissao
      true
    elsif permissao_publico
      true
    else
      false
    end
  end
end
