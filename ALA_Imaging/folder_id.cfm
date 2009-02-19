<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
<cfoutput>

<cfquery name="folder_identification" datasource="uam_god">
	select distinct(folder_identification) folder_identification from ala_plant_imaging where status = 'bad_folder_id'
	order by folder_identification
</cfquery>
The following folder identifications are not in Arctos taxonomy. You must:
<ul>
	<li>Correct misspellings here, and/or</li>
	<li>Add taxonomy to Arctos</li>
</ul>
Then click Save. Changes will process overnight.
<p>Example:</p>
<table border>
	<tr>
		<td>Problem</td>
		<td>Fix</td>
		<td>Process</td>
	</tr>
	<tr>
		<td>
			An item is mis-spelled. The correct version exists in Arctos.
		</td>
		<td>
			Provide the correct spelling in the ShouldBe box. Submit form.
		</td>
		<td>
			All records using the old Folder_ID are updated to the value you provide. 
			The record is flagged to be re-checked, which will happen the following night. 
			If everything is OK, it will be loaded. Otherwise, it will be rejected and an 
			email will be sent.
		</td>
	</tr>
	<tr>
		<td>
			An item is missing from Arctos. The value given is correct, we just don't have it.
		</td>
		<td>
			Add the ID to Arctos Taxonomy. Check the addedToArctos box. Submit form.
		</td>
		<td>
			The record is flagged to be re-checked, which will happen the following night. 
			If everything is OK, it will be loaded. Otherwise, it will be rejected and an 
			email will be sent.
		</td>
	</tr>
	<tr>
		<td>
			An item is mis-spelled. Neither the mis-spelling nor the corrected version exists in Arctos. 
		</td>
		<td>
			Add the correct ID to Arctos Taxonomy. Fill in the ShouldBe box with the correction. Submit form.
		</td>
		<td>
			All records using the old Folder_ID are updated to the value you provide. 
			The record is flagged to be re-checked, which will happen the following night. 
			If everything is OK, it will be loaded. Otherwise, it will be rejected and an 
			email will be sent.
		</td>
	</tr>
	<tr>
		<td>
			Beats me. The "problem" record exists in Arctos. Spelling seems to be OK. Argghhhh! 
		</td>
		<td>
			Check "Valid?" flag in Arctos - records flagged as invalid are invisible to the ALA apps.
			Check for leading or trailing spaces and other whitespace characters in Arctos and
			in the seemingly-fine flagged record. Send email to DLM if you can't find the problem. 
			Flag and/or update the record. Submit the form.
		</td>
		<td>
			Same as above. 
		</td>
	</tr>
</table>
<p>&nbsp;</p>
<table border>
	<tr>
		<td>Current</td>
		<td>ShouldBe</td>
		<td>addedToArctos</td>
		<td>?</td>
	</tr>
	<form name="fid" method="post" action="folder_id.cfm">
	<input type="hidden" name="action" value="setID">
	<cfset i=1>
<cfloop query="folder_identification">
<cfquery name="g" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select taxon_name_id from taxonomy where scientific_name='#trim(folder_identification)#'
</cfquery>
	<input type="hidden" name="folder_identification_#i#" value="#folder_identification#">
	<tr>
		<td>#folder_identification#</td>
		<td>
			<input type="text" name="n_folder_id_#i#">
		</td>
		<td>
			<input type="checkbox" name="added_#i#" value="true">
		</td>
		<td>
			<cfif #len(g.taxon_name_id)# gt 0>
				Check accepted fg <a href="/Taxonomy.cfm?Action=edit&taxon_name_id=#g.taxon_name_id#">here</a>
			</cfif>
		</td>
	</tr>
	<cfset i=#i#+1>
</cfloop>
<cfset mi=#i#-1>
<input type="hidden" name="mi" value="#mi#">
<tr>
	<td>
		<input type="submit" value="makeChanges">
	</td>
</tr>

</form>
</table>
</cfoutput>
</cfif>
<cfif #action# is "setID">
	<cfoutput>
		<cfloop from="1" to="#mi#" index="i">
			<cfset id = evaluate("folder_identification_" & i)>
			<cfset nid = evaluate("n_folder_id_" & i)>

			<cfif isdefined("added_#i#")>
				<cfset add = evaluate("added_" & i)>
			<cfelse>
				<cfset add="false">
			</cfif>
			<cfif #add#>
				<!---
								update ala_plant_imaging set status=null where status='bad_folder_id' and folder_identification='#id#'		
				--->		
				<cfquery name="ss" datasource="uam_god">
					update ala_plant_imaging set status=null where status='bad_folder_id' and folder_identification='#id#'
				</cfquery>

			</cfif>
			<cfif len(#nid#) gt 0>
				<!---
					update ala_plant_imaging set folder_identification = '#nid#',status=NULL where folder_identification = '#id#'
				--->
				<cfquery name="nid" datasource="uam_god">
					update ala_plant_imaging set folder_identification = '#trim(nid)#',status=NULL where folder_identification = '#id#'
				</cfquery>

			</cfif>
		</cfloop>
		Update complete.
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">