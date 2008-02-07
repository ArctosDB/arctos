<!--- no security --->
<cfinclude template="/includes/_header.cfm">
<a href="ala_edit.cfm">Search</a>~<a href="index.cfm">Enter</a>
<cfif #action# is "nothing">
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
		<option value="ALAAC" selected >ALAAC</option>
		<option value="field number">field number</option>
	</select>
	<label for="idNum">ID Number</label>
	<input type="text" name="idNum" id="idNum" size="20">
	<label for="whodunit">Whodunit</label>
	<input type="text" name="whodunit" id="whodunit" size="20">
	<label for="whendunit">Entered Date</label>
	<input type="text" name="whendunit" id="whendunit" size="20">
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
	<cfquery name="f" datasource="#Application.uam_dbo#">
		select * from ala_plant_imaging
		where 1=1
		<cfif len(#folder_identification#) gt 0>
			AND folder_identification='#folder_identification#'
		</cfif>
		<cfif len(#folder_barcode#) gt 0>
			AND folder_barcode='#folder_barcode#'
		</cfif>
		<cfif len(#idType#) gt 0>
			AND idType='#idType#'
		</cfif>
		<cfif len(#idNum#) gt 0>
			AND idNum='#idNum#'
		</cfif>
		<cfif len(#barcode#) gt 0>
			AND barcode='#barcode#'
		</cfif>
		<cfif len(#whodunit#) gt 0>
			AND whodunit='#whodunit#'
		</cfif>
		<cfif len(#whendunit#) gt 0>
			AND whendunit='to_date(#whendunit#)'
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
			</tr>
		</cfloop>
	</table>
		</cfoutput>
		
</cfif>
<!---------------------------------------->
<cfif #action# is "editRecord">
<cfoutput>
	<cfquery name="f" datasource="#Application.uam_dbo#">
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
	</select>
	<label for="idNum">ID Number</label>
	<input type="text" name="idNum" id="idNum" size="20" value="#f.idNum#">
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
		
			<cfquery name="ins" datasource="#Application.uam_dbo#">
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