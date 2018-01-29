<cfinclude template="/includes/_header.cfm">
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
	<table border>
		<tr>
			<th>Collection</th>
			<th>Contact</th>
			<th>Email</th>
			<th>Active Email</th>
		</tr>
		<cfloop query="c">
			<tr>
				<td>#c.guid_prefix#</td>
				<td>#c.contactName#</td>
				<td>#c.allEmail#</td>
				<td>#c.activeEmail#</td>

			</tr>
		</cfloop>
	</table>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">
