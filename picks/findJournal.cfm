<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Journal pick">
 
 
 
	<!--- make sure we're searching for something --->
	<cfif  len(#journalName#) is 0>
		You must enter search criteria.
		<cfabort>
	</cfif>
	<cfoutput>
	Select a journal:
	<p>&nbsp;</p>
		<cfset sql = "SELECT * from journal where journal_id > 0">
		<cfif len(#journalName#) gt 0>
			<cfset sql = "#sql# AND upper(journal_name) LIKE '%#ucase(journalName)#%'">
		</cfif>	
		
		<cfquery name="getJournal" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(sql)#
		</cfquery>
		</cfoutput>
	
		<cfoutput query="getJournal">
						
		<br><a href="javascript: opener.document.#formName#.#journalIdFld#.value='#journal_id#';opener.document.#formName#.#journalNameFld#.value='#journal_name#';self.close();">#journal_name#</a>
		
			
		
		</cfoutput>
		
<cfinclude template="../includes/_pickFooter.cfm">