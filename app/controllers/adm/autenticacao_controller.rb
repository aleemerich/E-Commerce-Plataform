# encoding: UTF-8
class Adm::AutenticacaoController < ApplicationController
  before_filter :forca_bruta
  
  def index
    render :layout => false, :template => '/adm/autenticacao/index'
  end
  
  def login
    @usuario = Adm::Usuario.find(:first, :conditions => ["email = ? AND senha = ?", params[:email], params[:senha]])
    if @usuario
      if @usuario.status.codigo == '0' or @usuario.status.codigo == '1'
        session[:usuario] = Adm::Usuario.new
        session[:usuario].id = @usuario.id
        session[:usuario].nome_completo = @usuario.nome_completo
        session[:usuario].email = @usuario.email
        session[:usuario].status_id = @usuario.status_id
        session[:permissao] = @usuario.permissao.split(";")
        session[:duracao_sessao] = DateTime.now + 1.hour # TODO: Esse valor esta HARD e precisa ser setado via config 
        logUsuario(request.remote_ip, session[:usuario].id, "Autenticou com sucesso")
        if @usuario.url_entrada.nil? || @usuario.url_entrada.empty?
          redirect_to adm_painel_path
        else
          redirect_to @usuario.url_entrada
        end
      elsif @usuario.status.codigo == '1'
        logUsuario(request.remote_ip, -1, params[:email] + " autenticou, mas esta bloqueado")
        flash[:notice] = 'Seu usuário foi bloqueado'
        redirect_to adm_autenticacao_path
      else
        logUsuario(request.remote_ip, -1, params[:email] + " autenticou, mas estava com STATUS não previsto")
        flash[:notice] = 'Seu usuário esta com problemas'
        redirect_to adm_autenticacao_path 
      end
    else
      if !session[:controle].nil?
        session[:controle] = 1 + session[:controle]
        if session[:controle] == 2
          flash[:notice] = 'Usuário e senha não conferem! Você tem apenas mais 1 tentativa'
        else
          flash[:notice] = 'Usuário e senha não conferem! Você esta bloqueado temporariamente. Tente novamente daqui a 30 minutos.'
        end
      else
        session[:controle] = 1
        flash[:notice] = 'Usuário e senha não conferem! Você têm mais 2 tentativas'
      end
      logUsuario(request.remote_ip, -1, "[I] " + params[:email] + " - erro de autenticação. (tentativa = " + session[:controle].to_s + ")")
      redirect_to adm_autenticacao_path
    end
  end
  
  def logoff
    logUsuario(request.remote_ip, session[:usuario].id, "Saiu do sistema")
    reset_session
    flash[:notice] = 'Você saiu do sistema'
    redirect_to adm_autenticacao_path
  end
  
  # ===============
  #   VALIDACAO
  # ===============
  
  protected

  # Checa eventuais tentativas de quebra de senha por brute force
  # contudo esse métodos não é tão forte para se evitar essa situação
  # uma vez que o usuário pode apagar o cache de seu micro
  # TODO: É preciso mudar essa checagem no futuro.
  def forca_bruta
    if session[:controle]
      # Checa se o usuário atingiu o máximo de tentativas
      if session[:controle] == 3
        # Joga para 4 a fim de comecar a checar o tempo de suspensão
        session[:controle] = 1 + session[:controle]
        # Ativa time de bloqueio
        session[:time_bloqueio] = DateTime.now + 30.minute # TODO: Esse valor esta HARD e precisa ser setado via config
        logCliente(request.remote_ip, -1, -1, "[I] Bloqueio de acesso temporário (" + request.env['PATH_INFO'] + ")")
        render :text => 'Por tentar mais 3 vezes sem sucesso, você esta bloqueado temporariamente! Tente novamente daqui a 30 minutos.'
      elsif session[:controle] == 4
        # Checa se o tempo de suspensão do acesso esgotou
        if session[:time_bloqueio] < DateTime.now
          # Se esgotou, reseta a sessao para ele tentar novamente
          reset_session
          logCliente(request.remote_ip, -1, -1, "Bloqueio de acesso temporário liberado")
        else
          # Caso contrário, continua a emitir a mensagem ao cliente
          render :text => 'Por tentar mais 3 vezes sem sucesso, você esta bloqueado temporariamente! Tente novamente daqui a 30 minutos.'
        end
      end
    end
  end
end
