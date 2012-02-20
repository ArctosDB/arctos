<cfinclude template="/includes/_header.cfm">

<cfdirectory action="create" directory="/corral/tg/uaf/arctos_uploads/">
woot

<cfabort>

<cfform name="atts" method="post" enctype="multipart/form-data">
	<input type="hidden" name="Action" value="getFile">
	<input type="file" name="FiletoUpload" size="45">
	<input type="submit" value="Upload this file" class="savBtn">
  </cfform>

<cfoutput>
<cfif action is "getFile">
	<cfif listlast(FiletoUpload,".") is not "csv">
		only csv allowed.
	</cfif>
	
	
	<cffile action="upload"
    	destination="/corral/tg/uaf/arctos_uploads/"
      	nameConflict="overwrite"
      	fileField="Form.FiletoUpload" mode="777">
	<cfset fileName=cffile.serverfile>
	===#isValidMediaUpload(fileName)#===
	<cfif len(isValidMediaUpload(fileName)) gt 0>
		failed
		<cfabort>
	</cfif>
	passed
	------------------------------------------
	
	
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
	
	
	
	<cfdump var=#cffile#>
	<cfdump var=#form#>
</cfif>


		</cfoutput>
