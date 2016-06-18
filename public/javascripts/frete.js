	
function getCEP(cod){
	var apoio = document.getElementById("pedido_endereco_id_"+cod).value.split(";");
	document.getElementById("adm_pedido_endereco_id").value = apoio[0];
	atributos[0] = apoio[1]; // cep destino
}

function getServico(cod){
	var apoio = document.getElementById("forma_envio_"+cod).value.split(";");
	document.getElementById("adm_pedido_forma_envio_id").value = apoio[2];
	atributos[1] = apoio[0]; // codigo de envio
	atributos[2] = apoio[1]; // funcao de envio
	calculoFrete();
}

function calculoFrete(){

	// Não foi implementado outras funções além da do Correio, contudo
	// é possível fazê-lo só mexendo nessa função e, conforme for, 
	// na função retornoAjax
	if (atributos[0] == '' || atributos[1] == '' || atributos[2] == '' || atributos[3] == '' ){
		alert('Você precisa selecionar um endereço');
		var inputs = document.getElementsByTagName("input");
		for (var i = 0; i < inputs.length; ++i){
			if (inputs[i].type == "radio"){
				inputs[i].checked = false;
			}
		}
	}
	else{
		var aguarde = document.getElementById("img_aguarde");
		var paginasMedidas = pegaMedidas();
		var xtop = (paginasMedidas[3] / 2);
		xtop = xtop - (aguarde.scrollHeight / 2);
		var xleft = (paginasMedidas[2] / 2);
		xleft = xleft - (aguarde.scrollWidth / 2);
		aguarde.style.top = (xtop) + 'px';
		aguarde.style.left = (xleft) + 'px';
		ativaFundo();
		aguarde.style.visibility = 'visible';
		// GET /adm/pedidos/:id/services/:funcao/:cepDestino/:codigo
		var url = '/adm/pedidos/' + atributos[3] + '/services/' + atributos[2] + '/' + atributos[0] + '/' + atributos[1];
		//document.getElementById("valor_envio").innerHTML = url;
		envioAjax(url, true, 'GET');
	}
}

function retornoAjax() {
    if ( xmlhttp.readyState == 4) { // Completo 
        if ( xmlhttp.status == 200) { // resposta do servidor OK 
        	if (xmlhttp.responseText.length > 0 ) {
        		// sem tratamento para resposta
        			if (xmlhttp.responseText != 'erro'){
	        			apoio = xmlhttp.responseText.split(";");
        				if (apoio[2] == 'ajuste'){
 		   					var mensagemHTML = '<span id="mensagem" style="font-size:medium;">Dimensão Estimada: ' + apoio[3];
		   					mensagemHTML += '<br /><br /> <span  style="color:#FF0000; font-size:large">Os Correios não realizam entregas com essas dimensões.</span> Nos consulte sobre outra forma de envio.'
		   					mensagemHTML += '</span>';
		   					document.getElementById("mensagem").innerHTML = mensagemHTML;
		   					desativaFundoUI();
        				}
        				else{
		        			document.getElementById("adm_pedido_valor_envio").value = apoio[0];
		   					var mensagemHTML = '<span id="mensagem" style="font-size:medium;"> Valor do Frete: <span style="color:#FF0000; font-size:large">R$ '; 
		   					mensagemHTML += float2moeda(apoio[0]) + '</span> com entrega prevista em <span  style="color:#FF0000; font-size:large">';
		   					mensagemHTML += apoio[1] + '</span> dia(s)';
		   					mensagemHTML += '<br />Dimensão Estimada: ' + apoio[3];
		   					mensagemHTML += '</span>';
		   					document.getElementById("mensagem").innerHTML = mensagemHTML;
		   					desativaFundoUI();
        				}
        			}
        			else{
        				var mensagemHTML = '<span style="color:#FF0000;">O serviço de consulta de frete esta indisponível</span>';
   						document.getElementById("mensagem").innerHTML = mensagemHTML;
   						desativaFundoUI();
        			}
             	} 
        } else { 
        	document.getElementById('td_mensagem_aviso').innerHTML = 'Houve problemas no envio das informações'; 
        	//xmlhttp.statusText;
        	mensagem(true);
        	desativaFundoUI();
        } 
    }
}

function desativaFundoUI(){
	desativaFundo();
	var aguarde = document.getElementById("img_aguarde");
	aguarde.style.visibility = 'hidden';
}

function checarFormulario(){
	var formulario = document.getElementById("edit_adm_pedido");
	var valor = document.getElementById("adm_pedido_valor_envio").value
	if (valor <= 0){
		alert('Você precisa escolher algumas das opções acima');
	}
	else{
		formulario.submit();
	}
}

function ocultaFormulario(){
	var formulario = document.getElementById("edit_adm_pedido");
	var desejo = document.getElementById("btn_desejo");
	var prosseguir = document.getElementById("btn_prosseguir_topo");
	var volta_topo = document.getElementById("btn_volta_topo");
	
	if (formulario.style.visibility == "hidden"){
		formulario.style.visibility = "visible";
		desejo.style.visibility = "hidden";
		volta_topo.style.visibility = "hidden";
		prosseguir.style.visibility = "hidden";
	}
	else{
		formulario.style.visibility = "hidden";
		desejo.style.visibility = "visible";
		volta_topo.style.visibility = "visible";
		prosseguir.style.visibility = "visible";
	}
}

function anularFrete(){
	var formulario = document.getElementById("edit_adm_pedido");
	document.getElementById("adm_pedido_endereco_id").value = '';
	document.getElementById("adm_pedido_forma_envio_id").value = '';
	document.getElementById("adm_pedido_valor_envio").value = '0.0';
	formulario.submit();
}
