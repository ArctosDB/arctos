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
	<cffile action="upload"
		destination="#application.webDirectory#/temp/"
		nameConflict="overwrite"
		fileField="Form.FiletoUpload"
		accept="application/zip">
	<cfdump var=#form#>
	<cffile 
	   action = "rename"
	   source = "#application.webDirectory#/temp/#Form.FiletoUpload#"
	   destination = "zip_#session.username#.zip">

	File accepted. <a href="uploadMedia.cfm?action=unzip">Click to proceed.</a>
</cfif>
<cfif action is "unzip">
	unzip
</cfif>
<cfinclude template="/includes/_footer.cfm">
