<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfheader statuscode="401" statustext="Not authorized">
This is a development server. You may log in or create an account 
for testing purposes. You may not access this machine without logging in.
Data available from this machine are for testing purposes only and are not
valid specimen data.

<p>
<a href="/login.cfm">Log In</a>
</p>
<p>
	<a href="http://arctos.database.museum">Go to Arctos</a>
</p>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">