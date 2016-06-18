# encoding: UTF-8
class Adm::PedidoItensController < ApplicationController
  before_filter :permissao
  before_filter :pedido_aberto

  layout "adm"
  
  def index
    # config de layout     
    @layout = Array.new()
    @layout[0] = "pedido" # menu     
    @layout[1] = "Item de Pedidos" # titulos     
    @layout[2] = "slogan" # subtitulo_css     
    @layout[3] = "Escolha um item para adicionar ao pedido" # subtitulo_css     
    @layout[4] = "" #subtitulo_url
    @layout[5] = "pedidos/search" #busca_url
    
    # paginacao
    if params[:pag]
      @offset = params[:pag].to_i
    else
      @offset = 0
    end
    
    @adm_produtos_full = Adm::Produto.limit(20).offset(@offset).all

    # filtrando pela permissao do usuário os registros que ele pode ver
    if session[:usuario].status.area.codigo != '0'
      @adm_produtos = @adm_produtos_full.find_all {|p|  p.status.codigo == '0'}
    else
      @adm_produtos = @adm_produtos_full
    end
    
    if @adm_produtos.length == 0 and params[:pag]
        redirect_to(adm_pedido_itens_path, :notice => 'Não ha mais itens disponiveis')
    end
  end
  
  def new
    @adm_produto = Adm::Produto.find(params[:id_produto])

    # config de layout     
    @layout = Array.new()
    @layout[0] = "pedido" # menu     
    @layout[1] = @adm_produto.nome # titulos     
    @layout[2] = "slogan" # subtitulo_css     
    @layout[3] = "" # subtitulo_css     
    @layout[4] = "" #subtitulo_url
    @layout[5] = "pedidos/search" #busca_url

    @adm_item_pedido = Adm::ItemPedido.new
    @adm_item_pedido_extra = Adm::ItemPedidoExtra.new 
  end
  
  def create
    #TODO: Precisa fazer o TRY CATH
    @adm_item_pedido = Adm::ItemPedido.new(params[:adm_item_pedido])
    if @adm_item_pedido.save
      if extracao_item_pedido_extra(params[:adm_item_pedido_extra],@adm_item_pedido.id)
        if calculoTotal(@adm_item_pedido.pedido)
          # Mudando STATUS de pedido para Análise
          # devido a solicitação do cliente
          if params[:fl_desconto]
            pedido = @adm_item_pedido.pedido
            pedido.status_id = Status.where(["codigo = '5' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
            pedido.save
          end
          redirect_to(adm_pedido_path(@adm_item_pedido.pedido_id), :notice => 'Produto adicionado com sucesso')
        else
          redirect_to(adm_pedido_path(@adm_item_pedido.pedido_id), :notice => 'Produto adicionado, mas pedido não foi atualizado')
        end
      else
        redirect_to(adm_pedido_path(@adm_item_pedido.pedido_id), :notice => 'Produto adicionado, mas os intens extras não foram salvos')
      end
    else
      redirect_to(adm_pedido_path(params[:id_pedido]), :notice => 'Houve problemas ao adicionar o produto', :id => params[:id_pedido])
    end
  end
  
  # NÃO USADO!
  #def edit
  #  @adm_item_pedido = Adm::ItemPedido.find(params[:id])
  #  @adm_produto = @adm_item_pedido.produto
  #
  #  # config de layout     
  #  @layout = Array.new()
  #  @layout[0] = "pedido" # menu     
  #  @layout[1] = @adm_produto.nome # titulos     
  #  @layout[2] = "slogan" # subtitulo_css     
  #  @layout[3] = "" # subtitulo_css     
  #  @layout[4] = "" #subtitulo_url
  #  @layout[5] = "pedidos/search" #busca_url
  #  
  #  respond_to do |format|
  #    format.html # index.html.erb
  #    format.xml  { render :xml => @adm_item_pedido }
  #  end  
  #end

  # NÃO USADO!
  #def update
  #  @adm_item_pedido = Adm::ItemPedido.find(params[:id])
  #  if @adm_item_pedido.update_attributes(params[:adm_item_pedido])
  #    if calculoTotal(@adm_item_pedido.pedido)
  #      redirect_to(adm_pedido_path(@adm_item_pedido.pedido_id), :notice => 'Produto atualizado com sucesso')
  #    else
  #      redirect_to(adm_pedido_path(@adm_item_pedido.pedido_id), :notice => 'Produto atualizado, mas pedido não foi atualizado')
  #    end
  #  else
  #    redirect_to(adm_pedido_path(params[:idPedido]), :notice => 'Houve problemas ao atualizar o produto')
  #  end
  #end
  
  def destroy
     @adm_item_pedido = Adm::ItemPedido.find(params[:id])
     if @adm_item_pedido.pedido.valor_desconto > 0.00
       # Volta pedido para ANALISE DE DESCONTO(5)
       @adm_item_pedido.pedido.status_id = Status.where(["codigo = '5' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
       @adm_item_pedido.pedido.save
       msg = 'Produto excluido com sucesso, contudo o pedido voltou para analise de desconto'
     else
       msg = 'Produto excluido com sucesso'
     end
     @adm_item_pedido.status_id = Status.where(["codigo = 'IP-1' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
     if @adm_item_pedido.save
       if calculoTotal(@adm_item_pedido.pedido)
         logPedido(request.remote_ip, @adm_item_pedido.pedido_id, session[:usuario].id,  msg + " (COD item_pedido = " + @adm_item_pedido.id.to_s + ")")
         redirect_to(adm_pedido_path(@adm_item_pedido.pedido_id), :notice => msg)
       else
         logPedido(request.remote_ip, @adm_item_pedido.pedido_id, session[:usuario].id, "Item de pedido excluido (COD item_pedido = " + @adm_item_pedido.id.to_s + ")")
         redirect_to(adm_pedido_path(@adm_item_pedido.pedido_id), :notice => 'Produto excluido, mas valor pedido não foi atualizado')
       end
     else
       logPedido(request.remote_ip, @adm_item_pedido.pedido_id, session[:usuario].id, "Item de pedido excluido (COD item_pedido = " + @adm_item_pedido.id.to_s + ")")
       redirect_to(session[:ultima_url], :notice => 'Houve problemas ao excluir o produto')
     end
  end

=begin
 ===============
 NOTA IMPORTANTE
 ===============
 
 Os ITEM_PEDIDO_EXTRA(s) são enviados obedecendo a estrutura de BD ADM_ITEM_PRODUTO_EXTRA.
 Contudo, as propriedades DADO_FORNECIDO e VALOR sem "ALTERAM" conforme o TIPO (arquivo, checkbox e etc) do 
 PRODUTO_EXTRA cadastrado.
 
 Para TIPO = ARQUIVO
 -------------------
 Manda, pelo campo DADO_FORNECIDO, dois arrays de chamado ARQUIVO e um array chamado DESCRICAO, ambos contendo esses dados.
 Manda, pelo campo VALOR, o valor cobrado quando houver
 
 Para TIPO = COMBO
 -----------------
 Manda, pelo campo DADO_FORNECIDO, uma string contendo o item e o preço referente ao item
 selecionado pelo usuário. Basta então quebrar essa string (split com ";") e obter os dados
 para DADO_FORNECIDO e VALOR
 
 Para TIPO = CHECK
 -----------------
 Manda, pelo campo DADO_FORNECIDO, um arry contendo os itens e os preços referentes a cada
 item selecionado (lembrando que podem haver vários itens). Basta então quebrar cada um desses
 itens (similar a strings) usando split com ";" então obte-se os dados para DADO_FORNECIDO e VALOR
 OBS: Essa opção gera vários ITEM_PEDIDO_EXTRA
 
 Para os outros tipos
 --------------------
 
 Manda, pelo campo DADO_FORNECIDO a informação que o usuário digitou no campo TEXT e,
 havendo, mandará o valor a ser cobrado pelo campo VALOR.
 

 EXEMPLO "APENAS" DOS DADOS EXTRAS ENVIADOS
 ==========================================
 
 {"item2"=>
   {"item_pedido_id"=>"", "produto_extra_id"=>"2", "valor"=>"", "dado_fornecido"=>
     {"arquivo"=>{"0"=>#>, "1"=>#>, "2"=>#>, "3"=>#>, "4"=>#>}, 
     "descricao"=>{"0"=>"www", "1"=>"www", "2"=>"www", "3"=>"www", "4"=>"www"}}}, 
 "item7"=>
   {"item_pedido_id"=>"", "produto_extra_id"=>"7", "valor"=>"", "dado_fornecido"=>"Clip;4.5"}, 
 "item8"=>{"item_pedido_id"=>"", "produto_extra_id"=>"8", "valor"=>"", "dado_fornecido"=>"1"}, 
 "item9"=>{"item_pedido_id"=>"", "produto_extra_id"=>"9", "valor"=>"", "dado_fornecido"=>
   {"0"=>"Desejo que seja impresso em papel fotográfico;0.9", 
     "1"=>"Adicionar prioridade URGÊNCIA;0.5"}}}  
 
 OBS: Cada item tem um número associado. Esse nro é referente ao do ID de PRODUTO_EXTRA. 
 Nesse exemplo:
   - Item 2 é do tipo "arquivo"
   - Item 7 é do tipo "combo"
   - Item 8 e do tipo "outros"
   - Item 9 é do tipo "check"
   
 LEMBRETE
 ========
 Ha uma varredura "chata" nessa ação sem uar os principios do RAILS porque 
 se faz necessário detectar tipo de dados que necessitam de comportamentos
 específicos como os dados ARQUIVO quee, quando se detectado, exige que
 um download deva ser requerido.
 TODO: É preciso melhorar essa ação assim que possível.
=end

 def extracao_item_pedido_extra(arrayCompleto, adm_item_pedido_id)
    #Verifica se o array está preenchido
    if arrayCompleto
      # Recebe array de itens de pedidos extras e varre array recebido
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
          #TODO:Ridiculo, mas "é o que tinha pra agora" e tem que ser melhorado
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
              gravacao_item_pedido_extra(adm_item_pedido_id, adm_item_pedido_extra[1][:produto_extra_id], arquivoNovo.id.to_s + ";" + arquivoNovo.nome, Adm::ProdutoExtra.find(adm_item_pedido_extra[1][:produto_extra_id]).valor_cobrado.sub('%',''))
            end
            i += 1
          end
        when 'combo'
          # extraindo informações dos arquivos
          apoio = adm_item_pedido_extra[1][:dado_fornecido].split(";")
          gravacao_item_pedido_extra(adm_item_pedido_id, adm_item_pedido_extra[1][:produto_extra_id], apoio[0], apoio[1].sub('%',''))
        when 'check'
          adm_item_pedido_extra[1][:dado_fornecido].each do |info|
            # extraindo informações dos arquivos
            apoio = info[1].split(";")
            gravacao_item_pedido_extra(adm_item_pedido_id, adm_item_pedido_extra[1][:produto_extra_id], apoio[0], apoio[1].sub('%',''))
          end
        else
          gravacao_item_pedido_extra(adm_item_pedido_id, adm_item_pedido_extra[1][:produto_extra_id], adm_item_pedido_extra[1][:dado_fornecido], Adm::ProdutoExtra.find(adm_item_pedido_extra[1][:produto_extra_id]).valor_cobrado.sub('%',''))
        end
      end
    end
    return true
  end
  
  # faz a gravação dos item_pedido_extra propriamente dito
  def gravacao_item_pedido_extra(item_pedido_id, produto_extra_id, dado_fornecido, valor)
    item_pedido_extra = Adm::ItemPedidoExtra.new
    item_pedido_extra.item_pedido_id = item_pedido_id
    item_pedido_extra.produto_extra_id = produto_extra_id
    item_pedido_extra.status_id = Status.where(["codigo = 'PE-0' and area_id = ?", Area.select('id').where(["codigo = 5"]).first]).first.id
    item_pedido_extra.dado_fornecido = dado_fornecido
    item_pedido_extra.valor = ((valor.nil? || valor.blank?) ? 0.0 : valor)
    item_pedido_extra.codigo_fator_calculo = Adm::ProdutoExtra.find(produto_extra_id).produto_extra_fator_calculo.codigo
    item_pedido_extra.save
  end
  
  def pedido_aberto
    pedido = Adm::Pedido.find(params[:id_pedido])
    #antiga análise => if pedido.parcela_pedido.length > 0 
    if pedido.status.codigo != '0' and pedido.status.codigo != '5'
      redirect_to(show_adm_painel_path(pedido), :notice => 'Esse pedido não pode receber novos itens')
    end  
  end
end
