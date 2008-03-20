<script type='text/javascript' src='/ajax/core/engine.js'></script>
<script type='text/javascript' src='/ajax/core/util.js'></script>
<script type='text/javascript' src='/ajax/core/settings.js'></script>
				<script type='text/javascript' src='/ajax/core/prototype.js'></script>	
		<script type='text/javascript' src='/ajax/core/suggest.js'></script>


	


<script language='javascript'>
function onInit()
{
onSuggestFieldFocus(mySuggestObject);
mySuggestObject.InitQueryCode('mySuggestObject','formfieldname')
}

function getData(qry) {
	alert(qry);
	searchString = qry;
	DWREngine._execute(_cfscriptLocation, null, 'suggestGeology', searchString, getDataResult);
}

function getDataResult(bla){
	alert('hi');
	//for (i=0; i < return.length; i++) {
	//	key[i] = return[i].GEOLOGY_ATTRIBUTE;
	//}
	//strQuery = selectedSuggestObject.name + '.showQueryDiv("' + searchString + '", key )'; 
	//eval (strQuery);
}
</script>
<input id="formfieldname" name="formfieldname" value="" size=20 autocomplete="off" onFocus="onSuggestFieldFocus(mySuggestObject)">


<script>onInit();</script>
