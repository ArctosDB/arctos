<cfinclude template="/includes/_frameHeader.cfm">
<cfif #action# is "nothing">
	<form name="uploadFile" method="post" enctype="multipart/form-data" action="upMediaPreview.cfm">
		<input type="hidden" name="action" value="getFile">
		  <label for="PreviewToUpload">Preview...</label>
		  <input type="file" name="PreviewToUpload" id="PreviewToUpload" size="90">
   
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
				onclick="parent.closeUpload('')">
	</form>
</cfif>
<cfif #action# is "getFile">
<cfoutput>
	<cfset loadPath = "#Application.webDirectory#/mediaUploads/#session.username#">
	<cftry>
		<cfdirectory action="create" directory="#loadPath#">
		<cfcatch><!--- it already exists, do nothing---></cfcatch>
	</cftry>
    <cfif len(#PreviewToUpload#) gt 0>
	
	
	
        <cffile action="upload"
	    	destination="#Application.webDirectory#/temp/"
	      	nameConflict="overwrite"
	      	fileField="Form.PreviewToUpload" mode="777">
	      	
       <cfif (CFFILE.FileSize GT (15 * 1024))>
        	Preview may not be larger than 15K. Resize the preview image, or leave it blank to autogenerate.
			<cfabort>
        </cfif>
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
        <cfset acceptablePreviewExtensions=".jpg,.jpeg,.gif,.png">
	    <cfif not listfindnocase(acceptablePreviewExtensions,extension)>
            <span class="error">
                Preview extension (#extension#) must be one of:
                #acceptablePreviewExtensions# 
            </span>
            <cfabort>
        </cfif>
        <cftry>
			<cfdirectory action="create" directory="#loadPath#">
			<cfcatch><!--- it already exists, do nothing---></cfcatch>
		</cftry>
        <cffile action="move"
			source="#Application.webDirectory#/temp/#fileName#" 
	    	destination="#loadPath#"
	      	nameConflict="error">
        <cfset preview_uri = "#Application.ServerRootUrl#/mediaUploads/#session.username#/#fileName#">
    <cfelse>
         <cfset preview_uri = "">
    </cfif>
	
<script>parent.closePreviewUpload('#preview_uri#');</script>
</cfoutput>
</cfif>
 
	  
	  
 	<!---<cffile action="write" file="#filename#" nameconflict="overwrite" output="blank" mode="777">--->
    
