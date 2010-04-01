<cfinclude template="includes/_header.cfm">
<script>
	function change_all() {
		var p = document.getElementById('part_names').value;
		var t = document.getElementById('is_tiss').value;
		//alert('turn ' + p + ' to ' + t);
		allChecks=document.getElementsByTagName('input');
 for(i in allChecks)
 {
  	var thisId = allChecks[i].id;
  	//id="#part_name#_#part_id#"
  	var thisType = 'is_tissue_' + p;
  	//alert(thisId);
  	var isThere = thisId.indexOf(thisType);
  	//alert(isThere);
  	if (isThere > -1) {
  		var thisElementStr = "document.getElementById('" + allChecks[i].id + "')";
  		var thisElement=eval(thisElementStr);
		if (t=="true") {
			thisElement.checked=true;
		} else {
			thisElement.checked=false;
		}
		
  		//alert('yep');
  	}
}
	}
</script>
<!---
<!--- no security --->
--->
<cfquery name="ctcoll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection_cde from ctcollection_cde
</cfquery>
<cfquery name="ctStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select accn_status from ctaccn_status
</cfquery>
<cfquery name="ctType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select accn_type from ctaccn_type
</cfquery>
<cfquery name="ctPermitType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from ctpermit_type
</cfquery>
<cfquery name="ctInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct(institution_acronym)  from collection
</cfquery>
<!-------------------------------------------------------------------->
<cfif #Action# is "nothing">
	<cfoutput>
	<cfset title="Make Tissues">
		<cfquery name="specData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT
				cataloged_item.collection_object_id,
				collection.institution_acronym,
				collection.collection_cde,
				cat_num,
				accn_number,
				scientific_name,
				specimen_part.COLLECTION_OBJECT_ID part_id,
				decode(SAMPLED_FROM_OBJ_ID,
					NULL, PART_NAME,
					part_name || ' sample') part_name,
				IS_TISSUE 
			FROM
				cataloged_item,
				collection,
				identification,
				accn,
				specimen_part
			WHERE
				cataloged_item.collection_id = collection.collection_id AND
				cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
				cataloged_item.collection_id = collection.collection_id AND
				cataloged_item.accn_id = accn.transaction_id AND
				cataloged_item.collection_object_id = identification.collection_object_id AND
				cataloged_item.collection_object_id IN (#collection_object_id#)
		</cfquery>
		<cfquery name="dSpecData" dbtype="query">
			select 
				collection_object_id,
				institution_acronym,
				collection_cde,
				cat_num,
				accn_number,
				scientific_name
			FROM
				specData
			GROUP BY
				collection_object_id,
				institution_acronym,
				collection_cde,
				cat_num,
				accn_number,
				scientific_name
		</cfquery>
		<cfquery name="distPartList" dbtype="query">
			select part_name from specData group by part_name
		</cfquery>
		Flag parts as tissues. You cannot use this form to UNflag tissues; use the links to specimens instead.
		<br>
		<form name="m">
		Change all: <select name="part_names" id="part_names" >
			<option value=""></option>
			<cfloop query="distPartList">
				<option value="#part_name#">#part_name#</option>
			</cfloop>
		</select>
		to:
		<select name="is_tiss" id="is_tiss">
			<option value="true">tissues</option>
			<option value="false">not tissues</option>
		</select>
		<input type="button" value="go" onclick="change_all();" class="lnkBtn"
   					onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	
		</form>
		<table border>
			<tr>
				<td>Catalog Number</td>
				<td>Scientific Name</td>
				<td>Accession</td>
				<td>Parts</td>
			</tr>
			<form name="ptt" method="post" action="tissueParts.cfm">
			<input type="hidden" name="action" value="saveChange">
			<cfloop query="dSpecData">
				<cfquery name="partData" dbtype="query">
					select 
						part_id,
						part_name,
						IS_TISSUE 
					FROM
						specData
					WHERE
						collection_object_id = #collection_object_id#
				</cfquery>
				<tr>
					<td valign="top"><a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">
						#institution_acronym# #collection_cde# #cat_num#</a></td>
					<td valign="top">#scientific_name#</td>
					<td valign="top">#accn_number#</td>
					<td valign="top">
						<table border="0" width="100%">
							<cfloop query="partData">
								<tr>
									<td>
										#part_name# 
									</td>
									<td align="right">
										Tiss? <input type="checkbox" 
											name="is_tissue" 
											id="is_tissue_#part_name#_#part_id#"
											value="#part_id#" 
											<cfif #IS_TISSUE# is 1> checked="checked" </cfif>>
									</td>
								</tr>
							</cfloop>
						</table>
					</td>
				</tr>
			</cfloop>
		</table>
		<input type="submit" value="Save Tissues Flags" class="savBtn"
   					onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">
		</form>
	</cfoutput>
	
</cfif>
<cfif #action# is "saveChange">
	<cfoutput>
		<cfquery name="upPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update specimen_part set is_tissue=1 where collection_object_id IN (#is_tissue#)
		</cfquery>
		All spiffy, go away now....
	</cfoutput>
</cfif>
<cfinclude template="includes/_footer.cfm">