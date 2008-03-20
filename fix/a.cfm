<cfinclude template="/includes/_header.cfm">
	<link rel="stylesheet" type="text/css" href="/ajax/core/suggest.js">
	<script language='javascript'>
var mySuggestObject= new Suggest();
var searchString = "";
}


function getData(qry)
{
searchString = qry;
DWREngine._execute(_cfscriptLocation, null, 'suggestGeology', searchString, getDataResult);
}

function getDataResult(return)
/*
this function assumes a CF query object with columns USERNAME and DN is coming back from the database via the CF function
as the username is typed, the full DN is displayed as the suggest option
*/
{ var key = Array();
var value = Array();
for (i=0; i < return.length; i++)
{
key[i] = return[i].GEOLOGY_ATTRIBUTE; //if your query has a different column name, use it here
}
strQuery = selectedSuggestObject.name + '.showQueryDiv("' + searchString + '", key , value)'; eval (strQuery);
}
</script>
<input id="formfieldname" name="formfieldname" value="" size=20 autocomplete="off" onFocus="onSuggestFieldFocus(mySuggestObject)">


<script>
onSuggestFieldFocus(mySuggestObject);
mySuggestObject.InitQueryCode('mySuggestObject','formfieldname')
</script>