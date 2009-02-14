<!--- take a string of non-DGR collection_object_id's, see if there's an equivilant --->
<cfset sql="
	SELECT DISTINCT
		institution_acronym,
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
		concatSingleOtherId(cataloged_item.collection_object_id,'NK Number') nk,
		concatparts(cataloged_item.collection_object_id) as partString,
		concatEncumbranceDetails(cataloged_item.collection_object_id) as encumbrance_action,
		concatColls('collection_object_id', cataloged_item.collection_object_id, 'agent_name','coll_names') collectors,
		dec_lat,
		dec_long
	FROM 
		cataloged_item
	INNER JOIN collection ON (cataloged_item.collection_id = collection.collection_id)
	INNER JOIN identification ON (cataloged_item.collection_object_id = identification.collection_object_id)
	INNER JOIN collecting_event ON (cataloged_item.collecting_event_id = collecting_event.collecting_event_id)
	INNER JOIN locality ON (collecting_event.locality_id = locality.locality_id)
	INNER JOIN geog_auth_rec ON (locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id)
	INNER JOIN Coll_object ON (cataloged_item.collection_object_id = coll_object.collection_object_id)
	LEFT OUTER JOIN coll_obj_other_id_num ON (cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id)
	LEFT OUTER JOIN accepted_lat_long ON (locality.locality_id = accepted_lat_long.locality_id)
	WHERE 
		identification.accepted_id_fg = 1 AND
		cataloged_item.collection_object_id IN ( #collection_object_id# )
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
<cfquery name="notDGR" dbtype="query">
	select * from data where institution_acronym <> 'DGR'
</cfquery>
<cfoutput>
	This form displays DGR data and non-DGR data compared by NK number ONLY. Records with only MSB catalog numbers are displayed; records with only DGR catalog numbers are NOT displayed.
	<table border>
		<tr>
			<td width="50%">Collection Data</td>
			<td>DGR Data</td>
		</tr>
			<cfset i=1>
		<cfloop query="notDGR">
			<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
				<td>
					<table border>
						<tr>
							<td>
								NK #nk#: <a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">#institution_acronym# #collection_cde# #cat_num#</a>
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
				<cfquery name="dgr" dbtype="query">
					select * from data where institution_acronym = 'DGR'
					and nk='#nk#'
				</cfquery>
				<cfif #dgr.recordcount# is 1>
					<table border>
						<tr>
							<td>
								NK #dgr.nk#: <a href="/SpecimenDetail.cfm?collection_object_id=#dgr.collection_object_id#">#dgr.institution_acronym# #dgr.collection_cde# #dgr.cat_num#</a>
							</td>
							<td>
								<span class="
									<cfif #dgr.scientific_name# is #scientific_name#>
										match
									<cfelse>
										nomatch
									</cfif>">
										#dgr.scientific_name#
									</span>
									
							</td>
						</tr>
						<tr>
							<td>
								<span class="
									<cfif #dgr.geog_auth_rec_id# is #geog_auth_rec_id#>
										match
									<cfelse>
										nomatch
									</cfif>">
										#dgr.continent_ocean#  - #dgr.country#
										 - #dgr.state_prov# - #dgr.quad# - #dgr.county# - #dgr.island# - #dgr.island_group#
									</span>
							</td>
							<td>
								<span class="
									<cfif #dgr.locality_id# is #locality_id#>
										match
									<cfelse>
										nomatch
									</cfif>">
										#dgr.spec_locality#
									</span>
									
							</td>
						</tr>
						<tr>
							<td>
								<span class="
									<cfif #dgr.collecting_event_id# is #collecting_event_id#>
										match
									<cfelse>
										nomatch
									</cfif>">
										#dgr.verbatim_date# - #dateformat(dgr.BEGAN_DATE,"dd-mmm-yyyy")#
										- #dateformat(dgr.ended_date,"dd-mmm-yyyy")#
									</span>
							</td>
							<td>
								<span class="
									<cfif #dgr.other_ids# is #other_ids#>
										match
									<cfelse>
										nomatch
									</cfif>">
										#dgr.other_ids#
									</span>
							</td>
						</tr>
						<tr>
							<td>
								<span class="
									<cfif #dgr.lat_long_id# is #lat_long_id#>
										match
									<cfelse>
										nomatch
									</cfif>">
										#dgr.dec_lat# - #dgr.dec_long#
									</span>
							</td>
							
							<td>
								<span class="
									<cfif #dgr.partString# is #partString#>
										match
									<cfelse>
										nomatch
									</cfif>">
										#dgr.partString#
									</span>
							</td>
						</tr>
						<tr>
							<td>
								<span class="
									<cfif #dgr.collectors# is #collectors#>
										match
									<cfelse>
										nomatch
									</cfif>">
										#dgr.collectors#
									</span>
							</td>
							<td>#dgr.encumbrance_action#
							<cfif #dgr.encumbrance_action# does not contain "mask record by Jerry W. Dragoo on 13 Jan 2005">
							<input type="button" name="delEnc" id="del#dgr.collection_object_id#" onClick="window.open('picks/delEncThis.cfm?collection_object_id=#dgr.collection_object_id#','width=700,height=400, resizable,scrollbars')" value="Mark For Deletion">
							</cfif>
							</td>
						</tr>
					</table>
				<cfelse>
					No match for DGR NK## = #nk#
				</cfif>
				</td>
			</tr>
			<cfset i=#i#+1>
		</cfloop>
	</table>
</cfoutput>
