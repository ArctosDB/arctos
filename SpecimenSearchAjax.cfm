<cfinclude template="/includes/_header.cfm">
<cfset title="Specimen Search">
<script type='text/javascript' src='/includes/jquery/jquery.js'></script>	
<script language="javascript" type="text/javascript">
function changeTarget(id,tvalue) {
	//alert('id:' + id);
	//alert('tvalue: ' + tvalue);
	//alert('len: ' +tvalue.length);
	if(tvalue.length == 0) {
		tvalue='SpecimenResults.cfm';
		//alert('tvalue manually set:' + tvalue);
	}
	if (id =='tgtForm1') {
		var otherForm = document.getElementById('tgtForm');
	} else {
		var otherForm = document.getElementById('tgtForm1');
	}
	otherForm.value =  tvalue;
	if (tvalue == 'SpecimenResultsSummary.cfm') {
		document.getElementById('groupByDiv').style.display='';
		document.getElementById('groupByDiv1').style.display='';
	} else {
		document.getElementById('groupByDiv').style.display='none';
		document.getElementById('groupByDiv1').style.display='none';
	}
	document.SpecData.action = tvalue;
}
function changeGrp(tid) {
	if (tid == 'groupBy') {
		var oid = 'groupBy1';
	} else {
		var oid = 'groupBy';
	}
	var mList = document.getElementById(tid);
	var sList = document.getElementById(oid);
	var len = mList.length;
	// uncheck everything in the other box
	for (i = 0; i < len; i++) {
		sList.options[i].selected = false;
	}
	// make em match
	for (i = 0; i < len; i++) {
		if (mList.options[i].selected) {
			sList.options[i].selected = true;
		}
	}
}
function nada(){var a=1;}
function showHide(id,onOff) {
	var t='e_' + id;
	var z='c_' + id;	
	if (document.getElementById(t) && document.getElementById(z)) {	
		var tab=document.getElementById(t);
		var ctl=document.getElementById(z);
		if (onOff==1) {
			var ptl="/includes/SpecSearch/" + id + ".cfm";
			$.get(ptl, function(data){
			 $(tab).html(data);
			})
			ctl.setAttribute("onclick","showHide('" + id + "',0)");
			ctl.innerHTML='Show Fewer Options';
		} else {
			tab.innerHTML='';
			ctl.setAttribute("onclick","showHide('" + id + "',1)");
			ctl.innerHTML='Show More Options';
		} 
		// see if we can save it to their preferences
		DWREngine._execute(_cfscriptLocation, null, 'saveSpecSrchPref', id, onOff,nada);
	}
}

function customizeIdentifiers() {
	var theDiv = document.createElement('div');
		theDiv.id = 'customDiv';
		theDiv.className = 'customBox';
		theDiv.innerHTML='<br>Loading...';
		theDiv.src = "";
		document.body.appendChild(theDiv);
		var ptl="/includes/SpecSearch/customIDs.cfm";
			$.get(ptl, function(data){
			 $(theDiv).html(data);
			})
}
</script>

<style>
	
	.customBox {
		border:3px solid green;
		z-index:9999;
		position:absolute;
		top:5%;
		left:5%;
		background-color:white;
		overflow:hidden;
	}
.secHead{background-color:lightgrey;}

.secLabel{
	float:left;
	font-weight:bold;
}
.secControl ,.infoLink a:visited{
	float:right;
	padding-right:1em;
	cursor:pointer;
	color:#2B547E;
	font-size:.65em;
	font-family:Arial, Helvetica, sans-serif;
}

.secControl:hover {
	color:#FF0000;
	text-decoration: underline;
	}
.secDiv {
	border:1px solid green;
	width:50em;
	margin-left:1em;
}
table.ssrch {
	width:100%;
}

td.lbl {
	width:15em;
	text-align:right;
	padding-right:5px;
}
</style>

<cfoutput>
<cfquery name="getCount" datasource="#Application.web_user#">
	select count(collection_object_id) as cnt from cataloged_item
	<cfif len(#exclusive_collection_id#) gt 0>
		,collection
		WHERE cataloged_item.collection_id = collection.collection_id AND
		cataloged_item.collection_id = #exclusive_collection_id#
	</cfif>
</cfquery>
<cfquery name="hasCanned" datasource="#Application.web_user#">
	select SEARCH_NAME,URL
	from cf_canned_search,cf_users
	where cf_users.user_id=cf_canned_search.user_id
	and username='#client.username#'
	order by search_name
</cfquery>
<table cellpadding="0" cellspacing="0">
	<tr>
		<td>
			Access to #getCount.cnt#
			<cfif len(#exclusive_collection_id#) gt 0>
				<cfquery name="coll" datasource="#Application.web_user#">
					select collection
					from collection where
					collection_id=#exclusive_collection_id#
				</cfquery>
				<strong>#coll.collection#</strong>
			records. <a href="searchAll.cfm">Search all collections</a>.
			<cfelse>
			records.
			</cfif>
		</td>
		<td style="padding-left:2em;padding-right:2em;">
			<span class="infoLink" onClick="getHelp('CollStats');">
				Holdings Details
			</span>
		</td>
		<cfif #hasCanned.recordcount# gt 0>
			<td style="padding-left:2em;padding-right:2em;">
				Saved Searches: <select name="goCanned" id="goCanned" size="1" onchange="document.location=this.value;">
					<option value=""></option>
					<option value="saveSearch.cfm?action=manage">[ Manage ]</option>
					<cfloop query="hasCanned">
						<option value="#url#">#SEARCH_NAME#</option><br />
					</cfloop>
				</select>
			</td>
		</cfif>
		<td style="padding-left:2em;padding-right:2em;">
			<span style="color:red;">
				<cfif #action# is "dispCollObj">
					<p>You are searching for items to add to a loan.</p>
				<cfelseif #action# is "encumber">
					<p>You are searching for items to encumber.</p>
				<cfelseif #action# is "collEvent">
					<p>You are searching for items to change collecting event.</p>
				<cfelseif #action# is "identification">
					<p>You are searching for items to reidentify.</p>
				<cfelseif #action# is "addAccn">
					<p>You are searching for items to reaccession.</p>
				</cfif>
			</span>
		</td>
	</tr>
</table>
<cfif #len(client.username)# is 0>
	<form name="logIn" method="post" action="/login.cfm">
	<input type="hidden" name="action" value="signIn">
	<input type="hidden" name="gotopage" value="SpecimenSearch.cfm">
		<div style="float:right; clear:both; border: 2px solid ##0066FF; padding:2px; width:25%; ">
			<table cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td align="right">
						Username:&nbsp;
					</td>
					<td>
						<input type="text" name="username">
					</td>
				</tr>
				<tr>
					<td align="right">
						Password:&nbsp;
					</td>
					<td>
						 <input type="password" name="password">
					</td>
				</tr>
				<tr>
					<td colspan="2" align="center">
						<input type="submit" value="Log In" class="lnkBtn"
		   					onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	
						<input type="button" value="Create Account" class="lnkBtn"
		   					onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
							onClick="logIn.action.value='newUser';submit();">
							<span class="infoLink" 
								onclick="pageHelp('customize');">What's this?</span>
					</td>
				</tr>
				<tr>
					
					<td colspan="2">
						<div class="infoBox">
							Logging in enables you to turn on, turn off, or otherwise customize many features of this database. To create an account and log in, simply supply a username and password here and click Create Account.
						</div>
					</td>
				</tr>
			</table>
		</div>
	</form>
</cfif>
<form method="post" action="SpecimenResults.cfm" name="SpecData">

<table border="0">
	<tr>
		<td valign="top">
			<input type="submit" value="Search" class="schBtn"
				onmouseover="this.className='schBtn btnhov'" onmouseout="this.className='schBtn'">	
		</td>
		<td valign="top">
			<input type="reset" name="Reset" value="Clear Form" class="clrBtn"
   				onmouseover="this.className='clrBtn btnhov'" onmouseout="this.className='clrBtn'">
		</td>
		<td align="right" valign="top">
			<b>See results as:</b>
		</td>
		<td valign="top">
		 	<select name="tgtForm1" id="tgtForm1" size="1"  onChange="changeTarget(this.id,this.value);">
				<option value="">Specimen Records</option>
				<option value="SpecimenResultsHTML.cfm">HTML Specimen Records</option>
				<option  value="/bnhmMaps/bnhmMapData.cfm">BerkeleyMapper Map</option>
				<option value="SpecimenResultsSummary.cfm">Specimen Summary</option>
				<option  value="SpecimenGraph.cfm">Graph</option>
				<cfif isdefined("client.username") AND (#client.username# is "link" OR #client.username# is "dusty")>
				<option  value="/CustomPages/Link.cfm">Link's Form</option>
				</cfif>
				<cfif isdefined("client.username") AND (#client.username# is "cindy" OR #client.username# is "dusty")>
				<option  value="/CustomPages/CindyBats.cfm">Cindy's Form</option>
				</cfif>
			</select>
		</td>
		<td align="left">
			<div id="groupByDiv1" style="display:none ">
				<font size="-1"><em><strong>Group by:</strong></em></font><br>
				<select name="groupBy1" id="groupBy1" multiple size="4" onchange="changeGrp(this.id)">
					<option value="">Scientific Name</option>
					<option value="continent_ocean">Continent</option>
					<option value="country">Country</option>
					<option value="state_prov">State</option>
					<option value="county">County</option>
					<option value="quad">Map Name</option>
					<option value="feature">Feature</option>
					<option value="island">Island</option>
					<option value="island_group">Island Group</option>
					<option value="sea">Sea</option>
					<option value="spec_locality">Specific Locality</option>
					<option value="yr">Year</option>
				</select>
			</div>
		</td>
		 <cfif #client.showObservations# is not 1>
			<td>
				<strong>
					Show 
					<a href="javascript:void(0);" 
						onClick="getHelp('show_observations'); return false;"
						onMouseOver="self.status='Click for Observations help.';return true;"
						onmouseout="self.status='';return true;">Observations</a>?
				</strong>
				<input type="checkbox" name="showObservations" value="true">
			</td>
		</cfif>
		<td>
			<a href="javascript:alert('This \'tissues only\' flag is an 
				MVZ phenomenon; checking this box will preclude returning any 
				data from institutions other than the MVZ. Checking the box 
				will return all MVZ specimen records with a part designated as 
				tissue, which typically is a part collected for destructive sampling. 
				This may include \'tissue\' parts that no longer exist in the 
				collection (e.g., they have been used up).');">Tissues Only?</a>
			<input type="checkbox" name="is_tissue" value="1">
		</td>
	</tr>
</table>			
<input type="hidden" name="Action" value="#Action#">

<div class="secDiv">
	<cfquery name="ctInst" datasource="#Application.web_user#">
		SELECT institution_acronym, collection, collection_id FROM collection
		<cfif len(#exclusive_collection_id#) gt 0>
			WHERE collection_id = #exclusive_collection_id#
		</cfif>
		order by collection
	</cfquery>
	<cfif isdefined("collection_id") and len(#collection_id#) gt 0>
		<cfset thisCollId = #collection_id#>
	<cfelse>
		<cfset thisCollId = "">
	</cfif>
	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
					<span class="secLabel">Identifiers</span>
					
					<span class="secControl" id="c_identifiers"
						onclick="showHide('identifiers',1)">Show More Options</span>
					<span class="secControl" id="c_identifiers_cust"
						onclick="customizeIdentifiers()">Customize</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				<a href="javascript:void(0);" 
						onClick="pageHelp('SpecimenSearchFldDef','cat_num');">
						Institutional Catalog:
				</a>
			</td>
			<td class="srch">
				<select name="collection_id" size="1">
					<cfif len(#exclusive_collection_id#) is 0>
						<option value="">All</option>
					</cfif>
					<cfloop query="ctInst">
						<option <cfif #thisCollId# is #ctInst.collection_id#>
					 		selected </cfif>
							value="#ctInst.collection_id#">
							#ctInst.collection#</option>
					</cfloop>
				</select>				
			</td>
		</tr>
		<tr>
		<td class="lbl">
			Catalog Number:
		</td>
		<td class="srch">
			<cfif #ListContains(client.searchBy, 'bigsearchbox')# gt 0>
				<textarea name="listcatnum" rows="6" cols="40" wrap="soft"></textarea>
			<cfelse>
				<input type="text" name="listcatnum" size="21">
			</cfif>
		</td>
	</tr>
	<cfif isdefined("Client.CustomOtherIdentifier") and len(#Client.CustomOtherIdentifier#) gt 0>
		<tr>
			<td class="lbl">
				<a href="javascript:void(0);" 
					onClick="pageHelp('SpecimenSearchFldDef','custom_identifier');">
					#Client.CustomOtherIdentifier#:
				</a>
			</td>
			<td class="srch">
				<label for="CustomOidOper">Display Value</label>
				<select name="CustomOidOper" size="1">
					<option value="IS">is</option>
					<option value="" selected="selected">contains</option>
					<option value="LIST">in list</option>
					<option value="BETWEEN">in range</option>								
				</select><input type="text" name="CustomIdentifierValue" size="50">
			</td>
		</tr>
		<tr>
		<td class="lbl">
		<cfif isdefined("Client.fancyCOID") and #Client.fancyCOID# is 1>
			&nbsp;
		</td>
			<td class="srch">
				<table cellpadding="0" cellspacing="0">
					<tr>
						<td>
							<label for="custom_id_prefix">OR: Prefix</label>
							<input type="text" name="custom_id_prefix" id="custom_id_prefix" size="12">
						</td>
						<td>
							<label for="custom_id_number">Number</label>
							<input type="text" name="custom_id_number" id="custom_id_number" size="24">
						</td>
						<td>
							<label for="custom_id_suffix">Suffix</label>
							<input type="text" name="custom_id_suffix" id="custom_id_suffix" size="12">
						</td>
					</tr>
				</table>
			</td>
			</cfif>
		</tr>
	</cfif>
</table>

<div id="e_identifiers"></div>
</div>
<div class="secDiv">
	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
					<span class="secLabel">Identification and Taxonomy</span>
					<span class="secControl" id="c_taxonomy"
						onclick="showHide('taxonomy',1)">Show More Options</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				Any Taxonomic Element:
			</td>
			<td class="srch">
				<input type="text" name="any_taxa_term" size="28">
			</td>
		</tr>
	</table>
	<div id="e_taxonomy"></div>
</div>
<div class="secDiv">
	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
					<span class="secLabel">Locality</span>
					<span class="secControl" id="c_locality"
						onclick="showHide('locality',1)">Show More Options</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				<a href="javascript:void(0);" 
					onClick="getHelp('geog'); return false;"
					onMouseOver="self.status='Click for Geographic Element help.';return true;" 
					onmouseout="self.status='';return true;">Any&nbsp;Geographic&nbsp;Element:</a>
			</td>
			<td class="srch">
				<input type="text" name="any_geog" size="50">
			</td>
		</tr>
	</table>
	<div id="e_locality"></div>
</div>
<div class="secDiv">
	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
					<span class="secLabel">Collecting Event</span>
					<span class="secControl" id="c_collevent"
						onclick="showHide('collevent',1)">Show More Options</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				<a href="javascript:void(0);"
					onClick="getHelp('year_collected'); return false;"
					onMouseOver="self.status='Click for Year Collected help.';return true;"
					onmouseout="self.status='';return true;">Year Collected:
				</a>
			</td>
			<td class="srch">
				<input name="begYear" type="text" size="6">&nbsp;
				<span class="infoLink" onclick="SpecData.endYear.value=SpecData.begYear.value">-->&nbsp;Copy&nbsp;--></span>
				&nbsp;<input name="endYear" type="text" size="6">
			</td>
		</tr>
	</table>
	<div id="e_collevent"></div>
</div>
<div class="secDiv">
	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
					<span class="secLabel">Usage</span>
					<span class="secControl" id="c_usage"
						onclick="showHide('usage',1)">Show More Options</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				Type Status:
			</td>
			<td class="srch">
				<cfquery name="ctTypeStatus" datasource="#Application.web_user#">
					select type_status from ctcitation_type_status
				</cfquery>
				<select name="type_status" size="1">
					<option value=""></option>
					<option value="any">Any</option>
					<option value="type">Any TYPE</option>
					<cfloop query="ctTypeStatus">
						<option value="#ctTypeStatus.type_status#">#ctTypeStatus.type_status#</option>
					</cfloop>
				</select>
				<span class="infoLink" onclick="getCtDoc('ctcitation_type_status',SpecData.phylclass.value);">Define</span>	
			</td>
		</tr>
	</table>
	<div id="e_usage"></div>
</div>
<cfquery name="Part" datasource="#Application.web_user#">
	select part_name from 
		<cfif len(#exclusive_collection_id#) gt 0>cctspecimen_part_name#exclusive_collection_id#<cfelse>ctspecimen_part_name</cfif>
		group by part_name order by part_name
</cfquery>
<div class="secDiv">
	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
					<span class="secLabel">Biological Individual</span>
					<span class="secControl" id="c_biolindiv"
						onclick="showHide('biolindiv',1)">Show More Options</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				<a href="javascript:void(0);" 
					onClick="getHelp('parts'); return false;"
					onMouseOver="self.status='Click for Parts help.';return true;" 
					onmouseout="self.status='';return true;">Part:
				</a>
			</td>
			<td class="srch">
				<select name="part_name"  
					<cfif #ListContains(client.searchBy, 'bigsearchbox')# gt 0>
						multiple="multiple" size="5"
					<cfelse>
						size="1"
					</cfif>>
					<option value=""></option>
						<cfloop query="Part"> 
							<option value="#Part.Part_Name#">#Part.Part_Name#</option>
						</cfloop>
				</select>
				<span class="infoLink" onclick="getCtDoc('ctspecimen_part_name',SpecData.part_name.value);">Define</span>
			</td>
		</tr>
	</table>
	<div id="e_biolindiv"></div>
</div>
<cfif listcontainsnocase(client.roles,"coldfusion_user")>
	<div class="secDiv">
		<table class="ssrch">
			<tr>
				<td colspan="2" class="secHead">
						<span class="secLabel">Curatorial</span>
						<span class="secControl" id="c_curatorial"
							onclick="showHide('curatorial',1)">Show More Options</span>
				</td>
			</tr>
			<tr>
				<td class="lbl">
					Barcode:
				</td>
				<td class="srch">
					<input type="text" name="barcode" size="50">
				</td>
			</tr>
		</table>
		<div id="e_curatorial"></div>
	</div>
</cfif>	
<table>
	<tr>
		<td valign="top">
			<input type="submit" value="Search" class="schBtn"
   				onmouseover="this.className='schBtn btnhov'" onmouseout="this.className='schBtn'">
		</td>
		<td valign="top">
			<input type="reset" name="Reset" value="Clear Form" class="clrBtn"
   				onmouseover="this.className='clrBtn btnhov'" onmouseout="this.className='clrBtn'">
		</td>
		<td valign="top" align="right">
			<b>See results as:</b>
		</td>
		<td align="left" colspan="2" valign="top">
			<select name="tgtForm" id="tgtForm" size="1" onChange="changeTarget(this.id,this.value);">
				<option value="">Specimen Records</option>
				<option value="SpecimenResultsHTML.cfm">HTML Specimen Records</option>
				<option  value="/bnhmMaps/bnhmMapData.cfm">BerkeleyMapper Map</option>
				<option value="SpecimenResultsSummary.cfm">Specimen Summary</option>
				<option  value="SpecimenGraph.cfm">Graph</option>
				<cfif isdefined("client.username") AND (#client.username# is "link" OR #client.username# is "dusty")>
				<option  value="/CustomPages/Link.cfm">Link's Form</option>
				</cfif>
				<cfif isdefined("client.username") AND (#client.username# is "cindy" OR #client.username# is "dusty")>
				<option  value="/CustomPages/CindyBats.cfm">Cindy's Form</option>
				</cfif>
			</select>
		</td>
		<td align="left">
			<div id="groupByDiv" style="display:none ">
			<font size="-1"><em><strong>Group by:</strong></em></font><br>
			<select name="groupBy" id="groupBy" multiple size="4" onchange="changeGrp(this.id)">
				<option value="">Scientific Name</option>
				<option value="continent_ocean">Continent</option>
				<option value="country">Country</option>
				<option value="state_prov">State</option>
				<option value="county">County</option>
				<option value="quad">Map Name</option>
				<option value="feature">Feature</option>
				<option value="island">Island</option>
				<option value="island_group">Island Group</option>
				<option value="sea">Sea</option>
				<option value="spec_locality">Specific Locality</option>
				<option value="yr">Year</option>
			</select>
			</div>
		</td>
	</tr>
</table> 
<cfif isdefined("transaction_id") and len(#transaction_id#) gt 0>
	<input type="hidden" name="transaction_id" value="#transaction_id#">
</cfif>
<input type="hidden" name="newQuery" value="1"><!--- pass this to the next form so we clear the cache and run the proper queries--->
</form>
</cfoutput> 
<script type='text/javascript' language='javascript'>
	var tval = document.getElementById('tgtForm').value;
	changeTarget('tgtForm',tval);
	changeGrp('groupBy');
	// make an ajax call to get preferences, then turn stuff on
	DWREngine._execute(_cfscriptLocation, null, 'getSpecSrchPref', r_getSpecSrchPref);
	function r_getSpecSrchPref (result){
		//alert(result);
		var j=result.split(',');
		for (var i = 0; i < j.length; i++) {
			if (j[i].length>0){
				showHide(j[i],1);
				//alert(j[i]);
			}
		}
	}
</script>
<cfinclude template = "includes/_footer.cfm">