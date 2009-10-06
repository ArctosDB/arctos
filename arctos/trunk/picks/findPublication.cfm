<cfinclude template="../includes/_pickHeader.cfm">
	<!--- make sure we're searching for something --->
	<cfif len(publication_title) is 0>
		<form name="searchForPub" action="findPublication.cfm" method="post">
			<label for="publication_title">Publication Title</label>
			<input type="text" name="publication_title" id="publication_title">
			<input type="submit" 
				value="Search" 
				class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'"
				onmouseout="this.className='lnkBtn'">
			<cfoutput>
				<input type="hidden" name="pubIdFld" value="#pubIdFld#">
				<input type="hidden" name="pubStringFld" value="#pubStringFld#">
				<input type="hidden" name="formName" value="#formName#">
			</cfoutput>
		</form>
		<cfabort>
	</cfif>
	<cfoutput>
		<cfquery name="getPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				publication_id,
				formatted_publication
			FROM
				formatted_publication
			WHERE
				UPPER(regexp_replace(formatted_publication,'<[^>]*>')) LIKE '%#ucase(escapeQuotes(publication_title))#%'and
				format_style='long'
			ORDER BY
				formatted_publication
		</cfquery>
		<cfif #getPub.recordcount# is 0>
			Nothing matched #publication_title#. <a href="findPublication.cfm?formName=#formName#&pubIdFld=#pubIdFld#&pubStringFld=#pubStringFld#">Try again.</a>
		<cfelse>
	<table border>
		<tr>
			<td>Title</td>
		</tr>
	<cfloop query="getPub">
		<cfif #getPub.recordcount# is 1>
			<script>
				opener.document.#formName#.#pubIdFld#.value='#publication_id#';
				opener.document.#formName#.#pubStringFld#.value=escape('#formatted_publication#');
				opener.document.#formName#.#pubStringFld#.style.background='##8BFEB9';
				self.close();
			</script>
		<cfelse>
			<tr>
				<td>
					<a href="##" onClick="javascript: opener.document.#formName#.#pubIdFld#.value='#publication_id#';
						opener.document.#formName#.#pubStringFld#.value=escape('#formatted_publication#');self.close();">#formatted_publication#</a>
				</td>
			</tr>
		</cfif>
	</cfloop>
	</table>
</cfif>
	</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">