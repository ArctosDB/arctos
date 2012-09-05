<cfinclude template="/includes/_pickHeader.cfm">
<cfoutput>
	<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select institution_acronym || ':' || collection_cde instccde from collection order by institution_acronym,collection_cde
	</cfquery>
	<cfif left(r_accnNumber,1) is "[" and r_accnNumber contains "]">
		<cfset InstAcrColnCde = rereplace(r_accnNumber,"^.*\[(.*)\].*$",'\1')>
		<cfset accnNumber = rereplace(r_accnNumber,"\[(.*)\]",'')>
	<cfelse>
		<cfset accnNumber=r_accnNumber>
		<cfset InstAcrColnCde=r_InstAcrColnCde>
	</cfif>
	<form name="searchForAccn" action="findAccn.cfm" method="get">
		<input type="hidden" name="rtnFldID" value="#rtnFldID#">
		<label for="InstAcrColnCde">Collection</label>
		<select name="InstAcrColnCde" id="InstAcrColnCde">
			<option value=""></option>
			<cfloop query="ctcollection">
				<option <cfif instccde is InstAcrColnCde> selected="selected" </cfif>value="#instccde#">#instccde#</option>
			</cfloop>
		</select>
		<label for="accnNumber">Accn Number</label>
		<input type="text" name="accnNumber" id="accnNumber" value="#accnNumber#">
		<input type="submit" value="Search"	class="lnkBtn">
	</form>
	<cfif len(accnNumber) gt 0>
		<cfquery name="getAccn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT 
				collection.institution_acronym || ':' || collection.collection_cde instccde,
				accn_number
			FROM
				accn,
				trans,
				collection
			WHERE
				accn.transaction_id=trans.transaction_id and
				trans.collection_id=collection.collection_id and
				<cfif len(InstAcrColnCde) gt 0>
					collection.institution_acronym || ':' || collection.collection_cde='#InstAcrColnCde#' and
				</cfif>
				upper(accn_number) like '%#ucase(accnNumber)#%'
			ORDER BY
				collection.institution_acronym,
				collection.collection_cde,
				accn_number
		</cfquery>
		<cfif getAccn.recordcount is 0>
			Nothing matched.
		<cfelse>
			<cfloop query="getAccn">
				<br><span class="likeLink" onClick="opener.document.getElementById('#rtnFldID#').value='[#instccde#]#accn_number#';self.close();">#instccde# #accn_number#</span>
			</cfloop>
		</cfif>
	</cfif>
</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">