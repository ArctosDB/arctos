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
		<li>
			<a href="/SpecimenResults.cfm?begmon=#datePart("mm",now())#&begday=#datePart("dd",now())#&endmon=#datePart("mm",now())#&endday=#datePart("dd",now())#&chronological_extent=1">today</a>
		</li>
		<cfloop query="links">
			<li><a href="#link#">#display#</a></li>
		</cfloop>
	</ul>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
