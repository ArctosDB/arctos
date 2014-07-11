<cfoutput>
	<cfquery name="pn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select scientific_name
		from taxon_name
		where upper(scientific_name) like '%#ucase(q)#%'
		order by scientific_name
	</cfquery>
	<cfloop query="pn">
		#scientific_name# #chr(10)#
	</cfloop>
</cfoutput>