<cfinclude template="/includes/_header.cfm">
<cfset title="Locality Archive">
<cfoutput>
	<cfif not isdefined("locality_id")>
		bad call<cfabort>
	</cfif>
	<cfquery name="d" datasource="uam_god">
		select * from locality_archive where locality_id in (  <cfqueryparam value = "#locality_id#" CFSQLType = "CF_SQL_INTEGER"
        list = "yes"
        separator = ","> )
	</cfquery>
	<cfif d.recordcount is 0>
		No archived information found.<cfabort>
	</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">