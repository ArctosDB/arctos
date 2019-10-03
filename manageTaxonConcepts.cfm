<cfinclude template="includes/_header.cfm">
<cfset title='Manage Concepts'>
	<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select scientific_name from taxon_name where taxon_name_id=#val(taxon_name_id)#
	</cfquery>
	<cfdump var=#t#>
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from taxon_concept where taxon_name_id=#val(taxon_name_id)#
	</cfquery>

	<cfdump var=#c#>

<cfinclude template="includes/_footer.cfm">
