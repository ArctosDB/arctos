<cfif not isdefined("collection_object_id")>
		<cfabort>
	</cfif>
	<cfquery name="ctAtt" datasource="#Application.web_user#">
	select distinct(attribute_type) from ctAttribute_type order by attribute_type
</cfquery>
<cfset attList = "">
<cfloop query="ctAtt">
	<cfif len(#attList#) is 0>
		<cfset attList = "#ctAtt.attribute_type#">
	<cfelse>
		<cfset attList = "#attList#,#ctAtt.attribute_type#">
	</cfif>
</cfloop>
<cfset seleAttributes = "">
<cfloop query="ctAtt">
			<cfset thisName = #ctAtt.attribute_type#>
			<cfset thisName = #replace(thisName," ","_","all")#>
			<cfset thisName = #replace(thisName,"-","_","all")#>
			<cfset thisName = #left(thisName,20)#>
			<cfif #thisName# is not "sex"><!--- already got it --->
				<cfset seleAttributes = "#seleAttributes# ,ConcatAttributeValue(cataloged_item.collection_object_id,'#ctAtt.attribute_type#') 
				as #thisName#">
			</cfif>
		</cfloop>
<cfset sql="
select
			cataloged_item.collection_object_id,
			cat_num,
			identification.scientific_name,
			state_prov,
			country,
			quad,
			county,
			island,
			sea,
			feature,
			spec_locality,
			CASE orig_lat_long_units
				WHEN 'decimal degrees' THEN dec_lat || 'd'
				WHEN 'deg. min. sec.' THEN lat_deg || 'd ' || lat_min || 'm ' || lat_sec || 's ' || lat_dir
				WHEN 'degrees dec. minutes' THEN lat_deg || 'd ' || dec_lat_min || 'm ' || lat_dir
			END as VerbatimLatitude,
			CASE orig_lat_long_units
				WHEN 'decimal degrees' THEN dec_long || 'd'
				WHEN'degrees dec. minutes' THEN long_deg || 'd ' || dec_long_min || 'm ' || long_dir
				WHEN 'deg. min. sec.' THEN long_deg || 'd ' || long_min || 'm ' || long_sec || 's ' || long_dir
			END as VerbatimLongitude,
			concatColl(cataloged_item.collection_object_id) as collectors,
			ConcatAttributeValue(cataloged_item.collection_object_id,'sex') as sex,
			concatotherid(cataloged_item.collection_object_id) as other_ids,
			concatparts(cataloged_item.collection_object_id) as parts,
			concatsingleotherid(cataloged_item.collection_object_id,'NK Number') as NK,
			verbatim_date,
			accn_num_prefix,
			accn_num,
			family,
			accn_num_suffix
			#seleAttributes#
		FROM
			cataloged_item
			INNER JOIN identification ON (cataloged_item.collection_object_id = identification.collection_object_id)
			INNER JOIN identification_taxonomy ON (identification.identification_id = identification_taxonomy.identification_id)
			INNER JOIN taxonomy ON (identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id)
			INNER JOIN collecting_event ON (cataloged_item.collecting_event_id = collecting_event.collecting_event_id)
			INNER JOIN locality ON (collecting_event.locality_id = locality.locality_id)
			INNER JOIN geog_auth_rec ON (locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id)
			LEFT OUTER JOIN accepted_lat_long ON (locality.locality_id = accepted_lat_long.locality_id)
			LEFT OUTER JOIN accn ON (cataloged_item.accn_id=accn.transaction_id)			
		WHERE
			accepted_id_fg=1 AND cataloged_item.collection_object_id IN (#collection_object_id#)		
			">
	<cfquery name="data" datasource="#Application.web_user#">
		#preservesinglequotes(sql)#
	</cfquery>

<!------------------------------->
<cfoutput>
<!--- pre-build the barcodes we'll need here --->
<cfloop query="data">
	<cf_makeBarcode barcode="#cat_num#">
</cfloop>
</cfoutput>