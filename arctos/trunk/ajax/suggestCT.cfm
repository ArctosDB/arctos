<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	SELECT 
		#f# data
	FROM 
		#t#
	where upper(#f#) like '%#ucase(q)#%'
	group by #f#
	order by #f#
</cfquery>
	<cfoutput query="ins">#data#
	</cfoutput>