
function envioAjax(url, retorno, metodo, dados, f_retornoAjax) {
    try { 
        xmlhttp = new ActiveXObject("Msxml2.XMLHTTP"); 
    } catch (e) { 
        try { 
            xmlhttp = new ActiveXObject("Microsoft.XMLHTTP"); 
        } catch (E) { 
            xmlhttp = false; 
        } 
    } 

    if  (!xmlhttp && typeof  XMLHttpRequest != 'undefined' ) { 
        try  { 
            xmlhttp = new  XMLHttpRequest(); 
        } catch  (e) { 
            xmlhttp = false ; 
        } 
    }

	if (f_retornoAjax == null)
		var v_retornoAjax = 'retornoAjax';
	else
		var v_retornoAjax = f_retornoAjax;
    if (xmlhttp) {
    	if (retorno){
    			// Para trabalhar com o retorno de uma requisição, é preciso
    			// implementar a função retornoAjax 
    			xmlhttp.onreadystatechange = eval(v_retornoAjax);}
        if (metodo == "POST"){
	        xmlhttp.open("POST",url,true);
	        xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	        xmlhttp.setRequestHeader("Content-length", dados.length);
	        xmlhttp.send(dados);}
	    else{
	        xmlhttp.open("GET", url);
	        xmlhttp.setRequestHeader('Content-Type','text/xml');
	        xmlhttp.send(null);}  
    }
}
