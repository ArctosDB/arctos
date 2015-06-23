<!----

	drop table cf_temp_classification;


	create table cf_temp_classification (
		status varchar2(255),
		operation  varchar2(255),
		taxon_name_id number,
		scientific_name varchar2(255) not null,
		author_text varchar2(255) null,
		infraspecific_author varchar2(255) null,
		nomenclatural_code varchar2(255) null,
		source_authority varchar2(255) null,
		valid_catalog_term_fg varchar2(255) null,
		taxon_status varchar2(255) null,
		remark varchar2(255) null,
		superkingdom varchar2(255) null,
		kingdom varchar2(255) null,
		subkingdom varchar2(255) null,
		infrakingdom varchar2(255) null,
		superphylum varchar2(255) null,
		phylum varchar2(255) null,
		subphylum varchar2(255) null,
		subdivision varchar2(255) null,
		infraphylum varchar2(255) null,
		superclass varchar2(255) null,
		class varchar2(255) null,
		subclass varchar2(255) null,
		infraclass varchar2(255) null,
		hyperorder varchar2(255) null,
		superorder varchar2(255) null,
		phylorder varchar2(255) null,
		suborder varchar2(255) null,
		infraorder varchar2(255) null,
		superfamily varchar2(255) null,
		subfamily varchar2(255) null,
		supertribe varchar2(255) null,
		tribe varchar2(255) null,
		subtribe varchar2(255) null,
		genus varchar2(255) null,
		subgenus varchar2(255) null,
		species varchar2(255) null,
		subpspecies varchar2(255) null,
		forma varchar2(255) null
);



create or replace public synonym cf_temp_classification for cf_temp_classification;

grant all on cf_temp_classification to coldfusion_user;



---->
<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkload Classifications">


<!----------------------------------------------------------------->
<cfif action is "nothing">
	<cfoutput>
		Update, replace, or create classifications. This form will happily create garbage; use the Contact link below to ask questions and do not
		click any buttons unless you KNOW what they do.
		 <p>
			Upload a comma-delimited text file (csv). <a href="BulkloadTaxonomy.cfm?action=makeTemplate">[ Get the Template ]</a>
		</p>
		<p>
			You can (and should) also pull classification from globalnames.
		</p>
		<p>subgeneric terms are multinomial</p>
		<p>
			Source is <a href="/info/ctDocumentation.cfm?table=CTTAXONOMY_SOURCE">CTTAXONOMY_SOURCE</a>
		</p>
		<cfform name="oids" method="post" enctype="multipart/form-data" action="BulkloadClassification.cfm">
			<input type="hidden" name="action" value="getFile">
			<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
			<input type="submit" value="Upload this file">
		</cfform>
	</cfoutput>
</cfif>
<!----------------------------------------------------------------->
<cfif action is "makeTemplate">

	<cfquery name="dbcols" datasource="uam_god">
		select
			column_name
		from
			user_tab_cols
		where
			upper(table_name)='BULKLOAD_CLASSIFICATION' and
			lower(column_name) not in ('status','taxon_name_id')
		ORDER BY INTERNAL_COLUMN_ID
	</cfquery>

	<cfdump var=#dbcols#>


	<cfset thecolumns=valuelist(dbcols.column_name)>



	<cfdump var=#thecolumns#>



	<cfset header=thecolumns>
	<cffile action = "write"
    file = "#Application.webDirectory#/download/BulkloadClassification.csv"
    output = "#header#"
    addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkloadClassification.csv" addtoken="false">
</cfif>
