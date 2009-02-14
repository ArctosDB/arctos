<cfquery name="mammByOrder" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select phylorder,
	count(distinct(cat_num)) cnt,
	sum(distinct(cat_num)) sum
	from 
	cataloged_item,
	identification,
	identification_taxonomy,
	taxonomy
	where 
	cataloged_item.collection_object_id = identification.collection_object_id and
	accepted_id_fg=1 and
	taxa_formula='A' and
	identification.identification_id = identification_taxonomy.identification_id and
	identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id and
	taxonomy.phylclass='Mammalia'
	group by phylorder
</cfquery>
<cfoutput query="mammByOrder">
	#phylorder# #cnt# <br>
</cfoutput>
<cfquery name="MammSpecByState" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select
		count(distinct(cat_num)) cnt,
		continent_ocean,
		country
	FROM
		cataloged_item,
		identification,
		identification_taxonomy,
		taxonomy,
		collecting_event,
		locality,
		geog_auth_rec
	WHERE
		cataloged_item.collection_object_id = identification.collection_object_id and
		accepted_id_fg=1 and
		taxa_formula='A' and
		identification.identification_id = identification_taxonomy.identification_id and
		identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id and
		taxonomy.phylclass='Mammalia' and
		cataloged_item.collecting_event_id = collecting_event.collecting_event_id and
		collecting_event.locality_id = locality.locality_id and
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and
		state_prov <> 'Alaska'
		group by 
		continent_ocean,
		country
</cfquery>
<cfoutput query="MammSpecByState">
<br>#continent_ocean# #country# #cnt#

</cfoutput>
<hr>
<cfquery name="MammSpecAK" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select
		count(distinct(cat_num)) cnt,
		continent_ocean,
		country
	FROM
		cataloged_item,
		identification,
		identification_taxonomy,
		taxonomy,
		collecting_event,
		locality,
		geog_auth_rec
	WHERE
		cataloged_item.collection_object_id = identification.collection_object_id and
		accepted_id_fg=1 and
		taxa_formula='A' and
		identification.identification_id = identification_taxonomy.identification_id and
		identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id and
		taxonomy.phylclass='Mammalia' and
		cataloged_item.collecting_event_id = collecting_event.collecting_event_id and
		collecting_event.locality_id = locality.locality_id and
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and
		state_prov='Alaska'
		group by 
		continent_ocean,
		country
</cfquery>
<cfoutput query="MammSpecAK">
<br>#continent_ocean# #country# #cnt#

</cfoutput>
