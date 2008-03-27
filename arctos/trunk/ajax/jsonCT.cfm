<cfquery name="ins" datasource="#Application.web_user#">
	SELECT 
		#c#
	FROM 
		#t#
	order by #c#
	group by #c#
	
</cfquery>
	<cfoutput query="ins">#c#
	</cfoutput>
</cfif>