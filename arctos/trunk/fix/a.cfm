<cfoutput>

<cfinclude template="/includes/_header.cfm">
<cfsetting requesttimeout="600">


 <cfquery name="c" datasource="uam_god" >
	select * from publication where doi is null
 </cfquery>
<cfdump var=#c#>


<cfinclude template="/includes/_footer.cfm">
</cfoutput>