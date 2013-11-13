<cfabort>




	<cfinclude template="/includes/_header.cfm">

create table dmnsinvtax as select taxon_name.scientific_name from taxon_name,identification_taxonomy,identification,cataloged_item
where
taxon_name.taxon_name_id=identification_taxonomy.taxon_name_id and
identification_taxonomy.identification_id=identification.identification_id and
identification.collection_object_id=cataloged_item.collection_object_id and
cataloged_item.collection_id=74 group by taxon_name.scientific_name;

alter table dmnsinvtax add done number;



update dmnsinvtax set done=47 where scientific_name in (select scientific_name from taxon_name,taxon_term where taxon_name.taxon_name_id=taxon_term.taxon_name_id);

select scientific_name from dmnsinvtax  where scientific_name not in 
(select scientific_name from taxon_name,taxon_term where taxon_name.taxon_name_id=taxon_term.taxon_name_id);


<cfoutput>

<cfquery name="c" datasource="uam_god">
	select scientific_name from dmnsinvtax where done is null and rownum<101
</cfquery>
	<cfset sourcesToIgnore="Arctos">


<cfloop query="c">
<hr>
	<cfset name=scientific_name>
	<br>#scientific_name#



<cfquery name="c" datasource="uam_god">
	update dmnsinvtax set done=1 where scientific_name='#scientific_name#'
</cfquery>
	<cfquery name="ids" datasource="uam_god">
		select 
			taxon_name_id 
		from 
			taxon_name 
		where 
			scientific_name='#name#'
	</cfquery>
	<cfloop query="ids">
		 <cfquery name="d" datasource="uam_god">
			select scientific_name,taxon_name_id from taxon_name where taxon_name_id='#taxon_name_id#'
		</cfquery>
		<cfhttp url="http://resolver.globalnames.org/name_resolvers.json?names=#d.scientific_name#"></cfhttp>
		<cfset x=DeserializeJSON(cfhttp.filecontent)>
		<cfloop from="1" to="#ArrayLen(x.data[1].results)#" index="i">
			<cfset pos=1>
			<!--- because lists are stupid and ignore NULLs.... ---->
			<cfif structKeyExists(x.data[1].results[i],"classification_path") and structKeyExists(x.data[1].results[i],"classification_path_ranks")>
				<cfset cterms=ListToArray(x.data[1].results[i].classification_path, "|", true)>
				<cfif listlen(x.data[1].results[i].classification_path, "|") gt 1>
					<!--- ignore the stuff with no useful classification, which includes one-term "classifications" --->
					<cfset cranks=ListToArray(x.data[1].results[i].classification_path_ranks, "|", true)>
					 
					<cfset thisSource=x.data[1].results[i].data_source_title>
					<cfif not listfindnocase(sourcesToIgnore,thisSource,"|")>
						<cfset thisSourceID=x.data[1].results[i].classification_path_ids>
						<cfif len(thisSourceID) is 0>
							<cfset thisSourceID=CreateUUID()>
						<cfelse>
							<!------------ 
								delete (so we can reinsert to update) from Arctos 
								if we already have the classification.
								
								Delete is just cheaper/easier than checking for existing, updating lastdate, etc.
								
								Don't bother if we're creating a UUID - it won't exist (that's the point!) so save 
								a trip to the DB
							--------------->
							<cfquery name="flush_old" datasource="uam_god">
								delete from taxon_term where taxon_name_id=#d.taxon_name_id#
								and classification_id='#thisSourceID#'
							</cfquery>
						</cfif>
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
						
						<cfset thisScore=x.data[1].results[i].score>
						<cfif len(thisScore) is 0><cfset thisScore=0></cfif>
						<cfset thisNameString=x.data[1].results[i].name_string>
						<cfset thisCanonicalFormName=x.data[1].results[i].canonical_form>
						
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
			</cfif>
		</cfloop>
	</cfloop>
</cfloop>
			</cfoutput>
		<cfinclude template="/includes/_footer.cfm">

