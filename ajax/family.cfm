<cfoutput>
	<cfquery name="pn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select family from taxonomy where upper(family) like '%#ucase(q)#%'
		group by family
		order by family
	</cfquery>
	<cfloop query="pn">
		#family# #chr(10)#
	</cfloop>
</cfoutput>