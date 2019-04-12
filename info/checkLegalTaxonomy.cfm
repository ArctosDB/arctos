<cfoutput>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			taxon_term.term_type,
			taxon_term.term,
			guid
		from
			#session.username#.#table_name#,
			identification,
			identification_taxonomy,
			taxon_term
		where
			#session.username#.#table_name#.collection_object_id=identification.collection_object_id and
			identification.identification_id=identification_taxonomy.identification_id and
			identification_taxonomy.taxon_name_id=taxon_term.taxon_name_id and
			taxon_term.source='Arctos Legal'
	</cfquery>
	<cfdump var=#d#>
</cfoutput>