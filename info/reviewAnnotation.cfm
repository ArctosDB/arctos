<cfinclude template="/includes/_header.cfm">
<cfset title="Review Annotations">
<cfif not isdefined("type")>
	<cfset type="">
</cfif>
<cfif not isdefined("reviewed")>
	<cfset reviewed="">
</cfif>
<cfif isdefined("type") and type is "collection_object_id">
	<cfset type=''>
</cfif>
<cfoutput>
<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select guid_prefix from collection order by guid_prefix
</cfquery>
<form name="filter" method="get" action="reviewAnnotation.cfm">
	<input type="hidden" name="action" value="show">
	<label for="type">Type of Annotation</label>
	<select name="type" size="1">
		<option  <cfif type is "taxon">selected="selected" </cfif>value="taxon">Taxonomy</option>
		<option  <cfif type is "project">selected="selected" </cfif>value="project">Project</option>
		<option  <cfif type is "publication">selected="selected" </cfif>value="publication">Publication</option>
		<option  <cfif type is "">selected="selected" </cfif>value="">All Specimens</option>
		<cfloop query="c">
			<option  <cfif type is "#guid_prefix#">selected="selected" </cfif>value="#guid_prefix#">#guid_prefix# Specimens</option>
		</cfloop>
	</select>
	<label for="reviewed">Reviewed</label>
	<select name="reviewed" size="1">
		<option value="">whatever</option>
		<option <cfif reviewed is 1>selected="selected" </cfif>value="1">yes</option>
		<option <cfif reviewed is 0>selected="selected" </cfif>value="0">no</option>
	</select>
	<br>
	<input type="submit" class="lnkBtn" value="Filter">
	<input type="reset" class="clrBtn" value="Clear Form">	
</form>
</cfoutput>
<cfif action is "show">
<cfoutput>
	<cfif type is "publication">
		<cfquery name="data" datasource="uam_god">
			select 
				publication.full_citation summary,
				'/publication/' || annotations.publication_id datalink,
				'publication_id' pkeytype,
				publication.publication_id pkey,
				annotations.ANNOTATION_ID,
				annotations.ANNOTATE_DATE,
				annotations.CF_USERNAME,
				annotations.annotation,	 
				annotations.reviewer_agent_id,
				preferred_agent_name.agent_name reviewer,
				annotations.reviewed_fg,
				annotations.reviewer_comment,
				cf_user_data.email
			FROM
				annotations,
				publication,
				cf_user_data,
				cf_users,
				preferred_agent_name
			WHERE
				annotations.publication_id = publication.publication_id AND
				annotations.reviewer_agent_id=preferred_agent_name.agent_id (+) and
				annotations.CF_USERNAME=cf_users.username (+) and
				cf_users.user_id = cf_user_data.user_id (+)
				<cfif isdefined("publication_id") and len(publication_id) gt 0>
					AND annotations.publication_id = #publication_id#
				</cfif>
				<cfif isdefined("reviewed") and len(reviewed) gt 0>
					and REVIEWED_FG=#reviewed#
				</cfif>
				<cfif isdefined("publication_id") and len(publication_id) gt 0>
					and publication.publication_id=#publication_id#
				</cfif>
				<cfif isdefined("id") and len(id) gt 0>
					and publication.publication_id=#id#
				</cfif>
		</cfquery>
	<cfelseif type is "project">
		<cfquery name="data" datasource="uam_god">
			select 
				project.project_name summary,
				'/project/' || niceURL(project.project_name) datalink,
				'project_id' pkeytype,
				project.project_id pkey,
				annotations.ANNOTATION_ID,
				annotations.ANNOTATE_DATE,
				annotations.CF_USERNAME,
				annotations.annotation,	 
				annotations.reviewer_agent_id,
				preferred_agent_name.agent_name reviewer,
				annotations.reviewed_fg,
				annotations.reviewer_comment,
				cf_user_data.email
			FROM
				annotations,
				project,
				cf_user_data,
				cf_users,
				preferred_agent_name
			WHERE
				annotations.project_id = project.project_id AND
				annotations.reviewer_agent_id=preferred_agent_name.agent_id (+) and
				annotations.CF_USERNAME=cf_users.username (+) and
				cf_users.user_id = cf_user_data.user_id (+)
				<cfif isdefined("project_id") and len(project_id) gt 0>
					AND annotations.project_id = #project_id#
				</cfif>
				<cfif isdefined("reviewed") and len(reviewed) gt 0>
					and REVIEWED_FG=#reviewed#
				</cfif>
				<cfif isdefined("id") and len(id) gt 0>
					and annotations.project_id=#id#
				</cfif>
		</cfquery>
	<cfelseif type is "taxon" or type is "taxon_name_id">
		<cfquery name="data" datasource="uam_god">
			select 
				taxon_name.scientific_name summary,
				'/name/' || taxon_name.scientific_name datalink,
				'taxon_name_id' pkeytype,
				taxon_name.taxon_name_id pkey,
				annotations.ANNOTATION_ID,
				annotations.ANNOTATE_DATE,
				annotations.CF_USERNAME,
				annotations.annotation,	 
				annotations.reviewer_agent_id,
				preferred_agent_name.agent_name reviewer,
				annotations.reviewed_fg,
				annotations.reviewer_comment,
				cf_user_data.email,
				annotations.taxon_name_id
			FROM
				annotations,
				taxon_name,
				cf_user_data,
				cf_users,
				preferred_agent_name
			WHERE
				annotations.taxon_name_id = taxon_name.taxon_name_id AND
				annotations.reviewer_agent_id=preferred_agent_name.agent_id (+) and
				annotations.CF_USERNAME=cf_users.username (+) and
				cf_users.user_id = cf_user_data.user_id (+)
				<cfif isdefined("taxon_name_id") and len(taxon_name_id) gt 0>
					AND annotations.taxon_name_id = #taxon_name_id#
				</cfif>
				<cfif isdefined("id") and len(id) gt 0>
					AND annotations.taxon_name_id = #id#
				</cfif>
				<cfif isdefined("reviewed") and len(reviewed) gt 0>
					and REVIEWED_FG=#reviewed#
				</cfif>
		</cfquery>
	<cfelse>
		<cfquery name="data" datasource="uam_god">
			select
				 flat.guid || ' - ' || flat.scientific_name summary,
				 '/guid/' || flat.guid datalink,
				 'COLLECTION_OBJECT_ID' pkeytype,
				 annotations.COLLECTION_OBJECT_ID pkey,
				 annotations.ANNOTATION_ID,
				 annotations.ANNOTATE_DATE,
				 annotations.CF_USERNAME,
				 annotations.annotation,	 
				 annotations.reviewer_agent_id,
				 preferred_agent_name.agent_name reviewer,
				 annotations.reviewed_fg,
				 annotations.reviewer_comment,
				 cf_user_data.email
			FROM
				annotations,
				flat,
				cf_user_data,
				cf_users,
				preferred_agent_name
			WHERE
				annotations.COLLECTION_OBJECT_ID = flat.COLLECTION_OBJECT_ID AND
				annotations.reviewer_agent_id=preferred_agent_name.agent_id (+) and
				annotations.CF_USERNAME=cf_users.username (+) and
				cf_users.user_id = cf_user_data.user_id (+)
				<cfif isdefined("collection_object_id") and len(collection_object_id) gt 0>
					AND annotations.collection_object_id = #collection_object_id#
				</cfif>
				<cfif isdefined("id") and len(id) gt 0>
					AND annotations.collection_object_id = #id#
				</cfif>
				<cfif isdefined("type") and len(type) gt 0>
					AND flat.guid_prefix = '#type#'
				</cfif>
				<cfif isdefined("reviewed") and len(reviewed) gt 0>
					and REVIEWED_FG=#reviewed#
				</cfif>
				<cfif isdefined("COLLECTION_OBJECT_ID") and len(COLLECTION_OBJECT_ID) gt 0>
					and flat.COLLECTION_OBJECT_ID=#COLLECTION_OBJECT_ID#
				</cfif>
		</cfquery>		
	</cfif>
	<cfif not isdefined("data") or data.recordcount is 0>
		<div class="error">
			nothing found
		</div>
		<cfabort>
	</cfif>
	<cfquery name="uData" dbtype="query">
		select
			datalink,
			summary,
			pkeytype,
			pkey
		from
			data
		group by
			datalink,
			summary,
			pkeytype,
			pkey
	</cfquery>
	<cfset i=1>
	<table width="100%" border="1">
		<cfloop query="uData">
			<cfquery name="details" dbtype="query">
				select * from data where datalink = '#datalink#'
			</cfquery>
			<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
				<td colspan="5">
					<a href="#datalink#">#summary#</a>
				</td>
			</tr>
			<cfloop query="details">
				<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					<td style="padding-left:2em;">
						Annotation by <strong>#CF_USERNAME#</strong> 
						(#email#) on #dateformat(ANNOTATE_DATE,"yyyy-mm-dd")#
					</td>
					<td>
						#annotation#
					</td>
					<form name="r" method="post" action="reviewAnnotation.cfm">
						<input type="hidden" name="action" value="saveReview">
						<input type="hidden" name="type" value="#pkeytype#">
						<input type="hidden" name="id" value="#pkey#">
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
							<textarea rows="4" cols="30"  name="reviewer_comment" id="reviewer_comment">#reviewer_comment#</textarea>
						</td>
						<td>
							<input type="submit" value="save review" class="savBtn">
						</td>
					</form>
				</tr>
			</cfloop>
			<cfset i=i+1>
		</cfloop>
	</table>
</cfoutput>
</cfif>
<cfif action is "saveReview">
<cfoutput>
	<cfquery name="annotations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update annotations set
			REVIEWER_AGENT_ID=#session.myAgentId#,
			REVIEWED_FG=#REVIEWED_FG#,
			REVIEWER_COMMENT='#stripQuotes(REVIEWER_COMMENT)#'
		where
			annotation_id=#annotation_id#
	</cfquery>
	<cflocation url="reviewAnnotation.cfm?action=show&type=#type#&id=#id#" addtoken="false">
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">