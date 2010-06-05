<cfinclude template="/includes/_header.cfm">
<cfset goodExtensions="jpg">

<cfif action is "nothing">
	Step One: Upload a ZIP file containing images. Anything else will be rejected. 
	<br>File extensions are not case sensitive, but must be in #goodExtensions#.
	<br>File names may not start with _ (underbar) or . (dot).
	<br>You may need to load smaller batches if you get timeout errors.
	<br>You may include thumbnails, which should be JPG files prefixed with "tn_", or you may create them with this app.
	Do not click the "create thumbnails" option when you get to it if you've uploaded thumbnails.
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
	
	You can now <a href="uploadMedia.cfm?action=preview">preview your files</a> or <a href="uploadMedia.cfm?action=thumb">create thumbnails</a>
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
			<cfimage action="resize" source="#directory#/#name#" width="#newwidth#" height="#newheight#" 
				destination="#application.webDirectory#/temp/#session.username#/tn_#name#" overwrite="yes">
		</cfif>
	</cfloop>
	thumbnails created.
	<a href="uploadMedia.cfm?action=preview">Preview your files</a>
	<br>
	</cfoutput>



</cfif>
<cfif action is "preview">
	<cfquery name="ctmedia_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select media_type from ctmedia_type order by media_type
	</cfquery>
	<cfquery name="ctmime_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select mime_type from ctmime_type order by mime_type
	</cfquery>
	
	<cfdirectory action="LIST"
    	directory="#application.webDirectory#/temp/#session.username#"
        name="dir"
		recurse="yes">
	<cfoutput>
		<form name="f" method="post" action="uploadMedia.cfm">
		<table border>
			<tr>
				<td>Attributes</td>
				<td>image</td>
			</tr>
		<cfset i=1>
	<cfloop query="dir">
		
		<cfif listfindnocase(goodExtensions,listlast(name,".")) and left(name,1) is not "_" and left(name,1) is not "." and left(name,3) is not "tn_">
			
			<cfset webpath=replace(directory,application.webDirectory,application.serverRootUrl) & "/" & name>
			<cfquery name="thumb" dbtype="query">
				select * from dir where name='tn_#name#'
			</cfquery>
			<cfset tnwebpath="">
			<cfif thumb.recordcount is 1>
				<cfset tnwebpath=replace(thumb.directory,application.webDirectory,application.serverRootUrl) & "/" & thumb.name>
			</cfif>
			
			<tr>
			<td>
				<cfif len(tnwebpath) gt 0>
					<img src="#tnwebpath#">
				<cfelse>
					NO THUMBNAIL
				</cfif>
				<!---
				<br>TempImageId: #i#
				<input type="text" value="#tnwebpath#" name="tnwebpath_#i#" id="nwebpath_#i#">
				<input type="text" value="#webpath#" name="webpath_#i#" id="webpath_#i#">
				<label for="created_by_agent_#i#">Create By Agent</label>
				<input type="text" name="created_by_agent_#i#" id="created_by_agent_#i#" value="#session.username#" >
				<input type="text" name="created_by_agent_id_#i#" id="created_by_agent_id_#i#" value="#session.myagentid#" >
				<label for="description_#i#">Description</label>
				<input type="text" name="description_#i#" id="description_#i#" value="">
				<cfset thisMediaType="image">
				<label for="media_type_#i#">Media Type</label>
				<select name="media_type_#i#" id="media_type_#i#" >
					<cfloop query="ctmedia_type">
						<option <cfif thisMediaType is media_type> selected="selected"</cfif> value="#media_type#">#media_type#</option>
					</cfloop>
				</select>
				<cfset thisMimeType="image/jpeg">
				<label for="mime_type_#i#">MIME Type</label>
				<select name="mime_type_#i#" id="mime_type_#i#" >
					<cfloop query="ctmime_type">
						<option <cfif thisMimeType is mime_type> selected="selected"</cfif> value="#mime_type#">#mime_type#</option>
					</cfloop>
				</select>
		
			
				--->
			</td>
			<td>
			<img src="#webpath#">
			</td>
			

			<td>
				
			</td>
			</tr>
			<cfset i=i+1>
		</cfif>		
	</cfloop>
	</table>
	</form>
	</cfoutput>
</cfif>
<cfif action is "webserver">
webserver
</cfif>
<cfinclude template="/includes/_footer.cfm">
