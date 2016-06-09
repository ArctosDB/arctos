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
				select agent_id from  agent_relations where agent_relationship='bad duplicate of'
			) and
			regexp_like(preferred_agent_name,'[^A-Za-z -.]')
	</cfquery>

	<cfloop query="raw">
		<br>#preferred_agent_name#
		<cfset mname=rereplace(preferred_agent_name,'[^A-Za-z -.]','_')>
		<br>   -->  #mname#

		<cfquery name="hasascii"  datasource="uam_god">
			 select agent_name from agent_name where agent_id=#agent_id# and agent_name like '#mname#' and
			 regexp_like(agent_name,'^[A-Za-z -.]*$')
		</cfquery>
		<cfif hasascii.recordcount lt 1>
			<cfset baidlist=listappend(baidlist,agent_id)>
			<p>
				-------this one has no good agent ---------
			</p>
		</cfif>
	</cfloop>

	these are funky: #baidlist#


	<cfquery name="funk"  datasource="uam_god">
		select
			agent_id,
			preferred_agent_name,
			CREATED_BY_AGENT_ID,
			getPreferredAgentName(CREATED_BY_AGENT_ID) cb
		from
			agent
		where
			agent_id in (#baidlist#)
		order by
			CREATED_BY_AGENT_ID,
			preferred_agent_name
	</cfquery>

	<p>
		the funk:<cfdump var=#funk#>
	</p>


	<cfquery name="creators" dbtype="query">
		select CREATED_BY_AGENT_ID from funk group by CREATED_BY_AGENT_ID
	</cfquery>
	<cfquery name="getCreatorEmail"  datasource="uam_god">
		select distinct ADDRESS from address where address_type='email' and agent_id in (#valuelist(creators.CREATED_BY_AGENT_ID)#)
	</cfquery>

	<br />
	<p>
		the getCreatorEmail:<cfdump var=#getCreatorEmail#>
	</p>

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
	<cfdump var=#creatorCollections#>


	<cfquery name="allAddEmails" dbtype="query">
		select ADDRESS from getCreatorEmail union select address from creatorCollections
	</cfquery>
	<cfquery name="addEmails" dbtype="query">
		select address from allAddEmails group by address
	</cfquery>

	<cfdump var=#addEmails#>
	<p>

		^^^^ is the collectionmanager of all collections which have users who have created funky agents

	</p>


	<hr>
		Agents which may not comply with the agent creation guidelines (https://arctosdb.org/documentation/agent/##create) have been detected.
		<p>
			If you are receiving this email, you have created a noncompliant agent, or
			have manage_collection roles for a user who has created a noncompliant agent.
		</p>
		<p>
			Please review the following agents and make corrections as appropriate.
		</p>
		<p>
			If you are a collection manager, please ensure that everyone with manage_agents rights in your collection
			has read and understands the agent creation guidelines.
		</p>
		<p>
			<cfloop query="funk">
				<br><a href="#application.serverRootURL#/agents.cfm?agent_id=#agent_id#">#PREFERRED_AGENT_NAME#</a> (created by #cb#)
			</cfloop>
		</p>
	<hr>

<!-----
	<cfloop query="creators">
		<br>#CREATED_BY_AGENT_ID#
		<!--- find their collections ---->
		<cfquery name="creatorCollections"  datasource="uam_god">
			select distinct
				GRANTEE,
				GRANTED_ROLE
			from
				dba_role_privs,
				agent_name,
				collection
			where
				dba_role_privs.GRANTEE=upper(agent_name.agent_name) and
				dba_role_privs.GRANTED_ROLE=replace(upper(guid_prefix),':','_') and
				agent_name.agent_name_type='login' and
				agent_name.agent_id = #CREATED_BY_AGENT_ID#
		</cfquery>
		<cfdump var=#creatorCollections#>

		<cfloop query="creatorCollections">
			<cfquery name="creatorCollectionManager"  datasource="uam_god">
				select distinct
					a.GRANTEE
				from
					dba_role_privs a,
					dba_role_privs b
				where
					a.grantee=b.grantee and
					a.GRANTED_ROLE='MANAGE_COLLECTION' AND
					b.GRANTED_ROLE='#GRANTED_ROLE#'
			</cfquery>
			<cfdump var=#creatorCollectionManager#>

		</cfloop>

	</cfloop>

	----->
	<!----
	<cfquery name="getCreatorCollectionEmail"  datasource="uam_god">
		select
			GRANTEE,
			GRANTED_ROLE
		from
			dba_role_privs creator,
			agent_name creatoragent
		where
			creator.GRANTEE=upper(creatoragent.agent_name) and
			creatoragent.agent_name_type='login' and
			creatoragent.agent_id in (#valuelist(creators.CREATED_BY_AGENT_ID)#)
	</cfquery>

	<cfdump var=#getCreatorCollectionEmail#>

	---->






</cfoutput>
	<!----------
	<cfquery name="enc" dbtype="query">
		select
			ENCUMBRANCE_ID,
			EXPIRATION_DATE,
			ENCUMBRANCE,
			REMARKS,
			MADE_DATE,
			ENCUMBRANCE_ACTION,
			encumberer
		from
			raw
		group by
			ENCUMBRANCE_ID,
			EXPIRATION_DATE,
			ENCUMBRANCE,
			REMARKS,
			MADE_DATE,
			ENCUMBRANCE_ACTION,
			encumberer
	</cfquery>
	<cfloop query="enc">
		<cfquery name="mt" dbtype="query">
			select
				collection_contact_email
			from
				raw
			where
				collection_contact_email is not null and
				encumbrance_id=#encumbrance_id#
			group by
				collection_contact_email
		</cfquery>
		<cfquery name="sp" dbtype="query">
			select guid_prefix,nspc from raw where encumbrance_id=#encumbrance_id# group by guid_prefix,nspc
		</cfquery>
		<cfif isdefined("Application.version") and  Application.version is "prod">
			<cfset subj="Arctos Encumbrance Notification">
			<cfset maddr=valuelist(mt.collection_contact_email)>
		<cfelse>
			<cfset maddr=application.bugreportemail>
			<cfset subj="TEST PLEASE IGNORE: Arctos Encumbrance Notification">
		</cfif>
		<cfmail to="#maddr#" bcc="#Application.LogEmail#" subject="#subj#" from="encumbrance_notification@#Application.fromEmail#" type="html">
			<p>
				You are receiving this message because you are a collection contact for a collection holding encumbered specimens.
			</p>
			<p>
				Please review encumbrance <strong>#enc.ENCUMBRANCE#</strong> created by <strong>#enc.encumberer#</strong> on
				<strong>#enc.MADE_DATE#</strong>, expires <strong>#enc.EXPIRATION_DATE#</strong>.
			</p>
			<p>
				Specimen data are available at
				<a href="#Application.serverRootURL#/SpecimenResults.cfm?encumbrance_id=#encumbrance_id#">
					#Application.serverRootURL#/SpecimenResults.cfm?encumbrance_id=#encumbrance_id#
				</a>
			</p>
			<p>
				The encumbrance may be accessed at
				<a href="#Application.serverRootURL#/Encumbrances.cfm?action=updateEncumbrance&encumbrance_id=#encumbrance_id#">
					#Application.serverRootURL#/Encumbrances.cfm?action=updateEncumbrance&encumbrance_id=#encumbrance_id#
				</a>
			</p>
			<p>
				Please remove specimens from and delete any un-needed encumbrances.
			</p>
			<p>
				Summary of encumbered specimens:
				<cfloop query="sp">
					<p>
					#guid_prefix#: #nspc#
					</p>
				</cfloop>
			</p>
			#emailFooter#
		</cfmail>
	</cfloop>

	----------->

<cfinclude template="/includes/_footer.cfm">
	<!--- end of encumbrance code --->