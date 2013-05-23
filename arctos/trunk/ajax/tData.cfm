<cfif #action# is "suggestGeologyAttVal">
	<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
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
<cfif #action# is "suggestFeature">
	<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			distinct(Feature) 
		from 
			geog_auth_rec
		where
			feature is not null and 
			upper(feature) LIKE '%#ucase(q)#%'
		 order by Feature
	</cfquery>
	<cfoutput query="ins">#attribute_value##chr(10)#
	</cfoutput>
</cfif>