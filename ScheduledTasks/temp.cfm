<cfinclude template="/includes/_header.cfm">


<cfoutput>

<!----
drop table temp_mp;

create table temp_mp as select media_id,media_uri,PREVIEW_URI from media where PREVIEW_URI is not null;

alter table temp_mp add checkeddate date;
alter table temp_mp add previewfilesize number;
alter table temp_mp add previewstatus varchar2(200);
alter table temp_mp add mediastatus varchar2(200);


create unique index ix_temp_mid on temp_mp(media_id) tablespace uam_idx_1;



 MEDIA_ID							   NOT NULL NUMBER
 MEDIA_URI							   NOT NULL VARCHAR2(255)
 PREVIEW_URI								    VARCHAR2(255)
 CHECKEDDATE								    DATE
 PREVIEWFILESIZE							    NUMBER
 PREVIEWSTATUS								    VARCHAR2(200)
 MEDIASTATUS								    VARCHAR2(200)




select media_id || ': ' || PREVIEWFILESIZE from temp_mp where PREVIEWFILESIZE>15000 order by PREVIEWFILESIZE;
select media_id || ': ' || PREVIEWFILESIZE from temp_mp where PREVIEWFILESIZE>64000 order by PREVIEWFILESIZE;


select PREVIEWSTATUS,count(*) from temp_mp group by PREVIEWSTATUS;

select media_id from temp_mp where previewstatus = '404';


select mediastatus,count(*) from temp_mp group by mediastatus;

 select count(*) from temp_mp where checkeddate is not null;


---->




	<cfquery name="d" datasource="uam_god">
		select * from temp_mp where checkeddate is null and rownum<500
	</cfquery>
	<cfloop query="d">
		<cfhttp method="head" timeout="2" url="#PREVIEW_URI#"></cfhttp>
		<cftry>
			<cfset pfs=cfhttp.Responseheader["Content-Length"]>
			<cfcatch>
				<cfset pfs=0>
			</cfcatch>
		</cftry>
		<cftry>
			<cfset ps=cfhttp.Responseheader.Status_Code>
			<cfcatch>
				<cfset ps='caught_error'>
			</cfcatch>
		</cftry>
		<cfif media_uri contains 'http://web.corral.tacc.utexas.edu'>
			<cfset ms='on_tacc_nocheck'>
		<cfelse>
			<cfhttp method="head" timeout="2" url="#media_uri#"></cfhttp>
			<cftry>
				<cfset ms=cfhttp.Responseheader["Status_Code"]>
				<cfcatch>
					<cfset ms='caught_error'>
				</cfcatch>
			</cftry>
		</cfif>
		
		<cfquery name="u" datasource="uam_god">
			update 
				temp_mp 
			set 
				checkeddate=sysdate,
				previewfilesize=#pfs#,
				previewstatus='#ps#',
				mediastatus='#ms#'
			where 
				media_id=#media_id#
		</cfquery>
	</cfloop>
</cfoutput>