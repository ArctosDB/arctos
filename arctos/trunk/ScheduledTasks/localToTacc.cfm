
edit code to run this<cfabort>


<!----
	create table cf_tacc_transfer (
		media_id number,
		sdate date,
		local_uri varchar2(4000),
		remote_uri varchar2(4000),
		local_hash varchar2(255),
		remote_hash varchar2(255),
		local_tn varchar2(4000),
		remote_tn varchar2(4000),
		local_tn_hash varchar2(255),
		remote_tn_hash varchar2(255)
	);
	create or replace public synonym cf_tacc_transfer for cf_tacc_transfer;
	revoke all on cf_tacc_transfer from coldfusion_user;
	grant all on cf_tacc_transfer to cf_dbuser;

	alter table cf_tacc_transfer add status varchar2(255);

	alter table cf_tacc_transfer add remotedirectory varchar2(30);

	create unique index idx_u_cf_tacc_transfer_mid on cf_tacc_transfer (media_id) tablespace uam_idx_1;


	UPDATE: Running this FROM TACC now, transfers are via irond/unix/whatever, just change URLs

	delete from cf_tacc_transfer;

	---->
<cfinclude template="/includes/_header.cfm">


<br><a href="localToTacc.cfm?action=checkNew">checkNew</a> - do this first; it finds stuff we care about and builds checksums for "local" junk
<br><a href="localToTacc.cfm?action=findCheckNewFile">findCheckNewFile</a> - do this second, it builds checksums for "remote" files

<br><a href="localToTacc.cfm?action=checkchecksum">checkchecksum</a> - do this third, it checks that everything is happy


<br><a href="localToTacc.cfm?action=showstatus">showstatus</a> - wut?
<br><a href="localToTacc.cfm?action=showfail">showfail</a> - oops
<br><a href="localToTacc.cfm?action=resetproblem">resetproblem</a> - try again
<br><a href="localToTacc.cfm?action=show_checksummatch">show_checksummatch</a> - caution this might break your browser
<br><a href="localToTacc.cfm?action=updateMedia">updateMedia</a> - I do hereby solemnly swear that nothing is jacked up, change real stuff




<cfsetting requesttimeout="300" />



<!---------------------------------------------------------------------------------------------------------->

<cfif action is "show_checksummatch">
	<cfquery name="d" datasource="cf_dbuser">
		 select * from  cf_tacc_transfer where status = 'checksummatch'
	</cfquery>
	<cfoutput>
	<cfloop query="d">
		<br>LOCAL_URI:  #LOCAL_URI#
		<br>REMOTE_URI: #REMOTE_URI#
		<br>LOCAL_TN:  #LOCAL_TN#
		<br>REMOTE_TN: #REMOTE_TN#
		<hr>
	</cfloop>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------------->
<cfif action is "updateMedia">
	<cfquery name="d" datasource="uam_god">
		select * from cf_tacc_transfer where status = 'checksummatch'
	</cfquery>
	<cfoutput>
		<cfloop query="d">
			<cftransaction>
				<cfquery name="upm" datasource="uam_god">
					update media set
						media_uri='#REMOTE_URI#',
						preview_uri='#LOCAL_TN#'
					where
						media_id=#media_id#
				</cfquery>
				<cfquery name="upc" datasource="uam_god">
					update cf_tacc_transfer set status='media_updated' where media_id=#media_id#
				</cfquery>
				<br>updated for #media_id#
			</cftransaction>
		</cfloop>
	</cfoutput>
</cfif>
<cfif action is "checkchecksum">

	<!--- these claim to have everything mapped out ---->
	<cfquery name="prep" datasource="cf_dbuser">
		 update cf_tacc_transfer set status='preparing_checksum_check' where status = 'remotefound'
	</cfquery>



	<!---- check for
				1) local url exists
				2) remote url exists
				3) local checksum exists
				4) remote checksum exists
				5) local checksum = remote checksum
				IF there's a preview (local preview_url exists) THEN
					6) local preview checksum exists
					7) remote preview_url exists
					8) remote preview checksum exists
					9) local preview checksum = remote preview checksum


	---->




	<!--- 1 and 2---->
	<cfquery name="nocheckfile" datasource="cf_dbuser">
		 update cf_tacc_transfer set status='missing URL' where status = 'preparing_checksum_check' and
		 (
		 	LOCAL_URI is null or
		 	REMOTE_URI is null
		 )
	</cfquery>

	<!--- 3 ---->
	<cfquery name="nocheckfile" datasource="cf_dbuser">
		 update cf_tacc_transfer set status='missing checksum for local URL' where status = 'preparing_checksum_check' and
		 LOCAL_HASH is null
	</cfquery>
	<!--- 4 ---->
	<cfquery name="nocheckfile" datasource="cf_dbuser">
		 update cf_tacc_transfer set status='missing checksum for remote URL' where status = 'preparing_checksum_check' and
		 REMOTE_HASH is null
	</cfquery>

	<!---- 5 ---->
	<cfquery name="d" datasource="cf_dbuser">
		 update cf_tacc_transfer set status='checksum mismatch' where status = 'preparing_checksum_check' and
		 LOCAL_HASH != REMOTE_HASH
	</cfquery>

	<!--- 6 ---->
	<cfquery name="nocheckfile" datasource="cf_dbuser">
		 update cf_tacc_transfer set status='missing checksum for local preview' where status = 'preparing_checksum_check' and
		 LOCAL_TN is not null and
		 LOCAL_TN_HASH is null
	</cfquery>
	<!--- 7 ---->
	<cfquery name="nocheckfile" datasource="cf_dbuser">
		 update cf_tacc_transfer set status='missing checksum for local preview' where status = 'preparing_checksum_check' and
		 LOCAL_TN is not null and
		 REMOTE_TN is null
	</cfquery>
	<!--- 8 ---->
	<cfquery name="nocheckfile" datasource="cf_dbuser">
		 update cf_tacc_transfer set status='missing checksum for local preview' where status = 'preparing_checksum_check' and
		 LOCAL_TN is not null and
		 REMOTE_TN_HASH is null
	</cfquery>
	<!--- 9 ---->
	<cfquery name="nocheckfile" datasource="cf_dbuser">
		 update cf_tacc_transfer set status='missing checksum for local preview' where status = 'preparing_checksum_check' and
		 LOCAL_TN is not null and
		 REMOTE_TN_HASH != LOCAL_TN_HASH
	</cfquery>


	<!--- anything that did NOT get caught in the above should be ready to rock ---->
	<cfquery name="d" datasource="cf_dbuser">
		 update cf_tacc_transfer set status='checksummatch' where status = 'preparing_checksum_check'
	</cfquery>

	<br>checkchecksum done
</cfif>

<!---------------------------------------------------------------------------------------------------------->


<cfif action is "showstatus">
	<cfquery name="d" datasource="cf_dbuser">
		 select status,count(*) c from cf_tacc_transfer group by status
	</cfquery>
	<cfdump var=#d#>
</cfif>
<!---------------------------------------------------------------------------------------------------------->

<cfif action is "showfail">
	<cfquery name="d" datasource="cf_dbuser">
		 select local_uri,remote_uri from cf_tacc_transfer where status like 'problem:%'
	</cfquery>
	<cfdump var=#d#>
</cfif>

<!---------------------------------------------------------------------------------------------------------->

<cfif action is "resetproblem">
	<cfquery name="d" datasource="cf_dbuser">
		 update cf_tacc_transfer set status='new' where status like 'problem:%'
	</cfquery>
	<br>done
</cfif>


<!---------------------------------------------------------------------------------------------------------->

<cfif action is "checkNew">
	<cfquery name="new" datasource="uam_god">
		select * from media where
			media_uri like '#application.serverRootUrl#%' and
			media_uri not in (
				select local_uri from cf_tacc_transfer
			)
	</cfquery>
	<cfloop query="new">
		<cftransaction>
			<cfinvoke component="/component/functions" method="genMD5" returnVariable="mHash">
				<cfinvokeargument name="returnFormat" value="plain">
				<cfinvokeargument name="uri" value="#media_uri#">
			</cfinvoke>
			<cfif len(preview_uri) gt 0>
				<cfinvoke component="/component/functions" method="genMD5" returnVariable="pHash">
					<cfinvokeargument name="returnFormat" value="plain">
					<cfinvokeargument name="uri" value="#preview_uri#">
				</cfinvoke>
			<cfelse>
				<cfset pHash='NOPREVIEW'>
			</cfif>

			<cfquery name="ins" datasource="cf_dbuser">
				insert into cf_tacc_transfer (
					media_id,
					sdate,
					local_uri,
					local_hash,
					LOCAL_TN,
					LOCAL_TN_HASH,
					status
				) values (
					#media_id#,
					sysdate,
					'#media_uri#',
					'#mHash#',
					'#preview_uri#',
					'#pHash#',
					'new'
				)
			</cfquery>
		</cftransaction>
	</cfloop>
</cfif>
<!---------------------------------------------------------------------------------------------------------->
<cfif action is "findCheckNewFile">
	<cfquery name="f" datasource="cf_dbuser">
		select * from cf_tacc_transfer where
		status = 'new'
	</cfquery>
	<cfset remoteBaseURL="http://web.corral.tacc.utexas.edu/UAF/arctos/mediaUploads/">
	<cfset localBaseURL="http://arctos.database.museum/mediaUploads/">
	<cfoutput>
	<cfloop query="f">
		<cftransaction>

			<!--- just replace old directory structure with new ---->

			<cfset remoteMediaURL=replace(local_uri,localBaseURL,remoteBaseURL)>
			<cfset remotePreviewURL=replace(LOCAL_TN,localBaseURL,remoteBaseURL)>

			<cfset remote_status="">
			<cfset remote__previewstatus="">

			<cfhttp url="#remoteMediaURL#" method="HEAD" />

			<cfif left(cfhttp.statuscode,3) is "200">
				<cfinvoke component="/component/functions" method="genMD5" returnVariable="rHash">
					<cfinvokeargument name="returnFormat" value="plain">
					<cfinvokeargument name="uri" value="#remoteMediaURL#">
				</cfinvoke>

				<cfif len(LOCAL_TN) gt 0>
					<cfhttp url="#remotePreviewURL#" method="HEAD" />
					<cfif left(cfhttp.statuscode,3) is "200">
						<cfinvoke component="/component/functions" method="genMD5" returnVariable="pHash">
							<cfinvokeargument name="returnFormat" value="plain">
							<cfinvokeargument name="uri" value="#remotePreviewURL#">
						</cfinvoke>
					<cfelse>
						<cfset remote__previewstatus=cfhttp.statuscode>
					</cfif>
				</cfif>
			<cfelse>
				<cfset remote_status=cfhttp.statuscode>
			</cfif>
			<cfif len(remote_status) is 0 and len(remote__previewstatus) is 0>
				<cfquery name="fit" datasource="cf_dbuser">
					update
						cf_tacc_transfer
					set
						status='remotefound',
						remote_uri='#remoteMediaURL#',
						remote_hash='#rHash#',
						REMOTE_TN='#remotePreviewURL#',
						REMOTE_TN_HASH='#pHash#'
					where
						media_id=#media_id#
				</cfquery>
			<cfelse>
				<br>FAIL
				<br>LOCAL_URI: #LOCAL_URI#
				<br>remoteMediaURL: #remoteMediaURL#
				<br>LOCAL_TN: #LOCAL_TN#
				<br>remotePreviewURL: #remotePreviewURL#

				<br>remote_status: #remote_status#
				<br>remote__previewstatus: #remote__previewstatus#

				<cfquery name="fit" datasource="cf_dbuser">
					update
						cf_tacc_transfer
					set
						status='problem: remote_status=#remote_status#; remote__previewstatus=#remote__previewstatus#'
					where
						media_id=#media_id#
				</cfquery>
			</cfif>


		</cftransaction>
	</cfloop>
	</cfoutput>
</cfif>



<!----
<!---------------------------------------------------------------------------------------------------------->
<cfif action is "fixURI">
	<cfquery name="f" datasource="cf_dbuser">
		select * from cf_tacc_transfer where
		status = 'found'
	</cfquery>
	<cfloop query="f">
		<cftransaction>
			<cfif len(local_uri) gt 0 and
				len(remote_uri) gt 0 and
				len(local_hash) gt 0 and
				len(remote_hash) gt 0 and
				local_hash is remote_hash>
				<cfquery name="isHash" datasource="uam_god">
					select LABEL_VALUE from media_labels where
					media_id=#media_id# and
					MEDIA_LABEL= 'MD5 checksum'
				</cfquery>
				<cfif isHash.recordcount is 1 and isHash.LABEL_VALUE is not remote_hash>
					<cfquery name="fit" datasource="uam_god">
						update
							cf_tacc_transfer
						set
							status='hash_collision'
						where
							media_id=#media_id#
					</cfquery>
				<cfelseif isHash.recordcount gt 1>
					<cfquery name="fit" datasource="uam_god">
						update
							cf_tacc_transfer
						set
							status='multiple_hash_label'
						where
							media_id=#media_id#
					</cfquery>
				<cfelseif isHash.recordcount is 1 and isHash.LABEL_VALUE is remote_hash>
					<cfquery name="fit" datasource="uam_god">
						update media set media_uri='#remote_uri#' where media_id=#media_id#
					</cfquery>
					<cfquery name="fit" datasource="uam_god">
						update
							cf_tacc_transfer
						set
							status='complete'
						where
							media_id=#media_id#
					</cfquery>
				<cfelseif isHash.recordcount is 0>
					<cfquery name="newLBL" datasource="uam_god">
						insert into media_labels (
							media_id,
							media_label,
							label_value,
							assigned_by_agent_id
						) values (
							#media_id#,
							'MD5 checksum',
							'#remote_hash#',
							0
						)
					</cfquery>
					<cfquery name="fit" datasource="uam_god">
						update media set media_uri='#remote_uri#' where media_id=#media_id#
					</cfquery>
					<cfquery name="fit" datasource="uam_god">
						update
							cf_tacc_transfer
						set
							status='complete'
						where
							media_id=#media_id#
					</cfquery>
				</cfif>
			<cfelse>
				<cfquery name="fit" datasource="uam_god">
					update
						cf_tacc_transfer
					set
						status='hash_fail'
					where
						media_id=#media_id#
				</cfquery>
			</cfif>
		</cftransaction>
	</cfloop>
</cfif>
<cfif action is "recoverDisk">
<cfabort>
<cfoutput>
	<!--- local files are loaded to /SpecimenImages or mediaUploads. Find stuff there that's not in media and delete it --->
	<cfdirectory action="LIST"
    	directory="#Application.webDirectory#/SpecimenImages"
        name="root"
		recurse="yes">
	<cfloop query="root">
		<cfif type is "file">
			<br>found #directory#/#name#
			<cfset webpath=replace(directory,application.webDirectory,application.serverRootUrl) & "/" & name>
			<br>webpath: #webpath#
			<cfquery name="isUsed" datasource="uam_god">
				select media_id from media where
					(
						media_uri='#webpath#' or
						preview_uri='#webpath#'
					)
			</cfquery>
			<br>isUsed.recordcount: #isUsed.recordcount#
			<cfif isUsed.recordcount is 0>
				<br>going to delete
				<cffile action="delete" file="#directory#/#name#">
			</cfif>
		<cfelse>
			<cfdirectory action="list" directory="#directory#/#name#" name="current">
			<br> got a directory #directory#/#name# containing #current.recordcount# files
			<cfif current.recordcount is 0>
				<br>deleting it
				<cfdirectory action="delete" directory="#directory#/#name#">
			</cfif>


		</cfif>
	</cfloop>

	<cfdirectory action="LIST"
    	directory="#Application.webDirectory#/mediaUploads"
        name="root"
		recurse="yes">
	<cfloop query="root">
		<cfif type is "file">
			<br>found #directory#/#name#
			<cfset webpath=replace(directory,application.webDirectory,application.serverRootUrl) & "/" & name>
			<br>webpath: #webpath#
			<cfquery name="isUsed" datasource="uam_god">
				select media_id from media where
					(
						media_uri='#webpath#' or
						preview_uri='#webpath#'
					)
			</cfquery>
			<br>isUsed.recordcount: #isUsed.recordcount#
			<cfif isUsed.recordcount is 0>
				<br>going to delete
				<cfif (dateCompare(dateAdd("d",7,datelastmodified),now()) LTE 0) and left(name,1) neq ".">
				 	<cffile action="delete" file="#directory#/#name#">
				 </cfif>
			</cfif>
		<cfelse>
			<cfdirectory action="list" directory="#directory#/#name#" name="current">
			<br> got a directory #directory#/#name# containing #current.recordcount# files
			<cfif current.recordcount is 0>
				<br>deleting it
				<cfif (dateCompare(dateAdd("d",7,datelastmodified),now()) LTE 0) and left(name,1) neq ".">
				 	<cffile action="delete" file="#directory#/#name#">
				 </cfif>
			</cfif>
		</cfif>
	</cfloop>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------------->
<cfif action is "report">
	<cfoutput>
	<cfquery name="d" datasource="cf_dbuser">
		select status || chr(9) || count(*) c from cf_tacc_transfer
		group by status
	</cfquery>
	<cfmail subject="Media Move Report" to="#Application.bugReportEmail#" from="media2tacc@#application.fromEmail#" type="html">
		cf_tacc_transfer status:
		<cfloop query="d">
			<br>#c#
		</cfloop>
	</cfmail>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------------->


---->
<cfinclude template="/includes/_footer.cfm">




<!----------------------------------------------------------------------------------------
<cfif action is "transfer">
	<cftransaction>
		<cfquery name="theFile" datasource="cf_dbuser">
			select * from cf_tacc_transfer where
			status = 'new' and
			rownum=1
		</cfquery>
		<cfif theFile.recordcount is not 1>
			nothing found
			<cfabort>
		</cfif>
		<cfset localFile=replace(theFile.local_uri,application.serverRootUrl,application.webDirectory)>
		<cfset fileName=listlast(theFile.local_uri,"/")>
		<cfset todaysDirectory=dateformat(now(),"yyyy_mm_dd")>
		<cfset remoteBase="/corral/tg/uaf/arctos">
		<cfset remoteFull=remoteBase & '/' & todaysDirectory>
		<cfset remoteFile=remoteFull & '/' & fileName>
		<cfftp action="open"
			username="dustylee"
			server="Garcia.corral.tacc.utexas.edu"
			connection="corral"
			secure="true"
			key="/opt/coldfusion8/runtime/bin/id_rsa"
		    timeout="300">
		<cfftp action="ListDir"
			directory="#remoteBase#"
			connection="corral"
			name="ld">
		<cfquery name="chk" dbtype="query">
			select NAME from ld where ISDIRECTORY='YES' and NAME='#todaysDirectory#'
		</cfquery>
		<cfif len(chk.name) is 0>
			<cfftp action="CreateDir"
				directory="#remoteFull#"
				connection="corral">
		</cfif>
		<cfftp action="putfile"
		    connection="corral"
		    transferMode = "binary"
			localFile = "#localFile#"
			remoteFile = "#remoteFile#">
		<cfftp action="close"
			connection="corral">
		<cfquery name="s" datasource="cf_dbuser">
			update
				cf_tacc_transfer
			set
				status='transferred',
				remotedirectory='#todaysDirectory#'
			where
				media_id=#theFile.media_id#
		</cfquery>
	</cftransaction>
</cfif>
------------------>