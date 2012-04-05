<cfoutput>
	<cfquery name="pn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select phylum from taxonomy where upper(phylum) like '%#ucase(q)#%'
		group by phylum
		order by phylum
	</cfquery>
	<cfloop query="pn">
		#phylum# #chr(10)#
	</cfloop>
</cfoutput>