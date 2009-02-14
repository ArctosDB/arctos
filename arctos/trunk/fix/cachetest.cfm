<script type='text/javascript' src='/ajax/core/engine.js'></script>
	<script type='text/javascript' src='/ajax/core/util.js'></script>
	<script type='text/javascript' src='/ajax/core/settings.js'></script>
	
	
<script>

function ssvar (startrow,maxrows) {
	
	DWREngine._execute(_cfscriptLocation, null, 'ssvar',startrow,maxrows, success_ssvar);
}

function success_ssvar(result){
	//alert(result);
	ahah('ctcont.cfm','test');
}


function ahah(url, target, delay) {
  var req;
  document.getElementById(target).innerHTML = 'waiting...';
  if (window.XMLHttpRequest) {
    req = new XMLHttpRequest();
  } else if (window.ActiveXObject) {
    req = new ActiveXObject("Microsoft.XMLHTTP");
  }
  if (req != undefined) {
    req.onreadystatechange = function() {ahahDone(req, url, target, delay);};
    req.open("GET", url, true);
    req.send("");
  }
}  

function ahahDone(req, url, target, delay) {
  if (req.readyState == 4) { // only if req is "loaded"
    if (req.status == 200) { // only if "OK"
      document.getElementById(target).innerHTML = req.responseText;
    } else {
      document.getElementById(target).innerHTML="ahah error:\n"+req.statusText;
    }
    if (delay != undefined) {
       setTimeout("ahah(url,target,delay)", delay); // resubmit after delay
	    //server should ALSO delay before responding
    }
  }
}
</script>

<cffunction name="query2xml" returntype="string" output="yes">
	<cfargument name="theQuery" type="query" required="true">
	<cfoutput>
	<cfxml  variable="returnData">
		<result>

			<cfloop query="theQuery">
			<record>
				<cfloop list="#theQuery.ColumnList#" index="cname">
					<#cname#>
							#evaluate("theQuery." & cname)#
						</#cname#>

				</cfloop>
				</record>
			</cfloop>
		</result>
	</cfxml>

	</cfoutput>
	<cfreturn returnData>
</cffunction>
<cf_get_header collection_id="#exclusive_collection_id#">


<input type="button" value="aha" onclick="ahah('ctcont.cfm','test');">
<input type="button" value="1-3" onclick="ssvar(1,3);">
<input type="button" value="1-1" onclick="ssvar(1,1);">
<input type="button" value="3-5" onclick="ssvar(3,5);">

<div id="test" style="border:1px solid red;">test</div>


<form name="a" method="post" action="cachetest.cfm">
	<input type="hidden" name="action" value="go">
	<input type="text" name="b">
	<input type="text" name="c">
	<input type="submit">
</form>




<cfquery name="session.bob" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT flat.collection_object_id, flat.cat_num, flat.institution_acronym, flat.collection_cde, flat.collection_id, flat.parts, flat.sex, flat.scientific_name, flat.country, flat.state_prov, flat.spec_locality, flat.verbatim_date ,concatSingleOtherId(flat.collection_object_id,'ALAAC') AS CustomID, to_number(ConcatSingleOtherIdInt(flat.collection_object_id,'ALAAC')) AS CustomIDInt,dec_lat,dec_long FROM flat INNER JOIN cataloged_item ON (flat.collection_object_id =cataloged_item.collection_object_id) inner join taxa_terms on (flat.collection_object_id = taxa_terms.collection_object_id) WHERE
	 flat.collection_object_id IS NOT NULL AND taxa_terms.taxa_term like '%PHOCA HISPIDA%'
	 and cataloged_item.cat_num < 10000 and  cataloged_item.cat_num > 1
	 <!------>
	 </cfquery>
	


<cfif #action# is "i">
<cfoutput>

<cfxml variable="returnData">
<result>
			<cfloop query="bob">
			<record>
				<cfloop list="#bob.ColumnList#" index="cname">
					<#cname#>
							#evaluate("bob." & cname)#
						</#cname#>

				</cfloop>
				</record>
			</cfloop>
		</result>
			</cfxml>

</cfoutput>

</cfif>
<cfif #action# is "f">

	<cfset a = query2xml(#bob#)>

<cfdump var=#a#>

</cfif>
