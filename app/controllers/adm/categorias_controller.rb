# encoding: UTF-8
class Adm::CategoriasController < ApplicationController
  before_filter :permissao
  
  layout "adm"
  def index
    # config de layout     
    @layout = Array.new()
    @layout[0] = "produto" # menu     
    @layout[1] = "Categoria" # titulos     
    @layout[2] = "slogan" # subtitulo_css     
    @layout[3] = "Editar/Inserir categorias" # subtitulo_css     
    @layout[4] = "" #subtitulo_url
    @layout[5] = "produtos/search" #busca_url
    
    @adm_categoria = Adm::Categoria.new
    @adm_categorias = Adm::Categoria.where("categoria_pai_id is null").order(:ordem).all
  end

  def create
    begin
      categoria = Adm::Categoria.new(params[:adm_categoria])
      categoria.save
      logUsuario(request.remote_ip, session[:usuario].id, "Nova categoria criada (ID " + categoria.id.to_s + ")") 
      redirect_to adm_categorias_path, :notice => "Uma nova categoria foi criada."
    rescue
      logUsuario(request.remote_ip, session[:usuario].id, "[I] Erro ao criar uma nova categoria. ERRO: " + $!.to_s)
      redirect_to adm_categorias_path, :notice => "Ocorreu um erro ao criar uma nova categoria."
    end
  end
  
  def update
    begin
      params[:adm_categorias].values.each do |c|
        categoria = Adm::Categoria.find(c[:id])
        categoria.update_attributes(c)
      end
      logUsuario(request.remote_ip, session[:usuario].id, "Categorias atualizadas")
      redirect_to adm_categorias_path, :notice => "Atualização feita com sucesso."
    rescue
      logUsuario(request.remote_ip, session[:usuario].id, "[I] Erro ao atualizar uma categoria. ERRO: " + $!.to_s)
      redirect_to adm_categorias_path, :notice => "Ocorreu um erro e a atualização NÃO foi feita completamente."
    end
  end
  
  def destroy
    begin
      categoria = Adm::Categoria.find(params[:id])
      categoria.destroy
      logUsuario(request.remote_ip, session[:usuario].id, "Categoria excluída (ID " + params[:id] + ")")
      redirect_to adm_categorias_path, :notice => "A categoria foi excluída com sucesso."
    rescue
      logUsuario(request.remote_ip, session[:usuario].id, "[I] Erro ao apagar uma categoria (ID " + params[:id] + "). ERRO: " + $!.to_s)
      redirect_to adm_categorias_path, :notice => "Erro ao excluir a categoria."
    end
  end
end
