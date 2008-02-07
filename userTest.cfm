<!----
create user testuser identified by tu;
grant create session to testuser;


---->

<cfif action is "nothing">

<cfquery name="c" datasource="#Application.web_user#" username="" password="">
	select count(*) from test
</cfquery>
<cfoutput>
	#c.recordcount#
</cfoutput>

</cfif>