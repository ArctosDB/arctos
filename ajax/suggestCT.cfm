<cfquery name="ins" datasource="#Application.web_user#">
	SELECT 
		#f# data
	FROM 
		#t#
	group by #f#
	order by #f#
</cfquery>
	<cfoutput query="ins">#data#
	</cfoutput>