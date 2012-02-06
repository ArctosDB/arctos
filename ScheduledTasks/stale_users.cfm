<cfoutput>
	<cfif not isdefined("d")>
		<cfset d=180>
	</cfif>
	<!--- users who haven't logged in for 6 months --->
	<cfquery name="nologinsixmo" datasource="uam_god">
		select 
			DBA_USERS.username,
			LAST_LOGIN
		from
			DBA_USERS,
			cf_users
		where
			upper(DBA_USERS.USERNAME)=upper(cf_users.USERNAME) and
			PROFILE='ARCTOS_USER' and
			LOCK_DATE is null and
			SYSDATE-LAST_LOGIN > #d#
	</cfquery>
	<cfdump var=#nologinsixmo#>
	<!---
	<cfloop query="nologinsixmo">
		<cfquery name="nologinsixmo_buhbye" datasource="uam_god">
			alter user "#username#" account lock
		</cfquery>
	</cfloop>
	---->
</cfoutput>