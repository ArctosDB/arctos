<cfinclude template="/includes/_header.cfm">
<cfset goodExtensions="jpg,png">
<cfset baseWebDir="#application.serverRootURL#/mediaUploads/#session.username#/#dateformat(now(),'yyyy-mm-dd')#">
<cfset baseFileDir="#application.webDirectory#/mediaUploads/#session.username#/#dateformat(now(),'yyyy-mm-dd')#">
<cfset sandboxdir="#application.sandbox#/#session.username#">


<cfif action is "nothing">
	This form allows you to upload a ZIP archive containing images, extract the images, create thumbnails, preview the
	results, load the images to Arctos, and download a Media Bulkloader template containing the URIs of the images you loaded.
	<p>
	Step One: Upload a ZIP file containing images..
	<br>File extensions are not case sensitive, but must be in
	( <cfoutput>#goodExtensions#</cfoutput> ).
	<br>File names may contain only A-Za-z0-9 and not start with _ (underbar) or . (dot).
	<br>You may need to load smaller batches if you get timeout errors. You can start over at any time without breaking anything.
	The number of files that will work is dependant on file format and file size. 25 medium-sized JPGs works easily.
	(Please let us know what does and does not work for you.)
	<a href="/contact.cfm">Contact us</a> or use other means to get your Media to the web if that's not practical.
	<br>You may include thumbnails, which should be JPG files prefixed with "tn_", or you may create them with this app.
	Do not click the "create thumbnails" option when you get to it if you've uploaded thumbnails in your ZIP.
	<br><a href="/contact.cfm">Contact us</a> if you need something else.
	<form name="atts" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<label for="FiletoUpload">Upload a ZIP file</label>
		<input type="file" name="FiletoUpload" size="45">
		<input type="submit" value="Upload this file" class="savBtn">
  </form>
</cfif>
<cfif action is "getFile">
	<cftry>
		<cfdirectory action="delete" directory="#sandboxdir#" recurse="true">
		<br>deleted temp dir...
		<cfcatch><!--- exists --->
			<br>could not delete temp dir...
		</cfcatch>
	</cftry>

	<cftry>
		<cfdirectory action="create" directory="#sandboxdir#" mode="766">
		<br>created temp dir...
		<cfcatch><br>could not create temp dir...<!--- exists ---></cfcatch>
	</cftry>
	<cffile action="upload"	destination="#sandboxdir#/" nameConflict="overwrite" fileField="Form.FiletoUpload" mode="600">
	<cffile
	    action = "rename"
	    nameConflict="overwrite"
	    destination = "#sandboxdir#/temp.zip"
	    source = "#sandboxdir#/#cffile.ClientFile#">

	Upload complete. <a href="uploadMedia.cfm?action=unzip">Continue to unzip</a>.
</cfif>
<cfif action is "unzip">
	<cfzip file="#sandboxdir#/temp.zip" action="unzip"
		destination="#sandboxdir#/"/>
	<cfdirectory action="LIST" directory="#sandboxdir#" name="dir" recurse="no">

	<cfoutput>
	The following files were extracted:
	<table border>
		<tr>
			<th>Filename</th>
			<th>KB</th>
			<th>Status</th>
		</tr>
	<cfloop query="dir">
		<cfset s=round(size/1024)>
		<tr>
			<td>#name#</td>
			<td>#s#</td>
			<td>
				<cfif type is "File" and
					listlen(name,".") is 2 and
					listfindnocase(goodExtensions,listlast(name,".")) and
					left(name,1) is not "_" and
					left(name,1) is not "." and
					REfind("[^A-Za-z0-9_]",listgetat(name,1,".")) eq 0>
					Acceptable - processing
				<cfelse>
					Unacceptable - DELETING....
					<cfif type is "file">
				 		<cffile action="DELETE" file="#sandboxdir#/#name#">
					<cfelse>
						<cfdirectory action="DELETE" recurse="true" directory="#sandboxdir#/#name#">
					</cfif>
					deleted
				</cfif>
			</td>
		</tr>
	</cfloop>
	</table>
	You can now <a href="uploadMedia.cfm?action=thumb">create thumbnails</a>, or skip to
	<a href="uploadMedia.cfm?action=webserver">moving your files to the webserver</a> if you don't need thumbs.
	<p>
		Rename and reload if anything useful was deleted above.
	</p>
	</cfoutput>
</cfif>


<cfif action is "thumb">
	<cfdirectory action="LIST" directory="#sandboxdir#" name="dir" recurse="yes">
	<cfoutput>
	<cfloop query="dir">
		<cfif listfindnocase(goodExtensions,listlast(name,".")) and left(name,1) is not "_" and left(name,1) is not ".">
			<cfimage action="info" structname="imagetemp" source="#directory#/#name#">
			<cfset x=min(150/imagetemp.width, 113/imagetemp.height)>
			<cfset newwidth = x*imagetemp.width>
			<cfset newheight = x*imagetemp.height>
			<cfimage action="resize" source="#sandboxdir#/#name#" width="#newwidth#" height="#newheight#"
				destination="#sandboxdir#/tn_#name#" overwrite="yes">
		</cfif>
	</cfloop>
	Thumbnails created.
	<a href="uploadMedia.cfm?action=webserver">Continue to move your files to the webserver</a>.
	</cfoutput>
</cfif>

<cfif action is "webserver">
	<!----
		we have to do this before we can preview.
		Everything up until this point has happened in the sandbox,
		and users cannot acccess anything in the sandbox directly.
		The steps above should have deleted anything even slightly wonky or dangerous, so
		make a daily directory and rock on.
	---->
<cfoutput>
	<cftry>
		<cfdirectory action="create" directory="#baseFileDir#">
		<cfcatch><!--- exists ---></cfcatch>
	</cftry>
	<cfdirectory action="LIST" directory="#sandboxdir#" name="dir" recurse="no">
	<cfloop query="dir">
		<br>moving #name# to #finalpath#/#name#
		<cffile action="move" source="#sandboxdir#/#name#" destination="#baseFileDir#/#name#">
	</cfloop>
	<p>
		<br>Your files are now on the webserver.
		<br><a href="uploadMedia.cfm?action=preview">Preview them here</a>.
		<br>If the above looks wrong, you can <a href="uploadMedia.cfm?action=deleteTodayDir">delete your #dateformat(now(),'yyyy-mm-dd')# directory</a>
		from the webserver. CAUTION: This deletes EVERYTHING you've loaded today.

	</p>
	<!-----
	<cfdirectory action="LIST" directory="#finalpath#" name="final">
	<cfset variables.fileName="#Application.webDirectory#/download/BulkMediaTemplate_#session.username#.csv">
	<cfset variables.encoding="US-ASCII">
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		a='media_uri,media_type,mime_type,preview_uri,media_relationships,media_labels';
		variables.joFileWriter.writeLine(a);
	</cfscript>
	<cfloop query="final">
		<cfif left(name,3) is not "tn_">
			<cfquery name="thumb" dbtype="query">
				select * from final where name='tn_#name#'
			</cfquery>
			<cfset tnwebpath="">
			<cfif thumb.recordcount is 1>
				<cfset tnwebpath=replace(thumb.directory,application.webDirectory,application.serverRootUrl) & "/" & thumb.name>
			</cfif>
			<cfset muri=replace(directory,application.webDirectory,application.serverRootUrl) & "/" & name>
			<cfset mimetype="image/jpeg">
			<cfset mediatype="image">
			<cfscript>
				a='"' & muri  & '","' & mediatype & '","' & mimetype & '","' & tnwebpath & '","",""';
				variables.joFileWriter.writeLine(a);
			</cfscript>
		</cfif>
	</cfloop>
	<cfscript>
		variables.joFileWriter.close();
	</cfscript>
	<br>Your uploads are now on the webserver. You may now
	<a href="/download.cfm?file=BulkMediaTemplate_#session.username#.csv">download the CSV template</a>,
	fill in relationships and labels, and load it through <a href="/tools/BulkloadMedia.cfm">Media Bulkloader</a>
	<br>Images will be deleted 7 days after they are uploaded if they have not been used in Media
		by that time.
		----->
</cfoutput>
</cfif>




<cfif action is "preview">
	<cfoutput>
		<p>
			NOTE: This lists everything from your today-directory. You may need to delete or ignore some stuff.
		</p>
		<p>
			Click on a few links and make sure everything looks OK before proceeding.
		</p>

		<cfdirectory action="LIST" directory="#baseFileDir#" name="dir" recurse="yes">
		<table border>
			<tr>
				<td>thumb</td>
				<td>image URL</td>
			</tr>
			<cfloop query="dir">
				<cfif left(name,3) is not "tn_">
					<cfquery name="thumb" dbtype="query">
						select * from dir where name='tn_#name#'
					</cfquery>


					<tr>
						<td>
							<cfif thumb.recordcount gt 0>
								<img src="#baseWebDir#/#thumb.name#">
							<cfelse>
								NO THUMBNAIL
							</cfif>
						</td>
						<td>
							<a href="#baseWebDir#/#name#" target="_blank">#baseWebDir#/#name#</a>
						</td>
					</tr>
				</cfif>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<cfif action is "deleteTodayDir">
	<cfdirectory action="LIST" directory="#application.webDirectory#/mediaUploads/#session.username#/#dateformat(now(),'yyyy-mm-dd')#" name="dir" recurse="yes">
	<cfdump var=#dir#>
	<br><a href="uploadMedia.cfm?action=reallyDeleteTodayDir">Seriously, delete everything in the table above!</a>
</cfif>

<cfif action is "reallyDeleteTodayDir">
	<cfdirectory action="LIST" directory="#application.webDirectory#/mediaUploads/#session.username#/#dateformat(now(),'yyyy-mm-dd')#" name="dir" recurse="yes">
	<cfloop query="dir">
		<cfset fp="#application.serverRootURL#/mediaUploads/#session.username#/#dateformat(now(),'yyyy-mm-dd')#/#name#">
		<cfquery name="d" datasource="uam_god">
			select count(*) c from media where media_uri='#fp#' or preview_uri='#fp#'
		</cfquery>
		<cfif d.c is not 0>
			<cfoutput>
				<br>#fp# is used in Media and cannot be deleted.
			</cfoutput>
			<cfabort>
		</cfif>
	</cfloop>
	<cfloop query="dir">
		<cfif type is "file">
			<cffile action="DELETE" file="#DIRECTORY#/#name#">
		<cfelse>
			<cfdirectory action="DELETE" recurse="true" directory="#DIRECTORY#/#name#">
		</cfif>
	</cfloop>
	<p>
		All gone. <a href="uploadMedia.cfm">Try again.</a>
	</p>
</cfif>
<cfinclude template="/includes/_footer.cfm">