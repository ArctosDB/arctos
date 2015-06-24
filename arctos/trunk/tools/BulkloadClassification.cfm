<!----

	drop table cf_temp_classification;


	create table cf_temp_classification (
		-- admin junk
		status varchar2(255),
		classification_id varchar2(4000),
		username varchar2(255) not null,
		operation  varchar2(255) not null,
		source  varchar2(255) not null,
		taxon_name_id number,
		-- key AND lowest-ranking classification term
		scientific_name varchar2(255) not null,
		--non-classification terms
		author_text varchar2(255) null,
		infraspecific_author varchar2(255) null,
		nomenclatural_code varchar2(255) not null,
		source_authority varchar2(255) null,
		valid_catalog_term_fg varchar2(255) null,
		taxon_status varchar2(255) null,
		remark varchar2(255),
		display_name varchar2(255) null,
		--classification terms - MAKE SURE THESE STAY ORDERED
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
		family varchar2(255),
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

create unique index iu_temp_class on cf_temp_classification(scientific_name) tablespace uam_idx_1;

---->
<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkload Classifications">


<!----------------------------------------------------------------->
<cfif action is "nothing">
	<cfoutput>
		<p>
			<a href="BulkloadClassification.cfm?action=managemystuff">Manage Existing</a>
		</p>
		Update, replace, or create classifications. This form will happily create garbage; use the Contact link below to ask questions and do not
		click any buttons unless you KNOW what they do.
		 <p>
			Upload a comma-delimited text file (csv). <a href="BulkloadClassification.cfm?action=makeTemplate">[ Get the Template ]</a>
		</p>
		<p>
			You can (and should) also pull classification from globalnames.
		</p>
		<p>scientific_name is globally-unique; coordinate with other users if there's a conflict.</p>
		<p>subgeneric terms are multinomial</p>
		<p>
			Terms are defined at is <a href="/info/ctDocumentation.cfm?table=CTTAXON_TERM">CTTAXON_TERM</a>
		</p>
		<p>username is required and must match your Arctos username</p>
		<p>
			Source (NOT source_authority) is required and must be from <a href="/info/ctDocumentation.cfm?table=CTTAXONOMY_SOURCE">CTTAXONOMY_SOURCE</a>
		</p>
		<p>
			nomenclatural_code is required and must be one of (ICZN, ICBN)
		</p>
		<p>
			"classification" is defined as the intersection of source and scientific_name.
		</p>
		<p>
			If multiple classifications exist (e.g., two sets of data in the "Arctos" classification for <i>Some name</i>), an error will be thrown and no
			updates will be performed.
		</p>



		<p>
			<strong>operation</strong> is required. Values are as follows.


			<ul>
				<li>
					update: update terms which have data in the file you're uploading. Ignore everything else. Examples:
					<ul>
						<li>
							Your Data: contain something in "kingdom"
							<br>Existing Data: contain a term ranked "kingdom"
							<br>What Happens: Kingdom is UPDATED
						</li>
						<li>
							Your Data: contain something in "kingdom"
							<br>Existing Data: contain nothing ranked "kingdom"
							<br>What Happens: Kingdom is ADDED
						</li>
						<li>
							Your Data: contain something in "kingdom"
							<br>Existing Data: contain an unranked term of the same value
							<br>What Happens: Kingdom is ADDED, existing term is IGNORED
						</li>
						<li>
							Your Data: "kingdom" is NULL
							<br>Existing Data: contain a term ranked "kingdom"
							<br>What Happens: NOTHING
						</li>
					</ul>
				</li>
				<li>
					replace: delete the entirety of the existing classification, add back whatever's in your file. Examples:

					<ul>
						<li>
							Your Data: "kingdom" is NULL
							<br>Existing Data: anything
							<br>Result: The classification has no term ranked "kingdom"
						</li>
						<li>
							Your Data: anything
							<br>Existing Data: contain an unranked term
							<br>Result: The unranked term is gone.
						</li>
					</ul>
				</li>
			</ul>
		</p>
		<cfform name="oids" method="post" enctype="multipart/form-data" action="BulkloadClassification.cfm">
			<input type="hidden" name="action" value="getFileData">
			<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
			<input type="submit" value="Upload this file">
		</cfform>
	</cfoutput>
</cfif>
<!----------------------------------------------------------------->
<cfif action is "managemystuff">
	<cfoutput>

		<p>
			<a href="BulkloadClassification.cfm?action=deletemystuff">Delete all of your data</a>
		</p>
		<p>
			<a href="BulkloadClassification.cfm?action=nothing">Load from CSV</a>
		</p>

		<p>
			<a href="BulkloadClassification.cfm?action=getDisplayName">Autogenerate Display Name</a>
		</p>

        <cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from CF_TEMP_CLASSIFICATION where upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfdump var=#d#>
	</cfoutput>
</cfif>
<!----------------------------------------------------------------->
<!----------------------------------------------------------------->
<cfif action is "deletemystuff">
	<cfoutput>
        <cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from CF_TEMP_CLASSIFICATION where upper(username)='#ucase(session.username)#'
		</cfquery>
		<cflocation url="BulkloadClassification.cfm?action=managemystuff" addtoken="false">
	</cfoutput>
</cfif>
<!----------------------------------------------------------------->

<cfif action is "getDisplayName">
	<cfoutput>
	    <cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from CF_TEMP_CLASSIFICATION where upper(username)='#ucase(session.username)#' and display_name is null
		</cfquery>

        <cfloop query="d">
			<cfset problem="">
			<!---- infraspecific crap ---->
			<cfif len(genus) is 0>
				<cfif len(forma) gt 0 or len(subpspecies) gt 0>
					<cfif len(genus) is 0 or len(species) is 0)>
						<cfset problem="infraspecific terms must be accompanied by genus and species">
					<cfelse>
						<cfif len(forma) gt 0>
							<cfset ist=forma>
						<cfelseif len(subpspecies) gt 0>
							<cfset ist=subpspecies>
						</cfif>
					</cfif>
				</cfif>
				<cfif nomenclatural_code is "ICZN">
					<cfset dname='<i>' & genus & ' ' & species & ' ' & ist & '</i> ' & author_text>
				<cfelse>
					<cfset dname='<i>' & genus & ' ' & species & '</i> ' & author_text & ' <i>' & ist & '</i> ' & infraspecific_author>
				</cfif>
				<cfset dname=trim(replace(dname,'  ',' ')>
			<cfelse>
				<!--- no genus just use scientificname --->
				<cfset dname=scientific_name>
			</cfif>

			<br>:#dname#:

        </cfloop>
		<!----
		<cflocation url="BulkloadClassification.cfm?action=managemystuff" addtoken="false">
		---->
	</cfoutput>
</cfif>
<!----------------------------------------------------------------->

<cfif action is "getFileData">
	<cfoutput>
		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
        <cfset  util = CreateObject("component","component.utilities")>
		<cfset x=util.CSVToQuery(fileContent)>
        <cfset cols=x.columnlist>
        <cfloop query="x">
            <cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	            insert into CF_TEMP_CLASSIFICATION (#cols#) values (
	            <cfloop list="#cols#" index="i">
	            		'#stripQuotes(evaluate(i))#'
	            	<cfif i is not listlast(cols)>
	            		,
	            	</cfif>
	            </cfloop>
	            )
            </cfquery>
        </cfloop>
		<cflocation url="BulkloadClassification.cfm?action=managemystuff" addtoken="false">
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
			upper(table_name)='CF_TEMP_CLASSIFICATION' and
			lower(column_name) not in ('status','taxon_name_id','classification_id')
		ORDER BY INTERNAL_COLUMN_ID
	</cfquery>
	<cfset thecolumns="">
	<cfloop query="dbcols">
		<cfset thecolumns=listappend(thecolumns,column_name)>
	</cfloop>


	<cfset header=thecolumns>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/BulkloadClassification.csv"
	    output = "#header#"
	    addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkloadClassification.csv" addtoken="false">
</cfif>
<!----------------------------------------------------------------->


select
	distinct CF_TEMP_CLASSIFICATION.scientific_name
from
	CF_TEMP_CLASSIFICATION,
	taxon_name,
	taxon_term
where
	CF_TEMP_CLASSIFICATION.scientific_name=taxon_name.scientific_name and
	taxon_name.taxon_name_id=taxon_term.taxon_name_id and
	--upper(CF_TEMP_CLASSIFICATION.username)='#ucase(session.username)#' and
	( taxon_term.TERM_TYPE is null or
		 taxon_term.TERM_TYPE not in (select taxon_term from CTTAXON_TERM)
	)
	;