<cfinclude template="/includes/_pickHeader.cfm">
<cfoutput>
	<cfquery name="ctspecpart_attribute_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select attribute_type from ctspecpart_attribute_type order by attribute_type
	</cfquery>

	<cfquery name="pAtt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
			 part_attribute_id,
			 attribute_type,
			 attribute_value,
			 attribute_units,
			 determined_date,
			 determined_by_agent_id,
			 attribute_remark
		from
			specimen_part_attribute
		where
			collection_object_id=#partID#
	</cfquery>
	
	<hr>
	
	Create Part Attribute
	<label for="attribute_type_new">Attribute Type</label>
	<select id="attribute_type_new" name="attribute_type_new" onchange="setPartAttOptions('new',this.value)">
		<option value=""></option>
		<cfloop query="ctspecpart_attribute_type">
			<option value="#attribute_type#">#attribute_type#</option>
		</cfloop>
	</select>
	<div id='pattr_new'></div>
	
	<input type="text" id="attribute_value_new" name="attribute_value_new">
	<label for="attribute_units_new">Attribute Units</label>
	<input type="text" id="attribute_units_new" name="attribute_units_new">
	
			part_attribute_id NUMBER NOT NULL,
    collection_object_id NUMBER NOT NULL,
    attribute_type VARCHAR2(30) NOT NULL,
    attribute_value VARCHAR2(255) NOT NULL,
    attribute_units varchar2(30),
    determined_date DATE,
    determined_by_agent_id NUMBER,
    attribute_remark varchar2(4000)
	<cfdump var="#pAtt#">

</cfoutput>	
