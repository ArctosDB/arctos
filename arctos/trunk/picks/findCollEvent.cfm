<cfinclude template="/includes/_frameHeader.cfm">
<cfif #action# is "nothing">
<cfoutput>
<cfset showLocality=1>
<cfset showEvent=1>
<form name="findCollEvent" method="post">
	<input type="hidden" name="action" value="findem">
	<input type="hidden" name="dispField" value="#dispField#">
	<input type="hidden" name="formName" value="#formName#">
	<input type="hidden" name="collIdFld" value="#collIdFld#">
 	<cfinclude template="/includes/frmFindLocation_guts.cfm">
</form>
</cfoutput>
</cfif>
<!----------------------------------------------------------------------->
<cfif #action# is "findem">

<cfoutput>
	<cf_findLocality>
	
	<table border>
		<tr>
						
			<tr>
			<td rowspan="3"> <b>Geog</b></td>
			<td rowspan="3"><b>Locality</b></td>
			<td rowspan="3">&nbsp;
			
			</td>
			<td><b>Verb. Loc.</b></td>
			<td><strong>Coll Date</strong></td>
			</tr>
		<tr>
			
			<td>
				<strong>Feature</strong>
			</td>
			<td>
				<strong>Island</strong>
			</td>
		</tr>
		<tr>
			
			<td colspan="2">
				<strong>Coordinates</strong>
			</td>
		</tr>
		
		
		
	<cfset i = 1>
	<cfloop query="localityResults">
		 <tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
			<td rowspan="3"> 
				<font size="-2">
					#higher_geog# 
					(<a href="/Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#" 
						target="_blank">#geog_auth_rec_id#</a>)
				</font></td>
			<td rowspan="3">
				<font size="-2">
					#spec_locality# 
					(<a href="/Locality.cfm?Action=editLocality&locality_id=#locality_id#" 
						target="_blank">#locality_id#</a>)
				</font>
</td>
			<td rowspan="3">
			<form name="coll#i#" method="post" action="">
				<input type="hidden" name="formName" value="#formName#">
				<input type="hidden" name="collIdFld" value="#collIdFld#">
				<input type="hidden" name="dispField" value="#dispField#">
				<input type="hidden" name="action" value="updateCollEvent">
				<table cellpadding="0" cellspacing="0">
				<tr>
					<td>
						<cfset vl=replace(verbatim_locality,"'","\'","all")>
						<input type="button" 
							value="Select" 
							class="savBtn"
							onmouseover="this.className='savBtn btnhov'" 
							onmouseout="this.className='savBtn'"
							onclick="javascript: opener.document.#formName#.#collIdFld#.value='#collecting_event_id#'; 
								opener.document.#formName#.#dispField#.value='#vl# (#verbatim_date#)';
								self.close();">
					</td>
				</tr>
			</table>
			
						
						
			</form>
			</td>
			<td>#verbatim_locality#</td>
			<cfif (#verbatim_date# is #began_date#) AND
			 		(#verbatim_date# is #ended_date#)>
					<cfset thisDate = #dateformat(began_date,"dd mmm yyyy")#>
			<cfelseif (
						(#verbatim_date# is not #began_date#) OR
			 			(#verbatim_date# is not #ended_date#)
					)
					AND
					#began_date# is #ended_date#>
					<cfset thisDate = "#verbatim_date# (#dateformat(began_date,"dd mmm yyyy")#)">
			<cfelse>
					<cfset thisDate = "#verbatim_date# (#dateformat(began_date,"dd mmm yyyy")# - #dateformat(ended_date,"dd mmm yyyy")#)">
			</cfif>
			
			<td>#thisDate#</td>
			</tr>
		<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
			
			<td>
				#feature#
			</td>
			<td>
				#island#
			</td>
		</tr>
		<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
			
			<td colspan="2">
				<font size="-1">
					#VerbatimLatitude# / #verbatimLongitude# &plusmn; #max_error_distance# #max_error_units# <em><strong>Ref:</strong></em> #lat_long_ref_source#
				</font>
			</td>
		</tr>
	<cfset i=#i#+1>
	</cfloop>
		
	</table>
	</cfoutput>
</cfif>
<!----------------------------------------------------------------------->