<cfif #action# is "suggestGeologyAttVal">
			<cfquery name="ins" datasource="#Application.web_user#">
				SELECT attribute_value
		FROM geology_attribute_hierarchy
		WHERE upper(attribute_value) LIKE '%#ucase(q)#%'
		group by attribute_value
		</cfquery>
	<cfoutput query="ins"><cfif isdefined("type")>--#type#--</cfif>#attribute_value#
	</cfoutput>
</cfif>