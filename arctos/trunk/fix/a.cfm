<cfquery name="a" datasource="uam_god">
	select dbms_xmlgen.getxml('select * from uam.arctos_audit') from dual
</cfquery>
<cfdump var=#a#>