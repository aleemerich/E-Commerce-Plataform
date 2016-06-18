# encoding: UTF-8
class Adm::UsuariosController < ApplicationController
   before_filter :permissao
  
   layout "adm"
   # GET /adm/usuarios
   # GET /adm/usuarios.xml
   def index  
    # config de layout     
    @layout = Array.new()
    @layout[0] = "funcionario" # menu     
    @layout[1] = "Funcionários" # titulos     
    @layout[2] = "sloganD2" # subtitulo_css     
    @layout[3] = "Adicionar um funcionário" # subtitulo_css     
    @layout[4] = "usuarios/new" #subtitulo_url
    @layout[5] = "usuarios/search" #busca_url
    
    # paginacao
    if params[:pag]
      @offset = params[:pag].to_i
    else
      @offset = 0
    end
    
    # criando a lista
    @adm_usuarios_full = Adm::Usuario.limit(20).offset(@offset).all
    
    # filtrando pela permissao do usuário os registros que ele pode ver
    if session[:usuario].status.area.codigo == '0'
      @adm_usuarios = @adm_usuarios_full
    else
      @adm_usuarios = @adm_usuarios_full.find_all {|u|  (u.status.codigo == '0' and u.status.area.codigo == '1') or (u.status.codigo == '1' and u.status.area.codigo == '1') }
    end
    
    # verificando se há usuarios a retornar 
    if @adm_usuarios.length == 0 and params[:pag]
      redirect_to(adm_usuarios_path, :notice => 'Não ha mais usuários')
    else
      respond_to do |format|
        format.html # index.html.erb       
        format.xml  { render :xml => @adm_usuarios } 
      end
    end
   end
      

  # GET /adm/usuarios/1   
  # GET /adm/usuarios/1.xml   
  def show     
    # config de layout     
    @layout = Array.new     
    @layout[0] = "funcionario"     
    @layout[1] = "Ficha do Funcionário"    
    @layout[2] = "sloganD3"     
    @layout[3] = "COD: " + params[:id]    
    @layout[4] = ""
    @layout[5] = "/adm/usuarios/search" 

    @adm_usuario = Adm::Usuario.find(params[:id])
    @acessos = LogUsuario.order("created_at DESC").limit(10).where(["usuario_id = ?", @adm_usuario.id]).all

    respond_to do |format|       
      format.html # show.html.erb       
      format.xml  { render :xml => @adm_usuario }
    end
  end

  # GET /adm/usuarios/new   
  # GET /adm/usuarios/new.xml   
  def new      
    # config de layout     
    @layout = Array.new     
    @layout[0] = "funcionario"     
    @layout[1] = "Novo Funcionário"     
    @layout[2] = "slogan"     
    @layout[3] = "Cadastro de novo funcionario"     
    @layout[4] = ""
    @layout[5] = "/adm/usuarios/search" #busca_url

    @adm_usuario = Adm::Usuario.new
    @areas = Area.all
    @permissao_item = PermissaoItem.order("cod_acesso ASC").all
    
    respond_to do |format|       
      format.html # new.html.erb       
      format.xml  { render :xml => @adm_usuario }
    end   
  end

  # GET /adm/usuarios/1/edit   
  def edit     
     # config de layout     
    @layout = Array.new     
    @layout[0] = "funcionario"     
    @layout[1] = "Ficha do Funcionário"    
    @layout[2] = "slogan"     
    @layout[3] = "COD: " + params[:id]    
    @layout[4] = ""
    @layout[5] = "/adm/usuarios/search"
    
    @areas = Area.all
    @permissao_item = PermissaoItem.order("cod_acesso ASC").all
    @adm_usuario = Adm::Usuario.new
    @adm_usuario = Adm::Usuario.find(params[:id])
    @acessos = LogUsuario.order("created_at DESC").limit(10).where(["usuario_id = ?", @adm_usuario.id]).all
  end
  
  # GET /adm/usuarios/1/block   
  # GET /adm/usuarios/1/block.xml 
  def block     
    @adm_usuario = Adm::Usuario.find(params[:id])
    @adm_usuario.status_id = Status.where(["codigo = '1'and area_id = ?", Area.select('id').where(["codigo = 1"]).first]).first.id
    @adm_usuario.save
    respond_to do |format|
      format.html { redirect_to(@adm_usuario, :notice => 'O usuário foi bloqueado') }      
      format.xml  { render :xml => @adm_usuarios } 
    end
  end

  # POST /adm/usuarios   
  # POST /adm/usuarios.xml  
  def create     
    @adm_usuario = Adm::Usuario.new(params[:adm_usuario])
    if params[:permissao_item]
      str = String.new
      params[:permissao_item].each {|p| str = str + p[1] + ";"}
      @adm_usuario.permissao = str
    else
      @adm_usuario.permissao = '0'
    end
    if @adm_usuario.save   
      logUsuario(request.remote_ip, session[:usuario].id, "Novo funcionário criado (ID " + @adm_usuario.id.to_s + ")")      
      redirect_to(adm_usuarios_path, :notice => 'Novo funcionário adicionado com sucesso.')       
    else 
      logUsuario(request.remote_ip, session[:usuario].id, "Problemas ao criar um novo funcionário")      
      redirect_to :back, :notice => 'Os dados não foram salvos. Revise-os e tente novamente.'
    end     
  end

  # PUT /adm/usuarios/1   
  # PUT /adm/usuarios/1.xml   
  def update     
    @adm_usuario = Adm::Usuario.find(params[:id])
    @adm_usuario.update_attributes(params[:adm_usuario])
    if params[:permissao_item]
      str = String.new
      params[:permissao_item].each {|p| str = str + p[1] + ";"}
      @adm_usuario.permissao = str
    else
      @adm_usuario.permissao = '0'
    end
    if @adm_usuario.save
      logUsuario(request.remote_ip, session[:usuario].id, "Dados do funcionário editado (ID " + @adm_usuario.id.to_s + ")")
      redirect_to(:adm_usuarios, :notice => 'Os dados do usuário foram alterados com sucesso e só terão validade quando ele se logar novamente.') 
    else
      logUsuario(request.remote_ip, session[:usuario].id, "[I] problemas ao editar o funcionário (ID " + @adm_usuario.id.to_s + ")")         
      redirect_to :back, :notice => 'Os dados não foram salvos. Revise-os e tente novamente.'    
    end     
  end

  # DELETE /adm/usuarios/1   
  # DELETE /adm/usuarios/1.xml   
  def destroy     
    @adm_usuario = Adm::Usuario.find(params[:id])     
    @adm_usuario.status_id = Status.where(["codigo = '2'and area_id = ?", Area.select('id').where(["codigo = '1'"]).first]).first.id
    if @adm_usuario.save
      logUsuario(request.remote_ip, session[:usuario].id, "Funcionário excluido (ID " + @adm_usuario.id.to_s + ")")
      redirect_to(adm_usuarios_url, :notice => 'O funcionário foi apagado')
    else
      logUsuario(request.remote_ip, session[:usuario].id, "Problemas ao bloquear um usuário (ID " + params[:id] + ")")
      redirect_to :back, :notice => 'Problemas ao bloquear o funcionário. O funcionário não foi apagado'
    end   
  end 
  
  # GET /adm/usuarios/search
  def search
    # config de layout     
    @layout = Array.new()
    @layout[0] = "funcionario" # menu     
    @layout[1] = "Busca de Funcionário"    
    @layout[2] = "sloganD3"     
    @layout[3] = 'Resultado da busca por "' + params[:busca] + '"'    
    @layout[4] = ""
    @layout[5] = "/adm/usuarios/search" #busca_url
    
    # criando a lista
    @adm_usuarios_full = Adm::Usuario.where('nome_completo LIKE "%' + params[:busca] + '%" OR email LIKE "%' + params[:busca] + '%"').all
    
    # filtrando pela permissao do usuário os registros que ele pode ver
    if session[:usuario].status.area.codigo != '0'
      @adm_usuarios = @adm_usuarios_full.find_all {|u|  u.status.codigo == '0' or u.status.codigo == '1' }
    else
      @adm_usuarios = @adm_usuarios_full
    end

    if @adm_usuarios.length > 0
      # render search.html.erb
    else
      redirect_to(adm_usuarios_path, :notice => 'A busca não retornou nenhum resultado')
    end
  end
end