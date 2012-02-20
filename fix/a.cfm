<cfinclude template="/includes/_header.cfm">



<cfform name="atts" method="post" enctype="multipart/form-data">
	<input type="hidden" name="Action" value="getFile">
	<input type="file" name="FiletoUpload" size="45">
	<input type="submit" value="Upload this file" class="savBtn">
  </cfform>

<cfoutput>
<cfif action is "getFile">

	
	
	<cffile action="upload"
    	destination="/corral/tg/uaf/sandbox/"
      	nameConflict="overwrite"
      	fileField="Form.FiletoUpload" mode="777">
	
	loaded it to sandbox...
	
	<cffile action="upload"
    	destination="#Application.webDirectory#/temp/"
      	nameConflict="overwrite"
      	fileField="Form.FiletoUpload" mode="777">
	
	loaded it to #Application.webDirectory#/temp/
	
	listing webdir/temp
	
	<cfdirectory name="w" action="list" directory="#Application.webDirectory#/temp/">
	<cfdump var=#w#>
	
	listing sandbox
	
	<cfdirectory name="s" action="list" directory="/corral/tg/uaf/sandbox/">
	<cfdump var=#s#>
	
	
	<!--------
	<cfset fileName=cffile.serverfile>
	===#isValidMediaUpload(fileName)#===
	<cfif len(isValidMediaUpload(fileName)) gt 0>
		failed
		<cfabort>
	</cfif>
	passed
	------------------------------------------
		<cfif listlast(FiletoUpload,".") is not "csv">
		only csv allowed.
	</cfif>
	/corral/tg/uaf/arctos_uploads/
	<cfset msg="">
	
	
	<cfset extension=listlast(fileName,".")>
	<cfset acceptExtensions="jpg,jpeg,gif,png,pdf,txt,m4v,mp3">
	
	
	--listfindnocase(acceptExtensions,extension)--#listfindnocase(acceptExtensions,extension)#
	<cfif listfindnocase(acceptExtensions,extension) is 0>
		<cfset msg="An valid file name extension is required. extension=#extension#">
	</cfif>
	
	<cfset name=replace(fileName,".#extension#","")>
	name==#name#
	<cfif REFind("[^A-Za-z0-9_-]",name,1) gt 0>
		<cfset msg="Filenames may contain only letters, numbers, dash, and underscore.">
	</cfif>
------------------#msg#---------------	
	
	
	/corral/tg/uaf/arctos_uploads/
	
	
	<cfdump var=#cffile#>
	<cfdump var=#form#>
	
	
	_----->
</cfif>


		</cfoutput>
