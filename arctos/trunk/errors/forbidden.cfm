<cfinclude template="/includes/_header.cfm">
<div class="error">
 Access denied.
</div>
<cfif not isdefined("url.ref")><cfset url.ref=""></cfif>
<cfset r=replace(url.ref,application.webDirectory,"")>
<cfsavecontent variable="errortext">
	<cfoutput>
		 Referrer: #r#
	</cfoutput>
</cfsavecontent>
<cfthrow 
   type = "Access_Violation"
   message = "Forbidden"
   detail = "Someone found a locked form."
   errorCode = "99928786513 "
   extendedInfo = "#errortext#">