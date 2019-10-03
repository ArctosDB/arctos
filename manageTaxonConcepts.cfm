<cfinclude template="includes/_header.cfm">
<cfset title='Manage Concepts'>
<cfif action is "nothing">
	<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select scientific_name from taxon_name where taxon_name_id=#val(taxon_name_id)#
	</cfquery>
	<cfdump var=#t#>
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from taxon_concept where taxon_name_id=#val(taxon_name_id)#
	</cfquery>

	<cfdump var=#c#>
	<cfoutput>
		<form name="n" method="post" action="manageTaxonConcepts.cfm">
			<input type="hidden" name="action" value="new">
			<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
			<input type="hidden" name="publication_id" id="publication_id">
			<label for="publication">pick publication</label>
			<input type="text" id="publication"	value='' onchange="getPublication(this.id,'publication_id',this.value)" size="50" >
			<label for="publication">pick publication</label>
			<input type='text' name='concept_label' size='100' id='concept_label' required class='reqdClr'>
			<br><input type="submit" value='create'>
		</form>
	</cfoutput>
</cfif>
<cfif action is "new">
	<cfoutput>
		<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into taxon_concept (
				taxon_concept_id,
				taxon_name_id,
				publication_id,
				concept_label
			) values (
				sq_taxon_concept_id.nextval,
				#taxon_name_id#,
				#publication_id#,
				'#concept_label#'
			)
		</cfquery>
		<cflocation url="manageTaxonConcepts.cfm?action=nothing&taxon_name_id=#taxon_name_id#" addtoken="false">
	</cfoutput>
</cfif>
<cfinclude template="includes/_footer.cfm">
