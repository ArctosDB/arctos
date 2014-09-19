<cfinclude template="/includes/_header.cfm">
<cfset title="Active Encumbrances">
<script src="/includes/sorttable.js"></script>
<cfquery name="d" datasource="uam_god" cachedwithin="#createtimespan(1,0,0,0)#">
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
		guid_prefix,
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
		guid_prefix
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
					select guid_prefix,numberSpecimens from d where encumbrance_id=#encumbrance_id# order by guid_prefix
				</cfquery>
				<td>
					<cfloop query="cols">
						<div>
							#guid_prefix#: #numberSpecimens#
						</div>
					</cfloop>
				</td>
			</tr>
		</cfloop>
	</table>


<cfquery name="sencs" datasource="uam_god" cachedwithin="#createtimespan(1,0,0,0)#">
  select
    guid_prefix, 
    count(distinct(cataloged_item.COLLECTION_OBJECT_ID)) collnSize,
    count(distinct(allencs.COLLECTION_OBJECT_ID)) numberEncumberedRecords,
    count(distinct(maskrecord.COLLECTION_OBJECT_ID)) numberMaskedRecords,
    count(distinct(restrictusage.COLLECTION_OBJECT_ID)) numberRestrictedRecords,
    count(distinct(infowithheld.COLLECTION_OBJECT_ID)) numberWithheldRecords
  from
    collection,
    cataloged_item,
    coll_object_encumbrance allencs,
    (
        select 
          collection_object_id 
        from 
          coll_object_encumbrance,
          encumbrance 
        where 
          coll_object_encumbrance.encumbrance_id=encumbrance.encumbrance_id and 
          encumbrance_action='mask record'
    ) maskrecord,
    (
        select 
          collection_object_id 
        from 
          coll_object_encumbrance,
          encumbrance 
        where 
          coll_object_encumbrance.encumbrance_id=encumbrance.encumbrance_id and 
          encumbrance_action='restrict usage'
    ) restrictusage,
    (
        select 
          collection_object_id 
        from 
          coll_object_encumbrance,
          encumbrance 
        where 
          coll_object_encumbrance.encumbrance_id=encumbrance.encumbrance_id and 
          encumbrance_action not in ('restrict usage','mask record')
    ) infowithheld
  where
    collection.collection_id = cataloged_item.collection_id and
    cataloged_item.COLLECTION_OBJECT_ID=allencs.COLLECTION_OBJECT_ID (+) and
    cataloged_item.COLLECTION_OBJECT_ID=maskrecord.COLLECTION_OBJECT_ID (+) and
    cataloged_item.COLLECTION_OBJECT_ID=restrictusage.COLLECTION_OBJECT_ID (+) and
    cataloged_item.COLLECTION_OBJECT_ID=infowithheld.COLLECTION_OBJECT_ID (+)
  group by
    collection.guid_prefix
  order by
    collection.guid_prefix
</cfquery>
<h2>Encumbrances by Type and Collection</h2>

<ul>
	<li><strong>Hidden</strong>: Data are not publicly available</li>
	<li><strong>Restricted</strong>: Data are available, but certain conditions (e.g., permission of an agency) are required for use.</li>
	<li><strong>Withheld</strong> Data are selectively available, specimens are excluded from queries which might reveal restricted data.</li>
</ul>
<table border id="t" class="sortable">
		<tr>
			<th>Collection</th>
			<th>Total Specimens</th>
			
			<th>## Encumbered</th>
			<th>% Encumbered</th>
			
			<th>## Hidden</th>
			<th>% Hidden</th>
			
			<th>## Restricted</th>
			<th>% Restricted</th>
			
			<th>## Withheld</th>
			<th>% Withheld</th>
		</tr>
		<cfloop query="sencs">
		

			<tr>
				<td>#guid_prefix#</td>
				<td>#collnSize#</td>
				
				<td>#numberEncumberedRecords#</td>
				<td>#numberformat(100 * (numberEncumberedRecords/collnSize),"99.99")#</td>
				
				<td>#numberMaskedRecords#</td>
				<td>#numberformat(100 * (numberMaskedRecords/collnSize),"99.99")#</td>
				
				<td>#numberRestrictedRecords#</td>
				<td>#numberformat(100 * (numberRestrictedRecords/collnSize),"99.99")#</td>
				
				
				<td>#numberWithheldRecords#</td>
				<td>#numberformat(100 * (numberWithheldRecords/collnSize),"99.99")#</td>
				
			</tr>
		</cfloop>
	</table>

</cfoutput>


<cfinclude template="/includes/_footer.cfm">