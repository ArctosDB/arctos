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
	<cfoutput query="ins">#Feature##chr(10)#
	</cfoutput>
</cfif>
<cfif action is "suggestStateProv">
	<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			distinct(state_prov)
		from
			geog_auth_rec
		where
			state_prov is not null and
			upper(state_prov) LIKE '%#ucase(q)#%'
		 order by state_prov
	</cfquery>
	<cfoutput query="ins">#state_prov##chr(10)#
	</cfoutput>
</cfif>

<cfif action is "suggestQuad">
	<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			distinct(quad)
		from
			geog_auth_rec
		where
			quad is not null and
			upper(quad) LIKE '%#ucase(q)#%'
		 order by quad
	</cfquery>
	<cfoutput query="ins">#quad##chr(10)#
	</cfoutput>
</cfif>

<cfif action is "suggestCounty">
	<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			distinct(county)
		from
			geog_auth_rec
		where
			county is not null and
			upper(county) LIKE '%#ucase(q)#%'
		 order by county
	</cfquery>
	<cfoutput query="ins">#county##chr(10)#
	</cfoutput>
</cfif>

<cfif action is "suggestIsland">
	<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			distinct(island)
		from
			geog_auth_rec
		where
			island is not null and
			upper(island) LIKE '%#ucase(q)#%'
		 order by island
	</cfquery>
	<cfoutput query="ins">#island##chr(10)#
	</cfoutput>
</cfif>
<cfif action is "suggestDrainage">
	<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			distinct(drainage)
		from
			geog_auth_rec
		where
			drainage is not null and
			upper(drainage) LIKE '%#ucase(q)#%'
		 order by drainage
	</cfquery>
	<cfoutput query="ins">#drainage##chr(10)#
	</cfoutput>
</cfif>
