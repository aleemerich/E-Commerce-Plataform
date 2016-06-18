# encoding: UTF-8
class ItemPedidosController < ApplicationController
  before_filter :permissao_publico
  before_filter :permissao_destroy_item_pedido, :only => [:destroy]
  before_filter :permissao_create_item_pedido, :only => [:create]
  layout "publico"
  
  def new
    @produto = Adm::Produto.find(params[:id_produto])
    @adm_item_pedido = Adm::ItemPedido.new
    @pedido = Adm::Pedido.where('cliente_id = ? AND (status_id = ? OR status_id = ?)', session[:cliente].id, Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id, Status.where(["codigo = '5' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id).first
    logCliente(request.remote_ip, session[:cliente].id, -1, "Acessando tela de DETALHE de um produto (ID produto = " + @produto.id.to_s + " )")
    
    # Essa funcao checa se o cliente já tem pedidos abertos (PRÉ-PEDIDOS),
    # caos não tenha, é criado um novo pedido. Se ja tiver, 
    # é exibido uma lista de pedidos para o cliente
    if !@pedido
      @pedido = Adm::Pedido.new
      @pedido.cliente_id = session[:cliente].id
      @pedido.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
      @pedido.total = 0.0 # TODO: Ajustar isso no banco como DEFAULT, quando der
      if @pedido.save
        logPedido(request.remote_ip, @pedido.id, -1, "Novo pedido criado")
      else
        logPedido(request.remote_ip, -1, -1, "[I] Problemas ao criar um novo pedido para uma compra")
        redirect_to(:back, :notice => 'Não foi possivel criar um novo pedido para sua compra. Tente novamente.')
      end
    else
      logPedido(request.remote_ip, @pedido.id, -1, "Pedido Encontrado")
    end

    # lancamentos
    if session[:cliente]
      @publico_produtos_recentes = Adm::Produto.limit(5).order('created_at DESC').where('status_id = ?', Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id).all
    else
      @publico_produtos_recentes = Adm::Produto.limit(2).order('created_at DESC').where('status_id = ?', Status.where(["codigo = '0'and area_id = ?", Area.select('id').where(["codigo = '3'"]).first]).first.id).all
    end
  end
  
  def create
    begin
      @adm_item_pedido = Adm::ItemPedido.new(params[:adm_item_pedido])
      if @adm_item_pedido.save
        if extracao_item_pedido_extra(params[:adm_item_pedido_extra],@adm_item_pedido.id)
          logPedido(request.remote_ip, @adm_item_pedido.pedido_id, -1, "Criando item de pedido (ID do Item de Pedido = " + @adm_item_pedido.id.to_s + ")")
          logCliente(request.remote_ip, session[:cliente].id, -1, "Novo produto adicionado (ID do Item de Pedido = " + @adm_item_pedido.id.to_s + ")")
          if calculoTotal(@adm_item_pedido.pedido)
            # Mudando STATUS de pedido para Análise
            # devido a solicitação do cliente
            if params[:fl_desconto]
              pedido = @adm_item_pedido.pedido
              pedido.status_id = Status.where(["codigo = '5' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
              pedido.save
            end
            redirect_to(pedido_path(@adm_item_pedido.pedido_id), :notice => 'Produto adicionado com sucesso')
          else
            logPedido(request.remote_ip, @adm_item_pedido.pedido_id, -1, "[I] Criando item de pedido, mas não recalculado (ID do Item de Pedido = " + @adm_item_pedido.id.to_s + ")")
            logCliente(request.remote_ip, session[:cliente].id, -1, "[I] Criando item de pedido, mas não recalculado (ID do Item de Pedido = " + @adm_item_pedido.id.to_s + ")")
            redirect_to(pedido_path(@adm_item_pedido.pedido_id), :notice => 'Produto adicionado, mas pedido não foi atualizado')
          end
        else
          @adm_item_pedido.destroy
          logPedido(request.remote_ip, @adm_item_pedido.pedido_id, -1, "[I] Problemas ao adicionar um novo item EXTRA de pedido (ID do Item de Pedido = " + @adm_item_pedido.id.to_s + ")")
          logCliente(request.remote_ip, session[:cliente].id, -1, "[I] Problemas ao adicionar um novo item EXTRA de pedido (ID do Item de Pedido = " + @adm_item_pedido.id.to_s + ")")
          redirect_to(:back, :notice => 'Houve problemas ao adicionar o produto. Por favor, confira os dados abaixo')
        end
      else
        logPedido(request.remote_ip, -1, -1, "Problemas ao adicionar um novo item de pedido")
        logCliente(request.remote_ip, session[:cliente].id, -1, "Problemas ao adicionar um novo item de pedido")
        redirect_to(:back, :notice => 'Houve problemas ao adicionar o produto. Por favor, confira os dados abaixo')
      end
    rescue
      logPedido(request.remote_ip, @adm_item_pedido.pedido_id, -1, "[I] Problemas ao cadastrar um item de pedido")
      logCliente(request.remote_ip, session[:cliente].id, -1, "[I] Problemas ao cadastrar um item de pedido")
      begin
        # Esse log envia e-mail, então foi colocado entre TRY - CATCH para
        # não atrapalhar o fluxo do sistem em eventual problema de envio de e-mail
        logCritico("item_pedido_controller => create = ERRO: " + $!.to_s)
        logger.fatal "item_pedido_controller => create = ERRO: #{$!}"
      rescue
        logger.fatal "item_pedido_controller => create = ERRO: #{$!}"
      end
      redirect_to(:back, :notice => 'Houve problemas ao adicionar o produto')
    end
  end

  def destroy
     @item_pedido = Adm::ItemPedido.find(params[:id])
     if @item_pedido.pedido.valor_desconto > 0.00
       @item_pedido.status_id = Status.where(["codigo = 'IP-1' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
       # Volta pedido para ANALISE DE DESCONTO(5)
       @item_pedido.pedido.status_id = Status.where(["codigo = '5' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
       @item_pedido.pedido.save
       msg = 'Produto excluido com sucesso, contudo o pedido voltou para analise de desconto'
     else
       @item_pedido.status_id = Status.where(["codigo = 'IP-1' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
       msg = 'Produto excluido com sucesso'
     end
     if @item_pedido.save
       if calculoTotal(@item_pedido.pedido)
        logPedido(request.remote_ip, @item_pedido.pedido_id, -1, msg + " (COD item_pedido = " + @item_pedido.id.to_s + ")")
        logCliente(request.remote_ip, session[:cliente].id, -1, msg + " (COD item_pedido = " + @item_pedido.id.to_s + ")")
        redirect_to(pedido_path(@item_pedido.pedido_id), :notice => msg)
       else
        logPedido(request.remote_ip, @item_pedido.pedido_id, -1, "[I] Item de pedido excluido, mas pedido não atualizado (COD item_pedido = " + @item_pedido.id.to_s + ")")
        logCliente(request.remote_ip, session[:cliente].id, -1, "[I] Item de pedido excluido, mas pedido não atualizado (COD item_pedido = " + @item_pedido.id.to_s + ")")
        redirect_to(pedido_path(@item_pedido.pedido_id), :notice => 'Produto excluido, mas custos do pedido não foi atualizado')
       end
     else
       logPedido(request.remote_ip, @item_pedido.pedido_id, -1, "[I] não foi possivel excluir o item do pedido (COD pedido = " + params[:id] + ")")
       logCliente(request.remote_ip, session[:cliente].id, -1, "[I] não foi possivel excluir o item do pedido (COD pedido = " + params[:id] + ")")
       redirect_to(:back, :notice => 'Não foi possivel excluir o item do pedido')
     end
  end


  # =================
  # FUNÇÕES DE APOIO
  # =================

=begin
 ===============
 NOTA IMPORTANTE
 ===============
 
 Uma explicação melhor sobre essa função pode ser vista no arquivo adm/pedido_itens_controller.rb pois essa função
 é exatamente uma cópia da função contida nesse arquivo.
 TODO: É preciso aproveitar a função já existente para não haver duplicidade.
=end
 def extracao_item_pedido_extra(arrayCompleto, adm_item_pedido_id)
    begin
      #Verifica se o array está preenchido
      if !arrayCompleto.nil?
        arrayCompleto.each do |adm_item_pedido_extra|
          # VERIRIFICAÇÃO do TIPO de cada PRODUTO_EXTRA a ser gravado
          #
          # LEMBRETE: Os indices "1" vistos aqui são devido ao fato de não se poder
          # trabalhar com array como se trabalha com o PARAMS (generics).
          # Como não sei trabalhar com isso no Rials ainda (e nem tive tempo),
          # usei assim mesmo. 
          # EX: {item6, #} no loop, acessa o array com VAR_DE_APOIO[1]
          # TODO: Isso está muito mal feito, é preciso melhorar!
      
          case Adm::ProdutoExtra.find(adm_item_pedido_extra[1][:produto_extra_id]).produto_extra_tipo.codigo
          # Esse é o tipo mais trabalhoso e precisa se trabalhar com vários arrays 
          # TODO: Isso está muito mal feito, é preciso melhorar!
          when 'arquivo'
            #apenas para apoio
            #TODO: Ficou ridiculo, mas "é o que tinha pra agora" e tem que ser melhorado
            arquivos = Array.new
            descricoes = Array.new

            # analizando se há arquivos a inserir
            if adm_item_pedido_extra[1][:dado_fornecido][:arquivo]
              # extraindo informações dos arquivos
              adm_item_pedido_extra[1][:dado_fornecido][:arquivo].each do |info|
                arquivos << info[1]
              end
              adm_item_pedido_extra[1][:dado_fornecido][:descricao].each do |info|
                descricoes << info[1]
              end
            end

            #fazendo os carregamentos
            i = 0
            while i < arquivos.length
              # Verifique se o campo não esta vazio
              if !arquivos[i].original_filename.nil?
                # carregando os dados para a criação de 
                # um novo arquivo
                arquivoNovo = Arquivo.new
                arquivoNovo.produto_id = Adm::ItemPedido.find(adm_item_pedido_id).produto_id
                arquivoNovo.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 3"]).first]).first.id
                arquivoNovo.caminho = File.join(Rails.root, "public/temp/", SecureRandom.hex(14) + File.extname(arquivos[i].original_filename))
                arquivoNovo.nome = arquivos[i].original_filename
                arquivoNovo.descricao = descricoes[i]
                
                # fazendo o upload
                arquivo_up = File.open(arquivoNovo.caminho, "wb")
                arquivo_up.write(arquivos[i].read)
                arquivo_up.close
                
                # salvando o novo arquivo
                arquivoNovo.save
                
                # adicionando referencia ao item extra do pedido
                # 
                # Lembrete: Serão gravados os "IDs;Nome" dos arquivos gerados,
                # para que se possa recuperá-los posteriormente para exibição e download
                gravacao_item_pedido_extra(adm_item_pedido_id, adm_item_pedido_extra[1][:produto_extra_id], arquivoNovo.id.to_s + ";" + arquivoNovo.nome, Adm::ProdutoExtra.find(adm_item_pedido_extra[1][:produto_extra_id]).valor_cobrado)
               end
               i += 1
            end
          when 'combo'
            # extraindo informações dos arquivos
            apoio = adm_item_pedido_extra[1][:dado_fornecido].split(";")
            gravacao_item_pedido_extra(adm_item_pedido_id, adm_item_pedido_extra[1][:produto_extra_id], apoio[0], apoio[1])
          when 'check'
            adm_item_pedido_extra[1][:dado_fornecido].each do |info|
              # extraindo informações dos arquivos
              apoio = info[1].split(";")
              gravacao_item_pedido_extra(adm_item_pedido_id, adm_item_pedido_extra[1][:produto_extra_id], apoio[0], apoio[1])
            end
          else
            gravacao_item_pedido_extra(adm_item_pedido_id, adm_item_pedido_extra[1][:produto_extra_id], adm_item_pedido_extra[1][:dado_fornecido], Adm::ProdutoExtra.find(adm_item_pedido_extra[1][:produto_extra_id]).valor_cobrado)
          end
        end
      end
      return true
    rescue
      logger.fatal "item_pedido_controller => extracao_item_pedido_extra = ERRO: #{$!}"
      return false
    end
  end
  
  # faz a gravação dos item_pedido_extra propriamente dito
  def gravacao_item_pedido_extra(item_pedido_id, produto_extra_id, dado_fornecido, valor)
    begin
      item_pedido_extra = Adm::ItemPedidoExtra.new
      item_pedido_extra.item_pedido_id = item_pedido_id
      item_pedido_extra.produto_extra_id = produto_extra_id
      item_pedido_extra.status_id = Status.where(["codigo = 'PE-0' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
      item_pedido_extra.dado_fornecido = dado_fornecido
      item_pedido_extra.valor = ((valor.nil? || valor.blank?) ? 0.0 : valor)
      item_pedido_extra.codigo_fator_calculo = Adm::ProdutoExtra.find(produto_extra_id).produto_extra_fator_calculo.codigo
      item_pedido_extra.save
    rescue
      logger.fatal "item_pedido_controller => gravacao_item_pedido_extra = ERRO:  #{$!}"
      return false
    end
  end

  # ====================
  # FUNÇÕES DE VALIDAÇÃO
  # ====================

  protected

  # Como cada ação tem um determinado tipo de dado sendo recebido
  # resolvi separar em ações unicas. Mas com certeza deve ter outro jeito
  # mais elegante de resolver isso.
  # TODO: Achar jeito mais elegante de resolver isso
  
  # Não permitir que seja apagado item de pedido 
  # de pedidos que não seja PRÉ-PEDIDO através de acesso indireto
  def permissao_destroy_item_pedido
    item = Adm::ItemPedido.find(params[:id])
    if item.pedido.status.codigo == '0'
      true
    else
      logPedido(request.remote_ip, item.pedido.id, -1, "[I] Acao suspeita. Tentativa de excluir item de pedido de pedido ja encerrado. Acesso bloqueado. (COD pedido = " + item.id.to_s + ")")
      logCliente(request.remote_ip, session[:cliente].id, -1, "[I] Acao suspeita. Tentativa de excluir item de pedido de pedido ja encerrado. Acesso bloqueado. (COD pedido = " + item.id.to_s + ")")
      redirect_to(pedido_path(item.pedido.id), :notice => 'Acao suspeita. Pedido ja encerrado e acesso bloqueado. Um aviso foi enviado ao ADM do sistema')
    end
  end
  
  # Não permitir que seja inseridos novos itens de pedido
  # de pedido que não seja PRÉ-PEDIDO através de acesso indireto
  def permissao_create_item_pedido
    if Adm::Pedido.find(params[:adm_item_pedido][:pedido_id]).status.codigo == '0'
      true
    else
      logPedido(request.remote_ip, params[:adm_item_pedido][:pedido_id], -1, "[I] Acao suspeita. Tentativa de incluir item de pedido em pedido ja encerrado. Acesso bloqueado.")
      logCliente(request.remote_ip, session[:cliente].id, -1, "[I] Acao suspeita. Tentativa de incluir item de pedido em pedido ja encerrado. Acesso bloqueado.")
      redirect_to(pedido_path(params[:adm_item_pedido][:pedido_id]), :notice => 'Acao suspeita. Pedido ja encerrado e acesso bloqueado. Um aviso foi enviado ao ADM do sistema')
    end
  end
end
