<cfset c="collection">
<cfset t="collection">
<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT 
		#c# data
	FROM 
		#t#
	group by #c#
	order by #c#
</cfquery>
[
	<cfoutput query="ins">{optionValue:'#data#', optionDisplay: '#data#'},
	</cfoutput>
	]