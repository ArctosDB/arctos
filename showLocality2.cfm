<cfinclude template="includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<style>
	.infoPop {
		border:3px solid green;
		padding:.5em;
		z-index:9999;
		position:absolute;
		top:5%;
		left:5%;
		background-color:white;
		width:80%;
		height:60%;
		overflow:auto;
	}
</style>
<script>
	function removeDetail(){
		$("#bgDiv").remove();
		$("#customDiv").remove();
	}
	function expandGeog(geogID){
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "getGeogDetails",
				geogID : geogID,
				returnformat : "json",
				queryformat : 'column'
			},
			function (r) {
				if (r.ROWCOUNT){
 					var d='<div align="right" class="infoLink" onclick="removeDetail()">close</div>';
 					d+="Detail for geography <strong>" + r.DATA.HIGHER_GEOG[0] + '</strong>';
 					if(r.DATA.CONTINENT_OCEAN[0]){
 						 d+='<br>Continent or Ocean: <strong>' + r.DATA.CONTINENT_OCEAN[0] + '</strong>';
 					}
 					if(r.DATA.COUNTRY[0]){
 						d+='<br>Country: <strong>' + r.DATA.COUNTRY[0] + '</strong>';
 					}
 					if(r.DATA.STATE_PROV[0]){
 						d+='<br>State or Province: <strong>' + r.DATA.STATE_PROV[0] + '</strong>';
 					}
 					if(r.DATA.COUNTY[0]){
 						d+='<br>County: <strong>' + r.DATA.COUNTY[0] + '</strong>';
 					}
 					if(r.DATA.QUAD[0]){
 						d+='<br>USGS Quad: <strong>' + r.DATA.QUAD[0] + '</strong>';
 					}
 					if(r.DATA.FEATURE[0]){
 						d+='<br>Feature: <strong>' + r.DATA.FEATURE[0] + '</strong>';
 					}
 					if(r.DATA.ISLAND_GROUP[0]){
 						d+='<br>Island Group: <strong>' + r.DATA.ISLAND_GROUP[0] + '</strong>';
 					}
 					if(r.DATA.ISLAND[0]){
 						d+='<br>Island: <strong>' + r.DATA.ISLAND[0] + '</strong>';
 					}
 					if(r.DATA.SEA[0]){
 						d+='<br>Sea: <strong>' + r.DATA.SEA[0] + '</strong>';
 					}
 					if(r.DATA.SOURCE_AUTHORITY[0]){
 						d+='<br>Source: <strong>' + r.DATA.SOURCE_AUTHORITY[0] + '</strong>';
 					}
					$('<div />').addClass('bgDiv').attr("id","bgDiv").bind("click",removeDetail).appendTo('body').show();
		            $('<div />').html(d).attr("id","customDiv").addClass('infoPop').appendTo('body');
					viewport.init("#customDiv");
				} else {
					alert('An error occurred. \n' + r);
				}
			}
		);
	}
	function expand(variable, value){
		$('<div />').addClass('bgDiv').attr("id","bgDiv").bind("click",removeDetail).appendTo('body').show();
		$('<div />').attr("id","customDiv").addClass('infoPop').appendTo('body');
		var ptl="/includes/forms/locationDetail.cfm?" + variable + "=" + value;
		jQuery("#customDiv").load(ptl,{},function(){
			viewport.init("#customDiv");
		});
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
	<script>
		jQuery(document).ready(function() {
			$.each($("div[id^='mapgohere-']"), function() {
				var theElemID=this.id;
				var theIDType=this.id.split('-')[1];
				var theID=this.id.split('-')[2];
			  	var ptl='/component/functions.cfc?method=getMap&showCaption=true&returnformat=plain&size=150x150&' + theIDType + '=' + theID;
			    jQuery.get(ptl, function(data){
					jQuery("#" + theElemID).html(data);
				});
			});
		});
	</script>
	<cfset title="Locality Information">
	<cfoutput>
		<cf_findLocality type="event">
		<cfquery name="localityResults" dbtype="query">
			select
				collecting_event_id,
				higher_geog,
				geog_auth_rec_id,
				spec_locality,
				geolAtts,
				Verbatim_coordinates,
				locality_id,
				verbatim_locality,
				dec_lat,
				dec_long,
				began_date,
				ended_date,
				verbatim_date
			from
				localityResults
			group by
				collecting_event_id,
				higher_geog,
				geog_auth_rec_id,
				spec_locality,
				geolAtts,
				Verbatim_coordinates,
				dec_lat,
				dec_long,
				locality_id,
				verbatim_locality,
				began_date,
				ended_date,
				verbatim_date
		</cfquery>
		<a href="showLocality.cfm">Search Again</a>
		<table border id="t" class="sortable">
			<tr>
				<th>Geography</th>
				<th>Locality</th>
				<th>Event</th>
			</tr>
			<cfset x=0>
			<cfloop query="localityResults">
				<cfset x=x+1>
		        <cfif (verbatim_date is began_date) AND (verbatim_date is ended_date)>
					<cfset thisDate = began_date>
				<cfelseif (
							(verbatim_date is not began_date) OR
				 			(verbatim_date is not ended_date)
						)
						AND
						began_date is ended_date>
						<cfset thisDate = "#verbatim_date# (#began_date#)">
				<cfelse>
						<cfset thisDate = "#verbatim_date# (#began_date# - #ended_date#)">
				</cfif>
		        <tr>
					<td>
						<span class="infoLink" onclick="expand('geog_auth_rec_id', #geog_auth_rec_id#)">[&nbsp;details&nbsp;]</span>
						<a href="showLocality.cfm?action=srch&geog_auth_rec_id=#geog_auth_rec_id#">#higher_geog#</a>
					</td>
					<td>
						<cfif len(locality_id) gt 0>
							<span class="infoLink" onclick="expand('locality_id', #locality_id#)">[&nbsp;details&nbsp;]</span>
							<cfif len(spec_locality) gt 0>
								<a href="showLocality.cfm?action=srch&locality_id=#locality_id#">#spec_locality#</a>
							<cfelse>
								[null]
							</cfif>
							<cfif len(geolAtts) gt 0>[#geolAtts#]</cfif>
							<cfif len(dec_lat) gt 0>
								<div id="mapgohere-locality_id-#locality_id#">
									<img src="/images/indicator.gif"> [#dec_lat#/#dec_long#]
								</div
								<!----
								<br>#dec_lat#/#dec_long#
								<cfif x lte 25>
									<cfinvoke component="component.functions" method="getMap" returnvariable="contents">
									    <cfinvokeargument name="locality_id" value="#locality_id#">
									</cfinvoke>
									#contents#
								</cfif>
								---->
							</cfif>
						<cfelse>
							[no localities]
						</cfif>
					<td>
						<cfif len(collecting_event_id) gt 0>
							<span class="infoLink" onclick="expand('collecting_event_id', #collecting_event_id#)">[&nbsp;details&nbsp;]</span>
							<a href="showLocality.cfm?action=srch&collecting_event_id=#collecting_event_id#">
							<cfif len(verbatim_locality) gt 0>
								#verbatim_locality#
							<cfelse>
								[null]
							</cfif>
							</a>
							<br>#thisDate#
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