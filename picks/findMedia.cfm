<cfinclude template="../includes/_pickHeader.cfm">
	<cfparam name="media_uri" default="">
	<cfparam name="media_id" default="">
	<cfif media_uri is 'undefined'>
		<cfset media_uri=''>
	</cfif>
		<cfoutput>
	<!--- make sure we're searching for something --->
	<cfif len(media_uri) is 0>
		<form name="searchForMedia" action="findMedia.cfm" method="post">
			<label for="media_uri">Media URI</label>
			<input type="text" name="media_uri" id="media_uri" value="#media_uri#">
			<label for="media_id">Media ID</label>
			<input type="text" name="media_id" id="media_id" value="#media_id#">
			<input type="submit" value="Search" class="lnkBtn">
			<cfoutput>
				<input type="hidden" name="mediaIdFld" value="#mediaIdFld#">
				<input type="hidden" name="mediaStringFld" value="#mediaStringFld#">
			</cfoutput>
		</form>
		<cfabort>
	</cfif>
	<cfif len(media_id) is 0 and len(media_uri) is 0>
		<cfabort>
	</cfif>

		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				media_id,
				media_uri,
				preview_uri,
				media_type
			FROM
				media
			WHERE
				1=1
				<cfif len(media_uri) gt 0>
					and UPPER(media_uri) LIKE '%#ucase(escapeQuotes(media_uri))#%'
				</cfif>
				<cfif len(media_id) gt 0>
					and media_id=#media_id#
				</cfif>
			ORDER BY
				media_uri
		</cfquery>
		<cfdump var=#d#>
		<cfif d.recordcount is 0>
			Nothing matched.
		<cfelse>
	<table border>
		<tr>
			<td>
				Preview
			</td>
			<td>URI</td>
		</tr>
		<cfset  func = CreateObject("component","component.functions")>

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
					<cfset mp = func.getMediaPreview(preview_uri="#preview_uri#",media_type="#media_type#")>
					<img src="#mp#" style="max-width:150px;max-height:150px;">
				</td>
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
	</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">