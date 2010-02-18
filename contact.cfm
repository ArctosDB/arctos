<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
	<cfset title="Contact Us">
<cfoutput>
	<form action="contact.cfm" method="post" name="contact">
		<label for="name">Your Name</label>
		<input type="text" id="name" name="name" size="60" value="#session.username#">
		<label for="form">Form or Operation</label>
		<input type="text" id="form" name="form" size="60" value="#session.username#">
		<label for="msg">Message</label>
		<textarea name="msg" id="msg" rows="50" cols="10"></textarea>
	</form>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">