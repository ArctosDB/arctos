<!-------

setup

drop table taxon_metadata;
drop table taxon_term;


-- "dictionary" table
create table taxon_term (
	taxon_name_id number not null primary key,
	scientific_name varchar2(255) not null
);

-- as now, "scientific name" is globally unique

create unique index ix_temp_tt_sciname on taxon_term(scientific_name) tablespace uam_idx_1;

taxon_name_id is a local primary key
scientific_name retains it's current meaning: a literature-derived term (eg, not something you made up) - "Sorex cinereus" and "Animalia"
-- metadata table
create table taxon_metadata (
	tmid number not null primary key,
	taxon_name_id number not null,
	term varchar2(255) not null,
	term_type varchar2(255),
	source varchar2(255) not null,
	position_in_source_hierarchy number,
	 CONSTRAINT fk_tnid
    FOREIGN KEY (taxon_name_id)
    REFERENCES taxon_term (taxon_name_id)
  );

tmid  - local primary key
taxon_name_id - foreign key to taxon_metadata
term - any string
term_type - rank or "metadata class"
source "classification" - Arctos, EOL, NCBI, etc.
position_in_source_hierarchy - dual-purpose integer that 
	(1) when NOT NULL, indicates that this is a taxon term usable in building "hierarchy" from the source, or 
	(2) when NULL,  indicates a non-taxno-term value, such as "botanical display name"
 CONSTRAINT fk_tnid
   FOREIGN KEY (taxon_name_id)
   REFERENCES taxon_term (taxon_name_id)




delete from taxon_metadata;
delete from taxon_term;
commit;


------------>


<cfinclude template="/includes/_header.cfm">

<cfoutput>


<a href="/fix/taxonomyservice.cfm?action=popFromArctos">popFromArctos</a>

<br>


<a href="/fix/taxonomyservice.cfm?action=whatsThere">whatsThere</a>
<br>


<a href="/fix/taxonomyservice.cfm?action=pullFromGlobalnames">pullFromGlobalnames</a>



	<cfif action is "pullFromGlobalnames">
		<cfhttp url="http://resolver.globalnames.org/name_resolvers.json?names=#scientific_name#"></cfhttp>
		<cfset x=DeserializeJSON(cfhttp.filecontent)>
		<br>JSON result converted to object
		<br>get taxon_name_id
		<cfquery name="d" datasource="uam_god">
			select taxon_name_id from taxon_term where scientific_name='#scientific_name#'
		</cfquery>
		<cfdump var=#d#>
		<cfloop from="1" to="#ArrayLen(x.data[1].results)#" index="i">
			<cfset pos=1>
			<br>listlen(x.data[1].results[i].classification_path,"|"): #listlen(x.data[1].results[i].classification_path,"|")#
			<br>listlen(x.data[1].results[i].classification_path_ranks,"|"): #listlen(x.data[1].results[i].classification_path_ranks,"|")#
			
			<br>x.data[1].results[i].classification_path: #x.data[1].results[i].classification_path#
			<br>x.data[1].results[i].classification_path_ranks: #x.data[1].results[i].classification_path_ranks#
			
			
			 
			
			<cfloop from="1" to="#listlen(x.data[1].results[i].classification_path,"|")#" index="listPos">
				<cfset thisTerm=listgetat(x.data[1].results[i].classification_path,listPos,"|")>
				<cfset thisRank=listgetat(x.data[1].results[i].classification_path_ranks,listPos,"|")>
				<br>thisTerm: #thisTerm# ---- thisRank: #thisRank#
			</cfloop>
			
			<!------------
			<cfquery name="meta" datasource="uam_god">
				insert into taxon_metadata (
					tmid,
					taxon_name_id,
					term,
					term_type,
					source,
					position_in_source_hierarchy
				) values (
					somerandomsequence.nextval,
					#d.taxon_name_id#,
					'#thisTermVal#',
					'#lcase(termtype)#',
					'Arctos',
					#pos#
				)
			</cfquery>
			<cfset pos=pos+1>
				
				
			
			<cfset thisDataSource=x.data[1].results[i].data_source_title[1]>
			<cfset thisclassification_path
			<hr>
			loop #i#
			<br>canonical_form 	#x.data[1].results[i].canonical_form#
			<br>classification_path 	#x.data[1].results[i].classification_path#
			<br>
			<br>classification_path_ranks 	#x.data[1].results[i].classification_path_ranks#
			<br>data_source_title 	##
			
			------------>
		</cfloop>



		<!----
			<cfset xmlDoc=xmlParse(cfhttp.filecontent)>
<!-----
				<cfdump var=#xmlDoc#>
---->
<cfdump var=#xmlDoc.hash#>




<cfdump var=#xmlDoc.hash.data.datum.results#>



<cfloop from="1" to="#ArrayLen(xmlDoc.hash.data.datum.results.result)#" index="i">
	<p>#i#
	<cfset a=xmlDoc.hash.data.datum.results.result[i].xmlattributes>
		<cfdump var=#a#>
				
				
	</p>
</cfloop>
		---->
	

	</cfif>

	<cfif action is "whatsThere">
		<br>
		get everything with one trip to the DB
		<br>
		select * from taxon_term,taxon_metadata where 
			taxon_term.taxon_name_id=taxon_metadata.taxon_name_id (+) and
			scientific_name='#scientific_name#'
		<cfquery name="d" datasource="uam_god">
			select * from taxon_term,taxon_metadata where 
			taxon_term.taxon_name_id=taxon_metadata.taxon_name_id (+) and
			scientific_name='#scientific_name#'
		</cfquery>
		<cfdump var=#d#>
		<br>
		
		get THE scientific_name with a local CF query
		
		<br>
	
		
		<cfquery name="scientific_name" dbtype="query">
			select scientific_name from d group by scientific_name
		</cfquery>
		<cfdump var=#scientific_name#>
		<br>
		get taxon terms ordered by classification then by position_in_source_hierarchy
		<br>
		
		<br>
		<cfquery name="taxterms" dbtype="query">
		select source,term,term_type,position_in_source_hierarchy from d where position_in_source_hierarchy is not null group by 
		source,term,term_type,position_in_source_hierarchy order by source,position_in_source_hierarchy 
		</cfquery>
		<cfdump var=#taxterms#>
		
		get non-taxon terms ordered by classification
		<br>
		
		<br>
		<cfquery name="nontaxterms" dbtype="query">
		select term,term_type,source from  d where position_in_source_hierarchy is null order by source,term_type
		</cfquery>
		<cfdump var=#nontaxterms#>
		
		
	</cfif>
<!-------------------------------------------------------------->
	<cfif action is "popFromArctos">
		<cfquery name="d" datasource="uam_god">
			select * from taxonomy where scientific_name='#scientific_name#'
		</cfquery>
		<cfset pos=1>
		<cfquery name="tt" datasource="uam_god">
			insert into taxon_term (taxon_name_id,scientific_name) values (#d.taxon_name_id#,'#d.SCIENTIFIC_NAME#')
		</cfquery>
		<!--- first, taxon terms ---->
		<cfset orderedTerms="KINGDOM,PHYLUM,PHYLCLASS,SUBCLASS,PHYLORDER,SUBORDER,SUPERFAMILY,FAMILY,SUBFAMILY,TRIBE,GENUS,SUBGENUS,SPECIES,SUBSPECIES">
		<cfloop list="#orderedTerms#" index="termtype">
			<cfset thisTermVal=evaluate("d." & termtype)>
			<cfif len(thisTermVal) gt 0>
				<cfif termtype is "SUBSPECIES" and len(d.INFRASPECIFIC_RANK) gt 0>
					<cfset thisTermVal=d.INFRASPECIFIC_RANK>
				</cfif>
				<cfquery name="meta" datasource="uam_god">
					insert into taxon_metadata (
						tmid,
						taxon_name_id,
						term,
						term_type,
						source,
						position_in_source_hierarchy
					) values (
						somerandomsequence.nextval,
						#d.taxon_name_id#,
						'#thisTermVal#',
						'#lcase(termtype)#',
						'Arctos',
						#pos#
					)
				</cfquery>
				<cfset pos=pos+1>
			</cfif>
		</cfloop>
		<!--- then "non-taxonomy metadata" - we may not want to keep all this stuff, so discuss before any large-scale migration ---->
		<cfset orderedTerms="VALID_CATALOG_TERM_FG|SOURCE_AUTHORITY|AUTHOR_TEXT|TAXON_REMARKS|NOMENCLATURAL_CODE|INFRASPECIFIC_AUTHOR|DISPLAY_NAME|TAXON_STATUS">
		<cfloop list="#orderedTerms#" index="termtype" delimiters="|">
			<cfset thisTermVal=evaluate("d." & termtype)>
			<cfif len(thisTermVal) gt 0>
				<cfquery name="meta" datasource="uam_god">
					insert into taxon_metadata (
						tmid,
						taxon_name_id,
						term,
						term_type,
						source
					) values (
						somerandomsequence.nextval,
						#d.taxon_name_id#,
						'#thisTermVal#',
						'#lcase(termtype)#',
						'Arctos'
					)
				</cfquery>
				<cfset pos=pos+1>
			</cfif>
		</cfloop>
	</cfif>
</cfoutput>