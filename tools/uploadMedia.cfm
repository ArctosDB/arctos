<cfinclude template="/includes/_header.cfm">
<cfset title="ZIP image uploader">
<!--- leave this link at the top of the page --->

<br><a href="uploadMedia.cfm?action=preview">View Existing Jobs</a>
<br><a href="uploadMedia.cfm?action=nothing">splashpage</a>
<!------------------------------------------------------------------------------------------------>
<cfif action is "nothing">
	<script>
		function checkZIP() {
		    var filePath,ext;

		    filePath = $("#FiletoUpload").val();
		    ext = filePath.substring(filePath.lastIndexOf('.') + 1).toLowerCase();
		    if(ext != 'zip') {
		        alert('Only files with the file extension ZIP are allowed');
		        return false;
		    } else {
		        return true;
		    }
		}
	</script>
	<cfoutput>
		<p>
			Upload a ZIP archive of image files. Arctos will attempt to move them to an archival file server, create thumbnail/previews, and
			email you a media bulkloader template.
		</p>
		<p>
			The single-image file loader available from various nodes is probably more convenient for very small batches. Contact us
			if it's not available or suitable.
		</p>
		<p>
			 <span class="helpLink" data-helplink="tacc_scp">SCP to TACC</span> is preferred for large uploads.
		</p>
		<ul>
			<li>Only .jpg, .jpeg, and .png (case-insensitive) files will be accepted. File an Issue with expansion requests.</li>
			<li>Files which start with _ (underbar) or . (dot) will be ignored.</li>
			<li>Filenames containing characters other than A-Z, a-z, and 0-9 will be changed.</li>
			<li>The ZIP must contain only image files. Do not ZIP a folder; it will be ignored.</li>
			<li>
				The process usually completes within hours, but backlog is possible. Contact us (referencing job name) if you do not receive email within 24 hours.
			</li>
			<li>
				You will receive an email containing a link to a file when the process is done. That file will be deleted 3 days after the message is
				sent, but may be regenerated from the "existing jobs" link above.
			</li>
			<li>
				The "directory" option of the media bulkloader may be more useful than the supplied file if you need to extract data from filenames.
			</li>
		</ul>
		<cfquery name="addr" datasource="uam_god">
			select get_Address(#session.myagentid#,'email') addr from dual
		</cfquery>
		<form name="mupl" method="post" enctype="multipart/form-data" action="uploadMedia.cfm" onsubmit="return checkZIP();">
			<input type="hidden" name="action" value="getFile">
			<label for ="username">Username</label>
			<input name="username" class="reqdClr" required value="#session.username#">
			<label for ="email">Email</label>
			<input name="email" class="reqdClr" required value="#addr.addr#">
			<label for ="jobname">Job Name (must be unique; any string is OK; used to keep track of this batch)</label>
			<input name="jobname" class="reqdClr" required value="#CreateUUID()#">
			<label for="FiletoUpload">Upload a ZIP file</label>
			<input type="file" name="FiletoUpload" id="FiletoUpload" size="45">
			<input type="submit" value="Upload this file" class="savBtn">
	  </form>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "getFile">
	<!---- temp directory is good for 3 days, should be plenty ---->
	<!--- first insert - will guarantee a unique job name ---->
	<cfoutput>
		<cfquery name="cjob" datasource="uam_god">
			insert into cf_temp_zipload (
				zid,
				username,
				email,
				jobname,
				status,
				submitted_date
			) values (
				somerandomsequence.nextval,
				'#username#',
				'#email#',
				'#jobname#',
				'new',
				sysdate
			)
		</cfquery>
		<!--- get the ID we just used for a file name---->
		<cfquery name="jid" datasource="uam_god">
			select zid from cf_temp_zipload where jobname='#jobname#'
		</cfquery>
		<!---- now upload the ZIP ---->
		<cffile action="upload"	destination="#Application.webDirectory#/temp/#jid.zid#.zip" nameConflict="overwrite" fileField="Form.FiletoUpload" mode="600">
		<p>
			Your ZIP has been loaded and a job created. You will receive email from Arctos referencing job #jobname#. Do not delete the ZIP file until you
			have confirmed that all of your data are on Corral.
		</p>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "regen_download">
	<cfoutput>
		<cfset utilities = CreateObject("component","component.utilities")>
		<cfset utilities.makeMBLDownloadFile(#zid#)>

		<p>
			Generation attempted: #Application.serverRootURL#/download/media_bulk_zip#zid#.csv
		</p>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "preview">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_zipload where username='#session.username#' order by submitted_date desc
		</cfquery>
		<cfif d.recordcount is 0>
			You have no jobs.<cfabort>
		</cfif>
		<a name="top"></a>
		<p>
			Summary
		</p>
		<cfloop query="d">
			<blockquote>
				<br>Job Name: #JOBNAME#
				<br>Submitted Date: #submitted_date#
				<br>Status: #STATUS#
				<br><a href="###d.zid#">Scroll To</a>
			</blockquote>
		</cfloop>
		<cfloop query="d">
			<hr>
			<a name="#d.zid#" href="##top">Scroll Top</a>
			<br>Job Name: #JOBNAME#
			<br>Submitted Date: #submitted_date#
			<br>Status: #STATUS#
			<br><a href="uploadMedia.cfm?action=regen_download&zid=#d.zid#">Regenerate Download File</a>
			<cfquery name="f" datasource="uam_god">
				select * from cf_temp_zipfiles where zid=#d.zid#
			</cfquery>
			<table border>
				<tr>
					<th>STATUS</th>
					<th>FILENAME</th>
					<th>NEW_FILENAME</th>
					<th>PREVIEW_FILENAME</th>
					<th>REMOTEPATH</th>
					<th>REMOTE_PREVIEW</th>
					<th>MIME_TYPE</th>
					<th>MEDIA_TYPE</th>
					<th>MD5</th>
				</tr>
				<cfloop query="f">
					<tr>
						<td>#STATUS#</td>
						<td>#FILENAME#</td>
						<td>#NEW_FILENAME#</td>
						<td>#PREVIEW_FILENAME#</td>
						<td>
							<a href="#REMOTEPATH#" target="_blank">#REMOTEPATH#</a>
						</td>
						<td>
							<a href="#REMOTE_PREVIEW#" target="_blank">#REMOTE_PREVIEW#</a>
						</td>
						<td>#MIME_TYPE#</td>
						<td>#MEDIA_TYPE#</td>
						<td>#MD5#</td>
					</tr>
				</cfloop>
			</table>
		</cfloop>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">