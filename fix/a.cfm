<cfquery name="d" datasource="uam_god">
		SELECT dbms_metadata.get_ddl('TABLE', 'ATTRIBUTES') x FROM DUAL
</cfquery>
<CFDUMP VAR=#D#>

