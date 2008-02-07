<cfquery name="s" datasource="#Application.uam_dbo#">
	select  attributes.ATTRIBUTE_ID,
	attributes.COLLECTION_OBJECT_ID,
	attributes.DETERMINED_BY_AGENT_ID,
	attributes.ATTRIBUTE_TYPE ,
	attributes.ATTRIBUTE_VALUE,
	attributes.ATTRIBUTE_UNITS,
	attributes.ATTRIBUTE_REMARK,
	attributes.DETERMINED_DATE,
	attributes.DETERMINATION_METHOD 
 from 
	attributes,
	coll_obj_other_id_num,
	cf_temp_attributes
where
attributes.collection_object_id = coll_obj_other_id_num.collection_object_id and
cf_temp_attributes.OTHER_ID_NUMBER = coll_obj_other_id_num.other_id_num and
cf_temp_attributes.OTHER_ID_TYPE = coll_obj_other_id_num.other_id_type 
order by attributes.collection_object_id
</cfquery>
<cfoutput>
<table border>
	<cfloop query="s">
		<tr>
			<td>#COLLECTION_OBJECT_ID#</td>
			<td>#DETERMINED_BY_AGENT_ID#</td>
			<td>#ATTRIBUTE_TYPE#</td>
			<td>#ATTRIBUTE_VALUE#</td>
			<td>#ATTRIBUTE_UNITS#</td>
			<td>#ATTRIBUTE_REMARK#</td>
			<td>#DETERMINED_DATE#</td>
			<td>#DETERMINATION_METHOD#</td>
		</tr>
	</cfloop>
	</table>
</cfoutput>