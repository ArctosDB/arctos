<cfif not isdefined("action")><cfset action="nothing"></cfif>	
<cfinclude template="/includes/functionLib.cfm">	
<link rel="stylesheet" type="text/css" href="/includes/style.css" >
<cfset defaultjsfilelist="/includes/ajax.js,/includes/jquery/jquery-1.3.2.min.js">
<cfif not isdefined("jsfilelist")>
	<cfset jsfilelist=defaultjsfilelist>
<cfelse>
	<cfset jsfilelist=listappend(jsfilelist,defaultjsfilelist)>
</cfif>
<cfoutput><script src="/includes/combine.cfm?type=js&files=#jsfilelist#" type="text/javascript"></script></cfoutput>