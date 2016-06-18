# encoding: UTF-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # Faz a verificação de autenticação para o ADM
  def permissao
    # verifica se tem sessão registrada
    if !session[:usuario].nil?
      # Verifica se a sessão expirou
      if session[:duracao_sessao] < DateTime.now
        reset_session
        redirect_to adm_autenticacao_path, :notice => 'Sua sessão expirou por inatividade. Faça novamente sua autenticação.'
        false
      else
        # Prolonga a duração da sessão devido ao uso normal
        session[:duracao_sessao] = DateTime.now + 1.hour # TODO: Esse valor esta HARD e precisa ser setado via config
        # verifica se tem status ATIVO e area ARICH
        if session[:usuario].status.codigo == '0' and session[:usuario].status.area.codigo == '0'
          session[:ultima_url] = request.env['PATH_INFO']
          true
        else
          # verifica se tem tem permissao 
          if !session[:permissao].index(params[:cod_acesso]).nil?
            session[:ultima_url] = request.env['PATH_INFO']
            true
          else
            if session[:ultima_url]
              logUsuario(request.remote_ip,session[:usuario].id, "Acesso negado (" + request.env['PATH_INFO'] + ")")
              # TODO: Acredito que não será mais necessário usar session[:ultima_url] porque o :back resolveu. 
              # Usar o session[:ultima_url] causa distorção quando se usa AJAX dado que a ultima URL é a consultada
              # eplo AJAX. Usar o back evita esse erro e aparentemente dá o mesmo resultado. É preciso mais testes
              # para certificar que essa troca não dê erros.
              #redirect_to session[:ultima_url], :notice => 'Você não tem acesso'
              redirect_to :back, :notice => 'Você não tem acesso'
            else
              logUsuario(request.remote_ip,session[:usuario].id, "[I] Acesso indevido (" + request.env['PATH_INFO'] + ")")
              redirect_to adm_autenticacao_path, :notice => 'Você não tem acesso'
            end
          end
        end
      end
    else
      logUsuario(request.remote_ip, -1, "[I] Acesso indevido (" + request.env['PATH_INFO'] + ")")
      redirect_to adm_autenticacao_path, :notice => 'Você não tem acesso! Seu IP ' + request.remote_ip + 'foi armazenado.'
    end
    
  end

  # Faz a verificação de autenticação para o PUBLICO
  def permissao_publico
    # verifica se tem sessão registrada
    if !session[:cliente].nil?
      if session[:duracao_sessao] < DateTime.now
        reset_session
        redirect_to index_publico_path, :notice => 'Sua sessão expirou por inatividade. Faça novamente sua autenticação.'
        false
      else
        # Prolonga a duração da sessão devido ao uso normal
        session[:duracao_sessao] = DateTime.now + 1.hour # TODO: Esse valor esta HARD e precisa ser setado via config
        session[:ultima_url] = request.env['PATH_INFO']
        true
      end
    else
      logUsuario(request.remote_ip, -1, "[I] Acesso indevido (" + request.env['PATH_INFO'] + ")")
      redirect_to index_publico_path, :notice => 'Essa área é reservada aos nossos clientes! Faça já seu cadastro e aproveite!'
      false
    end
  end

  # Sobrescrevendo uma função do sistema para mostrar erros mais amigáveis
  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    if instance.error_message.kind_of?(Array)
      %(#{html_tag}<span style="color:#F00">&nbsp;
        #{instance.error_message.join('|')}</span>).html_safe
    else
      %(#{html_tag}<span style="color:#F00">&nbsp;
        #{instance.error_message}</span>).html_safe
    end
  end

  def logCritico(msg)
    begin
      Notificacao.sistema_erro(msg).deliver
      logger.fatal msg
    rescue
      logger.fatal msg
      logger.fatal 'application_controller => logCritico = ERRO: ' + $!.to_s
    end
  end
  
  def logUsuario(xip_usuario, xadm_usuario_id, xacao)
    @log = LogUsuario.new
    @log.ip = xip_usuario
    @log.usuario_id = xadm_usuario_id
    @log.acao = xacao
    @log.save
  end

  def logCliente(xip_cliente, xadm_cliente_id, xadm_usuario_id, xacao)
    @log = LogCliente.new
    @log.ip = xip_cliente
    @log.cliente_id = xadm_cliente_id
    @log.usuario_id = xadm_usuario_id
    @log.acao = xacao
    @log.save
  end

  def logProduto(xip_cliente, xadm_produto_id, xadm_usuario_id, xacao)
    @log = LogProduto.new
    @log.ip = xip_cliente
    @log.produto_id = xadm_produto_id
    @log.usuario_id = xadm_usuario_id
    @log.acao = xacao
    @log.save
  end

  def logPedido(xip_cliente, xadm_pedido_id, xadm_usuario_id, xacao)
    @log = LogPedido.new
    @log.ip = xip_cliente
    @log.pedido_id = xadm_pedido_id
    @log.usuario_id = xadm_usuario_id
    @log.acao = xacao
    @log.save
  end

  def calculoTotal(pedido)
    begin
      soma = 0.0
 logger.debug '===========> INICIO'
      pedido.item_pedido.select{|i| i if i.status.codigo == 'IP-0'}.each do |item|
        item.valor_total = calculoSubItens(item)
        begin
              calculoComissao(item)
        rescue
 logger.debug '===========> ERRO COMISSÃO'
 logger.debug "Erro #{$!}"
        end
 logger.debug 'item.valor_total'
 logger.debug item.valor_total
        item.save
        soma += item.valor_total
 logger.debug 'soma'
 logger.debug soma
      end
      soma += pedido.valor_envio
 logger.debug 'soma + pedido.valor_envio'
 logger.debug soma
      soma -= pedido.valor_desconto
 logger.debug 'soma - pedido.valor_desconto'
 logger.debug soma
      pedido.total = soma
 logger.debug '===========> FIM'
      pedido.save ? true : false
    rescue
 logger.debug '===========> ERRO'
 logger.debug "Erro #{$!}"
      false
    end
  end
  
  def calculoSubItens(item)
    vIndiv = item.valor_unitario
    qdte = item.quantidade
 logger.debug 'vIndiv (inicial)'
 logger.debug vIndiv
    #primeiro verificando os valores individuais
    item.item_pedido_extra.each do |extra|
      case extra.codigo_fator_calculo
      when 'soma_individual'
        vIndiv += extra.valor 
      when 'perc_individual'
        vIndiv = vIndiv * (extra.valor == 0.0 ? 1 : 1 + extra.valor) # Para percentuais
     end
    end
 logger.debug 'vIndiv'
 logger.debug vIndiv
 logger.debug 'qdte'
 logger.debug qdte
    
    total = vIndiv * qdte

 logger.debug 'total'
 logger.debug total

    #agora os valores totais
    item.item_pedido_extra.each do |extra|
      case extra.codigo_fator_calculo
      when 'soma_total'
        total += extra.valor 
      when 'perc_total'
        total = total * (extra.valor == 0.0 ? 1 : 1 + extra.valor) # Para percentuais
      end
    end
 logger.debug 'total + valores totais'
 logger.debug total
    
    #agora cópias
    #
    # Lembrete: essa ordem é necessária para que o 
    # calculo seja feito corretamente. É preciso
    # calcular individual, depois sob o total
    # e por fim ver quantas vezes isso vai ser 
    # multiplicado (cópias)
    item.item_pedido_extra.each do |extra|
      case extra.codigo_fator_calculo
      when 'multiplicacao_quantidade'
        if !extra.dado_fornecido.nil?
          if extra.dado_fornecido.to_f > 0
            apoio = extra.dado_fornecido.to_f
          else
            apoio = 1
          end
        else
          apoio = 1
        end
        total = total * apoio
      end
    end
 logger.debug 'total + copias (final)'
 logger.debug total

    return (total.nil? or total.blank?) ? 0.0 : total
  end
  
  def calculoComissao(item)
 logger.debug 'fazendo busca'
    comissao = Adm::Comissao.first(:conditions => ['item_pedido_id = ?', item.id])
 logger.debug 'analizando a busca'
    if comissao
 logger.debug 'atualizacao de dados'
      comissao.quantidade = item.quantidade
      comissao.valor_unitario = item.valor_unitario
      comissao.perc_comissao = item.produto.perc_comissao
      comissao.valor_comissao = (item.valor_total * item.produto.perc_comissao)
    else
 logger.debug 'inserindo nova comissao'
      comissao = Adm::Comissao.new
 logger.debug 'item.pedido_id'
     comissao.pedido_id = item.pedido_id
 logger.debug 'item.produto_id'
      comissao.produto_id = item.produto_id
 logger.debug 'item.id'
      comissao.item_pedido_id = item.id
 logger.debug 'item.quantidade'
      comissao.quantidade = item.quantidade
 logger.debug 'item.valor_unitario'
      comissao.valor_unitario = item.valor_unitario
 logger.debug 'item.produto.comissao'
      comissao.perc_comissao = item.produto.perc_comissao
 logger.debug 'valor_comissao'
 logger.debug item.valor_total * item.produto.perc_comissao
  logger.debug 'GRAVANDO -> valor_comissao'
     comissao.valor_comissao = (item.valor_total * item.produto.perc_comissao)
    end
 logger.debug 'comissao.valor_comissao'
 logger.debug comissao.valor_comissao
    comissao.save
  end
end
