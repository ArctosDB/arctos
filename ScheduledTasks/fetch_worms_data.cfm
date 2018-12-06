
<!---------
for the first run get this from the temp table
needs rebuilt to something like this once that's done

<cfquery name="d" datasource="uam_god">
	select
		taxon_name_id,
		term aphiaid ,
		sysdate-lastdate,
		lastdate
	from
		taxon_term
	where
		source='WoRMS (via Arctos)' and
		term_type='aphiaid' and
		sysdate-lastdate > 30
</cfquery>
------------>


<cfquery name="d" datasource="uam_god">
	select
		taxon_name_id,
		taxonID aphiaid,
		scientificname
	from
		temp_worms
	where
		seeded_class=1 and
		init_pull is null and
		rownum<2
</cfquery>
<cfdump var=#d#>

<cfset tc = CreateObject("component","component.taxonomy")>

<cfloop query="d">
	<cfset x=tc.updateWormsArctosByAphiaID(aphiaid,taxon_name_id)>
	<cfdump var=#x#>
</cfloop>
