<!--- no security --->
<cfinclude template="/includes/_header.cfm">
<a href="ala_edit.cfm">Search</a>~<a href="index.cfm">Enter</a>
<cfif #action# is "nothing">
<cfquery name="cts" datasource="uam_god">
	select distinct(status) status from ala_plant_imaging order by status
</cfquery>


<cfoutput>
	<cfset numberFolders = 20>
<h2>
	ALA Plant Collection Imaging Project - Find records to Edit
</h2>
(all fields are exact match)
<form name="findEm" method="post" action="ala_edit.cfm">
	<input type="hidden" name="action" value="findem">
	<label for="folder_identification">Identification on Folder</label>
	<input type="text" name="folder_identification" id="folder_identification" size="50">
	<label for="folder_barcode">Barcode on Folder</label>
	<input type="text" name="folder_barcode" id="folder_barcode" size="20">
	<label for="barcode">Barcode on Sheet</label>
	<input type="text" name="barcode" id="barcode" size="20">
	<label for="idType">ID Type</label>
	<select name="idType" id="" size="1">
		<option value=""></option>
		<option value="ALAAC" >ALAAC</option>
		<option value="field number">field number</option>
		<option value="ISC: Ada Hayden Herbarium, Iowa State University">ISC: Ada Hayden Herbarium, Iowa State University</option>
	</select>
	<label for="idNum">ID Number</label>
	<input type="text" name="idNum" id="idNum" size="20">
	<label for="whodunit">Whodunit</label>
	<input type="text" name="whodunit" id="whodunit" size="20">
	<label for="whendunit">Entered Date</label>
	<input type="text" name="whendunit" id="whendunit" size="20">
	<label for="status">Status</label>
	<select name="status" id="status" size="1">
		<option value=""></option>
		<cfloop query="cts">
			<option value="#status#">#status#</option>
		</cfloop>"
	</select>
	<input type="submit" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
	   				onmouseout="this.className='lnkBtn'"
					value="Find">
</form>
</cfoutput>
</cfif>
<!---------------------------------------->
<cfif #action# is "findem">
<cfoutput>
	<cfquery name="f" datasource="uam_god">
		select * from ala_plant_imaging
		where 1=1
		<cfif isdefined("folder_identification") and len(#folder_identification#) gt 0>
			AND folder_identification='#folder_identification#'
		</cfif>
		<cfif isdefined("status") and  len(#status#) gt 0>
			AND status='#status#'
		</cfif>
		<cfif isdefined("folder_barcode") and  len(#folder_barcode#) gt 0>
			AND folder_barcode='#folder_barcode#'
		</cfif>
		<cfif isdefined("idType") and  len(#idType#) gt 0>
			AND idType='#idType#'
		</cfif>
		<cfif isdefined("idNum") and  len(#idNum#) gt 0>
			AND idNum='#idNum#'
		</cfif>
		<cfif isdefined("barcode") and  len(#barcode#) gt 0>
			AND barcode='#barcode#'
		</cfif>
		<cfif isdefined("whodunit") and  len(#whodunit#) gt 0>
			AND whodunit='#whodunit#'
		</cfif>
		<cfif isdefined("whendunit") and  len(#whendunit#) gt 0>
			AND whendunit='to_date(#whendunit#)'
		</cfif>
		<cfif isdefined("image_id_list") and len(#image_id_list#) gt 0>
			AND image_id IN (#image_id_list#)
		</cfif>
	</cfquery>
	<table border>
		<tr>
			<td>folder_identification</td>
			<td>folder_barcode</td>
			<td>idType</td>
			<td>idNum</td>
			<td>barcode</td>
			<td>who</td>
			<td>when</td>
			<td>status</td>
			<td>Arctos</td>
		</tr>
		<cfloop query="f">
			<tr class="likeLink" onclick="document.location='ala_edit.cfm?action=editRecord&image_id=#image_id#';">
				<td>#folder_identification#</td>
				<td>#folder_barcode#</td>
				<td>#idType#</td>
				<td>#idNum#</td>
				<td>#barcode#</td>
				<td>#whodunit#</td>
				<td>#whendunit#</td>
				<td>#status#</td>
				<td><a href="/SpecimenResults.cfm?OIDType=#idType#&OIDNum=#idNum#">Arctos?</a></td>
			</tr>
		</cfloop>
	</table>
		</cfoutput>
		
</cfif>
<!---------------------------------------->
<cfif #action# is "editRecord">
<cfoutput>
	<cfquery name="f" datasource="uam_god">
		select * from ala_plant_imaging
		where image_id=#image_id#
	</cfquery>
<form name="pd" method="post" action="ala_edit.cfm">
<input type="hidden" name="action" value="saveEdit">
<input type="hidden" name="image_id" value="#image_id#">
	<label for="folder_identification">Identification on Folder</label>
	<input type="text" name="folder_identification" id="folder_identification" size="50" value="#f.folder_identification#">
	<label for="folder_barcode">Barcode on Folder</label>
	<input type="text" name="folder_barcode" id="folder_barcode" size="20" value="#f.folder_barcode#">
	<label for="barcode">Barcode on Sheet</label>
	<input type="text" name="barcode" id="barcode" size="20" value="#f.barcode#">
	<label for="idType">ID Type</label>
	<select name="idType" id="" size="1">
		<option value="ALAAC" <cfif #f.idType# is "ALAAC"> selected </cfif> >ALAAC</option>
		<option value="field number"  <cfif #f.idType# is "field number"> selected </cfif>>field number</option>
		<option <cfif #f.idType# is "ISC: Ada Hayden Herbarium, Iowa State University"> selected </cfif>
			value="ISC: Ada Hayden Herbarium, Iowa State University">ISC: Ada Hayden Herbarium, Iowa State University</option>
	</select>
	<label for="idNum">ID Number</label>
	<input type="text" name="idNum" id="idNum" size="20" value="#f.idNum#">
	<label for="">Search Arctos for this ID</label>
	<a href="/SpecimenResults.cfm?OIDType=#f.idType#&OIDNum=#f.idNum#">Arctos?</a>
	<label for="savBtn">&nbsp;</label>
	<input type="submit" 
					class="savBtn"
					onmouseover="this.className='savBtn btnhov'" 
	   				onmouseout="this.className='savBtn'"
					value="Save Edits">
</form>
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif #action# is "saveEdit">

	<cfoutput>
		<cfif len(#folder_identification#) is 0 or len(#folder_barcode#) is 0>
			Folder Identification, Folder Barcode and Sheet Barcode are required. Use your back button...
			<cfabort>
		</cfif>
		
			<cfquery name="ins" datasource="uam_god">
				UPDATE ala_plant_imaging SET
					folder_identification = '#folder_identification#',
					folder_barcode = '#folder_barcode#',
					idType = '#idType#',
					idNum = '#idNum#',
					barcode = '#barcode#'
				WHERE
					image_id=#image_id#
			</cfquery>		
		<cflocation url="ala_edit.cfm">
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">