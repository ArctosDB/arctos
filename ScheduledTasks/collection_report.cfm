<!---
	IMPORTANT

	this is a companion file to info/collection_report.

	ScheduledTasks is fast, minimal, and send email.

	info is a comprehensive summary of your collection's users

---->

<cfset summary=querynew("u,p,s,c")>
<cfoutput>
	<cfquery name="CTCOLL_CONTACT_ROLE" datasource="uam_god">
		select
			CONTACT_ROLE
		from
			CTCOLL_CONTACT_ROLE
		where
			CONTACT_ROLE not in ('mentor')
		order by
			CONTACT_ROLE
	</cfquery>

	<cfquery name="colns" datasource="uam_god">
		select * from collection order by guid_prefix
	</cfquery>

	<cfloop query="colns">
		<cfsavecontent variable="crept">
			<hr>	Collection and User report for #guid_prefix#

			<p>
				Details and tools are available at
				<a href="#Application.serverRootUrl#/info/collection_report.cfm?guid_prefix=#guid_prefix#">
					#Application.serverRootUrl#/info/collection_report.cfm?guid_prefix=#guid_prefix#
				</a>
			</p>
			<p>
				Get started in the Arctos Github Community at <a href="https://doi.org/10.7299/X75B02M5">https://doi.org/10.7299/X75B02M5</a>
			</p>

			<cfquery name="users" datasource="uam_god">
				select
					grantee,
					preferred_agent_name
				from
					dba_role_privs,
					agent_name,
					dba_users,
					agent
				where
					upper(dba_role_privs.granted_role)= upper(replace('#guid_prefix#',':','_')) and
					dba_role_privs.grantee=upper(agent_name.agent_name) and
					agent_name.agent_name_type='login' and
					agent_name.agent_id=agent.agent_id and
					dba_role_privs.grantee=dba_users.username and
					dba_users.account_status='OPEN'
				order by preferred_agent_name
			</cfquery>
			<cfquery name="contacts"  datasource="uam_god">
				select
					get_address(collection_contacts.contact_agent_id,'email') address,
					collection_contacts.CONTACT_ROLE,
					agent.preferred_agent_name
				from
					collection_contacts,
					agent
				where
					collection_contacts.collection_id=#collection_id# and
					collection_contacts.contact_agent_id=agent.agent_id
				order by preferred_agent_name
			</cfquery>
			<cfloop query="CTCOLL_CONTACT_ROLE">
				<cfquery name="hasActiveContact" dbtype="query">
					select count(*) c from contacts where address is not null and CONTACT_ROLE='#CONTACT_ROLE#'
				</cfquery>
				<cfif hasActiveContact.c lt 1>
					<p>
						WARNING: collection has no active #CONTACT_ROLE# contact!
					</p>
				</cfif>
			</cfloop>
			<p>
				Active Collection Users
				<table border>
					<tr>
						<td>PreferredName</td>
						<td>Username</td>
					</tr>
					<cfloop query="users">
						<tr>
							<td>#preferred_agent_name#</td>
							<td>#grantee#</td>
						</tr>
					</cfloop>
				</table>
			</p>

			<p>
				Collection Contacts
				<br>NOTE: contacts without an email address may not have a "valid" email, or their account may be locked.
				<table border>
					<tr>
						<td>PreferredName</td>
						<td>Role</td>
						<td>Email</td>
					</tr>
					<cfloop query="contacts">
						<tr>
							<td>#preferred_agent_name#</td>
							<td>#CONTACT_ROLE#</td>
							<td>#address#</td>
						</tr>
					</cfloop>
				</table>
				<cfquery name="mailto" dbtype="query">
					select distinct address from contacts where CONTACT_ROLE in ('data quality')
				</cfquery>
				<cfif len(valuelist(mailto.address)) gt 0>
					<cfset mt=valuelist(mailto.address)>
					<cfset intro='You are receiving this message because you are a data quality contact for collection #guid_prefix#.'>
				<cfelse>
					<cfset mt=Application.DataProblemReportEmail>
					<cfset intro='You are receiving this message because you are a data report contact for Arctos,
						and collection #guid_prefix# has no data quality contact.'>
				</cfif>

			</cfsavecontent>
			<cfif isdefined("Application.version") and  Application.version is "prod">
				<cfset subj="Arctos Collection Report">
				<cfset maddr="#mt#, arctos.database@gmail.com">
			<cfelse>
				<cfset maddr=application.bugreportemail>
				<cfset subj="TEST PLEASE IGNORE: Arctos Collection Report">
			</cfif>
<!----
			<p>
				mailto: #mt#
			</p>
			<p>
				intro: #intro#
			</p>
			<p>
				subj: #subj#
			</p>
			<p>
				mt: #mt#
			</p>
			<p>
				maddr: #maddr#
			</p>

			<p>
				body...
			</p>
			<p>
				#crept#
			</p>
			---->
			<cfmail to="#maddr#" subject="#subj#" from="collection_report@#Application.fromEmail#" type="html">
				<p>
					#intro#
				</p>
				<p>
					#crept#
				</p>
			</cfmail>
		</cfloop>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">
