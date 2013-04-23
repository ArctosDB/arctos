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

<cfif not isdefined("scientific_name") or len(scientific_name) is 0>
	add "?scientific_name=somescientificname to the URL.
	
	<cfquery name="has" datasource="uam_god">
		select scientific_name from taxon_term order by scientific_name
	</cfquery>
	<hr>
	These exist:
	<cfloop query="has">
		<br><a href="taxonomyservice?scientific_name=#scientific_name#">#scientific_name#</a>
	</cfloop>
	<hr>
	Here are some you can create:
	<cfquery name="nohas" datasource="uam_god">
		select scientific_name from taxonomy where scientific_name not in (select scientific_name from taxon_term) and rownum<20
	</cfquery>
	<cfloop query="nohas">
		<br><a href="taxonomyservice?scientific_name=#scientific_name#">#scientific_name#</a>
	</cfloop>
</cfif>
<cfif isdefined("scientific_name") and len(scientific_name) gt 0>
	<cfquery name="d" datasource="uam_god">
		select * from taxon_term,taxon_metadata where 
		taxon_term.taxon_name_id=taxon_metadata.taxon_name_id (+) and
		scientific_name='#scientific_name#'
	</cfquery>
	<cfdump var=#d#>
	<cfif d.recordcount gt 0>
		#scientific_name# has an entry - here it is
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
		<cfquery name="taxterms" dbtype="query">
			select source,term,term_type,position_in_source_hierarchy from d where position_in_source_hierarchy is not null group by 
			source,term,term_type,position_in_source_hierarchy order by source,position_in_source_hierarchy 
		</cfquery>
		<cfdump var=#taxterms#>
		get non-taxon terms ordered by classification		
		<br>
		<cfquery name="nontaxterms" dbtype="query">
			select term,term_type,source from  d where position_in_source_hierarchy is null order by source,term_type
		</cfquery>
		<cfdump var=#nontaxterms#>
		
		<br> we can create "hierarchies"....
		<br>get distinct sources....
		<cfquery name="sources" dbtype="query">
			select source from d group by source order by source
		</cfquery>
		<cfdump var=#sources#>
		<br>loop through them...
		<cfloop query="sources">
			<p>Hierarchy according to #source#:</p>
			<cfquery name="thisone" dbtype="query">
				select 
					term,
					term_type 
				from 
					d 
				where 
					position_in_source_hierarchy is not null and 
					source='#source#' 
				group by 
					term,
					term_type 
				order by 
					position_in_source_hierarchy 
			</cfquery>
			<cfdump var=#thisone#>
			<cfset indent=1>
			<cfloop query="thisone">
				<div style="padding-left:#indent#em;">
					#term#
					<cfif len(term_type) gt 0>
						(#term_type#)
					</cfif>
				</div>
				<cfset indent=indent+1>
			</cfloop>
		</cfloop>
	<cfelse><!--- fetch the name ---->
		that name does not exist in the experimental structure - pulling it.....
		<br>first make the Arctos entry.....
		<cfquery name="d" datasource="uam_god">
			select * from taxonomy where scientific_name='#scientific_name#'
		</cfquery>
		<cfdump var=#d#>
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
		<br>now get service data.....
		<cfhttp url="http://resolver.globalnames.org/name_resolvers.json?names=#scientific_name#"></cfhttp>
		<cfset x=DeserializeJSON(cfhttp.filecontent)>
		<cfquery name="d" datasource="uam_god">
			select taxon_name_id from taxon_term where scientific_name='#scientific_name#'
		</cfquery>
		<cfdump var=#d#>
		<cfif len(d.taxon_name_id) is 0>
			taxon name not found<cfabort>
		</cfif>
		<cfloop from="1" to="#ArrayLen(x.data[1].results)#" index="i">
			<cfset pos=1>
			<!--- because lists are stupid and ignore NULLs.... ---->
			<cfset cterms=ListToArray(x.data[1].results[i].classification_path, "|", true)>
			<cfset cranks=ListToArray(x.data[1].results[i].classification_path_ranks, "|", true)>
			 
			<cfset thisSource=x.data[1].results[i].data_source_title>
			<cfloop from="1" to="#arrayLen(cterms)#" index="listPos">
				<cfset thisTerm=cterms[listpos]>
				<cfset thisRank=cranks[listpos]>
				<br>thisTerm: #thisTerm# ---- thisRank: #thisRank#
				<cfif len(thisTerm) gt 0>
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
							'#thisTerm#',
							'#lcase(thisRank)#',
							'#thisSource#',
							#pos#
						)
					</cfquery>
				<cfset pos=pos+1>
				</cfif>
			
			</cfloop>
		</cfloop>
		<hr>
		name+data created....		
		<br><a href="taxonomyservice?scientific_name=#scientific_name#">click here to see #scientific_name#</a>
	</cfif>
</cfoutput>