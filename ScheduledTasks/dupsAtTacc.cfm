<!---
create table tacc_dup as select
	barcode,
	folder
	from
	tacc_check
	where barcode in (
		select barcode from tacc_check having count(*) > 1 group by barcode
	);
	
	alter table tacc_dup add checksum varchar2(255);
---->

<cfquery name="d" datasource="uam_god">
	select * from tacc_dup where checksum is null and rownum < 101
</cfquery>
<cfoutput>
	<cfset t=1>	
	<cfloop query="d">
		<cfoutput>
		<br>starting thread for #folder#/#barcode#...
		</cfoutput>
		<cfthread action="run" name="t#t#" folder="#folder#" barcode="#barcode#">
			<cftransaction >
				<cfset uri='http://goodnight.corral.tacc.utexas.edu/UAF/#folder#/#barcode#.dng'>
				<cfinvoke component="/component/functions" method="genMD5" returnVariable="mHash">
					<cfinvokeargument name="returnFormat" value="plain">
					<cfinvokeargument name="uri" value="#uri#">
				</cfinvoke>
				<cfquery name="d" datasource="uam_god">
					update tacc_dup set checksum='#mHash#' where barcode='#barcode#' and folder='#folder#'
				</cfquery>
				<cfquery name="d" datasource="uam_god">
					insert into media_labels (
						MEDIA_ID,
						MEDIA_LABEL,
						LABEL_VALUE,
						ASSIGNED_BY_AGENT_ID
					)  (
						select media_id,
						'MD5 checksum',
						'#mHash#',
						2072
						from media where media_uri='#uri#'
					)
				</cfquery>
			</cftransaction>
		</cfthread>
		<cfset t=t+1>
	</cfloop>
</cfoutput>
