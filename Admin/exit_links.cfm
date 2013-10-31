<cfinclude template="/includes/_header.cfm">
<cfset title="Exit Link Report">
<script>
		jQuery(document).ready(function() {
			$("#fdate").datepicker();
		});
</script>
<cfoutput>
	<cfparam name="fdate">
	
	<form method="post" action="exit_links.cfm">
		<label for="fdate">Earlies Date</label>
		<input type="text" id="fdate" name="fdate" value="#fdate#">
	</form>
	<cfif len(form.fieldnames)>
		<cfquery name="exit"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from exit_link order by WHEN_DATE desc
		</cfquery>
		<cfdump var=#exit#>
	</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">