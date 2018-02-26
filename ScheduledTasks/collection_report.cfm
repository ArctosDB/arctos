<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title="collection contact report">
<style>
	.hasNoContact{color:red;}
</style>

<cfoutput>
	<cfquery name="coln" datasource="uam_god">
		select guid_prefix, collection_id from collection where upper(guid_prefix)='#ucase(guid_prefix)#'
	</cfquery>
	<cfif coln.recordcount neq 1>
		collection not found<cfabort>
	</cfif>
	<cfquery name="users" datasource="uam_god">
		select
			agent.agent_id,
			grantee username,
			agent.preferred_agent_name
		from
			dba_role_privs,
			agent_name,
			agent
		where
			upper(dba_role_privs.granted_role) = upper(replace('#guid_prefix#',':','_')) and
			upper(dba_role_privs.grantee) = upper(agent_name.agent_name) and
			agent_name.agent_name_type='login' and
			agent_name.agent_id=agent.agent_id
	</cfquery>

	<p>
		User report for collection #guid_prefix#
	</p>

	<cfloop query="users">
		<hr>
		<br>#users.username# #users.preferred_agent_name#
		<cfquery name="cct" datasource="uam_god">
			select * from collection_contacts where CONTACT_AGENT_ID=#users.agent_id#  and
			collection_contacts.collection_id=#coln.collection_id#
			order by CONTACT_ROLE
		</cfquery>
		<cfloop query="cct">
			<br>Collection Contact Role: #cct.CONTACT_ROLE#
		</cfloop>
		<cfquery name="acts" datasource="uam_god">
			select account_status FROM dba_users where username='#users.username#'
		</cfquery>
		<br>Account Status: #acts.account_status#

		<cfquery name="addr" datasource="uam_god">
			select * from address where agent_id=#users.agent_id#
		</cfquery>
		<p>
			Addresses
		</p>


		<table border>
			<tr>
				<th>Type</th>
				<th>Valid?</th>
				<th>Address</th>
			</tr>
			<cfloop query="addr">
				<tr>
					<td>#replace(ADDRESS_TYPE,chr(10),"<br>","all")#</td>
					<td><cfif VALID_ADDR_FG is 1>yes<cfelse>no</cfif></td>
					<td>#ADDRESS#</td>
				</tr>
			</cfloop>
		</table>

		<cfquery name="role" datasource="uam_god">
		select
					granted_role role_name
				from
					dba_role_privs
				where
					upper(grantee) = '#users.username#'
					and granted_role not in (select upper(replace(guid_prefix,':','_')) from collection)
			</cfquery>


			<cfdump var=#role#>
	</cfloop>


<!----

select
					granted_role role_name
				from
					dba_role_privs,
					collection
				where
					upper(dba_role_privs.granted_role) = upper(replace(collection.guid_prefix,':','_')) and
					upper(grantee) = '#ucasename#'




	<cfquery name="c" datasource="uam_god">
		select
			collection.guid_prefix,
			collection.collection_id,
			collection_contacts.CONTACT_ROLE,
			getPreferredAgentName(collection_contacts.CONTACT_AGENT_ID) contactName,
			get_address(collection_contacts.contact_agent_id,'email',1) activeEmail,
			get_address(collection_contacts.contact_agent_id,'email',0) allEmail
		from
			collection,
			collection_contacts
		where
			collection.guid_prefix='UAM:Mamm' and
			collection.collection_id=collection_contacts.collection_id (+)
		order by
			collection.guid_prefix,
			collection_contacts.CONTACT_ROLE,
			getPreferredAgentName(collection_contacts.CONTACT_AGENT_ID)
	</cfquery>
	<p>
		<ul>
			<li><strong>Email</strong> is email address attached to agent record</li>
			<li>
				<strong>Active Email</strong> is valid email address attached to agent record of active Operator. This is generally
				the only address used when sending notifications to collection contacts.
			</li>
		</ul>
	</p>

	<table border id="t" class="sortable">
		<tr>
			<th>Collection</th>
			<th>Contact</th>
			<th>Role</th>
			<th>Email</th>
			<th>Active Email</th>
		</tr>
		<cfloop query="c">
			<tr>

				<td>
					#c.guid_prefix#
					<cfquery name="hasDQ" dbtype="query">
						select count(*) c from c where guid_prefix='#guid_prefix#' and activeEmail is not null
						and CONTACT_ROLE='data quality'
					</cfquery>
					<cfif hasDQ.c lt 1>
						<div class="hasNoContact">
							no active data quality contact
						</div>
					</cfif>
					<cfquery name="hasLR" dbtype="query">
						select count(*) c from c where guid_prefix='#guid_prefix#' and activeEmail is not null
						and CONTACT_ROLE='loan request'
					</cfquery>
					<cfif hasLR.c lt 1>
						<div class="hasNoContact">
							no active loan request contact
						</div>
					</cfif>
					<cfquery name="hasTS" dbtype="query">
						select count(*) c from c where guid_prefix='#guid_prefix#' and activeEmail is not null
						and CONTACT_ROLE='technical support'
					</cfquery>
					<cfif hasTS.c lt 1>
						<div class="hasNoContact">
							no active technical support contact
						</div>
					</cfif>
				</td>
				<td>#c.contactName#</td>
				<td>#c.CONTACT_ROLE#</td>
				<td>#c.allEmail#</td>
				<td>#c.activeEmail#</td>

			</tr>
		</cfloop>
	</table>
	--->
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">
