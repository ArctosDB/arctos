<cfif #action# is "suggestGeologyAttVal">
	<cfquery name="ins" datasource="#Application.web_user#">
		SELECT 
			attribute_value
		FROM 
			geology_attribute_hierarchy
		WHERE 
			upper(attribute_value) LIKE '%#ucase(q)#%'
			<cfif isdefined("t") and len(#t#) gt 0>and attribute='#t#'</cfif>
			group by attribute_value
	</cfquery>
	<cfoutput query="ins">#attribute_value#
	</cfoutput>
</cfif>