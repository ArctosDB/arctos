<cfinclude template="../includes/_pickHeader.cfm">
<cfoutput>
	<cfif action is "nothing">
		<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select collection_id,collection from collection order by collection
		</cfquery>
		<form name="searchForAccn" action="findPublication.cfm" method="post">
			<input type="hidden" name="action" value="srch">
			<input type="hidden" name="AccnNumFld" value="#AccnNumFld#">
			<input type="hidden" name="AccnIdFld" value="#AccnIdFld#">
			<input type="hidden" name="formName" value="#formName#">
			<label for="collection_id">Collection</label>
			<select name="collection_id" id="collection_id">
				<option value=""></option>
				<cfloop query="ctcollection">
					<option value="#collection_id#">#collection#</option>
				</cfloop>
			</select>
			<label for="accn_number">Accn Number</label>
			<input type="text" name="accn_number" id="accn_number">
			<input type="submit" 
				value="Search" 
				class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'"
				onmouseout="this.className='lnkBtn'">
		</form>
	</cfif>
	<cfif action is "srch">
		<cfquery name="getAccn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				collection,
				accn_number,
				accn.transaction_id
			FROM
				accn,
				trans,
				collection
			WHERE
				accn.transaction_id=trans.transaction_id and
				trans.collection_id=collection.collection_id and
				<cfif len(collection_id) gt 0>
					collection.collection_id=#collection# and
				</cfif>
				upper(accn_number) like '%#ucase(accn_number)#%'
			ORDER BY
				collection,
				accn_number
		</cfquery>
		<cfif #getAccn.recordcount# is 0>
			Nothing matched. <a href="findAccn.cfm?formName=#formName#&AccnNumFld=#AccnNumFld#&AccnIdFld=#AccnIdFld#">Try again.</a>
		<cfelse>
			<table border>
				<tr>
					<td>Accn</td>
				</tr>
				<cfloop query="getPub">
					<cfif #getAccn.recordcount# is 1>
						<script>
							opener.document.#formName#.#AccnNumFld#.value='#collection# #accn_number#';
							opener.document.#formName#.#AccnIdFld#.value='#transaction_id#';
							opener.document.#formName#.#pubStringFld#.style.background='##8BFEB9';
							self.close();
						</script>
					<cfelse>
						<tr>
							<td>
								<a href="##" onClick="javascript: opener.document.#formName#.#AccnNumFld#.value='#collection# #accn_number#';
									opener.document.#formName#.#AccnIdFld#.value='#transaction_id#';self.close();">#collection# #accn_number#</a>
							</td>
						</tr>
					</cfif>
				</cfloop>
			</table>
		</cfif>
	</cfif>
</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">