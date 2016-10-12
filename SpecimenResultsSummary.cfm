<cfinclude template = "/includes/_header.cfm">
<script type='text/javascript' language="javascript" src='/includes/jtable/jquery.jtable.min.js'></script>
<link rel="stylesheet" title="lightcolor-blue"  href="/includes/jtable/themes/lightcolor/blue/jtable.min.css" type="text/css">
<cfset title="Specimen Results Summary">
<!---
Bad things? Last standalone copy of this form is in v6.11
---->
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
	<cfif not isdefined("groupBy") or len(groupBy) is 0>
		<cfset groupBy='scientific_name'>
	</cfif>
	<cfif listfindnocase(groupBy,"collection_object_id")>
		<cfset groupBy=listdeleteat(groupby,listfindnocase(groupby,"collection_object_id"))>
	</cfif>
	<!----
	<cfif not listfindnocase(groupBy,"scientific_name")>
		<cfset groupBy=listprepend(groupby,'scientific_name')>
	</cfif>
	---->
	<!---- now pull everything that's NOT groupby out of wherever it came from ---->
	<cfset querystring="">
	<cfloop list="#StructKeyList(form)#" index="key">
		<cfif len(form[key]) gt 0 and key is not "groupby">
			<cfset querystring=listappend(querystring,"#key#=#form[key]#","&")>
		</cfif>
	</cfloop>
	<cfloop list="#StructKeyList(url)#" index="key">
		<cfif len(url[key]) gt 0 and key is not "groupby">
			<cfset querystring=listappend(querystring,"#key#=#url[key]#","&")>
		</cfif>
	</cfloop>
	<cfset equerystring=URLEncodedFormat(querystring)>
	<div>
		<a class="likeLink" id="getDownload" onclick="getDownload();">Download</a>
		<br><span class="likeLink"
			onclick="saveSearch('#Application.ServerRootUrl#/SpecimenResultsSummary.cfm?#querystring#&groupBy=#groupBy#');">
			Save&nbsp;Search</span>
		<br><a href="/saveSearch.cfm?action=manage">View/Manage Saved Searches</a>
	</div>
	<cfset sortby="">
	<cfloop list="#groupby#" index="c">
		<cfset sortby=listappend(sortby,'#ucase(c)# ASC')>
	</cfloop>
	<script type="text/javascript">
	    $(document).ready(function () {
	    	$.getJSON("/component/SpecimenResults.cfc",
				{
					method : "getSpecimenSummary",
					returnformat : "json",
					querystring : "#equerystring#",
					groupBy: "#groupBy#"
				},
				function(r) {
					 if (r.Result !='OK'){
			        	$('##msgdiv').html(r.Message).addClass('error');
			   		 	return false;
					}
					 $('##specresults').jtable({
			            title: 'Specimen Summary: ' + r.TotalSpecimenCount + ' Specimens grouped into ' + r.TotalRecordCount + ' records.',
						paging: true, //Enable paging
			            pageSize: 100, //Set page size (default: 10)
			            sorting: true, //Enable sorting
			            defaultSorting: '#sortby#', //Set default sorting
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
			                listAction: '/component/SpecimenResults.cfc?method=getSpecimenSummary&totalRecordCount=' + r.TotalRecordCount + '&TotalSpecimenCount=' + r.TotalSpecimenCount + '&qid=' + r.qid
			            },
			            fields:  {
							COUNTOFCATALOGEDITEM:{title: 'Count'},
							LINKTOSPECIMENS: {title: 'Specimens'},
							<cfset thisLoopNum=1>
						 	<cfset numFlds=listlen(groupby)>
							<cfloop list="#groupby#" index="col">
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
			        $('##msgdiv').removeClass().hide();
				}
			);
	    });
	</script>
	<div id="msgdiv"><img  src="/images/indicator.gif">&nbsp;Processing request</div>
	<label for="specresults">Control-Click in order of desired result to sort by multiple columns</label>
	<div id="specresults"></div>
</cfoutput>
<cfinclude template = "includes/_footer.cfm">