<cfinclude template="/includes/_frameHeader.cfm">
<cfif #action# is "nothing">
	<div id="progressbar" style="display:none" align="center">
		Uploading Media....<br><img src="/images/progressbar.gif">
	</div>
	<div id="formDiv">
	<form name="uploadFile" method="post" enctype="multipart/form-data" action="upMedia.cfm">
		<input type="hidden" name="action" value="getFile">
		  <label for="FiletoUpload">Browse your drive for Media....</label>
		  <input type="file" name="FiletoUpload" id="FiletoUpload" size="90" >
          <label for="PreviewToUpload">Browse for Thumbnail - leave blank to attempt auto create</label>
		  <input type="file" name="PreviewToUpload" id="PreviewToUpload" size="90">
   			<br>
      <input type="button" 
				value="Upload" 
				class="savBtn"
				onclick="this.value='Loading....';document.getElementById('formDiv').style.display='none';document.getElementById('progressbar').style.display='';uploadFile.submit();">
	<input type="button" 
				value="Cancel" 
				class="qutBtn"
				onclick="parent.removeUpload('')">
	</form>
	</div>
</cfif>
<cfif action is "getFile">
<cfoutput>
	<cftry>
	<cffile action="upload"	destination="#Application.sandbox#/" nameConflict="overwrite" 
		fileField="Form.FiletoUpload" mode="600">
	<cfset fileName=cffile.serverfile>
	<cfset fext=listlast(fileName,".")>
	<cfset fName=listdeleteat(fileName,listlen(filename,'.'),'.')>
	<cfset fName=REReplace(fName,"[^A-Za-z0-9_$]","_","all")>
	    
	    <br>fName...#fName#
	<cfif len(isValidMediaUpload(fileName)) gt 0>
		#isValidMediaUpload(fileName)#
		<cfabort>
	</cfif>
	
	buhbye<cfabort>
	<cfset loadPath = "#Application.webDirectory#/mediaUploads/#session.username#">
	<cftry>
		<cfdirectory action="create" directory="#loadPath#" mode="755">
		<cfcatch><!--- it already exists, do nothing---></cfcatch>
	</cftry>
	<cfset media_uri = "#Application.ServerRootUrl#/mediaUploads/#session.username#/#fileName#">
	<cffile action="move" source="#Application.sandbox#/#fileName#" 
		destination="#loadPath#" nameConflict="error" mode="644">
    
	<cfif len(PreviewToUpload) gt 0>
        <cffile action="upload"
	    	destination="#Application.sandbox#/"
	      	nameConflict="overwrite"
	      	fileField="Form.PreviewToUpload" mode="600">
	    <cfset fileName=cffile.serverfile>
	    
	    <cfset fileName=REReplace(fileName,"[^A-Za-z0-9_$]","_","all")>
	    
	    <br>filename...#fileName#
	    <cfif len(isValidMediaPreview(fileName)) gt 0>
			#isValidMediaPreview(fileName)#
			<cfabort>
		</cfif>
        <cftry>
			<cfdirectory action="create" directory="#loadPath#" mode="644">
			<cfcatch><!--- it already exists, do nothing---></cfcatch>
		</cftry>
        <cffile action="move"
			source="#Application.sandbox#/#fileName#" 
	    	destination="#loadPath#"
	      	nameConflict="error"
	      	mode="644">
        <cfset preview_uri = "#Application.ServerRootUrl#/mediaUploads/#session.username#/#fileName#">
    <cfelse>
         <cfset preview_uri = "">
    </cfif>
	<cfcatch>
		<font color="##FF0000" size="+2">Error: #cfcatch.message# #cfcatch.detail#</font>
			<a href="javascript:back()">Go Back</a>
			<cfabort>   
	</cfcatch>
	</cftry>
	<cfif IsImageFile("#loadPath#/#fileName#")>
		<cfif len(preview_uri) is 0>
			<cfset tnAbsPath=loadPath & '/tn_' & fileName>
			<cfset tnRelPath=replace(loadPath,application.webDirectory,'') & '/tn_' & fileName> 
			<cfset preview_uri = "#Application.ServerRootUrl#/mediaUploads/#session.username#/tn_#fileName#">
			<cfimage action="info" structname="imagetemp" source="#loadPath#/#fileName#">
			<cfset x=min(180/imagetemp.width, 180/imagetemp.height)>
			<cfset newwidth = x*imagetemp.width>
      		<cfset newheight = x*imagetemp.height>
   			<cfimage action="resize" source="#loadPath#/#fileName#" width="#newwidth#" height="#newheight#"
				destination="#tnAbsPath#" overwrite="true">
			<cfset tnAbsPath=loadPath & '/tn_' & fileName>
			<cfset tnRelPath=replace(loadPath,application.webDirectory,'') & '/tn_' & fileName> 
			<cfset preview_uri = "#Application.ServerRootUrl#/mediaUploads/#session.username#/tn_#fileName#">
			<table>
				<tr>
					<td>
						<img src="#tnRelPath#">
					</td>
					<td valign="top">
						<span class="likeLink" onclick="parent.closeUpload('#media_uri#','#preview_uri#');">Use this thumbnail as a preview</span>
						<br><span class="likeLink" onclick="parent.closeUpload('#media_uri#','');">Do not use this thumbnail as a preview</span>
					</td>
				</tr>
			</table>			
		<cfelse>
			<script>parent.closeUpload('#media_uri#','#preview_uri#');</script>
			<span onclick="parent.closeUpload('#media_uri#','#preview_uri#');">Click here</span>
		</cfif>
	<cfelse>
		<script>parent.closeUpload('#media_uri#','#preview_uri#');</script>
		<span onclick="parent.closeUpload('#media_uri#','#preview_uri#');">Click here</span>
	</cfif>
</cfoutput>
</cfif>