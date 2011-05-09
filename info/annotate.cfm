<cfinclude template="/includes/_frameHeader.cfm">
<cfif #action# is "nothing">
<cfoutput>
	<cfset t=listgetat(q,1,"=")>
	<cfset v=listgetat(q,2,"=")>
	<cfset "#t#"="#v#">
	<link rel="stylesheet" type="text/css" href="/includes/annotate.css">		
	<span onclick="closeAnnotation()" class="windowCloser">Close Annotation Window</span>
	<cfquery name="hasEmail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select email from cf_user_data,cf_users
		where cf_user_data.user_id = cf_users.user_id and
		cf_users.username='#session.username#'
	</cfquery>
	<cfif #hasEmail.recordcount# is 0 OR #len(hasEmail.email)# is 0>
		<div class="error">
			You must provide an email address to annotate specimens.
			<br>
			Update <a href="/myArctos.cfm" target="_blank">your profile</a> (opens in new window) to proceed.
			<br>
			<span class="likeLink" onclick="closeAnnotation()">Close this window</span>
		</div>
		<cfabort>
	</cfif>
	<cfif isdefined("collection_object_id") and len(collection_object_id) gt 0>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				'Specimen <strong>' || collection.collection || ' ' || cat_num ||
				' <i>' || scientific_name || '</i></strong>' summary
			from 
				cataloged_item,
				identification,
				collection
			where 
				cataloged_item.collection_object_id = identification.collection_object_id AND
				accepted_id_fg=1 AND
				cataloged_item.collection_id = collection.collection_id and
				cataloged_item.collection_object_id=#collection_object_id#
		</cfquery>
		<cfquery name="prevAnn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from annotations where collection_object_id=#collection_object_id#
		</cfquery>
	<cfelseif isdefined("taxon_name_id") and len(taxon_name_id) gt 0>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				'Name <strong>' || display_name || '</strong>' summary
			from 
				taxonomy
			where 
				taxon_name_id=#taxon_name_id#
		</cfquery>
		<cfquery name="prevAnn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from annotations where taxon_name_id=#taxon_name_id#
		</cfquery>
	<cfelseif isdefined("project_id") and len(project_id) gt 0>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				'Project <strong>' || PROJECT_NAME || '</strong>' summary
			from 
				project
			where 
				project_id=#project_id#
		</cfquery>
		<cfquery name="prevAnn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from annotations where project_id=#project_id#
		</cfquery>
	<cfelseif isdefined("publication_id") and len(publication_id) gt 0>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				'Publication <strong>' || publication_title || '</strong>' summary
			from 
				publication
			where 
				publication_id=#publication_id#
		</cfquery>
		<cfquery name="prevAnn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from annotations where publication_id=#publication_id#
		</cfquery>
	<cfelse>
		<div class="error">
			Oops! I can't handle that request. File a bug report.
			<cfthrow detail="unhandled_annotation" errorcode="9999" message="unhandled annotation">
		</div>
		<cfabort>
	</cfif>
	Annotations for #d.summary#
	<form name="annotate" method="post" action="/info/annotate.cfm">
		<input type="hidden" name="action" value="insert">
		<input type="hidden" name="idtype" id="idtype" value="#t#">
		<input type="hidden" name="idvalue" id="idvalue" value="#v#">
		<label for="annotation">Annotation</label>
		<textarea rows="4" cols="50" name="annotation" id="annotation"></textarea>
		<br>
		<input type="button" 
			class="qutBtn"
			value="Quit without Saving"
			onclick="closeAnnotation()">
		<input type="button" 
			class="savBtn"
			value="Save Annotations"
			onclick="saveThisAnnotation()">
	</form>
	<cfif prevAnn.recordcount gt 0>
		<label for="tbl">Previous Annotations</label>
		<table id="tbl" border>
			<th>Annotation</th>
			<th>Made Date</th>
			<th>Status</th>
			<cfloop query="prevAnn">
				<tr>
					<td>#annotation#</td>
					<td>#dateformat(ANNOTATE_DATE,"yyyy-mm-dd")#</td>
					<td>
						<cfif len(REVIEWER_COMMENT) gt 0>
							#REVIEWER_COMMENT#
						<cfelseif REVIEWED_FG is 0>
							Not Reviewed
						<cfelse>
							Reviewed
						</cfif>
					</td>
				</tr>
			</cfloop>
		</table>
	<cfelse>
		There are no previous annotations for this object.
	</cfif>	
</cfoutput>
</cfif>
<cfif #action# is "insert">
<cfoutput>
	<cfquery name="insAnn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	insert into specimen_annotations (
		collection_object_id,
		scientific_name)
	values (
		#collection_object_id#,
		'#scientific_name#')
	</cfquery>
	<cflocation url="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#&showAnnotation=true">
</cfoutput>
</cfif>