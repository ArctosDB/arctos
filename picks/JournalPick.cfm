<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Journal pick">
<cfoutput>
<label for="findJournal">Find Journal</label>
<form name="findJournal" id="findJournal" method="post" action="JournalPick.cfm">
	<input type="hidden" name="journalIdFld" value="#journalIdFld#">
	<input type="hidden" name="journalNameFld" value="#journalNameFld#">
	<input type="hidden" name="formName" value="#formName#">
	<input type="hidden" name="search" value="true">
	<label for="journal_name">Journal Name</label>
	<input type="text" name="journal_name" id="journal_name">
	<label for="journal_abbreviation">Journal Abbreviation</label>
	<input type="text" name="journal_abbreviation" id="journal_abbreviation">
	<label for="publisher_name">Publisher</label>
	<input type="text" name="publisher_name" id="publisher_name">
	<br><input type="submit" value="Find Journal" class="lnkBtn">
</form>
</cfoutput>
	
<cfif isdefined("search") and #search# is "true">
	<!--- make sure we're searching for something --->
	<cfif  len(#journal_name#) is 0  AND len(#journal_abbreviation#) is 0  AND len(#publisher_name#) is 0 >
		You must enter search criteria.
		<cfabort>
	</cfif>
	<cfoutput>
		<cfset sql = "SELECT * from journal where journal_id > 0">
		<cfif len(#journal_name#) gt 0>
			<cfset sql = "#sql# AND upper(journal_name) LIKE '%#ucase(journal_name)#%'">
		</cfif>
		<cfif len(#journal_abbreviation#) gt 0>
			<cfset sql = "#sql# AND upper(journal_abbreviation) LIKE '%#ucase(journal_abbreviation)#%'">
		</cfif>
		<cfif len(#publisher_name#) gt 0>
			<cfset sql = "#sql# AND upper(publisher_name) LIKE'%#ucase(publisher_name)#%'">
		</cfif>
		
		
		<cfquery name="getJournal" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(sql)#
		</cfquery>
		</cfoutput>
	
		<cfoutput query="getJournal">
						
		<br><a href="javascript: opener.document.#formName#.#journalIdFld#.value='#journal_id#';opener.document.#formName#.#journalNameFld#.value='#journal_name#';self.close();">#journal_name#</a>
		
			
		
		</cfoutput>
		
</cfif>
<cfinclude template="../includes/_pickFooter.cfm">