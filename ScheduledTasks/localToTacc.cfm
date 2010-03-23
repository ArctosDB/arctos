<!---
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
--->
<cfinclude template="/includes/_header.cfm">
<cfsetting requesttimeout="300" />
<cfif action is "checkNew">
	<cfquery name="new" datasource="uam_god">
		select * from media where
			media_uri like '#application.serverRootUrl#%' and
			media_uri not in (
				select media_uri from cf_tacc_transfer
			)
	</cfquery>
	<cfloop query="new">
		<cftransaction>
			<cfinvoke component="/component/functions" method="genMD5" returnVariable="mHash">
				<cfinvokeargument name="returnFormat" value="plain">
				<cfinvokeargument name="uri" value="#media_uri#">
			</cfinvoke>
			<cfquery name="ins" datasource="cf_dbuser">
				insert into cf_tacc_transfer (
					media_id,
					sdate,
					local_uri,
					local_hash,
					status
				) values (
					#media_id#,
					sysdate,
					'#media_uri#',
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
<!---------------------------------------------------------------------------------------------------------->
<cfif action is "findIt">
	<cfquery name="f" datasource="cf_dbuser">
		select * from cf_tacc_transfer where
		status = 'transferred'
	</cfquery>
	<cfset bURL="http://goodnight.corral.tacc.utexas.edu/UAF/arctos">
	<cfoutput>
	<cfloop query="f">
		<cftransaction>
			<cfset fileName=listlast(local_uri,"/")>
			<cfset thisURL=bURL & '/' & remotedirectory & '/' & fileName>
			<cfhttp url="#thisURL#" method="HEAD" />
			<cfif left(cfhttp.statuscode,3) is "200">
				<cfinvoke component="/component/functions" method="genMD5" returnVariable="rHash">
					<cfinvokeargument name="returnFormat" value="plain">
					<cfinvokeargument name="uri" value="#thisURL#">
				</cfinvoke>
				<cfquery name="fit" datasource="cf_dbuser">
					update 
						cf_tacc_transfer 
					set 
						status='found',
						remote_uri='#thisURL#',
						remote_hash='#rHash#'
					where 
						media_id=#media_id#
				</cfquery>		
			</cfif>
		</cftransaction>
	</cfloop>
	</cfoutput>
</cfif>
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
<!---------------------------------------------------------------------------------------------------------->
<cfif action is "report">
	<cfoutput>
	<cfquery name="d" datasource="cf_dbuser">
		select status || chr(9) || count(*) c from cf_tacc_transfer
		group by status
	</cfquery>
	<cfmail subject="Media Move Report" to="#Application.PageProblemEmail#" from="media2tacc@#application.fromEmail#" type="html">
		cf_tacc_transfer status:
		<cfloop query="d">
			<br>#c#
		</cfloop>
	</cfmail>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------------->
<cfinclude template="/includes/_footer.cfm">