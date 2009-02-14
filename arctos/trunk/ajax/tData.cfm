<cfif #action# is "suggestGeologyAttVal">
	<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			attribute_value
		FROM 
			geology_attribute_hierarchy
		WHERE 
			upper(attribute_value) LIKE '%#ucase(q)#%'
			<cfif isdefined("t") and len(#t#) gt 0>and attribute='#t#'</cfif>
			group by attribute_value
	</cfquery>
	<cfoutput query="ins">#attribute_value##chr(10)#
	</cfoutput>
</cfif>