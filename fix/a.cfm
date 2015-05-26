<cfoutput>

<cfinclude template="/includes/_header.cfm">
<cfsetting requesttimeout="600">


 <cfquery name="c" datasource="uam_god" >
	select * from publication where doi is null and rownum<10
 </cfquery>
<cfdump var=#c#>

<cfhttp url="http://www.crossref.org/openurl/?pid=dlmcdonald@alaska.edu&format=unixref"></cfhttp>

<cfdump var=#cfhttp#>


<cfinclude template="/includes/_footer.cfm">
</cfoutput>