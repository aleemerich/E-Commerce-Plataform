// JavaScript Document
var contAC = 1
function adicionarCampos(id){
	var input = document.createElement("INPUT");
	var espaco = document.createTextNode('Descrição:');
	var input2 = document.createElement("INPUT");
	var br = document.createElement('br');
	input.type = "file";
	input.name = "adm_item_pedido_extra[item"+id+"[dado_fornecido[arquivo["+contAC+"]]]]";
	input.id = "adm_item_pedido_extra_item_"+id+"_dado_fornecido_arquivo_"+contAC;
	input2.type = "text";
	input2.name = "adm_item_pedido_extra[item"+id+"[dado_fornecido[descricao["+contAC+"]]]]";
	input2.size = "30";
	input2.id = "adm_item_pedido_extra_item_"+id+"_dado_fornecido_descricao_"+contAC;

	contAC = contAC + 1;

	//document.body.appendChild(input);
	document.getElementById("itens_extras_"+id).appendChild(input);
	document.getElementById("itens_extras_"+id).appendChild(br);
	document.getElementById("itens_extras_"+id).appendChild(espaco);
	document.getElementById("itens_extras_"+id).appendChild(input2);
	document.getElementById("itens_extras_"+id).appendChild(br);
	document.getElementById("itens_extras_"+id).appendChild(br);
}

function checa_input_file(){
	ativaFundo();
	var nvazio = false;
	var extensao_invalida = false; 
	var inputs = document.getElementsByTagName("input");
	// checando os inputs
	for (var i = 0; i < inputs.length; ++i){
		if (inputs[i].type == "file"){
			// valida se está preenchido
			if ((inputs[i].value == null) && (inputs[i].value =='')){
				nvazio = true;}
			else{
				// valida se a extenção é válida
				// extenção válida = JPG, GIF, JPEG, TIFF, PNG, PDF, CDR, RAR, ZIP
				ext = inputs[i].value.substr(inputs[i].value.length - 4,inputs[i].value.length);
				ext = ext.toUpperCase();
				if ((ext != '.JPG') && (ext != '.JPEG') && (ext != '.PNG') && (ext != '.GIF') && (ext != '.PDF') && (ext != '.CDR') && (ext != '.ZIP') && (ext != '.RAR')){
					extensao_invalida = true;
				}
			}
		}
	}
	// Se passou na checagem, o form é submetido. Caso contrário uma
	// mensagem é exibida ao user
	if (nvazio || extensao_invalida){
		alert('Há campos de ARQUIVOS VAZIOS ou ARQUIVOS DE FORMATO NÃO ACEITO. Por favor, corrija o problema e tente novamente.');
		desativaFundo();
	}
	else{
		document.getElementById('Xcontacts-form').submit();	
		}
}
