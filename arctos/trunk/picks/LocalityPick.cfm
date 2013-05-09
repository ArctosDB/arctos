<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Locality Pick Search">
<cfif action is "nothing">
	<cfoutput>
		<cfif locality_name is 'undefined'>
			<cfset locality_name=''>
		</cfif>
		<script>
			jQuery(document).ready(function() {
				if ('#locality_name#'.length > 0) {
					$("##locality_name").val('#locality_name#');
					$("##getLoc").submit();
				}
			});
		</script>
		<cfset showLocality=1>
		<form name="getLoc" id="getLoc" method="post" action="LocalityPick.cfm">
			<input type="hidden" name="Action" value="findLocality">
			<input type="hidden" name="localityIdFld" value="#localityIdFld#">
			<input type="hidden" name="speclocFld" value="#speclocFld#">
			<input type="hidden" name="formName" value="#formName#">
			<cfinclude template="/includes/frmFindLocation_guts.cfm">
		</form>
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------->
<cfif Action is "findLocality">
<cfset title = "Select a Locality">
<script>
	jQuery(document).ready(function() {
		$.each($("div[id^='mapgohere-']"), function() {
			var theElemID=this.id;
			var theIDType=this.id.split('-')[1];
			var theID=this.id.split('-')[2];
		  	var ptl='/component/functions.cfc?method=getMap&showCaption=false&returnformat=plain&size=150x150&' + theIDType + '=' + theID;
		    jQuery.get(ptl, function(data){
				jQuery("#" + theElemID).html(data);
			});
		});
	});
</script>
<cfoutput>
	<cf_findLocality type="locality">
	<cfquery name="localityResults" dbtype="query">
		select
			locality_id,
			geog_auth_rec_id,
			locality_id,
			spec_locality,
			higher_geog,
			dec_lat,
			dec_long,
			minimum_elevation,
			maximum_elevation,
			orig_elev_units,
			georeference_source,
			georeference_protocol,
			locality_name,
			geolAtts
		from
			localityResults
		group by
			locality_id,
			geog_auth_rec_id,
			locality_id,
			spec_locality,
			higher_geog,
			dec_lat,dec_long,
			minimum_elevation,
			maximum_elevation,
			orig_elev_units,
			georeference_source,
			georeference_protocol,
			locality_name,
			geolAtts
	</cfquery>
	<table border>
		<cfset x=1>
    	 <cfloop query="localityResults">
      		<tr #iif(currentrow MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
       			<td>
		  			<input type="button" value="Accept" class="lnkBtn"
  						onClick="javascript: opener.document.#formName#.#localityIdFld#.value='#locality_id#';
						opener.document.#formName#.#speclocFld#.value='#jsescape(spec_locality)#';
						self.close();">
				</td>
				<td>
          			<span style="font-size:.7em">#higher_geog#</span>
					<br>#localityResults.spec_locality#
					<cfif len(locality_name) gt 0>
						<br>Locality Nickname: #locality_name#
					</cfif>
					<cfif len(geolAtts) gt 0> [#geolAtts#] </cfif>
					<br>
					<span style="font-size:.7em">
						<cfif len(dec_lat) gt 0 and len(dec_long) gt 0>
							<div id="mapgohere-locality_id-#locality_id#"></div>
							<br>
							#dec_lat# #dec_long#
							(#georeference_source# - #georeference_protocol#)
						</cfif>
					</span>
		  			<cfif len(#orig_elev_units#) gt 0>
						<br>
						<span style="font-size:.7em">
							Elevation: #minimum_elevation#-#maximum_elevation# #orig_elev_units#
						</span>
					</cfif>
				</td>

</tr>

</cfloop>
                          </table>




		<!---
		<br><a href="javascript: opener.document.#formName#.#localityIdFld#.value='#locality_id#';opener.document.#formName#.#speclocFld#.value='#spec_locality#';self.close();" onClick="">#spec_locality#</a>
--->
    </cfoutput>
</cfif>
<cfinclude template="../includes/_pickFooter.cfm">
