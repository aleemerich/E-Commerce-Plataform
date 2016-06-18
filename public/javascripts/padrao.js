// JavaScript Document

function redirecionarURL(url){
	window.parent.location = url;
}

function mensagem(exibir)
{
	var objDIV = document.getElementById('div_mensagem');
	//esquerda = (screen.width - 400)/2
	//topo = (screen.height - 100)/4;
	if (exibir)
	{
		window.scrollBy(-1000,-10000000)
		objDIV.style.width = "90%";
		objDIV.style.top = '0px' ;
		objDIV.style.left = ((screen.width * 0.1) / 2) + 'px' 
	    objDIV.style.visibility = "visible";
	}
	else
	{
	    objDIV.style.visibility = "hidden";
	}
}

function mascara (formato, keypress, objeto){
campo = document.getElementById(objeto);

	// cep
	if (formato=='cep'){
		separador = '-';
		conjunto1 = 5;
		if (campo.value.length == conjunto1){
		campo.value = campo.value + separador;}
	}
	
	// moeda
	// TODO: Precisa ser ajustado
	if (formato=='moeda'){
		separador = '.';
		conjunto1 = 2;
		
		var novoValor = "";
		
		for(i= campo.value.length - 1; i > -1 ; -i)
		{
			novoValor += campo.value[i];
		}
		campo.value = novoValor;
		//if (campo.value.length == conjunto1){
		//campo.value = campo.value.substr(campo.value.length, 0) + separador;}
	}
	
	// cpf
	if (formato=='cpf'){
		separador1 = '.'; 
		separador2 = '-'; 
		conjunto1 = 3;
		conjunto2 = 7;
		conjunto3 = 11;
		if (campo.value.length == conjunto1)
		  {
		 	 campo.value = campo.value + separador1;
		  }
		if (campo.value.length == conjunto2)
		  {
		 	 campo.value = campo.value + separador1;
		  }
		if (campo.value.length == conjunto3)
		  {
		  	campo.value = campo.value + separador2;
		  }
	}
	
	// data
	if (formato=='data'){
		if (campo.value.length <= 9)
			{
			separador = '/'; 
			conjunto1 = 2;
			conjunto2 = 5;
			if (campo.value.length == conjunto1)
			  {
				campo.value = campo.value + separador;
			  }
			if (campo.value.length == conjunto2)
			  {
				campo.value = campo.value + separador;
			  }
		}
		else{
			campo.value = campo.value.substr(0,9);}
	}
	
	// telefone
	if (formato=='telefone'){
		separador1 = '(';
		separador2 = ')';
		separador3 = '-';
		conjunto1 = 0;
		conjunto2 = 3;
		conjunto3 = 8;
		if (campo.value.length == conjunto1){
			campo.value = campo.value + separador1;
		}
		if (campo.value.length == conjunto2){
			campo.value = campo.value + separador2;
		}
		if (campo.value.length == conjunto3){
			campo.value = campo.value + separador3;
		}
	}
}

function float2moeda(num) {

   x = 0;

   if(num<0) {
      num = Math.abs(num);
      x = 1;
   }
   if(isNaN(num)) num = "0";
      cents = Math.floor((num*100+0.5)%100);

   num = Math.floor((num*100+0.5)/100).toString();

   if(cents < 10) cents = "0" + cents;
      for (var i = 0; i < Math.floor((num.length-(1+i))/3); i++)
         num = num.substring(0,num.length-(4*i+3))+'.'
               +num.substring(num.length-(4*i+3));
   ret = num + ',' + cents;
   if (x == 1) ret = ' - ' + ret;return ret;

}
