<cfinclude template="/includes/_header.cfm">
<cfsetting requesttimeout="600">
<!---
	modify for final cleanup in move to S3
	old version is in v7.9.6
---->


<!----

select media_uri,media_id from media where media_uri like '%arctos.database%';

	drop table temp_m_f;

	create table temp_m_f as select
		media_id,
		media_uri,
		preview_uri
	from
		media
	where
		(media_uri like '%arctos.database%' and media_uri like '%mediaUploads%') or
		(preview_uri like '%arctos.database%' and preview_uri like '%mediaUploads%')
		;


	alter table temp_m_f add lcl_p varchar2(255);
	alter table temp_m_f add lcl_p_p varchar2(255);

	alter table temp_m_f add status varchar2(255);


	update temp_m_f set status=null,lcl_p=null where lcl_p='/';
		update temp_m_f set status=null,lcl_p_p=null where lcl_p_p='/';


select status,count(*) from temp_m_f group by status;

-- some some complexity
					select LABEL_VALUE from media_labels where MEDIA_LABEL='MD5 checksum' and MEDIA_ID in (select media_id from temp_m_f);

---->

	<p>
		 <a href="cleanImages.cfm?action=cleanup">cleanup</a>
	</p>
	<p>
		 <a href="cleanImages.cfm?action=upmuris">upmuris</a>
	</p>
	<p>
		 <a href="cleanImages.cfm?action=cpfls">cpfls</a>
	</p>
	<p>
		 <a href="cleanImages.cfm?action=mklclp">mklclp</a>
	</p>
	<p>
		 <a href="cleanImages.cfm?action=cklcl">cklcl</a>
	</p>
<cfoutput>


	<cfif action is "cleanup">
	 <cfdirectory directory = "#Application.webDirectory#/mediaUploads" action = "list" name = "D" recurse = "yes">
	 <CFLOOP QUERY="D">
		<cfif TYPE is "file">

			<cfset fpath=replace(DIRECTORY,'/usr/local/httpd/htdocs/wwwarctos','')>
			<br>fpath: #fpath#
			<cfset qn=fpath & '/' & name>
			<br>qn: #qn#

		</cfif>
	</CFLOOP>

	</cfif>
	<cfif action is "upmuris">
		<cfquery name="d" datasource="uam_god">
			select * from temp_m_f where status ='loaded_to_s3'
			and rownum<100
		</cfquery>
		<cfset f = CreateObject("component","component.functions")>

		<cfloop query="d">
			<hr>
			<br>lcl_p: #lcl_p#
			<br>lcl_p_p: #lcl_p_p#
			<cfset newMediaURI="">
			<cfset newPreviewURI="">
			<cfset newMediaChecksum="">
			<cfset hasExistingCheck=false>
			<cfset probs=false>
			<cfif len(lcl_p) gt 0>
				<br>lcl_p: #lcl_p#
				<br>lcl_p_p: #lcl_p_p#

				<cfset usrnm=lcase(listgetat(lcl_p,1,"/"))>
				<cfset filename=listlast(lcl_p,"/")>
				<cfset lclurl=media_uri>

				<cfset newMediaURI="https://web.corral.tacc.utexas.edu/arctos-s3/#usrnm#/2018-07-25/#filename#">
				<cfset lclchsm=f.genMD5(lclurl)>
				<cfset rmtchsm=f.genMD5(newMediaURI)>
				<br>lclchsm: #lclchsm#
				<br>rmtchsm: #rmtchsm#
				<br>lclurl: #lclurl#
				<br>newMediaURI: #newMediaURI#
				<cfquery name="ckck" datasource="uam_god">
					select LABEL_VALUE from media_labels where MEDIA_LABEL='MD5 checksum' and MEDIA_ID=#MEDIA_ID#
				</cfquery>


				<cfset newMediaChecksum=rmtchsm>

				<cfif lclchsm neq rmtchsm>
					<br>FAIL::nomatch
					<cfset probs=true>
				</cfif>
				<cfif len(ckck.LABEL_VALUE) gt 0>
					<cfset hasExistingCheck=true>
					<cfif ckck.LABEL_VALUE neq lclchsm>
						<cfset probs=true>
						<br>fail:nomatchw/exist
					</cfif>
				</cfif>
			</cfif>

			<cfif len(lcl_p_p) gt 0>
				<cfset usrnm=lcase(listgetat(lcl_p_p,1,"/"))>
				<cfset filename=listlast(lcl_p_p,"/")>
				<cfset lclurl=preview_uri>

				<cfset newPreviewURI="https://web.corral.tacc.utexas.edu/arctos-s3/#usrnm#/2018-07-25/tn/#filename#">
				<cfset lclchsm=f.genMD5(lclurl)>
				<cfset rmtchsm=f.genMD5(newPreviewURI)>
				<br>lclchsm: #lclchsm#
				<br>rmtchsm: #rmtchsm#


				<br>lclurl: #lclurl#
				<br>newPreviewURI: #newPreviewURI#


				<cfif lclchsm neq rmtchsm>
					<br>FAIL::nomatch
					<cfset probs=true>
				</cfif>
			</cfif>

			<p>
				probs: #probs#
			</p>
			<cfif probs is false>
				<cfquery name="upm" datasource="uam_god">
					update media set
					<cfif len(newMediaURI) gt 0>
						media_uri='#newMediaURI#'
					</cfif>
					<cfif len(newPreviewURI) gt 0>
						<cfif len(newMediaURI) gt 0>
							,
						</cfif>
						preview_uri='#newPreviewURI#'
					</cfif>
					where media_id=#media_id#
				</cfquery>
				update media set
					<cfif len(newMediaURI) gt 0>
						media_uri='#newMediaURI#'
					</cfif>
					<cfif len(newPreviewURI) gt 0>
						<cfif len(newMediaURI) gt 0>
							,
						</cfif>
						preview_uri='#newPreviewURI#'
					</cfif>
					where media_id=#media_id#
				<br>
				<cfif hasExistingCheck is false and len(newMediaChecksum) gt 0>
					<cfquery name="iml" datasource="uam_god">
						insert into media_labels (
							MEDIA_LABEL_ID,
							MEDIA_ID,
							MEDIA_LABEL,
							LABEL_VALUE,
							ASSIGNED_BY_AGENT_ID
						) values (
							sq_MEDIA_LABEL_ID.nextval,
							#MEDIA_ID#,
							'MD5 checksum',
							'#newMediaChecksum#',
							2072
						)
					</cfquery>

					insert into media_labels (
						MEDIA_LABEL_ID,
						MEDIA_ID,
						MEDIA_LABEL,
						LABEL_VALUE,
						ASSIGNED_BY_AGENT_ID
					) values (
						sq_MEDIA_LABEL_ID.nextval,
						#MEDIA_ID#,
						'MD5 checksum',
						'#newMediaChecksum#',
						2072
					)

				</cfif>
				<cfquery name="us" datasource="uam_god">
					update temp_m_f set status='move_complete' where media_id=#media_id#
				</cfquery>
			</cfif>
		</cfloop>
	</cfif>

	<cfif action is "cpfls">

		<cfquery name="d" datasource="uam_god">
			select * from temp_m_f where status ='spiffy'
			and rownum<100
		</cfquery>
		<cfquery name="s3" datasource="uam_god" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
			select S3_ENDPOINT,S3_ACCESSKEY,S3_SECRETKEY from cf_global_settings
		</cfquery>
		<cfloop query="d">
			<hr>
			<cfif len(lcl_p) gt 0>
				<br>lcl_p: #lcl_p#
				<!---- make a username bucket. This will create or return an error of some sort. ---->
				<cfset uname=listgetat(lcl_p,1,"/")>
				<br>uname: #uname#
				<cfset currentTime = getHttpTimeString( now() ) />
				<cfset contentType = "text/html" />
				<cfset bucket="#lcase(uname)#">
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
				<cfhttp result="mkunamebkt" method="put" url="#s3.s3_endpoint#/#bucket#">
					<cfhttpparam type="header" name="Authorization" value="AWS #s3.s3_accesskey#:#signature#"/>
				    <cfhttpparam type="header" name="Content-Type" value="#contentType#" />
				    <cfhttpparam type="header" name="Date" value="#currentTime#" />
				</cfhttp>
				<br>mkunamebkt: #mkunamebkt.filecontent#


				<cffile variable="content" action = "readBinary" file="#Application.webDirectory#/mediaUploads/#lcl_p#">

				<cfset filename=listlast(lcl_p,"/")>


				<cfset mimetype="FAIL">
				<cfset mediatype="FAIL">
				<cfset fext=listlast(lcl_p,".")>
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
				</cfif>
				<br>mimetype:#mimetype#
				<br>mediatype:#mediatype#
				<cfset bucket="#lcase(uname)#/#dateformat(now(),'YYYY-MM-DD')#">
				<cfset currentTime = getHttpTimeString( now() ) />
				<cfset contentType=mimetype>
				<cfset contentLength=arrayLen( content )>
				<cfset stringToSignParts = [
				    "PUT",
				    "",
				    contentType,
				    currentTime,
				    "/" & bucket & "/" & fileName
				] />

				<cfset stringToSign = arrayToList( stringToSignParts, chr( 10 ) ) />
				<cfset signature = binaryEncode(
					binaryDecode(
						hmac( stringToSign, s3.s3_secretKey, "HmacSHA1", "utf-8" ),
						"hex"
					),
					"base64"
				)>
				<cfhttp result="putfile" method="put" url="#s3.s3_endpoint#/#bucket#/#fileName#">
					<cfhttpparam type="header" name="Authorization" value="AWS #s3.s3_accesskey#:#signature#"/>
				    <cfhttpparam type="header" name="Content-Length" value="#contentLength#" />
				    <cfhttpparam type="header" name="Content-Type" value="#contentType#"/>
				    <cfhttpparam type="header" name="Date" value="#currentTime#" />
				    <cfhttpparam type="body" value="#content#" />
				</cfhttp>
				<br>putfile: #putfile.filecontent#
			</cfif>

			<cfif len(lcl_p_p) gt 0>
				<br>lcl_p_p: #lcl_p_p#
				<!---- make a username bucket. This will create or return an error of some sort. ---->
				<cfset uname=listgetat(lcl_p_p,1,"/")>
				<br>uname: #uname#
				<cfset currentTime = getHttpTimeString( now() ) />
				<cfset contentType = "text/html" />
				<cfset bucket="#lcase(uname)#">
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
				<cfhttp result="mkunamebkt" method="put" url="#s3.s3_endpoint#/#bucket#">
					<cfhttpparam type="header" name="Authorization" value="AWS #s3.s3_accesskey#:#signature#"/>
				    <cfhttpparam type="header" name="Content-Type" value="#contentType#" />
				    <cfhttpparam type="header" name="Date" value="#currentTime#" />
				</cfhttp>
				<br>mkunamebkt: #mkunamebkt.filecontent#


				<cffile variable="content" action = "readBinary" file="#Application.webDirectory#/mediaUploads/#lcl_p_p#">

				<cfset filename=listlast(lcl_p_p,"/")>


				<cfset mimetype="FAIL">
				<cfset mediatype="FAIL">
				<cfset fext=listlast(lcl_p_p,".")>
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
				</cfif>
				<br>mimetype:#mimetype#
				<br>mediatype:#mediatype#
				<cfset bucket="#lcase(uname)#/#dateformat(now(),'YYYY-MM-DD')#/tn">
				<cfset currentTime = getHttpTimeString( now() ) />
				<cfset contentType=mimetype>
				<cfset contentLength=arrayLen( content )>
				<cfset stringToSignParts = [
				    "PUT",
				    "",
				    contentType,
				    currentTime,
				    "/" & bucket & "/" & fileName
				] />

				<cfset stringToSign = arrayToList( stringToSignParts, chr( 10 ) ) />
				<cfset signature = binaryEncode(
					binaryDecode(
						hmac( stringToSign, s3.s3_secretKey, "HmacSHA1", "utf-8" ),
						"hex"
					),
					"base64"
				)>
				<cfhttp result="putfile" method="put" url="#s3.s3_endpoint#/#bucket#/#fileName#">
					<cfhttpparam type="header" name="Authorization" value="AWS #s3.s3_accesskey#:#signature#"/>
				    <cfhttpparam type="header" name="Content-Length" value="#contentLength#" />
				    <cfhttpparam type="header" name="Content-Type" value="#contentType#"/>
				    <cfhttpparam type="header" name="Date" value="#currentTime#" />
				    <cfhttpparam type="body" value="#content#" />
				</cfhttp>
				<br>putfile: #putfile.filecontent#
			</cfif>

				update temp_m_f set status='loaded_to_s3' where media_id=#media_id#
			<cfquery name="mkup" datasource="uam_god">
				update temp_m_f set status='loaded_to_s3' where media_id=#media_id#
			</cfquery>

		</cfloop>

	</cfif>

















	 <cfif action is "cklcl">
		<cfquery name="d" datasource="uam_god">
			select * from temp_m_f where status is null
		</cfquery>

		<cfloop query="d">
			<cfset s="spiffy">
			<cfif len(lcl_p) gt 0>
				<cfif not FileExists("#Application.webDirectory#/mediaUploads/#lcl_p#")>
					<cfset s=listappend(s,'lcl_p not found')>
				</cfif>
			</cfif>
			<cfif len(lcl_p_p) gt 0>
				<cfif not FileExists("#Application.webDirectory#/mediaUploads/#lcl_p_p#")>
					<cfset s=listappend(s,'lcl_p_p not found')>
				</cfif>
			</cfif>

			<cfquery name="d" datasource="uam_god">
				update temp_m_f set status='#s#' where media_id=#media_id#
			</cfquery>
		</cfloop>
	</cfif>
	 <cfif action is "mklclp">
		<cfquery name="d" datasource="uam_god">
			select * from temp_m_f  where status is null
		</cfquery>
		<cfloop query="d">
			<cfset mf="">
			<cfset pf="">
			<cfif media_uri contains "/mediaUploads/" and media_uri contains "/arctos.database.museum/">
				<cfset mf=media_uri>
				<cfloop from ="1" to="5" index="i">
					<cfif listgetat(mf,1,'/') is not "mediaUploads">
						<cfset mf=listdeleteat(mf,1,'/')>
					</cfif>
				</cfloop>
				<cfset mf=listdeleteat(mf,1,'/')>
				<br>media_uri:#media_uri#
				<br>mf:#mf#
			<cfelse>
				<br>not local
			</cfif>

			<cfif preview_uri contains "/mediaUploads/" and preview_uri contains "/arctos.database.museum/">
				<cfset pf=preview_uri>
				<cfloop from ="1" to="5" index="i">
					<cfif listgetat(pf,1,'/') is not "mediaUploads">
						<cfset pf=listdeleteat(pf,1,'/')>
					</cfif>
				</cfloop>
				<cfset pf=listdeleteat(pf,1,'/')>
				<br>preview_uri:#preview_uri#
				<br>pf:#pf#
			<cfelse>
				<br>not local
			</cfif>
			<cfquery name="d" datasource="uam_god">
				update temp_m_f set lcl_p='#mf#',lcl_p_p='#pf#' where media_id=#media_id#
			</cfquery>
		</cfloop>


	</cfif>
</cfoutput>



<cfinclude template="/includes/_footer.cfm">