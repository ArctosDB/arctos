<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title="Find a Mentor">
<cfoutput>
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select
		GUID_PREFIX,
		COLLECTION,
		INSTITUTION,
		description,
		getPreferredAgentName(CONTACT_AGENT_ID) agentName,
		get_address(CONTACT_AGENT_ID, 'email') email
	from
		collection,
		collection_contacts
	where
		collection.collection_id=collection_contacts.collection_id and
		CONTACT_ROLE='mentor'
</cfquery>

The following people and collections have volunteered to serve as mentors; please contact any of them with any
questions regarding Arctos.

<table border>
	<tr>
		<th>Name</th>
		<th>Email</th>
		<th>Collection</th>
		<th>Collection Description</th>
	</tr>
	<cfloop query="d">
		<tr>
			<td>#agentName#</td>
			<td>#email#</td>
			<td>#INSTITUTION# #COLLECTION# (#GUID_PREFIX#)</td>
			<td>#description#</td>
		</tr>
	</cfloop>
</table>

</cfoutput>
<cfinclude template="/includes/_footer.cfm">