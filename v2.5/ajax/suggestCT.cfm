<cfquery name="ins" datasource="#Application.web_user#">
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