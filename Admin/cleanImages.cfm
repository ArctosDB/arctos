<cfinclude template="/includes/_header.cfm">
<cfsetting requesttimeout="600">
<!---
	modify for final cleanup in move to S3
	old version is in v7.9.6
---->


<!----

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

---->

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



	<cfif action is "cpfls">
		<cfquery name="d" datasource="uam_god">
			select * from temp_m_f where status ='spiffy'
			--and rownum<2
		</cfquery>
		<cfquery name="s3" datasource="uam_god" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
			select S3_ENDPOINT,S3_ACCESSKEY,S3_SECRETKEY from cf_global_settings
		</cfquery>
		<cfloop query="d">
			<cfif len(lcl_p) gt 0>
				<br>lcl_p: #lcl_p#
				<!---- make a username bucket. This will create or return an error of some sort. ---->
				<cfset uname=listgetat(lcl_p,1,"/")>
				<br>uname: #uname#
				<!----------
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
				<cffile variable="content" action = "readBinary" file="#Application.webDirectory#/mediaUploads/#lcl_p#">
				---------->
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
			</cfif>
		</cfloop>

		<!----------




		<cfset tempName=createUUID()>
		<cffile action="upload"	destination="#Application.sandbox#/" nameConflict="overwrite" fileField="file" mode="600">
		<cfset fileName=cffile.serverfile>
		<cffile action = "rename" destination="#Application.sandbox#/#tempName#.tmp" source="#Application.sandbox#/#fileName#">
		<cfset fext=listlast(fileName,".")>
		<cfset fName=listdeleteat(fileName,listlen(filename,'.'),'.')>
		<cfset fName=REReplace(fName,"[^A-Za-z0-9_$]","_","all")>
		<cfset fName=replace(fName,'__','_','all')>
		<cfset fileName=fName & '.' & fext>
		<cfset vfn=isValidMediaUpload(fileName)>
		<cfif len(vfn) gt 0>
			<cfset r.statusCode=400>
			<cfset r.msg=vfn>
			<cfreturn serializeJSON(r)>
		</cfif>
		<cfset lclFile="#Application.sandbox#/#fileName#">


		<!--- generate a checksum while we're holding the binary ---->
		<cfset md5 = createObject("component","includes.cfc.hashBinary").hashBinary(content)>
		<!--- see if the image exists ---->
		<cfquery name="ckck" datasource="uam_god">
			select media_id from media_labels where MEDIA_LABEL='MD5 checksum' and LABEL_VALUE='#md5#'
		</cfquery>
		<cfif ckck.recordcount gt 0>
			<cfset r.statusCode=400>
			<cfset r.msg='Media Exists'>
			<cfloop list="#valuelist(ckck.media_id)#" index="i">
				<cfset r.msg=r.msg & '\n#Application.serverRootURL#/media/#i#'>
			</cfloop>
			<cfset r.msg=r.msg & '\nUse the "link to existing" option'>
			<cfreturn serializeJSON(r)>
		</cfif>


		<cfset r.md5=md5>
		<!----
			this does not work properly; Adobe ColdFusion thinks Adobe DNGs are TIFFs
			<cfset mimetype=FilegetMimeType("#Application.sandbox#/#tempName#.tmp")>
			<cfset r.mimetype=mimetype>
		 ---->
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
			<cfset r.statusCode=400>
			<cfset r.msg='Invalid filetype: could not determine mime or media type.'>
			<cfreturn serializeJSON(r)>
		</cfif>

		<cfset r.media_type=mediatype>
		<cfset r.mime_type=mimetype>

		<!--- now load the file ---->
		<!--- "virtual" date-bucket inside the username bucket ---->
		<cfset bucket="#lcase(session.username)#/#dateformat(now(),'YYYY-MM-DD')#">
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
		<cfset media_uri = "https://web.corral.tacc.utexas.edu/arctos-s3/#bucket#/#fileName#">

		<cfif IsImageFile("#Application.sandbox#/#tempName#.tmp")>
			<!---- make a thumbnail ---->
			<cfimage action="info" structname="imagetemp" source="#Application.sandbox#/#tempName#.tmp">
			<cfset x=min(180/imagetemp.width, 180/imagetemp.height)>
			<cfset newwidth = x*imagetemp.width>
	    	<cfset newheight = x*imagetemp.height>
		    <cfset barefilename=listgetat(filename,1,".")>
		    <cfset tfilename="tn_#barefilename#.jpg">
		   	<cfimage action="convert" source="#Application.sandbox#/#tempName#.tmp" width="#newwidth#" height="#newheight#" destination="#Application.sandbox#/#tfilename#" overwrite = "true">
		   	<cfimage action="resize" source="#Application.sandbox#/#tfilename#" width="#newwidth#" height="#newheight#" destination="#Application.sandbox#/#tfilename#" overwrite = "true">
		   	<cfset bucket="#lcase(session.username)#/#dateformat(now(),'YYYY-MM-DD')#/tn">
			<cfset currentTime = getHttpTimeString( now() ) />
			<cfset contentType = "image/jpeg" />
			<cffile variable="content" action = "readBinary"  file="#Application.sandbox#/#tfilename#">
			<cfset contentLength=arrayLen( content )>
			<cfset stringToSignParts = [
			    "PUT",
			    "",
			    contentType,
			    currentTime,
			    "/" & bucket & "/" & tfilename
			] />
			<cfset stringToSign = arrayToList( stringToSignParts, chr( 10 ) ) />
			<cfset signature = binaryEncode(
				binaryDecode(
					hmac( stringToSign, s3.s3_secretKey, "HmacSHA1", "utf-8" ),
					"hex"
				),
				"base64"
			)>
			<cfhttp result="putTN" method="put" url="#s3.s3_endpoint#/#bucket#/#tfilename#">
				<cfhttpparam type="header" name="Authorization" value="AWS #s3.s3_accesskey#:#signature#"/>
			    <cfhttpparam type="header" name="Content-Length"  value="#contentLength#" />
			    <cfhttpparam type="header" name="Content-Type"  value="#contentType#" />
			    <cfhttpparam type="header" name="Date" value="#currentTime#" />
			    <cfhttpparam type="body" value="#content#" />
			</cfhttp>
			<cfset r.preview_uri = "https://web.corral.tacc.utexas.edu/arctos-s3/#bucket#/#tfilename#">
		<cfelse>
			<cfset r.preview_uri="">
		</cfif>
		<!--- statuscode of putting the actual file - the important thing--->
	    <cfset r.statusCode=left(putfile.statusCode,3)>
		<cfset r.filename="#fileName#">
		<cfset r.media_uri="#media_uri#">
			<cfcatch>
				<cfset r.statusCode=444>
				<cfset r.msg=cfcatch.message & '; ' & cfcatch.detail>
				<cfif isdefined("putTN")>
					<cfset r.putTN=putTN>
				</cfif>
				<cfif isdefined("putfile")>
					<cfset r.putfile=putfile>
				</cfif>
				<cfif isdefined("mkunamebkt")>
					<cfset r.mkunamebkt=mkunamebkt>
				</cfif>
			</cfcatch>
	</cftry>
	<cfreturn serializeJSON(r)>
</cffunction>
------------->
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