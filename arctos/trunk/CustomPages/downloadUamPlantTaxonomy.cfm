<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfif action is "nothing">
		<p>
			Click the following links to build and download CSV. Please note that the resulting files with be
			UTF-8 encoded and may not work properly in Excel.
		</p>
		<a href="downloadUamPlantTaxonomy.cfm?action=getMain">Taxa used in identifications for UAM Herbarium collections</a>
		
		<br>
		<a href="downloadUamPlantTaxonomy.cfm?action=related">Taxa related to taxa used in identifications for UAM Herbarium collections</a>
		<br>
		<a href="downloadUamPlantTaxonomy.cfm?action=common">common names</a>
		
	</cfif>
	<cfif action is "common">
		<cfquery name="d" datasource="uam_god">
			select taxon_name_id,common_name from (
			select
				common_name.taxon_name_id,
				common_name
			from
				common_name,
				identification,
				identification_taxonomy,
				cataloged_item
			where
				common_name.taxon_name_id = identification_taxonomy.taxon_name_id and
				identification_taxonomy.identification_id=identification.identification_id and
				identification.collection_object_id = cataloged_item.collection_object_id and
				cataloged_item.collection_id in (6,40)
			union
			select
					common_name.taxon_name_id,
					common_name
				from
					taxon_relations,
					common_name,
					identification,
					identification_taxonomy,
					cataloged_item
				where
					taxon_relations.taxon_name_id = common_name.taxon_name_id and
					taxon_relations.related_taxon_name_id=identification_taxonomy.taxon_name_id and
					identification_taxonomy.identification_id=identification.identification_id and
					identification.collection_object_id = cataloged_item.collection_object_id and
					cataloged_item.collection_id in (6,40)
			) group by taxon_name_id,common_name 
			</cfquery>
			<cfset variables.fileName="#Application.webDirectory#/download/commonname.csv">
			<cfset variables.encoding="UTF-8">
			<cfscript>
				variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			</cfscript>
			<cfscript>
				a='"taxon_name_id","common_name"';
				variables.joFileWriter.writeLine(a);
			</cfscript>		
			<cfloop query="d">
				<cfscript>
					a='"' & taxon_name_id & '","' & common_name & '"';
					variables.joFileWriter.writeLine(a);
				</cfscript>	
			</cfloop>
			<cfscript>
				variables.joFileWriter.close();
			</cfscript>
			<a href="/download/commonname.csv">download</a>
	</cfif>
	<cfif action is "getMain">
		<cfquery name="d" datasource="uam_god">
			select
				t.taxon_name_id,
				t.KINGDOM,
				t.PHYLUM,		
				t.PHYLCLASS,
				t.SUBCLASS,
				t.PHYLORDER,
				t.SUBORDER,	
				t.SUPERFAMILY,
				t.FAMILY,
				t.SUBFAMILY,
				t.TRIBE,
				t.GENUS,
				t.SUBGENUS,
				t.SPECIES,
				t.AUTHOR_TEXT,		
				t.INFRASPECIFIC_RANK,
				t.SUBSPECIES,
				t.INFRASPECIFIC_AUTHOR,	
				t.NOMENCLATURAL_CODE,
				t.VALID_CATALOG_TERM_FG,
				t.SOURCE_AUTHORITY,
				t.TAXON_REMARKS,
				t.FULL_TAXON_NAME,
				t.SCIENTIFIC_NAME,				
				t.DISPLAY_NAME
			from
				taxonomy t,
				identification,
				identification_taxonomy,
				cataloged_item
			where
				t.taxon_name_id = identification_taxonomy.taxon_name_id and
				identification_taxonomy.identification_id=identification.identification_id and
				identification.collection_object_id = cataloged_item.collection_object_id and
				cataloged_item.collection_id in (6,40)
			group by
				t.taxon_name_id,
				t.KINGDOM,
				t.PHYLUM,		
				t.PHYLCLASS,
				t.SUBCLASS,
				t.PHYLORDER,
				t.SUBORDER,	
				t.SUPERFAMILY,
				t.FAMILY,
				t.SUBFAMILY,
				t.TRIBE,
				t.GENUS,
				t.SUBGENUS,
				t.SPECIES,
				t.AUTHOR_TEXT,		
				t.INFRASPECIFIC_RANK,
				t.SUBSPECIES,
				t.INFRASPECIFIC_AUTHOR,	
				t.NOMENCLATURAL_CODE,
				t.VALID_CATALOG_TERM_FG,
				t.SOURCE_AUTHORITY,
				t.TAXON_REMARKS,
				t.FULL_TAXON_NAME,
				t.SCIENTIFIC_NAME,				
				t.DISPLAY_NAME
			</cfquery>
			<cfset variables.fileName="#Application.webDirectory#/download/uamplanttaxa.csv">
			<cfset variables.encoding="UTF-8">
			<cfscript>
				variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			</cfscript>
			<cfscript>
				a='"taxon_name_id","kingdom","phylum","phylclass","subclass","phylorder","suborder","superfamily","family","subfamily","tribe","genus","subgenus","species","author_text","infraspecific_rank","subspecies","infraspecific_author","nomenclatural_code","valid_catalog_term_fg","source_authority","taxon_remarks","full_taxon_name","scientific_name","display_name"';
				variables.joFileWriter.writeLine(a);
			</cfscript>		
			<cfloop query="d">
				<cfscript>
					a='"' & taxon_name_id & '","' & kingdom & '","' & phylum & '","' & phylclass & '","' & subclass & '","' & phylorder & '","' & suborder & '","' & superfamily & '","' & family & '","' & subfamily & '","' & tribe & '","' & genus & '","' & subgenus & '","' & species & '","' & author_text & '","' & infraspecific_rank & '","' & subspecies & '","' & infraspecific_author & '","' & nomenclatural_code & '","' & valid_catalog_term_fg & '","' & source_authority & '","' & taxon_remarks & '","' & full_taxon_name & '","' & scientific_name & '","' & display_name & '"';
					variables.joFileWriter.writeLine(a);
				</cfscript>	
			</cfloop>
			<cfscript>
				variables.joFileWriter.close();
			</cfscript>
			<a href="/download/uamplanttaxa.csv">download</a>
	</cfif>
	<cfif action is "related">
		<cfquery name="d" datasource="uam_god">
			select
				taxon_relations.taxon_name_id,
				taxon_relations.related_taxon_name_id,
				t.KINGDOM,
				t.PHYLUM,		
				t.PHYLCLASS,
				t.SUBCLASS,
				t.PHYLORDER,
				t.SUBORDER,	
				t.SUPERFAMILY,
				t.FAMILY,
				t.SUBFAMILY,
				t.TRIBE,
				t.GENUS,
				t.SUBGENUS,
				t.SPECIES,
				t.AUTHOR_TEXT,		
				t.INFRASPECIFIC_RANK,
				t.SUBSPECIES,
				t.INFRASPECIFIC_AUTHOR,	
				t.NOMENCLATURAL_CODE,
				t.VALID_CATALOG_TERM_FG,
				t.SOURCE_AUTHORITY,
				t.TAXON_REMARKS,
				t.FULL_TAXON_NAME,
				t.SCIENTIFIC_NAME,				
				t.DISPLAY_NAME,
				TAXON_RELATIONSHIP,
				RELATION_AUTHORITY
			from
				taxon_relations,
				taxonomy t,
				identification,
				identification_taxonomy,
				cataloged_item
			where
				taxon_relations.related_taxon_name_id = t.taxon_name_id and 
				taxon_relations.taxon_name_id = identification_taxonomy.taxon_name_id and
				identification_taxonomy.identification_id=identification.identification_id and
				identification.collection_object_id = cataloged_item.collection_object_id and
				cataloged_item.collection_id in (6,40)
			group by
				taxon_relations.taxon_name_id,
				taxon_relations.related_taxon_name_id,
				t.KINGDOM,
				t.PHYLUM,		
				t.PHYLCLASS,
				t.SUBCLASS,
				t.PHYLORDER,
				t.SUBORDER,	
				t.SUPERFAMILY,
				t.FAMILY,
				t.SUBFAMILY,
				t.TRIBE,
				t.GENUS,
				t.SUBGENUS,
				t.SPECIES,
				t.AUTHOR_TEXT,		
				t.INFRASPECIFIC_RANK,
				t.SUBSPECIES,
				t.INFRASPECIFIC_AUTHOR,	
				t.NOMENCLATURAL_CODE,
				t.VALID_CATALOG_TERM_FG,
				t.SOURCE_AUTHORITY,
				t.TAXON_REMARKS,
				t.FULL_TAXON_NAME,
				t.SCIENTIFIC_NAME,				
				t.DISPLAY_NAME,
				TAXON_RELATIONSHIP,
				RELATION_AUTHORITY
			</cfquery>
			<cfset variables.fileName="#Application.webDirectory#/download/uamrelatedplanttaxa.csv">
			<cfset variables.encoding="UTF-8">
			<cfscript>
				variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			</cfscript>
			<cfscript>
				a='"ID_taxon_name_id","taxon_name_id","kingdom","phylum","phylclass","subclass","phylorder","suborder","superfamily","family","subfamily","tribe","genus","subgenus","species","author_text","infraspecific_rank","subspecies","infraspecific_author","nomenclatural_code","valid_catalog_term_fg","source_authority","taxon_remarks","full_taxon_name","scientific_name","display_name","taxon_relationship","relation_authority"';
				variables.joFileWriter.writeLine(a);
			</cfscript>		
			<cfloop query="d">
				<cfscript>
					a='"' & taxon_name_id & '","' & related_taxon_name_id & '","' & kingdom & '","' & phylum & '","' & phylclass & '","' & subclass & '","' & phylorder & '","' & suborder & '","' & superfamily & '","' & family & '","' & subfamily & '","' & tribe & '","' & genus & '","' & subgenus & '","' & species & '","' & author_text & '","' & infraspecific_rank & '","' & subspecies & '","' & infraspecific_author & '","' & nomenclatural_code & '","' & valid_catalog_term_fg & '","' & source_authority & '","' & taxon_remarks & '","' & full_taxon_name & '","' & scientific_name & '","' & display_name & '","' & taxon_relationship & '","' & relation_authority & '"';
					variables.joFileWriter.writeLine(a);
				</cfscript>	
			</cfloop>
			<cfscript>
				variables.joFileWriter.close();
			</cfscript>
			ID_taxon_name_id is the taxon_name_id used in an identification, and will appear in the file from <a href="downloadUamPlantTaxonomy.cfm?action=getMain">Taxa used in identifications for UAM Herbarium collections</a>
			<p>
				taxon_name_id is the ID of the record in this file.
			</p>
			<a href="/download/uamrelatedplanttaxa.csv">download</a>
	</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
