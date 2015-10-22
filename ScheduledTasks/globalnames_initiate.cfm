<!-----


This builds the initial tables in Arctos with data from Arctos and globalnames.

It is obsolete once it's run once.



--------------------------------->

deprecated
<cfabort>

<cfoutput>
	<!---
		pipe-delimited list of things to completely ignore

		Arctos: Is locally-managed taxonomy that we send to GN; picking it back up would
			cause a black hole and could spell the end of the universe.
			Or possibly some slight confusion.
	--->
	<cfset sourcesToIgnore="Arctos">


		<!--- see if we can find something interesting to update ---->


		<cfquery name="ids" datasource="uam_god">
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
		<cfif ids.recordcount is 0>
			<cfquery name="ids" datasource="uam_god">
				select * from (
					select
						taxon_name_id
					from
						ANNOTATIONS
					where
						taxon_name_id not in (select taxon_name_id from taxon_name)
					group by taxon_name_id
				) where rownum<1001
			</cfquery>
		</cfif>
		<cfif ids.recordcount is 0>
			<cfquery name="ids" datasource="uam_god">
				select * from (
					select
						taxon_name_id
					from
						identification_taxonomy
					where
						taxon_name_id not in (select taxon_name_id from taxon_name)
					group by taxon_name_id
				) where rownum<1001
			</cfquery>
		</cfif>
		<cfif ids.recordcount is 0>
			<cfquery name="ids" datasource="uam_god">
				select
					 taxon_name_id from (
						SELECT related_primary_key taxon_name_id FROM
						 media_relations WHERE media_relationship like '% taxonomy' and
						 related_primary_key NOT IN (SELECT TAXON_NAME_ID FROM TAXON_NAME)
					group by related_primary_key
				) where rownum<1001
			</cfquery>
		</cfif>
		<cfif ids.recordcount is 0>
			<cfquery name="ids" datasource="uam_god">
				select * from (
					select
						taxon_name_id
					from
						TAXONOMY_PUBLICATION
					where
						taxon_name_id not in (select taxon_name_id from taxon_name)
					group by taxon_name_id
				) where rownum<1001
			</cfquery>
		</cfif>
		<cfif ids.recordcount is 0>
			<cfquery name="ids" datasource="uam_god">
				select * from (
					select
						taxon_name_id
					from
						TAXON_RELATIONS
					where
						taxon_name_id not in (select taxon_name_id from taxon_name)
					group by taxon_name_id
				) where rownum<1001
			</cfquery>
		</cfif>
		<cfif ids.recordcount is 0>
			<cfquery name="ids" datasource="uam_god">
				select * from (
					select
						related_taxon_name_id  taxon_name_id
					from
						TAXON_RELATIONS
					where
						related_taxon_name_id not in (select taxon_name_id from taxon_name)
					group by related_taxon_name_id
				) where rownum<2001
			</cfquery>
		</cfif>
		<cfif ids.recordcount is 0>
			<cfquery name="ids" datasource="uam_god">
				select taxon_name_id from taxonomy where taxon_name_id not in (select taxon_name_id from taxon_name)
				and rownum<1001
			</cfquery>
		</cfif>



	<cfloop query="ids">
		<!--- spawn threads 		<cfthread action="run" name="t#taxon_name_id#" taxon_name_id="#taxon_name_id#">
--->

		<!--- after initial population, need to adjust this to NOT make the new Arctos classifications ---->

		<!----
		---->
		 <cfquery name="d" datasource="uam_god">
			select * from taxonomy where taxon_name_id='#taxon_name_id#'
		</cfquery>
		<br>#d.SCIENTIFIC_NAME#
		<cfquery name="tt" datasource="uam_god">
			insert into taxon_name (taxon_name_id,scientific_name) values (#d.taxon_name_id#,'#d.SCIENTIFIC_NAME#')
		</cfquery>
		<cfset orderedTerms="KINGDOM,PHYLUM,PHYLCLASS,SUBCLASS,PHYLORDER,SUBORDER,SUPERFAMILY,FAMILY,SUBFAMILY,TRIBE,GENUS,SUBGENUS,SPECIES,SUBSPECIES,SCIENTIFIC_NAME">
		<cfset pos=1>
			<!--- arctos "source_id" is just the taxon_name_id ---->
			<cfloop list="#orderedTerms#" index="termtype">
				<cfset thisTermVal=evaluate("d." & termtype)>
				<cfset thisTermType=termtype>
				<cfif len(thisTermVal) gt 0>
					<cfif thisTermType is "SUBSPECIES" and len(d.INFRASPECIFIC_RANK) gt 0>
						<cfset thisTermType=d.INFRASPECIFIC_RANK>
					</cfif>
					<cfquery name="meta" datasource="uam_god">
						insert into taxon_term (
							taxon_term_id,
							taxon_name_id,
							term,
							term_type,
							source,
							position_in_classification,
							classification_id
						) values (
							sq_taxon_term_id.nextval,
							#d.taxon_name_id#,
							'#thisTermVal#',
							'#lcase(thisTermType)#',
							'Arctos',
							#pos#,
							'#d.taxon_name_id#'
						)
					</cfquery>
					<cfset pos=pos+1>
				</cfif>
			</cfloop>
			<cfset orderedTerms="VALID_CATALOG_TERM_FG|SOURCE_AUTHORITY|AUTHOR_TEXT|TAXON_REMARKS|NOMENCLATURAL_CODE|INFRASPECIFIC_AUTHOR|DISPLAY_NAME|TAXON_STATUS">
			<cfloop list="#orderedTerms#" index="termtype" delimiters="|">
				<cfset thisTermVal=evaluate("d." & termtype)>
				<cfif len(thisTermVal) gt 0>
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
							#d.taxon_name_id#,
							'#thisTermVal#',
							'#lcase(termtype)#',
							'Arctos',
							'#d.taxon_name_id#'
						)
					</cfquery>
					<cfset pos=pos+1>
				</cfif>
			</cfloop>



			<!------------

			for the purposes of test initiation, don't bother with globalnames - just get the Arctos data


			<cfhttp url="http://resolver.globalnames.org/name_resolvers.json?names=#d.scientific_name#"></cfhttp>
			<cfset x=DeserializeJSON(cfhttp.filecontent)>
			<cfloop from="1" to="#ArrayLen(x.data[1].results)#" index="i">
				<cfset pos=1>
				<!--- because lists are stupid and ignore NULLs.... ---->
				<cfif structKeyExists(x.data[1].results[i],"classification_path") and structKeyExists(x.data[1].results[i],"classification_path_ranks")>
					<cfset cterms=ListToArray(x.data[1].results[i].classification_path, "|", true)>
					<cfset cranks=ListToArray(x.data[1].results[i].classification_path_ranks, "|", true)>

					<cfset thisSource=x.data[1].results[i].data_source_title>
					<cfif not listfindnocase(sourcesToIgnore,thisSource,"|")>
						<cfset match_type=x.data[1].results[i].match_type>
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
						<cfset thisSourceID=x.data[1].results[i].classification_path_ids>
						<cfif len(thisSourceID) is 0>
							<cfset thisSourceID=CreateUUID()>
						</cfif>
						<cfset thisScore=x.data[1].results[i].score>
						<cfif len(thisScore) is 0><cfset thisScore=0></cfif>
						<cfset thisNameString=x.data[1].results[i].name_string>
						<cfset thisCanonicalFormName=x.data[1].results[i].canonical_form>

						<cfloop from="1" to="#arrayLen(cterms)#" index="listPos">
							<cfset thisTerm=cterms[listpos]>
							<br>thisTerm: #thisTerm#
							<cfif ArrayIsDefined(cranks, listpos)>
								<cfset thisRank=cranks[listpos]>
							<cfelse>
								<cfset thisRank=''>
							</cfif>

							<cfif len(thisTerm) gt 0>
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
										#d.taxon_name_id#,
										'#thisTerm#',
										'#lcase(thisRank)#',
										'#thisSource#',
										#pos#,
										'#thisSourceID#',
										#thisScore#,
										'#thisMatchType#'
									)
								</cfquery>
								<cfset pos=pos+1>
							</cfif>
						</cfloop>

						<cfif len(thisNameString) gt 0>
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
									#d.taxon_name_id#,
									'#thisNameString#',
									'name string',
									'#thisSource#',
									'#thisSourceID#'
								)
							</cfquery>
						</cfif>
						<cfif len(thisCanonicalFormName) gt 0>
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
									#d.taxon_name_id#,
									'#thisCanonicalFormName#',
									'canonical name',
									'#thisSource#',
									'#thisSourceID#'
								)
							</cfquery>
						</cfif>
					</cfif>
				</cfif>
			</cfloop>


			------>

			<!----	 </cfthread>
		----->



	</cfloop>
	<cfif isdefined("name") and len(name) gt 0>
		<br>threads spawned - we're done here
	</cfif>
</cfoutput>