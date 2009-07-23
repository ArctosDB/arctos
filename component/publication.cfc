<cfcomponent>
<cffunction name="shortCitation" access="remote">
	<cfargument name="publication_id" type="numeric" required="yes">
	<cfquery name="p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select published_year from publication where publication_id=#publication_id#
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
		<cfquery name="p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select SUBSTR(publication_title,1,20) || '...' pt from publication where publication_id=#publication_id#
		</cfquery>
		<cfreturn p.pt>
	</cfif>
	<cfif a.recordcount is 1>
		<cfset as=a.last_name>
	<cfelseif a.recordcount is 2>
		<cfset as=a.last_name[1] & ' and ' & a.last_name[2]>
	<cfelse>
		<cfset as=a.last_name[1] & ' et al.'>
	</cfif>
	<cfset r=as & ' ' & p.published_year>
	<cfreturn r>
</cffunction>
<!------------------------------------------------------------------------------------------------>
<cffunction name="longCitation" access="remote" output="true">
	<cfargument name="publication_id" type="numeric" required="yes">
		<cfquery name="p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			publication_title,
			published_year,
			publication_type
		from publication where publication_id=#publication_id#
	</cfquery>
	<cfquery name="a" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			agent_name,
			author_position
		from 
			publication_author_name,
			agent_name
		where 
			publication_author_name.agent_name_id=agent_name.agent_name_id and
			publication_author_name.publication_id=#publication_id# and
			author_role='author'
		order by 
			author_position
	</cfquery>
	<cfquery name="e" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			agent_name,
			author_position
		from 
			publication_author_name,
			agent_name
		where 
			publication_author_name.agent_name_id=agent_name.agent_name_id and
			publication_author_name.publication_id=#publication_id# and
			author_role='editor'
		order by 
			author_position
	</cfquery>
	<cfset as="">
	<cfset es="">
	<cfif a.recordcount is 1>
		<cfset as=a.agent_name>
	<cfelseif a.recordcount is 2>
		<cfset as=a.agent_name[1] & ' and ' & a.agent_name[2]>
	<cfelse>
		<cfset as=valuelist(a.agent_name,", ")>	
	</cfif>
	<cfif right(as,1) is '.'>
		<cfset as=left(as,len(as)-1)>
	</cfif>
	<cfif e.recordcount is 1>
		<cfset es=e.agent_name>
	<cfelseif e.recordcount is 2>
		<cfset es=e.agent_name[1] & ' and ' & e.agent_name[2]>
	<cfelse>
		<cfset es=valuelist(e.agent_name,", ")>	
	</cfif>
	<cfif right(es,1) is '.'>
		<cfset es=left(es,len(es)-1)>
	</cfif>
	<cfquery name="atts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from publication_attributes where publication_id=#publication_id#
	</cfquery>
	<cfquery name="journal" dbtype="query">
		select pub_att_value from atts where publication_attribute='journal name'
	</cfquery>
	<cfquery name="issue" dbtype="query">
		select pub_att_value from atts where publication_attribute='issue'
	</cfquery>
	<cfquery name="volume" dbtype="query">
		select pub_att_value from atts where publication_attribute='volume'
	</cfquery>
	<cfquery name="begin" dbtype="query">
		select pub_att_value from atts where publication_attribute='begin page'
	</cfquery>
	<cfquery name="end" dbtype="query">
		select pub_att_value from atts where publication_attribute='end page'
	</cfquery>
	<cfquery name="pagetotal" dbtype="query">
		select pub_att_value from atts where publication_attribute='page total'
	</cfquery>
	<cfif right(p.publication_title,1) is not '.' and right(p.publication_title,1) is not '?'>
		<cfset publication_title=p.publication_title & '.'>
	<cfelse>
		<cfset publication_title=p.publication_title>
	</cfif> 
	<cfif p.publication_type is "journal article">
		<cfset r=as & '. ' & p.published_year & '. ' & publication_title>
		<cfset r=r & ' ' & journal.pub_att_value>
		<cfif len(volume.pub_att_value) gt 0>
			<cfset r=r & ' ' & volume.pub_att_value>
		</cfif>
		<cfif len(issue.pub_att_value) gt 0>
			<cfset r=r & '(' & issue.pub_att_value & ')'>
		</cfif>
		<cfset r=r & ':' & 	begin.pub_att_value & '-' & end.pub_att_value & '.'>
	<cfelseif p.publication_type is "book">
		<cfset r=as & '. ' & p.published_year & '. ' & publication_title>
		<cfif len(volume.pub_att_value) gt 0>
			<cfset r=r & ' Volume ' & volume.pub_att_value>
		</cfif>
		<cfif len(pagetotal.pub_att_value) gt 0>
			<cfset r=r & ' ' & pagetotal.pub_att_value & 'pp.'>
		</cfif>
	<cfelseif p.publication_type is "book section">
		<cfset r=as & '. ' & p.published_year & '. ' & publication_title>
		<cfif len(volume.pub_att_value) gt 0>
			<cfset r=r & ' Volume ' & volume.pub_att_value & '.'>
		</cfif>
		<cfif len(pagetotal.pub_att_value) gt 0>
			<cfset r=r & ' ' & pagetotal.pub_att_value & 'pp.'>
		</cfif>
		<cfif len(es) gt 0>
			<cfset r=r & ' Edited by ' & es & '.'>
		</cfif>
	<cfelse>
		<cfset r=as>
		<cfif len(p.published_year) gt 0>
			<cfset r=r & '. ' & p.published_year>
		</cfif>
		<cfset r=r & '. ' & publication_title>
	</cfif>
	<cfif len(r) is 0>
		<cfset r="unknown format">
	</cfif>
	<cfreturn r>
</cffunction>
</cfcomponent>