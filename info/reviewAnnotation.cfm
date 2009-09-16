<cfinclude template="/includes/_header.cfm">
<cfset title="Review Annotations">
<cfoutput>
<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection cln from collection order by collection
</cfquery>
<table border>
	<tr>
		<td align="center">
			<label>Specimens</label>
			<form name="filter" method="get" action="reviewAnnotation.cfm">
				<input type="hidden" name="action" value="show">
				<input type="hidden" name="type" value="collection_object_id">
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
		</td>
		<td align="center">
			<label>The Rest</label>
			<form name="filter" method="get" action="reviewAnnotation.cfm">
				<input type="hidden" name="action" value="show">
				<label for="type">Type</label>
				<select name="type" size="1">
					<option value="taxon_name_id">Taxonomy</option>
					<option value="project_id">Project</option>
					<option value="publication_id">Publication</option>
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
		</td>
	</tr>
</table>
Filter for:

</cfoutput>
<cfif action is "show">
<cfoutput>
	<cfif type is "collection_object_id">
		<cfif isdefined("id") and len(id) gt 0>
			<cfset collection_object_id=id>
		</cfif>
		<cfquery name="ci" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select
				 annotations.ANNOTATION_ID,
				 annotations.ANNOTATE_DATE,
				 annotations.CF_USERNAME,
				 annotations.COLLECTION_OBJECT_ID,
				 annotations.annotation,	 
				 annotations.reviewer_agent_id,
				 preferred_agent_name.agent_name reviewer,
				 annotations.reviewed_fg,
				 annotations.reviewer_comment,
				 collection.collection,
				 cataloged_item.cat_num,
				 identification.scientific_name idAs,
				 geog_auth_rec.higher_geog,
				 locality.spec_locality,
				 cf_user_data.email
			FROM
				annotations,
				cataloged_item,
				collection,
				collecting_event,
				locality,
				geog_auth_rec,
				identification,
				cf_user_data,
				cf_users,
				preferred_agent_name
			WHERE
				annotations.COLLECTION_OBJECT_ID = cataloged_item.COLLECTION_OBJECT_ID AND
				annotations.reviewer_agent_id=preferred_agent_name.agent_id (+) and
				cataloged_item.collection_id = collection.collection_id AND
				cataloged_item.collection_object_id = identification.collection_object_id AND
				accepted_id_fg=1 AND
				cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
				collecting_event.locality_id = locality.locality_id AND
				locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
				annotations.CF_USERNAME=cf_users.username (+) and
				cf_users.user_id = cf_user_data.user_id (+)
				<cfif isdefined("collection_object_id") and len(#collection_object_id#) gt 0>
					AND annotations.collection_object_id = #collection_object_id#
				</cfif>
				<cfif isdefined("collection") and len(#collection#) gt 0>
					AND collection.collection = '#collection#'
				</cfif>
		</cfquery>
		<cfquery name="catitem" dbtype="query">
			select
				COLLECTION_OBJECT_ID,
				collection,
				cat_num,
				idAs,
				higher_geog,
				spec_locality
			from 
				ci 
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
			<cfloop query="catitem">
				<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
					<td>
						<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">#collection# #cat_num#</a>
						<br><em>#idAs#</em>
						<br>#higher_geog#
						<br>#spec_locality#
						<cfquery name="itemAnno" dbtype="query">
							select * from ci where collection_object_id = #collection_object_id#
						</cfquery>
						<table border width="100%">
							<cfloop query="itemAnno">
								<tr>
									<td>
										Annotation by <strong>#CF_USERNAME#</strong> 
										(#email#) on #dateformat(ANNOTATE_DATE,"dd Mmm yyyy")#
									</td>
									<td>
										<br>Scientific Name: #annotation#
									</td>
									<form name="r" method="post" action="reviewAnnotation">
										<input type="hidden" name="action" value="saveReview">
										<input type="hidden" name="type" value="collection_object_id">
										<input type="hidden" name="id" value="#collection_object_id#">
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
	<cfelseif type is "publication_id">
	publication_id
	
	<cfelseif type is "taxon_name_id">
	taxon_name_id
	<cfelseif type is "project_id">
	project_id
	<cfelse>
		fail.
	</cfif><!--- end collection_object_id --->
</cfoutput>
</cfif>
<cfif action is "saveReview">
<cfoutput>
	<cfquery name="annotations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update annotations set
			REVIEWER_AGENT_ID=#session.myAgentId#,
			REVIEWED_FG=#REVIEWED_FG#,
			REVIEWER_COMMENT='#stripQuotes(REVIEWER_COMMENT)#'
		where
			annotation_id=#annotation_id#
	</cfquery>
	<cflocation url="annotate.cfm?action=show&type=#type#&id=#id#" addtoken="false">
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">