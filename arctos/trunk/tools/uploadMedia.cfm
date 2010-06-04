<cfinclude template="/includes/_header.cfm">
<cfset goodExtensions="jpg">

<cfif action is "nothing">
	Step One: Upload a ZIP file containing images. Anything else will be rejected. 
	<br>File extensions are not case sensitive, but must be in #goodExtensions#.
	<br>File names may not start with _ (underbar) or . (dot).
	<br>You may need to load smaller batches if you get timeout errors.
	<br><a href="/contact.cfm">Contact us</a> if you need something else.
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
	<cfoutput>
	The following files were extracted:
	<cfloop query="dir">
		<cfif listfindnocase(goodExtensions,listlast(name,".")) and left(name,1) is not "_" and left(name,1) is not ".">
			<cfset s=round(size/1024)>
			<br>#name# (#s#k)
		</cfif>
	</cfloop>
	
	<br>
	
	You can now <a href="uploadMedia.cfm?action=webserver">move the files to the public webserver</a> or <a href="uploadMedia.cfm?action=thumb">create thumbnails</a>
	</cfoutput>
</cfif>
<cfif action is "thumb">
	<cfdirectory action="LIST"
    	directory="#application.webDirectory#/temp/#session.username#"
        name="dir"
		recurse="yes">
	<cfoutput>
	<cfloop query="dir">
		<cfif listfindnocase(goodExtensions,listlast(name,".")) and left(name,1) is not "_" and left(name,1) is not ".">
			
			<cfimage action="info" structname="imagetemp" source="#directory#/#name#">
			<cfset x=min(150/imagetemp.width, 113/imagetemp.height)>
			<cfset newwidth = x*imagetemp.width>
			<cfset newheight = x*imagetemp.height>
			<cfimage action="resize" source="#directory#/#name# width="#newwidth#" height="#newheight#" 
				destination="#directory#" name="tn_#name#">
		</cfif>
	</cfloop>
	
	</cfoutput>



</cfif>
<cfif action is "webserver">
webserver
</cfif>
<cfinclude template="/includes/_footer.cfm">
