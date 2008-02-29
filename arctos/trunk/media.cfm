<cfinclude template="/includes/_header.cfm">
<cfif #action# is "newMedia">
	<cfoutput>
		<form name="newMedia" method="post" action="media.cfm">
			<input type="hidden" name="action" value="saveNew">
			<label for="media_uri">Media URI</label>
			<input type="text" name="media_uri" id="media_uri" size="50">
		</form>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">