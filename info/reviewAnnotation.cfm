<cfinclude template="/includes/_header.cfm">
<cfset title="Review Annotations">
<!----
	Ways to get here:
		1) From a data object (specimen, project, etc)
			--> find all annotations concerning it
				-->create links to group page for any group annotations
		3) From a group of annotations

---->

<cfif isdefined("id") and len(id) gt 0>

yes got ID....


	<!--- legacy format, redirect to modern ---->
	<cfif isdefined("type") and type is "taxon">
		<cflocation url="reviewAnnotation.cfm?taxon_name_id=#id#" addtoken="false">
	<cfelseif isdefined("type") and type is "project">
		<cflocation url="reviewAnnotation.cfm?project_id=#id#" addtoken="false">
	<cfelseif isdefined("type") and type is "publication">
		<cflocation url="reviewAnnotation.cfm?publication_id=#id#" addtoken="false">
	<cfelse>
		<cflocation url="reviewAnnotation.cfm?collection_object_id=#id#" addtoken="false">
	</cfif>
</cfif>

<!---- search form, always displayed ---->
<!----
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
----->
<!---- if we have any useful IDs, find the annotations and what's referenced by them ---->

<cfquery name="data" datasource="uam_god">
	select
		ANNOTATION_ID,
		ANNOTATION_GROUP_ID,
		ANNOTATION,
		to_char(ANNOTATE_DATE,'yyyy-mm-dd') ANNOTATE_DATE,
		CF_USERNAME,
		REVIEWER_AGENT_ID,
		getPreferredAgentName(REVIEWER_AGENT_ID) reviewer,
		REVIEWED_FG,
		REVIEWER_COMMENT
	from
		annotations
	where
		<cfif isdefined("collection_object_id") and len(collection_object_id) gt 0>
			collection_object_id in (
				<cfqueryparam value = "#collection_object_id#" CFSQLType = "CF_SQL_INTEGER" list = "yes" separator = ",">
			)
		</cfif>
		<cfif isdefined("annotation_id") and len(annotation_id) gt 0>
			annotation_id = (
				<cfqueryparam value = "#annotation_id#" CFSQLType = "CF_SQL_INTEGER" list = "yes" separator = ",">
			)
		</cfif>
		<!----
		<!--- specimen view ---->
	<cfelseif isdefined("guid") and len(guid) gt 0>
		<!---- alternate specimen view ---->
	<cfelseif isdefined("taxon_name_id") and len(taxon_name_id) gt 0>
		<!---- taxon view ---->
---->





</cfquery>

<cfoutput>
	<cfset i=1>
	<cfloop query="data">
		<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
			<div>Submittor: <cfif len(CF_USERNAME) gt 0>#CF_USERNAME#<cfelse>anonymous</cfif></div>
			<div>Date: #ANNOTATE_DATE#</div>
			<div>Annotation: #ANNOTATION#</div>
			<cfif session.roles contains "manage_collection">
				<form name="r#i#" method="post" action="reviewAnnotation.cfm">
					<input type="hidden" name="action" value="saveReview">
					<input type="hidden" name="annotation_id" value="#annotation_id#">
					<label for="reviewed_fg">Reviewed?</label>
					<select name="reviewed_fg" id="reviewed_fg">
						<option value="0" <cfif reviewed_fg is 0>selected="selected"</cfif>>No</option>
						<option value="1" <cfif reviewed_fg is 1>selected="selected"</cfif>>Yes</option>
					</select>
					<label for="reviewer_comment">Review Comments</label>
					<textarea class="hugetextarea"  name="reviewer_comment" id="reviewer_comment">#reviewer_comment#</textarea>
					<br><input type="submit" class="savBtn" value="save review">
				</form>
			<cfelse>
				<cfif len(reviewer) gt 0>
					<div>Reviewed By #reviewer#</div>
				</cfif>
				<cfif len(reviewer_comment) gt 0>
					<div>Reviewer Comments: #reviewer_comment#</div>
				</cfif>
			</cfif>
			<cfquery name="grp" datasource="uam_god">
				select
					getAnnotationObject(annotation_id) dlink
				 from annotations where ANNOTATION_GROUP_ID=#ANNOTATION_GROUP_ID#
			</cfquery>
			<div>
				Annotated Object(s)
				<ul>
					<cfloop query="grp">
						<li>#dlink#</li>
					</cfloop>
				</ul>
			</div>
		</div>

		<!----
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




		<p>
			edit the annotation here: #ANNOTATION_ID# - #ANNOTATION#
			<!--- now get all objects to which the annotation refers ---->
			<cfquery name="grp" datasource="uam_god">
				select
					getAnnotationObject(annotation_id) dlink

				 from annotations where ANNOTATION_GROUP_ID=#ANNOTATION_GROUP_ID#
			</cfquery>
			Group: <cfdump var=#grp#>
			<cfloop query="grp">
				<br>#dlink#
			</cfloop>

		</p>
						   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 ANNOTATION_ID							   NOT NULL NUMBER
 ANNOTATE_DATE							   NOT NULL DATE
 CF_USERNAME								    VARCHAR2(255)
 COLLECTION_OBJECT_ID							    NUMBER
 TAXON_NAME_ID								    NUMBER
 PROJECT_ID								    NUMBER
 PUBLICATION_ID 							    NUMBER
 ANNOTATION							   NOT NULL VARCHAR2(4000)
 REVIEWER_AGENT_ID							    NUMBER
 REVIEWED_FG							   NOT NULL NUMBER(1)
 REVIEWER_COMMENT							    VARCHAR2(255)
----->

			<cfset i=i+1>
	</cfloop>
</cfoutput>

<cfabort>


<!----


	<cfif len(d.TAXON_NAME_ID) gt 0>
		<cfset id=valuelist(d.TAXON_NAME_ID)>
		<cfset type='taxon'>
	<cfelseif len(d.PROJECT_ID) gt 0>
		<cfset id=valuelist(d.PROJECT_ID)>
		<cfset type='project'>
	<cfelseif len(d.PUBLICATION_ID) gt 0>
		<cfset id=valuelist(d.PUBLICATION_ID)>
		<cfset type='publication'>
	<cfelseif len(d.COLLECTION_OBJECT_ID) gt 0>
		<cfset id=valuelist(d.COLLECTION_OBJECT_ID)>
		<cfset type='specimen'>
	</cfif>
	<cfif isdefined("id") and len(id) gt 0>
		<cflocation url="/info/reviewAnnotation.cfm?action=show&id=#id#" addtoken="false">






<!----

<cfif isdefined("collection_object_id") and len(collection_object_id) gt 0>
	<!--- specimen view ---->
<cfelseif isdefined("guid") and len(guid) gt 0>
	<!---- alternate specimen view ---->
<cfelseif isdefined("taxon_name_id") and len(taxon_name_id) gt 0>
	<!---- taxon view ---->


</cfif>

---->


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

</cfoutput>

<cfif isdefined("ANNOTATION_GROUP_ID") and len(ANNOTATION_GROUP_ID) gt 0>
	<!--- figure it out and redirect ---->
	<cfquery name="d" datasource="uam_god">
		select * from annotations where ANNOTATION_GROUP_ID=#val(ANNOTATION_GROUP_ID)#
	</cfquery>
	<cfif len(d.TAXON_NAME_ID) gt 0>
		<cfset id=valuelist(d.TAXON_NAME_ID)>
		<cfset type='taxon'>
	<cfelseif len(d.PROJECT_ID) gt 0>
		<cfset id=valuelist(d.PROJECT_ID)>
		<cfset type='project'>
	<cfelseif len(d.PUBLICATION_ID) gt 0>
		<cfset id=valuelist(d.PUBLICATION_ID)>
		<cfset type='publication'>
	<cfelseif len(d.COLLECTION_OBJECT_ID) gt 0>
		<cfset id=valuelist(d.COLLECTION_OBJECT_ID)>
		<cfset type='specimen'>
	</cfif>
	<cfif isdefined("id") and len(id) gt 0>
		<cflocation url="/info/reviewAnnotation.cfm?action=show&id=#id#" addtoken="false">
	<cfelse>
		bad call<cfabort>
	</cfif>

</cfif>

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
				<cfif isdefined("reviewed") and len(reviewed) gt 0>
					and REVIEWED_FG=#reviewed#
				</cfif>
				<cfif isdefined("id") and len(id) gt 0>
					and publication.publication_id in ( #id# )
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
					and annotations.project_id in ( #id# )
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
					AND annotations.taxon_name_id in ( #id# )
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
					AND annotations.collection_object_id in ( #id# )
				</cfif>
				<cfif isdefined("type") and len(type) gt 0>
					AND flat.guid like '#type#%'
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

---->
<cfif action is "saveReview">
<cfoutput>
	<cfquery name="annotations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update annotations set
			REVIEWER_AGENT_ID=#session.myAgentId#,
			REVIEWED_FG=1,
			REVIEWER_COMMENT='#stripQuotes(REVIEWER_COMMENT)#'
		where
			annotation_id=#annotation_id#
	</cfquery>
	<cflocation url="reviewAnnotation.cfm?annotation_id=#annotation_id#" addtoken="false">
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">