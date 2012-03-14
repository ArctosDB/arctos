<cfinclude template="/includes/_header.cfm">
<cfif not isdefined("url.ref")><cfset url.ref=""></cfif>
<cfsavecontent variable="errortext">
	<cfoutput>
		 Referrer: #url.ref#
	</cfoutput>
</cfsavecontent>
<cfheader statuscode="403" statustext="Forbidden">
<cfthrow 
   type = "Access_Violation"
   message = "Forbidden"
   detail = "access denied"
   errorCode = "403 "
   extendedInfo = "#errortext#">
<cfabort>