<cfcomponent>
	<cffunction name="getTaxonLinks" access="remote">
	<cfargument name="tnid" type="numeric" required="yes">
	<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select scientific_name from taxonomy where taxon_name_id=#tnid#
	</cfquery>
	<cfhttp method="get" url="/SpecimenResults.cfm?taxon_name_id=#tnid#">
	</cfhttp>
	<cfdump var="cfhttp">
	</cffunction>
</cfcomponent>