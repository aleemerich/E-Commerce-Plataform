// JavaScript Document

function adicionaArquivo(nomeTab)
{
	var tabela = document.getElementById(nomeTab);	
	var corpo = tabela.tBodies[0];
	var linha = corpo.insertRow(-1);
	linha.name = tabela.rows.length;
	
	var coluna01 = linha.insertCell(0);
	coluna01.innerHTML = '<td><input type="text" id="arquivo[' + tabela.rows.length + '][cod]" name="arquivo_' + tabela.rows.length + '_cod" size="3" disabled="disabled"  /></td>';

	var coluna01 = linha.insertCell(1);
	coluna01.innerHTML = '<td><input type="file" id="arquivo[' + tabela.rows.length + '][caminho]" name="arquivo_' + tabela.rows.length + '_caminho" /></td>';

	var coluna01 = linha.insertCell(2);
	coluna01.innerHTML = '<td><input type="text" id="arquivo[' + tabela.rows.length + '][descricao]" name="arquivo_' + tabela.rows.length + '_descricao" /></td>';
	
	var coluna01 = linha.insertCell(3);
	coluna01.innerHTML = '<td><input type="checkbox" onclick="removeArquivo(\'' + nomeTab + '\', this.parentNode.parentNode.rowIndex)" /></td>';
}

function removeArquivo(nomeTab, id)
{
	document.getElementById(nomeTab).deleteRow(id);	
}

function adicionaArquivoCFundo(estado)
{
	objDIV = document.getElementById('div_adiciona_arquivo');
	objBTEnviar = document.getElementById('btnAdicionarArquivo');
	
	switch (estado)
	{
		case "abrir":
			ativaFundo();
			objBTEnviar.onclick = function () {adicionaArquivoCFundo('enviar'); return false;}
			objDIV.style.left = (document.getElementById('tab_arquivo').offsetLeft) + 'px';
			objDIV.style.top = (document.getElementById('tab_arquivo').offsetTop) + 'px';
			objDIV.style.visibility = "visible";
			break;
		case "fechar":
			desativaFundo();
			objDIV.style.visibility = "hidden";
			break;
		case "enviar":
			var caminho = document.getElementById('arquivo[caminho]');
			var descricao = document.getElementById('arquivo[descricao]');

			var tabela = document.getElementById('tab_arquivo');	
			var corpo = tabela.tBodies[0];
			var linha = corpo.insertRow(-1);
			
			
			var coluna01 = linha.insertCell(0);
			coluna01.innerHTML = '<td>' + caminho.value + '</td>';
		
			var coluna01 = linha.insertCell(1);
			coluna01.innerHTML = '<td>' + descricao.value + '</td>';

			var coluna01 = linha.insertCell(2);
			coluna01.innerHTML = '<td><input type="button" onclick="removeArquivoCFundo(this.parentNode.parentNode.rowIndex)" value="Excluir" /></td>';
			
			objDIV.style.visibility = "hidden";
			desativaFundo();
			
			break;
	}
}

function removeArquivoCFundo(id)
{
	document.getElementById('tab_arquivo').deleteRow(id);	
}