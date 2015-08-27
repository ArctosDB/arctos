<cfinclude template="includes/_header.cfm">

<cfset title="Specimen Results">

<!----
<cfset mapRecordLimit=1000>
<cfif not isdefined("session.RESULTSBROWSEPREFS")>
	<cfset session.RESULTSBROWSEPREFS=0>
</cfif>
<cfif not isdefined("session.srmapclass") or len(session.srmapclass) is 0>
	<cfset session.srmapclass='nomap'>
</cfif>
---->
<script type='text/javascript' language="javascript" src='/includes/jtable/jquery.jtable.min.js'></script>
<script type='text/javascript' language="javascript" src='/includes/SpecimenResults.js?v=2'></script>


<link rel="stylesheet" title="lightcolor-blue"  href="/includes/jtable/themes/lightcolor/blue/jtable.min.css" type="text/css">
<style>
	#usertools{border:3px solid #417bb5; }
	#goWhere{border:3px solid #417bb5; }
</style>
<cfoutput>

	<cfset session.resultColumnList='GUID,SCIENTIFIC_NAME'>
	<!----
	<cfif not isdefined("session.resultColumnList") or len(session.resultColumnList) is 0>
		<cfset session.resultColumnList='GUID'>
	</cfif>
	<cfquery name="usercols" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select CF_VARIABLE,DISPLAY_TEXT,disp_order,SQL_ELEMENT from (
			select CF_VARIABLE,DISPLAY_TEXT,disp_order,SQL_ELEMENT from ssrch_field_doc where SPECIMEN_RESULTS_COL=1 and cf_variable in (#listqualify(lcase(session.resultColumnList),chr(39))#)
			union
			select CF_VARIABLE,DISPLAY_TEXT,disp_order,SQL_ELEMENT from ssrch_field_doc where SPECIMEN_RESULTS_COL=1 and category='required'
		)
		group by CF_VARIABLE,DISPLAY_TEXT,disp_order,SQL_ELEMENT
		order by disp_order
	</cfquery>
	<cfset session.resultColumnList=valuelist(usercols.CF_VARIABLE)>


	---->
	<cfset basSelect = " SELECT distinct #session.flatTableName#.collection_object_id,#session.flatTableName#.GUID,#session.flatTableName#.SCIENTIFIC_NAMe">

	<cfset basFrom = " FROM #session.flatTableName#">
	<cfset basJoin = "">
	<cfset basWhere = " WHERE #session.flatTableName#.collection_object_id IS NOT NULL ">
	<cfset basQual = "">
	<cfset mapurl="">
	<cfinclude template="/includes/SearchSql.cfm">

	<!--- wrap everything up in a string --->
	<cfset SqlString = "#basSelect# #basFrom# #basJoin# #basWhere# #basQual#">
	<cfset sqlstring = replace(sqlstring,"flatTableName","#session.flatTableName#","all")>


	<!--- require some actual searching --->
	<cfset srchTerms="">
	<cfloop list="#mapurl#" delimiters="&" index="t">
		<cfset tt=listgetat(t,1,"=")>
		<cfset srchTerms=listappend(srchTerms,tt)>
	</cfloop>
	<cfif listcontains(srchTerms,"collection_id")>
		<cfset srchTerms=listdeleteat(srchTerms,listfindnocase(srchTerms,'collection_id'))>
	</cfif>
	<!--- ... and abort if there's nothing left --->
	<cfif len(srchTerms) is 0>
		<CFSETTING ENABLECFOUTPUTONLY=0>
		<font color="##FF0000" size="+2">You must enter some search criteria!</font>
		<cfabort>
	</cfif>
	<!--- try to kill any old tables that they may have laying around --->
	<cftry>
		<cfquery name="die" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			drop table #session.SpecSrchTab#
		</cfquery>
		<cfcatch><!--- not there, so what? --->
		</cfcatch>
	</cftry>
	<!---- build a temp table --->
	<cfset checkSql(SqlString)>
	<cfif isdefined("debug") and debug is true>
		#preserveSingleQuotes(SqlString)#
	</cfif>
	<cfset SqlString = "create table #session.SpecSrchTab# AS #SqlString#">
	<cfquery name="buildIt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" timeout="60">
		#preserveSingleQuotes(SqlString)#
	</cfquery>
	<cfquery name="trc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from #session.SpecSrchTab#
	</cfquery>
	<cfset loginfo="#dateformat(now(),'yyyy-mm-dd')#T#TimeFormat(now(), 'HH:mm:ss')#||#session.username#||#request.ipaddress#||#mapurl#||#session.resultColumnList#||#trc.c#||#request.uuid#">
	<cfthread name="log#request.uuid#" action="run" priority="LOW" loginfo="#loginfo#">
		<cffile action="append" file="#Application.querylog#" output="#loginfo#">
    </cfthread>


	<cfset thisLoopNum=1>
	<script type="text/javascript">
	    $(document).ready(function () {
			//$("##usertools").menu();
			//$("##goWhere").menu();
	        $('##specresults').jtable({
	            title: 'Specimen Results',
				paging: true, //Enable paging
	            pageSize: 10, //Set page size (default: 10)
	            sorting: true, //Enable sorting
	            defaultSorting: 'GUID ASC', //Set default sorting
				columnResizable: true,
				multiSorting: true,
				columnSelectable: false,
				//recordsLoaded: getPostLoadJunk,
				//multiselect: true,
				//selectingCheckboxes: true,
  				selecting: true, //Enable selecting
          		//selectingCheckboxes: true, //Show checkboxes on first column
            	//selectOnRowClick: false, //Enable this to only select using checkboxes
				pageSizes: [10, 25, 50, 100, 250, 500,5000],
				actions: {
	                listAction: '/component/SpecimenResults.cfc?totalRecordCount=#trc.c#&method=getSpecimenResults&m=true'
	            },
	            fields:  {
					 COLLECTION_OBJECT_ID: {
	                    key: true,
	                    create: false,
	                    edit: false,
	                    list: false
	                },
	                GUID:{title: 'GUID'},
                    SCIENTIFIC_NAME:{title: 'ScientificName'}
	                <!----
					<cfloop query="usercols">
						#ucase(CF_VARIABLE)#: {title: '#replace(DISPLAY_TEXT," ","&nbsp;","all")#'}
						<cfif len(session.CustomOtherIdentifier) gt 0 and thisLoopNum eq 1>,CUSTOMID: {title: '#session.CustomOtherIdentifier#'}</cfif>
						<cfif thisLoopNum lt numFlds>,</cfif>
						<cfset thisLoopNum=thisLoopNum+1>
					</cfloop>
					---->
	            }
	        });
	        $('##specresults').jtable('load');
	    });
	</script>


	<cfif trc.C is 0>
		<div>
			Your query returned no results.
			<ul>
				<li>Check your form input, or use the Clear Form button to start over.</li>
				<li>
					If you searched by taxonomy, consult <a href="/taxonomy.cfm" class="novisit">Arctos Taxonomy</a>.
					Taxa are often synonymized and revised, and may not be consistent across collections. Previous Identifications,
					which are separate from the taxonomy used in Identifications, may be located using the scientific name
					"include all IDs" option.
				</li>
				<li>
					Try broadening your search criteria. Try the next-higher geographic element, remove criteria, or use a substring match.
					Don't assume we've accurately or predictably recorded data.
				</li>
				<li>
					 Not all specimens have coordinates, and the spatial query tool will not locate all specimens.
				</li>
				<li>
					Use dropdowns or partial word matches instead of text strings, which may be entered in unexpected ways.
					"Doe" is a good choice for a collector if "John P. Doe" didn't match anything, for example.
				</li>
				<li>
					Read the documentation for individual search fields (click the title of the field to see documentation).
					Arctos fields may not be what you expect them to be.
				</li>
				<li>
					Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and
					<a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">attribute data definitions</a> documentation for terms,
					vocabulary, and standards.
				</li>
				<li>
					<a href="/googlesearch.cfm">Try our Google search</a>. Not everything in Arctos
					is indexed in Google, but it may provide a starting point to locate specific items.
				</li>
				<li>
					<a href="/contact.cfm">Contact us</a> if you still can't find what you need. We'll help if we can.
				</li>
			</ul>
		</div>
	</cfif>




	<div id="specresults"></div>
</cfoutput>
<cfinclude template="includes/_footer.cfm">