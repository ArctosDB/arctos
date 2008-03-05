<cfset collection_object_id="587812,587718,587818,587790,587706,587768,587814,587724,587840,676610,587856,587810,587688,587716,587830,587754,587826,587870,600878,587774,587728,587816,587844,587796,587762,587872,587832,587698,587802,587806,587740,587764,587748,637114,587738,587746,587704,587868,587720,587778,587770,587772,587710,587842,587834,587804,587852,587694,587722,587726,587848,587732,587860,587824,587730,587788,587786,587864,587828,641040,587690,587836,587696,587782,587700,587862,587742,587798,587850,587692,587756,587780,587776,641000,587838,587708,587800,602220,587750,587766,587784,587760,587736,587792,587820,645154,587758,736240,587854,587858,587712,587752,587714,587808,660706,587744,587702,587866,587734,587822,587846,587794">
<cfset collection_object_id="587812">
<cfif not isdefined("collection_object_id")>
		<cfabort>
	</cfif>

	
<cfset sql="
	select
		get_scientific_name_auths(cataloged_item.collection_object_id) sci_name_with_auth,
		concatAcceptedIdentifyingAgent(cataloged_item.collection_object_id) identified_by,
		get_taxonomy(cataloged_item.collection_object_id,'family') family,
		get_taxonomy(cataloged_item.collection_object_id,'scientific_name') tsname,
		get_taxonomy(cataloged_item.collection_object_id,'author_text') auth,
		identification_remarks,
		made_date,
		cat_num,
		state_prov,
		country,
		quad,
		county,
		island,
		sea,
		feature,
		spec_locality,
		CASE orig_lat_long_units
			WHEN 'decimal degrees' THEN dec_lat || 'd'
			WHEN 'deg. min. sec.' THEN lat_deg || 'd ' || lat_min || 'm ' || lat_sec || 's ' || lat_dir
			WHEN 'degrees dec. minutes' THEN lat_deg || 'd ' || dec_lat_min || 'm ' || lat_dir
		END as VerbatimLatitude,
		CASE orig_lat_long_units
			WHEN 'decimal degrees' THEN dec_long || 'd'
			WHEN'degrees dec. minutes' THEN long_deg || 'd ' || dec_long_min || 'm ' || long_dir
			WHEN 'deg. min. sec.' THEN long_deg || 'd ' || long_min || 'm ' || long_sec || 's ' || long_dir
		END as VerbatimLongitude,
		MAXIMUM_ELEVATION,
		MINIMUM_ELEVATION,
		ORIG_ELEV_UNITS,
		concatColl(cataloged_item.collection_object_id) as collectors,
		concatotherid(cataloged_item.collection_object_id) as other_ids,
		concatsingleotherid(cataloged_item.collection_object_id,'original identifier') fieldnum,
		concatsingleotherid(cataloged_item.collection_object_id,'U. S. National Park Service accession') npsa,
		concatsingleotherid(cataloged_item.collection_object_id,'U. S. National Park Service catalog') npsc,
		concatsingleotherid(cataloged_item.collection_object_id,'ALAAC') ALAAC,
		verbatim_date,
		habitat_desc,
		habitat,
		associated_species,
		project_name
	FROM
		cataloged_item,
		identification,
		collecting_event,
		locality,
		geog_auth_rec,
		accepted_lat_long,
		coll_object_remark,
		project_trans,
		project
	WHERE
		cataloged_item.collection_object_id = identification.collection_object_id AND
		cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		collecting_event.locality_id = locality.locality_id AND
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		locality.locality_id = accepted_lat_long.locality_id (+) AND
		cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+) AND
		cataloged_item.accn_id = project_trans.transaction_id (+) AND
		project_trans.project_id = project.project_id(+) AND
		accepted_id_fg=1 AND cataloged_item.collection_object_id IN (#collection_object_id#)
	ORDER BY
		concatsingleotherid(cataloged_item.collection_object_id,'original identifier')
			">
	<cfquery name="data" datasource="#Application.web_user#">
		#preservesinglequotes(sql)#
	</cfquery>

<!---- 
	Last label is mussed if there are an odd number of labels
	--->
	
	<cfif  #data.recordcount# mod 2 neq 0>
		<!--- pad on a garbage record --->
		<cfset temp = queryaddrow(data,1)>
		<cfset temp = querysetcell(data,'family','blank filler')>
		
	</cfif>
<cfoutput>


 <cfloop query="data">
 	
	<cfset coordinates = "">
	<cfif len(#verbatimLatitude#) gt 0 AND len(#verbatimLongitude#) gt 0>
		<cfset coordinates = "#verbatimLatitude# / #verbatimLongitude#">
		<cfset coordinates = replace(coordinates,"d","&##176;","all")>
		<cfset coordinates = replace(coordinates,"m","'","all")>
		<cfset coordinates = replace(coordinates,"s","''","all")>
	</cfif>
	
	<cfif #collectors# contains ";">
		<Cfset spacePos = find(";",collectors)>
		<cfset thisColl = left(collectors,#SpacePos# - 1)>
		<cfset thisColl = "#thisColl# et al.">
	<cfelse>
		<cfset thisColl = #collectors#>
	</cfif>
	
	<cfset thisDate = "">
	<cftry>
		<cfset thisDate = #dateformat(verbatim_date,"dd mmm yyyy")#>
		<cfcatch>
			<cfset thisDate = #verbatim_date#>
		</cfcatch>
	</cftry>
<cfdocument format="pdf">
	<cfdocumentsection >hi</cfdocumentsection>
	<cfpdfform action="populate" source="#application.webDirectory#/Reports/templates/template_alaLabel.pdf">
        <cfpdfsubform name="form1">
            <cfpdfformparam name="family" value="#family#">
        </cfpdfsubform>
    </cfpdfform>
</cfdocument>
</cfloop>
<!---
				<table cellpadding="0" cellspacing="0" width="100%" class="pad10" border="0">
					<tr>
						<td colspan="1" class="times14b">#family#</td>
						<td class="times14b" colspan="1" align="right">
							#ucase(state_prov)#,&nbsp;<cfif #country# is "United States">USA<cfelse>#ucase(country)#</cfif>
						</td>
					</tr>
					<tr>
						<td colspan="2">&nbsp;</td>
					</tr>
					<tr>
					<!---
						<cfset sn = #replace(sci_name_with_auth," ","-space-","all")#>
						<cfset sn = #replace(sci_name_with_auth,"&nbsp;","-nobreakspace-","all")#>
						<CFSET sn = REReplaceNoCase(sci_name_with_auth, "[^a-z]", ":dammit:" , "All")> 
						<cfset sn = #replace(sn,"/",":slashie:","all")#>
						
						<cfset sn = #replace(sn,">",":closebracket:","all")#>
						<cfset sn = #replace(sn,"<",":openbracket:","all")#>
						
						#replace(tsname," ","&nbsp;","all")#
						--->
						<cfset sn=sci_name_with_auth>
						
						
						<td colspan="2" class="times15b">
							#sci_name_with_auth#
						<!---
							<table border="1" width="100%">
								<tr>
									<td>askjfbgaskjlbdh lkjasbdakjshdf lkjasdfajkhsd lalksdjhaks liuasb</td>
									<td>/lkdj kljfls dlkj kjsdfg lkj ajkhgsd lghjkdf kjahsd lkjh sadflkj</td>
								</tr>
							</table>
							---->
						</td>
					</tr>
					<tr>
						<td colspan="2" class="times12 height20">
						#identification_remarks#&nbsp;</td>
					</tr>
					<tr>
						<cfset geog="">
						<cfif len(#quad#) gt 0>
							<cfset geog = "#quad# Quad.:">
						</cfif>
						<cfif len(#spec_locality#) gt 0>
							<cfset geog = "#geog# #spec_locality#">
						</cfif>
						<cfif len(#coordinates#) gt 0>
						 	<cfset geog = "#geog#, #coordinates#">
						 </cfif>
						  <cfif len(#ORIG_ELEV_UNITS#) gt 0>
						 	<cfset geog = "#geog#. Elev.&nbsp;#MINIMUM_ELEVATION#-#MAXIMUM_ELEVATION#&nbsp;#ORIG_ELEV_UNITS#">
						 </cfif>
						 <cfif len(#habitat#) gt 0>
						 	<cfset geog = "#geog#, #habitat#">
						 </cfif>
						 <cfif len(#associated_species#) gt 0>
						 	<cfset geog = "#geog#, #associated_species#">
						 </cfif>
						 <cfif right(geog,1) is not "."><cfset geog = "#geog#."></cfif>
						<td colspan="2" class="times12 height100">
							#geog#
						</td>
					</tr>
				
					<tr>
						<td class="times12">#collectors# #fieldnum#</td>
						<td class="times12" align="right">
						#thisDate#
						</td>
					</tr>
					<tr>
						<td class="times12" colspan="2"><cfif #collectors# neq #identified_by# AND #identified_by# is not "unknown">
								Det: #identified_by# on #dateformat(made_date,"dd mmm yyyy")#
							</cfif>&nbsp;
						</td>
					</tr>
					<tr>
						<td colspan="2" align="middle" class="times12">
							#project_name#&nbsp;
						</td>
					</tr>
					<tr>
						<td colspan="2"  align="middle" class="times12">
							<cfif len(#npsa#) gt 0 or len(#npsc#) gt 0>
								NPS: #npsa# #npsc#&nbsp;
							</cfif>
						</td>
					</tr>
					<tr>
						<td colspan="2" align="middle" class="times12b">
							Herbarium, University of Alaska Museum (ALA) accession #alaac#
						</td>
					</tr>
					
					
					
				</table>
				<!--- end cell table --->
				</td><!--- end cell cell --->
	
	
	<cfset i=#i#+1>
	<cfset t=#t#+1>	
	</cfloop>
</tr>
</table><!--- close page table --->
	<!-----

	----->
	</cfdocument>
	
	<a href="#Application.ServerRootUrl#/temp/alaLabel.pdf">pdf</a>
	--->
	</cfoutput>
	

