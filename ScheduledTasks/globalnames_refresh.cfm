<!---- some way of keeping track of stuff....

drop table taxon_refresh_log;
create table taxon_refresh_log (
	taxon_name_id number,
	taxon_name varchar2(255),
	lastfetch date
);


get stuff into that table HOWEVER.

anything with a timestamp gets ignored



insert into taxon_refresh_log (
	taxon_name_id,
	taxon_name) (
		select
		taxon_name_id,
		scientific_name
		from taxon_name where taxon_name_id in (
		select taxon_name_id from taxon_term where source='GBIF Taxonomic Backbone'
		)
	)
;




**********************

This form may be called in two ways:

- a bare call will find records from the refresh log and process them

- a call with a "name" parameter will run for that name


 ---->




<cfoutput>
	<cfif isdefined("name") and len(name) gt 0>
		<cfquery name="d" datasource="uam_god">
			select * from taxon_refresh_log where TAXON_NAME='#name#'
		</cfquery>
		<cfif d.recordcount lt 1>
			<cfquery name="t" datasource="uam_god">
				select TAXON_NAME_ID from taxon_name where scientific_name='#name#'
			</cfquery>
			<cfif len(t.taxon_name_id) is 0>
				bad call<cfabort>
			</cfif>
			<cfquery name="ins" datasource="uam_god">
				insert into taxon_refresh_log (TAXON_NAME_ID,TAXON_NAME,LASTFETCH) values (#t.taxon_name_id#,'#name#',sysdate)
			</cfquery>
			<cfquery name="d" datasource="uam_god">
				select * from taxon_refresh_log where TAXON_NAME='#name#'
			</cfquery>
		</cfif>
	<cfelse><!--- no-name run ---->
		<cfif not isdefined("numberOfNamesOneFetch")>
			<cfset numberOfNamesOneFetch=200>
		</cfif>
		<cfquery name="checknew" datasource="uam_god">
			insert into taxon_refresh_log (TAXON_NAME_ID,TAXON_NAME) (
				select TAXON_NAME_ID,scientific_name from taxon_name where taxon_name_id not in (
					select TAXON_NAME_ID from taxon_refresh_log
				)
				and rownum<500
			)
		</cfquery>
		<!---
			globalnames cannot deal with plus-symbol, so ignore them all for now
			No, nobody knows why Oracle thinks chr(215) is spelt chr(50071
		---->
		<cfquery name="ignorethis" datasource="uam_god">
			update taxon_refresh_log set lastfetch=sysdate where instr(TAXON_NAME,chr(50071)) > 0
		</cfquery>

		<cfquery name="d" datasource="uam_god">
			select * from taxon_refresh_log where lastfetch is null and rownum < #numberOfNamesOneFetch#
		</cfquery>

		<cfif d.recordcount is 0>
			<!---- start at old and work newer ---->
			<cfquery name="d" datasource="uam_god">
				select * from taxon_refresh_log where sysdate-lastfetch>90 and rownum < #numberOfNamesOneFetch#
			</cfquery>
		</cfif>
	</cfif>


	<cfset theseNames=valuelist(d.taxon_name,'|')>



	<cfloop condition = "theseNames contains chr(215)">
		<cfset theseNames=listdeleteat(theseNames,ListContainsNoCase(theseNames,chr(215),'|'),"|")>
	</cfloop>


	<cfloop condition = "len(theseNames) gt 6300">
		<cfset theseNames=listdeleteat(theseNames,listlen(theseNames,"|"),"|")>
	</cfloop>
	<cfquery name="tti" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select source from ctTAXONOMY_SOURCE
	</cfquery>
	<cfset sourcesToIgnore=valuelist(tti.source,'|')>

	<cfset sourcesToIgnoreComma=valuelist(tti.source)>



	<cfset theseTaxonNameIds="">


<!----

---->




	<cfset jsfail=true>
	<cfloop condition="jsfail is true">
		<br>coming in loop: jsfail=#jsfail#
		<p>
			http://resolver.globalnames.org/name_resolvers.json?names=#theseNames#
		</p>
		<cfhttp url="http://resolver.globalnames.org/name_resolvers.json?names=#theseNames#"></cfhttp>

		<cfdump var=#cfhttp#>
		<cfif cfhttp.Responseheader.Status_Code contains "500">
			<cfset theNameThatFailed=listgetat(theseNames,1,'|')>
			<br>testing for failure: #theNameThatFailed#
			<cfset theseNames=listdeleteat(theseNames,1,'|')>
		<cfelse>
			<cfif isdefined("theNameThatFailed") and len(theNameThatFailed) gt 0>
				<br>theNameThatFailed: #theNameThatFailed#
				<cfquery name="FAIL" datasource="uam_god">
					update taxon_refresh_log set lastfetch=sysdate where taxon_name = '#theNameThatFailed#'
				</cfquery>
			</cfif>
			<cfset jsfail=false>
		</cfif>

		<br>exitig loop: jsfail=#jsfail#
	</cfloop>


<br>out of the loop here we go!


	<cfset x=DeserializeJSON(cfhttp.filecontent)>
	<cfloop from="1" to="#ArrayLen(x.data)#" index="thisResultIndex">
		<cfset thisName=listgetat(theseNames,thisResultIndex,"|")>
		<!----
			<hr>thisName::::::::::::::::::::::::::: #thisName#
		---->




		<cfquery name="dfd" dbtype="query">
			select taxon_name_id from d where taxon_name='#thisName#'
		</cfquery>
		<cfset thisTaxonNameID=dfd.taxon_name_id>
		<!--- just delete all previously-fetched globalnames data ---->
		<cfquery name="flush_old" datasource="uam_god">
			delete from taxon_term where taxon_name_id=#thisTaxonNameID#
			and source not in (#listqualify(sourcesToIgnoreComma,chr(39))#)
		</cfquery>
		<cftry>
			<cfif structKeyExists(x.data[thisResultIndex],"results")>
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
								<cfif len(thisScore) is 0>
									<cfset thisScore=0>
								</cfif>
								<cfset thisNameString=x.data[thisResultIndex].results[i].name_string>
								<cfif structKeyExists(x.data[thisResultIndex].results[i],"canonical_form")>
									<cfset thisCanonicalFormName=x.data[thisResultIndex].results[i].canonical_form>
								<cfelse>
									<cfset thisCanonicalFormName=''>
								</cfif>
								<cfloop from="1" to="#arrayLen(cterms)#" index="listPos">
									<cfset thisTerm=cterms[listpos]>
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
											#thisTaxonNameID#,
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
											#thisTaxonNameID#,
											'#thisCanonicalFormName#',
											'canonical name',
											'#thisSource#',
											'#thisSourceID#'
										)
									</cfquery>
								</cfif>
							</cfif><!---- end is something to ignore ---->
						</cfif><!---- end has classification path check ---->
					</cfif><!----- end classification_path struct exists check ------>
				</cfloop><!---- end array data loop ---->
				<cfset theseTaxonNameIds=listappend(theseTaxonNameIds,thisTaxonNameID)>
			<cfelse><!---- end results struct exists check ----->
				<br>no results exists
				<cfquery name="gotit" datasource="uam_god">
					update taxon_refresh_log set lastfetch=sysdate where taxon_name_id = #thisTaxonNameID#
				</cfquery>
			</cfif>
			<cfcatch>
				<cfdump var=#cfcatch#>
				<!---
				<cf_logError subject="globalnames_refresh error" attributeCollection=#cfcatch#>
				--->
			</cfcatch>
		</cftry>
	</cfloop><!---- end looping over results ---->
	<cfif len(theseTaxonNameIds) gt 0>
		<cfquery name="gotit" datasource="uam_god">
			update taxon_refresh_log set lastfetch=sysdate where taxon_name_id in (#theseTaxonNameIds#)
		</cfquery>
	</cfif>
	<cfif isdefined("name") and len(name) gt 0>
		<!--- we came here on a name, redirect back to the taxon page ---->
		<cflocation url="/name/#name#" addtoken="false">
	</cfif>
</cfoutput>