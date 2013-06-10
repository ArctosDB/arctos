deprecated<cfabort>
<!---
 Run this weekly to cleanup things that weren't there and deal with duplicates

--->

<cfoutput>
	<cfquery name="gotFolder" datasource="uam_god">
		update tacc_check set jpg_status=null where jpg_status='not_there'		
	</cfquery>

</cfoutput>