<cfinclude template="/includes/_header.cfm">
	<cfquery name="d" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			guid_prefix || cat_num cnum,
			catcollobj.condition specCondition,
			catcollobj.coll_obj_disposition specDisposition
		from
			cataloged_item,
			coll_object catcollobj
		where
			cataloged_item.collection_object_id=catcollobj.collection_object_id and
			(
				catcollobj.condition like '%loan%' or
				catcollobj.coll_obj_disposition like '%loan%'
			)
		group by
			catcollobj.condition,
			catcollobj.coll_obj_disposition
	</cfquery>
	<table>
		<tr>
			<td>cnum</td>
			<td>specCondition</td>
			<td>specDisposition</td>
		</tr>
	<cfloop query="d">
		<tr>
			<td>#cnum#</td>
			<td>#specCondition#</td>
			<td>#specDisposition#</td>
		</tr>
	</cfloop>	
	</table>
<cfinclude template="/includes/_footer.cfm">