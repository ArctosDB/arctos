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
				<input type="hidden" name="LoanIDFld" value="#LoanIDFld#">
				<input type="hidden" name="LoanNumberFld" value="#LoanNumberFld#">
			</cfoutput>
		</form>
		<cfabort>
	</cfif>
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT 
				guid_prefix,
				loan_number,
				loan.transaction_id
			FROM
				collection,
				trans,
				loan
			WHERE
				collection.collection_id=trans.collection_id and
				trans.transaction_id=loan.transaction_id and
				UPPER(loan.loan_number) LIKE '%#ucase(escapeQuotes(loan_number))#%'
				<cfif len(collection_id) gt 0>
					and trans.collection_id=#collection_id#
				</cfif>
			ORDER BY
				guid_prefix,loan_number
		</cfquery>
		<cfif d.recordcount is 0>
			Nothing matched #loan_number#. 
			<!----<a href="getLoan.cfm?mediaIdFld=#mediaIdFld#&mediaStringFld=#mediaStringFld#">Try again.</a>---->
		<cfelse>
	<table border>
		<tr>
			<td>Loan</td>
		</tr>
	<cfloop query="d">
		<cfif d.recordcount is 1>
			<script>
				opener.document.getElementById('#LoanIDFld#').value='#transaction_id#';
				opener.document.getElementById('#LoanNumberFld#').value='#guid_prefix# #loan_number#';
				opener.document.getElementById('#LoanNumberFld#').style.background='##8BFEB9';
				self.close();
			</script>
		<cfelse>
			<tr>
				<td>
					<a href="##" onClick="javascript: opener.document.getElementById('#LoanIDFld#').value='#transaction_id#';
						opener.document.getElementById('#LoanNumberFld#').value='#guid_prefix# #loan_number#';
						opener.document.getElementById('#LoanNumberFld#').style.background='##8BFEB9';
						self.close();
						">#guid_prefix# #loan_number#</a>
				</td>
			</tr>
		</cfif>
	</cfloop>
	</table>
</cfif>
</cfoutput><cfinclude template="/includes/_pickFooter.cfm">