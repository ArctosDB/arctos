<cfinclude template = "/includes/_header.cfm">
<script type='text/javascript' language="javascript" src='/includes/jtable/jquery.jtable.min.js'></script>
<link rel="stylesheet" title="lightcolor-blue"  href="/includes/jtable/themes/lightcolor/blue/jtable.min.css" type="text/css">
<cfset title="Specimen Results Summary">
<cfif not isdefined("groupBy") or len(groupBy) is 0>
	<cfset groupBy='scientific_name'>
</cfif>
<cfoutput>
	<cfif not listfindnocase(groupby,'collection_object_id')>
		<cfset groupBy=listprepend(groupby,"collection_object_id")>
	</cfif>
	<cfset prefixed_cols="">
	<cfset spcols="">
	<cfloop list="#groupBy#" index="x">
		<cfset prefixed_cols = listappend(prefixed_cols,"#session.flatTableName#.#x#")>
		<cfif x is not "collection_object_id">
			<cfset spcols = listappend(spcols,"#session.flatTableName#.#x#")>
		</cfif>
	</cfloop>
	<cfset basSelect = " SELECT #prefixed_cols# ">
	<cfset basFrom = " FROM #session.flatTableName#">
	<cfset basJoin = "">
	<cfset basWhere = " WHERE #session.flatTableName#.collection_object_id IS NOT NULL ">
	<cfset basQual = "">
	<cfset mapurl="">
	<cfinclude template="includes/SearchSql.cfm">
	<cfset group_cols = groupBy>
	<cfset group_cols=listdeleteat(group_cols,listfindnocase(group_cols,'collection_object_id'))>
	<cfif listfindnocase(group_cols,'individualcount')>
		<cfset group_cols=listdeleteat(group_cols,listfindnocase(group_cols,'individualcount'))>
	</cfif>
	<!--- require some actual searching --->
	<cfset srchTerms="">
	<cfloop list="#mapurl#" delimiters="&" index="t">
		<cfset tt=listgetat(t,1,"=")>
		<cfset srchTerms=listappend(srchTerms,tt)>
	</cfloop>
	<!--- remove standard criteria that kill Oracle... --->
	<cfif listcontains(srchTerms,"collection_id")>
		<cfset srchTerms=listdeleteat(srchTerms,listfindnocase(srchTerms,'collection_id'))>
	</cfif>
	<!--- ... and abort if there's nothing left --->
	<cfif len(srchTerms) is 0>
		<CFSETTING ENABLECFOUTPUTONLY=0>
		<font color="##FF0000" size="+2">You must enter some search criteria!</font>
		<cfabort>
	</cfif>
	<cfset thisLink=mapurl>

	<!---
		mapURL probably contains taxon_scope
		We have to over-ride that here to get the
		correct links - eg, the no-subspecies name
		should not contain all the subspecies
	---->
	<cfif thisLink contains "scientific_name_match_type">
		<cfset delPos=listcontains(thisLink,"scientific_name_match_type=","?&")>
		<cfset thisLink=listdeleteat(thisLink,delPos,"?&")>
	</cfif>
	<cfset thisLink="#thisLink#&scientific_name_match_type=exact">
	<cfloop list="#spcols#" index="pt">
		<cfset x=listgetat(pt,2,'.')>
		<cfif thisLink contains x>
			<!---
				they searched for something that they also grouped by
				REMOVE the thing they searched (eg, more general)
				ADD the thing grouped (eg, more specific)
			---->
			<!--- replace search terms with stuff here ---->
			<cfset delPos=listcontainsnocase(thisLink,x,"?&")>
			<cfset thisLink=listdeleteat(thisLink,delPos,"?&")>
			<cfset thisLink=listappend(thisLink,"#x#=' || #pt# || '","&")>
		<cfelse>
			<!--- they grouped by something they did not search by, add it to the specimen-link ---->
			<cfset thisLink=listappend(thisLink,"#x#=' || #pt# || '","&")>
		</cfif>
	</cfloop>
	<cfif left(thislink,1) is '&'>
		<cfset thisLInk=right(thisLink,len(thisLink)-1)>
	</cfif>
	<cfif right(thisLink,5) is " || '">
		<cfset thisLink=left(thisLink,len(thisLink)-5)>
	</cfif>
	<cfset thisLink="'" & thisLInk>
	<cfset basSelect=basSelect & ",#thisLink# AS linktospecimens ">
	<cfset SqlString = "#basSelect# #basFrom# #basJoin# #basWhere# #basQual# ">
	<cfset checkSql(SqlString)>
	<cfset InnerSqlString = 'select COUNT(collection_object_id) CountOfCatalogedItem, linktospecimens,'>
	<cfif listfindnocase(groupBy,'individualcount')>
		<cfset InnerSqlString = InnerSqlString & 'sum(individualcount) individualcount, '>
	</cfif>
	<cfset InnerSqlString = InnerSqlString & '#group_cols# from (#SqlString#) group by #group_cols#,linktospecimens order by #group_cols#'>
	<cfset InnerSqlString = 'create table #session.SpecSumTab# as ' & InnerSqlString>
	<cftry>
		<cfquery name="die" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			drop table #session.SpecSumTab#
		</cfquery>
		<cfcatch><!--- not there, so what? --->
		</cfcatch>
	</cftry>
	<cfquery name="mktbl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preserveSingleQuotes(InnerSqlString)#
	</cfquery>
	<cfquery name="trc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from #session.SpecSumTab#
	</cfquery>
	<p>
		Found #trc.c# records. <a href="SpecimenResultsSummaryPages.cfm?action=getCSV">download</a>
	</p>
		<span class="likeLink" onclick="getDownload();">download</span>

		<span class="controlButton"	onclick="saveSearch('#Application.ServerRootUrl#/SpecimenResultsSummary.cfm?#mapURL#&groupBy=#groupBy#');">[ Save&nbsp;Search ]</span>

	<a href="/saveSearch.cfm?action=manage">[ view/manage your saved searches ]</a>


	<script type="text/javascript">
		function getDownload(){
			$.getJSON("/component/SpecimenResults.cfc",
				{
					method : "downloadSpecimenSummary",
					returnformat : "json"
				},
		function(r) {
			alert(r);
			}
	);
		}



	    $(document).ready(function () {
			//$("##usertools").menu();
			//$("##goWhere").menu();
	        $('##specresults').jtable({
	            title: 'Specimen Summary',
				paging: true, //Enable paging
	            pageSize: 10, //Set page size (default: 10)
	            sorting: true, //Enable sorting
	            defaultSorting: 'SCIENTIFIC_NAME ASC', //Set default sorting
				columnResizable: true,
				multiSorting: true,
				columnSelectable: false,
				//recordsLoaded: getPostLoadJunk,
				multiselect: true,
				selectingCheckboxes: false,
  				selecting: true, //Enable selecting
          		selectingCheckboxes: true, //Show checkboxes on first column
            	selectOnRowClick: false, //Enable this to only select using checkboxes
				pageSizes: [10, 25, 50, 100, 250, 500,5000],
				actions: {
	                listAction: '/component/SpecimenResults.cfc?totalRecordCount=#trc.c#&method=getSpecimenSummary'
	            },
	              fields:  {
					 COUNTOFCATALOGEDITEM:{title: 'Count'},
					 LINKTOSPECIMENS: {
                            title: 'Specimens'
                        },
					 	<cfset thisLoopNum=1>
					 	<cfset numFlds=listlen(group_cols)>
						<cfloop list="#group_cols#" index="col">
							<cfif col is "phylclass">
								<cfset x="Class">
							<cfelseif col is "phylorder">
								<cfset x="Order">
							<cfelseif col is "scientific_name">
								<cfset x="ScientificName">
							<cfelseif col is "formatted_scientific_name">
								<cfset x="FormattedScientificName">
							<cfelseif col is "state_prov">
								<cfset x="StateOrProvince">
							<cfelseif col is "island_group">
								<cfset x="IslandGroup">
							<cfelseif col is "spec_locality">
								<cfset x="SpecificLocality">
							<cfelseif col is "continent_ocean">
								<cfset x="ContinentOrOcean">
							<cfelse>
								<cfset x=toProperCase(col)>
							</cfif>
							#ucase(COL)#: {title: '#x#'}
							<cfif thisLoopNum lt numFlds>,</cfif>
							<cfset thisLoopNum=thisLoopNum+1>
						</cfloop>
	            }
	        });
	        $('##specresults').jtable('load');
	    });
	</script>
	<div id="specresults"></div>






</cfoutput>
<cfinclude template = "includes/_footer.cfm">