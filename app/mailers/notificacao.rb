# encoding: UTF-8
class Notificacao < ActionMailer::Base
  # Recurso para usar HELPER dentro do MAILER
  add_template_helper(PedidosHelper)
  default :from => "no-replay@rmgraficarapida.com.br"    
      
  def cliente_validacao(xcliente)
    @cliente = xcliente
    mail(:to => @cliente.email, 
      :subject => "[RM Gráfica Rápida] Confirmação de Cadastro") do |format|
      format.html { 
        render 'cliente_validacao'
        }
      end
  end

  def adm_cliente_novo(xcliente)
    @cliente = xcliente
    mail(:to => @cliente.email, 
      :subject => "[RM Gráfica Rápida] Você está cadastrado em nosso site") do |format|
      format.html { 
        render 'adm_cliente_novo'
        }
      end
  end

  def cliente_pedido_final(xpedido)
    @pedido = xpedido
    mail(:to => @pedido.cliente.email, 
      :subject => "[RM Gráfica Rápida] Confirmação de Pedido") do |format|
      format.html { 
        render 'cliente_pedido_final'
        }
      end
  end

  def cliente_pagamento_concluido(xpagamento)
    @pagamento = xpagamento
    mail(:to => @pagamento.parcela_pedido.pedido.cliente.email, 
      :subject => "[RM Gráfica Rápida] Confirmação de Pagamento") do |format|
      format.html { 
        render 'cliente_pagamento_concluido'
        }
      end
  end

  def cliente_pagamento_cancelado(xpagamento)
    @pagamento = xpagamento
    mail(:to => @pagamento.parcela_pedido.pedido.cliente.email, 
      :subject => "[RM Gráfica Rápida] Problemas no pagamento") do |format|
      format.html { 
        render 'cliente_pagamento_cancelado'
        }
      end
  end
  
  def cliente_duvida(xpedido, xduvida)
    @pedido = xpedido
    @duvida = xduvida
    mail(:to => @pedido.cliente.email, :from => 'duvida@rmgraficarapida.com.br',
      :subject => "[RM Gráfica Rápida] Dúvidas no pedido " + "%05d" % @pedido.id) do |format|
      format.html { 
        render 'cliente_duvida'
        }
      end
  end

  def cliente_desconto(xpedido)
    @pedido = xpedido
    mail(:to => @pedido.cliente.email,
      :subject => "[RM Gráfica Rápida] Análise de desconto realiazada - pedido " + "%05d" % @pedido.id) do |format|
      format.html { 
        render 'cliente_desconto'
        }
      end
  end

  def cliente_despachado(xpedido)
    @pedido = xpedido
    mail(:to => @pedido.cliente.email,
      :subject => "[RM Gráfica Rápida] Pedido " + "%05d" % @pedido.id + " foi despachado") do |format|
      format.html { 
        render 'cliente_despachado'
        }
      end
  end

  def cliente_status(xpedido, xstatusid)
    @pedido = xpedido
    @status = Status.find(xstatusid).descricao
    mail(:to => @pedido.cliente.email,
      :subject => "[RM Gráfica Rápida] Pedido " + "%05d" % @pedido.id + " teve alterações") do |format|
      format.html { 
        render 'cliente_status'
        }
      end
  end
    
  def sistema_erro(msg)
    @msg = msg
    mail(:to => 'suporte@arich.com.br', # TODO: Esta HARD CODE, precisa mudar 
      :subject => "[RM Gráfica Rápida] Erro no sistema") do |format|
      format.html { 
        render 'sistema_erro'
        }
      end
  end

  def sistema_parcelas_vencidas(xparcelas)
    @parcelas = xparcelas
    mail(:to => 'contato@rmgraficarapida.com.br', :bcc => 'suporte@arich.com.br',# TODO: Esta HARD CODE, precisa mudar 
      :subject => "[RM Gráfica Rápida] Checagem de parcelas vencidas") do |format|
      format.html { 
        render 'sistema_parcelas_vencidas'
        }
      end
  end

end
