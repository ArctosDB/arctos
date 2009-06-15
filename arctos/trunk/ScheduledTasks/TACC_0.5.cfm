<!---
 Run this weekly to cleanup things that weren't there and deal with duplicates

--->

<cfoutput>
	<cfquery name="gotFolder" datasource="uam_god">
		update tacc_check set jpeg_status=null where jpeg_status='not_there'		
	</cfquery>

</cfoutput>