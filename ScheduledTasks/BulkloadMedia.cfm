<cfinclude template="/includes/_header.cfm">

<!---
pause
--->
running only as DLM

<cfif not isdefined('session.username') or session.username is not 'dlm'>
	not DML<cfabort>
</cfif>
<cfset numLabels=10>
<cfset numRelns=5>
<cfif not isdefined("debug")><cfset debug=false></cfif>
<!------------------------------------------------------->
<cfif action is "nothing">
	<p>
		These actually create Media
	</p>
	<a href="BulkloadMedia.cfm?action=validate&debug=true">validate&debug</a>
	<br><a href="BulkloadMedia.cfm?action=report">report</a>
	<br><a href="BulkloadMedia.cfm?action=cleanup">cleanup</a>
	<br><a href="BulkloadMedia.cfm?action=load">load</a>


	<p>
		These are handlers for uploaded image-containing ZIP files. Putting them here in an attempt to keep more organized.
		<br><a href="BulkloadMedia.cfm?action=zip_unzip">zip_unzip</a>
		<br><a href="BulkloadMedia.cfm?action=zip_rename">zip_rename</a>
		<br><a href="BulkloadMedia.cfm?action=zip_rename_confirm">zip_rename_confirm</a>
		<br><a href="BulkloadMedia.cfm?action=zip_makepreview">zip_makepreview</a>
		<br><a href="BulkloadMedia.cfm?action=zip_makepreview_confirm">zip_makepreview_confirm</a>
		<br><a href="BulkloadMedia.cfm?action=zip_s3ify">zip_s3ify</a>
		<br><a href="BulkloadMedia.cfm?action=zip_s3ify_confirm">zip_s3ify_confirm</a>
		<br><a href="BulkloadMedia.cfm?action=zip_notify_done">zip_notify_done</a>

	</p>
</cfif>

<!--------------------------------------------------------------------------------------------->
<cfif action is "zip_unzip">
	<!---
		first step
		trigger status: cf_temp_zipload status: new
		success status: cf_temp_zipload status: unzipped
	---->
	<cfoutput>
		<!--- see if there's anything new; just grab one --->
		<cfquery name="jid" datasource="uam_god">
			select * from cf_temp_zipload where status='new' and rownum=1
		</cfquery>
		<cfif jid.recordcount lt 1>
			<cfabort>
		</cfif>
		<cfloop query="jid">
			<cfdirectory action="create" directory="#Application.webDirectory#/temp/#jid.zid#" >
			<cfzip file="#Application.webDirectory#/temp/#jid.zid#.zip" action="unzip" destination="#Application.webDirectory#/temp/#jid.zid#/"/>
			<cfdirectory action="LIST" directory="#Application.webDirectory#/temp/#jid.zid#" name="dir" recurse="no">
			<cfloop query="dir">
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


<!------------------------------------------------------------------------------------------------>
<cfif action is "zip_rename">
	<!----
		second step
		trigger: cf_temp_zipload status: unzipped
		success:
			cf_temp_zipload status: unzipped (nochange)
			cf_temp_zipfiles status ALL: renamed
	---->

	<cfoutput>
		<cfset goodExtensions="jpg,png">
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_zipload where status='unzipped' and rownum=1
		</cfquery>
		<cfif d.recordcount lt 1>
			<cfabort>
		</cfif>
		<cfset utilities = CreateObject("component","component.utilities")>
		<cfloop query="d">
			<cfquery name="f" datasource="uam_god">
				select * from cf_temp_zipfiles where zid=#d.zid#
			</cfquery>
			<cfloop query="f">
				<cftransaction>
					<cfif f.status neq 'renamed'>
						<cfset fext=listlast(filename,".")>
						<cfif not listfindnocase(goodExtensions,fext)>
							<cfquery name="fail" datasource="uam_god">
								update cf_temp_zipload set status='FATAL ERROR: #filename# contains an invalid extension' where zid=#d.zid#
							</cfquery>
							<cfbreak>
						</cfif>
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
					</cfif>
				</cftransaction>
			</cfloop>
		</cfloop>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------>
<cfif action is "zip_rename_confirm">
	<!--- third step
		trigger:
			cf_temp_zipload status: unzipped
			ALL cf_temp_zipfiles status: renamed
		success:
			cf_temp_zipload status: unzipped
			ALL cf_temp_zipfiles status: rename_confirmed
	---->
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_zipload where status='unzipped' and rownum=1
		</cfquery>
		<cfif d.recordcount lt 1>
			<cfabort>
		</cfif>
		<cfquery name="d_f" datasource="uam_god">
			select distinct status from cf_temp_zipfiles where zid=#d.zid#
		</cfquery>
		<cfif valuelist(d_f.status) is "renamed">
			<cfquery name="r" datasource="uam_god">
				update cf_temp_zipload set status='rename_confirmed' where zid=#d.zid#
			</cfquery>
		</cfif>
	</cfoutput>
</cfif>





<!------------------------------------------------------------------------------------------------>
<cfif action is "zip_makepreview">
	<!----
		fourth step
			trigger:
				cf_temp_zipload status: unzipped
				ALL cf_temp_zipfiles status: rename_confirmed
			success:
				cf_temp_zipload.status: unzipped (no change)
				cf_temp_zipfiles.status: previewed
	---->
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
				select * from cf_temp_zipfiles where zid=#d.zid# and preview_filename is null and rownum <20
			</cfquery>
			<cfloop query="f">
			<cftry>
				<cftransaction>
					<cfif len(f.preview_filename) is 0>
						<!--- we haven't been here, process this one ---->
						<!--- grab the file into a local var ---->
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
				<cfcatch>
				<br>						update cf_temp_zipload set status='FATAL_ERROR: zip_makepreview failure' where zid=#d.zid#

					<cfquery name="r" datasource="uam_god">
						update cf_temp_zipload set status='FATAL_ERROR: zip_makepreview failure' where zid=#d.zid#
					</cfquery>
				</cfcatch>
				</cftry>
			</cfloop>
		</cfloop>
	</cfoutput>
</cfif>




<!------------------------------------------------------------------------------------------------>
<cfif action is "zip_makepreview_confirm">
	<!----
		fifth step
			trigger:
				cf_temp_zipload.status: unzipped
				cf_temp_zipfiles.status: previewed
			success:
				cf_temp_zipload.status=preview_confirmed
	---->
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_zipload where status='previewed' and rownum=1
		</cfquery>
		<cfdump var=#d#>
		<cftry>
			<cfif d.recordcount lt 1>
				<cfabort>
			</cfif>
			<cfquery name="d_f" datasource="uam_god">
				select distinct status from cf_temp_zipfiles where zid=#d.zid#
			</cfquery>
		<cfdump var=#d_f#>
			<cfif valuelist(d_f.status) is "previewed">
				<cfquery name="r" datasource="uam_god">
					update cf_temp_zipload set status='preview_confirmed' where zid=#d.zid#
				</cfquery>
			</cfif>
			<cfcatch>

				<cfquery name="r" datasource="uam_god">
					update cf_temp_zipload set status='FATAL ERROR: at zip_makepreview_confirm' where zid=#d.zid#
				</cfquery>
			</cfcatch>
		</cftry>
	</cfoutput>
</cfif>


<!------------------------------------------------------------------------------------------------>
<cfif action is "zip_s3ify">
	<!----
		sixth step
		trigger: cf_temp_zipload.status = preview_confirmed
		success: cf_temp_zipfiles.status='loaded_to_s3'

	----->
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_zipload where status='preview_confirmed' and rownum=1
		</cfquery>
		<cfif d.recordcount is 0>
			<cfabort>
		</cfif>
		<cftry>
			<cfquery name="s3" datasource="uam_god" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
				select S3_ENDPOINT,S3_ACCESSKEY,S3_SECRETKEY from cf_global_settings
			</cfquery>
			<cfquery name="f" datasource="uam_god">
				select * from cf_temp_zipfiles where zid=#d.zid# and status='previewed' and rownum<10
			</cfquery>
			<!---- make a username bucket. This will create or return an error of some sort. ---->
			<cfset currentTime = getHttpTimeString( now() ) />
			<cfset contentType = "text/html" />
			<cfset bucket="#lcase(d.username)#">
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
				<cfset bucket="#lcase(d.username)#/#dateformat(now(),'YYYY-MM-DD')#">
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
				<cfset bucket="#lcase(d.username)#/#dateformat(now(),'YYYY-MM-DD')#/tn">
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
		<cfcatch>
			caught
			<cfdump var=#cfcatch#>
			-----------------------------------

			<cfquery name="lldd" datasource="uam_god">
				update cf_temp_zipfiles set status='FATAL ERROR: loaded_to_s3 fail'	where new_filename='#f.new_filename#'
			</cfquery>
		</cfcatch>
		</cftry>
	</cfoutput>
</cfif>



<!------------------------------------------------------------------------------------------------>

<cfif action is "zip_s3ify_confirm">
	<!----
		seventh step
		trigger:cf_temp_zipfiles.status='loaded_to_s3'
		success:

	---->
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_zipload where status='preview' and rownum=1
		</cfquery>
		<cfif d.recordcount lt 1>
			<cfabort>
		</cfif>
		<cfquery name="d_f" datasource="uam_god">
			select distinct status from cf_temp_zipfiles where zid=#d.zid#
		</cfquery>
		<cfif valuelist(d_f.status) is "loaded_to_s3">
			<cfquery name="r" datasource="uam_god">
				update cf_temp_zipload set status='loaded_to_s3' where zid=#d.zid#
			</cfquery>
		</cfif>
	</cfoutput>
</cfif>


























<!------------------------------------------------------------------------------------------------>
<cfif action is "zip_notify_done">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_temp_zipload where (
			status like '%FATAL ERROR%' or
			status='loaded_to_s3') and
			status not like '%complete_email_sent%' and
			rownum=1
		</cfquery>
		<cfif d.recordcount is 0>
			<cfabort>
		</cfif>

		<cftry>
			<cfif d.status contains "FATAL ERROR">
				<cfmail to="#d.email#" bcc="arctos.database@gmail.com" subject="ZIP upload status" cc="#Application.LogEmail#" from="zipmedia@#Application.fromEmail#" type="html">
					Dear #d.username#,
					<p>
						Your image zip upload job #d.jobname# has failed with error #d.status#
					</p>
					<p>
						Please review the instructions on the upload page, and contact us if you need assistance to resolve the problem.
					</p>
					<p>
						More information may be available at #application.serverRootUrl#/tools/uploadMedia.cfm?action=preview###d.zid#
					</p>
				</cfmail>

				<cfquery name="r" datasource="uam_god">
					update cf_temp_zipload set status='complete_email_sent - ' || status where zid=#d.zid#
				</cfquery>
			<cfelse>
				<cfset utilities = CreateObject("component","component.utilities")>
				<cfset utilities.makeMBLDownloadFile(#d.zid#)>
				<cfmail to="#d.email#" bcc="arctos.database@gmail.com" subject="ZIP upload status" cc="#Application.LogEmail#" from="zipmedia@#Application.fromEmail#" type="html">
					Dear #d.username#,
					<p>
						Your image zip upload job #d.jobname# is complete.
					</p>
					<p>
						A file is available at #application.serverRootUrl#/download/media_bulk_zip#d.zid#.csv. This file will be deleted in three days,
						but may be regenerated from the more information link below.
					</p>
					<p>
						The file is NOT ready to upload in the media bulkloader.
					</p>
					<p>
						* TEMP_original_filename is the filename as supplied.
						<br>* TEMP_new_filename is the filename as loaded.
					</p>
					<p>
						Please delete these columns before attempting upload. Instructions for adding columns or data are available from the Media Bulkloader.
					</p>
					<p>
						Please do NOT delete the "MD5 checksum" (in MEDIA_LABEL_1 and MEDIA_LABEL_VALUE_1). This is important to preventing duplicate creation
						and ensuring that files have not inadvertantly been changed over time.
					</p>
					<p>
						More information may be available at #application.serverRootUrl#/tools/uploadMedia.cfm?action=preview###d.zid#
					</p>
				</cfmail>
				<cfquery name="r" datasource="uam_god">
					update cf_temp_zipload set status='complete_email_sent' where zid=#d.zid#
				</cfquery>
			</cfif>
		<cfcatch>
			<cfquery name="r" datasource="uam_god">
				update cf_temp_zipload set status='FATAL ERROR: complete_email_sent failed' where zid=#d.zid#
			</cfquery>
		</cfcatch>
		</cftry>
	</cfoutput>
</cfif>


<!--------------------------------------------------------------------------------------------->
<cfif action is "report">
	<cfoutput>
	<cfquery name="who" datasource="uam_god">
		select username,user_agent_id from cf_temp_media group by username,user_agent_id
	</cfquery>
	<cfloop query="who">
		<cfquery name="e" datasource="uam_god">
			select get_address(#user_agent_id#,'email') address from dual
		</cfquery>
		<cfquery name="s" datasource="uam_god">
			select status, count(*) c from cf_temp_media where username='#username#' group by status
		</cfquery>

		<cfif len(e.address) is 0>
			<cfset mailto="arctos.database@gmail.com">
			<cfset msubj="media bulkloader: no contact info">
		<cfelse>

			<cfset mailto=e.address>
			<cfset msubj="media bulkloader">

		</cfif>
		<cfmail to="#mailto#" bcc="arctos.database@gmail.com" subject="#msubj#" cc="#Application.LogEmail#" from="bulkmedia@#Application.fromEmail#" type="html">
			Dear #username#,
			<p>
				The following records are in the Media Bulkloader:
			</p>
			<p>
			<cfloop query="s">
				<br>#status#: #c#
			</cfloop>
			</p>
			<p>
			After logging in to Arctos, you may follow the links from the Media Bulkloader
			(http://arctos.database.museum/tools/BulkloadMedia.cfm?action=myStuff) to review detailed status
			messages or delete your records. You will receive daily reminders until you have deleted all records in
			your temporary table.
			</p>
		</cfmail>
	</cfloop>
	</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "cleanup">
	<cfquery name="killOld" datasource="uam_god">
		delete from cf_temp_media_relations where key not in (select key from cf_temp_media)
	</cfquery>
	<cfquery name="killOld" datasource="uam_god">
		delete from cf_temp_media_labels where key not in (select key from cf_temp_media)
	</cfquery>
</cfif>
<!------------------------------------------------------->
<cfif action is "validate">
<cfoutput>
<cfset stime=now()>
<cfquery name="d" datasource="uam_god">
	select * from cf_temp_media where status is null and rownum<51
</cfquery>
#d.recordcount#....
<cfif debug is true>
	#d.recordcount#....
	<cfdump var=#d#>
	</cfif>
<cfloop query="d">
	<cftransaction>
		<cfset rec_stat="">
		<cfif len(media_license) gt 0>
			<cfquery name="ml" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
				select MEDIA_LICENSE_ID from ctmedia_license where display='#media_license#'
			</cfquery>
			<cfif len(ml.MEDIA_LICENSE_ID) is 0>
				<cfset rec_stat=listappend(rec_stat,'media license is invalid',";")>
			<cfelse>
				<cfquery name="mlk" datasource="uam_god">
					update cf_temp_media set media_license_id=#ml.media_license_id# where key=#key#
				</cfquery>
			</cfif>
		</cfif>
		<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select MIME_TYPE from CTMIME_TYPE where MIME_TYPE='#MIME_TYPE#'
		</cfquery>
		<cfif len(c.MIME_TYPE) is 0>
			<cfset rec_stat=listappend(rec_stat,'MIME_TYPE #MIME_TYPE# is invalid',";")>
		</cfif>
		<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select MEDIA_TYPE from CTMEDIA_TYPE where MEDIA_TYPE='#MEDIA_TYPE#'
		</cfquery>
		<cfif len(c.MEDIA_TYPE) is 0>
			<cfset rec_stat=listappend(rec_stat,'MEDIA_TYPE #MEDIA_TYPE# is invalid',";")>
		</cfif>
		<!--- something has weird/weak ciphers and this fails to Corral. Try http--->
		<cfset pf_muri=media_uri>
		<cfif pf_muri contains 'https://web.corral.tacc'>
			<cfset pf_muri=replace(pf_muri,'https://web.corral.tacc','http://web.corral.tacc')>
		</cfif>
		<cfhttp url="#pf_muri#" charset="utf-8" method="head" />
		<cfif debug is true>
			<cfdump var=#cfhttp#>
		</cfif>
		<cfif left(cfhttp.statuscode,3) is not "200">
			<cfset rec_stat=listappend(rec_stat,'#media_uri# is invalid',";")>
		</cfif>
		<cfquery name="ago" datasource="uam_god">
			select count(*) c from media where media_uri='#media_uri#'
		</cfquery>
		<cfif ago.c is not 0>
			<cfset rec_stat=listappend(rec_stat,'#media_uri# already exists',";")>
		</cfif>
		<cfif len(preview_uri) gt 0>
			<cfset pf_puri=preview_uri>
			<cfif pf_puri contains 'https://web.corral.tacc'>
				<cfset pf_puri=replace(pf_puri,'https://web.corral.tacc','http://web.corral.tacc')>
			</cfif>

			<cfhttp url="#pf_puri#" charset="utf-8" method="head" />
			<cfif debug is true>
				<cfdump var=#cfhttp#>
			</cfif>
			<cfif left(cfhttp.statuscode,3) is not "200">
				<cfset rec_stat=listappend(rec_stat,'#preview_uri# is invalid',";")>
			</cfif>
		</cfif>
		<cfif debug>
			<br>start labels...
		</cfif>
		<cfloop from="1" to="#numLabels#" index="i">
			<cfset ln=evaluate("media_label_" & i)>
			<cfif len(ln) gt 0>
				<cfset ln=evaluate("media_label_" & i)>
				<cfset lv=evaluate("media_label_value_" & i)>
				<cfif debug>
					<br>ln: #ln#
					<br>lv: #lv#
				</cfif>
				<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
					select MEDIA_LABEL from CTMEDIA_LABEL where MEDIA_LABEL='#ln#'
				</cfquery>
				<cfif len(c.MEDIA_LABEL) is 0>
					<cfset rec_stat=listappend(rec_stat,'media_label_#i# (#ln#) is invalid',";")>
					<cfif debug>
						<br>media_label_#i# (#ln#) is invalid'
					</cfif>
				</cfif>
			</cfif>
		</cfloop>

		<cfif debug>
			<br>start relationships...
		</cfif>
		<cfloop from="1" to="#numRelns#" index="i">
			<cfset pf="">
			<cfset r=evaluate("media_relationship_" & i)>
				<cfif debug is true>
					<br>r: #r#
				</cfif>
				<cfif len(r) gt 0>
				<cfset rk=evaluate("media_related_key_" & i)>
				<cfset rt=evaluate("media_related_term_" & i)>
				<cfif debug>
					<br>rk: #rk#
					<br>rt: #rt#
				</cfif>
				<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
					select MEDIA_RELATIONSHIP from CTMEDIA_RELATIONSHIP where MEDIA_RELATIONSHIP='#r#'
				</cfquery>
				<cfif len(c.MEDIA_RELATIONSHIP) is 0>
					<cfset rec_stat=listappend(rec_stat,'Media relationship #r# is invalid',";")>
					<cfset pf="f">
				</cfif>
				<cfif len(rk) gt 0 and len(rt) gt 0>
					<!--- ignore event lookups, they're legit ---->
					<cfif not (listlast(r," ") is "collecting_event" and rt is "lookup")>
						<cfset rec_stat=listappend(rec_stat,'You cannot specify a relationship key and term',";")>
						<cfset pf="f">
					</cfif>
				</cfif>
				<cfif len(pf) is 0>
					<cfset table_name = listlast(r," ")>
					<cfif debug is true>
						<br>pf: #pf#
						<br>table_name:==#table_name#=============
					</cfif>
					<cfif len(rt) gt 0>
						<cfif table_name is "agent">
							<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
								select distinct(agent_id) agent_id from agent_name where agent_name ='#rt#'
							</cfquery>
							<cfif c.recordcount is 1 and len(c.agent_id) gt 0>
								<cfquery name="i" datasource="uam_god">
									update cf_temp_media set media_related_key_#i#=#c.agent_id# where key=#key#
								</cfquery>
							<cfelse>
								<cfset rec_stat=listappend(rec_stat,'Agent #rt# matched #c.recordcount# records.',";")>
							</cfif>
						<cfelseif table_name is "collecting_event">
							<cfif len(rk) is 0 and rt is "lookup">
								<p>
									running getMakeCollectingEvent.....
								</p>
								<!--- get a collecting event or throw an error ---->
								<!----
									well crap
									CF10 ignores dbvarname
									so we have to pass these things in in order or fail
									crap.
									srsly.
									crap.
								---->
								<cftry>
								<cfstoredproc procedure="getMakeCollectingEvent" datasource="uam_god">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#COLLECTING_EVENT_ID#" dbvarname="v_COLLECTING_EVENT_ID">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#COLLECTING_EVENT_NAME#" dbvarname="v_COLLECTING_EVENT_NAME">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#VERBATIM_DATE#" dbvarname="v_VERBATIM_DATE">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#BEGAN_DATE#" dbvarname="v_BEGAN_DATE">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#ENDED_DATE#" dbvarname="v_ENDED_DATE">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#VERBATIM_LOCALITY#" dbvarname="v_VERBATIM_LOCALITY">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#COLL_EVENT_REMARKS#" dbvarname="v_COLL_EVENT_REMARKS">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LOCALITY_ID#" dbvarname="v_LOCALITY_ID">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#SPEC_LOCALITY#" dbvarname="v_SPEC_LOCALITY">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LOCALITY_NAME#" dbvarname="v_LOCALITY_NAME">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#ORIG_ELEV_UNITS#" dbvarname="v_ORIG_ELEV_UNITS">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#MINIMUM_ELEVATION#" dbvarname="v_MINIMUM_ELEVATION">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#MAXIMUM_ELEVATION#" dbvarname="v_MAXIMUM_ELEVATION">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#DEPTH_UNITS#" dbvarname="v_DEPTH_UNITS">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#MIN_DEPTH#" dbvarname="v_MIN_DEPTH">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#MAX_DEPTH#" dbvarname="v_MAX_DEPTH">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#ORIG_LAT_LONG_UNITS#" dbvarname="v_ORIG_LAT_LONG_UNITS">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#DATUM#" dbvarname="v_DATUM">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#GEOREFERENCE_SOURCE#" dbvarname="v_GEOREFERENCE_SOURCE">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#GEOREFERENCE_PROTOCOL#" dbvarname="v_GEOREFERENCE_PROTOCOL">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#MAX_ERROR_UNITS#" dbvarname="v_MAX_ERROR_UNITS">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#MAX_ERROR_DISTANCE#" dbvarname="v_MAX_ERROR_DISTANCE">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#DEC_LAT#" dbvarname="v_DEC_LAT">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#DEC_LONG#" dbvarname="v_DEC_LONG">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LAT_DEG#" dbvarname="v_LAT_DEG">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LAT_MIN#" dbvarname="v_LAT_MIN">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LAT_SEC#" dbvarname="v_LAT_SEC">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LAT_DIR#" dbvarname="v_LAT_DIR">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LONG_DEG#" dbvarname="v_LONG_DEG">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LONG_MIN#" dbvarname="v_LONG_MIN">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LONG_SEC#" dbvarname="v_LONG_SEC">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LONG_DIR#" dbvarname="v_LONG_DIR">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#DEC_LAT_MIN#" dbvarname="v_DEC_LAT_MIN">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#DEC_LONG_MIN#" dbvarname="v_DEC_LONG_MIN">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#UTM_ZONE#" dbvarname="v_UTM_ZONE">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#UTM_EW#" dbvarname="v_UTM_EW">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#UTM_NS#" dbvarname="v_UTM_NS">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#WKT_POLYGON#" dbvarname="v_WKT_POLYGON">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#LOCALITY_REMARKS#" dbvarname="v_LOCALITY_REMARKS">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#HIGHER_GEOG#" dbvarname="v_HIGHER_GEOG">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geology_attribute_1#" dbvarname="v_geology_attribute_1">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_value_1#" dbvarname="v_geo_att_value_1">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_date_1#" dbvarname="v_geo_att_determined_date_1">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determiner_1#" dbvarname="v_geo_att_determiner_1">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_method_1#" dbvarname="v_geo_att_determined_method_1">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_remark_1#" dbvarname="v_geo_att_remark_1">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geology_attribute_2#" dbvarname="v_geology_attribute_2">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_value_2#" dbvarname="v_geo_att_value_2">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_date_2#" dbvarname="v_geo_att_determined_date_2">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determiner_2#" dbvarname="v_geo_att_determiner_2">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_method_2#" dbvarname="v_geo_att_determined_method_2">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_remark_2#" dbvarname="v_geo_att_remark_2">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geology_attribute_3#" dbvarname="v_geology_attribute_3">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_value_3#" dbvarname="v_geo_att_value_3">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_date_3#" dbvarname="v_geo_att_determined_date_3">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determiner_3#" dbvarname="v_geo_att_determiner_3">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_method_3#" dbvarname="v_geo_att_determined_method_3">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_remark_3#" dbvarname="v_geo_att_remark_3">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geology_attribute_4#" dbvarname="v_geology_attribute_4">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_value_4#" dbvarname="v_geo_att_value_4">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_date_4#" dbvarname="v_geo_att_determined_date_4">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determiner_4#" dbvarname="v_geo_att_determiner_4">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_method_4#" dbvarname="v_geo_att_determined_method_4">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_remark_4#" dbvarname="v_geo_att_remark_4">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geology_attribute_5#" dbvarname="v_geology_attribute_5">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_value_5#" dbvarname="v_geo_att_value_5">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_date_5#" dbvarname="v_geo_att_determined_date_5">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determiner_5#" dbvarname="v_geo_att_determiner_5">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_method_5#" dbvarname="v_geo_att_determined_method_5">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_remark_5#" dbvarname="v_geo_att_remark_5">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geology_attribute_6#" dbvarname="v_geology_attribute_6">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_value_6#" dbvarname="v_geo_att_value_6">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_date_6#" dbvarname="v_geo_att_determined_date_6">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determiner_6#" dbvarname="v_geo_att_determiner_6">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_determined_method_6#" dbvarname="v_geo_att_determined_method_6">
									<cfprocparam type="in" cfsqltype="CF_SQL_VARCHAR" value="#geo_att_remark_6#" dbvarname="v_geo_att_remark_6">
									<cfprocparam type="out" cfsqltype="cf_sql_numeric" variable="ceid" dbvarname="v_r_ceid">
								</cfstoredproc>
								<cfif debug>
									<p>
										update cf_temp_media set media_related_key_#i#=#ceid# where key=#key#
									</p>
								</cfif>
								<cfquery name="i" datasource="uam_god">
									update cf_temp_media set media_related_key_#i#=#ceid# where key=#key#
								</cfquery>
								<cfcatch>
									<cfset rec_stat=listappend(rec_stat,'event unresolvable: #cfcatch.message# #cfcatch.detail#',";")>
									<cfif debug>
										<br>catch!
										<br>#cfcatch.message# #cfcatch.detail#'
										<br>rec_stat: #rec_stat#
									</cfif>
								</cfcatch>
								</cftry>
							</cfif>

						<cfelseif table_name is "project">
							<cftry>
								<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
									select distinct(project_id) project_id from project where project_id ='#rt#'
								</cfquery>
								<cfif c.recordcount is 1 and len(c.project_id) gt 0>
									<cfquery name="i" datasource="uam_god">
										update cf_temp_media set media_related_key_#i#=#c.project_id# where key=#key#
									</cfquery>
								<cfelse>
									<cfset rec_stat=listappend(rec_stat,'Project #lv# matched #c.recordcount# records.',";")>
								</cfif>
								<cfcatch>
									<cfset rec_stat=listappend(rec_stat,'Project #lv# error: #cfcatch.Message#',";")>
								</cfcatch>
							</cftry>
						<cfelseif table_name is "media">
							<cfquery name="c" datasource="uam_god">
								select distinct(media_id) media_id from media where media_uri ='#rt#'
							</cfquery>
							<cfif c.recordcount is 1 and len(c.media_id) gt 0>
								<cfquery name="i" datasource="uam_god">
									update cf_temp_media set media_related_key_#i#=#c.media_id# where key=#key#
								</cfquery>
							<cfelse>
								<cfset rec_stat=listappend(rec_stat,'Media #rt# matched #c.recordcount# records.',";")>
								<cfif debug>
									<br>fail@relationship media
									<cfdump var=#c#>
								</cfif>
							</cfif>
						<cfelseif table_name is "cataloged_item">
							<cfif debug is true>
								-----------here we are now-------------
								---------------
								select collection_object_id from
										flat
									WHERE
										guid='#rt#'
										---------
							</cfif>
							<!--- accepts GUID or barcode. We're screwed if anyone ever orders barcodes with a guid-like format, but until then....---->
							<cfif listlen(rt,':') is 3>
								<!--- guid --->
								<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
									select collection_object_id from
										flat
									WHERE
										guid='#rt#'
								</cfquery>
							<cfelse>
								<!--- barcode or stoopids --->
								<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
									select flat.collection_object_id from
										flat,
										container child,
										container parent,
										specimen_part,
										coll_obj_cont_hist
									WHERE
										flat.collection_object_id=specimen_part.derived_from_cat_item and
										specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
										coll_obj_cont_hist.container_id=child.container_id and
										child.parent_container_id=parent.container_id and
										parent.barcode='#rt#'
								</cfquery>
							</cfif>
							<cfif debug is true>
								<cfdump var=#c#>
							</cfif>
							<cfif c.recordcount is 1 and len(c.collection_object_id) gt 0>
								<cfquery name="i" datasource="uam_god">
									update cf_temp_media set media_related_key_#i#=#c.collection_object_id# where key=#key#
								</cfquery>
							<cfelse>
								<cfset rec_stat=listappend(rec_stat,'Cataloged Item matched #c.recordcount# records.',";")>
							</cfif>
						<cfelse>
							<cfset rec_stat=listappend(rec_stat,'Media relationship #ln# is not handled',";")>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		<cfif len(rec_stat) is 0>
			<cfset rec_stat='pass'>
		</cfif>
		<cfif len(rec_stat) gt 254>
			<cfset rec_stat=left(rec_stat,250) & '...'>
		</cfif>
		<cfif debug>
			<br>final: #rec_stat#
			<hr>
		</cfif>
		<cfquery name="c" datasource="uam_god">
			update cf_temp_media set status='#trim(rec_stat)#' where key=#key#
		</cfquery>
	</cftransaction>
</cfloop>
<cfset qtime=now()>
#stime#----------#qtime#
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "load">
<cfoutput>
	<cfquery name="media" datasource="uam_god">
		select
			*
		from
			cf_temp_media where status='pass' and rownum<500
	</cfquery>
	<cfloop query="media">
		<cftransaction>
			<cftry>
				<cfquery name="mid" datasource="uam_god">
					select sq_media_id.nextval nv from dual
				</cfquery>
				<cfset media_id=mid.nv>
				<cfquery name="makeMedia" datasource="uam_god">
					insert into media (media_id,media_uri,mime_type,media_type,preview_uri,media_license_id)
		            values (#media_id#,'#escapeQuotes(media_uri)#','#mime_type#','#media_type#','#preview_uri#',
		            <cfif len(media_license_id) gt 0>
						#media_license_id#
					<cfelse>
						NULL
					</cfif>)
				</cfquery>
				<cfloop from="1" to="#numRelns#" index="i">
					<cfset r=evaluate("media_relationship_" & i)>
					<cfif len(r) gt 0>
						<cfset rk=evaluate("media_related_key_" & i)>
						<cfset table_name = listlast(r," ")>
						<cfquery name="makeRelation" datasource="uam_god">
							insert into media_relations (
								media_id,media_relationship,related_primary_key,CREATED_BY_AGENT_ID
							) values (
								#media_id#,'#r#',#rk#,#user_agent_id#
							)
						</cfquery>
					</cfif>
				</cfloop>
				<cfloop from="1" to="#numLabels#" index="i">
					<cfset ln=evaluate("media_label_" & i)>
					<cfif len(ln) gt 0>
						<cfset ln=evaluate("media_label_" & i)>
						<cfset lv=evaluate("media_label_value_" & i)>
						<cfquery name="makeRelation" datasource="uam_god">
							insert into media_labels (
								media_id,media_label,label_value,ASSIGNED_BY_AGENT_ID
							) values (
								#media_id#,'#ln#','#lv#',#media.user_agent_id#
							)
						</cfquery>
					</cfif>
				</cfloop>
				<cfquery name="tm" datasource="uam_god">
					update cf_temp_media set status='loaded',loaded_media_id=#media_id# where key=#key#
				</cfquery>
				<cfcatch>
					<cftransaction action="rollback">
					<cfset temp=cfcatch.message & ": " & cfcatch.detail>
					<cfif isdefined("cfcatch.sql")>
						<cfset temp=temp & ":: " & cfcatch.sql>
					</cfif>
					<cfquery name="tm" datasource="uam_god">
						update cf_temp_media set status='#trim(temp)#' where key=#key#
					</cfquery>
				</cfcatch>
			</cftry>
		</cftransaction>
	</cfloop>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">