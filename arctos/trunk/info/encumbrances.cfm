<cfinclude template="/includes/_header.cfm">
<cfset title="Active Encumbrances">
<script src="/includes/sorttable.js"></script>
<cfquery name="d" datasource="uam_god">
	select
		collection.collection_id,
		encumbrance.encumbrance_id,
		getPreferredAgentName(ENCUMBERING_AGENT_ID) encumberer,
		EXPIRATION_DATE,
		EXPIRATION_EVENT,
		ENCUMBRANCE,
		MADE_DATE,
		REMARKS,
		ENCUMBRANCE_ACTION,
		collection,
		count(coll_object_encumbrance.COLLECTION_OBJECT_ID) numberSpecimens
	from
		encumbrance,
		coll_object_encumbrance,
		cataloged_item,
		collection
	where
		encumbrance.encumbrance_id=coll_object_encumbrance.encumbrance_id and
		coll_object_encumbrance.COLLECTION_OBJECT_ID=cataloged_item.COLLECTION_OBJECT_ID and
		cataloged_item.collection_id=collection.collection_id 
	group by
		collection.collection_id,
		encumbrance.encumbrance_id,
		getPreferredAgentName(ENCUMBERING_AGENT_ID),
		EXPIRATION_DATE,
		EXPIRATION_EVENT,
		ENCUMBRANCE,
		MADE_DATE,
		REMARKS,
		ENCUMBRANCE_ACTION,
		collection
</cfquery>

<cfquery name="encs" dbtype="query">
	select 
		encumbrance_id,
		encumberer,
		ENCUMBRANCE_ACTION,
		EXPIRATION_DATE,
		EXPIRATION_EVENT,
		ENCUMBRANCE,
		MADE_DATE,
		REMARKS		
	from
		d
	group by
		encumbrance_id,
		encumberer,
		ENCUMBRANCE_ACTION,
		EXPIRATION_DATE,
		EXPIRATION_EVENT,
		ENCUMBRANCE,
		MADE_DATE,
		REMARKS	
</cfquery>
<cfoutput>
<h2>All Active Encumbrances</h2>	
<table border id="t" class="sortable">
		<tr>
			<th>Encumbering Agent</th>
			<th>Encumbrance Action</th>
			<th>Description</th>
			<th>Expiration Date</th>
			<th>Expiration Event</th>
			<th>Made Date</th>
			<th>Remarks</th>
			<th>Specimens</th>
		</tr>
		<cfloop query="encs">
			<tr>
				<td>#encumberer#</td>
				<td>#ENCUMBRANCE_ACTION#</td>
				<td>#ENCUMBRANCE#</td>
				<td>#dateformat(EXPIRATION_DATE,"YYYY-MM-DD")#</td>
				<td>#EXPIRATION_EVENT#</td>
				<td>#dateformat(MADE_DATE,"YYYY-MM-DD")#</td>
				<td>#REMARKS#</td>
				<cfquery name="cols" dbtype="query">
					select collection,numberSpecimens from d where encumbrance_id=#encumbrance_id# order by collection
				</cfquery>
				<td>
					<cfloop query="cols">
						<div>
							#collection#: #numberSpecimens#
						</div>
					</cfloop>
				</td>
			</tr>
		</cfloop>
	</table>
<h2>Encumbrances by action and collection</h2>


<cfquery name="sencs" datasource="uam_god">
	select
		collection.collection_id,
		collection,		
		decode (ENCUMBRANCE_ACTION,
			'mask record','mask record',
			'restrict usage','restrict usage',
			'hide or alter data') encaction,
		count(coll_object_encumbrance.COLLECTION_OBJECT_ID) under,
		count(cataloged_item.COLLECTION_OBJECT_ID) notunder		
	from
		collection,
		cataloged_item,
		coll_object_encumbrance,
		encumbrance
	where
		collection.collection_id = cataloged_item.collection_id and
		cataloged_item.COLLECTION_OBJECT_ID=coll_object_encumbrance.COLLECTION_OBJECT_ID (+) and
		coll_object_encumbrance.encumbrance_id=encumbrance.encumbrance_id (+)
	group by
		collection.collection_id,
		collection.collection,
		decode (ENCUMBRANCE_ACTION,
			'mask record','mask record',
			'restrict usage','restrict usage',
			'hide or alter data')
</cfquery>

<cfquery name="col" dbtype="query">
	select collection,collection_id from sencs group by  collection,collection_id order by collection
</cfquery>

<!----
<cfquery name="eac" dbtype="query">
	select
		decode (ENCUMBRANCE,
			'mask record','mask record',
			'restrict usage','restrict usage',
			'hide or alter data') encaction,
		collection,
		sum(numberSpecimens) affectedSpecimens
	from
		d
	group by
		decode (ENCUMBRANCE,
			'mask record','mask record',
			'restrict usage','restrict usage',
			'hide or alter data') encaction,
		collection
</cfquery>
---->
<table border id="t" class="sortable">
		<tr>
			<th>Collection</th>
			<th>Total Specimens</th>
			<th>Mask Record</th>
			<th>Restrict Usage</th>
			<th>Withhold Information</th>
		</tr>
		<cfloop query="col">
			<cfquery name="cs" dbtype="query">
				select 
					sum(notunder) as c
				from 
					sencs 
				where 
					collection_id=#collection_id#
			</cfquery>
			<cfquery name="etc" dbtype="query">
				select 
					encaction,
					under c
				from 
					sencs 
				where 
					collection_id=#collection_id#
			</cfquery>
			<cfdump var=#etc#>
			<tr>
				<td>#col.collection#</td>
				<td>#cs.c#</td>
				<td>##</td>
			</tr>
		</cfloop>
	</table>

</cfoutput>


<cfinclude template="/includes/_footer.cfm">