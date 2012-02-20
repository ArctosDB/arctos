<cfinclude template="/includes/_header.cfm">

<cfform name="atts" method="post" enctype="multipart/form-data">
	<input type="hidden" name="Action" value="getFile">
	<input type="file" name="FiletoUpload" size="45">
	<input type="submit" value="Upload this file" class="savBtn">
  </cfform>
<cfif action is "getFile">
	<cfif listlast(FiletoUpload,".") is not "csv">
		only csv allowed.
	</cfif>
	
	
	<cffile action="upload"
    	destination="#Application.webDirectory#/temp/"
      	nameConflict="overwrite"
      	fileField="Form.FiletoUpload" mode="777">
	<cfset fileName=cffile.serverfile>
	<cfif isValidMediaUpload(fileName) is not "pass">
		<cfoutput>
		#isValidMediaUpload(fileName)#
		</cfoutput>
		<cfabort>
	</cfif>
	
	
	
	<cfdump var=#cffile#>
	<cfdump var=#form#>
</cfif>