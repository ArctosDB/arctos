<cfcomponent>

<!--------------------------------------------------------------------------------------------------------->
<cffunction name="getSSSpecimens" access="remote" returnformat="plain" queryFormat="column">
	<cfparam name="what" type="string" default="">
	<cfparam name="where" type="string" default="">
	<cfparam name="minDate" type="string" default="">
	<cfparam name="maxDate" type="string" default="">

	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from flat where rownum<=100 and
		<cfif isdefined("what") and len(what) gt 0>
			upper(scientific_name) like '%#ucase(what)#%'
		</cfif>
	</cfquery>


	<cfreturn d>

</cffunction>

</cfcomponent>
