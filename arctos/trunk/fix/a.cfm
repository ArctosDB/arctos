<script type='text/javascript' src='/ajax/core/prototype.js'></script>	
		<script type='text/javascript' src='/ajax/core/suggest.js'></script>
		
		<cfinclude template="/includes/_header.cfm">

<html>
<body onload="onInit()"></body>
</html>

<!----


		<script type='text/javascript' src='/ajax/core/engine.js'></script>
<script type='text/javascript' src='/ajax/core/util.js'></script>
<script type='text/javascript' src='/ajax/core/settings.js'></script>
				
---->
<script language='javascript'>
var mySuggestObject= new Suggest();
var searchString = "";
</script>


<script language='javascript'>

function onInit()
{
onSuggestFieldFocus(mySuggestObject);
mySuggestObject.InitQueryCode('mySuggestObject','formfieldname')
}
</script>





<form name="a" id="a">
<input id="formfieldname" name="formfieldname" value="" size=20 autocomplete="off" onFocus="onSuggestFieldFocus(mySuggestObject)">
</form>
<script language='javascript'>

function onInit()
{
onSuggestFieldFocus(mySuggestObject);
mySuggestObject.InitQueryCode('mySuggestObject','formfieldname')
}

function getData(qry) {
	//alert('going');
	searchString = qry;
	DWREngine._execute(_cfscriptLocation, null, 'suggestGeologyAttVal',searchString, getDataResult);
}

function getDataResult(result){
	//alert('hi');

	var value = Array();			
	for (i=0; i < result.length; i++) {
		key[i] = result[i].ATTRIBUTE_VALUE;
	}
	strQuery = selectedSuggestObject.name + '.showQueryDiv("' + searchString + '", key )'; 
	eval (strQuery);
}
</script>
</body>
</html>

