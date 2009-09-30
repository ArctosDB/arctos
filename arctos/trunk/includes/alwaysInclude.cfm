<cfif not isdefined("action")><cfset action="nothing"></cfif>	
<cfinclude template="/includes/functionLib.cfm">	
<link rel="stylesheet" type="text/css" href="/includes/style.css" >
<cfset fl="/includes/jquery/jquery-1.3.2.min.js,/includes/ajax.js">
<cfif isdefined("jsfilelist")>
	<cfset fl=listappend(fl,jsfilelist)>
</cfif>
<cfoutput><cfhtmlhead text='<script src="/includes/combine.cfm?type=js&files=#fl#" type="text/javascript"></script>'></cfoutput>