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


<cfif #Action# is "nothing">
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
			minimum_elevation,maximum_elevation,orig_elev_units
		from localityResults
		group by
			locality_id,geog_auth_rec_id,locality_id,spec_locality,higher_geog,verbatimLatitude,
			verbatimLongitude,NoGeorefBecause,
			minimum_elevation,maximum_elevation,orig_elev_units
	</cfquery>
	<table border>
    	<tr> 
      		<td><b>&nbsp;</b></td>
	   		<td><b>Spec Locality</b></td>
    	</tr>
    	 <cfloop query="localityResults"> 
      		<tr #iif(currentrow MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
       			<td>
		  			<cfset thisValue=#replace(spec_locality,"'","`","all")#>
		  			<cfset thisValue=#replace(thisValue,'"','``',"all")#>
		  			<input type="button" value="Accept" class="lnkBtn"
   						onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
  						onClick="javascript: opener.document.#formName#.#localityIdFld#.value='#locality_id#';
						opener.document.#formName#.#speclocFld#.value='#thisValue#';
						self.close();">
				</td>
				<td> 
          			#localityResults.spec_locality#
		  			<br>
		  			<font size="-2">#higher_geog#
						<cfif len(#orig_elev_units#) gt 0>
							&nbsp;&nbsp;&nbsp;Elevation: #minimum_elevation#-#maximum_elevation# #orig_elev_units#
						</cfif>
					</font>
					<br><font size="-2">#verbatimLatitude# #verbatimLongitude#</font>
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
