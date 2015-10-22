<!---- some way of keeping track of stuff....
create table temp_gn_fetched (taxon_name_id number);



 this is copied from the single-fetch page, but MODIFIED.


Make sure any useful changes end up in both places.


Delete this file after initial fetch


 ---->
deprecated
<cfabort>



<cfset numberOfNamesOneFetch="3">
<cfquery name="d" datasource="uam_god">
	select * from (
		select
			taxon_name.scientific_name,
			taxon_name.taxon_name_id
		from
			taxon_name,
			identification_taxonomy
		where
			taxon_name.taxon_name_id=identification_taxonomy.taxon_name_id and
			taxon_name.taxon_name_id not in (select taxon_name_id from temp_gn_fetched)
		group by
			taxon_name.scientific_name,
			taxon_name.taxon_name_id
	) where rownum < #numberOfNamesOneFetch#
</cfquery>
<cfif d.recordcount is 0>
	<cfquery name="d" datasource="uam_god">
		select * from (
			select
				taxon_name.scientific_name,
				taxon_name.taxon_name_id
			from
				taxon_name,
				TAXON_RELATIONS
			where
				taxon_name.taxon_name_id=TAXON_RELATIONS.taxon_name_id and
				taxon_name.taxon_name_id not in (select taxon_name_id from temp_gn_fetched)
			group by
				taxon_name.scientific_name,
				taxon_name.taxon_name_id
		) where rownum < #numberOfNamesOneFetch#
	</cfquery>
</cfif>
<cfif d.recordcount is 0>
	<cfquery name="d" datasource="uam_god">
		select * from (
			select
				taxon_name.scientific_name,
				taxon_name.taxon_name_id
			from
				taxon_name,
				ANNOTATIONS
			where
				taxon_name.taxon_name_id=ANNOTATIONS.taxon_name_id and
				taxon_name.taxon_name_id not in (select taxon_name_id from temp_gn_fetched)
		group by
			taxon_name.scientific_name,
			taxon_name.taxon_name_id
		) where rownum < #numberOfNamesOneFetch#
	</cfquery>
</cfif>

<cfif d.recordcount is 0>
	<cfquery name="d" datasource="uam_god">
		select * from ( select
			taxon_name.scientific_name,
			taxon_name.taxon_name_id
		from
			taxon_name,
			media_relations
		where
			taxon_name.taxon_name_id=media_relations.related_primary_key and
			media_relationship like '% taxonomy' and
			taxon_name.taxon_name_id not in (select taxon_name_id from temp_gn_fetched)
	group by
		taxon_name.scientific_name,
		taxon_name.taxon_name_id) where rownum < #numberOfNamesOneFetch#
	</cfquery>
</cfif>
<cfif d.recordcount is 0>
	<cfquery name="d" datasource="uam_god">
		select * from ( select
			taxon_name.scientific_name,
			taxon_name.taxon_name_id
		from
			taxon_name,
			TAXONOMY_PUBLICATION
		where
			taxon_name.taxon_name_id=TAXONOMY_PUBLICATION.taxon_name_id and
			taxon_name.taxon_name_id not in (select taxon_name_id from temp_gn_fetched)
	group by
		taxon_name.scientific_name,
		taxon_name.taxon_name_id) where rownum < #numberOfNamesOneFetch#
	</cfquery>
</cfif>

<cfif d.recordcount is 0>
	<cfquery name="d" datasource="uam_god">
		select * from (select
			taxon_name.scientific_name,
			taxon_name.taxon_name_id
		from
			taxon_name,
			TAXON_RELATIONS
		where
			taxon_name.taxon_name_id=TAXON_RELATIONS.related_taxon_name_id and
			taxon_name.taxon_name_id not in (select taxon_name_id from temp_gn_fetched)
	group by
		taxon_name.scientific_name,
		taxon_name.taxon_name_id) where rownum < #numberOfNamesOneFetch#
	</cfquery>
</cfif>


		<cfdump var=#d#>


		<cfflush>




		<!----





<cfquery name="d" datasource="uam_god">
			select * from (
				select
					taxon_name_id
				from
					common_name
				where
					taxon_name_id not in (select taxon_name_id from taxon_name)
				group by taxon_name_id
			) where rownum<1001
		</cfquery>




		<cfif d.recordcount is 0>
			<cfquery name="d" datasource="uam_god">
				select taxon_name_id from taxonomy where taxon_name_id not in (select taxon_name_id from taxon_name)
				and rownum<1001
			</cfquery>
		</cfif>
	---------->





<!-------------------- ---->
<cfoutput>

	<cfset sourcesToIgnore="Arctos">

	<cfset theseNames=valuelist(d.scientific_name,"|")>
		<hr>


		-----------theseNames: #theseNames#

		<br>
		<!---------------

							 <cfthread name="t_#taxon_name_id#" action="run" priority="LOW" scientific_name="#scientific_name#" taxon_name_id="#taxon_name_id#">


		----------------------->


<cfsetting requesttimeout="30" />

		<!------------
			<cfif left(scientific_name,1) is chr(215)>
				hybrid - aborting......
				<cfquery name="gotit" datasource="uam_god">
					insert into temp_gn_fetched (taxon_name_id) values (#taxon_name_id#)
				</cfquery>
				<cfquery name="gotit" datasource="uam_god">
					insert into temp_tax_stuck (taxon_name_id) values (#taxon_name_id#)
				</cfquery>

				<cfabort>
			</cfif>

			--------------->


			<!----

						<cfhttp url="http://resolver.globalnames.org/name_resolvers.json?names=#scientific_name#"></cfhttp>

			----->
			<cfhttp url="http://resolver.globalnames.org/name_resolvers.json?names=#theseNames#"></cfhttp>



			<cfset x=DeserializeJSON(cfhttp.filecontent)>







			<cfloop from="1" to="#ArrayLen(x.data)#" index="thisResultIndex">

			<cfset thisName=listgetat(theseNames,thisResultIndex,"|")>

			<hr>thisName::::::::::::::::::::::::::: #thisName#

			<cfquery name="dfd" dbtype="query">
				select taxon_name_id from d where scientific_name='#thisName#'
			</cfquery>

			<cfset thisTaxonNameID=dfd.taxon_name_id>
						<hr>thisTaxonNameID::::::::::::::::::::::::::: #thisTaxonNameID#

			<cfloop from="1" to="#ArrayLen(x.data[thisResultIndex].results)#" index="i">
				<cfset pos=1>
				<!--- because lists are stupid and ignore NULLs.... ---->
				<cfif structKeyExists(x.data[thisResultIndex].results[i],"classification_path") and structKeyExists(x.data[thisResultIndex].results[i],"classification_path_ranks")>
					<cfset cterms=ListToArray(x.data[thisResultIndex].results[i].classification_path, "|", true)>
					<cfif listlen(x.data[thisResultIndex].results[i].classification_path, "|") gt 1>
						<!--- ignore the stuff with no useful classification, which includes one-term "classifications" --->
						<cfset cranks=ListToArray(x.data[thisResultIndex].results[i].classification_path_ranks, "|", true)>

						<cfset thisSource=x.data[thisResultIndex].results[i].data_source_title>
						<cfif not listfindnocase(sourcesToIgnore,thisSource,"|")>
							<cfset thisSourceID=x.data[thisResultIndex].results[i].classification_path_ids>
							<cfif len(thisSourceID) is 0>
								<cfset thisSourceID=CreateUUID()>

							<!----- nodelete for init
							<cfelse>
								<!------------
									delete (so we can reinsert to update) from Arctos
									if we already have the classification.

									Delete is just cheaper/easier than checking for existing, updating lastdate, etc.

									Don't bother if we're creating a UUID - it won't exist (that's the point!) so save
									a trip to the DB
								--------------->
								<cfquery name="flush" datasource="uam_god">
									delete from taxon_term where taxon_name_id=#d.taxon_name_id#
									and classification_id='#thisSourceID#'
								</cfquery>
								 ---------->
							</cfif>

							<cfset match_type=x.data[thisResultIndex].results[i].match_type>
							<cfif match_type is 1>
								<cfset thisMatchType="Exact match">
							<cfelseif match_type is 2>
								<cfset thisMatchType="Exact match by canonical form of a name">
							<cfelseif match_type is 3>
								<cfset thisMatchType="Fuzzy match by canonical form">
							<cfelseif match_type is 4>
								<cfset thisMatchType="Partial exact match by species part of canonical form">
							<cfelseif match_type is 5>
								<cfset thisMatchType="Partial fuzzy match by species part of canonical form">
							<cfelseif match_type is 6>
								<cfset thisMatchType=" Exact match by genus part of a canonical form">
							<cfelse>
								<cfset thisMatchType="">
							</cfif>
							<!--- try to use something from them to uniquely identify the hierarchy---->
							<!---- failing that, make a local identifier useful only in patching the hierarchy back together ---->



							<cfset thisScore=x.data[thisResultIndex].results[i].score>
							<cfif len(thisScore) is 0><cfset thisScore=0></cfif>
							<cfset thisNameString=x.data[thisResultIndex].results[i].name_string>

							<cfif structKeyExists(x.data[thisResultIndex].results[i],"canonical_form")>
								<cfset thisCanonicalFormName=x.data[thisResultIndex].results[i].canonical_form>
							<cfelse>
								<cfset thisCanonicalFormName=''>
							</cfif>



							<cfloop from="1" to="#arrayLen(cterms)#" index="listPos">
								<cfset thisTerm=cterms[listpos]>
								<br>thisTerm: #thisTerm#
								<cfif ArrayIsDefined(cranks, listpos)>
									<cfset thisRank=cranks[listpos]>
								<cfelse>
									<cfset thisRank=''>
								</cfif>

								<cfif len(thisTerm) gt 0>
									<!----


									----->


									<cfquery name="meta" datasource="uam_god">
										insert into taxon_term (
											taxon_term_id,
											taxon_name_id,
											term,
											term_type,
											source,
											position_in_classification,
											classification_id,
											gn_score,
											match_type
										) values (
											sq_taxon_term_id.nextval,
											#thisTaxonNameID#,
											'#thisTerm#',
											'#lcase(thisRank)#',
											'#thisSource#',
											#pos#,
											'#thisSourceID#',
											#thisScore#,
											'#thisMatchType#'
										)
									</cfquery>

								<hr>
								insert into taxon_term (
											taxon_term_id,
											taxon_name_id,
											term,
											term_type,
											source,
											position_in_classification,
											classification_id,
											gn_score,
											match_type
										) values (
											sq_taxon_term_id.nextval,
											#thisTaxonNameID#,
											'#thisTerm#',
											'#lcase(thisRank)#',
											'#thisSource#',
											#pos#,
											'#thisSourceID#',
											#thisScore#,
											'#thisMatchType#'
										)

									<cfset pos=pos+1>
								</cfif>
							</cfloop>

							<cfif len(thisNameString) gt 0>
								<!----

									----->
								<cfquery name="meta" datasource="uam_god">
									insert into taxon_term (
										taxon_term_id,
										taxon_name_id,
										term,
										term_type,
										source,
										classification_id
									) values (
										sq_taxon_term_id.nextval,
										#thisTaxonNameID#,
										'#thisNameString#',
										'name string',
										'#thisSource#',
										'#thisSourceID#'
									)
								</cfquery>
								<hr>

								insert into taxon_term (
										taxon_term_id,
										taxon_name_id,
										term,
										term_type,
										source,
										classification_id
									) values (
										sq_taxon_term_id.nextval,
										#thisTaxonNameID#,
										'#thisNameString#',
										'name string',
										'#thisSource#',
										'#thisSourceID#'
									)
							</cfif>
							<cfif len(thisCanonicalFormName) gt 0>
							<!----


								----->
								<cfquery name="meta" datasource="uam_god">
									insert into taxon_term (
										taxon_term_id,
										taxon_name_id,
										term,
										term_type,
										source,
										classification_id
									) values (
										sq_taxon_term_id.nextval,
										#thisTaxonNameID#,
										'#thisCanonicalFormName#',
										'canonical name',
										'#thisSource#',
										'#thisSourceID#'
									)
								</cfquery>
								<hr>
								insert into taxon_term (
										taxon_term_id,
										taxon_name_id,
										term,
										term_type,
										source,
										classification_id
									) values (
										sq_taxon_term_id.nextval,
										#thisTaxonNameID#,
										'#thisCanonicalFormName#',
										'canonical name',
										'#thisSource#',
										'#thisSourceID#'
									)

							</cfif>
						</cfif>

					</cfif>
				</cfif>
			</cfloop>

			<cfquery name="gotit" datasource="uam_god">
		insert into temp_gn_fetched (taxon_name_id) values (#thisTaxonNameID#)
	</cfquery>

			</cfloop>




	<!------------

			</cfthread>

	----------->

</cfoutput>