<cfinclude template="/includes/_pickHeader.cfm">
<cfoutput>
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
	<cfdump var="#pAtt#">

</cfoutput>	
