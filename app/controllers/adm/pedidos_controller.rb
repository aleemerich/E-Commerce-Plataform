# encoding: UTF-8
class Adm::PedidosController < ApplicationController
  before_filter :permissao
  before_filter :pedido_aberto, :only => [:show, :calc, :block]
  # Essa excessão trata apenas do web service dos correios
  skip_before_filter :permissao, :only => [:services]
  
  layout "adm"
  
  def index
    # config de layout     
    @layout = Array.new()
    @layout[0] = "pedido" # menu     
    @layout[1] = "Pedidos" # titulos     
    @layout[2] = "sloganD2" # subtitulo_css     
    @layout[3] = "Adicionar um pedido" # subtitulo_css     
    @layout[4] = "/adm/pedidos/new" #subtitulo_url
    @layout[5] = "/adm/painel/search" #busca_url

    # paginacao
    if params[:pag]
      @offset = params[:pag].to_i
    else
      @offset = 0
    end
    
    # criando a lista
    @adm_pedidos_full = Adm::Pedido.limit(20).order('id DESC').offset(@offset).all

    # TODO: Verificar se haverá status que só a Arich poderá ver
    # filtrando pela permissao do usuário os registros que ele pode ver
    
    #if session[:usuario].status.area.codigo != '0'
      #@adm_pedidos = @adm_pedidos_full.find_all {|p|  p.status.codigo == '0' or p.status.codigo == '1' }
    #else
    @adm_pedidos = @adm_pedidos_full
    #end

    if @adm_pedidos.length == 0 and params[:pag]
        redirect_to(adm_pedidos_path, :notice => 'Não ha mais pedidos')
    else
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @adm_pedidos }
      end    
    end
  end
  
  def new
    # config de layout     
    @layout = Array.new     
    @layout[0] = "pedido" # menu     
    @layout[1] = "Novo Pedido" # titulos     
    @layout[2] = "slogan"     
    @layout[3] = "Cadastro de novo pedido"
    @layout[4] = ""
    @layout[5] = "/adm/painel/search"
    
    @adm_pedido = Adm::Pedido.new
      #@layout[3] = "COD: " + "%07d" % session[:pedido_id] 

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @adm_pedido }
    end
  end
  
  def create
    @adm_pedido = Adm::Pedido.new(params[:adm_pedido])
    @adm_pedido.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
    @adm_pedido.total = 0.0
    if @adm_pedido.save
      redirect_to(adm_pedido_path(@adm_pedido))
    else
      redirect_to(adm_pedidos_path, :notice => 'Problemas ao criar o pedido')
    end
  end
  
  def show
    @adm_pedido = Adm::Pedido.find(params[:id])
    
    # config de layout     
    @layout = Array.new     
    @layout[0] = "pedido" # menu     
    @layout[1] = "Pedido de Compra " + "%05d" % params[:id]   
    @layout[2] = "slogan"     
    @layout[3] = "STATUS = " + @adm_pedido.status.descricao
    @layout[4] = ""
    @layout[5] = "/adm/painel/search"
  end
  
  def block
    @adm_pedido = Adm::Pedido.find(params[:id])

    # verifica se o pedido já tem parcelas geradas
    #pedidoProcessado(@adm_pedido)

    if @adm_pedido.status.codigo == '0'
      @adm_pedido.status_id = Status.where(["codigo = '1' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
      msg = "Pedido cancelado"
    else
      @adm_pedido.status_id = Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
      msg = "Esse pedido volto para o STATUS de PRE-PREDIDO, é necessário revisa-lo"
    end
    
    if @adm_pedido.save
      redirect_to(adm_pedidos_path, :notice => msg)
    else
      redirect_to(adm_pedidos_path, :notice => 'Problemas na função de cancelamento')
    end
  end
  
  # Realiza o calculo no pedido novamente 
  def calc
    @adm_pedido = Adm::Pedido.find(params[:id])

    # verifica se o pedido já tem parcelas geradas
    #pedidoProcessado(@adm_pedido)

    if calculoTotal(@adm_pedido)
      redirect_to(show_adm_painel_path(@adm_pedido), :notice => 'Pedido recalculado')
    else
      redirect_to(show_adm_painel_path(@adm_pedido), :notice => 'Erro no recalculo')
    end
  end

=begin  
  ##################################################################################################  
  ==> Essas ações foram criadas no incio do projeto visando simular e testar ações de clientes, 
  ==>  contudo não foi visto sentido em deixá-las aqui para serem usadas pelos pelo ADM do sistema
  ##################################################################################################  
  
  def envio
    @adm_pedido = Adm::Pedido.find(params[:id])

    # config de layout     
    @layout = Array.new     
    @layout[0] = "pedido" # menu     
    @layout[1] = "Pedido de Compra " + "%05d" % params[:id]   
    @layout[2] = "slogan"     
    @layout[3] = "Forma de envio"
    @layout[4] = ""
    @layout[5] = "/adm/pedidos/search"

    @adm_enderecos = Adm::Endereco.all(:conditions => ['cliente_id = ? AND status_id = ?', @adm_pedido.cliente.id, Status.where(["codigo = '0' and area_id = ?", Area.select('id').where(["codigo = 2"]).first]).first.id])
    @adm_forma_envios = Adm::FormaEnvio.all
  end
  
  def update
    @adm_pedido = Adm::Pedido.find(params[:id])
 
    if @adm_pedido.update_attributes(params[:adm_pedido])
      calculoTotal(@adm_pedido)
      redirect_to(new_adm_parcela_pedido_path(@adm_pedido))
    else
      redirect_to(adm_pedido_path(@adm_pedido), :notice => 'Problemas ao atribuir um endereço a esse pedido')
    end
  end
  
  def finally
    @adm_pedido = Adm::Pedido.find(params[:id])
    # config de layout     
    @layout = Array.new     
    @layout[0] = "pedido" # menu     
    @layout[1] = "Pedido de Compra " + "%05d" % params[:id]   
    @layout[2] = "slogan"     
    @layout[3] = "STATUS = " + @adm_pedido.status.descricao
    @layout[4] = ""
    @layout[5] = "/adm/pedidos/search"

    if params[:pagamento_pedido_id]
      @adm_pagamento_pedido = Adm::PagamentoPedido.find(params[:pagamento_pedido_id])
    end
  end
=end  

  def services
    begin
      envio = 'erro'
      @adm_pedido = Adm::Pedido.find(params[:id])
      @medidasTotais = calculo_medidas(@adm_pedido)
  
      # Não foi implementado outras funções além da do Correio, contudo
      # é possível fazê-lo só mexendo nessa função e nas funções 
      # JS chamada frete e retornoAjax
      case params[:funcao]
      when 'correios'
        # Conferindo as limitações dos Correios
        # --> altura
        rejeite = false
        dimensao = 'largura ' + @medidasTotais[0].to_s + 'cm, altura ' + @medidasTotais[1].to_s + 'cm, comprimento ' + @medidasTotais[2].to_s + 'cm' + ', peso ' + @medidasTotais[3].to_s + ' g'
        logger.debug '====================> DIMENSAO INICIAL'
        logger.debug dimensao
        
        # LEMBRETE: Os locais que se modificam as dimensões são apenas para ajustar 
        # para a dimensão mínima. Nos locais que o máximo é atingido, o sistema
        # acusa que o Correio não atende
        
        # ANALISE DE ALTURA
        if @medidasTotais[1] < 2.0 # altura não pode ser menor que 2cm
          @medidasTotais[1] = 3.0
        elsif @medidasTotais[1] > 90.0 # altura não pode ser maior que 90cm
          rejeite = true
        end
        if !rejeite and (@medidasTotais[1] > @medidasTotais[2]) # altura não pode ser que o comprimento
          aux = @medidasTotais[2]
          @medidasTotais[2] = @medidasTotais[1]
          @medidasTotais[1] = aux
          # as medidas são trocadas pois isso equivale
          # a deitar uma caixa muito alta e estreita
        end

        # ANALISE DE LARGURA
        if @medidasTotais[0] < 11.0 # largura não pode ser menor que 5cm
          @medidasTotais[0] = 12.0
        elsif @medidasTotais[0] > 90.0 # largura não pode ser maior que 90cm
          rejeite = true
        end
        
         # ANALISE DE COMPRIMENTO
        if @medidasTotais[2] < 16.0 # comprimento não pode ser menor que 16cm
          @medidasTotais[2] = 17.0
        elsif @medidasTotais[2] > 90.0 # comprimento não pode ser maior que 90cm
          rejeite = true
        end
        
        # ANALISE GERAL        
        if (@medidasTotais[0] + @medidasTotais[1] + @medidasTotais[2]) > 160.00 # a soma altura + largura + comprimento
          rejeite = true
        end

        if @medidasTotais[2] < 25.00 and @medidasTotais[0] < 11.00 # largunra não pode ser menor que 11cm
          @medidasTotais[0] = 12.00                                # quando o comprimento for menor que 25cm
        end

        
        # ANALISE DE PESO
        if @medidasTotais[3] > 30000 # peso não pode ser superior a 30 kg (ou 30.000 g)
          rejeite = true
        end

       logger.debug '====================> DIMENSAO final'
       logger.debug 'largura ' + @medidasTotais[0].to_s + 'cm, altura ' + @medidasTotais[1].to_s + 'cm, comprimento ' + @medidasTotais[2].to_s + 'cm' + ', peso ' + @medidasTotais[3].to_s + ' g'
        
        # Analisando se haverá ou não consulta aos correios
        if rejeite
          logger.debug '====================> HOUVE REJEITE'
          # Envia array de informações para o JAVASCRIPT
          envio = ';;' + 'ajuste' + ';' + dimensao
        else
          frete = Correios::Frete::Calculador.new :cep_origem => "04052000", 
                                                  :cep_destino => params[:cepDestino],
                                                  :peso => (@medidasTotais[3] / 1000).to_s,
                                                  :comprimento => @medidasTotais[2].to_s.sub(/[.]/,','),
                                                  :largura => @medidasTotais[0].to_s.sub(/[.]/,','),
                                                  :altura => @medidasTotais[1].to_s.sub(/[.]/,',')
      
          case params[:codigo]
          when '41106'
            servico = frete.calcular :pac                                            
          when '40010'
            servico = frete.calcular :sedex
          when '40215'
            servico = frete.calcular :sedex_10                                            
          when '40298'
            servico = frete.calcular :sedex_hoje                                            
          else
            servico = nil                                            
          end
        end 
        
        if !servico.nil?
          if servico.sucesso?
            # Envia array de informações para o JAVASCRIPT
            envio =  servico.valor.to_s + ';' + servico.prazo_entrega.to_s + ';' + 'n_ajuste' + ';' + dimensao
          else
            logger.fatal '====================> ERRO NO WEB SERVICE CORREIOS'
            logger.fatal 'Dimensao' 
            logger.fatal 'largura = ' + frete.largura + ' altura = ' + frete.altura + ' comprimento = ' + frete.comprimento + ' peso = ' + frete.peso
            logger.fatal 'ERRO ' 
            logger.fatal servico.erro
          end
        else
          logger.fatal '====================> NENHUM SERVICO DOS CORREIOS FOI ESCOLHIDO'
          logger.fatal 'params[:codigo]' 
          logger.fatal params[:codigo]
         end
      else
        logger.fatal '====================> PARAMETRO DE SERVICO INEXISTENTE' 
        logger.fatal params[:funcao]
      end
      # Finalização da função caso aconteça algo não prevenido
      render :text => envio
    rescue
      logger.fatal '====================> ERRO NO SISTEMA (WEB SERVICE ENVIO)'
      logger.fatal "Erro #{$!}"
      render :text => 'erro'
    end
  end
  
  def calculo_medidas(pedido)
    medidas = [0.0, 0.0, 0.0, 0.0]
    #posicao 0 = largura
    #posicao 1 = altura
    #posicao 2 = comprimento
    #posicao 3 = peso
    
    #medidas
    larguraMax = 0.0
    comprimentoMax = 0.0
    alturaMax = 0.0
    
    #varredura
    pedido.item_pedido.select{|i| i if i.status.codigo != 'IP-1'}.each do |item|
      if item.produto.largura > medidas[0]
        medidas[0] = item.produto.largura # maior largura
      end
      medidas[1] += (item.produto.altura * item.quantidade) #soma das alturas
      if item.produto.comprimento > medidas[2]
       medidas[2] = item.produto.comprimento # maior comprimento
      end
      medidas[3] += (item.produto.peso * item.quantidade) #soma das alturas
    end
    return medidas
  end


  # verifica se o pedido já tem parcelas geradas
  # ou sejam, se ele ja foi processado
  def pedido_aberto
    pedido = Adm::Pedido.find(params[:id])
    #antiga análise => if pedido.parcela_pedido.length > 0 
    if pedido.status.codigo != '0' and pedido.status.codigo != '5'
      redirect_to(show_adm_painel_path(pedido))
    end  
  end
   
end
