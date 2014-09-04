<cfinclude template = "includes/_header.cfm">
<cfif application.version is not "test">
	no<cfabort>
</cfif>
<form name="f" method="post" action="makeTestAccounts.cfm">
<input type="hidden" name="action" value="magic">
<label for="username">username</label>
<input type="text" name="usernmae" required>


<label for="password">password</label>
<input type="text" name="password" required>

<br>
<input type="submit">
</form>

<cfinclude template = "includes/_header.cfm">
