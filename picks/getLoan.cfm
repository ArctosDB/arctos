<cfinclude template="/includes/_pickHeader.cfm">
	<cfif not isdefined("loan_number") or loan_number is 'undefined'>
		<cfset loan_number=''>
	</cfif>
	<cfif not isdefined("collection_id") or collection_id is 'undefined'>
		<cfset collection_id=''>
	</cfif>
	<!--- make sure we're searching for something --->
	<cfif len(loan_number) is 0>
		<form name="f" action="getLoan.cfm" method="post">
			<label for="collection_id">Collection</label>
			<input type="text" name="collection_id" id="collection_id">
			<label for="loan_number">Loan Number</label>
			<input type="text" name="loan_number" id="loan_number">
			<input type="submit" value="Search"	class="lnkBtn">
			<cfoutput>
				<input type="hidden" name="LoanIDFld" value="#mediaIdFld#">
				<input type="hidden" name="LoanNumberFld" value="#LoanNumberFld#">
			</cfoutput>
		</form>
		<cfabort>
	</cfif>
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT 
				media_id,
				media_uri
			FROM
				media
			WHERE
				UPPER(media_uri) LIKE '%#ucase(escapeQuotes(media_uri))#%'
			ORDER BY
				media_uri
		</cfquery>
		<cfif d.recordcount is 0>
			Nothing matched #media_uri#. <a href="findMedia.cfm?mediaIdFld=#mediaIdFld#&mediaStringFld=#mediaStringFld#">Try again.</a>
		<cfelse>
	<table border>
		<tr>
			<td>URI</td>
		</tr>
	<cfloop query="d">
		<cfif d.recordcount is 1>
			<script>
				opener.document.getElementById('#mediaIdFld#').value='#media_id#';
				opener.document.getElementById('#mediaStringFld#').value='#media_uri#';
				opener.document.getElementById('#mediaStringFld#').style.background='##8BFEB9';
				self.close();
			</script>
		<cfelse>
			<tr>
				<td>
					<a href="##" onClick="javascript: opener.document.getElementById('#mediaIdFld#').value='#media_id#';
						opener.document.getElementById('#mediaStringFld#').value='#media_uri#';
						opener.document.getElementById('#mediaStringFld#').style.background='##8BFEB9';
						self.close();
						">#media_uri#</a>
				</td>
			</tr>
		</cfif>
	</cfloop>
	</table>
</cfif>
	</cfoutput><cfinclude template="/includes/_pickFooter.cfm">