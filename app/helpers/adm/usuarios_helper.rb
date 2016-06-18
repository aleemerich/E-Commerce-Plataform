# encoding: UTF-8
module Adm::UsuariosHelper
  def permissao_acesso_helper(dados=';', cod=0)
    apoio = dados.split(";")
    apoio.index(cod.to_s)
  end
end
