<cfinclude template = "/includes/_header.cfm">
<script type='text/javascript' language="javascript" src='/includes/jtable/jquery.jtable.min.js'></script>
<link rel="stylesheet" title="lightcolor-blue"  href="/includes/jtable/themes/lightcolor/blue/jtable.min.css" type="text/css">
<cfset title="Specimen Results Summary">

<script>
	function getDownload(){
			$("#getDownload").html("<img src='/images/indicator.gif'>");
			$.getJSON("/component/SpecimenResults.cfc",
				{
					method : "downloadSpecimenSummary",
					returnformat : "json"
				},
				function(r) {
					$("#getDownload").prop('onclick',null).off('click')
						.text("Save File")
						.attr("href",'/download.cfm?file=ArctosSpecimenSummary.csv');
					 window.location='/download.cfm?file=ArctosSpecimenSummary.csv';
				}
			);
		}
</script>
<style>
	#specresults{
		display: inline-block;
	}
</style>
<cfoutput>
	
	
	
	<div>
		<a class="likeLink" id="getDownload" onclick="getDownload();">Download</a>
		<br><span class="likeLink"
			onclick="saveSearch('#Application.ServerRootUrl#/SpecimenResultsSummary.cfm?#mapURL#&groupBy=#groupBy#');">
			Save&nbsp;Search</span>
		<br><a href="/saveSearch.cfm?action=manage">View/Manage Saved Searches</a>
	</div>
	<script type="text/javascript">
	    $(document).ready(function () {
			//$("##usertools").menu();
			//$("##goWhere").menu();
	        $('##specresults').jtable({
	            title: 'Specimen Summary: #numberformat(trc.ttl,",")# Specimens grouped into #numberformat(trc.c,",")# records.',
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
          		selectingCheckboxes: false, //Show checkboxes on first column
            	selectOnRowClick: false, //Enable this to only select using checkboxes
				pageSizes: [10, 25, 50, 100, 250, 500,5000],
				actions: {
	                listAction: '/component/SpecimenResults.cfc?totalRecordCount=#trc.c#&method=getSpecimenSummaryFS'
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