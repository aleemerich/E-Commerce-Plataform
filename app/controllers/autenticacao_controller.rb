# encoding: UTF-8
class AutenticacaoController < ApplicationController
  # Filtra acesso em demasiado sem acerto
  before_filter :forca_bruta
  layout 'publico'

  def login
    @cliente = Adm::Cliente.find(:first, :conditions => ["email = ? AND senha = ?", params[:email], params[:pass]])
    if @cliente
      if @cliente.status.codigo == '0'
        session[:cliente] = Adm::Cliente.new
        session[:cliente].id = @cliente.id
        session[:cliente].nome_completo = @cliente.nome_completo
        session[:cliente].email = @cliente.email
        session[:cliente].status_id = @cliente.status_id
        # Define o tempo máximo sem atividade no sistema
        session[:duracao_sessao] = DateTime.now + 1.hour # TODO: Esse valor esta HARD e precisa ser setado via config
        logCliente(request.remote_ip, @cliente.id, -1, "Cliente autenticado")
        redirect_to(:index_publico)
      elsif @cliente.status.codigo == '1'
        logCliente(request.remote_ip, @cliente.id, -1, "Cliente autenticado, mas bloqueado")
        flash[:notice] = 'Seu usuário foi bloqueado'
        redirect_to :index_publico
      elsif @cliente.status.codigo == '3'
        logCliente(request.remote_ip, @cliente.id, -1, "Cliente autenticado, mas não validado")
        flash[:notice] = 'Seu usuário ainda não foi validado. Consulte seu e-mail.'
        redirect_to :index_publico
      else
        logCliente(request.remote_ip, @cliente.id, -1, "Cliente autenticado, mas esta com problemas")
        flash[:notice] = 'Seu usuário está com problemas'
        redirect_to :index_publico 
      end
    else
      if session[:controle].nil?
        session[:controle] = 1
        flash[:notice] = 'Usuario e senha não conferem! Você tem mais 2 tentativas'
      else
        session[:controle] = 1 + session[:controle]
        if session[:controle] == 2
          flash[:notice] = 'Usuario e senha não conferem! Você tem apenas mais 1 tentativa'
        else
          flash[:notice] = 'Usuario e senha não conferem! Você esta bloqueado temporariamente. Tente novamente daqui a 30 minutos.'
        end
      end
      logCliente(request.remote_ip, -1, -1, "[I] " + params[:email] + " - erro de autenticacao. (tentativa = " + session[:controle].to_s + ")")
      redirect_to index_publico_path
    end
  end
  
  def logoff
    logCliente(request.remote_ip, session[:cliente].id, -1, "Cliente saiu do sistema")
    reset_session
    flash[:notice] = 'Você saiu do sistema'
    redirect_to index_publico_path
  end

  def validacao
    begin
      @cliente = Adm::Cliente.find(:first, :conditions => ["chave_autenticacao = ?", params[:chave]])
      if @cliente
        if @cliente.status_id == Status.where(["codigo = '3' and area_id = ?", Area.select('id').where(["codigo = 2"]).first]).first.id
          @cliente.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 2"]).first]).first.id
          if @cliente.save
            flash[:notice] = 'Seu cadastro foi validado! Basta agora se autenticar abaixo.'
            logCliente(request.remote_ip, @cliente.id, -1, "Cliente validou seu cadastro")
          else
            flash[:notice] = 'Houve problemas ao validar sua chave. Procure-nos.'
            logCliente(request.remote_ip, @cliente.id, -1, "[I] Erro ao salvar o novo STATUS do cliente na validação de sua chave")
          end
        else
          flash[:notice] = 'Essa chave já foi validada.'
          logCliente(request.remote_ip, @cliente.id, -1, "[I] O cliente não estava com STATUS para validar, mas usou a chave.")
        end
      else
        flash[:notice] = 'Chave inválida.'
        logCliente(request.remote_ip, -1, -1, "[I] Tentativa de uso de uma chave inválida.")
      end
    rescue
      flash[:notice] = 'Problemas para validar o cadastro. Um aviso foi enviado ao suporte. Se desejar, entre em contato conosco.'
      begin
        # Esse log envia e-mail, então foi colocado entre TRY - CATCH para
        # não atrapalhar o fluxo do sistem em eventual problema de envio de e-mail
        logCritico("AUTENTICACAO_CONTROLLER -> VALIDAÇÃO: ERRO = " + $!.to_s)
      end
      logCliente(request.remote_ip, -1, -1, "[I] ERRO AO VALIDAR CADASTRO = " + $!.to_s[0,200])
    end
    redirect_to index_publico_path
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
