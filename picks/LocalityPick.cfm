<cfinclude template="../includes/_pickHeader.cfm">
<script>
	function fireEvent (fEvent) {
		//alert('event thingy: ' + fEvent);
		if (fEvent.length > 0 && fEvent != 'undefined') {
			var fireThis = "opener." + fEvent + "()";
			eval(fireThis);
		}
		self.close();
	}
</script>
<cfset title = "Locality Pick Search">
<cfif action is "nothing">
<cfoutput>
<cfset showLocality=1>
<form name="getLoc" method="post" action="LocalityPick.cfm">
	<input type="hidden" name="Action" value="findLocality">
	<input type="hidden" name="localityIdFld" value="#localityIdFld#">
		<input type="hidden" name="speclocFld" value="#speclocFld#">
		<input type="hidden" name="formName" value="#formName#">
		<input type="hidden" name="fireEvent" value="#fireEvent#">
		<cfinclude template="/includes/frmFindLocation_guts.cfm">
	</form>
</cfoutput>
</cfif>
<!-------------------------------------------------------------------->
<cfif #Action# is "findLocality">
<cfset title = "Select a Locality">
<cfoutput>
	<cf_findLocality>
	<cfquery name="localityResults" dbtype="query">
		select 
			locality_id,geog_auth_rec_id,locality_id,spec_locality,higher_geog,
			verbatimLatitude,verbatimLongitude,NoGeorefBecause,
			minimum_elevation,maximum_elevation,orig_elev_units,
			coordinateDeterminer,
			determined_date,
			lat_long_ref_source,
			geolAtts
		from localityResults
		group by
			locality_id,geog_auth_rec_id,locality_id,spec_locality,higher_geog,verbatimLatitude,
			verbatimLongitude,NoGeorefBecause,
			minimum_elevation,maximum_elevation,orig_elev_units,
			coordinateDeterminer,
			determined_date,
			lat_long_ref_source,
			geolAtts
	</cfquery>
	<table border>
    	<tr> 
      		<td><b>&nbsp;</b></td>
	   		<td><b>Spec Locality</b></td>
    	</tr>
    	 <cfloop query="localityResults"> 
      		<tr #iif(currentrow MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
       			<td>
		  			<input type="button" value="Accept" class="lnkBtn"
   						onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
  						onClick="javascript: opener.document.#formName#.#localityIdFld#.value='#locality_id#';
						opener.document.#formName#.#speclocFld#.value='#jsescape(spec_locality)#';
						self.close();">
				</td>
				<td> 
          			<span style="font-size:.7em">#higher_geog#</span>
					<br>#localityResults.spec_locality#
					<cfif len(geolAtts) gt 0> [#geolAtts#] </cfif>
					<br>
					<span style="font-size:.7em">
						<cfif len(#verbatimLatitude#) gt 0 and len(#verbatimLongitude#) gt 0>
							#verbatimLatitude# #verbatimLongitude# 
							(#coordinateDeterminer# on #dateformat(determined_date,"dd mmm yyyy")# ref. #lat_long_ref_source#)
						<cfelse>
							#NoGeorefBecause#
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
