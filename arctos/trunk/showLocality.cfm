<cfinclude template="includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<script>
	function removeDetail(){
		console.log('remove');
	}
	function expandLoc(geogID){
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "getGeogDetails",
				geogID : geogID,
				returnformat : "json",
				queryformat : 'column'
			},
			function (r) {
				if (r.ROWCOUNT){
 					var d="Detail for geography <strong>" + r.DATA.HIGHER_GEOG[0] + '</strong>';
 					/*
 					CONTINENT_OCEAN,
				COUNTRY,
				STATE_PROV,
				COUNTY,
				QUAD,
				FEATURE,
				ISLAND,
				ISLAND_GROUP,
				SEA,
				VALID_CATALOG_TERM_FG,
				SOURCE_AUTHORITY,
				
				""
				*/
				var bgDiv = $('<div id="bgDiv" class="bgDiv" onclick="removeDetail()"></div>').appendTo(document.body); 
				var cDiv = $('<div id="customDiv" class="sscustomBox" onclick="removeDetail()">' + d + '</div>').appendTo("#bgDiv"); 
				
				//viewport.init("#customDiv");
				//viewport.init("#bgDiv");
				} else {
					alert('An error occurred. \n' + r);
				}
			}
		);
	}
</script>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "nothing">
<cfoutput> 
	<cfset title="Explore Localities">
	<cfset showLocality=1>
	<cfset showEvent=1>
	<strong>Find Localities</strong>
    <form name="getCol" method="post" action="showLocality.cfm">
		<input type="hidden" name="action" value="srch">	
		<cfinclude template="/includes/frmFindLocation_guts.cfm">
    </form>
</cfoutput>
</cfif>

<!---------------------------------------------------------------------------------------------------->
<cfif action is "srch">
	<cfoutput>
		<cf_findLocality>

		<cfquery name="localityResults" dbtype="query">
			select
				collecting_event_id,
				higher_geog,
				geog_auth_rec_id,
				spec_locality,
				geolAtts,
				VerbatimLatitude,
				VerbatimLongitude,
				nogeorefbecause,
				locality_id,
				verbatim_locality,
				began_date,
				ended_date,
				verbatim_date,
				collecting_source,
				collecting_method
			from localityResults
			group by 
				collecting_event_id,
				higher_geog,
				geog_auth_rec_id,
				spec_locality,
				geolAtts,
				VerbatimLatitude,
				VerbatimLongitude,
				nogeorefbecause,
				locality_id,
				verbatim_locality,
				began_date,
				ended_date,
				verbatim_date,
				collecting_source,
				collecting_method
		</cfquery>
		<table border id="t" class="sortable">
			<tr>
				<th>&nbsp;</th>
				<th>Geography</th>
				<th>Locality</th>
				<th>Event</th>
			</tr>
			<cfloop query="localityResults">
		        <cfif (verbatim_date is began_date) AND
		 		    (verbatim_date is ended_date)>
				    <cfset thisDate = dateformat(began_date,"dd mmm yyyy")>
		        <cfelseif (
					(verbatim_date is not began_date) OR
		 			(verbatim_date is not ended_date)
				    )
			    	AND
			    	began_date is ended_date>
				    <cfset thisDate = "#verbatim_date# (#dateformat(began_date,"dd mmm yyyy")#)">
		        <cfelse>
				    <cfset thisDate = "#verbatim_date# (#dateformat(began_date,"dd mmm yyyy")# - #dateformat(ended_date,"dd mmm yyyy")#)">
		        </cfif>
		        <tr>
					<td>
						<span id="ex#geog_auth_rec_id#" class="likeLink" onclick="expandLoc(#geog_auth_rec_id#)">details</span>
					</td>
					<td>
						<a href="showLocality.cfm?action=srch&geog_auth_rec_id=#geog_auth_rec_id#">#higher_geog#</a>
					</td>
					<td>
						<cfif len(locality_id) gt 0>
							<cfif len(spec_locality) gt 0>
								<a href="showLocality.cfm?action=srch&locality_id=#locality_id#">#spec_locality#</a>
							<cfelse>
								[null]
							</cfif>
							<cfif len(geolAtts) gt 0>[#geolAtts#]</cfif>
							<cfif len(#VerbatimLatitude#) gt 0>
								<br>#VerbatimLatitude#/#VerbatimLongitude#
							<cfelse>
								<br>#nogeorefbecause#
							</cfif>
						<cfelse>
							[no localities]
						</cfif> 
					<td>
						<cfif len(collecting_event_id) gt 0>
							<a href="showLocality.cfm?action=srch&collecting_event_id=#collecting_event_id#">
							<cfif len(verbatim_locality) gt 0>
								#verbatim_locality#
							<cfelse>
								[null]
							</cfif>
							</a>
							<br>#thisDate#; #collecting_source#
							<cfif len(collecting_method) gt 0> 
								(#collecting_method#)
							</cfif>
						<cfelse>
							[no events]
						</cfif>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfinclude template="includes/_footer.cfm">