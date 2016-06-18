# encoding: UTF-8
class Adm::ComissoesController < ApplicationController
  before_filter :permissao
  layout "adm"
  
  def index
    if params[:id_mes] and params[:id_ano]
      mesReferencia = params[:id_mes].to_i
      anoReferencia = params[:id_ano].to_i
    else
      mesReferencia = Time.now.month
      anoReferencia = Time.now.year
    end

    # config de layout     
    @layout = Array.new()
    @layout[0] = "extrato" # menu     
    @layout[1] = "Extrato" # titulos     
    @layout[2] = "sloganD" # subtitulo_css     
    @layout[3] = "mes de referencia = " + "%02d" % mesReferencia.to_s # subtitulo_css     
    @layout[4] = "" #subtitulo_url
    @layout[5] = "/adm/painel/search" #busca_url
    
    bd = ActiveRecord::Base.connection
    
    @extrato_pagamentos = Adm::Comissao.where(["created_at >= ? and created_at < ? AND pedido_id = 0", 
      anoReferencia.to_s + '-' + mesReferencia.to_s + '-01', 
      mesSeguinte(anoReferencia, mesReferencia) + '-01']).order(:created_at) 

    @extrato_pedidos =  bd.select_all 'SELECT c.created_at, c.id, b.id as \'item_pedido_id\', b.valor_total, a.valor_comissao, a.perc_comissao 
    FROM adm_comissaos a
      INNER JOIN adm_item_pedidos b
        ON a.item_pedido_id = b.id
      INNER JOIN adm_pedidos c
        ON a.pedido_id = c.id
      INNER JOIN status d
        ON b.status_id = d.id
          AND d.codigo = \'IP-0\'
      INNER JOIN status e
        ON c.status_id = e.id
          AND e.codigo NOT IN (\'0\',\'1\',\'2\',\'3\',\'5\',\'12\',\'13\')
      WHERE c.created_at >= \'' + anoReferencia.to_s + '-' + mesReferencia.to_s + '-01\' and c.created_at < \'' + mesSeguinte(anoReferencia, mesReferencia) + '-01\'
      GROUP BY c.created_at, c.id, b.id, b.valor_total, a.valor_comissao, a.perc_comissao
      ORDER BY c.created_at ASC' 
          
    
    saldo_inical_comissao = bd.select_all 'SELECT SUM(a.valor_comissao) \'saldo\' 
      FROM adm_comissaos a
      INNER JOIN adm_item_pedidos b
        ON a.item_pedido_id = b.id
      INNER JOIN adm_pedidos c
        ON a.pedido_id = c.id
      INNER JOIN status d
        ON b.status_id = d.id
          AND d.codigo = \'IP-0\'
      INNER JOIN status e
        ON c.status_id = e.id
          AND e.codigo NOT IN (\'0\',\'1\',\'2\',\'3\',\'5\',\'12\',\'13\')
      WHERE c.created_at < \'' + anoReferencia.to_s + '-' + mesReferencia.to_s + '-01\''
    
    saldo_inical_pagamentos = bd.select_all 'SELECT SUM(a.valor_comissao) \'saldo\'  
      FROM adm_comissaos a
      WHERE a.created_at < \'' + anoReferencia.to_s + '-' + mesReferencia.to_s + '-01\' AND a.pedido_id = 0'

    saldo_final_comissao = bd.select_all 'SELECT SUM(a.valor_comissao) \'saldo\' 
      FROM adm_comissaos a
      INNER JOIN adm_item_pedidos b
        ON a.item_pedido_id = b.id
      INNER JOIN adm_pedidos c
        ON a.pedido_id = c.id
      INNER JOIN status d
        ON b.status_id = d.id
          AND d.codigo = \'IP-0\'
      INNER JOIN status e
        ON c.status_id = e.id
          AND e.codigo NOT IN (\'0\',\'1\',\'2\',\'3\',\'5\',\'12\',\'13\')
      WHERE c.created_at < \'' + mesSeguinte(anoReferencia, mesReferencia) + '-01\''
    
    saldo_final_pagamentos = bd.select_all 'SELECT SUM(a.valor_comissao) \'saldo\' 
      FROM adm_comissaos a
      WHERE a.created_at < \'' + mesSeguinte(anoReferencia, mesReferencia) + '-01\' AND a.pedido_id = 0'
      
    @select_anteriores = bd.select_all 'SELECT YEAR(`created_at`) \'ano\', MONTH(`created_at`) \'mes\' FROM adm_pedidos
      GROUP BY YEAR(`created_at`), MONTH(`created_at`)
      ORDER BY YEAR(`created_at`), MONTH(`created_at`) desc;'

    @extrato_saldo_inicial =  saldo_inical_comissao[0]['saldo'].nil? ? 0.00 : saldo_inical_comissao[0]['saldo'].to_f
    @extrato_saldo_inicial += saldo_inical_pagamentos[0]['saldo'].nil? ? 0.00 : saldo_inical_pagamentos[0]['saldo'].to_f

    @extrato_saldo_final =  saldo_final_comissao[0]['saldo'].nil? ? 0.00 : saldo_final_comissao[0]['saldo'].to_f
    @extrato_saldo_final += saldo_final_pagamentos[0]['saldo'].nil? ? 0.00 : saldo_final_pagamentos[0]['saldo'].to_f
    @saldo_corrente = @extrato_saldo_inicial
  end
  






  
  def mesSeguinte(anoReferencia, mesReferencia)
    if mesReferencia == 12
      mesReferencia = 1
      anoReferencia += 1
    else
      mesReferencia += 1
    end
    return anoReferencia.to_s + '-' + mesReferencia.to_s
  end
end
