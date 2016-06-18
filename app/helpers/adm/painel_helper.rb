# encoding: UTF-8
module Adm::PainelHelper
  
  def alerta_painel(cod)
    if cod == '5' # AGUARDANDO ANALISE
      'atencao10'
    elsif cod == '4' # AGUARDANDO EXECUÇÃO
      'atencao7'
    elsif cod == '6' # EM EXECUCAO
      'atencao5'
    elsif cod == '9' or cod == '8' # CONCLUIDO ou ENTREGUE
      'atencao3'
    else
      ''
    end
  end
end
