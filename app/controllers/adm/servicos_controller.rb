# encoding: UTF-8
class Adm::ServicosController < ApplicationController
  def check_parcelas_vencidas
    begin
      @adm_parcela_pedidos = Adm::ParcelaPedido.where('dt_vencimento < ? and status_id = ?', DateTime.now, Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 8"]).first]).first.id).all
      if @adm_parcela_pedidos
        @adm_parcela_pedidos.each do |p|
          p.status_id = Status.where(["codigo = '2' and area_id = ?", Area.select('id').where(["codigo = 8"]).first]).first.id
          p.save
        end
        Notificacao.sistema_parcelas_vencidas(@adm_parcela_pedidos).deliver
      end
    rescue
      # Esse log envia e-mail, então foi colocado entre TRY - CATCH para
      # não atrapalhar o fluxo do sistem em eventual problema de envio de e-mail
      logCritico("servicos_controller => check_parcelas_vencidas = ERRO: " + $!.to_s)
    end
    render :nothing => true
  end
  
  def envio_demonstrativo_pedido
    @adm_pedido = Adm::Pedido.find(params[:id])
    # Esse tratamento evita que um simples erro de envio de 
    # e-mail pare o processo como um todo
    begin
      # Envio de e-mail para cliente
      Notificacao.cliente_pedido_final(@adm_pedido).deliver
    rescue
      logCritico("pedidos_controller => parcela_rec -> Notificacao.cliente_pedido_final = ERRO: " + $!.to_s)
    end    
    render :nothing => true
  end
  
  def reenvio_autenticacao_cliente
    @cliente = Adm::Cliente.where('email = ?', params[:email]).first
    # Esse tratamento evita que um simples erro de envio de 
    # e-mail pare o processo como um todo
    if @cliente
      begin
        # Se cliente é status 3, precisa do reenvio da chave
        if @cliente.status.codigo == '3'
          # Envio de e-mail para cliente
          Notificacao.cliente_validacao(@cliente).deliver
          logCliente(request.remote_ip, @cliente.id, -1, "Reenvio de chave de autenticação solicitado")
         # Se cliente é status 0, precisa do reenvio da senha
        elsif @cliente.status.codigo == '0'
          # Envio de e-mail para cliente
          Notificacao.cliente_validacao(@cliente).deliver
          logCliente(request.remote_ip, @cliente.id, -1, "Reenvio de senha solicitado")
        # Se não for nenhum desses, não há ação
        end
      rescue 
        logCritico("adm/servicos_controller => envio_chave_autenticacao_cliente -> ERRO: " + $!.to_s)
      end  
    end  
    render :nothing => true
  end

end
