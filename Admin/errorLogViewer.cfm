<cfinclude template="/includes/_header.cfm">

<cfif not isdefined("log")>
	<cfset log="log">
</cfif>
<cffile action="read" file="#Application.webDirectory#/log/#log#.txt" variable="logtxt">
<cfoutput>	
	<cfset x=xmlparse("<logs>" & logtxt & "</logs>")>
	<cfdump var=#x#>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
