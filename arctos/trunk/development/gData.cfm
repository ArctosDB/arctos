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
<cfset x=serializeJSON(d)>
<cfdump var=#x#>