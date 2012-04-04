<cfoutput>
	<cfquery name="pn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,jsessionid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select phylorder from taxonomy where upper(phylorder) like '%#ucase(q)#%'
		group by phylorder
		order by phylorder
	</cfquery>
	<cfloop query="pn">
		#phylorder# #chr(10)#
	</cfloop>
</cfoutput>