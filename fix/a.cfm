<cfinclude template="/includes/_header.cfm">
	<link rel="stylesheet" type="text/css" href="/ajax/core/suggest.js">
	
		<link rel="stylesheet" type="text/css" href="/includes/scriptaculous/prototype.js">
	
	
	


		<script language="javascript">
			var zipLookup = new Suggest(); 
			var searchString = "";
		
			function getData(qry)
			{
				searchString = qry;
				DWREngine._execute(_cfscriptLocation, null, 'suggestGeology', searchString, getDataResult);
			}
			
			function getDataResult(stateArray)
			{
				var key = Array();
				var value = Array();
				
				for (i=0; i < stateArray.length; i++)
				{
					key[i] = stateArray[i]['KEY'];
					value[i] = stateArray[i]['VALUE'];
				}
				strQuery = selectedSuggestObject.name + '.showQueryDiv("' + searchString + '", key , value)';
				eval (strQuery);
			}
			
			function onInit()
			{
				onSuggestFieldFocus(zipLookup);
				zipLookup.InitQueryCode('zipLookup','fldZipLookup')
			}
		</script>
	</head>


		<table width="100%">
			<tr>
				<td width="30%">
					<h1>CFAjax</h1>
				</td>
				<td align="right" width="60%">
					<div align="right">
						<script type="text/javascript"><!--
							google_ad_client = "pub-4186342241163356";
							google_ad_width = 468;
							google_ad_height = 60;
							google_ad_format = "468x60_as";
							google_ad_type = "text_image";
							google_ad_channel ="";
							//--></script>

							<script type="text/javascript"
							  src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
						</script>
					</div>
				</td>
				<td width="10%">&nbsp;</td>
			</tr>
		</table>
		
		<table width="100%" cellpadding="3" cellspacing="0" border="0">
			<tr>

				<td class="nav" nowrap>
					<b><a href="/cfajax/">[ Home ]</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="/cfajax/examples.asp">[ Examples ]</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="/cfajax/project.asp">[ Project / Download ]</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="/cfajax/faq.asp">[ FAQ / How To]</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="/cfajax/docs/default.asp">[ Docs/Articles]</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="/cfajax/about.asp">[ About Me ]</a></b>				
				</td>
			</tr>
		</table>
		<p>

			<b>CFAjax Suggest with Zero Configuration</b>
			<br>
			This example uses CFAjax suggest with very basic configuration, all the function and property 
			set in this example are the basic essentials that are required to run CFAjax suggest.			
			<br><br>
			In order to use this example, move the cursor focus on the text field and enter the first character 
			of any us state  e.g   “v” for Virginia.			
		</p>
		<p>
			US State Name : <input id="fldZipLookup" name="fldZipLookup" value="" size=20 autocomplete="off" onFocus="onSuggestFieldFocus(zipLookup)"> 
		</p>

	</body>
</html>



<script>onInit();</script>

<!----
<script language='javascript'>



function getData(qry)
{
	alert(qry);
searchString = qry;
DWREngine._execute(_cfscriptLocation, null, 'suggestGeology', searchString, getDataResult);
}

function getDataResult(return){ 
	var key = Array();
	var value = Array();
	for (i=0; i < return.length; i++) {
		key[i] = return[i].GEOLOGY_ATTRIBUTE; //if your query has a different column name, use it here
	}
	strQuery = selectedSuggestObject.name + '.showQueryDiv("' + searchString + '", key , value)'; eval (strQuery);
}
</script>
<input id="formfieldname" name="formfieldname" value="" size=20 autocomplete="off" onFocus="onSuggestFieldFocus(mySuggestObject)">


<script>
	var mySuggestObject= new Suggest();
var searchString = "";
onSuggestFieldFocus(mySuggestObject);
mySuggestObject.InitQueryCode('mySuggestObject','formfieldname')
</script>

---->