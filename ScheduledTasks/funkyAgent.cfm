<!--------
drop table temp;

create table temp as 
 select
      		agent_id,
			preferred_agent_name
    	from
			agent
		where
			agent_type='person' and
			CREATED_BY_AGENT_ID != 0 and
    		agent_id not in (
				select agent_id from  agent_relations where agent_relationship='bad duplicate of' union
				select related_agent_id from  agent_relations where agent_relationship='bad duplicate of'
			) and
			regexp_like(preferred_agent_name,'[^A-Za-z -.]')
		;
		
drop table temp2;

create table temp2 as 
select
			agent_id,
			preferred_agent_name,
			CREATED_BY_AGENT_ID,
			getPreferredAgentName(CREATED_BY_AGENT_ID) createdBy,
			'no_ascii_variant' reason
		from
			agent
		where
			agent_id in (#baidlist#)
		order by
			CREATED_BY_AGENT_ID,
			preferred_agent_name	;
			
			
			---------->
			
<cfsavecontent variable="emailFooter">
	<div style="font-size:smaller;color:gray;">
		--
		<br>Don't want these messages? Update Collection Contacts.
		<br>Want these messages? Update Collection Contacts, make sure you have a valid email address.
		<br>Links not working? Log in, log out, or check encumbrances.
		<br>Need help? Send email to arctos.database@gmail.com
	</div>
</cfsavecontent>
<cfoutput>
	<cfset baidlist="">
	<cfquery name="raw" datasource="uam_god">
		 select
      		agent_id,
			preferred_agent_name
    	from
			agent
		where
			agent_type='person' and
			CREATED_BY_AGENT_ID != 0 and
    		agent_id not in (
				select agent_id from  agent_relations where agent_relationship='bad duplicate of' union
				select related_agent_id from  agent_relations where agent_relationship='bad duplicate of'
			) and
			regexp_like(preferred_agent_name,'[^A-Za-z -.]')
	</cfquery>
	<cfloop query="raw">
		<cfset mname=rereplace(preferred_agent_name,'[^A-Za-z -.]','_','all')>
		<cfquery name="hasascii"  datasource="uam_god">
			 select agent_name from agent_name where agent_id=#agent_id# and agent_name like '#mname#' and
			 regexp_like(agent_name,'^[A-Za-z -.]*$')
		</cfquery>
		<cfif hasascii.recordcount lt 1>
			<cfset baidlist=listappend(baidlist,agent_id)>
		</cfif>
	</cfloop>
	<cfquery name="funk1"  datasource="uam_god">
		select
			agent_id,
			preferred_agent_name,
			CREATED_BY_AGENT_ID,
			getPreferredAgentName(CREATED_BY_AGENT_ID) createdBy,
			'no_ascii_variant' reason
		from
			agent
		where
			agent_id in (#baidlist#)
		order by
			CREATED_BY_AGENT_ID,
			preferred_agent_name
	</cfquery>

	<cfset baidlist="">
	<cfquery name="raw" datasource="uam_god">
		 select
      		agent_id,
			preferred_agent_name
    	from
			agent
		where
			CREATED_BY_AGENT_ID != 0 and
    		agent_id not in (
				select agent_id from  agent_relations where agent_relationship='bad duplicate of'
			) and
			(
				lower(preferred_agent_name) like '% co.%' or
				lower(preferred_agent_name) like '% inc.%'
			)
	</cfquery>
	<cfloop query="raw">
		<cfset mname=preferred_agent_name>
		<cfset mname=replacenocase(mname,' inc.',' incorporated')>
		<cfset mname=replacenocase(mname,' co.',' company')>
		<cfquery name="hasascii"  datasource="uam_god">
			 select agent_name from agent_name where agent_id=#agent_id# and lower(agent_name) like '#lcase(mname)#'
		</cfquery>
		<cfif hasascii.recordcount lt 1>
			<cfset baidlist=listappend(baidlist,agent_id)>
		</cfif>
	</cfloop>

	<cfquery name="funk2"  datasource="uam_god">
		select
			agent_id,
			preferred_agent_name,
			CREATED_BY_AGENT_ID,
			getPreferredAgentName(CREATED_BY_AGENT_ID) createdBy,
			'no_unabbreviated_variant' reason
		from
			agent
		where
			agent_id in (#baidlist#)
		order by
			CREATED_BY_AGENT_ID,
			preferred_agent_name
	</cfquery>

	<cfset baidlist="">
	<cfquery name="raw" datasource="uam_god">
		 select
      		agent_id,
			preferred_agent_name
    	from
			agent
		where
			CREATED_BY_AGENT_ID != 0 and
    		agent_id not in (
				select agent_id from  agent_relations where agent_relationship='bad duplicate of'
			) and
			(
				lower(preferred_agent_name) like '%&%'
			)
	</cfquery>
	<cfloop query="raw">
		<cfset mname=preferred_agent_name>
		<cfset mname=replacenocase(mname,'&','and')>
		<cfquery name="hasascii"  datasource="uam_god">
			 select agent_name from agent_name where agent_id=#agent_id# and lower(agent_name) like '#lcase(mname)#'
		</cfquery>
		<cfif hasascii.recordcount lt 1>
			<cfset baidlist=listappend(baidlist,agent_id)>
		</cfif>
	</cfloop>

	<cfquery name="funk3"  datasource="uam_god">
		select
			agent_id,
			preferred_agent_name,
			CREATED_BY_AGENT_ID,
			getPreferredAgentName(CREATED_BY_AGENT_ID) createdBy,
			'no_unampersanded_variant' reason
		from
			agent
		where
			agent_id in (#baidlist#)
		order by
			CREATED_BY_AGENT_ID,
			preferred_agent_name
	</cfquery>
	<cfquery name="funk_norder" dbtype="query">
		select * from funk1 union select * from funk2 union select * from funk3
	</cfquery>
	<cfquery name="funk" dbtype="query">
		select * from funk_norder order by preferred_agent_name
	</cfquery>

	<cfquery name="creators" dbtype="query">
		select CREATED_BY_AGENT_ID from funk group by CREATED_BY_AGENT_ID
	</cfquery>
	<cfquery name="getCreatorEmail"  datasource="uam_god">
		select distinct ADDRESS from address where VALID_ADDR_FG=1 and address_type='email' and agent_id in (#valuelist(creators.CREATED_BY_AGENT_ID)#)
	</cfquery>

	<cfquery name="creatorCollections"  datasource="uam_god">
		select distinct
			a.GRANTEE,
			address
		from
			dba_role_privs a,
			dba_role_privs b,
			agent_name,
			address
		where
			VALID_ADDR_FG=1 and
			a.grantee=b.grantee and
			a.GRANTED_ROLE='MANAGE_COLLECTION' AND
			address_type='email' and
			a.grantee=upper(agent_name) and
			agent_name_type='login' and
			agent_name.agent_id=address.agent_id and
			b.GRANTED_ROLE in (
			select distinct
				GRANTED_ROLE
			from
				dba_role_privs,
				agent_name,
				collection
			where
				dba_role_privs.GRANTEE=upper(agent_name.agent_name) and
				dba_role_privs.GRANTED_ROLE=replace(upper(guid_prefix),':','_') and
				agent_name.agent_name_type='login' and
				agent_name.agent_id in (#valuelist(creators.CREATED_BY_AGENT_ID)#)
			)
	</cfquery>
	<cfquery name="allAddEmails" dbtype="query">
		select ADDRESS from getCreatorEmail union select address from creatorCollections
	</cfquery>
	<cfquery name="addEmails" dbtype="query">
		select address from allAddEmails group by address
	</cfquery>
	<cfif isdefined("Application.version") and  Application.version is "prod">
		<cfset subj="Arctos Noncompliant Agent Notification">
		<cfset maddr=valuelist(addEmails.ADDRESS)>
	<cfelse>
		<cfset maddr=application.bugreportemail>
		<cfset subj="TEST PLEASE IGNORE: Arctos Noncompliant Agent Notification">
	</cfif>
	<cfmail to="#maddr#" bcc="#Application.LogEmail#" subject="#subj#" from="suspect_agent@#Application.fromEmail#" type="html">
		<cfif not isdefined("Application.version") or Application.version is not "prod">
			<hr>prod would have sent this email to #valuelist(addEmails.ADDRESS)#<hr>
		</cfif>
		Agents which may not comply with the Arctos Agent Creation Guidelines (https://arctosdb.org/documentation/agent/##create)
			have been detected. If you are receiving this email, you have either created a potentially noncompliant agent or
			have manage_collection roles for a user who has created a potentially noncompliant agent. If you are a collection manager,
			please ensure that everyone with manage_agents rights in your collection
			has read and understands the agent creation guidelines.
		</p>
		<p>
			Please use the <a href="#application.serverRootURL#/contact.cfm?ref=noncompliant_agent_notice">contact</a> link at the bottom of any Arctos form
			if you believe you have received this mail in error, or if you wish to discuss the Arctos Agent Creation Guidelines.
		<p>
			Please review the following agents and make corrections or additions as appropriate.
		</p>
		<p>
			<cfloop query="funk">
				<br><a href="#application.serverRootURL#/agents.cfm?agent_id=#agent_id#">#PREFERRED_AGENT_NAME#</a>
				<br>&nbsp;&nbsp;&nbsp;CreatedBy: #createdBy#
				<br>&nbsp;&nbsp;&nbsp;Problem: #reason#
			</cfloop>
		</p>
		#emailFooter#
	</cfmail>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">