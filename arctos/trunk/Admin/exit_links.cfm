<cfinclude template="includes/_header.cfm">
<cfset title="Exit Link Report">
<cfoutput>
	<cfquery name="exit"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from exit_link order by WHEN_DATE desc
	</cfquery>
	<cfdump var=#exit#>
</cfoutput>
<cfinclude template="includes/_footer.cfm">