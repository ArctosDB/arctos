<!---
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
	<a href="checkHelpLinks.cfm?action=getLinks">getLinks</a>
	<br><a href="checkHelpLinks.cfm?action=checkProd">checkProd</a>
	<br><a href="checkHelpLinks.cfm?action=checkLinks">checkLinks</a>

</p>

<br />						select distinct DOCUMENTATION_LINK from ssrch_field_doc;


<cfif action is "checkLinks">
	<cfquery name="d" datasource="prod">
		select distinct DOCUMENTATION_LINK from ssrch_field_doc
	</cfquery>
	<cfoutput>
		<cfloop query="d">
			<p>#DOCUMENTATION_LINK#</p>
			<cfhttp url="#d.DOCUMENTATION_LINK#" method="GET"></cfhttp>
			<cfif left(cfhttp.statuscode,3) is not "200">
				<br>#cfhttp.statuscode#
				<cfdump var=#cfhttp#>
			</cfif>
			<cfif d.DOCUMENTATION_LINK contains "##">
				<cfset anchor=listlast(d.DOCUMENTATION_LINK,'##')>
				<cfif cfhttp.fileContent does not contain 'id="#anchor#"'>
					<br>DOCUMENTATION_LINK anchor no bueno
				</cfif>
			</cfif>
		</cfloop>
	</cfoutput>


</cfif>

<cfif action is "checkProd">
<cfoutput>
	<cfquery name="d_raw" datasource="uam_god">
		select * from temp_doc_id_raw
	</cfquery>
	<cfquery name="p_raw" datasource="prod">
		select * from ssrch_field_doc
	</cfquery>
	<cfquery name="allterms" dbtype="query">
		select id cfvar from d_raw
		union
		select cf_variable cfvar from p_raw
	</cfquery>
	<cfloop query="allterms">
		<cfquery name="p" dbtype="query">
			select * from p_raw where cf_variable='#cfvar#'
		</cfquery>
		<cfquery name="c" dbtype="query">
			select * from d_raw where id='#cfvar#'
		</cfquery>
		<cfset in_docs="no">
		<cfset in_code="no">
		<cfif p.recordcount gt 0>
			<cfset in_docs="yes">
		</cfif>

		<cfif c.recordcount gt 0>
			<cfset in_code="yes">
		</cfif>
		<cfset used_in_frm="">
		<cfset rawtags="">

		<cfquery name="u_f" dbtype="query">
			select distinct frm from c
		</cfquery>
		<cfloop query="u_f">
			<cfset used_in_frm=listappend(used_in_frm,frm,';')>
		</cfloop>

		<cfquery name="u_t" dbtype="query">
			select distinct rawtag from c
		</cfquery>
		<cfloop query="u_t">
			<cfset rawtags=listappend(rawtags,rawtag,';')>
		</cfloop>



		<cfquery name="update" datasource="uam_god">
			insert into temp_doc_merge (
				cfvar,
				in_code,
				in_docs,
				CATEGORY,
				CONTROLLED_VOCABULARY,
				DATA_TYPE,
				DEFINITION,
				DISPLAY_TEXT,
				DOCUMENTATION_LINK,
				PLACEHOLDER_TEXT,
				SEARCH_HINT,
				SQL_ELEMENT,
				SPECIMEN_RESULTS_COL,
				DISP_ORDER,
				SPECIMEN_QUERY_TERM,
				used_in_frm,
				rawtags
			) values (
				'#cfvar#',
				'#in_code#',
				'#in_docs#',
				'#p.CATEGORY#',
				'#p.CONTROLLED_VOCABULARY#',
				'#p.DATA_TYPE#',
				'#p.DEFINITION#',
				'#p.DISPLAY_TEXT#',
				'#p.DOCUMENTATION_LINK#',
				'#p.PLACEHOLDER_TEXT#',
				'#p.SEARCH_HINT#',
				'#p.SQL_ELEMENT#',
				'#p.SPECIMEN_RESULTS_COL#',
				'#p.DISP_ORDER#',
				'#p.SPECIMEN_QUERY_TERM#',
				'#used_in_frm#',
				'#rawtags#'
			)
		</cfquery>
	</cfloop>



	<!-----


	 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------




	<cfdump var=#allterms#>


	<cfquery name="d" dbtype="query">
		select distinct id from d_raw order by id
	</cfquery>
	<cfloop query="d">
		<hr>
		#id#
		<cfquery name="dd" dbtype="query">
			select frm,rawtag from d_raw where id='#id#'
		</cfquery>
		<cfloop query="dd">
			<br>----#frm# ----
			<textarea rows="4" cols="60">#rawtag#</textarea>
		</cfloop>
		<cfquery name="p" datasource="prod">
			select * from ssrch_field_doc where cf_variable='#id#'
		</cfquery>
		<cfif p.recordcount gt 0>
			<cfdump var=#p#>
		</cfif>
	</cfloop>
	---->
</cfoutput>
</cfif>

<cfif action is "getLinks">
<cfset res=  DirectoryList(Application.webDirectory,true,"path","*.cf*")>
<cfoutput>
	<cftransaction>
	<cfloop array="#res#" index="f">
		<!--- ignore cfr etc --->
		<cfif listlast(f,".") is "cfm" or listlast(f,".") is "cfc">
			<br>#f#
			<cffile action = "read" file = "#f#" variable = "fc">
			<cfif fc contains "helpLink">

				<!----<br>-------------------------- something to check here -------------------->
				<cfset l = REMatch('(?i)<[^>]+class="helpLink"[^>]*>(.+?)>', fc)>
				<br>l: <cfdump var=#l#>

				<cfloop array="#l#" index='h'>
					h: <textarea rows="4" cols="80">#h#</textarea>
					<cfset go=false>
					<cfif h contains 'id='>
						<cfset go=true>
						<br>got ID

						<cfset idSPos=find("id=",h)+4>
						<br>idSPos: #idSPos#
						<cfset nqPos=find('"',h,idsPos)>
						<br>nqPos: #nqPos#
						<cfset theID=mid(h,idSPos,nqPos-idSPos)>
						<br>theID: #theID#
						<cfif left(theID,1) is "_">
							<cfset theID=right(theID,len(theID)-1)>
						</cfif>

						<br>theID: #theID#
					<cfelseif h contains 'data-helplink='>
						<cfset go=true>
					<br>got data tag

						<cfset idSPos=find("data-helplink=",h)+15>
						<br>idSPos: #idSPos#
						<cfset nqPos=find('"',h,idsPos)>
						<br>nqPos: #nqPos#
						<cfset theID=mid(h,idSPos,nqPos-idSPos)>
						<br>theID: #theID#
						<cfif left(theID,1) is "_">
							<cfset theID=right(theID,len(theID)-1)>
						</cfif>

						<br>theID: #theID#
					<cfelse>
						<p>

							========================================== bad juju ===================================
						</p>
					</cfif>
					<cfif go is true>
						<cfquery name="d" datasource="uam_god">
							insert into temp_doc_id_raw(frm,rawtag,id) values ('#f#','#h#','#theID#')
						</cfquery>
					</cfif>
					<!----

					<cfset tid= rereplace(h,'<span[^>]+?id="([^"]+)".*',"\1")>
				<cfquery name="d" datasource="uam_god">
						insert into temp_doc_id_raw(frm,rawtag,id) values ('#f#','#h#','#theID#')
					</cfquery>


					---->
					<br>

				</cfloop>
			</cfif>
		</cfif>

	</cfloop>

	</cftransaction>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
