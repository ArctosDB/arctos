<!---
	create table temp_tacc_mpreview (
		media_id number,
		sdate date,
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
--->
<cfinclude template="/includes/_header.cfm">

<cfsetting requesttimeout="300" />
<cfif action is "checkNew">
	<cfquery name="new" datasource="uam_god">
		select * from media where
			preview_uri like '#application.serverRootUrl#%' and
			preview_uri not in (
				select local_tn from temp_tacc_mpreview
			)
	</cfquery>
	<cfloop query="new">
		<cftransaction>
			<cfinvoke component="/component/functions" method="genMD5" returnVariable="mHash">
				<cfinvokeargument name="returnFormat" value="plain">
				<cfinvokeargument name="uri" value="#preview_uri#">
			</cfinvoke>
			<cfquery name="ins" datasource="uam_god">
				insert into temp_tacc_mpreview (
					media_id,
					sdate,
					local_tn,
					local_tn_hash,
					status
				) values (
					#media_id#,
					sysdate,
					'#preview_uri#',
					'#mHash#',
					'new'
				)
			</cfquery>
		</cftransaction>
	</cfloop>
</cfif>
<!---------------------------------------------------------------------------------------------------------->
<cfif action is "transfer">
	<cftransaction>
		<cfquery name="theFile" datasource="uam_god">
			select * from temp_tacc_mpreview where
			status = 'new' and
			rownum<500
		</cfquery>
		<cfif theFile.recordcount eq 0>
			nothing found
			<cfabort>
		</cfif>
		<cfset todaysDirectory=dateformat(now(),"yyyy_mm_dd")>
		<cfset remoteBase="/corral/tg/uaf/arctos">
		<cfset remoteFull=remoteBase & '/' & todaysDirectory>
		
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
		
		   
		<cfloop query="theFile">
			<cftry>
			<cfset localFile=replace(theFile.local_tn,application.serverRootUrl,application.webDirectory)>
			<cfset fileName=listlast(theFile.local_tn,"/")>
			<cfset remoteFile=remoteFull & '/' & fileName>
			<cfftp action="putfile" 
		   	 connection="corral"
			    transferMode = "binary"
				localFile = "#localFile#"
				remoteFile = "#remoteFile#">
			<cfquery name="s" datasource="uam_god">
				update 
					temp_tacc_mpreview 
				set 
					status='transferred',
					remotedirectory='#todaysDirectory#'
				where 
					media_id=#theFile.media_id#
			</cfquery>
			<cfcatch>
				<br>#cfcatch.message#=#cfcatch.detail#
				<cfquery name="s" datasource="uam_god">
					update 
						temp_tacc_mpreview 
					set 
						status='#cfcatch.message#=#cfcatch.detail#',
						remotedirectory='#todaysDirectory#'
					where 
						media_id=#theFile.media_id#
				</cfquery>
			</cfcatch>
			</cftry>
		</cfloop>
		
		<cfftp action="close" 
			connection="corral">
		
	</cftransaction>
</cfif>
<!---------------------------------------------------------------------------------------------------------->
<cfif action is "findIt">
	<cfquery name="f" datasource="uam_god">
		select * from temp_tacc_mpreview where
		status = 'transferred'
		and rownum < 501
	</cfquery>
	<cfdump var=#f#>
	<cfflush>
	<cfset bURL="http://web.corral.tacc.utexas.edu/UAF/arctos">
	<cfoutput>
	<cfset t=1>
	<cfloop query="f">
			<br>start...<cfflush>
			<cfset fileName=listlast(local_tn,"/")>
			<cfset thisURL=bURL & '/' & remotedirectory & '/' & fileName>
			<br>#thisURL#
			<cfthread action="run" name="t#t#" fileName="#fileName#" thisURL="#thisURL#" thisMediaId="#media_id#">
				<cftransaction>
					<cfhttp url="#thisURL#" method="HEAD" />
					<cfif left(cfhttp.statuscode,3) is "200">
						<cfinvoke component="/component/functions" method="genMD5" returnVariable="rHash">
							<cfinvokeargument name="returnFormat" value="plain">
							<cfinvokeargument name="uri" value="#thisURL#">
						</cfinvoke>
						<cfquery name="fit" datasource="uam_god">
							update 
								temp_tacc_mpreview 
							set 
								status='found',
								remote_tn='#thisURL#',
								remote_tn_hash='#rHash#'
							where 
								media_id=#thisMediaId#
						</cfquery>
					<cfelse>
						<cfquery name="fit" datasource="uam_god">
							update 
								temp_tacc_mpreview 
							set 
								status='not found'
							where 
								media_id=#thisMediaId#
						</cfquery>
					</cfif>
				</cftransaction>
			</cfthread>
		<cfset t=t+1>
	</cfloop>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------------->
<cfif action is "fixURI">
	
	<cfquery name="f" datasource="uam_god">
		select * from temp_tacc_mpreview where
		status = 'found'
		and rownum<1000
	</cfquery>
	<cfoutput>
	<cfloop query="f">
		<br>#media_id#
		<cftransaction>
			<cfif len(local_tn) gt 0 and
				len(remote_tn) gt 0 and
				len(local_tn_hash) gt 0 and
				len(remote_tn_hash) gt 0 and
				local_tn_hash is remote_tn_hash>
					<BR>UPDATING
					<cfquery name="fit" datasource="uam_god">
						update media set preview_uri='#remote_tn#' where media_id=#media_id#
					</cfquery>
					<cfquery name="fit" datasource="uam_god">
						update 
							temp_tacc_mpreview 
						set 
							status='complete'
						where 
							media_id=#media_id#
					</cfquery>
			<CFELSE>
				<cfquery name="fit" datasource="uam_god">
					update 
						temp_tacc_mpreview 
					set 
						status='upfail'
					where 
						media_id=#media_id#
				</cfquery>
			</cfif>
		</cftransaction>
	</cfloop>
	</cfoutput>
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