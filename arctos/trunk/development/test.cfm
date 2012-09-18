	
<cfinclude template="/includes/_header.cfm">
	<cfquery name="d" datasource="uam_god">
	    select * from flat where collection_object_id=12
	</cfquery>
 <cfreport format="PDF" 
    	template="#application.webDirectory#/Reports/templates/alaLabel.cfr"
        query="d"
        overwrite="true">
	</cfreport>
