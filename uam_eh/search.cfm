<cfinclude template="/includes/_header.cfm">
<cfset title="Specimen Search: UAM:EH">
<cfset metaDesc="Search for museum specimens and observations by taxonomy, identifications, specimen attributes, and usage history.">
<cfoutput>
<cfquery name="getCount" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select count(cataloged_item.collection_object_id) as cnt from cataloged_item,filtered_flat where
			cataloged_item.collection_object_id=filtered_flat.collection_object_id
			and filtered_flat.guid_prefix like 'UAM:EH%'
</cfquery>
<table cellpadding="0" cellspacing="0">
	<tr>
		<td>
			Access to #numberformat(getCount.cnt,",")# records
			<div>
				<a href="/all_all.cfm">Search all of Arctos</a>
			</div>
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
	</tr>
</table>
<input type="hidden" name="action" value="#action#">
<div class="secDiv">
	<table class="ssrch">
		<tr>
			<td class="lbl">
				<span class="helpLink" id="cat_num">Catalog&nbsp;Number:</span>
			</td>
			<td class="srch">
				<input type="text" name="listcatnum" id="listcatnum" size="50" value="">
			</td>
		</tr>
		<tr>
			<td class="lbl">
				<span class="helpLink" id="_accn_number">Accession:</span>
			</td>
			<td class="srch">
				<input type="text" name="accn_number" id="accn_number">
				<span class="infoLink" onclick="var e=document.getElementById('accn_number');e.value='='+e.value;">Add = for exact match</span>
			</td>
		</tr>

		<tr>
			<td class="lbl">
				<span class="helpLink" id="_scientific_name">Identification/Object Type</span>
			</td>
			<td class="srch">
				<table style="border:1px solid green;">
					<tr>
						<td>
							<input type="text" name="scientific_name" id="scientific_name" size="50" placeholder="Identification (scientific name)">
							<input type="hidden" name="scientific_name_match_type" id="scientific_name_match_type" value="contains">
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				<span class="helpLink" id="_any_geog">Any&nbsp;Geographic&nbsp;Element:</span>
			</td>
			<td class="srch">
				<input type="text" name="any_geog" id="any_geog" size="50">
				<span class="secControl" style="font-size:.9em;" id="c_spatial_query" onclick="showHide('spatial_query',1)">Select on Google Map</span>
			</td>
		</tr>
		<tr>
			<td class="lbl">
				<span class="helpLink" id="_spec_locality">Specific&nbsp;Locality:</span>
			</td>
			<td class="srch">
				<input type="text" name="spec_locality" id="spec_locality" size="50">
				<span class="infoLink" onclick="var e=document.getElementById('spec_locality');e.value='='+e.value;">Add = for exact match</span>
				<span class="infoLink" onclick="document.getElementById('spec_locality').value='NULL';">[ NULL ]</span>
			</td>
		</tr>

		<cfquery name="ctcollector_role" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select collector_role from ctcollector_role order by collector_role
		</cfquery>
		<tr>
			<td class="lbl">
				<span class="helpLink infoLink" id="collector">Help</span>
				<select name="coll_role" id="coll_role" size="1">
					<option value="" selected="selected">Agent Role</option>
					<cfloop query="ctcollector_role">
						<option value="#ctcollector_role.collector_role#">#ctcollector_role.collector_role#</option>
					</cfloop>
				</select>
				<span class="infoLink" onclick="getCtDoc('ctcollector_role',SpecData.coll_role.value);">Define</span>
			</td>
			<td class="srch">
				<input type="text" name="coll" id="coll" size="50">
			</td>
		</tr>
		<tr>
			<td class="lbl">
				<span class="helpLink infoLink" id="_culture_of_origin">Help</span>
				Culture of Origin
			</td>
			<td class="srch">
				<input type="text" name="culture_of_origin" id="culture_of_origin" size="50">
			</td>
		</tr>






</table>

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
	</tr>
</table>
<input type="hidden" name="newQuery" value="1">
</form>
</cfoutput>
<script type='text/javascript' language='javascript'>
	$(document).ready(function() {
	  	var tval = document.getElementById('tgtForm').value;
		changeTarget('tgtForm',tval);
		//changeGrp('groupBy');
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
				} else {
					r_getSpecSrchPref(getResult);
				}
			}
		);
		jQuery.get("/form/browse.cfm", function(data){
			 jQuery('body').append(data);
		})
		$("#guid_prefix").multiselect({
			minWidth: "500",
			height: "300"
		});
		$("#groupBy").multiselect({
			//minWidth: "500",
			//height: "300"
		});

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
</script>
<cfinclude template = "includes/_footer.cfm">