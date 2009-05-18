<cfcomponent>
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