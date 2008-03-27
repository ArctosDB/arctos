<cfquery name="ins" datasource="#Application.web_user#">
	SELECT 
		#c#
	FROM 
		#t#
	group by #c#
	order by #c#
</cfquery>
	<cfoutput query="ins">#c#
	</cfoutput>