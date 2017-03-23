<!---
	dependencies:

		create table cf_temp_doc_page_link (frm varchar2(4000),rawtag varchar2(4000),id varchar2(4000));



	crawl through all code and get the helpLinks
	make sure they all exist in ssrch_field_doc

	drop table temp_doc_id_raw;

	create table temp_doc_id_raw (frm varchar2(4000),rawtag varchar2(4000),id varchar2(4000));

	delete from temp_doc_id_raw;


	select id || ' :: ' || frm from temp_doc_id_raw order by id;

		select id || ' :: ' || frm from temp_doc_id_raw where id not in (select cf_variable from ssrch_field_doc@db_production) order by id;


		delete from temp_doc_merge;



		create table temp_doc_merge (
			cfvar varchar2(4000),
			in_code  varchar2(4000),
			in_docs  varchar2(4000),
			CATEGORY varchar2(4000),
			CONTROLLED_VOCABULARY varchar2(4000),
			DATA_TYPE varchar2(4000),
			DEFINITION varchar2(4000),
			DISPLAY_TEXT varchar2(4000),
			DOCUMENTATION_LINK varchar2(4000),
			PLACEHOLDER_TEXT varchar2(4000),
			SEARCH_HINT varchar2(4000),
			SQL_ELEMENT varchar2(4000),
			SPECIMEN_RESULTS_COL varchar2(4000),
			DISP_ORDER varchar2(4000),
			SPECIMEN_QUERY_TERM varchar2(4000),
			used_in_frm varchar2(4000),
			rawtags varchar2(4000)
		);

		run checkProd to populate

		first pass: just deal with the stuff that's in the code....

		delete from temp_doc_merge where in_code ='no';

		.....and not in the docs
		delete from temp_doc_merge where in_docs ='yes';

		select cfvar from temp_doc_merge order by cfvar;

		select used_in_frm from temp_doc_merge where cfvar='specimen-event';


		select * from ssrch_field_doc@db_production where cf_variable='date';




		download CSV - do thang - upload - then.....

		select cf_variable from ssrch_field_doc where cf_variable in (select CFVAR from dlm.my_temp_cf);

		-- nada, just insert

		insert into ssrch_field_doc (
			CF_VARIABLE,
			DISPLAY_TEXT,
			SSRCH_FIELD_DOC_ID,
			SPECIMEN_RESULTS_COL,
			SPECIMEN_QUERY_TERM,
			CATEGORY,
			CONTROLLED_VOCABULARY,
			DATA_TYPE,
			DEFINITION,
			DOCUMENTATION_LINK,
			PLACEHOLDER_TEXT,
			SEARCH_HINT,
			SQL_ELEMENT,
			DISP_ORDER
		) (
			select
				CFVAR,
				decode (DISPLAY_TEXT,NULL,CFVAR,DISPLAY_TEXT),
				sq_short_doc_id.nextval,
				0,
				0,
				CATEGORY,
				CONTROLLED_VOCABULARY,
				DATA_TYPE,
				DEFINITION,
				DOCUMENTATION_LINK,
				PLACEHOLDER_TEXT,
				SEARCH_HINT,
				SQL_ELEMENT,
				DISP_ORDER
			from
				dlm.my_temp_cf
			);


				--- and done at prod 20170322




	now see if we can find anything broken or sucky....

	select distinct CF_VARIABLE from ssrch_field_doc;
			select distinct DISPLAY_TEXT from ssrch_field_doc;

						select distinct DOCUMENTATION_LINK from ssrch_field_doc;

			DOCUMENTATION_LINK
			Elapsed: 00:00:00.05
UAM@ARCTOS> desc ssrch_field_doc
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 CATEGORY								    VARCHAR2(4000)
 CF_VARIABLE							   NOT NULL VARCHAR2(4000)
 CONTROLLED_VOCABULARY							    VARCHAR2(4000)
 DATA_TYPE								    VARCHAR2(4000)
 DEFINITION								    VARCHAR2(4000)
 DISPLAY_TEXT							   NOT NULL VARCHAR2(4000)
 DOCUMENTATION_LINK							    VARCHAR2(4000)
 PLACEHOLDER_TEXT							    VARCHAR2(4000)
 SEARCH_HINT								    VARCHAR2(4000)
 SQL_ELEMENT								    VARCHAR2(4000)
 SSRCH_FIELD_DOC_ID						   NOT NULL NUMBER
 SPECIMEN_RESULTS_COL						   NOT NULL NUMBER
 DISP_ORDER								    NUMBER
 SPECIMEN_QUERY_TERM						   NOT NULL NUMBER






		> desc dlm.my_temp_cf
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 CFVAR									    VARCHAR2(4000)
 CONTROLLED_VOCABULARY							    VARCHAR2(4000)
 DATA_TYPE								    VARCHAR2(4000)
 DEFINITION								    VARCHAR2(4000)
 DOCUMENTATION_LINK							    VARCHAR2(4000)
 PLACEHOLDER_TEXT							    VARCHAR2(4000)
 DISPLAY_TEXT								    VARCHAR2(4000)
 DISP_ORDER								    VARCHAR2(4000)
 IN_CODE								    VARCHAR2(4000)
 IN_DOCS								    VARCHAR2(4000)
 RAWTAGS								    VARCHAR2(4000)
 SEARCH_HINT								    VARCHAR2(4000)
 SPECIMEN_QUERY_TERM							    VARCHAR2(4000)
 SPECIMEN_RESULTS_COL							    VARCHAR2(4000)
 SQL_ELEMENT								    VARCHAR2(4000)
 USED_IN_FRM								    VARCHAR2(4000)
 CATEGORY								    VARCHAR2(4000)

UAM@ARCTEST>


---->
<cfinclude template="/includes/_header.cfm">
<p>
	This is an iterative (because it's slow) single-user form.
</p>

<p>
	<a href="checkHelpLinks.cfm?action=getLinks">getLinks</a> - do this first, it crawls through Arctos code and
	finds all helpLinks.
</p>

<p>
	<a href="checkHelpLinks.cfm?action=showGetLinks">showGetLinks</a> - see the results of getLinks
</p>
<p>
	<a href="checkHelpLinks.cfm?action=checkUsedExists">checkUsedExists</a> - see if everything in the code has an entry in the doc table
</p>
<p>
	<a href="checkHelpLinks.cfm?action=checkLinks">checkLinks</a> - fetch all distinct DOCUMENTATION_LINKs from the doc table
</p>

<p>
	<a href="checkHelpLinks.cfm?action=showDocs">showDocs</a> - tableify documentation for all docs used in code
</p>

<cfif action is "showDocs">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from ssrch_field_doc where cf_variable in (select id from cf_temp_doc_page_link)
			order by cf_variable
		</cfquery>
		<table border>
			<tr>
				<th>CF_VARIABLE</th>
				<th>DEFINITION</th>
				<th>DOCUMENTATION_LINK</th>
				<th>DISPLAY_TEXT</th>
				<th>CONTROLLED_VOCABULARY</th>
				<th>PLACEHOLDER_TEXT</th>
				<th>SEARCH_HINT</th>
				<th>DATA_TYPE</th>
				<th>SQL_ELEMENT</th>
				<th>SPECIMEN_RESULTS_COL</th>
				<th>SPECIMEN_QUERY_TERM</th>
				<th>DISP_ORDER</th>
			</tr>
			<cfloop query="d">
				<tr>
					<td>#CF_VARIABLE#</td>
					<td>#DEFINITION#</td>
					<td>#DOCUMENTATION_LINK#</td>
					<td>#DISPLAY_TEXT#</td>
					<td>#CONTROLLED_VOCABULARY#</td>
					<td>#PLACEHOLDER_TEXT#</td>
					<td>#SEARCH_HINT#</td>
					<td>#DATA_TYPE#</td>
					<td>#SQL_ELEMENT#</td>
					<td>#SPECIMEN_RESULTS_COL#</td>
					<td>#SPECIMEN_QUERY_TERM#</td>
					<td>#DISP_ORDER#</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<cfif action is "checkLinks">
	<cfquery name="d" datasource="uam_god">
		select distinct DOCUMENTATION_LINK from ssrch_field_doc where DOCUMENTATION_LINK is not null
	</cfquery>
	<p>
		splat-f "ALERT"
	</p>
	<cfoutput>
		<cfloop query="d">
			<hr>
			<p>checking #DOCUMENTATION_LINK#....</p>
			<cfhttp url="#d.DOCUMENTATION_LINK#" method="GET"></cfhttp>
			<br>status: #cfhttp.statuscode#
			<cfif left(cfhttp.statuscode,3) is not "200">
				<br>ALERT: DOCUMENTATION_LINK seems to be broken; http dump follows
				<cfdump var=#cfhttp#>
			</cfif>
			<cfif d.DOCUMENTATION_LINK contains "##">
			<br>link has anchor....
				<cfset anchor=listlast(d.DOCUMENTATION_LINK,'##')>
				<br>anchor is #anchor#
				<cfif cfhttp.fileContent does not contain 'id="#anchor#"'>
					<br>ALERT: anchor appears to be busted; http dump follows
					<cfdump var=#cfhttp#>
				</cfif>
			</cfif>
		</cfloop>
	</cfoutput>
</cfif>

<cfif action is "checkUsedExists">
	<cfoutput>
		<cfquery name="incode" datasource="uam_god">
			select id from cf_temp_doc_page_link where id not in (select cf_variable from ssrch_field_doc)
		</cfquery>
		<p>
			Anything listed here is used in the code but does NOT exist in the documentation. Add it. Now!
		</p>
		<cfdump var=#incode#>
	</cfoutput>
</cfif>

<cfif action is "showGetLinks">
	<cfquery name="d" datasource="uam_god">
		select * from cf_temp_doc_page_link
	</cfquery>
	<cfquery name="did" dbtype="query">
		select id from d group by id order by id
	</cfquery>
	<cfoutput>
		<table border>
			<tr>
				<th>cf_variable</th>
				<th>called from</th>
				<th>raw tag</th>
			</tr>
			<cfloop query="did">
				<tr>
					<td>#id#</td>
					<cfquery name="qid" dbtype="query">
						select frm from d where id='#id#'
					</cfquery>
					<td>
						#valuelist(qid.frm,"<br>")#
					</td>
					<cfquery name="r" dbtype="query">
						select rawtag from d where id='#id#'
					</cfquery>
					<td><xmp>#valuelist(r.rawtag,chr(10))#</xmp></td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>

<cfif action is "getLinks">
<cfset res=  DirectoryList(Application.webDirectory,true,"path","*.cf*")>
<cfoutput>
	<cfquery name="d" datasource="uam_god">
		delete from cf_temp_doc_page_link
	</cfquery>
	<cftransaction>
		<cfloop array="#res#" index="f">
			<!--- ignore cfr etc --->
			<cfif listlast(f,".") is "cfm" or listlast(f,".") is "cfc">
				<cffile action = "read" file = "#f#" variable = "fc">
				<cfif fc contains "helpLink">
					<!----<br>-------------------------- something to check here -------------------->
					<cfset l = REMatch('(?i)<[^>]+class="helpLink"[^>]*>(.+?)>', fc)>
					<cfloop array="#l#" index='h'>
						<!----
						h: <textarea rows="4" cols="80">#h#</textarea>
						---->
						<cfset go=false>
						<cfif h contains 'id='>
							<cfset go=true>
							<cfset idSPos=find("id=",h)+4>
							<cfset nqPos=find('"',h,idsPos)>
							<cfset theID=mid(h,idSPos,nqPos-idSPos)>
							<cfif left(theID,1) is "_">
								<cfset theID=right(theID,len(theID)-1)>
							</cfif>
						<cfelseif h contains 'data-helplink='>
							<cfset go=true>
							<cfset idSPos=find("data-helplink=",h)+15>
							<cfset nqPos=find('"',h,idsPos)>
							<cfset theID=mid(h,idSPos,nqPos-idSPos)>
							<cfif left(theID,1) is "_">
								<cfset theID=right(theID,len(theID)-1)>
							</cfif>
						</cfif>
						<cfif go is true>
							<cfquery name="d" datasource="uam_god">
								insert into cf_temp_doc_page_link(frm,rawtag,id) values ('#f#','#h#','#theID#')
							</cfquery>
						</cfif>
					</cfloop>
				</cfif>
			</cfif>
		</cfloop>
	</cftransaction>
	all done
</cfoutput>
</cfif>















<cfinclude template="/includes/_footer.cfm">
