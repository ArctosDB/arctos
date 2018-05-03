<cfinclude template="/includes/_header.cfm">
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
--->
<cfset goodExtensions="jpg,png">
<cfset baseWebDir="#application.serverRootURL#/mediaUploads/#session.username#/#dateformat(now(),'yyyy-mm-dd')#">
<cfset baseFileDir="#application.webDirectory#/mediaUploads/#session.username#/#dateformat(now(),'yyyy-mm-dd')#">
<cfset sandboxdir="#application.sandbox#/#session.username#">



reset

delete from cf_temp_zipfiles;
update cf_temp_zipload set status='new';
<hr>
This form is under redevelopment.

cfabort


<p></p>

<br>thisform
<br>s1: <a href="uploadMedia.cfm?action=nothing">nothing</a>
<br>s2: getFile (submit f. nothing)
<br>will schedule
<br><a href="uploadMedia.cfm?action=unzip">unzip</a>
<!---- unzip is either going to work or not - no confirmation ---->
<br><a href="uploadMedia.cfm?action=rename">rename</a>
<br><a href="uploadMedia.cfm?action=rename_confirm">rename_confirm</a>




<br><a href="uploadMedia.cfm?action=mkprvw">mkprvw</a>
<br><a href="uploadMedia.cfm?action=mkprvw_confirm">mkprvw_confirm</a>


<br><a href="uploadMedia.cfm?action=s3ify">s3ify</a>
<br><a href="uploadMedia.cfm?action=s3ify_confirm">s3ify_confirm</a>



<br><a href="uploadMedia.cfm?action=notify_done">notify_done</a>


<br><a href="uploadMedia.cfm?action=preview">preview</a>


<hr>


<!------------------------------------------------------------------------------------------------>
<cfif action is "notify_done">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_zipload where status not like 'complete_email_sent%' and rownum=1
		</cfquery>
		<cfif d.recordcount is 0>
			found nothing<cfabort>
		</cfif>

		<cfdump var=#d#>

		<cfif d.status contains "FATAL ERROR">
			Dear #d.username#,

			Your image zip upload job #d.jobname# has failed with error

			#d.status#

			Please review the instructions on the upload page, and contact us if you need assistance to resolve the problem.

			<cfquery name="r" datasource="uam_god">
				update cf_temp_zipload set status='complete_email_sent - ' || status where zid=#d.zid#
			</cfquery>

		<cfelse>




			<cfquery name="f" datasource="uam_god">
				select * from cf_temp_zipfiles where zid=#d.zid#
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

			<cfdump var=#q#>

			<cfset  util = CreateObject("component","component.utilities")>
			<cfset csv = util.QueryToCSV2(Query=q,Fields=q.columnlist)>
			<cffile action = "write"
			    file = "#Application.webDirectory#/download/media_bulk_zip#d.zid#.csv"
		    	output = "#csv#"
		    	addNewLine = "no">


			Dear #d.username#,

			Your image zip upload job #d.jobname# is complete.

			A file is available at #application.serverRootUrl#/download/media_bulk_zip#d.zid#.csv. This file will be deleted in three days; please download
			it immediately.

			The file is NOT ready to upload in the media bulkloader.

			* TEMP_original_filename is the filename as supplied.

			* TEMP_new_filename is the filename as loaded.

			Please delete these columns before attempting upload.

			Instructions for adding columns or data are available from the Media Bulkloader.


			<cfquery name="r" datasource="uam_god">
				update cf_temp_zipload set status='complete_email_sent' where zid=#d.zid#
			</cfquery>

		</cfif>

	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "s3ify">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_zipload where status='previewed' and rownum=1
		</cfquery>
		<cfif d.recordcount is 0>
			found nothing<cfabort>
		</cfif>
		<cfquery name="s3" datasource="uam_god" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
			select S3_ENDPOINT,S3_ACCESSKEY,S3_SECRETKEY from cf_global_settings
		</cfquery>

		<!---- make a username bucket. This will create or return an error of some sort. ---->
		<cfset currentTime = getHttpTimeString( now() ) />
		<cfset contentType = "text/html" />
		<cfset bucket="#d.username#">
		<cfset stringToSignParts = [
			    "PUT",
			    "",
			    contentType,
			    currentTime,
			    "/" & bucket
			] />
		<cfset stringToSign = arrayToList( stringToSignParts, chr( 10 ) ) />
		<cfset signature = binaryEncode(
			binaryDecode(
				hmac( stringToSign, s3.s3_secretKey, "HmacSHA1", "utf-8" ),
				"hex"
			),
			"base64"
		)>
		<cfhttp result="mkunamebkt"  method="put" url="#s3.s3_endpoint#/#bucket#">
			<cfhttpparam type="header" name="Authorization" value="AWS #s3.s3_accesskey#:#signature#"/>
		    <cfhttpparam type="header" name="Content-Type" value="#contentType#" />
		    <cfhttpparam type="header" name="Date" value="#currentTime#" />
		</cfhttp>


		<cfquery name="f" datasource="uam_god">
			select * from cf_temp_zipfiles where zid=#d.zid# and status='previewed' and rownum=1
		</cfquery>
		<cfloop query="f">
			<cffile variable="content" action="readBinary" file="#Application.webDirectory#/temp/#d.zid#/#new_filename#">
			<cfset lmd5 = createObject("component","includes.cfc.hashBinary").hashBinary(content)>
			<cfquery name="ckck" datasource="uam_god">
				select media_id from media_labels where MEDIA_LABEL='MD5 checksum' and LABEL_VALUE='#md5#'
			</cfquery>
			<cfif ckck.recordcount gt 0>
				<cfquery name="fail" datasource="uam_god">
					update cf_temp_zipload set status='FATAL ERROR: #new_filename# exists as #Application.serverRootURL#/media/#ckck.media_id#' where zid=#d.zid#
				</cfquery>
				<cfbreak>
			</cfif>
			<cfset fext=listlast(new_filename,".")>
			<cfif fext is "jpg" or fext is "jpeg">
				<cfset mimetype="image/jpeg">
				<cfset mediatype="image">
			<cfelseif fext is "dng">
				<cfset mimetype="image/dng">
				<cfset mediatype="image">
			<cfelseif fext is "pdf">
				<cfset mimetype="application/pdf">
				<cfset mediatype="text">
			<cfelseif fext is "png">
				<cfset mimetype="image/png">
				<cfset mediatype="image">
			<cfelseif fext is "txt">
				<cfset mimetype="text/plain">
				<cfset mediatype="text">
			<cfelseif fext is "wav">
				<cfset mimetype="audio/x-wav">
				<cfset mediatype="audio">
			<cfelseif fext is "m4v">
				<cfset mimetype="video/mp4">
				<cfset mediatype="video">
			<cfelseif fext is "tif" or fext is "tiff">
				<cfset mimetype="image/tiff">
				<cfset mediatype="image">
			<cfelseif fext is "mp3">
				<cfset mimetype="audio/mpeg3">
				<cfset mediatype="audio">
			<cfelseif fext is "mov">
				<cfset mimetype="video/quicktime">
				<cfset mediatype="video">
			<cfelseif fext is "xml">
				<cfset mimetype="application/xml">
				<cfset mediatype="text">
			<cfelseif fext is "wkt">
				<cfset mimetype="text/plain">
				<cfset mediatype="text">
			<cfelse>
				<cfquery name="fail" datasource="uam_god">
					update cf_temp_zipload set status='FATAL ERROR: Mime/Media Type unknown for #new_filename#' where zid=#d.zid#
				</cfquery>
				<cfbreak>
			</cfif>
			<cfset bucket="#d.username#/#dateformat(now(),'YYYY-MM-DD')#">
			<cfset currentTime = getHttpTimeString( now() ) />
			<cfset contentType=mimetype>
			<cfset contentLength=arrayLen( content )>
			<cfset stringToSignParts = [
			    "PUT",
			    "",
			    contentType,
			    currentTime,
			    "/" & bucket & "/" & new_filename
			] />

			<cfset stringToSign = arrayToList( stringToSignParts, chr( 10 ) ) />
			<cfset signature = binaryEncode(
				binaryDecode(
					hmac( stringToSign, s3.s3_secretKey, "HmacSHA1", "utf-8" ),
					"hex"
				),
				"base64"
			)>
			<cfhttp result="putfile" method="put" url="#s3.s3_endpoint#/#bucket#/#new_filename#">
				<cfhttpparam type="header" name="Authorization" value="AWS #s3.s3_accesskey#:#signature#"/>
			    <cfhttpparam type="header" name="Content-Length" value="#contentLength#" />
			    <cfhttpparam type="header" name="Content-Type" value="#contentType#"/>
			    <cfhttpparam type="header" name="Date" value="#currentTime#" />
			    <cfhttpparam type="body" value="#content#" />
			</cfhttp>
			<cfset media_uri = "https://web.corral.tacc.utexas.edu/arctos-s3/#bucket#/#new_filename#">



			<!---- load thumbnail ---->
			<cfset bucket="#session.username#/#dateformat(now(),'YYYY-MM-DD')#/tn">
			<cfset currentTime = getHttpTimeString( now() ) />
			<cfset contentType = "image/jpeg" />
			<cffile variable="content" action = "readBinary" file="#Application.webDirectory#/temp/#d.zid#/tn/#preview_filename#">
			<cfset contentLength=arrayLen( content )>
			<cfset stringToSignParts = [
			    "PUT",
			    "",
			    contentType,
			    currentTime,
			    "/" & bucket & "/" & preview_filename
			] />
			<cfset stringToSign = arrayToList( stringToSignParts, chr( 10 ) ) />
			<cfset signature = binaryEncode(
				binaryDecode(
					hmac( stringToSign, s3.s3_secretKey, "HmacSHA1", "utf-8" ),
					"hex"
				),
				"base64"
			)>
			<cfhttp result="putTN" method="put" url="#s3.s3_endpoint#/#bucket#/#preview_filename#">
				<cfhttpparam type="header" name="Authorization" value="AWS #s3.s3_accesskey#:#signature#"/>
			    <cfhttpparam type="header" name="Content-Length"  value="#contentLength#" />
			    <cfhttpparam type="header" name="Content-Type"  value="#contentType#" />
			    <cfhttpparam type="header" name="Date" value="#currentTime#" />
			    <cfhttpparam type="body" value="#content#" />
			</cfhttp>
			<cfset preview_uri = "https://web.corral.tacc.utexas.edu/arctos-s3/#bucket#/#preview_filename#">
		<!--- statuscode of putting the actual file - the important thing--->


			<cfquery name="lldd" datasource="uam_god">
				update cf_temp_zipfiles set
					md5='#lmd5#',
					remotepath='#media_uri#',
					mime_type='#mimetype#',
					media_type='#mediatype#',
					remote_preview='#preview_uri#',
					status='loaded_to_s3'
				where
					new_filename='#new_filename#'
			</cfquery>



		</cfloop>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------>

<cfif action is "s3ify_confirm">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_zipload where status='previewed' and rownum=1
		</cfquery>
		<cfif d.recordcount lt 1>
			nope<cfabort>
		</cfif>
		<cfquery name="d_f" datasource="uam_god">
			select distinct status from cf_temp_zipfiles where zid=#d.zid#
		</cfquery>
		<cfif valuelist(d_f.status) is "loaded_to_s3">
			<br>all s3ifyied
			<cfquery name="r" datasource="uam_god">
				update cf_temp_zipload set status='loaded_to_s3' where zid=#d.zid#
			</cfquery>
		<cfelse>
			<br>loaded_to_s3 not complete, do nothing
		</cfif>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------>


<cfif action is "mkprvw">
	<cfoutput>
		<!---- this needs to run iteratively ---->
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_zipload where status='renamed' and rownum=1
		</cfquery>
		<cfloop query="d">
			<!--- create a thumb directory if it doesn't already exist ---->
			<cfif not DirectoryExists("#Application.webDirectory#/temp/#d.zid#/tn")>
				<cfdirectory action = "create" directory = "#Application.webDirectory#/temp/#d.zid#/tn" >
			</cfif>
			<cfquery name="f" datasource="uam_god">
				select * from cf_temp_zipfiles where zid=#d.zid# and preview_filename is null and rownum <100
			</cfquery>
			<cfloop query="f">
				<cftransaction>
					<cfif len(f.preview_filename) is 0>
						<!--- we haven't been here, process this one ---->
						<!--- grab the file into a local var ---->
						<br>read #Application.webDirectory#/temp/#d.zid#/#f.new_filename#
						<cfimage action="read" name="thisImg" source="#Application.webDirectory#/temp/#d.zid#/#f.new_filename#">
						<cfimage action="info" structname="imagetemp" source="#thisImg#">
						<cfset x=min(180/imagetemp.width, 180/imagetemp.height)>
						<cfset newwidth = x*imagetemp.width>
		    			<cfset newheight = x*imagetemp.height>
			    		<cfset barefilename=listgetat(f.new_filename,1,".")>
			    		<cfset tfilename="tn_#barefilename#.jpg">
			   			<cfimage action="convert"
			   				source="#thisImg#"
			   				destination="#Application.webDirectory#/temp/#d.zid#/tn/#tfilename#" overwrite = "true">
			   			<cfimage action="resize" source="#Application.webDirectory#/temp/#d.zid#/tn/#tfilename#"
			   				width="#newwidth#" height="#newheight#" destination="#Application.webDirectory#/temp/#d.zid#/tn/#tfilename#" overwrite = "true">
			   			<cfquery name="r" datasource="uam_god">
							update cf_temp_zipfiles set preview_filename='#tfilename#',status='previewed' where zid=#d.zid# and new_filename='#f.new_filename#'
						</cfquery>
					</cfif>
				</cftransaction>
			</cfloop>
		</cfloop>
	</cfoutput>
</cfif>

<!------------------------------------------------------------------------------------------------>
<cfif action is "mkprvw_confirm">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_zipload where status='renamed' and rownum=1
		</cfquery>
		<cfif d.recordcount lt 1>
			nope<cfabort>
		</cfif>
		<cfquery name="d_f" datasource="uam_god">
			select distinct status from cf_temp_zipfiles where zid=#d.zid#
		</cfquery>
		<cfif valuelist(d_f.status) is "previewed">
			<br>all previewed
			<cfquery name="r" datasource="uam_god">
				update cf_temp_zipload set status='previewed' where zid=#d.zid#
			</cfquery>
		<cfelse>
			<br>previewed not complete, do nothing
		</cfif>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "rename">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_zipload where status='unzipped' and rownum=1
		</cfquery>
		<cfif d.recordcount lt 1>
			nada<cfabort>
		</cfif>
		<cfdump var=#d#>
		<cfset utilities = CreateObject("component","component.utilities")>
		<cfloop query="d">
			<cfquery name="f" datasource="uam_god">
				select * from cf_temp_zipfiles where zid=#d.zid#
			</cfquery>
			<cfloop query="f">
				<cftransaction>
					<cfset fext=listlast(filename,".")>
					<cfif not listfindnocase(goodExtensions,fext)>
						<cfquery name="fail" datasource="uam_god">
							update cf_temp_zipload set status='FATAL ERROR: #filename# contains an invalid extension' where zid=#d.zid#
						</cfquery>
						<cfbreak>
					</cfif>
					<br>#filename#
					<cfset fName=listdeleteat(fileName,listlen(filename,'.'),'.')>
					<cfset fName=REReplace(fName,"[^A-Za-z0-9_$]","_","all")>
					<cfset fName=replace(fName,'__','_','all')>
					<cfset nfileName=fName & '.' & fext>
					<cfset vfn=utilities.isValidMediaUpload(nfileName)>
					<cfif len(vfn) gt 0>
						<cfquery name="fail" datasource="uam_god">
							update cf_temp_zipload set status='FATAL ERROR: #nfileName# is invalid - #vfn#' where zid=#d.zid#
						</cfquery>
						<cfbreak>
					</cfif>
					<cffile action = "rename"
						source = "#Application.webDirectory#/temp/#d.zid#/#filename#"
						destination = "#Application.webDirectory#/temp/#d.zid#/#nfileName#">
					<cfquery name="r" datasource="uam_god">
						update cf_temp_zipfiles set status='renamed',new_filename='#nfileName#' where zid=#d.zid# and filename='#filename#'
					</cfquery>
					<br>new:#nfileName#
				</cftransaction>
			</cfloop>
		</cfloop>
	</cfoutput>
</cfif>

<!------------------------------------------------------------------------------------------------>
<cfif action is "rename_confirm">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_zipload where status='unzipped' and rownum=1
		</cfquery>
		<cfif d.recordcount lt 1>
			nope<cfabort>
		</cfif>
		<cfquery name="d_f" datasource="uam_god">
			select distinct status from cf_temp_zipfiles where zid=#d.zid#
		</cfquery>
		<cfif valuelist(d_f.status) is "renamed">
			<br>all renamed
			<cfquery name="r" datasource="uam_god">
				update cf_temp_zipload set status='renamed' where zid=#d.zid#
			</cfquery>
		<cfelse>
			<br>rename not complete, do nothing
		</cfif>
	</cfoutput>
</cfif>
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
				sent. Please do not start this process if you cannot follow that schedule.
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
		You will receive email when processing has completed, usually within 24 hours.
	</p>
	<p>
		Your ZIP has been loaded and a job created. You will receive email from Arctos referencing job #jobname#. Do not delete the ZIP file until you
		are notified that the process is complete and you have confirmed that all of your data are on Corral.
	</p>

</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "unzip">
	<cfoutput>
		<!--- see if there's anything new; just grab one --->
		<cfquery name="jid" datasource="uam_god">
			select * from cf_temp_zipload where status='new' and rownum=1
		</cfquery>
		<cfloop query="jid">
			<cfdirectory action = "create" directory = "#Application.webDirectory#/temp/#jid.zid#" >
			<br>jidloop
			<cfzip file="#Application.webDirectory#/temp/#jid.zid#.zip" action="unzip" destination="#Application.webDirectory#/temp/#jid.zid#/"/>
			<cfdirectory action="LIST" directory="#Application.webDirectory#/temp/#jid.zid#" name="dir" recurse="no">
			<cfloop query="dir">
				<br>insert #name#
				<cfif left(name,1) is not "." and left(name,1) is not "_">
					<cfquery name="faf" datasource="uam_god">
						insert into cf_temp_zipfiles (zid,filename) values (#jid.zid#,'#name#')
					</cfquery>
				</cfif>
			</cfloop>
		</cfloop>
		<cfquery name="uz" datasource="uam_god">
			update cf_temp_zipload set status='unzipped' where zid=#jid.zid#
		</cfquery>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
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
<!---------------------------------------------------------------------------->
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
		<br>moving #name# to #baseWebDir#/#name#
		<cffile action="move" source="#sandboxdir#/#name#" destination="#baseFileDir#/#name#">
	</cfloop>
	<p>
		<br>Your files are now on the webserver.
		<br><a href="uploadMedia.cfm?action=preview">Preview them here</a>.
		<br>If the above looks wrong, you can <a href="uploadMedia.cfm?action=deleteTodayDir">delete your #dateformat(now(),'yyyy-mm-dd')# directory</a>
		from the webserver. CAUTION: This deletes EVERYTHING you've loaded today.
	</p>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "preview">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_zipload where username='#session.username#'
		</cfquery>
		<cfif d.recordcount is 0>
			You have no jobs.<cfabort>
		</cfif>

		<cfloop query="d">
			<br>Job Name: #JOBNAME#
			<br>Submitted Date: #submitted_date#
			<br>Status: #STATUS#

			<cfquery name="f" datasource="uam_god">
				select * from cf_temp_zipfiles where zid=#d.zid#
			</cfquery>
			<table border>
				<tr>
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
						<td>#FILENAME#</td>
						<td>#NEW_FILENAME#</td>
						<td>#PREVIEW_FILENAME#</td>
						<td>#REMOTEPATH#</td>
						<td>#REMOTE_PREVIEW#</td>
						<td>#MIME_TYPE#</td>
						<td>#MEDIA_TYPE#</td>
						<td>#MD5#</td>
					</tr>
				</cfloop>
			</table>
		</cfloop>

			<!---------
			UAM@ARCTOSTE> desc cf_temp_zipfiles
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 ZID								   NOT NULL NUMBER
 FILENAME								    VARCHAR2(255)
 LOCALPATH								    VARCHAR2(255)
 REMOTEPATH								    VARCHAR2(255)
 STATUS 								    VARCHAR2(255)
 NEW_FILENAME								    VARCHAR2(255)
 PREVIEW_FILENAME							    VARCHAR2(255)
 MD5									    VARCHAR2(255)
 MIME_TYPE								    VARCHAR2(255)
 MEDIA_TYPE								    VARCHAR2(255)
 REMOTE_PREVIEW 							    VARCHAR2(255)

UAM@ARCTOSTE>






			  Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 ZID								   NOT NULL NUMBER
 USERNAME							   NOT NULL VARCHAR2(255)
 EMAIL								   NOT NULL VARCHAR2(255)
 JOBNAME							   NOT NULL VARCHAR2(255)
 STATUS 							   NOT NULL VARCHAR2(255)
		</cfloop>
		<p>
			Click on a few links and make sure everything looks OK before proceeding.
		</p>
		<p>
			If things are wonky, you can
			<a href="uploadMedia.cfm?action=deleteTodayDir">delete your #dateformat(now(),'yyyy-mm-dd')# directory</a>
		</p>
		<p>
			If things are less-wonky, you can
			<a href="uploadMedia.cfm?action=getBLTemp">download a bulkloader template</a>.
			If you've loaded multiple batches today the template will contain them all; you may have to delete some stuff.
		</p>
		<p>
			Re-load the template to create Media at <a href="/tools/BulkloadMedia.cfm">BulkloadMedia</a>
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
		-------->
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">