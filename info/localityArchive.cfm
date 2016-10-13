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
	<cfloop list="#locality_id#" index="lid">
		<cfquery name="orig" datasource="uam_god">
			select * from locality where locality_id=#lid#
		</cfquery>
		original data:
		<cfdump var=#orig#>

		<cfquery name="thisChanges" dbtype="query">
			select * from d where locality_id=#lid# order by changedate
		</cfquery>
		changes:
		<cfdump var=#thisChanges#>
	</cfloop>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">