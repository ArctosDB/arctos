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
--->
<cfinclude template="/includes/_header.cfm">
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
			<cfinvoke component="/component/functions" method="genMD5" returnVariable="pHash">
				<cfinvokeargument name="returnFormat" value="plain">
				<cfinvokeargument name="uri" value="#preview_uri#">
			</cfinvoke>
			<cfquery name="ins" datasource="cf_dbuser">
				insert into cf_tacc_transfer (
					media_id,
					sdate,
					local_uri,
					local_hash,
					local_tn,
					local_tn_hash,
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
		<cfset remoteBase="/home/01030/dustylee">
		<cfset remoteFull=remoteBase & '/' & todaysDirectory>
		<cfset remoteFile=remoteFull & '/' & fileName>
		
		<cfftp action="open" 
			username="dustylee" 
			server="Garcia.corral.tacc.utexas.edu" 
			connection="corral"
			secure="true"
			key="/opt/coldfusion8/runtime/bin/id_rsa">
		
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
	<cfset bURL="http://goodnight.corral.tacc.utexas.edu/UAF">
	<cfloop query="f">
		<cftransaction>
			<cfset fileName=listlast(local_uri,"/")>
			<cfset thisURL=bURL & '/' & remotedirectory & '/' & fileName>
			<cfhttp url="#thisURL#" method="get" getAsBinary="yes">
			</cfhttp>
			<cfdump var="#cfhttp#">
		</cftransaction>
	</cfloop>
</cfif>
<!---------------------------------------------------------------------------------------------------------->
<cfif action is "checkTransfer">
	<cfquery name="f" datasource="cf_dbuser">
		select * from cf_tacc_transfer where
		status = 'online'
	</cfquery>
	<cfloop query="f">
		<cftransaction>
			<cfinvoke component="/component/functions" method="genMD5" returnVariable="mHash">
				<cfinvokeargument name="returnFormat" value="plain">
				<cfinvokeargument name="uri" value="#remote_uri#">
			</cfinvoke>
		</cftransaction>
	</cfloop>
</cfif>
<!---------------------------------------------------------------------------------------------------------->
<cfinclude template="/includes/_footer.cfm">