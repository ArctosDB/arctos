<cfquery name="d" datasource="uam_god">
	select
		guid,
		cat_num,
		taxon_name
	from
		flat
	where
		rownum=1
</cfquery>
<serializeJSON(d)>