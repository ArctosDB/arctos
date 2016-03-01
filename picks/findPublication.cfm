<cfinclude template="../includes/_pickHeader.cfm">
<cfoutput>
	<!--- make sure we're searching for something --->
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
	<cfif len(publication_title) gt 0>
		<cfquery name="getPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				publication_id,
				full_citation,
				short_citation
			FROM
				publication
			WHERE
				UPPER(regexp_replace(full_citation,'<[^>]*>')) LIKE '%#ucase(escapeQuotes(publication_title))#%'
			ORDER BY
				full_citation
		</cfquery>
		<cfif getPub.recordcount is 0>
			Nothing matched #publication_title#. <a href="findPublication.cfm?formName=#formName#&pubIdFld=#pubIdFld#&pubStringFld=#pubStringFld#">Try again.</a>
		<cfelseif getPub.recordcount is 1>
			<script>
				opener.document.#formName#.#pubIdFld#.value='#publication_id#';
				opener.document.#formName#.#pubStringFld#.value='#jsescape(short_citation)#';
				opener.document.#formName#.#pubStringFld#.style.background='##8BFEB9';
				self.close();
			</script>
		<cfelse>
			<table border>
				<tr>
					<td>Title</td>
				</tr>
				<cfloop query="getPub">
					<cfif

					<cfelse>
						<tr>
							<td>
								<a href="##" onClick="javascript: opener.document.#formName#.#pubIdFld#.value='#publication_id#';
									opener.document.#formName#.#pubStringFld#.value='#jsescape(full_citation)#';self.close();">#short_citation#</a>
							</td>
						</tr>
					</cfif>
				</cfloop>
			</table>
		</cfif>
	</cfif>
</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">