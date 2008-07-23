<!--- 
Title: helpPopupEntry.cfm 
Author: Peter DeVore
Email: zylorian@gmail.com

Description: 
	To enable people to insert into, update into and select from temp_help_popup.
Parameters: 
	action - which action to do. Takes the values "", "recallEntry", "addNewEntry",
		and "editEntry".  All of these (except for "") require fieldName.
	fieldName - which table.column value to do the above action with regards to.
Based on:
	tools/editImages.cfm

---> 
 
<script type="text/javascript">
//<!--
function modifyFieldNameForAction(fieldName,action) {
	var submitInput = document.getElementById(action + 'Submit');
	var fieldNameElement = document.getElementById(fieldName);
	var fieldNameValue = fieldNameElement.value;
	if (submitInput === null) {
		alert('does not work');
	} else {
		submitInput.setAttribute('onclick',"action='helpPopupEntry.cfm?Action=" +
				action + "&fieldName=" + fieldNameValue+"'");
		;
	} 
}
//-->
</script>
<cfinclude template="/includes/_header.cfm">
<cfset title='Help Popup Data Entry'>

<!--- set up default values for form entries --->
<cfparam name='form.add_fully_qualified_field_name' default=''>
<cfparam name='form.add_display_name' default=''>
<cfparam name='form.add_short_defn' default=''>
<cfparam name='form.add_links' default=''>
<cfparam name='form.edit_fully_qualified_field_name' default=''>
<cfparam name='form.edit_display_name' default=''>
<cfparam name='form.edit_short_defn' default=''>
<cfparam name='form.edit_links' default=''>

<!---
Do all of the add new entry/edit entry stuff BEFORE you query the db for the information.  
That way the page will get the updated data, not the previous data.
--->
<!----------------------------------------------------------------------------------->

<cfif #Action# is 'addNewEntry'>
	<cfif isdefined('form.add_fully_qualified_field_name') and 
			(not #form.add_fully_qualified_field_name# is '') and
			isdefined('form.add_display_name') and 
			(not #form.add_display_name# is '') and
			isdefined('form.add_short_defn') and 
			(not #form.add_short_defn# is '') and
			isdefined('form.add_links') and 
			(not #form.add_links# is '')>
		<cftry>
			<cfquery name='addNewEntryQuery' dataSource='uam_god'>
				INSERT INTO temp_help_popup
					(fully_qualified_field_name,
					display_name,
					short_defn,
					links) values
					('#form.add_fully_qualified_field_name#',
					'#form.add_display_name#',
					'#form.add_short_defn#',
					'#form.add_links#')
			</cfquery>
			<cfcatch type = 'database'>
				<script type='text/javascript'>
					alert('Had difficult saving new entries in the database. Please try again.');
				</script>
			</cfcatch>
		</cftry>
	<cfelse>
		<cfoutput>
			<script type='text/javascript'>
				alert('Please fill in all values for adding a new entry.');
			</script>
		</cfoutput>
	</cfif>
</cfif>

<!----------------------------------------------------------------------------------->

<cfif #Action# is 'editEntry'>
	<cfif isdefined('form.edit_fully_qualified_field_name') and 
			(not #form.edit_fully_qualified_field_name# is '') and
			isdefined('form.edit_display_name') and 
			(not #form.edit_display_name# is '') and
			isdefined('form.edit_short_defn') and 
			(not #form.edit_short_defn# is '') and
			isdefined('form.edit_links') and 
			(not #form.edit_links# is '')>
		<cftry>
			<cfquery name='editNewEntryQuery' dataSource='uam_god'>
				UPDATE temp_help_popup SET
					display_name = '#form.edit_display_name#',
					short_defn = '#form.edit_short_defn#',
					links = '#form.edit_links#' WHERE
					fully_qualified_field_name = '#form.edit_fully_qualified_field_name#'
			</cfquery>
			<cfcatch type = 'database'>
				<script type='text/javascript'>
					alert('Had difficult saving edited values in the database. Please try again.');
				</script>
			</cfcatch>
		</cftry>	
	<cfelse>
		<cfoutput>
			<script type='text/javascript'>
				alert('Please fill in all values for editing an existing entry.');
			</script>
		</cfoutput>
	</cfif>
</cfif>

<!----------------------------------------------------------------------------------->




<!--- define action if it is not defined --->
<cfif not isdefined('Action')>
	<cfset Action=''>
</cfif> 


<!--- get things that already have documentation --->
<cfquery name="helpPopupSelect" dataSource='uam_god'>
       select * from temp_help_popup order by 1
</cfquery>
<!---
Debug stuff:
Field names found in the helpPopupSelect database.
<cfoutput query='helpPopupSelect'>
	#fully_qualified_field_name#<br />
</cfoutput>
--->
	
<!--- get things that COULD have documentation but do not yet --->
<cfquery name="tableColumnsNotInHelpPopupSelect" dataSource='uam_god'>
	select table_name || '.' || column_name tablecolumn from user_tab_cols where
	        table_name || '.' || column_name not in 
			(select upper(fully_qualified_field_name) from temp_help_popup)
	        <!--- eliminate primary keys, etc. --->
	        and column_name not in ('COLLECTION_OBJECT_ID')
	        and table_name not like ('CT%')
			and table_name not like ('BIN%')
			order by 1
</cfquery>
<cfoutput>
Number of fields in request: #tableColumnsNotInHelpPopupSelect.RecordCount#.
</cfoutput>
<cfoutput>       
<!--- allow ADDitions --->
<table>
<form name="addEntryForm" method="post" action="helpPopupEntry.cfm">
	<input type="hidden" name="Action" value="addEntry" />
	<tr>
		<td colspan='2'><strong>Add a new entry.</strong></td>
	</tr>
	<tr>
		<td align='right'>fully_qualified_field_name:</td>
		<td><select id='add_fully_qualified_field_name' name='add_fully_qualified_field_name' onchange=
"javascript:modifyFieldNameForAction('add_fully_qualified_field_name','addNewEntry');">
                <cfloop query="tableColumnsNotInHelpPopupSelect">
					<option value="#tablecolumn#">#tablecolumn#</option>
				</cfloop>
				</select></td>
	</tr>
	<tr>
		<td align='right'>display_name:</td>
		<td><input type='text' name='add_display_name'
				maxlength='50' size='50' /></td>
	</tr>
	<tr>
		<td align='right'>short_defn:</td>
		<td><textarea name='add_short_defn' rows='3' cols='70'></textarea></td>
	</tr>
	<tr>
		<td align='right'>links:</td>
		<td><textarea name='add_links' rows='5' cols='70'></textarea></td>
	</tr>
	<tr>
		<!--- Make the default field name the one that has already turned up.  
		Modify it only onchange in the select menu. DO NOT CHANGE 
		id='addNewEntrySubmit' ifyou don't know what the function 
		modifyFieldNameForAction() really does.--->
		<td colspan='2'>
		<input id='addNewEntrySubmit' type='submit' value='Save New Entry' class="savBtn"
				onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'"
onclick="action='helpPopupEntry.cfm?Action=addNewEntry&fieldName=#add_fully_qualified_field_name#'"/>
		</td>
	</tr>
</form>         
                       
<!--- allow EDITs of already existing entries in the database. --->
<form name="editEntryForm" method="post" action="helpPopupEntry.cfm">
	<input type="hidden" name="Action" value="editEntry" />
	<tr>
		<td colspan='2'><strong>Edit a previously existing entry.</strong></td>
	</tr>
<!---
This portion of code fills in the values for display_name, short_defn, and links
in the edit portion of the form upon satisfying any of the following:
*you add a new entry, and so it is ready for editing.
*you recall an entry.
*you edit an existing entry, and so it is ready for editing.

It matches those values for against field names in the helpPopupSelect query,
using URL.fieldName first if it exists, and otherwise, the appropriate
fully_qualified_field_name, i.e. edit_fully_qualified_field_name if the action
is editEntry or recallEntry, and add_fully_qualified_field_name if the action 
is addNewEntry.
--->

<cfset default_display_name=''>
<cfset default_short_defn=''>
<cfset default_edit_links=''>
<cfif #Action# is 'recallEntry' or #Action# is 'addNewEntry' or 
		#Action# is 'editEntry'>
	<cfif isdefined('URL.fieldName')>
		<cfloop query='helpPopupSelect'>
			<cfif #ucase(helpPopupSelect.fully_qualified_field_name)# 
					is #URL.fieldName#>
				<cfset default_display_name='#display_name#'>
				<cfset default_short_defn='#short_defn#'>
				<cfset default_edit_links='#links#'>
				<!---
				Debug stuff:
				<cfoutput>It thinks the fully_qualified_field_name
					is #ucase(helpPopupSelect.fully_qualified_field_name)#
					while it is #URL.fieldName# in the URL.<br />
					Note that default_display_name='#display_name#'<br />
					default_short_defn='#short_defn#'<br />
					default_edit_links='#links#'
				</cfoutput>
				--->
				<cfbreak>
			</cfif>
		</cfloop>
	<cfelse>
		<cfloop query='helpPopupSelect'>
			<cfif (( #ucase(helpPopupSelect.fully_qualified_field_name)# 
					is #edit_fully_qualified_field_name#) and 
					((#Action# is 'editEntry') or (#Action# is 'recallEntry'))) 
						or 
					((#ucase(helpPopupSelect.fully_qualified_field_name)# 
					is #add_fully_qualified_field_name#) and 
					(#Action# is 'addNewEntry'))>
				<cfset default_display_name='#display_name#'>
				<cfset default_short_defn='#short_defn#'>
				<cfset default_edit_links='#links#'>
				<cfbreak>
			</cfif>
		</cfloop>
	</cfif>
</cfif>
<!----------------------------------------------------------------------------------->
	<tr>
		<td align='right'>fully_qualified_field_name:</td>
		<td><select id='edit_fully_qualified_field_name' 
				name='edit_fully_qualified_field_name' onchange=
				"javascript:modifyFieldNameForAction('edit_fully_qualified_field_name',
				'recallEntry'); modifyFieldNameForAction('edit_fully_qualified_field_name',
				'editEntry');">
<!---
This portion of code makes sure that the logically correct 
fully_qualified_field_name is chosen as the default value in the select menu.
This prevents problems with trying to make subsequent edits without
reloading the data.  Often, the page would think that the value for
edit_fully_qualified_field_name is what was there from before due to the fact
that the Coldfusion code is evaluated BEFORE the item is selected.
 --->
			<cfloop query="helpPopupSelect">
				<cfif (isdefined('URL.fieldName') and 
						ucase(fully_qualified_field_name) is URL.fieldName) or
						(isdefined('edit_fully_qualified_field_name') and
						ucase(fully_qualified_field_name) is edit_fully_qualified_field_name)>
					<option value="#ucase(fully_qualified_field_name)#" 
						selected='selected'>#ucase(fully_qualified_field_name)#</option>
				<cfelse>
					<option value='#ucase(fully_qualified_field_name)#' 
						>#ucase(fully_qualified_field_name)#</option>
				</cfif>
			</cfloop>
		</select></td>
	<tr>
	<tr>
		<td align='right'>display_name:</td>
		<td><input type='text' name='edit_display_name'
				maxlength='50' size='50' value='#default_display_name#'/></td>
	</tr>
	<tr>
		<td align='right'>short_defn:</td>
		<td><textarea name='edit_short_defn' rows='3' cols='70'>#default_short_defn#</textarea></td>
	</tr>
	<tr>
		<td align='right'>links (text area):</td>
		<td><textarea name='edit_links' rows='5' cols='70'>#default_edit_links#</textarea></td>
	</tr>
	<tr>
		<!--- Make the default field name the one that has already turned up.  Modify it
		only onchange in the select menu. --->
		<td colspan='2'>
		<input id='recallEntrySubmit' type='submit' value='Recall Data' class="picBtn"
			onmouseover="this.className='picBtn btnhov'" onmouseout="this.className='picBtn'"
			onclick="action='helpPopupEntry.cfm?Action=editEntry&fieldName=#edit_fully_qualified_field_name#'"  />
		<input id='editEntrySubmit' type='submit' value='Save Edits' class="savBtn"
			onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'"
			onclick="action='helpPopupEntry.cfm?Action=editEntry&fieldName=#edit_fully_qualified_field_name#'" />
		<!--- 
		debug code:
		edit_fully_qualified_field_name is #edit_fully_qualified_field_name#
		--->
		</td>
	</tr>
	<tr>
		<td colspan='2'>
		<input type='submit' value='Reset Page' class='clrBtn'
			onmouseover="this.className='clrBtn btnhov'" onmouseout="this.className='clrBtn'"
			onclick="action='helpPopupEntry.cfm'" />
		</td>
	</tr>
	<tr>
		<td colspan='2'>
		Please note that the format for 'links' is:
		"[title 1,]link 1;[title 2,]link 2{;etc...};[title n,]link n"
		(without the quotes).  The stuff in [] is an optional title for
		the link. If you do not specify the title, it will be displayed
		as 'more...'.  For example:<br /><br />
		<table padding='15px' margin='30px'>Google,http://www.google.com/;/SpecimenSearch.cfm</table><br />
		will be displayed as<br /><br />
		<table padding='15px' margin='30px'><a href='http://www.google.com/'>Google</a><br />
			<a href='/SpecimenSearch.cfm'>more...</a><br /></table>
		</td>
	</tr>
</form>
</table>
</cfoutput>
<!---
<cfoutput>
Please enter in the fully_qualified_field_name to get started.
Then (optionally) hit the 'Search' button to recall the entry under 
the specified fully_qualified_field_name, enter in the remaining values,
and hit 'Save' to save the entry.
<form name="helpPopupEntryForm" method="post" action="helpPopupEntry.cfm">
	<input type="hidden" name="Action" value="saveEdits">
<table>
	<tr>
		<td align='right'>fully_qualified_field_name:</td>
		<td><input type='text' name='fully_qualified_field_name'
				maxlength='77' size='77'></td>
	</tr>
	<tr>
		<td align='right'>display_name:</td>
		<td><input type='text' name='display_name'
				maxlength='50' size='50'></td>
	</tr>
	<tr>
		<td align='right'>short_defn:</td>
		<td><input type='text' name='short_defn'
				maxlength='255' size='100'></td>
	</tr>
	<tr>
		<td align='right'>links:</td>
		<td><input type='text' nname='links'
				maxlength='500' size='100'></td>
	</tr>
	<tr>
		<td colspan='2'><input type='submit' value='Search' class="savBtn"
				onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'"
					onclick="action='Search'">
		<input type='submit' value='Save' class="savBtn"
				onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'"></td>
	</tr>
	<tr>
		<td colspan='2'>
		Please note that the format for 'links' is:
		"[title 1,]link 1;[title 2,]link 2;{etc...};[title n,]link n"
		(without the quotes).  The stuff in [] is an optional title for
		the link. If you do not specify the title, it will be displayed
		as 'more...'.  For example:<br />
		<li>Google,http://www.google.com/;/SpecimenSearch.cfm</li><br />
		will be displayed as
		<li><a href='http://www.google.com/'>Google</a><br />
			<a href='/SpecimenSearch.cfm'>more...</a><br /></li>
		</td>
	</tr>
	
</table>
</form>
</cfoutput>
</cfif>--->


<cfinclude template="/includes/_footer.cfm">