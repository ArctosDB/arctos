<cfinclude template="/includes/_header.cfm">
<!----
<cfset obj = CreateObject("component","component.functions")>
<cfset signedURL = obj.googleSignURL(
								urlPath="/maps/api/geocode/json",
								urlParams="latlng=#URLEncodedFormat('#d.DEC_LAT#,#d.DEC_LONG#')#")>
---->
<cfhtmlhead text='<script src="http://maps.googleapis.com/maps/api/js?client=gme-museumofvertebrate1&sensor=false&libraries=places,geometry" type="text/javascript"></script>'>
<script src="/includes/jquery/jquery-autocomplete/jquery.autocomplete.pack.js" language="javascript" type="text/javascript"></script>
<cfset title="Specimen Search">
<cfset metaDesc="Search for museum specimens and observations by taxonomy, identifications, specimen attributes, and usage history.">
<cfoutput>
<cfquery name="getCount" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select count(collection_object_id) as cnt from cataloged_item
</cfquery>
<cfquery name="ctmedia_type" datasource="cf_dbuser" cachedwithin="#createtimespan(0,0,60,0)#">
	select media_type from ctmedia_type order by media_type
</cfquery>
<cfquery name="ctcataloged_item_type" datasource="cf_dbuser" cachedwithin="#createtimespan(0,0,60,0)#">
	select cataloged_item_type from ctcataloged_item_type order by cataloged_item_type
</cfquery>
<cfquery name="hasCanned" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select SEARCH_NAME,URL
	from cf_canned_search,cf_users
	where cf_users.user_id=cf_canned_search.user_id
	and username='#session.username#'
	and URL like '%SpecimenResults.cfm%'
	order by search_name
</cfquery>
<table cellpadding="0" cellspacing="0">
	<tr>
		<td>
			Access to #numberformat(getCount.cnt,",")# records
		</td>
		<cfif hasCanned.recordcount gt 0>
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
				<cfif action is "dispCollObj">
					<p>You are searching for items to add to a loan.</p>
				<cfelseif action is "encumber">
					<p>You are searching for items to encumber.</p>
				<cfelseif action is "collEvent">
					<p>You are searching for items to change collecting event.</p>
				<cfelseif action is "identification">
					<p>You are searching for items to reidentify.</p>
				<cfelseif action is "addAccn">
					<p>You are searching for items to reaccession.</p>
				</cfif>
			</span>
		</td>
	</tr>
</table>
<form method="post" action="SpecimenResults.cfm" name="SpecData" id="SpecData" onSubmit="getFormValues();">
<table>
	<tr>
		<td valign="top">
			<input type="submit" value="Search" class="schBtn">
		</td>
		<td valign="top">
			<input type="button" name="Reset" value="Clear Form" class="clrBtn" onclick="resetSSForm();">
		</td>
		<td valign="top">
			<input type="button" name="Previous" value="Use Last Values" class="lnkBtn"	onclick="setPrevSearch()">
		</td>
		<td align="right" valign="top">
			&nbsp;&nbsp;&nbsp;See&nbsp;results&nbsp;as:
		</td>
		<td valign="top">
		 	<select name="tgtForm1" id="tgtForm1" size="1"  onChange="changeTarget(this.id,this.value);">
				<option value="">Specimen Records</option>
				<option value="SpecimenResultsHTML.cfm">HTML Specimen Records</option>
				<option  value="/bnhmMaps/bnhmMapData.cfm">BerkeleyMapper Map</option>
				<option  value="/bnhmMaps/kml.cfm?action=newReq">KML</option>
				<option value="SpecimenResultsSummary.cfm">Specimen Summary</option>
				<option  value="SpecimenGraph.cfm">Graph</option>
			</select>
		</td>
		<td align="left">
			<div id="groupByDiv1" style="display:none;border:1px solid green;padding:.5em;">
				<font size="-1"><em><strong>Group by:</strong></em></font><br>
				<select name="groupBy1" id="groupBy1" multiple size="4" onchange="changeGrp(this.id)">
					<option value="kingdom">Kingdom</option>
					<option value="phylum">Phylum</option>
					<option value="phylclass">Class</option>
					<option value="phylorder">Order</option>
					<option value="family">Family</option>
					<option value="genus">Genus</option>
					<option value="scientific_name">Scientific Name</option>
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
					<option value="year">Year</option>
				</select>
			</div>
			<div id="kmlDiv1" style="display:none;border:1px solid green;padding:.5em;">
				<font size="-1"><em><strong>KML Options:</strong></em></font><br>
				<label for="next1">Color By</label>
				<select name="next1" id="next1" onchange="kmlSync(this.id,this.value)">
					<option value="colorByCollection">Collection</option>
					<option value="colorBySpecies">Species</option>
				</select>
				<label for="method1">Method</label>
				<select name="method1"  id="method1" onchange="kmlSync(this.id,this.value)">
					<option value="download">Download</option>
					<option value="link">Download Linkfile</option>
					<option value="gmap">Google Maps</option>
				</select>
				<label for="includeTimeSpan1">include Time?</label>
				<select name="includeTimeSpan1"  id="includeTimeSpan1" onchange="kmlSync(this.id,this.value)">
					<option value="0">no</option>
					<option value="1">yes</option>
				</select>
				<label for="showErrors1">Show error radii?</label>
				<select  name="showErrors1" id="showErrors1" onchange="kmlSync(this.id,this.value)">
					<option value="0">no</option>
					<option value="1">yes</option>
				</select>
			</div>
		</td>
	</tr>
</table>
<div>
	&nbsp;&nbsp;&nbsp;<span class="helpLink" id="_cataloged_item_type">Type</span>:<select name="cataloged_item_type" id="cataloged_item_type" size="1">
	<option value="">any</option>
		<cfloop query="ctcataloged_item_type">
			<option value="#ctcataloged_item_type.cataloged_item_type#">#ctcataloged_item_type.cataloged_item_type#</option>
		</cfloop>
	</select>
	&nbsp;&nbsp;&nbsp;<span class="helpLink" id="_is_tissue">Require&nbsp;Tissues?</span><input type="checkbox" name="is_tissue" id="is_tissue" value="1">
</div>
<input type="hidden" name="Action" value="#Action#">
<div class="secDiv">
	<cfquery name="ctInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT institution_acronym, collection, collection_id FROM collection order by collection
	</cfquery>
	<cfif isdefined("collection_id") and len(collection_id) gt 0>
		<cfset thisCollId = collection_id>
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
				<select name="collection_id" id="collection_id" size="3" multiple="multiple">
					<cfloop query="ctInst">
						<option <cfif thisCollId is ctInst.collection_id>selected="selected" </cfif>value="#ctInst.collection_id#">#ctInst.collection#</option>
					</cfloop>
				</select>
				<span class="helpLink" id="cat_num">Catalog Number:</span>
				<cfif #ListContains(session.searchBy, 'bigsearchbox')# gt 0>
					<textarea name="listcatnum" id="listcatnum" rows="6" cols="40" wrap="soft"></textarea>
				<cfelse>
					<input type="text" name="listcatnum" id="listcatnum" size="21" value="">
				</cfif>
			</td>
		</tr>
	<cfif isdefined("session.CustomOtherIdentifier") and len(session.CustomOtherIdentifier) gt 0>
		<tr>
			<td class="lbl">
				<span class="helpLink" id="custom_identifier">#replace(session.CustomOtherIdentifier," ","&nbsp;","all")#:</span>
			</td>
			<td class="srch">
				<cfif isdefined("session.CustomOidOper")>
					<cfset thisSelected=session.CustomOidOper>
				<cfelse>
					<cfset thisSelected="IS">
				</cfif>
				<label for="CustomOidOper">Display Value</label>
				<select name="CustomOidOper" id="CustomOidOper" size="1" onchange="setSessionCustomID(this.value);">
					<option value="IS" <cfif thisSelected is "IS"> selected="selected"</cfif>>is</option>
					<option value="" <cfif thisSelected is ""> selected="selected"</cfif>>contains</option>
					<option value="LIST"<cfif thisSelected is "LIST"> selected="selected"</cfif>>in list</option>
					<option value="BETWEEN"<cfif thisSelected is "BETWEEN"> selected="selected"</cfif>>in range</option>
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
			<!----
			<td class="lbl">
				<span class="helpLink" id="_any_taxa_term">Any Taxonomic Element:</span>
			</td>
			<td class="srch">
				<input type="text" name="any_taxa_term" id="any_taxa_term" size="50">
			</td>
			---->
			<td class="lbl">
				<span class="helpLink" id="_scientific_name">Identification</span>
			</td>
			<td class="srch">
				<table style="border:1px solid green;">
					<tr>
						<td>
							<input type="text" name="scientific_name" id="scientific_name" size="50" placeholder="Identification (scientific name)">
						</td>
					</tr>
					<tr>
						<td>
							<table width="100%">
								<tr>
									<td width="50%">
										<label for="scientific_name_scope">Include previous IDs?</label>
										<select name="scientific_name_scope" id="scientific_name_scope">
											<option value="currentID">Current ID only</option>
											<option value="allID">Include all IDs</option>
										</select>
									</td>
									<td>
										<label for="scientific_name_match_type">Match Type</label>
										<select name="scientific_name_match_type" id="scientific_name_match_type">
											<option value="contains">contains</option>
											<option value="exact">is (case insensitive)</option>
											<option value="notcontains">does not contain</option>
											<option value="inlist">comma-list</option>
										</select>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	<div id="e_taxonomy"></div>
</div>
	<!---

<div class="secDiv">
	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
				<span class="secLabel">Spatial Query</span>
				<span class="secControl" id="c_spatial_query" onclick="showHide('spatial_query',1)">Show More Options</span>
			</td>
		</tr>
		<tr>
			<td colspan="2">
			</td>
		</tr>
	</table>

</div>
	--->


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
				<span class="secControl" style="font-size:.9em;" id="c_spatial_query" onclick="showHide('spatial_query',1)">Select on Google Map</span>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<div id="e_spatial_query"></div>
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
				<span class="helpLink infoLink" id="collector">Help</span>
				<select name="coll_role" id="coll_role" size="1">
					<option value="" selected="selected">Collector or Preparator</option>
					<option value="c" >Collector</option>
					<option value="p">Preparator</option>
				</select>
			</td>
			<td class="srch">
				<input type="text" name="coll" id="coll" size="50">
			</td>
		</tr>
	</table>
	<div id="e_collevent"></div>
</div>
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
				<input type="text" name="partname" id="partname">
				<span class="infoLink" onclick="getCtDoc('ctspecimen_part_name',SpecData.partname.value);">Define</span>
				<span class="infoLink" onclick="var e=document.getElementById('partname');e.value='='+e.value;">Add = for exact match</span>
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
				<cfquery name="ctTypeStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
<div class="secDiv">
	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
				<span class="secLabel">Media</span>
				<span class="secControl" id="c_media" onclick="showHide('media',1)">Show More Options</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				<span class="helpLink" id="_media_type">Media Type:</span>
			</td>
			<td class="srch">
				<select name="media_type" id="media_type" size="1">
					<option value=""></option>
	                <option value="any">Any</option>
					<cfloop query="ctmedia_type">
						<option value="#ctmedia_type.media_type#">#ctmedia_type.media_type#</option>
					</cfloop>
				</select>
				<span class="infoLink" onclick="getCtDoc('ctmedia_type', SpecData.media_type.value);">Define</span>
			</td>
		</tr>
	</table>
	<div id="e_media"></div>
</div>

<cfquery name="ctid_references" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select id_references from ctid_references where id_references != 'self' order by id_references
</cfquery>

<div class="secDiv">
	<table class="ssrch">
		<tr>
			<td colspan="2" class="secHead">
				<span class="secLabel">Relationships</span>
				<span class="secControl" id="c_relationships" onclick="showHide('relationships',1)">Show More Options</span>
			</td>
		</tr>

		<tr>
			<td class="lbl">
				<span class="helpLink" id="id_references">Relationship:</span>
			</td>
			<td class="srch">
				<select name="id_references" id="id_references" size="1">
					<option value=""></option>
					<cfloop query="ctid_references">
						<option value="#ctid_references.id_references#">#ctid_references.id_references#</option>
					</cfloop>
				</select>
			</td>
		</tr>



	</table>
	<div id="e_relationships"></div>
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
					<span class="helpLink" id="srch_barcode">Part Barcode:</span>
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
			<input type="submit" value="Search" class="schBtn">
		</td>
		<td valign="top">
			<input type="button" name="Reset" value="Clear Form" class="clrBtn" onclick="resetSSForm();">
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
				<option  value="/bnhmMaps/kml.cfm?action=newReq">KML</option>
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
			<div id="groupByDiv" style="display:none;border:1px solid green;padding:.5em;">
			<font size="-1"><em><strong>Group by:</strong></em></font><br>
			<select name="groupBy" id="groupBy" multiple size="4" onchange="changeGrp(this.id)">
				<option value="kingdom">Kingdom</option>
				<option value="phylum">Phylum</option>
				<option value="phylclass">Class</option>
				<option value="phylorder">Order</option>
				<option value="family">Family</option>
				<option value="genus">Genus</option>
				<option value="scientific_name">Scientific Name</option>
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
				<option value="year">Year</option>
			</select>
			</div>
			<div id="kmlDiv" style="display:none;border:1px solid green;padding:.5em;">
				<font size="-1"><em><strong>KML Options:</strong></em></font><br>
				<label for="next">Color By</label>
				<select name="next" id="next" onchange="kmlSync(this.id,this.value)">
					<option value="colorByCollection">Collection</option>
					<option value="colorBySpecies">Species</option>
				</select>
				<label for="method">Method</label>
				<select name="method" id="method" onchange="kmlSync(this.id,this.value)">
					<option value="download">Download</option>
					<option value="link">Download Linkfile</option>
					<option value="gmap">Google Maps</option>
				</select>
				<label for="includeTimeSpan">include Time?</label>
				<select name="includeTimeSpan" id="includeTimeSpan" onchange="kmlSync(this.id,this.value)">
					<option value="0">no</option>
					<option value="1">yes</option>
				</select>
				<label for="showErrors">Show error radii?</label>
				<select name="showErrors" id="showErrors" onchange="kmlSync(this.id,this.value)">
					<option value="0">no</option>
					<option value="1">yes</option>
				</select>
			</div>
		</td>
	</tr>
</table>
<cfif isdefined("transaction_id") and len(transaction_id) gt 0>
	<input type="hidden" name="transaction_id" value="#transaction_id#">
</cfif>
<input type="hidden" name="newQuery" value="1">
</form>
</cfoutput>
<script type='text/javascript' language='javascript'>
	function setSessionCustomID(v) {
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "setSessionCustomID",
				val : v,
				returnformat : "json",
				queryformat : 'column'
			},
			function (getResult) {}
		
		);
	}

	jQuery(document).ready(function() {
	  	var tval = document.getElementById('tgtForm').value;
		changeTarget('tgtForm',tval);
		changeGrp('groupBy');
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "getSpecSrchPref",
				returnformat : "json",
				queryformat : 'column'
			},
			function (getResult) {
				if (getResult == "cookie") {
					var cookie = readCookie("specsrchprefs");
					if (cookie != null) {
						r_getSpecSrchPref(cookie);
					}
				}
				else
					r_getSpecSrchPref(getResult);
			}
		);

			jQuery.get("/form/browse.cfm", function(data){
				 jQuery('body').append(data);
			})

	});
	jQuery("#partname").autocomplete("/ajax/part_name.cfm", {
		width: 320,
		max: 50,
		autofill: false,
		multiple: false,
		scroll: true,
		scrollHeight: 300,
		matchContains: true,
		minChars: 1,
		selectFirst:false
	});
	function resetSSForm(){
		document.getElementById('SpecData').reset();
		try {
			initialize();
		} catch(e){}
	}
	function r_getSpecSrchPref (result){
		var j=result.split(',');
		for (var i = 0; i < j.length; i++) {
			if (j[i].length>0){
				showHide(j[i],1);
			}
		}
	}
	function kmlSync(tid,tval) {
		var rMostChar=tid.substr(tid.length -1,1);
		if (rMostChar=='1'){
			theOtherField=tid.substr(0,tid.length -1);
		} else {
			theOtherField=tid + '1';
		}
		document.getElementById(theOtherField).value=tval;
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
		for (i = 0; i < len; i++) {
			sList.options[i].selected = false;
		}
		for (i = 0; i < len; i++) {
			if (mList.options[i].selected) {
				sList.options[i].selected = true;
			}
		}
	}
	function changeTarget(id,tvalue) {
		if(tvalue.length == 0) {
			tvalue='SpecimenResults.cfm';
		}
		if (id =='tgtForm1') {
			var otherForm = document.getElementById('tgtForm');
		} else {
			var otherForm = document.getElementById('tgtForm1');
		}
		otherForm.value=tvalue;
		document.getElementById('groupByDiv').style.display='none';
		document.getElementById('groupByDiv1').style.display='none';
		document.getElementById('kmlDiv').style.display='none';
		document.getElementById('kmlDiv1').style.display='none';
		if (tvalue == 'SpecimenResultsSummary.cfm') {
			document.getElementById('groupByDiv').style.display='';
			document.getElementById('groupByDiv1').style.display='';
		} else if (tvalue=='/bnhmMaps/kml.cfm?action=newReq') {
			document.getElementById('kmlDiv').style.display='';
			document.getElementById('kmlDiv1').style.display='';
		}
		document.SpecData.action = tvalue;
	}
	function setPrevSearch(){
		var schParam=get_cookie ('schParams');
		var pAry=schParam.split("|");
	 	for (var i=0; i<pAry.length; i++) {
	 		var eAry=pAry[i].split("::");
	 		var eName=eAry[0];
	 		var eVl=eAry[1];
	 		if (document.getElementById(eName)){
				document.getElementById(eName).value=eVl;
				if (eName=='tgtForm' && (eVl=='/bnhmMaps/kml.cfm?action=newReq' || eVl=='SpecimenResultsSummary.cfm')) {
					changeTarget(eName,eVl);
				}
			}
	 	}
	 	try {
			setPreviousMap();
		} catch(e){}
	}
</script>
<cfinclude template = "includes/_footer.cfm">