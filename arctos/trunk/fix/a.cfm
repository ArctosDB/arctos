<cfinclude template="/includes/_header.cfm">

<!---
<cftry>
	<cffile action="delete" file="/corral/tg/uaf/wwwarctos/sandbox/test.png">
    	<br>deleted file
<cfcatch>ffff</cfcatch>
</cftry>

	<cfdirectory action="delete" directory="/corral/tg/uaf/wwwarctos/sandbox">
	<br>deleted dir
	
	
<br>create dir
--->
<cfset Application.sandbox="/corral/tg/uaf/wwwarctos/sandbox">
okeedokee


<form name="atts" method="post" enctype="multipart/form-data">
	<input type="hidden" name="Action" value="getFile">
	<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this)">
	<input type="submit" value="Upload this file" class="savBtn">
  </form>

<cfoutput>
<cfif action is "getFile">
<cfdump var=#FiletoUpload#><cfdump var=#form#>
<cffile action="upload"
    	destination="#Application.sandbox#"
      	nameConflict="overwrite"
      	fileField="Form.FiletoUpload" 
		mode="600">
<cfset fileName=cffile.serverfile>
	<cfif len(isValidCSV(fileName)) gt 0>
		<div class="error">#isValidCSV(fileName)#</div>
		<cfabort>
	</cfif>
	
	reading....
<cffile action="READ" file="#Application.sandbox#/#cffile.serverFile#" variable="fileContent">
	
	
	skippy<cfabort>
	
	
	
	
	
	<cffile action="upload"
    	destination="#Application.sandbox#"
      	nameConflict="overwrite"
      	fileField="Form.FiletoUpload" mode="600">
	
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	
	<cfset fileName=cffile.serverfile>
	===#isValidCSV(fileName)#===
	<cfif len(isValidCSV(fileName)) gt 0>
		failed
		<cfabort>
	</cfif>
	
	
	
	<cfif lcase(listLast(cffile.serverfile,".")) is not "csv">
		<br>not csv <cfabort>
	</cfif>
	<br>is .csv
	<cfif REFind("^([^;]*;)+[^;]*$", fileContent) is 1>
		<br>doesnt look like csv - abort<cfabort>
	</cfif>
	
	
	<br>uploaded file.........
	

		

	
	 
	 ----------<cfdump var=#LooksLikeCSV#>-----------

	loaded it to sandbox...
	<cfdirectory action="list" name="x" directory="/corral/tg/uaf/wwwarctos/sandbox">
<cfdump var=#x#>


<cfabort>


	
	<cffile action="upload"
    	destination="#Application.webDirectory#/temp/"
      	nameConflict="overwrite"
      	fileField="Form.FiletoUpload" mode="777">
	
	loaded it to #Application.webDirectory#/temp/
	
	listing webdir/temp
	
	<cfdirectory name="w" action="list" directory="#Application.webDirectory#/temp/">
	<cfdump var=#w#>
	
	listing sandbox
	
	<cfdirectory name="s" action="list" directory="/opt/coldfusion8/tmp/">
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
