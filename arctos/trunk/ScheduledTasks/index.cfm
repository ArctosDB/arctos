<cfinclude template="/includes/_header.cfm">
<cfdirectory action="list" directory="#Application.webDirectory#/ScheduledTasks" name="d" sort="name ASC">
<cfoutput>
	<cfloop query="d">
		<a href="#name#">#name#</a><br>
	</cfloop>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">