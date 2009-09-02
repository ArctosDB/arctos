<cfoutput>
<cfset x=1>
<cfquery name="a" datasource="uam_god">
	insert into t values ('a',nvl(#x#,NULL))
</cfquery>

<cfset x=0>
<cfquery name="a" datasource="uam_god">
	insert into t values ('a',nvl(#x#,NULL))
</cfquery>

<cfset x="">
<cfquery name="a" datasource="uam_god">
	insert into t values ('a',nvl(#x#,NULL))
</cfquery>

</cfoutput>