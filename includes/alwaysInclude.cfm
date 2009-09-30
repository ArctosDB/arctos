<cfif not isdefined("action")><cfset action="nothing"></cfif>	
<cfinclude template="/includes/functionLib.cfm">	
<link rel="stylesheet" type="text/css" href="/includes/style.css" >
<cfset defaultjsfilelist="/includes/ajax.js">
<cfif not isdefined("jsfilelist")>
	<cfset jsfilelist=defaultjsfilelist>
<cfelse>
	<cfset jsfilelist=listappend(jsfilelist,defaultjsfilelist)>
</cfif>
<cfhtmlhead text='<script type="text/javascript" language="javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>'>

<cfoutput><cfhtmlhead text='<script src="/includes/combine.cfm?type=js&files=#jsfilelist#" type="text/javascript"></script>'></cfoutput>