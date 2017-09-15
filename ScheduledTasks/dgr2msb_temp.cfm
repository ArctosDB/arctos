<!---
	processing table

	create table temp_dgr_box as select distinct freezer, rack, box from dgr_locator;

	delete from temp_dgr_box where freezer='2';

	alter table temp_dgr_box add status varchar2(255);

	update temp_dgr_box set status='done-before' where freezer=1 and rack=1 and box=1;
	update temp_dgr_box set status='done-before' where freezer=1 and rack=1 and box=2;
	update temp_dgr_box set status='done-before' where freezer=1 and rack=1 and box=2;

--->

<cfoutput>
	<cfquery datasource='uam_god' name='d'>
		select * from temp_dgr_box where status is null and rownum <2
	</cfquery>

	<cfloop query="d">
		<cfinclude template="/fix/dgr_box_to_objecttracking.cfm?f=#freezer#&r=#rack#&b=#box#">
	</cfloop>
</cfoutput>