<!--- take a string of non-DGR collection_object_id's, see if there's an equivilant --->
<cfset sql="
	SELECT DISTINCT
		collection,
		cataloged_item.cat_num,
		cataloged_item.collection_object_id as collection_object_id,
		cataloged_item.collection_cde,
		identification.scientific_name,
		continent_ocean,
		country,
		geog_auth_rec.geog_auth_rec_id,
		locality.locality_id,
		accepted_lat_long.lat_long_id,
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
		concatotherid(cataloged_item.collection_object_id) other_ids,
		concatSingleOtherId(cataloged_item.collection_object_id,'ALAAC') alaac,
		concatparts(cataloged_item.collection_object_id) as partString,
		concatEncumbranceDetails(cataloged_item.collection_object_id) as encumbrance_action,
		concatColls('collection_object_id', cataloged_item.collection_object_id, 'agent_name','coll_names') collectors,
		dec_lat,
		dec_long,
		concatEncumbrances(cataloged_item.collection_object_id) encumbrances
	FROM 
		cataloged_item,
		collection,
		identification,
		collecting_event,
		locality,
		geog_auth_rec,
		Coll_object,
		coll_obj_other_id_num,
		accepted_lat_long,
		coll_object_encumbrance
	WHERE 
		cataloged_item.collection_id = collection.collection_id and
		cataloged_item.collection_object_id = identification.collection_object_id and		
		identification.accepted_id_fg = 1 AND
		cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		collecting_event.locality_id = locality.locality_id and
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and
		cataloged_item.collection_object_id = coll_object.collection_object_id and
		cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id and
		locality.locality_id = accepted_lat_long.locality_id and
		cataloged_item.collection_object_id=coll_object_encumbrance.collection_object_id and
		cataloged_item.collection_object_id in 
			(select 
				COLLECTION_OBJECT_ID 
			from
				BIOL_INDIV_RELATIONS,
				coll_object_encumbrance
			where
				BIOL_INDIV_RELATIONS.COLLECTION_OBJECT_ID=coll_object_encumbrance.COLLECTION_OBJECT_ID and
				coll_object_encumbrance.encumbrance_id=1000025
			union all
			select 
				RELATED_COLL_OBJECT_ID 
			from
				BIOL_INDIV_RELATIONS,
				coll_object_encumbrance
			where
				BIOL_INDIV_RELATIONS.RELATED_COLL_OBJECT_ID=coll_object_encumbrance.COLLECTION_OBJECT_ID and
				coll_object_encumbrance.encumbrance_id=1000025
			)
	ORDER BY
		cat_num">
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(sql)#
</cfquery>
<style>
	.match {
		color:green;
		}
	.nomatch {color:red;
		}
</style>
<cfquery name="recOne" dbtype="query">
	select * from data where encumbrances like '%mask record%'
</cfquery>
<cfoutput>
	This form displays DGR data and non-DGR data compared by NK number ONLY. Records with only MSB catalog numbers are displayed; records with only DGR catalog numbers are NOT displayed.
	<table border>
		<tr>
			<td width="50%">Collection Data</td>
			<td>DGR Data</td>
		</tr>
			<cfset i=1>
		<cfloop query="recOne">
			<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
				<td>
					<table border>
						<tr>
							<td>
								ALAAC #ALAAC#: <a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">#institution_acronym# #collection_cde# #cat_num#</a>
							</td> 
							<td>
								#scientific_name#
							</td>
						</tr>
						<tr>
							<td>
								#continent_ocean# - #country# - #state_prov# - #quad# - #county# - #island# - #island_group#
							</td>
							<td>#spec_locality#</td>
						</tr>
						<tr>
							<td>
								#verbatim_date# - 
								#dateformat(BEGAN_DATE,"dd-mmm-yyyy")#
										- #dateformat(ended_date,"dd-mmm-yyyy")#
							</td>
							<td>#other_ids#</td>
						</tr>
						<tr>
							<td>#dec_lat# - #dec_long#</td>
							<td>#partString#</td>
						</tr>
						<tr>
							<td>#collectors#</td>
							<td>#encumbrance_action#</td>
						</tr>
						
					</table>
				</td>
				<td>
				<cfquery name="recTwo" dbtype="query">
					select * from data where
					and ALAAC='#ALAAC#'
					and collection_object_id <> #collection_object_id#
				</cfquery>
				<cfif #dgr.recordcount# is 1>
					<table border>
						<tr>
							<td>
								ALAAC #recTwo.ALAAC#: <a href="/SpecimenDetail.cfm?collection_object_id=#recTwo.collection_object_id#">#recTwo.institution_acronym# #recTwo.collection_cde# #recTwo.cat_num#</a>
							</td>
							<td>
								<span class="
									<cfif #recTwo.scientific_name# is #scientific_name#>
										match
									<cfelse>
										nomatch
									</cfif>">
										#recTwo.scientific_name#
									</span>
									
							</td>
						</tr>
						<tr>
							<td>
								<span class="
									<cfif #recTwo.geog_auth_rec_id# is #geog_auth_rec_id#>
										match
									<cfelse>
										nomatch
									</cfif>">
										#recTwo.continent_ocean#  - #recTwo.country#
										 - #recTwo.state_prov# - #recTwo.quad# - #recTwo.county# - #recTwo.island# - #recTwo.island_group#
									</span>
							</td>
							<td>
								<span class="
									<cfif #recTwo.locality_id# is #locality_id#>
										match
									<cfelse>
										nomatch
									</cfif>">
										#recTwo.spec_locality#
									</span>
									
							</td>
						</tr>
						<tr>
							<td>
								<span class="
									<cfif #recTwo.collecting_event_id# is #collecting_event_id#>
										match
									<cfelse>
										nomatch
									</cfif>">
										#recTwo.verbatim_date# - #dateformat(recTwo.BEGAN_DATE,"dd-mmm-yyyy")#
										- #dateformat(recTwo.ended_date,"dd-mmm-yyyy")#
									</span>
							</td>
							<td>
								<span class="
									<cfif #recTwo.other_ids# is #other_ids#>
										match
									<cfelse>
										nomatch
									</cfif>">
										#recTwo.other_ids#
									</span>
							</td>
						</tr>
						<tr>
							<td>
								<span class="
									<cfif #recTwo.lat_long_id# is #lat_long_id#>
										match
									<cfelse>
										nomatch
									</cfif>">
										#recTwo.dec_lat# - #recTwo.dec_long#
									</span>
							</td>
							
							<td>
								<span class="
									<cfif #recTwo.partString# is #partString#>
										match
									<cfelse>
										nomatch
									</cfif>">
										#recTwo.partString#
									</span>
							</td>
						</tr>
						<tr>
							<td>
								<span class="
									<cfif #recTwo.collectors# is #collectors#>
										match
									<cfelse>
										nomatch
									</cfif>">
										#recTwo.collectors#
									</span>
							</td>
							<td>#recTwo.encumbrance_action#
							<cfif #recTwo.encumbrance_action# does not contain "mask record by Jerry W. Dragoo on 13 Jan 2005">
							<input type="button" name="delEnc" id="del#recTwo.collection_object_id#" onClick="window.open('picks/delEncThis.cfm?collection_object_id=#recTwo.collection_object_id#','width=700,height=400, resizable,scrollbars')" value="Mark For Deletion">
							</cfif>
							</td>
						</tr>
					</table>
				<cfelse>
					No match for recTwo ALAAC## = #alaac#
				</cfif>
				</td>
			</tr>
			<cfset i=#i#+1>
		</cfloop>
	</table>
</cfoutput>
