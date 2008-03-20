<script type='text/javascript' src='/includes/jquery/jquery.js'></script>	
<script type='text/javascript' src='/includes/jquery/autocomplete.js'></script>	
		
		<cfinclude template="/includes/_header.cfm">

<style type="text/css">
.ac_input {
	width: 200px;
}
.ac_results {
	padding: 0px;
	border: 1px solid WindowFrame;
	background-color: Window;
	overflow: hidden;
}

.ac_results ul {
	width: 100%;
	list-style-position: outside;
	list-style: none;
	padding: 0;
	margin: 0;
}

.ac_results iframe {
	display:none;/*sorry for IE5*/
	display/**/:block;/*sorry for IE5*/
	position:absolute;
	top:0;
	left:0;
	z-index:-1;
	filter:mask();
	width:3000px;
	height:3000px;
}

.ac_results li {
	margin: 0px;
	padding: 2px 5px;
	cursor: pointer;
	display: block;
	width: 100%;
	font: menu;
	font-size: 12px;
	overflow: hidden;
}
.ac_loading {
	background : url('/jquery/img/indicator.gif') right center no-repeat;
}
.ac_over {
	background-color: Highlight;
	color: HighlightText;
}
</style>



<p><input id='ac_me' type='text'> (autocomplete box)</p>
<script type="text/javascript">

function selectItem(li) {
	if (li.extra) {
		alert("That's '" + li.extra[0] + "' you picked.")
	}
}
function formatItem(row) {
	return row[0] + "<br><i>" + row[1] + "</i>";
}

jQuery( function($) {
	$(document).ready(function() {
		$("#ac_me").autocomplete("search.php", { minChars:3, matchSubset:1, matchContains:1, cacheLength:10, onItemSelect:selectItem, formatItem:formatItem, selectOnly:1 });
		$("#ac_me2").autocomplete("search.php", { minChars:3, matchSubset:false, matchContains:false, cacheLength:10, onItemSelect:selectItem, formatItem:formatItem, selectOnly:1 });
	});
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
