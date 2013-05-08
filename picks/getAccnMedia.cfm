<cfinclude template="/includes/_pickHeader.cfm">
<!------------


		use findAccn for data entry
		
		
------------>
<cfoutput>
	<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collection,collection_id from collection order by institution_acronym,collection_cde
	</cfquery>
	<form name="searchForAccn" action="getAccnMedia.cfm" method="get">
		<input type="hidden" name="idOfTxtFld" value="#idOfTxtFld#">
		<input type="hidden" name="idOfPKeyFld" value="#idOfPKeyFld#">
		
		<label for="collectionID">Collection</label>
		<select name="collectionID" id="collectionID">
			<option value=""></option>
			<cfloop query="ctcollection">
				<option value="#collection_id#">#collection#</option>
			</cfloop>
		</select>
		<label for="accnNumber">Accn Number</label>
		<input type="text" name="accnNumber" id="accnNumber">
		<input type="submit" value="Search"	class="lnkBtn">
	</form>
	<cfif isdefined("accnNumber") and len(accnNumber) gt 0>
		<cfquery name="getAccn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT 
				collection.collection,
				collection.collection_id,
				accn_number,
				accn.accn_id
			FROM
				accn,
				trans,
				collection
			WHERE
				accn.transaction_id=trans.transaction_id and
				trans.collection_id=collection.collection_id and
				<cfif len(collectionID) gt 0>
					collection.collection_id=#collectionID# and
				</cfif>
				upper(accn_number) like '%#ucase(accnNumber)#%'
			ORDER BY
				collection.collection,
				accn_number
		</cfquery>
		<cfif getAccn.recordcount is 0>
			Nothing matched.
		<cfelse>
			<cfloop query="getAccn">
				<br><span class="likeLink" onClick="opener.document.getElementById('#idOfTxtFld#').value='#accn_number#';opener.document.getElementById('#idOfPKeyFld#').value='#accn_id#';self.close();">#collection# #accn_number#</span>
			</cfloop>
		</cfif>
	</cfif>
</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">