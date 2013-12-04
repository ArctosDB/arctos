<cfinclude template="/includes/_header.cfm">
<cfquery name="d">
	select
		getPreferredAgentName(ENCUMBERING_AGENT_ID) encumberer,
		EXPIRATION_DATE,
		EXPIRATION_EVENT,
		ENCUMBRANCE,
		MADE_DATE,
		REMARKS,
		ENCUMBRANCE_ACTION,
		count(	COLLECTION_OBJECT_ID ) numberSpecimens
	from
		encumbrance,
		coll_object_encumbrance
	where
		encumbrance.encumbrance_id=coll_object_encumbrance.encumbrance_id (+)
	group by
		getPreferredAgentName(ENCUMBERING_AGENT_ID) encumberer,
		EXPIRATION_DATE,
		EXPIRATION_EVENT,
		ENCUMBRANCE,
		MADE_DATE,
		REMARKS,
		ENCUMBRANCE_ACTION	
		
</cfquery>

<cfdump var=#d#>

<cfinclude template="/includes/_footer.cfm">