# encoding: UTF-8
class Adm::ProdutosController < ApplicationController
  before_filter :permissao
  
  layout "adm"
  # GET /adm/produtos(/pag/:pag)
  # GET /adm/produtos.xml(/pag/:pag)
  def index
    # config de layout     
    @layout = Array.new()
    @layout[0] = "produto" # menu     
    @layout[1] = "Produtos" # titulos     
    @layout[2] = "sloganD2" # subtitulo_css     
    @layout[3] = "Adicionar um produto" # subtitulo_css     
    @layout[4] = "produtos/new" #subtitulo_url
    @layout[5] = "produtos/search" #busca_url

    # paginacao
    if params[:pag]
      @offset = params[:pag].to_i
    else
      @offset = 0
    end
    
    # criando a lista
    @adm_produtos_full = Adm::Produto.limit(20).offset(@offset).all

    # filtrando pela permissao do usuário os registros que ele pode ver
    if session[:usuario].status.area.codigo != '0'
      @adm_produtos = @adm_produtos_full.find_all {|p|  p.status.codigo == '0' or p.status.codigo == '1' }
    else
      @adm_produtos = @adm_produtos_full
    end

    if @adm_produtos.length == 0 and params[:pag]
        redirect_to(adm_produtos_path, :notice => 'Não ha mais produtos')
    else
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @adm_produtos }
      end    
    end
  end

  # GET /adm/produtos/1
  # GET /adm/produtos/1.xml
  def show
    # config de layout     
    @layout = Array.new     
    @layout[0] = "produto"     
    @layout[1] = "Ficha do Produto"    
    @layout[2] = "slogan"     
    @layout[3] = "COD: " + "%07d" % params[:id]    
    @layout[4] = ""
    @layout[5] = "/adm/produtos/search" 
   
    @adm_produto = Adm::Produto.find(params[:id])
   
    # LEMBRETE
    # Para a edicao dos modelos produto_extra funcione, eh preciso 
    # criar uma funcao do application_helper que possibilita ativar ou
    # não o java script que abre o form de edicao.
    # Inclusive eh tb por isso que o DIV que faz o efeito light box fica
    # criado na pagina e não dinamicamente como o de costume.
   
    # obtendo registros
    @arquivos_full = Arquivo.where(['fl_sistema = 1 AND produto_id = ?', @adm_produto.id]).all
    @adm_produto_extras_full = Adm::ProdutoExtra.where(['produto_id = ?', @adm_produto.id]).all
    
    # filtrando pela permissao do usuário os registros que ele pode ver
    if session[:usuario].status.area.codigo == '0'
      @arquivos = @arquivos_full
      @adm_produto_extras = @adm_produto_extras_full
    else
      @arquivos = @arquivos_full.find_all {|a|  a.status.codigo == '0' }
      @adm_produto_extras = @adm_produto_extras_full.find_all {|p|  p.status.codigo == '0' }
    end

    # verificando se é uma edição de Produto Extra
    if params[:id_produto_extras]
      @adm_produto_extra = Adm::ProdutoExtra.find(params[:id_produto_extras])
    else
      @adm_produto_extra = Adm::ProdutoExtra.new
    end
    
    # obtendo dados extras
    @historico = LogProduto.order("created_at DESC").limit(10).where(["produto_id = ?", @adm_produto.id]).all
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @adm_produto }
    end
  end

  # GET /adm/produtos/new
  # GET /adm/produtos/new.xml
  def new
     # config de layout     
    @layout = Array.new     
    @layout[0] = "produto"     
    @layout[1] = "Novo Produto"     
    @layout[2] = "slogan"     
    @layout[3] = "Cadastro de novo produto"     
    @layout[4] = ""
    @layout[5] = "/adm/produtos/search"
    
    @adm_produto = Adm::Produto.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @adm_produto }
    end
  end

  # GET /adm/produtos/1/edit
  def edit
     # config de layout     
    @layout = Array.new     
    @layout[0] = "produto"     
    @layout[1] = "Ficha do Produto"    
    @layout[2] = "slogan"     
    @layout[3] = "COD: " + "%07d" % params[:id]    
    @layout[4] = ""
    @layout[5] = "/adm/produtos/search" 

    @adm_produto = Adm::Produto.find(params[:id])
    
    @historico = LogProduto.order("created_at DESC").limit(10).where(["produto_id = ?", @adm_produto.id]).all
  end
  
  # GET /adm/produtos/1/block   
  # GET /adm/produtos/1/block.xml 
  def block     
    @adm_produto = Adm::Produto.find(params[:id])
    @adm_produto.status_id = Status.where(["codigo = '1' and area_id = ?", Area.select('id').where(["codigo = 3"]).first]).first.id
    @adm_produto.save
    logProduto(request.remote_ip, @adm_produto.id, session[:usuario].id, "Produto bloqueado")
    respond_to do |format|
      format.html { redirect_to(@adm_produto, :notice => 'O produto foi bloqueado') }      
      format.xml  { render :xml => @adm_produto } 
    end
  end


  # POST /adm/produtos
  # POST /adm/produtos.xml
  def create
    params[:adm_produto][:perc_comissao] = params[:adm_produto][:perc_comissao].to_f / 100.0  # deixando na forma percentual correta
    @adm_produto = Adm::Produto.new(params[:adm_produto])
    respond_to do |format|
      if @adm_produto.save
        grava_categoria(params[:categorias], @adm_produto)
        logProduto(request.remote_ip, @adm_produto.id, session[:usuario].id, "Novo produto criado")
        format.html { redirect_to(:adm_produtos, :notice => 'Produto criado com sucesso') }
        format.xml  { render :xml => @adm_produto, :status => :created, :location => @adm_produto }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @adm_produto.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /adm/produtos/1
  # PUT /adm/produtos/1.xml
  def update
    params[:adm_produto][:perc_comissao] = params[:adm_produto][:perc_comissao].to_f / 100.0  # deixando na forma percentual correta
    @adm_produto = Adm::Produto.find(params[:id])
    
    respond_to do |format|
      if @adm_produto.update_attributes(params[:adm_produto])
        grava_categoria(params[:categorias], @adm_produto)
        logProduto(request.remote_ip, @adm_produto.id, session[:usuario].id, "Produto editado")
        format.html { redirect_to(:adm_produtos, :notice => 'Os novos dados do produto foram salvos') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @adm_produto.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /adm/produtos/1
  # DELETE /adm/produtos/1.xml
  def destroy
    @adm_produto = Adm::Produto.find(params[:id])
    @adm_produto.status_id = Status.where(["codigo = '2'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id
    @adm_produto.save
    logProduto(request.remote_ip, @adm_produto.id, session[:usuario].id, "Produto apagado")
    respond_to do |format|
      format.html { redirect_to(adm_produtos_url) }
      format.xml  { head :ok }
    end
  end
  
  # GET /adm/produtos/search
  def search
    # config de layout     
    @layout = Array.new()
    @layout[0] = "cliente" # menu     
    @layout[1] = "Busca de Produtos" # titulos     
    @layout[2] = "sloganD3" # subtitulo_css     
    @layout[3] = 'Resultado da busca por "' + params[:busca] + '"'     
    @layout[4] = "" #subtitulo_url
    @layout[5] = "/adm/produtos/search" #busca_url


    # criando a lista
    @adm_produtos_full = Adm::Produto.where('nome LIKE "%' + params[:busca] + '%" OR id LIKE "%' + params[:busca] + '%"').all
    
    # filtrando pela permissao do usuário os registros que ele pode ver
    if session[:usuario].status.area.codigo != '0'
      @adm_produtos = @adm_produtos_full.find_all {|c|  c.status.codigo == '0' or c.status.codigo == '1' }
    else
      @adm_produtos = @adm_produtos_full
    end
    
    #fazendo o encaminhamento
    if @adm_produtos.length > 0
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @adm_produtos }
      end
    else
        redirect_to(adm_produtos_path, :notice => 'A busca não retornou nenhum resultado')
    end
  end
  
  def grava_categoria(categorias, produto)
    # Lembrete: Não foi encontrado como atualizar dados de tabelas
    # relacionadas com "has_and_belongs_to_many", por isso apaga-se
    # todos os registros e os insere novamente de acordo com o que
    # foi escolhido
    # TODO: Isso precisa ser revisto
    CategoriasProdutos.delete_all(['produto_id = ?', produto.id])
    categorias.each do |v|
      prod_cat = CategoriasProdutos.new
      prod_cat.categoria_id = v[0].to_i # TODO: Isso precisa ser melhorado
      prod_cat.produto_id = produto.id
      prod_cat.save
    end
  end
end
