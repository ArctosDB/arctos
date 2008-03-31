<cfset c="collection">
<cfset t="collection">
<cfquery name="ins" datasource="#Application.web_user#">
	SELECT 
		#c# data
	FROM 
		#t#
	group by #c#
	order by #c#
</cfquery>
	<cfoutput query="ins">#data#
	</cfoutput>