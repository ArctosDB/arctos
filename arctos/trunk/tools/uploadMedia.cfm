<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
	Step One: Upload a ZIP file containing images. Anything else will be rejected.
	<cfform name="atts" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" size="45">
		<input type="submit" value="Upload this file" class="savBtn">
  </cfform>
</cfif>
<cfif action is "getFile">
	<cftry>
		<cfdirectory action="create" directory="#application.webDirectory#/temp/#session.username#">
		<cfcatch><!--- exists ---></cfcatch>
	</cftry>
	<cffile action="upload"
		destination="#application.webDirectory#/temp/#session.username#"
		nameConflict="overwrite"
		fileField="Form.FiletoUpload"
		accept="application/zip"
			mode="777">
	<cfdump var=#form#>
	<cfdump var=#cffile#>
	


	File accepted. <a href="uploadMedia.cfm?action=unzip">Click to proceed.</a>
</cfif>
<cfif action is "unzip">
	
	unzip
</cfif>
<cfinclude template="/includes/_footer.cfm">
