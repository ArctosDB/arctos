	<cfinclude template="/includes/_header.cfm">

<cfoutput>


<cfset body="


hi


this is an email

e = MVC squared

ok


buybye


">

<cf_logEmail body="#body#">
			</cfoutput>
		<cfinclude template="/includes/_footer.cfm">

