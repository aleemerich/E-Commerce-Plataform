# encoding: UTF-8
module Adm::ParcelaPedidosHelper

  def alerta_parcela(cod)
    if cod == '2' # EM ATRASO
      'atencao10'
    elsif cod == '1' or cod == '3' # PAGO ou PADO DIRETAMENTE
      'atencao3'
    else
      ''
    end
  end  
end
