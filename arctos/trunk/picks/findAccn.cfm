<cfinclude template="/includes/_pickHeader.cfm">
<!------------


		this form works for data entry only!!
		
		
------------>
<cfoutput>
	<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select guid_prefix instccde from collection order by guid_prefix
	</cfquery>
	<cfif not isdefined("r_accnNumber")>
		<cfset r_accnNumber=''>
	</cfif>
	<cfif not isdefined("r_InstAcrColnCde")>
		<cfset r_InstAcrColnCde=''>
	</cfif>
	<cfif left(r_accnNumber,1) is "[" and r_accnNumber contains "]">
		<cfset InstAcrColnCde = rereplace(r_accnNumber,"^.*\[(.*)\].*$",'\1')>
		<cfset accnNumber = rereplace(r_accnNumber,"\[(.*)\]",'')>
	<cfelseif isdefined("r_accnNumber") and not isdefined("accnNumber")>
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
				collection.guid_prefix instccde,
				accn_number
			FROM
				accn,
				trans,
				collection
			WHERE
				accn.transaction_id=trans.transaction_id and
				trans.collection_id=collection.collection_id and
				<cfif len(InstAcrColnCde) gt 0>
					collection.guid_prefix='#InstAcrColnCde#' and
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
				<br><span class="likeLink" onClick="opener.document.getElementById('#rtnFldID#').value='[#instccde#]#accn_number#';self.close();">[#instccde#]#accn_number#</span>
			</cfloop>
		</cfif>
	</cfif>
</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">