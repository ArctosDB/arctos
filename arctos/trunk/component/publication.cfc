<cfcomponent>
<cffunction name="shortCitation" access="remote">
	<cfargument name="publication_id" type="numeric" required="yes">
	<cfquery name="p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select publication_year from publication where publication_id=#publication_id#
	</cfquery>
	<cfquery name="a" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			last_name,
			author_position
		from 
			publication_author_name,
			agent_name,
			person
		where 
			publication_author_name.agent_name_id=agent_name.agent_name_id and
			agent_name.agent_id=person.person_id and
			publication_author_name.publication_id=#publication_id#
		order by 
			author_position
	</cfquery>
	<cfquery name="f" dbtype="query">
		select count(*) c from a where last_name is null
	</cfquery>
	<cfif f.c gt 0>
		<cfreturn "fail: null last names.">
	</cfif>
	<cfif a.recordcount is 1>
		<cfset as=a.last_name>
	<cfelseif auth.recordcount is 2>
		<cfset as=a.last_name[1] & ' and ' & a.last_name[2]>
	<cfelse>
		<cfset as=a.last_name[1] & ' et al.'>
	</cfif>
	<cfset r=as & ' ' & p.publication_year>
	<cfreturn r>
</cffunction>
</cfcomponent>