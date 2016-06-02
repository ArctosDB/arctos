<cfinclude template="/includes/_frameHeader.cfm">
<cfif action is "nothing">
<cfoutput>
	<cfset t=listgetat(q,1,"=")>
	<cfset v=listgetat(q,2,"=")>
	<cfset "#t#"="#v#">
	<link rel="stylesheet" type="text/css" href="/includes/annotate.css">
	<cfif listlen(v) eq 1>
		<cfif isdefined("collection_object_id") and len(collection_object_id) gt 0>
			<cfset linky="collection_object_id=#collection_object_id#">
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					'Specimen <strong>' || collection.guid_prefix || ':' || cat_num ||
					' <i>' || scientific_name || '</i></strong>' summary
				from
					cataloged_item,
					identification,
					collection
				where
					cataloged_item.collection_object_id = identification.collection_object_id AND
					accepted_id_fg=1 AND
					cataloged_item.collection_id = collection.collection_id and
					cataloged_item.collection_object_id in (
						<cfqueryparam value = "#collection_object_id#" CFSQLType = "CF_SQL_INTEGER" list = "yes" separator = ",">
					)
			</cfquery>
			<cfquery name="prevAnn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from annotations where	collection_object_id=#collection_object_id#
			</cfquery>
		<cfelseif isdefined("taxon_name_id") and len(taxon_name_id) gt 0>
			<cfset linky="taxon_name_id=#taxon_name_id#">
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					'Name <strong>' || scientific_name || '</strong>' summary
				from
					taxon_name
				where
					taxon_name_id=#taxon_name_id#
			</cfquery>
			<cfquery name="prevAnn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from annotations where taxon_name_id=#taxon_name_id#
			</cfquery>
		<cfelseif isdefined("project_id") and len(project_id) gt 0 >
			<cfset linky="project_id=#project_id#">
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
		<cfelseif isdefined("publication_id") and len(publication_id) gt 0 >
			<cfset linky="publication_id=#publication_id#">
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
		<p>Annotations for #d.summary#</p>
	</cfif>
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
		</cfif>
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
		<cfset imgName=hash(now() & session.sessionkey)>
		<cfimage action="captcha" width="300" height="50" text="#captcha#" difficulty="low"
		   	overwrite="yes"
		   	destination="#application.webdirectory#/download/#imgName#.png">
		<div style="align:center;">
			<img src="/download/#imgName#.png">
		</div>
		<label for="captcha">
			<cfif len(session.username) gt 0>You have an account - we'll get this for you.<cfelse>Enter the text above. Case doesn't matter. (required)</cfif>
		</label>
	    <input type="text" name="captcha" id="captcha" <cfif len(session.username) gt 0>value="#captcha#"</cfif> class="reqdClr" size="60">
		 <input type="hidden" name="captchaHash" id="captchaHash" value="#captchaHash#">
		<div style="margin:.3em;">
			<label for="email">Email - <span style="color:red">Please provide contact information!</span></label>
			<input type="text" class="reqdClr" name="email" id="email" value="#email#" size="60">
		</div>
		<br>
		<div style="align:center;margin:.3em;">
			<!----
		<input type="button"
			class="qutBtn"
			value="Quit without Saving"
			onclick="closeAnnotation()">
			-------->
		<input type="button"
			class="savBtn"
			value="Save Annotations"
			onclick="saveThisAnnotation()">
		</div>
	</form>
	<cfif isdefined("prevAnn.recordcount") and prevAnn.recordcount gt 0>
	<hr>
	<p>Previous Annotations (<a target="_blank" href="/info/reviewAnnotation.cfm?#linky#">Click here for details</a>)</p>
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
							<span style="color:green">#REVIEWER_COMMENT#</span>
						<cfelseif REVIEWED_FG is 0>
							<span style="color:red">Not Reviewed</span>
						<cfelse>
							<span style="color:green">Reviewed</span>
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