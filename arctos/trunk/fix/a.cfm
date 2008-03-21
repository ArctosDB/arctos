<script type='text/javascript' src='/includes/jquery/jquery.js'></script>	
<script type='text/javascript' src='/includes/jquery/jquery.dimensions.js'></script>
<script type='text/javascript' src='/includes/jquery/suggest.js'></script>	
<!---	
<script type='text/javascript' src='/includes/jquery/autocomplete.js'></script>	
--->

<cfinclude template="/includes/_header.cfm">

<style type="text/css">
	
	.ac_results {
		border: 1px solid gray;
		background-color: white;
		padding: 0;
		margin: 0;
		list-style: none;
		position: absolute;
		z-index: 10000;
		display: none;
	}
	
	.ac_results li {
		padding: 2px 5px;
		white-space: nowrap;
		color: #101010;
		text-align: left;
	}
	
	.ac_over {
		cursor: pointer;
		background-color: #F0F0B8;
	}
	
	.ac_match {
		text-decoration: underline;
		color: black;
	}
	
	
</style>



<input size="30" style="position: absolute" id="suggest" />
<script type="text/javascript">
jQuery( function($) {
	//	jQuery("#ac_me").autocomplete("/ajax/tData.cfm?action=suggestGeologyAttVal", { minChars:3, matchSubset:1, matchContains:1, cacheLength:10, onItemSelect:selectItem, formatItem:formatItem, selectOnly:1 });
	jQuery("#suggest").suggest("/ajax/tData.cfm?action=suggestGeologyAttVal",{minchars:4,  onSelect: function() {alert("You selected: " + this.value)}});
});
</script>
<!---

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

function getDataResult(stateArray){
	//alert('hi');



	var key = Array();
	var value = Array();
	for (i=0; i < stateArray.length; i++)
	{
		key[i] = stateArray[i]['ATTRIBUTE_VALUE'];
		value[i] = '';
	}
				strQuery = selectedSuggestObject.name + '.showQueryDiv("' + searchString + '", key , value)';
				eval (strQuery);
			}
		
		
			/*
			
	var key = Array();			
	for (i=0; i < result.length; i++) {
		key[i] = result[i].ATTRIBUTE_VALUE;
	}
	strQuery = selectedSuggestObject.name + '.showQueryDiv("' + searchString + '", key )'; 
	eval (strQuery);
	}
	*/

</script>
</body>
</html>
---->
