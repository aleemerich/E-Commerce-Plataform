# Plataforma de E-Commerce em Rails

Plataforma para e-commerce criada em Ruby on Rails 3.0

## Escopo planejado para o sistema

Este sistema teve como objetivo ser uma plataforma completa de e-commerce em 2011 com uma proposta diferente: todo o site seria dado a uma empresa para que ela vendesse por essa plataforma em troca de ter que pagar uma comissão pré-definida pelo uso da ferramenta. Por esse motivos, há o extrato de comissão desenvolvido como uma das funcionalidades.

## Funcionalidades macros do sistema de e-commerce
O sistema de e-commerce com as seguintes áreas:

-	Administrativa
-	Clientes
-	Pública

Abaixo serão descritas as principais funcionalidades do sistema para efeito de ciência e documentação com a empresa cliente.

###	Área administrativa

A área administrativa atua como backoffice, permitindo que se faça toda a gestão dos produtos, clientes, pagamentos, funcionários e comissionamentos pertencente ao sistema de e-commerce.
Essa área é totalmente restrita aos administradores do sistema e seu uso é controlado através de autenticação onde o usuário deve imputar um e-mail e senha anteriormente cadastrada a ele. Todas as principais ações nessa área são auditadas e armazenadas para possíveis comprovações de ações futuras.

####	Gestão de produtos

O portal contém uma área para gestão dos produtos a serem comercializados pelo sistema. Ao cadastrar um produto, os dados passíveis de serem cadastrados são:

-	Nome do produto (obrigatório);
- Descrição do produto (obrigatório);
- Valor unitário mínimo (obrigatório);
- Valor unitário máximo;
- Dimensões (peso, altura, largura e profundidade);
- Configurações avançadas para o campo QUANTIDADE;
- Permitir ao cliente que solicite uma análise de desconto;
- Status (obrigatório);
- Categoria;
- Comissão a ser paga.

#### Categorias

O sistema permite a criação de categorias para auxiliar a organização dos produtos no site, tornando a navegação mais intuitiva ao consumidor final. No cadastro de categorias, é possível cadastrar uma categoria principal ou vincular essa categoria a uma já existente, formando assim níveis de categorias e subcategorias.
É possível também ao administrador do site gerenciar a ordem das categorias, se quiser, e editar os nomes já cadastrados. Embora não seja recomendado, é possível também excluir uma dada categoria através da área de administração.

####	Gestão dos clientes
Todo cliente que efetuar uma compra no site terá que anteriormente seu cadastro efetuado no sistema. Esse cadastro pode ser feito por um administrador ou pelo próprio cliente acessando a área pública do site e navegando até a opção de fazer um cadastro. 

É possível cadastrar os seguintes dados para um cliente:

- Nome completo (obrigatório);
- CPF ou CNPJ (obrigatório);
- Data de nascimento / abertura da empresa (obrigatório);
- E-mail (obrigatório e usado para autenticação);
- Senha (obrigatório e usado para autenticação);
- Status (apenas para o administrador);
- Endereços (cada um contendo Logradouro, Número, Complemento, CEP, Cidade e UF);
- Telefones (cada um contendo DDD e número);
- Formas de pagamento (apenas para o administrador, sendo o “pagamento a vista” cadastrado como padrão para os casos de cadastros feitos pelo próprio cliente)
- Observações gerais

Quando o cadastro de um cliente é feito pelo administrador, ele automaticamente já é um cliente apto a fazer compra pelo site. Entretanto quando o cadastro é feito por um cliente, é necessário que o cliente valide esse cadastro através de uma chave de autenticação enviada ao e-mail cadastrado do cliente. Esse processo se faz necessário para assegurar que haja ao menos um meio verificado de comunicação com um cliente.
É possível ao administrador alterar dados e atribuir/editar novos endereços, telefones e formas de pagamentos de qualquer cliente. Já o próprio cliente poderá fazer isso apenas em seus dados, com exceção a modificações na forma de pagamento (estas somente pelo administrador do sistema).

####	Gestão de funcionários
Para que alguém possa auxiliar ou mesmo administrar o sistema de e-commerce, é necessário que seja cadastrado como “funcionário”. Ao se cadastrar um funcionário, o administrador pode entrar com as seguintes informações:

- Nome completo (obrigatório)
- E-mail (obrigatório e usado para autenticar o funcionário)
- Senha (obrigatório e usado para autenticar o funcionário)
- Permissões (obrigatório)
- Status
- Observações
- Página onde o usuário será redirecionado quando se autenticar 

O item “Permissões” define se um usuário será ou não um administrador. É considerado um administrador aquele usuário que tem todas as permissões na área de administração.
O item “Página onde o usuário será redirecionado quando se autenticar” tem a finalidade de levar o usuário a áreas que ele tem acesso, caso a área padrão (gestão de pedidos) não seja de acesso permitido a ele.

_Não está contemplado_

A área de gestão de funcionários não contempla:

•	Controle de ponto, presença ou quantidade de horas trabalhadas;
•	Nenhuma atividade relacionada a Recursos Humanos;
•	Nenhum controle focado em atender as leis de trabalho vigentes.

####	Gestão de pedidos
Todos os pedidos em andamento ou finalizados pelos clientes podem ser acompanhados pela área de pedidos. Essa área está subdividida em quatro subáreas:

- Painel
- Pedidos
- Parcelas
- Pagamentos

__Painel__

O painel mostra os pedidos atuais, em ordem de criação. Ele é atualizado a cada 30 segundos visando exibir aos funcionários e administradores uma visão sempre atualizada do que está ocorrendo no sistema. 
Através do painel é possível acessar a qualquer pedido que esteja visível, bastando para isso que se clique no pedido desejado.

__Pedidos__

A subárea de pedidos visa oferecer aos funcionários e administradores algumas funcionalidades extras como a possibilidade de ver a lista completa de pedido (com paginação), criar um pedido para um dado cliente e realizar algumas ações de manutenção. Contudo, a maioria das ações corriqueiras pode ser feita também pela subárea Painel.

__Parcelas__

Por padrão, o sistema permite apenas uma parcela para um dado pedido (venda à vista), contudo é possível cadastrar outras formas de venda para um cliente, resultando assim em vendas fracionadas (parcelas) com ou sem a cobrança de juros nessas parcelas.
Essa subárea permite aos funcionários e administradores checar como está o status das parcelas de um dado pedido, cancelar parcelas de um pedido pelos aos funcionários com permissão ou mudar o status da para “pago” em parcelas que foram acertadas diretamente com a empresa cliente. Outras customizações podem ser feitas nessa área, se for detectado essa necessidade pelo levantamento inicial com a empresa cliente.

__Pagamentos__

Todos os pagamentos são visíveis aos funcionários com permissão, contudo os pagamentos aqui citados tratam-se apenas daqueles feitos via serviços eletrônicos terceirizados com PAG SEGURO, PAGAMENTO DIGITAL, bancos e outros provedores de pagamentos. Esses pagamentos não são editáveis dado que seus status são modificados apenas pela empresa responsável pela compensação do pagamento. Isso inibe possíveis fraudes e erros na administração do site.

#### Dando andamento em um pedido

Ao atender um pedido, a empresa cliente tem acesso a dados como:

- Nome do cliente, com a possibilidade de ver a ficha do cliente ao alcance de um clique.
- Status do pedido e possibilidade de modificação
- Valor total do pedido
- Informações sobre pagamento
- Informações sobre a entrega (quando essa opção está ativa)
- Detalhamento completo do pedido
- Impressão do pedido
- Enviar um e-mail de contato ao cliente

Também deve se alterar seu status conforme a produção desse pedido for executada. Esse andamento pode ser acompanhado de perto pelo cliente, notificando-o quando determinados status forem acionados, como o status de “despachado para entrega”, por exemplo.
Todas as alterações importantes em um pedido são auditadas pelo sistema. Essa auditoria guarda a data e hora da ocorrência, o pedido em questão, o identificador do usuário e a ação ocorrida. Outras customizações podem ser feitas nessa área, se for detectado essa necessidade pelo levantamento inicial com a empresa cliente.

####	Extrato de comissionamento
A empresa cliente sempre terá acesso a uma área definida como “EXTRATO”. Nessa área a empresa cliente terá uma lista completa do percentual cobrado e o valor referente a cada item dos pedidos feitos pelos usuários no sistema de e-commerce. 
Também será possível ver de forma destacada os pagamentos realizados pela empresa cliente referente a comissionamento e os reembolsos feitos, quando esses ocorrem.


###	Área do cliente
A área do cliente permite que os usuários com o perfil de cliente acessem e editem seus dados, visualizem e vejam seus todos os seus pedidos e possam criar novos pedidos. Outras customizações podem ser feitas nessa área, se for detectado essa necessidade pelo levantamento inicial com a empresa cliente.

####	Novo cadastro

Os clientes poderão fazer o cadastro no sistema de e-commerce preenchendo um formulário padrão onde serão solicitados:

- Nome completo (obrigatório);
- CPF ou CNPJ (obrigatório);
- Data de nascimento / abertura da empresa (obrigatório);
- E-mail (obrigatório e usado para autenticação);
- Senha (obrigatório e usado para autenticação);
- Endereço contendo Logradouro, Número, Complemento, CEP, Cidade e UF;
- Telefone contendo DDD e número;

Após o cadastro dos dados acima, um e-mail de validação é enviado ao e-mail informado no momento do cadastro. Esse processo visa dar autenticidade ao e-mail informado, criando assim um meio válido de contato com o cliente.

#### Alterações dos dados / Inserções de novos dados

Os clientes poderão alterar seus dados cadastrais através da área restrita, acessada através de autenticação, por meio de seu e-mail e senha cadastrados.
Nesse local será possível alterar os dados cadastrados inicialmente e inserir novos dados de endereços e telefones. Esses novos dados também poderão ser alterados no futuro.

#### Pedidos

Os clientes poderão visualizar seus pedido ou fazer novos pedidos através de sua área restrita, acessada através de autenticação, por meio de seu e-mail e senha cadastrados.
Será possível ao cliente ver os pedidos já finalizados, os pedidos ainda em produção ou até o pedido ainda em aberto. Também é possível realizar o pagamento de um pedido e das parcelas de um pedido através dessa área. A impressão dos pedidos também é possíve, através de recurso próprio para impressão fornecido em cada pedido individualmente.

###	Área pública
A área pública permite a qualquer um acessar informações comuns e de ordem pública como os preços dos produtos, páginas institucionais e de página com informações de contato. Outras customizações podem ser feitas nessa área, se for detectado essa necessidade pelo levantamento inicial com a empresa cliente.
Os principais itens na área pública são:

- Páginas com conteúdo institucional (dados sobre a empresa cliente e outras informações);
- Relação das categorias;
- Páginas de detalhes sobre os produtos ofertados;
- Área de autenticação para os clientes;
- Links e botões para publicação dos conteúdos em sites de relacionamentos (Twitter, Facebook e afins);

## Diferenciais

1. O sistema permite fazer "pechincha", ou seja, se o dono do e-commerce quiser, ele pode marcar quais produtos os usuários podem pedir um desconto antes da compra. Esses produtos entram para o carrinho de compra e, antes de fechar o pedido, os gestores do site fazem a análise e permitem ou não um dado desconto.
2. O sistema permite que se cadastre agregados a produtos, ou seja, você pode adicionar itens extras que, se selecionados, aumentam ou diminuem o valor do produto adquirido.
3. Este sistema é o único conhecido que trabalha sobre o modelo de comissão, então cada venda feita gera um extrato ao dono do e-comerce que deixa claro quanto de comissão estão gerando.
4. O sistema suporta cálculo de frete pelos Correios e integração com brokers de pagamento (PagSeguro e outros)
5. O modelo de cobrança adotado quando o sistema foi desenvolvido era único: a empresa arcava com toda a parte de TI (hospedagem, registro de dominio, e-mails e manutenções) em troca de pagar comissão pelo que vendia pelo site.

## Objetivo de disponibilizar no GitHUb

Inicialmente é mostrar que possuo algum conhecimento em Rails, quem sabe oferecer ideias para outros produtos ou modelos de negócios e, principalmente, quem sabe achar um grupo que ajude a melhorar a ferramenta, sua arquitetura e funcionalidades a ponto de vir a ser uma nova plataforma de e-commerce, oferecendo funcionalidades e apoio a que deseja iniciar seu negócio.

Espero que ajude alguém e fico a disposição para contato!

Abraços.
