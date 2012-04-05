<cfset title="Explore Arctos">
<cfinclude template="/includes/_header.cfm">

<cfquery name="links" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" >
	select link,display from (
		select 
			link,display
		from
			browse
		 	sample(25)
		 order by
		 	dbms_random.value
		)
	WHERE rownum <= 25
</cfquery>
<cfoutput>
	<ul>
		<cfloop query="links">
			<li><a href="#link#">#display#</a></li>
		</cfloop>
	</ul>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
