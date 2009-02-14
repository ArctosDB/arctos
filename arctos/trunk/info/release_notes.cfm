<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
<cfoutput>
	<cfif #Application.ServerRootUrl# does not contain "arctos.database.museum">
		This application is maintained only at http://arctos.database.museum/tools/release_notes.cfm.
		 <br>
		<a href="http://arctos.database.museum/tools/release_notes.cfm">Click here</a> to use it.
		<cfabort>
	</cfif>
	<cfquery name="ctrn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select distinct(release_number) from cfrelease_notes order by release_number
	</cfquery>
	<form name="f" method="post" action="release_notes.cfm">
		<input name="action" type="hidden" value="find">
		<label for="release_number">Release Number</label>
		<select name="release_number" id="release_number" size="1">
			<option value=""></option>
			<cfloop query="ctrn">
				<option value="#release_number#">#release_number#</option>
			</cfloop>
		</select>
		<input type="submit" value="Display" 
			class="schBtn"
   			onmouseover="this.className='schBtn btnhov'" 
			onmouseout="this.className='schBtn'">
	</form>
<cfif #session.rights# contains "admin">
<table class="newRec">
	<tr>
		<td>
		Add Release Note:<br>
	<form name="new" method="post" action="release_notes.cfm">
				<input name="action" type="hidden" value="new">
		<label for="release_number">Release Number</label>
		<input type="text" name="release_number" id="release_number">
		<label for="made_by_person">made_by_person</label>
		<input type="text" name="made_by_person" id="made_by_person">
		<label for="change_type">change_type</label>
		<select name="change_type" id="change_type" size="1">
			<option vale="application">application</option>
			<option vale="structure">structure</option>
		</select>
		<label for="release_note">release_note</label>
		<textarea name="release_note" cols="40" rows="5" id="release_note"></textarea>
		<label for="code_change">code_change</label>
		<textarea name="code_change" cols="40" rows="5" id="code_change"></textarea>
		<input type="submit" value="Save" 
			class="savBtn"
   			onmouseover="this.className='savBtn btnhov'" 
			onmouseout="this.className='savBtn'">
	</form>
	</td>
	</tr>
</table>
</cfif>
</cfoutput>
</cfif>
<cfif #action# is "find">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from cfrelease_notes
			<cfif isdefined("release_number") and len(#release_number#) gt 0>
				where release_number = '#release_number#'
			</cfif>
		</cfquery>
		<table border>
			<tr>
				<th>Release Number</th>
				<th>Made By</th>
				<th>Change Type</th>
				<th>Note</th>
				<th>Code</th>
				<cfif #session.rights# contains "admin">
					<th>&nbsp;</th>
				</cfif>
			</tr>
		<cfloop query="d">
			<tr>
				<td>#release_number#</td>
				<td>#made_by_person#</td>
				<td>#change_type#</td>
				<td>#release_note#</td>
				<td>#code_change#</td>
				<cfif #session.rights# contains "admin">
					<td><a href="release_notes.cfm?action=edit&release_note_id=#release_note_id#">edit</a></td>
				</cfif>				
			</tr>
		</cfloop>		
		</table>
	</cfoutput>
	
</cfif>
<cfif #action# is "edit">
<cfoutput>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from cfrelease_notes
				where release_note_id = #release_note_id#
		</cfquery>
		<form name="new" method="post" action="release_notes.cfm">
				<input name="action" type="hidden" value="saveEdit">
				<input name="release_note_id" type="hidden" value="#release_note_id#">
		<label for="release_number">Release Number</label>
		<input type="text" name="release_number" value="#d.release_number#" id="release_number">
		<label for="made_by_person">made_by_person</label>
		<input type="text" name="made_by_person"  value="#d.made_by_person#" id="made_by_person">
		<label for="change_type">change_type</label>
		<select name="change_type" id="change_type" size="1">
			<option <cfif #d.change_type# is ""> selected </cfif> value="application">application</option>
			<option <cfif #d.change_type# is ""> selected </cfif> value="structure">structure</option>
		</select>
		<label for="release_note">release_note</label>
		<textarea name="release_note" cols="40" rows="5" id="release_note">#d.release_note#</textarea>
		<label for="code_change">code_change</label>
		<textarea name="code_change" cols="40" rows="5" id="code_change">#d.code_change#</textarea>
		<input type="submit" value="Save" 
			class="savBtn"
   			onmouseover="this.className='savBtn btnhov'" 
			onmouseout="this.className='savBtn'">
	</form>
	</cfoutput>
</cfif>

<cfif #action# is "saveEdit">
	<cfoutput>
		<cfquery name="i" datasource="#Application.uam_dbo#">
			update
			cfRelease_notes set
			release_number='#release_number#'
			<cfif len(#made_by_person#) gt 0>
				,made_by_person='#made_by_person#'
			<cfelse>
				made_by_person=NULL
			</cfif>
			<cfif len(#change_type#) gt 0>
				,change_type='#change_type#'
			<cfelse>
				change_type=NULL
			</cfif>
			<cfif len(#release_note#) gt 0>
				,release_note='#release_note#'
			<cfelse>
				release_note=NULL
			</cfif>
			<cfif len(#code_change#) gt 0>
				,code_change='#code_change#'
			<cfelse>
				code_change=NULL
			</cfif>
			where release_note_id = #release_note_id#
		</cfquery>
		<cflocation url="release_notes.cfm">
	
	</cfoutput>
</cfif>

<cfif #action# is "new">
	<cfoutput>
		<cfquery name="i" datasource="#Application.uam_dbo#">
			insert into 
			cfRelease_notes (
				release_number,
				made_by_person,
				change_type,
				release_note,
				code_change) values (
				'#release_number#',
				'#made_by_person#',
				'#change_type#',
				'#release_note#',
				'#code_change#')
		</cfquery>
		<cflocation url="release_notes.cfm">
	
	</cfoutput>
</cfif>
<h2>
	Version 2.2.1 Release Notes:
</h2>
<span class="infoLink" onclick="document.getElementById('v2.2Code').style.display='block';">Show Code</span>
<div class="code" id="v2.2Code" style="display:none;"><!--------------------------- code ------------------>
	NOTE: This is a mid-cycle feature release. Do NOT rebuild FLAT or build materialized views. Other changes
	in /DDL probably won't break anything, but they should not be necessary.
	<p>

	
	</p>

</div><!------------------------------------------------- /code div --------------------------------------->
<ul>
	<li>
		Add collections to Bulkloader
	</li>
	<li>
		Add Permits to Loans
	</li>
	<li>
		Add generic UAM loan form
	</li>	
	<li>
		Add GUID capability to SpecimenDetail. Examples:
		<ul>
			<li>SpecimenDetail.cfm?collection_object_id=1234</li>
			<li>SpecimenDetail.cfm?guid=UAM:Mamm:1234</li>
		</ul> 
	</li>
	<li>
		Updated Bulkloader documentation
	</li>
	<li>
		Deleted /includes/temp/
	</li>
	<li>
		Reorganize permits:
		<ul>
			<li>
				Remove permit search from SpecimenSearch
			</li>
			<li>Add permit number (with pick) to Loans and Accns</li>
			<li>Add links from loan and accn search results to SpecimenResults (combined for all 
				loans/permits in your search)</li>
		</ul>
	</li>
	<li>
		Update Data Entry:
		<ul>
			<li>Date validation</li>
			<li>Accn validation</li>
			<li>Copy dates/names to attributes only</li>
			<li>More calendar and copy widgets</li>
			<li>Custom Identifier replaces AF/NK</li>
			<li>Force new record part lot count to 1</li>
		</ul>
	</li>
</ul> 
<p>
Former Versions:
<ul>
	<li><a href="release_notes_2.2.cfm">v2.2</a></li>
</ul>

</p>
<cfinclude template="/includes/_footer.cfm">