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
	
<cffile 
    action = "rename"
    destination = "#application.webDirectory#/temp/#session.username#/temp.zip" 
    source = "#application.webDirectory#/temp/#session.username#/#cffile.ClientFile#">


	File accepted. <a href="uploadMedia.cfm?action=unzip">Click to proceed.</a>
</cfif>
<cfif action is "unzip">
	<cfzip file="#application.webDirectory#/temp/#session.username#/temp.zip" action="unzip" destination="#application.webDirectory#/temp/#session.username#/"/>
	<cfdirectory action="LIST"
    	directory="#application.webDirectory#/temp/#session.username#"
        name="dir"
		recurse="yes">
	<cfloop query="dir">
		#name#
	</cfloop>
	unzip
</cfif>
<cfinclude template="/includes/_footer.cfm">
