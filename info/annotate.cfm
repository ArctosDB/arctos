<cfinclude template="/includes/_frameHeader.cfm">
<cfif action is "nothing">
<cfoutput>
	<cfset t=listgetat(q,1,"=")>
	<cfset v=listgetat(q,2,"=")>
	<cfset "#t#"="#v#">
	<link rel="stylesheet" type="text/css" href="/includes/annotate.css">		
	<span onclick="closeAnnotation()" class="windowCloser">Close Annotation Window</span>
	
	
	
	
	<cfif isdefined("collection_object_id") and len(collection_object_id) gt 0>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
		<cfquery name="prevAnn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from annotations where collection_object_id=#collection_object_id#
		</cfquery>
	<cfelseif isdefined("taxon_name_id") and len(taxon_name_id) gt 0>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select 
				'Name <strong>' || display_name || '</strong>' summary
			from 
				taxonomy
			where 
				taxon_name_id=#taxon_name_id#
		</cfquery>
		<cfquery name="prevAnn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from annotations where taxon_name_id=#taxon_name_id#
		</cfquery>
	<cfelseif isdefined("project_id") and len(project_id) gt 0>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select 
				'Project <strong>' || PROJECT_NAME || '</strong>' summary
			from 
				project
			where 
				project_id=#project_id#
		</cfquery>
		<cfquery name="prevAnn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from annotations where project_id=#project_id#
		</cfquery>
	<cfelseif isdefined("publication_id") and len(publication_id) gt 0>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select 
				'Publication <strong>' || short_citation || '</strong>' summary
			from 
				publication
			where 
				publication_id=#publication_id#
		</cfquery>
		<cfquery name="prevAnn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from annotations where publication_id=#publication_id#
		</cfquery>
	<cfelse>
		<div class="error">
			Oops! I can't handle that request. <a href="/contact.cfm?ref=failedAnnotationType">contact us</a>
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
		<cfset email="">
		<cfif len(session.username) gt 0>
			<cfquery name="hasEmail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select email from cf_user_data,cf_users
				where cf_user_data.user_id = cf_users.user_id and
				cf_users.username='#session.username#'
			</cfquery>
			<cfif hasEmail.recordcount is 1 and len(hasEmail.email) gt 0>
				<cfset email=hasEmail.email>
			</cfif>
		<cfelse>
			<cffunction name="makeRandomString" returnType="string" output="false">
			    <cfset var chars = "23456789ABCDEFGHJKMNPQRS">
			    <cfset var length = randRange(4,7)>
			    <cfset var result = "">
			    <cfset var i = "">
			    <cfset var char = "">
			    <cfscript>
			    for(i=1; i <= length; i++) {
			        char = mid(chars, randRange(1, len(chars)),1);
			        result&=char;
			    }
			    </cfscript>
			    <cfreturn result>
			</cffunction>
			<cfset captcha = makeRandomString()>
			<cfset captchaHash = hash(captcha)>
			<cfimage action="captcha" width="300" height="50" text="#captcha#" difficulty="low"
		    	overwrite="yes"
		    	destination="#application.webdirectory#/download/captcha.png">
			<img src="/download/captcha.png">
			<label for="captcha">Enter the text above. Case doesn't matter. (required)</label>
	    <input type="text" name="captcha" id="captcha" value="#v#" class="reqdClr" size="60">
	    <input type="text" name="captchaHash" value="#captchaHash#">
	    
	    
		</cfif>
		<label for="email">Email</label>
		<input type="text" class="reqdClr" name="email" id="email" value="#email#">
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