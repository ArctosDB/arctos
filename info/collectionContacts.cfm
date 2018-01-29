<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<style>
	.hasNoContact{color:red;}
</style>
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
			collection.collection_id=collection_contacts.collection_id (+)
		order by
			collection.guid_prefix,
			collection_contacts.CONTACT_ROLE,
			getPreferredAgentName(collection_contacts.CONTACT_AGENT_ID)
	</cfquery>
	<cfoutput>
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
							no data quality contact
						</div>
					</cfif>
					<cfquery name="hasLR" dbtype="query">
						select count(*) c from c where guid_prefix='#guid_prefix#' and activeEmail is not null
						and CONTACT_ROLE='loan request'
					</cfquery>
					<cfif hasLR.c lt 1>
						<div class="hasNoContact">
							no loan request contact
						</div>
					</cfif>
					<cfquery name="hasTS" dbtype="query">
						select count(*) c from c where guid_prefix='#guid_prefix#' and activeEmail is not null
						and CONTACT_ROLE='technical support'
					</cfquery>
					<cfif hasTS.c lt 1>
						<div class="hasNoContact">
							no technical support contact
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
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">
