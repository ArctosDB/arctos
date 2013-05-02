	<cfquery name="ids" datasource="uam_god">
		select 
			taxon_name_id 
		from 
			identification_taxonomy 
		where 
			taxon_name_id not in (select taxon_name_id from taxon_name) and 
			rownum<2
		group by taxon_name_id
	</cfquery>
	<cfloop query="ids">
		 <cfthread action="run" name="t#taxon_name_id#" taxon_name_id="#taxon_name_id#">
			 <cfquery name="d" datasource="uam_god">
				select * from taxonomy where scientific_name='#scientific_name#'
			</cfquery>
			<cfquery name="tt" datasource="uam_god">
				insert into taxon_name (taxon_name_id,scientific_name) values (#d.taxon_name_id#,'#d.SCIENTIFIC_NAME#')
			</cfquery>
			<cfset orderedTerms="KINGDOM,PHYLUM,PHYLCLASS,SUBCLASS,PHYLORDER,SUBORDER,SUPERFAMILY,FAMILY,SUBFAMILY,TRIBE,GENUS,SUBGENUS,SPECIES,SUBSPECIES">
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
							source
						) values (
							sq_taxon_term_id.nextval,
							#d.taxon_name_id#,
							'#thisTermVal#',
							'#lcase(termtype)#',
							'Arctos'
						)
					</cfquery>
					<cfset pos=pos+1>
				</cfif>
			</cfloop>
			<cfhttp url="http://resolver.globalnames.org/name_resolvers.json?names=#scientific_name#"></cfhttp>
			<cfset x=DeserializeJSON(cfhttp.filecontent)>
			<cfloop from="1" to="#ArrayLen(x.data[1].results)#" index="i">
				<cfset pos=1>
				<!--- because lists are stupid and ignore NULLs.... ---->
				<cfif structKeyExists(x.data[1].results[i],"classification_path") and structKeyExists(x.data[1].results[i],"classification_path_ranks")>
					<cfset cterms=ListToArray(x.data[1].results[i].classification_path, "|", true)>
					<cfset cranks=ListToArray(x.data[1].results[i].classification_path_ranks, "|", true)>
					 
					<cfset thisSource=x.data[1].results[i].data_source_title>
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
					
					<br>thisSource: #thisSource#
					<cfloop from="1" to="#arrayLen(cterms)#" index="listPos">
						<cfset thisTerm=cterms[listpos]>
						<br>thisTerm: #thisTerm#
						<cfif ArrayIsDefined(cranks, listpos)>
							<cfset thisRank=cranks[listpos]>
							exists....
						<cfelse>
							<cfset thisRank=''>
							noexists....
						</cfif>
						
						 ---- thisRank: #thisRank#
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
									gn_score
								) values (
									sq_taxon_term_id.nextval,
									#d.taxon_name_id#,
									'#thisTerm#',
									'#lcase(thisRank)#',
									'#thisSource#',
									#pos#,
									'#thisSourceID#',
									#thisScore#
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
								source
							) values (
								sq_taxon_term_id.nextval,
								#d.taxon_name_id#,
								'#thisNameString#',
								'name string',
								'#thisSource#'
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
								source
							) values (
								sq_taxon_term_id.nextval,
								#d.taxon_name_id#,
								'#thisCanonicalFormName#',
								'canonical name',
								'#thisSource#'
							)
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>
		 </cfthread>
	</cfloop>