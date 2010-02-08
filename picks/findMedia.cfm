<cfinclude template="../includes/_pickHeader.cfm">
	<!--- make sure we're searching for something --->
	<cfif len(media_uri) is 0>
		<form name="searchForMedia" action="findMedia.cfm" method="post">
			<label for="media_uri">Media URI</label>
			<input type="text" name="media_uri" id="media_uri">
			<input type="submit" 
				value="Search" 
				class="lnkBtn">
			<cfoutput>
				<input type="hidden" name="mediaIdFld" value="#mediaIdFld#">
				<input type="hidden" name="mediaStringFld" value="#mediaStringFld#">
			</cfoutput>
		</form>
		<cfabort>
	</cfif>
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
				opener.document.getElementById('#pubIdFld#').value='#media_id#';
				opener.document.getElementById('#pubStringFld#').value='#media_uri#';
				opener.document.getElementById('#pubStringFld#').style.background='##8BFEB9';
				self.close();
			</script>
		<cfelse>
			<tr>
				<td>
					<a href="##" onClick="javascript: opener.document.getElementById('#pubIdFld#').value='#media_id#';
						opener.document.getElementById('#pubStringFld#').value='#media_uri#';
						opener.document.getElementById('#pubStringFld#').style.background='##8BFEB9';
						self.close();
						">#media_uri#</a>
				</td>
			</tr>
		</cfif>
	</cfloop>
	</table>
</cfif>
	</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">