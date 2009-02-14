<cfinclude template="/includes/_header.cfm">
<cfset title="Specimen Annotations">
<cfoutput>
<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection cln from collection order by collection
</cfquery>
Filter By:
<form name="filter" method="post" action='annotate.cfm'>
	<input type="hidden" name="action" value="show">
	<label for="collection">Collection</label>
	<select name="collection" size="1">
		<option value=""></option>
		<cfloop query="c">
			<option value="#cln#">#cln#</option>
		</cfloop>
	</select>
	<br>
	<input type="submit" 
		class="lnkBtn"
		onmouseover="this.className='lnkBtn btnhov'" 
		onmouseout="this.className='lnkBtn'"
		value="Filter">
	<input type="reset" 
		class="clrBtn"
		onmouseover="this.className='clrBtn btnhov'" 
		onmouseout="this.className='clrBtn'"
		value="Clear Form">
</form>
</cfoutput>
<cfif #action# is "show">
<cfoutput>
	<cfquery name="annotations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
			 specimen_annotations.ANNOTATION_ID,
			 specimen_annotations.ANNOTATE_DATE,
			 specimen_annotations.CF_USERNAME,
			 specimen_annotations.COLLECTION_OBJECT_ID,
			 specimen_annotations.SCIENTIFIC_NAME,
			 specimen_annotations.HIGHER_GEOGRAPHY,
			 specimen_annotations.SPECIFIC_LOCALITY,
			 specimen_annotations.ANNOTATION_REMARKS,			 
			 specimen_annotations.reviewer_agent_id,
			 agent_name.agent_name reviewer,
			 specimen_annotations.reviewed_fg,
			 specimen_annotations.reviewer_comment,
			 collection.collection,
			 cataloged_item.cat_num,
			 identification.scientific_name idAs,
			 geog_auth_rec.higher_geog,
			 locality.spec_locality,
			 cf_user_data.email
		FROM
			specimen_annotations,
			cataloged_item,
			collection,
			collecting_event,
			locality,
			geog_auth_rec,
			identification,
			cf_user_data,
			cf_users,
			agent_name
		WHERE
			specimen_annotations.COLLECTION_OBJECT_ID = cataloged_item.COLLECTION_OBJECT_ID AND
			specimen_annotations.reviewer_agent_id=agent_name.agent_name_id (+) and
			cataloged_item.collection_id = collection.collection_id AND
			cataloged_item.collection_object_id = identification.collection_object_id AND
			accepted_id_fg=1 AND
			cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
			collecting_event.locality_id = locality.locality_id AND
			locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
			specimen_annotations.CF_USERNAME=cf_users.username and
			cf_users.user_id = cf_user_data.user_id
			<cfif isdefined("collection_object_id") and len(#collection_object_id#) gt 0>
				AND specimen_annotations.collection_object_id = #collection_object_id#
			</cfif>
			<cfif isdefined("collection") and len(#collection#) gt 0>
				AND collection.collection = '#collection#'
			</cfif>
	</cfquery>
	<cfquery name="items" dbtype="query">
		select
			COLLECTION_OBJECT_ID,
			collection,
			cat_num,
			idAs,
			higher_geog,
			spec_locality
		from 
			annotations 
		group by
			COLLECTION_OBJECT_ID,
			collection,
			cat_num,
			idAs,
			higher_geog,
			spec_locality
	</cfquery>
	<table>
		<Cfset i=1>
		<cfloop query="items">
			<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
				<td>
					<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">#collection# #cat_num#</a>
					<br><em>#idAs#</em>
					<br>#higher_geog#
					<br>#spec_locality#
			<cfquery name="itemAnno" dbtype="query">
				select * from annotations where collection_object_id = #collection_object_id#
			</cfquery>
								<table border width="100%">
			<cfloop query="itemAnno">

						<tr>
							<td>
								Annotation by <strong>#CF_USERNAME#</strong> (#email#) on #dateformat(ANNOTATE_DATE,"dd Mmm yyyy")#
							</td>
							<td>
								<cfif len(#scientific_name#) gt 0>
									<br>Scientific Name: #scientific_name#
								</cfif>
								<cfif len(#higher_geography#) gt 0>
									<br>Higher Geography: #higher_geography#
								</cfif>
								<cfif len(#specific_locality#) gt 0>
									<br>Specific Locality: #specific_locality#
								</cfif>
								<cfif len(#ANNOTATION_REMARKS#) gt 0>
									<br>Remarks: #ANNOTATION_REMARKS#
								</cfif>
							</td>
							<form name="r" method="post" action="annotate.cfm">
								<input type="hidden" name="action" value="saveReview">
								<input type="hidden" name="collection_object_id" value="#collection_object_id#">
								<input type="hidden" name="annotation_id" value="#annotation_id#">
							<td>
								<label for="reviewed_fg">Reviewed?</label>
								<select name="reviewed_fg" id="reviewed_fg">
									<option value="0" <cfif reviewed_fg is 0>selected="selected"</cfif>>No</option>
									<option value="1" <cfif reviewed_fg is 1>selected="selected"</cfif>>Yes</option>
								</select>
								<cfif len(reviewer) gt 0>
									<span style="font-size:small"><br>Last review by #reviewer#</span>
								</cfif>
							</td>
							<td>
								<label for="reviewer_comment">Review Comments</label>
								<input type="text" name="reviewer_comment" id="reviewer_comment" value="#reviewer_comment#">
							</td>
							<td>
								<input type="submit" value="save review" class="savBtn">
							</td>
							</form>
						</tr>

			</cfloop>
								</table>
				</td>
			</tr>
			<cfset i=#i#+1>
		</cfloop>
	</table>
</cfoutput>
</cfif>
<cfif action is "saveReview">
<cfoutput>
	<cfquery name="annotations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update specimen_annotations set
			REVIEWER_AGENT_ID=#session.myAgentId#,
			REVIEWED_FG=#REVIEWED_FG#,
			REVIEWER_COMMENT='#stripQuotes(REVIEWER_COMMENT)#'
		where
			annotation_id=#annotation_id#
	</cfquery>
	<cflocation url="annotate.cfm?action=show&collection_object_id=#collection_object_id#" addtoken="false">
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">