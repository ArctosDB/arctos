<cfinclude template="/includes/_header.cfm">
<cfset title="Review Annotations">
<!--- major revision: after v7.2.3 ---->
<cfif isdefined("id") and len(id) gt 0>
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
	<cfquery name="c" datasource="uam_god"  cachedwithin="#createtimespan(0,0,60,0)#">
		select distinct guid_prefix from collection order by guid_prefix
	</cfquery>
<label for="filter">Search/Filter</label>
<form name="filter" method="get" action="reviewAnnotation.cfm">
	<input type="hidden" name="action" value="show">
	<label for="atype">Type of Annotation</label>
	<select name="atype" size="1">
		<option value=""></option>
		<option value="taxon">Taxonomy</option>
		<option value="project">Project</option>
		<option value="publication">Publication</option>
		<option value="specimen">Specimen</option>
	</select>
	<label for="guid_prefix">Collection (only works when "specimens" above)</label>
	<select name="guid_prefix" size="1">
		<option value=""></option>
		<cfloop query="c">
			<option value="#guid_prefix#">#guid_prefix# Specimens</option>
		</cfloop>
	</select>

	<label for="reviewer_comment">Reviewer Comment</label>
	<textarea class="hugetextarea"  name="reviewer_comment" id="reviewer_comment"></textarea>
	<span class="infoLink" onclick="$('#reviewer_comment').val('_');">NOT NULL</span>
	<span class="infoLink" onclick="$('#reviewer_comment').val('NULL');">IS NULL</span>


	<br>
	<input type="submit" class="lnkBtn" value="Filter">
	<input type="reset" class="clrBtn" value="Clear Form">
</form>
<!---- if we have any useful IDs, find the annotations and what's referenced by them ---->

	<script>
		function reviewAnnotation(annotation_id) {
			$.getJSON("/component/functions.cfc",
				{
					method : "reviewAnnotation",
					annotation_id : annotation_id,
					reviewer_comment : $("#reviewer_comment_" + annotation_id).val(),
					returnformat : "json",
					queryformat : 'column'
				},
				function (r) {
					if (r.DATA.STATUS=='success'){
						$("#reviewer_comment_" + r.DATA.ANNOTATION_ID).removeClass('badPick').addClass('goodPick');
					} else {
						$("#reviewer_comment_" + r.DATA.ANNOTATION_ID).removeClass('goodPick').addClass('badPick');
						alert(r.DATA.MESSAGE);
					}
				}
			);
		}
	</script>
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
			1=1
			<cfif isdefined("collection_object_id") and len(collection_object_id) gt 0>
				and annotations.collection_object_id in (
					<cfqueryparam value = "#collection_object_id#" CFSQLType = "CF_SQL_INTEGER" list = "yes" separator = ",">
				)
			</cfif>
			<cfif isdefined("publication_id") and len(publication_id) gt 0>
				and annotations.publication_id in (
					<cfqueryparam value = "#publication_id#" CFSQLType = "CF_SQL_INTEGER" list = "yes" separator = ",">
				)
			</cfif>
			<cfif isdefined("project_id") and len(project_id) gt 0>
				and annotations.project_id in (
					<cfqueryparam value = "#project_id#" CFSQLType = "CF_SQL_INTEGER" list = "yes" separator = ",">
				)
			</cfif>
			<cfif isdefined("taxon_name_id") and len(taxon_name_id) gt 0>
				and annotations.taxon_name_id in (
					<cfqueryparam value = "#taxon_name_id#" CFSQLType = "CF_SQL_INTEGER" list = "yes" separator = ",">
				)
			</cfif>
			<cfif isdefined("annotation_id") and len(annotation_id) gt 0>
				and annotations.annotation_id = (
					<cfqueryparam value = "#annotation_id#" CFSQLType = "CF_SQL_INTEGER" list = "yes" separator = ",">
				)
			</cfif>
			<cfif isdefined("annotation_group_id") and len(annotation_group_id) gt 0>
				and annotations.annotation_group_id = (
					<cfqueryparam value = "#annotation_group_id#" CFSQLType = "CF_SQL_INTEGER" list = "yes" separator = ",">
				)
			</cfif>
			<cfif isdefined("atype") and atype is "taxon">
				and annotations.taxon_name_id is not null
			</cfif>
			<cfif isdefined("atype") and atype is "project">
				and annotations.project_id is not null
			</cfif>
			<cfif isdefined("atype") and atype is "publication">
				and annotations.publication_id is not null
			</cfif>
			<cfif isdefined("atype") and atype is "specimen">
				and annotations.collection_object_id is not null
			</cfif>
			<cfif isdefined("guid_prefix") and len(guid_prefix) gt 0>
				and annotations.collection_object_id in (
					select collection_object_id from cataloged_item,collection where cataloged_item.collection_id=collection.collection_id and
					collection.guid_prefix in (
						<cfqueryparam value = "#guid_prefix#" CFSQLType = "CF_SQL_VARCHAR" list = "yes" separator = ",">
					)
			</cfif>

			<cfif isdefined("reviewer_comment") and len(reviewer_comment) gt 0>
				<cfif reviewer_comment is "NULL">
					and annotations.reviewer_comment is null
				<cfelse>
					and upper(annotations.reviewer_comment) like
					<cfqueryparam value = "#ucase(reviewer_comment)#" CFSQLType = "CF_SQL_VARCHAR" list = "no">
				</cfif>
			</cfif>
	</cfquery>
	<cfdump var=#data#>

	<cfoutput>
		<cfset i=1>
		<cfloop query="data">
			<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
				<div>Submittor: <cfif len(CF_USERNAME) gt 0>#CF_USERNAME#<cfelse>anonymous</cfif></div>
				<div>Date: #ANNOTATE_DATE#</div>
				<div>Annotation: #ANNOTATION#</div>
				<cfif len(reviewer) gt 0>
					<div>Reviewed By #reviewer#</div>
				</cfif>
				<cfif session.roles contains "manage_collection">
						<!----
						<form name="r#i#" method="post" action="reviewAnnotation.cfm">
						<input type="text" name="action" value="saveReview">
						<input type="text" name="annotation_id" value="#annotation_id#">
						<label for="reviewed_fg">Reviewed?</label>
						<select name="reviewed_fg" id="reviewed_fg">
							<option value="0" <cfif reviewed_fg is 0>selected="selected"</cfif>>No</option>
							<option value="1" <cfif reviewed_fg is 1>selected="selected"</cfif>>Yes</option>
						</select>
							</form>
						----->
						<label for="reviewer_comment">Review Comment</label>
						<textarea class="hugetextarea"  name="reviewer_comment" id="reviewer_comment_#annotation_id#">#reviewer_comment#</textarea>
						<br><input type="button" class="savBtn" value="save review" onclick="reviewAnnotation('#annotation_id#');">
				<cfelse>
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
			<cfset i=i+1>
		</cfloop>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">