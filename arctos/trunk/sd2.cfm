<style type="text/css" media="all">
	@import "/includes/tabs.css";
</style>
<cfif not isdefined("content_url")>
		<cfset content_url = "SpecimenDetail_body.cfm">
</cfif>
<cfinclude template = "includes/_header.cfm">

				


<cfset detSelect = "
	SELECT DISTINCT
		institution_acronym,
		cataloged_item.cat_num,
		cataloged_item.collection_object_id as collection_object_id,
		cataloged_item.collection_cde,
		identification.scientific_name,
		continent_ocean,
		country,
		collecting_event.collecting_event_id,
		state_prov,
		quad,
		county,
		island,
		island_group,
		spec_locality,
		verbatim_date,
		BEGAN_DATE,
		ended_date,
		sea,
		feature,
		other_id_type,
		other_id_num,
		concatparts(cataloged_item.collection_object_id) partString,
		concatEncumbrances(cataloged_item.collection_object_id) encumbrance_action,
		dec_lat,
		dec_long,
		to_number(af_num) af_num
	FROM 
		collection,
		cataloged_item,
		identification,
		collecting_event,
		locality,
		geog_auth_rec,
		Coll_object,
		coll_obj_other_id_num,
		accepted_lat_long,
		af_num
	WHERE 
		cataloged_item.collection_id = collection.collection_id AND
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		collecting_event.locality_id = locality.locality_id  AND
		Cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		cataloged_item.collection_object_id = identification.collection_object_id AND
		identification.accepted_id_fg = 1 AND
		coll_object.collection_object_id = cataloged_item.collection_object_id AND
		cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id (+) AND
		locality.locality_id = accepted_lat_long.locality_id (+) AND
		cataloged_item.collection_object_id =  af_num.collection_object_id (+) AND
		cataloged_item.collection_object_id = #collection_object_id#
	ORDER BY
		cat_num">

<cfquery name="detail" datasource = "#Application.web_user#">
	#preservesinglequotes(detSelect)#
</cfquery>

<cfoutput>
	<script type="text/javascript" language="javascript">
		changeStyle('#detail.institution_acronym#');
		// set this as a variable
		var thisStyle = '#detail.institution_acronym#';
		// define stylesheet
		parent.window.document.title = "#detail.institution_acronym# #detail.collection_cde# #detail.cat_num#";
	</script>
</cfoutput>
<cfoutput query="detail" group="cat_num">
<cfset hg="">
				<cfif len(#continent_ocean#) gt 0>
					<cfif len(#hg#) gt 0>
						<cfset hg="#hg#, #continent_ocean#">
					<cfelse>
						<cfset hg="#continent_ocean#">
					</cfif>
				</cfif>
				<cfif len(#sea#) gt 0>
					<cfif len(#hg#) gt 0>
						<cfset hg="#hg#, #sea#">
					<cfelse>
						<cfset hg="#sea#">
					</cfif>
				</cfif>
				<cfif len(#country#) gt 0>
					<cfif len(#hg#) gt 0>
						<cfset hg="#hg#, #country#">
					<cfelse>
						<cfset hg="#country#">
					</cfif>
				</cfif>
				<cfif len(#state_prov#) gt 0>
					<cfif len(#hg#) gt 0>
						<cfset hg="#hg#, #state_prov#">
					<cfelse>
						<cfset hg="#state_prov#">
					</cfif>
				</cfif>
				<cfif len(#feature#) gt 0>
					<cfif len(#hg#) gt 0>
						<cfset hg="#hg#, #feature#">
					<cfelse>
						<cfset hg="#feature#">
					</cfif>
				</cfif>
				<cfif len(#county#) gt 0>
					<cfif len(#hg#) gt 0>
						<cfset hg="#hg#, #county#">
					<cfelse>
						<cfset hg="#county#">
					</cfif>
				</cfif>
				<cfif len(#island_group#) gt 0>
					<cfif len(#hg#) gt 0>
						<cfset hg="#hg#, #island_group#">
					<cfelse>
						<cfset hg="#island_group#">
					</cfif>
				</cfif>
				<cfif len(#island#) gt 0>
					<cfif len(#hg#) gt 0>
						<cfset hg="#hg#, #island#">
					<cfelse>
						<cfset hg="#island#">
					</cfif>
				</cfif>
				<cfif len(#quad#) gt 0>
					<cfif len(#hg#) gt 0>
						<cfset hg="#hg#, #quad# Quad">
					<cfelse>
						<cfset hg="#quad# Quad">
					</cfif>
				</cfif>
</cfoutput>
				
<center>

<table width="90%">
	<tr>
		<td nowrap valign="top">
			<cfoutput query="detail" group="cat_num">
				<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#" class="novisit">
					<font size="+1"><B>#institution_acronym#&nbsp;#collection_cde#&nbsp;#cat_num#</b></font>
				</a>
							
						
						<cfif #detail.collection_cde# is "Mamm" and len(#af_num#) gt 0>
					<b>(AF&nbsp;#af_num#)</b>
				<cfelseif #detail.collection_cde# is "Herb">
					<cfquery name="getALACC" dbtype="query">
						select other_id_num from detail where other_id_type='ALAAC number'
					</cfquery>
					<b>(ALAAC:&nbsp;#getALACC.other_id_num#)</b>
				</cfif>			
				<br>
				<a href="javascript:void(0);" 
					onClick="getInfo('identification','#collection_object_id#'); return false;"
					onMouseOver="self.status='Click for Identification Details.';return true;" 
					onmouseout="self.status='';return true;">
						<font size="+1">
						<cfset sciname = '#replace(Scientific_Name," or ","</i>&nbsp;or&nbsp;<i>")#'>
							<b>
								<i>&nbsp;#sciname#</i>
								</b>
							</font>
				</a>
				 <cfif 
							(len(#dec_lat#) gt 0 and 
							len(#dec_long#) gt 0) 
						>
						<cfif #encumbrance_action# does not contain "coordinates" OR
							(isdefined("client.rights") AND #client.rights# contains "student0")>
								
							<cfset bnhmUrl="/bnhmMaps/bnhmMapData.cfm?collection_object_id=#collection_object_id#">
							<br><input type="button" 
								value="BerkeleyMapper" 
								class="lnkBtn"
								onmouseover="this.className='lnkBtn btnhov'" 
								onmouseout="this.className='lnkBtn'"
								onClick="window.open('#bnhmUrl#', '_blank');">
	
						</cfif>
					</cfif>
		</td>
		<td valign="top">
			
				<em>#spec_locality#</em>
				<br>#hg#
				
			<cfif (#verbatim_date# is #began_date#) AND
			 		(#verbatim_date# is #ended_date#)>
					<cfset thisDate = #dateformat(began_date,"dd mmm yyyy")#>
			<cfelseif (
						(#verbatim_date# is not #began_date#) OR
			 			(#verbatim_date# is not #ended_date#)
					)
					AND
					#began_date# is #ended_date#>
					<cfset thisDate = "#verbatim_date# (#dateformat(began_date,"dd mmm yyyy")#)">
			<cfelse>
					<cfset thisDate = "#verbatim_date# (#dateformat(began_date,"dd mmm yyyy")# - #dateformat(ended_date,"dd mmm yyyy")#)">
			</cfif>
			<br>#thisDate#
		</td>
		<td valign="top">
		
								<font size="-1">
								#partString#
								</font>
								
		</td>
		</cfoutput>
		
		
	</tr>
	<cfif isdefined("client.rights") and #client.rights# contains "student1">
	<tr>
		<td colspan="3" align="center">
		<cfoutput>
				
		<form name="incPg" method="post" action="SpecimenDetail.cfm">
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">
					<input type="hidden" name="content_url" value="#content_url#">
					<input type="hidden" name="suppressHeader" value="true">
					<input type="hidden" name="action" value="nothing">
					<input type="hidden" name="Srch" value="Part">
					<input type="hidden" name="collecting_event_id" value="#detail.collecting_event_id#">
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td nowrap>		
<div class="tabBG">
<input type="button" 
	class="tab"
	onmouseover="this.className='tab tabHov'" 
	onmouseout="this.className='tab'"
	value="Taxa"
	onClick="incPg.content_url.value='editIdentification.cfm';incPg.submit();">
<input type="button" 
	class="tab"
	onmouseover="this.className='tab tabHov'" 
	onmouseout="this.className='tab'"
	value="Accn"
	onClick="incPg.content_url.value='addAccn.cfm';incPg.submit();">
<input type="button" 
	class="tab"
	onmouseover="this.className='tab tabHov'" 
	onmouseout="this.className='tab'"
	value="Edit Locn."
	onClick="incPg.content_url.value='Locality.cfm';incPg.action.value='editCollEvnt';incPg.submit();">
</div>					
					
								
<li><a href="javascript:void(0);"><span onClick="incPg.content_url.value='editIdentification.cfm';incPg.submit();">Taxa</span></a></li>
<li><a href="javascript:void(0);"><span onClick="incPg.content_url.value='addAccn.cfm';incPg.submit();">Accn</span></a></li>
<li><a href="javascript:void(0);"><span onClick="incPg.content_url.value='Locality.cfm';incPg.action.value='editCollEvnt';incPg.submit();">Edit Locn.</span></a></li>
<li><a href="javascript:void(0);"><span onClick="incPg.content_url.value='changeCollEvent.cfm';incPg.submit();">New Locn.</span></a></li>
<li><a href="javascript:void(0);"><span onClick="incPg.content_url.value='editColls.cfm';incPg.submit();">Agents</span></a></li>
<li><a href="javascript:void(0);"><span onClick="incPg.content_url.value='editRelationship.cfm';incPg.submit();">Relations</span></a></li>
<li><a href="javascript:void(0);"><span onClick="incPg.content_url.value='editParts.cfm';incPg.submit();">Parts</span></a></li>
<li><a href="javascript:void(0);"><span onClick="window.open('Locations.cfm?collection_object_id=#collection_object_id#&srch=part','parts');">Part Locations</span></a></li>
<li><a href="javascript:void(0);"><span onClick="incPg.content_url.value='editBiolIndiv.cfm';incPg.submit();">Attributes</span></a></li>
<li><a href="javascript:void(0);"><span onClick="incPg.content_url.value='editIdentifiers.cfm';incPg.submit();">IDs</span></a></li>
<li><a href="javascript:void(0);"><span onClick="incPg.content_url.value='editImages.cfm';incPg.submit();">Images</span></a></li>
<li><a href="javascript:void(0);"><span onClick="incPg.content_url.value='Encumbrances.cfm';incPg.submit();">Encumbrances</span></a></li>

</td>
</tr>
</table>
			</form><!----
				
					\
					<input type="button" value="" onClick="" class="tab">
					<input type="button" value="Edit Coll Event" onClick="incPg.content_url.value='Locality.cfm';incPg.action.value='editCollEvnt';submit();" class="tab">
					<input type="button" value="Change Coll Event" onClick="incPg.content_url.value='changeCollEvent.cfm';submit();" class="tab">
					<input type="button" value="Collectors" onClick="incPg.content_url.value='editColls.cfm';submit();" class="tab">
					<input type="button" value="Relationships" onClick="incPg.content_url.value='editRelationship.cfm';submit();" class="tab">
					<input type="button" value="Parts" onClick="incPg.content_url.value='editParts.cfm';submit();" class="tab">
					<input type="button" value="Part Locations" onClick="window.open('Locations.cfm?collection_object_id=#collection_object_id#&srch=part','parts')" class="tab">
					
					<input type="button" value="Individual Attributes" onClick="incPg.content_url.value='editBiolIndiv.cfm';submit();" class="tab">
					<input type="button" value="Identifiers" onClick="incPg.content_url.value='editIdentifiers.cfm';submit();" class="tab">
					<input type="button" value="Images" onClick="incPg.content_url.value='editImages.cfm';submit();" class="tab">
					<input type="button" value="Encumbrances" onClick="incPg.content_url.value='Encumbrances.cfm';submit();" class="tab">
					---->
			</cfoutput>
		</td>
	</tr>
	</cfif>
	<!----
	<tr height="1">
		<td colspan="3" height="1">
			<img src="/images/black.gif" height="1" width="100%" border="0">
		</td>
	</tr>
	---->
	
</table>
</center>
<cfoutput>

<!---- resize this frame to just hold it's contents---->
<table width="90%">
	<tr>
		<td>
			<cfinclude template="#content_url#">
		</td>
	</tr>
</table>
	
	
</cfoutput>