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
		subspecies varchar2(255) null,
		subsp varchar2(255) null,
		forma varchar2(255) null
);



create or replace public synonym cf_temp_classification for cf_temp_classification;

grant all on cf_temp_classification to coldfusion_user;

create unique index iu_temp_class on cf_temp_classification(scientific_name) tablespace uam_idx_1;

---->
<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkload Classifications">


<!----------------------------------------------------------------->

<cfif action is "getCSV">
	<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from CF_TEMP_CLASSIFICATION where upper(username)='#ucase(session.username)#'
	</cfquery>
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset csv = util.QueryToCSV2(Query=mine,Fields=mine.columnlist)>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/BulkloadClassificationData.csv"
    	output = "#csv#"
    	addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkloadClassificationData.csv" addtoken="false">
</cfif>
<!----------------------------------------------------------------->

<cfif action is "setstatus">
	<cfoutput>
		  <cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update CF_TEMP_CLASSIFICATION set status='#status#' where upper(username)='#ucase(session.username)#'
		</cfquery>
	</cfoutput>
</cfif>
<!----------------------------------------------------------------->
<cfif action is "nothing">
	<cfoutput>
		<p>
			Replace classifications. This form will happily create garbage; use the Contact link below to ask questions and do not
			click any buttons unless you KNOW what they do.
		<p>
		<p>
			<a href="BulkloadClassification.cfm?action=makeTemplate">[ Get a Template ]</a> and view column descriptions
		</p>
		<p>
			<a href="BulkloadClassification.cfm?action=deletemystuff">Delete all of your data</a>
		</p>
		<p>
			Load (more) data
			<cfform name="oids" method="post" enctype="multipart/form-data" action="BulkloadClassification.cfm">
			<input type="hidden" name="action" value="getFileData">
			<label for="">Load CSV. Will APPEND to existing data</label>
			<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
			<input type="submit" value="Upload this file">
		</cfform>
		</p>
		<p>
			<a href="BulkloadClassification.cfm?action=checkGaps">Check for gaps</a>. This will
			find data in Arctos which has no place in this loader; these data will be lost if the
			data are loaded as-is. This will time out for large datasets; send us an email.
			<br>Note: fill_in_the_blanks_from_genus contains this functionality; the check is not necessary if you're
			filling in blanks.
		</p>





		<p>
			Display_Name is required. You may <a href="BulkloadClassification.cfm?action=getDisplayName">autogenerate display_name</a>.
			This may produce strange data; carefully verify the results of this operation. This will NOT over-write anything already in
			display_name; download CSV, remove display_name, and re-upload to accomplish that.
		</p>
		<p>
			The following options are slow, and so are performed asynchronously. Clicking these links simply updates STATUS.
			Arctos will send daily reminder emails, or check status below.
			<ul>
				<li>
					<a href="BulkloadClassification.cfm?action=setstatus&status=fill_in_the_blanks_from_genus">fill_in_the_blanks_from_genus</a>.
					Use this to set status of ALL of your data to "fill_in_the_blanks_from_genus." This will cause Arctos to insert species
					and subspecies
					data, and to fill in any gaps in the genus-only source record. Check stats below before clicking;
					 this force-overwrites anything in STATUS.
				</li>
				<li>
					<a href="BulkloadClassification.cfm?action=setstatus&status=ready_to_check">Mark to process</a>.
					Use this to begin pre-load processing. Use this AFTER fill_in_the_blanks_from_genus and
					autogenerate display_name. Check stats below before clicking;
					 this force-overwrites anything in STATUS.
				</li>
				<li>
					use the contact form to actually load
				</li>
			</ul>
		</p>
		<cfquery name="summary" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				status,
				count(*) c from CF_TEMP_CLASSIFICATION where upper(username)='#ucase(session.username)#'
			group by status
		</cfquery>
		<cfquery name="tot" dbtype="query">
			select sum(c) s from summary
		</cfquery>
		<p>
			Summary:
			<table border>
				<tr>
					<th>Status</th>
					<th>Count</th>
				</tr>
				<cfloop query="summary">
					<tr>
						<td>#status#</td>
						<td>#c#</td>
					</tr>
				</cfloop>
				<tr>
					<td>
						<div style="align:right;font-weight:bold">Total</div>
					</td>
					<td><div style="font-weight:bold">#tot.s#</div></td>
				</tr>
			</table>
		</p>
		<!----
		toobookoo

		<cfquery name="dbcols" datasource="uam_god">
			select
				column_name
			from
				user_tab_cols
			where
				upper(table_name)='CF_TEMP_CLASSIFICATION' and
				lower(column_name) not in ('taxon_name_id','classification_id')
			ORDER BY INTERNAL_COLUMN_ID
		</cfquery>


		<table border>
			<tr>
			<cfloop query="dbcols">
				<th>#column_name#</th>
			</cfloop>
			</tr>
			<cfloop query="d">
				<tr>
					<cfloop query="dbcols">
						<td>#evaluate("d." & column_name)#</td>
					</cfloop>
				</tr>
			</cfloop>
		</table>
		---->
	</cfoutput>
</cfif>
<!----------------------------------------------------------------->
<cfif action is "deletemystuff">
	<cfoutput>
        <cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from CF_TEMP_CLASSIFICATION where upper(username)='#ucase(session.username)#'
		</cfquery>
		<cflocation url="BulkloadClassification.cfm?action=nothing" addtoken="false">
	</cfoutput>
</cfif>
<!----------------------------------------------------------------->
<cfif action is "getDisplayName">
	<p>
		Timeout errors below? Just reload (or <a href="/contact">contact us</a> if that doesn't help).
	</p>
	<cfoutput>
	    <cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from CF_TEMP_CLASSIFICATION where upper(username)='#ucase(session.username)#'
			and display_name is null
		</cfquery>

        <cfloop query="d">
			<cftransaction>
			<cfset problem="">
			<!---- infraspecific crap ---->
			<cfif len(genus) gt 0>
				<cfset ist="">
				<cfset irnk="">
				<!--- check for infraspecific data ---->
				<cfif len(forma) gt 0 or len(subsp) gt 0 or len(subspecies) gt 0>
					<cfif len(genus) is 0 or len(species) is 0>
						<cfset problem="infraspecific terms must be accompanied by genus and species">
					<cfelse>
						<cfif len(forma) gt 0>
							<cfset ist=forma>
							<cfset irnk="forma">
						<cfelseif len(subspecies) gt 0>
							<cfset ist=subspecies>
						<cfelseif len(subsp) gt 0>
							<cfset ist=subsp>
							<cfset irnk="subsp.">
						</cfif>
					</cfif>
				</cfif>
				<cfif nomenclatural_code is "ICZN">
					<cfset dname='<i>' & genus & ' ' & species & ' ' & ist & '</i> ' & author_text>
				<cfelse>
					<cfset dname='<i>' & genus & ' ' & species & '</i> ' & author_text & ' ' & irnk & ' ' & ' <i>' & ist & '</i> ' & infraspecific_author>
				</cfif>
			<cfelse>
				<!--- no genus just use scientificname --->
				<cfset dname=scientific_name>
			</cfif>
			<cfset dname=rereplace(dname,'\s\s+','','All')>
			<cfset dname=replace(dname,'<i></i>','','All')>
			<cfset dname=replace(dname,' </i>','</i>','All')>
			<cfset dname=trim(dname)>
			<cfif len(problem) gt 0>
	    		<cfquery name="p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update CF_TEMP_CLASSIFICATION set status='Autogen DisplayName: #problem#' where scientific_name='#scientific_name#'
				</cfquery>
			<cfelse>
	    		<cfquery name="p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update CF_TEMP_CLASSIFICATION set display_name='#dname#' where scientific_name='#scientific_name#'
				</cfquery>
			</cfif>
			</cftransaction>
        </cfloop>
		<p>
			all done. Back to <a href="BulkloadClassification.cfm?action=nothing">manage</a>
		</p>
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
		<cflocation url="BulkloadClassification.cfm?action=nothing" addtoken="false">
	</cfoutput>
</cfif>
<!----------------------------------------------------------------->
<cfif action is "makeTemplate">
	<ul>
		<li>scientific_name is globally-unique; coordinate with other users if there's a conflict.</li>
		<li>subgeneric terms are multinomial. Sorex cinereus, NOT cinereus.</li>
		<li>Terms are defined at is <a href="/info/ctDocumentation.cfm?table=CTTAXON_TERM">CTTAXON_TERM</a></li>
		<li>username is required and must match your Arctos username</li>
		<li>
			Source (NOT source_authority) is required and must be from
			<a href="/info/ctDocumentation.cfm?table=CTTAXONOMY_SOURCE">CTTAXONOMY_SOURCE</a>
		</li>
		<li>nomenclatural_code is required and must be one of (ICZN, ICBN)</li>
		<li>
			"classification" is defined as the intersection of source and scientific_name. This tool REPLACES entire
			classifications (but see the fill_in_the_blanks_from_genus option)
		</li>
		<li>
			If multiple classifications exist (e.g., two sets of data in the "Arctos" classification for
			 <i>Some name</i>), an error will be thrown and no
			updates will be performed.
		</li>
		<li>Only one infraspecific term may be given; "subsp" and "forma" may not both exist in the same record</li>
	</ul>
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
	<a href="/download.cfm?file=BulkloadClassification.csv">get the template</a>
</cfif>
<!----------------------------------------------------------------->
<cfif action is "checkGaps">
	<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
	</cfquery>
	<cfoutput>
		<p>
			The following scientific names will cause data loss. The corresponding data in Arctos contains unranked or unhandled terms.
		</p>
		<cfloop query="ins">
			<br><a target="_blank" href="/name/#scientific_name#">#scientific_name#</a>
		</cfloop>
	</cfoutput>

</cfif>

<cfinclude template="/includes/_footer.cfm">

