<cfinclude template="/includes/_frameHeader.cfm">
<cfif #action# is "nothing">
	<form name="uploadFile" method="post" enctype="multipart/form-data" action="upMedia.cfm">
		<input type="hidden" name="action" value="getFile">
		  <label for="FiletoUpload">Browse...</label>
		  <input type="file" name="FiletoUpload" id="FiletoUpload" size="45">
   
      <input type="submit" 
				value="Upload" 
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'"
				onmouseout="this.className='savBtn'">
	<input type="button" 
				value="Cancel" 
				class="qutBtn"
				onmouseover="this.className='qutBtn btnhov'"
				onmouseout="this.className='qutBtn'"
				onclick="closeUpload()">
	</form>
</cfif>
<cfif #action# is "getFile">
<cfoutput>
	<cfquery name="validExtension" datasource="#application.web_user#">
		select media_type from ctmedia_type
	</cfquery>
	<cffile action="upload"
    	destination="#Application.webDirectory#/temp/"
      	nameConflict="overwrite"
      	fileField="Form.FiletoUpload" mode="777">
	<cfset fileName=#cffile.serverfile#>
	<cfset dotPos=find(".",fileName)>
	<cfset name=left(fileName,dotPos-1)>
	<cfset extension=right(fileName,len(fileName)-dotPos+1)>
	<cfif REFind("[^A-Za-z0-9_]",name,1) gt 0>
		<font color="##FF0000" size="+2">The filename (<strong>#fileName#</strong>) you entered contains characters that are not alphanumeric.
		Please rename your file and try again.</font>
		<a href="javascript:back()">Go Back</a>
		<cfabort>   
	</cfif>
	<!----This name contains only alphanumeric characters, check the extension---->
	<cfset ext=right(extension,len(extension)-1)>
	<cfif REFind("[^A-Za-z]",ext,1) gt 0>
		The extension you provided contains inappropriate characters.
		Please rename your file and <a href="javascript:back()">try again</a>.
		<cfabort>
	</cfif>
	<cfset goodExtensions=valuelist(validExtension.media_type)>
	<cfif not listfindnocase(goodExtensions,ext,",")>
		The extension you provided is not acceptable. Acceptable extensions are: #goodExtensions#
		Please <a href="/info/bugs.cfm">file a bug report</a> if you feel that this message is in error, or
		<a href="javascript:back()">try again</a>.
		<cfabort>
	</cfif>
	<cfset loadPath = "#Application.webDirectory#/mediaUploads/#client.username#">
	<cftry>
		<cfdirectory action="create" directory="#loadPath#">
		<cfcatch><!--- it already exists, do nothing---></cfcatch>
	</cftry>
	<cfset media_uri = "#Application.ServerRootUrl#/mediaUploads/#client.username#/#fileName#">
	<cffile action="move"
		source="#Application.webDirectory#/temp/#fileName#" 
    	destination="#loadPath#"
      	nameConflict="error">
	
<script>closeUpload('#media_uri#');</script>
</cfoutput>
</cfif>
 
	  
	  
 	<!---<cffile action="write" file="#filename#" nameconflict="overwrite" output="blank" mode="777">--->
    
