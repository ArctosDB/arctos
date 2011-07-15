<cfinclude template="/includes/_header.cfm">
<cfif len(session.username) is 0>
	You must log in to use this form.
	<cfabort>
</cfif>
<cfif action is "nothing">
	Welcome, #session.username#!
	<p>
		This form allows you to enter data from imaged herbarium labels.
	</p>
	<p>
		Do not use this form to report errors or request support. Use the <a href="/contact.cfm">link</a> in the footer for that.
	</p>
	<form method="post">
		To get started, enter the ID number and ID type from the sheet you are interested in. That's usually an ALA number ("ALAAC"),
		stamped on the sheet.
		<label for="idnum">ID Number</label>
		<input type="text" name="idnum" id="idnum">
		<label for="idtype">ID Type</label>
		<select name="idtype" id="idtype">
			<option value="ALAAC">ALA</option>
		</select>
	</form>
</cfif>

<cfinclude template="/includes/_footer.cfm">