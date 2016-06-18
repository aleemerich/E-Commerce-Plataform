function atualizaPainel(){
	// GET /adm/painel/ajax/tabela
	var url = '/adm/painel/ajax/tabela';
	envioAjax(url, true, 'GET');
}

function retornoAjax() {
    if ( xmlhttp.readyState == 4) { // Completo 
        if ( xmlhttp.status == 200) { // resposta do servidor OK 
        	if (xmlhttp.responseText.length > 0 ) {
         			if (xmlhttp.responseText != 'erro'){
        			document.getElementById("painel_conteudo").innerHTML = xmlhttp.responseText;
        			setTimeout("atualizaPainel()",5000);
        			mensagem(false);
         			}
        			else{
        				document.getElementById('div_mensagem').innerHTML = 'Erro no cálculo do frete';
        				mensagem(true);
        			}
             	} 
        } else { 
        	document.getElementById('td_mensagem_aviso').innerHTML = '<b>A atualização automática foi interrompida!</b>'; 
        	//xmlhttp.statusText;
        	mensagem(true);
        	setTimeout("atualizaPainel()",5000);
        } 
    }
}
