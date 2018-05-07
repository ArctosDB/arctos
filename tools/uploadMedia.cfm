<cfinclude template="/includes/_header.cfm">
<cfset title="ZIP image uploader">
<!--- leave this link at the top of the page --->
<p>
	<a href="uploadMedia.cfm?action=preview">View Existing Jobs</a>
</p>


<!---
	https://github.com/ArctosDB/arctos/issues/1446
	1) make this asynchronous
	2) move Media to s3/corral

	create table cf_temp_zipload (
		zid number not null,
		username varchar2(255) not null,
		email  varchar2(255) not null,
		jobname  varchar2(255) not null,
		status  varchar2(255) not null
	);

	alter table cf_temp_zipload add submitted_date date;


	create public synonym cf_temp_zipload for cf_temp_zipload;

	grant insert,select on cf_temp_zipload to manage_media;


	-- processing table
	-- only UAM will interact; no synonyms necessary
	create table cf_temp_zipfiles (
		zid number not null,
		filename varchar2(255),
		new_filename varchar2(255),
		preview_filename varchar2(255),
		localpath varchar2(255),
		remotepath varchar2(255),
		status varchar2(255)
	);

	alter table cf_temp_zipfiles add new_filename varchar2(255);
	alter table cf_temp_zipfiles add preview_filename varchar2(255);
	alter table cf_temp_zipfiles add md5 varchar2(255);
	alter table cf_temp_zipfiles add mime_type varchar2(255);
	alter table cf_temp_zipfiles add media_type varchar2(255);
	alter table cf_temp_zipfiles add remote_preview varchar2(255);


	-- schedule



insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'mediazip_zip_unzip',
	'BulkloadMedia.cfm?action=zip_unzip',
	'600',
	'ZIP Media Loader: unzip the loaded archive',
	'every half-hour',
	'0',
	'7,37',
	'*',
	'*',
	'*',
	'?'
);

insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'mediazip_zip_rename',
	'BulkloadMedia.cfm?action=zip_rename',
	'600',
	'ZIP Media Loader: rename images from a recently-unzipped archives',
	'every half-hour',
	'0',
	'17,47',
	'*',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'mediazip_zip_rename_confirm',
	'BulkloadMedia.cfm?action=zip_rename_confirm',
	'600',
	'ZIP Media Loader: confirm renameprocess from mediazip_zip_rename',
	'every half-hour',
	'0',
	'27,57',
	'*',
	'*',
	'*',
	'?'
);

insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'mediazip_zip_makepreview',
	'BulkloadMedia.cfm?action=zip_makepreview',
	'600',
	'ZIP Media Loader: create thumbnails',
	'every half-hour',
	'0',
	'8,28',
	'*',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'mediazip_zip_makepreview_confirm',
	'BulkloadMedia.cfm?action=zip_makepreview_confirm',
	'600',
	'ZIP Media Loader: confirm creation of thumbnails',
	'every half-hour',
	'0',
	'18,38',
	'*',
	'*',
	'*',
	'?'
);

insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'mediazip_zip_s3ify',
	'BulkloadMedia.cfm?action=zip_s3ify',
	'600',
	'ZIP Media Loader: load to server via S3',
	'every half-hour',
	'0',
	'28,48',
	'*',
	'*',
	'*',
	'?'
);


insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'mediazip_zip_s3ify_confirm',
	'BulkloadMedia.cfm?action=zip_s3ify_confirm',
	'600',
	'ZIP Media Loader: confirm load to server via S3',
	'every half-hour',
	'0',
	'9,29',
	'*',
	'*',
	'*',
	'?'
);



insert into cf_crontab (
	job_name,
	path,
	timeout,
	purpose,
	run_interval_desc,
	cron_sec,
	cron_min,
	cron_hour,
	cron_dom,
	cron_mon,
	cron_dow
) values (
	'mediazip_zip_notify_done',
	'BulkloadMedia.cfm?action=zip_notify_done',
	'600',
	'ZIP Media Loader: Notify user of results',
	'every half-hour',
	'0',
	'19,39',
	'*',
	'*',
	'*',
	'?'
);



--->
<br><a href="uploadMedia.cfm?action=nothing">splashpage</a>

<!-------------------------------------


<cffunction name="makeMBLDownloadFile">
	 <cfargument name="zid" required="true" type="numeric"/>
	 <cfquery name="f" datasource="uam_god">
		select * from cf_temp_zipfiles where zid=#zid#
	</cfquery>
	<cfset q=QueryNew("TEMP_original_filename, TEMP_new_filename,MEDIA_URI,MIME_TYPE,MEDIA_TYPE,PREVIEW_URI,media_license,media_label_1,media_label_value_1")>
	<cfloop query="f">
		<cfset queryaddrow(q,
				{
				TEMP_original_filename=filename,
				TEMP_new_filename=new_filename,
				MEDIA_URI=remotepath,
				MIME_TYPE=mime_type,
				MEDIA_TYPE=media_type,
				PREVIEW_URI=remote_preview,
				media_license='',
				media_label_1='MD5 checksum',
				media_label_value_1=md5
				}
			)>
	</cfloop>
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset csv = util.QueryToCSV2(Query=q,Fields=q.columnlist)>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/media_bulk_zip#zid#.csv"
    	output = "#csv#"
    	addNewLine = "no">
</cffunction>

----------------------------------------------------------->



<!------------------------------------------------------------------------------------------------>

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