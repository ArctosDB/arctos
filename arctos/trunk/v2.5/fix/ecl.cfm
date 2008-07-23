<cfabort>

<cfoutput>
<cfquery name="whatsThere" datasource="#Application.uam_dbo#">
	select higher_geog,geog_auth_rec.geog_auth_rec_id,locality.locality_id, locality ,spec_locality
	from ecl,locality,geog_auth_rec
	where locality=spec_locality
	and locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id
	and county is null
	and locality <> 'SPECIFIC LOCALITY UNKNOWN'
	 and locality <> 'NO DATA'	
	group by
	 higher_geog,locality.locality_id, geog_auth_rec.geog_auth_rec_id, locality ,spec_locality
	order by higher_geog
</cfquery>
<cfset i=1>
<table border="1">
<cfloop query="whatsThere">
<tr>
	<td>#i#</td>
	<td>#locality#</td>
	<td>#spec_locality#</td>
	<td>#higher_geog#</td>
	<td>#geog_auth_rec_id#</td>
	<td>#locality_id#</td>

<cfquery name="fec" datasource="#Application.uam_dbo#">
	update locality set geog_auth_rec_id = 3360
	where locality_id = #locality_id#
</cfquery>
<td>
update locality set geog_auth_rec_id = 3360
	where locality_id = #locality_id#
</td>

	</tr>
<cfset i=#i#+1>
</cfloop>
</table>
</cfoutput>