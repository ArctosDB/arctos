<!---
	processing table

	create table temp_dgr_box as select distinct freezer, rack, box from dgr_locator;

	alter table temp_dgrbox add status varchar2(255);

--->

<cfoutput>
	<cfquery datasource='uam_god' name='d'>
		select * from temp_dgr_box where status is null and rownum <2
	</cfquery>

	<cfloop query="d">
		<cfinclude template="/fix/dgr_box_to_objecttracking.cfm?f=#freezer#&r=#rack#&b=#box#">
	</cfloop>
</cfoutput>