<cfoutput>
	<cfquery name="pn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select phylclass from taxonomy where upper(phylclass) like '%#ucase(q)#%'
		group by phylclass
		order by phylclass
	</cfquery>
	<cfloop query="pn">
		#phylclass# #chr(10)#
	</cfloop>
</cfoutput>