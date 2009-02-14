<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Pick Higher Geog">
<cfif len(#geogString#) is 0>
	You must enter search criteria.
	<cfabort>
</cfif>
<cfset hg = replace(geogString,"'","''","all")>
	<cfset sql = "select 
		GEOG_AUTH_REC_ID,
		HIGHER_GEOG
		from 
		geog_auth_rec WHERE 
		upper(HIGHER_GEOG) LIKE '%#ucase(hg)#%'
		ORDER BY HIGHER_GEOG">
	
<cfquery name="getGeog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(sql)#
</cfquery>
<cfif #getGeog.recordcount# is 1>
	<cfoutput>
		<cfset thisName = #replace(getGeog.HIGHER_GEOG,"'","\'","all")#>
		<script>
			opener.document.#formName#.#geogIdFld#.value='#getGeog.GEOG_AUTH_REC_ID#';
			opener.document.#formName#.#geogStringFld#.value='#thisName#';
			opener.document.#formName#.#geogStringFld#.style.background='##8BFEB9';
			self.close();
		</script>
	 </cfoutput>
	<cfelseif #getGeog.recordcount# is 0>
		<cfoutput>
			Nothing matched #geogString#. <a href="javascript:void(0);" onClick="opener.document.#formName#.#geogIdFld#.value='';opener.document.#formName#.#geogStringFld#.value='';opener.document.#formName#.#geogStringFld#.focus();self.close();">Try again.</a>
		</cfoutput>
		
	<cfelse>
	<script>
		window.resizeTo(700,400);
	</script>
	<table border>
		<cfoutput query="getGeog">
		<tr>
			<cfset thisName = #replace(getGeog.HIGHER_GEOG,"'","\'","all")#>
			<td nowrap="nowrap">
				<a href="##" onClick="javascript: opener.document.#formName#.#geogIdFld#.value='#GEOG_AUTH_REC_ID#';opener.document.#formName#.#geogStringFld#.value='#thisName#';opener.document.#formName#.#geogStringFld#.style.background='##8BFEB9';self.close();">#HIGHER_GEOG#</a>
			</td>
		</tr>
	</cfoutput>
	</table>
	</cfif>

<cfinclude template="../includes/_pickFooter.cfm">