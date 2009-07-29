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
	grant all on cf_tacc_transfer to coldfusion_user;
	
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
			<cfdump var="#mHash#">
			<cfinvoke component="/component/functions" method="genMD5" returnVariable="pHash">
				<cfinvokeargument name="returnFormat" value="plain">
				<cfinvokeargument name="uri" value="#preview_uri#">
			</cfinvoke>
			
			<cfdump var="#pHash#">
			<cfquery name="ins" datasource="cf_dbuser">
				insert into cf_tacc_transfer (
					media_id,
					sdate,
					local_uri,
					local_hash,
					local_tn,
					local_tn_hash
				) values (
					#media_id#,
					sysdate,
					'#media_uri#',
					'#mHash#',
					'#preview_uri#',
					'#pHash#'
				)
			</cfquery>
		</cftransaction>
	</cfloop>
</cfif>
<!---------------------------------------------------------------------------------------------------------->
<cfinclude template="/includes/_footer.cfm">