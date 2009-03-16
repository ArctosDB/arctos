<cfinclude template="/includes/_header.cfm">
<cfset title="Specimen Search">
<script type='text/javascript' src='/includes/jquery/jquery.js'></script>
<script type='text/javascript' src='/includes/jquery/suggest.js'></script>
<script type='text/javascript' src='/includes/SpecSearch/jqLoad.js'></script>
<cfoutput>	
<cfquery name="getCount" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select count(collection_object_id) as cnt from cataloged_item
</cfquery>
<cfquery name="hasCanned" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select SEARCH_NAME,URL
	from cf_canned_search,cf_users
	where cf_users.user_id=cf_canned_search.user_id
	and username='#session.username#'
	order by search_name
</cfquery>
<table cellpadding="0" cellspacing="0">
	<tr>
		<td>
			Access to #getCount.cnt# records.
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
<cfform method="post" action="SpecimenResults.cfm" name="SpecData" id="SpecData" onSubmit="getFormValues()">
<table border="0">
	<tr>
		<td valign="top">
			<input type="submit" value="Search" class="schBtn" onmouseover="this.className='schBtn btnhov'" onmouseout="this.className='schBtn'">
		</td>
		<td valign="top">
			<input type="reset" name="Reset" value="Clear Form" class="clrBtn"	onmouseover="this.className='clrBtn btnhov'" onmouseout="this.className='clrBtn'">
		</td>
		<td valign="top">
			<input type="button" name="Previous" value="Use Last Values" class="lnkBtn"	onclick="setPrevSearch()">
		</td>
		<td align="right" valign="top">
			<b>See&nbsp;results&nbsp;as:</b>
		</td>
		<td valign="top">
		 	<select name="tgtForm1" id="tgtForm1" size="1"  onChange="changeTarget(this.id,this.value);">
				<option value="">Specimen Records</option>
				<option value="SpecimenResultsHTML.cfm">HTML Specimen Records</option>
				<option  value="/bnhmMaps/bnhmMapData.cfm">BerkeleyMapper Map</option>
				<option value="SpecimenResultsSummary.cfm">Specimen Summary</option>
				<option  value="SpecimenGraph.cfm">Graph</option>
				<cfif isdefined("session.username") AND (#session.username# is "link" OR #session.username# is "dusty")>
					<option  value="/CustomPages/Link.cfm">Link's Form</option>
				</cfif>
				<cfif isdefined("session.username") AND (#session.username# is "cindy" OR #session.username# is "dusty")>
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
		<td>
			Show&nbsp;<span class="helpLink" id="observations">Observations?</span>
			<input type="checkbox" name="showObservations" id="showObservations" value="1" onchange="changeshowObservations(this.checked);"<cfif #session.showObservations# eq 1> checked="checked" </cfif>>
		</td>
		<td>
			<span class="helpLink" id="_is_tissue">Tissues?</span>
			<input type="checkbox" name="is_tissue" id="is_tissue" value="1">
		</td>
	</tr>
</table>
<input type="hidden" name="Action" value="#Action#">
<div class="secDiv">
	<cfquery name="ctInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT institution_acronym, collection, collection_id FROM collection order by collection
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
				<span class="secControl" id="c_identifiers"	onclick="showHide('identifiers',1)">Show More Options</span>
				<span class="secControl" id="c_identifiers_cust">Customize</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				<span class="helpLink" id="collection">Collection</span>:
			</td>
			<td class="srch">
				<select name="collection_id" id="collection_id" size="1">
						<option value="">All</option>
					<cfloop query="ctInst">
						<option <cfif #thisCollId# is #ctInst.collection_id#>
					 		selected </cfif>
							value="#ctInst.collection_id#">
							#ctInst.collection#</option>
					</cfloop>
				</select>
				<span class="helpLink" id="cat_num">Number:</span>
				<cfif #ListContains(session.searchBy, 'bigsearchbox')# gt 0>
					<textarea name="listcatnum" id="listcatnum" rows="6" cols="40" wrap="soft"></textarea>
				<cfelse>
					<input type="text" name="listcatnum" id="listcatnum" size="21" value="">
				</cfif>			
			</td>
		</tr>
	<cfif isdefined("session.CustomOtherIdentifier") and len(#session.CustomOtherIdentifier#) gt 0>
		<tr>
			<td class="lbl">
				<span class="helpLink" id="custom_identifier">#replace(session.CustomOtherIdentifier," ","&nbsp;","all")#:</span>
			</td>
			<td class="srch">
				<label for="CustomOidOper">Display Value</label>
				<select name="CustomOidOper" id="CustomOidOper" size="1">
					<option value="IS">is</option>
					<option value="" selected="selected">contains</option>
					<option value="LIST">in list</option>
					<option value="BETWEEN">in range</option>								
				</select>&nbsp;<input type="text" name="CustomIdentifierValue" id="CustomIdentifierValue" size="50">
			</td>
		</tr>
		<tr>
		<td class="lbl">
			<cfif isdefined("session.fancyCOID") and #session.fancyCOID# is 1>
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
				<span class="secControl" id="c_taxonomy" onclick="showHide('taxonomy',1)">Show More Options</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				<span class="helpLink" id="_any_taxa_term">Any Taxonomic Element:</span>
			</td>
			<td class="srch">
				<input type="text" name="any_taxa_term" id="any_taxa_term" size="50">
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
				<span class="secControl" id="c_locality" onclick="showHide('locality',1)">Show More Options</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				<span class="helpLink" id="any_geog_term">Any&nbsp;Geographic&nbsp;Element:</span>
			</td>
			<td class="srch">
				<input type="text" name="any_geog" id="any_geog" size="50">
			</td>
		</tr>
	</table>
	<div id="e_locality"></div>
</div>
<div class="secDiv">
	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
				<span class="secLabel">Date/Collector</span>
				<span class="secControl" id="c_collevent" onclick="showHide('collevent',1)">Show More Options</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				<span class="helpLink" id="year_collected">Year Collected:</span>
			</td>
			<td class="srch">
				<input name="begYear" id="begYear" type="text" size="6">&nbsp;
				<span class="infoLink" onclick="SpecData.endYear.value=SpecData.begYear.value">-->&nbsp;Copy&nbsp;--></span>
				&nbsp;<input name="endYear" id="endYear" type="text" size="6">
			</td>
		</tr>
	</table>
	<div id="e_collevent"></div>
</div>
<cfquery name="Part" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select part_name from 
		ctspecimen_part_name
	group by part_name order by part_name
</cfquery>
<!--- no values messes with cfsuggest --->
<cfset partlist=#valuelist(Part.part_name,"\")#>
<cfif len(partlist) is 0>
	<cfset partlist="--empty--">
</cfif>
<div class="secDiv">
	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
				<span class="secLabel">Biological Individual</span>
				<span class="secControl" id="c_biolindiv" onclick="showHide('biolindiv',1)">Show More Options</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				<span class="helpLink" id="part_name">Part Name:</span>
			</td>
			<td class="srch">
				<cfinput type="text" autosuggest="#partlist#" name="partname" id="partname" delimiter="\">
				<span class="infoLink" onclick="getCtDoc('ctspecimen_part_name',SpecData.partname.value);">Define</span>
			</td>
		</tr>
	</table>
	<div id="e_biolindiv"></div>
</div>
<div class="secDiv">
	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
				<span class="secLabel">Usage</span>
				<span class="secControl" id="c_usage" onclick="showHide('usage',1)">Show More Options</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				<span class="helpLink" id="_type_status">Basis of Citation:</span>
			</td>
			<td class="srch">
				<cfquery name="ctTypeStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select type_status from ctcitation_type_status
				</cfquery>
				<select name="type_status" id="type_status" size="1">
					<option value=""></option>
					<option value="any">Any</option>
					<option value="type">Any TYPE</option>
					<cfloop query="ctTypeStatus">
						<option value="#ctTypeStatus.type_status#">#ctTypeStatus.type_status#</option>
					</cfloop>
				</select>
				<span class="infoLink" onclick="getCtDoc('ctcitation_type_status', SpecData.type_status.value);">Define</span>	
			</td>
		</tr>
	</table>
	<div id="e_usage"></div>
</div>
<cfif listcontainsnocase(session.roles,"coldfusion_user")>
	<div class="secDiv">
		<table class="ssrch">
			<tr>
				<td colspan="2" class="secHead">
					<span class="secLabel">Curatorial</span>
					<span class="secControl" id="c_curatorial" onclick="showHide('curatorial',1)">Show More Options</span>
				</td>
			</tr>
			<tr>
				<td class="lbl">
					Barcode:
				</td>
				<td class="srch">
					<input type="text" name="barcode" id="barcode" size="50">
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
		<td valign="top">
			<input type="button" name="Previous" value="Use Last Values" class="lnkBtn"	onclick="setPrevSearch()">
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
				<cfif isdefined("session.username") AND (#session.username# is "link" OR #session.username# is "dusty")>
				<option  value="/CustomPages/Link.cfm">Link's Form</option>
				</cfif>
				<cfif isdefined("session.username") AND (#session.username# is "cindy" OR #session.username# is "dusty")>
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
</cfform>
</cfoutput> 
<script type='text/javascript' language='javascript'>
	var tval = document.getElementById('tgtForm').value;
	changeTarget('tgtForm',tval);
	changeGrp('groupBy');
	// make an ajax call to get preferences, then turn stuff on
	DWREngine._execute(_cfscriptLocation, null, 'getSpecSrchPref', getComplete);
	function getComplete (getResult) {
		if (getResult == "cookie") {
			var cookie = readCookie("specsrchprefs");
			if (cookie != null) {
				r_getSpecSrchPref(cookie);
			}
			//else cookie does not exist = nothing to turn on
		}
		else
			r_getSpecSrchPref(getResult);
	}
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
	// for the stuff that's already here...
</script>
<cfinclude template = "includes/_footer.cfm">