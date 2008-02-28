<cfinclude template="/includes/_header.cfm">
<form name="bla" method="post" action="b.cfm">
	<cfinclude template="a.cfm">
<input type="submit">
</form>
<cfif isdefined("form")>
	<cfdump var=#form#>
</cfif>

<cfinclude template="/includes/_footer.cfm">