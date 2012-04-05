<cfoutput>
	<cfquery name="pn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select regexp_replace(project.project_name,'<[^>]*>') project_name from project where upper(regexp_replace(project.project_name,'<[^>]*>')) like '%#ucase(q)#%'
		order by project_name
	</cfquery>
	<cfloop query="pn">
		#project_name# #chr(10)#
	</cfloop>
</cfoutput>