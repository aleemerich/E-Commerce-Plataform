// JavaScript Document

function adicionaProduto(nomeTab)
{
	var tabela = document.getElementById(nomeTab);	
	var corpo = tabela.tBodies[0];
	var linha = corpo.insertRow(-1);
	linha.name = tabela.rows.length;
	
	var coluna01 = linha.insertCell(0);
	coluna01.innerHTML = '<td><input type="text" id="produto_extra[' + tabela.rows.length + '][cod]" id="produto_extra_' + tabela.rows.length + '_cod" disabled="disabled" size="3" /></td>';

	var coluna01 = linha.insertCell(1);
	coluna01.innerHTML = '<td><input type="text" id="produto_extra[' + tabela.rows.length + '][nome]" id="produto_extra_' + tabela.rows.length + '_nome" size="5" /></td>';

	var coluna01 = linha.insertCell(2);
	var aux = '<td><select id="produto_extra[' + tabela.rows.length + '][tipo]" name="produto_extra_' + tabela.rows.length + '_tipo">';
	aux += '			  <option value="0">Arquivos</option>';
	aux += '			  <option value="1">Listas</option>';
	aux += '			  <option value="2">Números</option>';
	aux += '			  <option value="3">Textos</option>';
	aux += '			</select></td>';
	coluna01.innerHTML = aux;
	
	var coluna01 = linha.insertCell(3);
	coluna01.innerHTML = '<td><input type="text" id="produto_extra[' + tabela.rows.length + '][valor]"  name="produto_extra_' + tabela.rows.length + '_valor" size="5" /></td>';
	
	var coluna01 = linha.insertCell(4);
	var aux = '<td><select id="produto_extra[' + tabela.rows.length + '][fator]" name="produto_extra_' + tabela.rows.length + '_fator">';
	aux += '			  <option value="0">Nenhum</option>';
	aux += '			  <option value="1">Soma Individual</option>';
	aux += '			  <option value="2">Soma no Total</option>';
	aux += '			  <option value="3">Multiplica Individual</option>';
	aux += '			  <option value="4">Multiplica no Total</option>';
	aux += '			</select></td>';
	coluna01.innerHTML = aux;
	
	var coluna01 = linha.insertCell(5);
	coluna01.innerHTML = '<td><input type="text" id="produto_extra[' + tabela.rows.length + '][txt_ajuda]" name="produto_extra_' + tabela.rows.length + '_txt_ajuda" /></td>';
	
	var coluna01 = linha.insertCell(6);
	coluna01.innerHTML = '<td><input type="checkbox" onclick="removeArquivo(\'' + nomeTab + '\', this.parentNode.parentNode.rowIndex)" /></td>';
}

function removeProduto(nomeTab, id)
{
	document.getElementById(nomeTab).deleteRow(id);	
}