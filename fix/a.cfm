<cfquery name="a" datasource="uam_god">
	select dbms_xmlgen.getxml('select * from uam.arctos_audit') q from dual
</cfquery>
<cfset x=xmlparse(a.q)>
<cfdump var=#x#>