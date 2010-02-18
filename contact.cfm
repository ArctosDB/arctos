<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
<cfoutput>
	<form action="contact.cfm" method="post" name="contact">
		<input type="text" id="name" size="60" value="#session.username#">
	</form>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">