<cfcomponent>
<!------------------------------------------->
<cffunction name="test" access="remote">
	<!---
	<cfargument name="barcode" type="string" required="yes">
	<cfargument name="parent_barcode" type="string" required="yes">
	<cfargument name="timestamp" type="string" required="yes">	
	--->
	<cfquery name="d" datasource="uam_god">
	select
		guid,
		cat_num,
		SCIENTIFIC_NAME
	from
		flat
	where
		rownum=1
</cfquery>
<cfreturn d>
</cffunction>
</cfcomponent>