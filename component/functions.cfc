<cfcomponent>
<cffunction name="addAnnotation" access="remote">
	<cfargument name="collection_object_id" type="numeric" required="yes">
	<cfargument name="scientific_name" type="string" required="yes">
	<cfargument name="higher_geography" type="string" required="yes">
	<cfargument name="specific_locality" type="string" required="yes">
	<cfargument name="annotation_remarks" type="string" required="yes">
	<cfinclude template="/includes/functionLib.cfm">
	<cftry>
		<cfset sql = "insert into specimen_annotations (
				collection_object_id,
				cf_username">
		<cfif len(#higher_geography#) gt 0 and #higher_geography# is not "Annotate">
			<cfset sql = "#sql#,higher_geography">
		</cfif>
		<cfif len(#scientific_name#) gt 0 and #scientific_name# is not "Annotate">
			<cfset sql = "#sql#,scientific_name">
		</cfif>
		<cfif len(#specific_locality#) gt 0 and #specific_locality# is not "Annotate">
			<cfset sql = "#sql#,specific_locality">
		</cfif>
		<cfif len(#annotation_remarks#) gt 0 and #annotation_remarks# is not "Annotate">
			<cfset sql = "#sql#,annotation_remarks">
		</cfif>
		<cfset sql = "#sql# ) values (
				#collection_object_id#,
				'#session.username#'">		
		<cfif len(#higher_geography#) gt 0 and #higher_geography# is not "Annotate">
			<cfset sql = "#sql#,'#stripQuotes(urldecode(higher_geography))#'">
		</cfif>
		<cfif len(#scientific_name#) gt 0 and #scientific_name# is not "Annotate">
			<cfset sql = "#sql#,'#stripQuotes(urldecode(scientific_name))#'">
		</cfif>
		<cfif len(#specific_locality#) gt 0 and #specific_locality# is not "Annotate">
			<cfset sql = "#sql#,'#stripQuotes(urldecode(specific_locality))#'">
		</cfif>
		<cfif len(#annotation_remarks#) gt 0 and #annotation_remarks# is not "Annotate">
			<cfset sql = "#sql#,'#stripQuotes(urldecode(annotation_remarks))#'">
		</cfif>	
		<cfset sql = "#sql# )">
		<cfquery name="insAnn" datasource="uam_god">
			#preservesinglequotes(sql)#
		</cfquery>
		<cfquery name="whoTo" datasource="uam_god">
			select
				address
			FROM
				cataloged_item,
				collection,
				collection_contacts,
				electronic_address
			WHERE
				cataloged_item.collection_id = collection.collection_id AND
				collection.collection_id = collection_contacts.collection_id AND
				collection_contacts.contact_agent_id = electronic_address.agent_id AND
				collection_contacts.CONTACT_ROLE = 'data quality' and
				electronic_address.ADDRESS_TYPE='e-mail' and
				cataloged_item.collection_object_id=#collection_object_id#
		</cfquery>
		<cfif len(#whoTo.address#) gt 0>
			<cfset mailTo = valuelist(whoTo.address)>
		<cfelse>	
			<cfset mailTo = #Application.bugReportEmail#>
		</cfif>		
		<cfmail to="#mailTo#" from="annotation@#Application.fromEmail#" subject="Annotation Submitted" type="html">
			Arctos User #session.username# has submitted a specimen annotation. View details at
			<a href="#Application.ServerRootUrl#/info/annotate.cfm?action=show&collection_object_id=#collection_object_id#">
			#Application.ServerRootUrl#/info/annotate.cfm?action=show&collection_object_id=#collection_object_id#
			</a>
		</cfmail>	
	<cfcatch>
		<cfset result = "A database error occured: #cfcatch.message# #cfcatch.detail# #sql#">
		<cfreturn result>
	</cfcatch>
	</cftry>
	<cfset result = "success">
	<cfreturn result>	
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="changeshowObservations" access="remote">
	<cfargument name="tgt" type="string" required="yes">
	<cfif #tgt# is "true">
		<cfset t = 1>
	<cfelse>
		<cfset t = 0>
	</cfif>
	<cftry>
		<cfquery name="up" datasource="cf_dbuser">
			UPDATE cf_users SET
				showObservations = #t#
			WHERE username = '#session.username#'
		</cfquery>
		<cfset session.showObservations = "#t#">
		<cfset result="success">
		<cfcatch>
			<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
		</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="saveSpecSrchPref" access="remote">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="onOff" type="numeric" required="yes">
	<cfif isdefined("session.username") and len(#session.username#) gt 0>
		<cftry>
			<cfquery name="ins" datasource="cf_dbuser">
				select specsrchprefs from cf_users
				where username='#session.username#'
			</cfquery>
			<cfset cv=valuelist(ins.specsrchprefs)>
			<cfif onOff is 1>
				<cfif not listfind(cv,id)>
					<cfset nv=listappend(cv,id)>
				</cfif>
			<cfelse>
				<cfif listfind(cv,id)>
					<cfset nv=listdeleteat(cv,listfind(cv,id))>
				</cfif>
			</cfif>
			<cfquery name="ins" datasource="cf_dbuser">
				update cf_users set specsrchprefs='#nv#'
				where username='#session.username#'
			</cfquery>
			<cfcatch><!-- nada --></cfcatch>
		</cftry>
		<cfreturn "saved">
	</cfif>
	<cfreturn "cookie,#id#,#onOff#">
</cffunction>
<!-------------------------------------------->
</cfcomponent>