<cfinclude template="/includes/_frameHeader.cfm">

<script>
//http://arctos-test.tacc.utexas.edu/component/functions.cfc?method=getMap&locality_id=1234
//$("#rightcolumn").append("img").prop("src", "my_image_file.jpg");


	jQuery(document).ready(function() {
		$.each($("span[id^='mapgohere_']"), function() {
		    console.log(this.id);
		    var c=this.id.split('_');
		    console.log('locality is ' + c[2]);


		    jQuery("#" + this.id).html('i like fish');

		    jQuery("#" + this.id).append('appended morewoot');

		    var ptl='/component/functions.cfc?method=getMap&showCaption=false&returnformat=plain&locality_id=' + c[2];
		    jQuery.get(ptl, function(data){
				console.log(data);
				jQuery("#" + this.id).html('i like fish');
			});
		});
	});


</script>
<cfif action is "nothing">
	<cfoutput>
		<cfif collecting_event_name is "undefined">
			<cfset collecting_event_name=''>
		</cfif>
		<script>
			jQuery(document).ready(function() {
				if ('#collecting_event_name#'.length > 0) {
					console.log('got something');
					$("##collecting_event_name").val('#collecting_event_name#');
					$("##findCollEvent").submit();
				}
			});
		</script>
		<cfset showLocality=1>
		<cfset showEvent=1>
		<form name="findCollEvent" id="findCollEvent" method="post" action="findCollEvent.cfm">
			<input type="hidden" name="action" value="findem">
			<input type="hidden" name="dispField" value="#dispField#">
			<input type="hidden" name="formName" value="#formName#">
			<input type="hidden" name="collIdFld" value="#collIdFld#">
		 	<cfinclude template="/includes/frmFindLocation_guts.cfm">
		</form>
	</cfoutput>
</cfif>
<!----------------------------------------------------------------------->
<cfif action is "findem">
<cfoutput>
	<cf_findLocality type="event">
	<table border>
		<tr>
			<th>Geog</th>
			<th>Locality</th>
			<th>Event</th>
			<th>ctl</th>
		</tr>
		<cfset i = 1>
		<cfquery name="d" dbtype="query">
			select
				verbatim_date,
				verbatim_coordinates,
				began_date,
				ended_date,
				higher_geog,
				geog_auth_rec_id,
				spec_locality,
				locality_id,
				DEC_LAT,
				DEC_LONG,
				verbatim_locality,
				collecting_event_name,
				collecting_event_id
			from
				localityResults
			where
				collecting_event_id is not null
			group by
				verbatim_date,
				verbatim_coordinates,
				began_date,
				ended_date,
				higher_geog,
				geog_auth_rec_id,
				spec_locality,
				locality_id,
				DEC_LAT,
				DEC_LONG,
				verbatim_locality,
				collecting_event_name,
				collecting_event_id
		</cfquery>
		<cfloop query="d">
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
		 	<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
		 		<td>
					<span style="font-size:x-small" title="higher_geog">
						#higher_geog#
						(<a href="/Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#"
						target="_blank">#geog_auth_rec_id#</a>)
					</span>
				</td>
				<td>
					<table>
						<tr>
							<td valign="top">
								<span style="font-size:x-small" title="spec_locality">
									#spec_locality#
									(<a href="/editLocality.cfm?locality_id=#locality_id#"
									target="_blank">#locality_id#</a>)
								</span>
							</td>
							<td>
								<cfif len(DEC_LAT) gt 0>
									<span id="mapgohere_#collecting_event_id#_#locality_id#">
										i am map thingee mapgohere_#collecting_event_id#_#locality_id#

									</span>
									<!----
									<cfinvoke component="component.functions" method="getMap" returnvariable="contents">
										<cfinvokeargument name="locality_id" value="#locality_id#">
									</cfinvoke>
									#contents#
									---->
								</cfif>
							</td>
						</tr>
					</table>
				</td>
				<td>
					<div title="verbatim_locality">#verbatim_locality#</div>
					<cfif len(collecting_event_name) gt 0>
						<div title="collecting_event_name">#collecting_event_name#</div>
					</cfif>
					<cfif len(verbatim_coordinates) gt 0>
						<div title="verbatim_coordinates">#verbatim_coordinates#</div>
					</cfif>
					<div title="collecting date">#thisDate#</div>
				</td>
				<td>
					<input type="button" value="UseThis" class="savBtn"
						onclick="javascript: opener.document.#formName#.#collIdFld#.value='#collecting_event_id#';
							opener.document.#formName#.#dispField#.value='#jsescape(verbatim_locality)#';
							self.close();">
				</td>
			</tr>
		<cfset i=i+1>
		</cfloop>
	</table>
	</cfoutput>
</cfif>
<!----------------------------------------------------------------------->