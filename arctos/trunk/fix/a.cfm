<cfquery name="d" datasource="uam_god">
		SELECT dbms_metadata.get_ddl('TABLE', 'ATTRIBUTES') x FROM DUAL
</cfquery>


<cfset ddl=replace(d.x,chr(10),"[chr10]","all")>
<cfoutput>
	#ddl#
	
	<textarea>#d.x#</textarea>
</cfoutput>
<CFDUMP VAR=#D#>

