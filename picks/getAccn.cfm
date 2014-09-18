<cfinclude template="/includes/_pickHeader.cfm">
<!------------


		use findAccn for data entry
		
		
------------>
<cfoutput>
	<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select guid_prefix,collection_id from collection order by guid_prefix
	</cfquery>
	<form name="searchForAccn" action="getAccn.cfm" method="get">
		<label for="collectionID">Collection</label>
		<select name="collectionID" id="collectionID">
			<option value=""></option>
			<cfloop query="ctcollection">
				<option <cfif collectionID is collection_id> selected="selected" </cfif>value="#collection_id#">#guid_prefix#</option>
			</cfloop>
		</select>
		<label for="accnNumber">Accn Number</label>
		<input type="text" name="accnNumber" id="accnNumber" value="#accnNumber#">
		<input type="submit" value="Search"	class="lnkBtn">
	</form>
	<cfif len(accnNumber) gt 0>
		<cfquery name="getAccn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT 
				collection.guid_prefix,
				collection.collection_id,
				accn_number
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
				collection.guid_prefix,
				accn_number
		</cfquery>
		<cfif getAccn.recordcount is 0>
			Nothing matched.
		<cfelse>
			<cfloop query="getAccn">
				<br><span class="likeLink" onClick="opener.document.getElementById('accn_number').value='#accn_number#';opener.document.getElementById('collection_id').value='#collection_id#';self.close();">#guid_prefix# #accn_number#</span>
			</cfloop>
		</cfif>
	</cfif>
</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">