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



	<p>
		the getCreatorEmail:<cfdump var=#getCreatorEmail#>
	</p>

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