<!----
create table temp_geo_wkt (
	geog_auth_rec_id number,
	media_id number,
	status varchar2(255)
);

alter table temp_geo_wkt add file_up_uri varchar2(4000);
alter table temp_geo_wkt add md5 varchar2(4000);


insert into temp_geo_wkt (geog_auth_rec_id) (select geog_auth_rec_id from geog_auth_rec where WKT_POLYGON is not null);

select count(*) from geog_auth_rec where WKT_POLYGON like 'MEDIA%';

update temp_geo_wkt set status='is_media' where geog_auth_rec_id in (select geog_auth_rec_id from geog_auth_rec where WKT_POLYGON like 'MEDIA%');


update temp_geo_wkt set status='happy',file_up_uri='https://web.corral.tacc.utexas.edu/arctos-s3/dlm/2019-05-21/geo_wkt_1002608.wkt' where geog_auth_rec_id=1002608;


select status,count(*) from temp_geo_wkt group by status;


create table bak_geog_auth_rec20190521 as select * from geog_auth_rec;

---->
<cfoutput>

<!--- blargh rules --->
	exec pause_maintenance('off');
	lock table geog_auth_rec in exclusive mode nowait;
	alter trigger TRG_HIGHER_GEOG_MAGICDUPS disable;
	alter trigger TR_GEOGAUTHREC_AU_FLAT disable;
	alter trigger TRG_MK_HIGHER_GEOG disable;
	alter trigger TR_LOG_GEOG_UPDATE disable;







	begin
		for r in (	select geog_auth_rec_id,media_id from temp_geo_wkt where status ='made_media' and rownum<2000) loop
			dbms_output.put_line(r.geog_auth_rec_id);
			update geog_auth_rec set WKT_POLYGON='MEDIA::' || r.media_id where geog_auth_rec_id=r.geog_auth_rec_id;
			update temp_geo_wkt set status='linked_made_media' where geog_auth_rec_id=r.geog_auth_rec_id;
		end loop;
	end;
	/

	alter trigger TRG_HIGHER_GEOG_MAGICDUPS enable;
	alter trigger TR_GEOGAUTHREC_AU_FLAT enable;
	alter trigger TRG_MK_HIGHER_GEOG enable;
	alter trigger TR_LOG_GEOG_UPDATE enable;

	commit;
		exec pause_maintenance('on');



-- make this easy and unambiguous

alter table geog_auth_rec add wkt_media_id number;

select distinct to_number(trim(DBMS_LOB.SUBSTR(wkt_polygon,500,8))) from geog_auth_rec;

ALTER TABLE geog_auth_rec ADD CONSTRAINT fk_geog_wkt_media FOREIGN KEY (wkt_media_id)   REFERENCES media (media_id);


	exec pause_maintenance('off');
	lock table geog_auth_rec in exclusive mode nowait;
	alter trigger TRG_HIGHER_GEOG_MAGICDUPS disable;
	alter trigger TR_GEOGAUTHREC_AU_FLAT disable;
	alter trigger TRG_MK_HIGHER_GEOG disable;
	alter trigger TR_LOG_GEOG_UPDATE disable;



update geog_auth_rec set wkt_media_id=to_number(trim(DBMS_LOB.SUBSTR(wkt_polygon,500,8))) ;


	alter trigger TRG_HIGHER_GEOG_MAGICDUPS enable;
	alter trigger TR_GEOGAUTHREC_AU_FLAT enable;
	alter trigger TRG_MK_HIGHER_GEOG enable;
	alter trigger TR_LOG_GEOG_UPDATE enable;

	commit;
		exec pause_maintenance('on');

 DBMS_LOB.SUBSTR(wkt_polygon,10),


	three: update geog to use media


<cfquery name="d" datasource='uam_god'>
	select geog_auth_rec_id,media_id from temp_geo_wkt where status ='made_media' and rownum<2
</cfquery>
<cfloop query="d">
<br>	#geog_auth_rec_id#
<cfquery name="u" datasource='uam_god'>
	update geog_auth_rec set WKT_POLYGON='MEDIA::#media_id#' where geog_auth_rec_id=#geog_auth_rec_id#
</cfquery>

<cfquery name="ml" datasource='uam_god'>
	update temp_geo_wkt set status='linked_made_media' where geog_auth_rec_id=#geog_auth_rec_id#
</cfquery>
</cfloop>


	<!--------------
part deux: make some Media

<cfquery name="d" datasource='uam_god'>
	select md5, file_up_uri, WKT_POLYGON,geog_auth_rec.geog_auth_rec_id,geog_auth_rec.higher_geog from geog_auth_rec,temp_geo_wkt where geog_auth_rec.geog_auth_rec_id=temp_geo_wkt.geog_auth_rec_id and
	status ='happy' and rownum<2000
</cfquery>
<cfloop query="d">
	<cftransaction>
		<cfquery name="mid" datasource='uam_god'>
			select sq_MEDIA_ID.nextval mid from dual
		</cfquery>
		<br>making #mid.mid#
		<cfquery name="mm" datasource='uam_god'>
			insert into media (
				MEDIA_ID,
				MEDIA_URI,
				MIME_TYPE,
				MEDIA_TYPE
			) values (
				#mid.mid#,
				'#d.file_up_uri#',
				'text/plain',
				'text'
			)
		</cfquery>
		<cfquery name="mr" datasource='uam_god'>
			insert into media_relations (
				MEDIA_RELATIONS_ID,
				MEDIA_ID,
				MEDIA_RELATIONSHIP,
				CREATED_BY_AGENT_ID,
				RELATED_PRIMARY_KEY,
				CREATED_ON_DATE
			) values (
				sq_MEDIA_RELATIONS_ID.nextval,
				#mid.mid#,
				'spatially defines geog_auth_rec',
				2072,
				#d.geog_auth_rec_id#,
				sysdate
			)
		</cfquery>
		<cfquery name="ml" datasource='uam_god'>
				insert into media_labels (
					MEDIA_LABEL_ID,
					MEDIA_ID,
					MEDIA_LABEL,
					LABEL_VALUE,
					ASSIGNED_BY_AGENT_ID,
					ASSIGNED_ON_DATE
				) values (
					sq_MEDIA_LABEL_ID.nextval,
					#mid.mid#,
					'description',
					'Polygon for #d.higher_geog#',
					2072,
					sysdate
				)
			</cfquery>
		<cfif len(d.md5) gt 0>
			<cfquery name="ml" datasource='uam_god'>
				insert into media_labels (
					MEDIA_LABEL_ID,
					MEDIA_ID,
					MEDIA_LABEL,
					LABEL_VALUE,
					ASSIGNED_BY_AGENT_ID,
					ASSIGNED_ON_DATE
				) values (
					sq_MEDIA_LABEL_ID.nextval,
					#mid.mid#,
					'MD5 checksum',
					'#d.md5#',
					2072,
					sysdate
				)
			</cfquery>
		</cfif>
		<cfquery name="ml" datasource='uam_god'>
			update temp_geo_wkt set status='made_media',media_id=#mid.mid# where geog_auth_rec_id=#geog_auth_rec_id#
		</cfquery>

	</cftransaction>


</cfloop>
---------------->

<!-------------------
init push to s3

	ctime:#now()#
<cfset utilities = CreateObject("component","component.utilities")>
<cfquery name="d" datasource='uam_god'>
	select WKT_POLYGON,geog_auth_rec.geog_auth_rec_id from geog_auth_rec,temp_geo_wkt where geog_auth_rec.geog_auth_rec_id=temp_geo_wkt.geog_auth_rec_id and
	status is null and rownum<200
</cfquery>
<cfloop query="d">
	<cfif len(WKT_POLYGON) gt 0>
		<cfset tempName=createUUID()>
		<br>tempName: #tempName#
		<cfset filename="geo_wkt_#geog_auth_rec_id#.wkt">
		<br>filename: #filename#
		<cffile	action = "write" file = "#Application.sandbox#/#tempName#.tmp" output='#WKT_POLYGON#' addNewLine="false">
		<br>written
		<cfset x=utilities.sandboxToS3("#Application.sandbox#/#tempName#.tmp",fileName)>
		<cfif not isjson(x)>
			upload fail<cfdump var=#x#><cfabort>
		</cfif>
		<cfset x=deserializeJson(x)>
		<!---
		<cfdump var=#x#>
		--->
		<cfif (not isdefined("x.STATUSCODE")) or (x.STATUSCODE is not 200) or (not isdefined("x.MEDIA_URI")) or (len(x.MEDIA_URI) is 0)>
			upload fail<cfdump var=#x#><cfabort>
			<cfquery name="uds" datasource='uam_god'>
				update temp_geo_wkt set status='upload_fail' where geog_auth_rec_id=#geog_auth_rec_id#
			</cfquery>
		<cfelse>
			<br>upload to #x.media_uri#
			<cfquery name="uds" datasource='uam_god'>
				update temp_geo_wkt set
					status='happy',
					file_up_uri='#x.media_uri#',
					md5='#x.MD5#'
				 where geog_auth_rec_id=#geog_auth_rec_id#
			</cfquery>
		</cfif>
	<cfelse>
		<cfquery name="uds" datasource='uam_god'>
			update temp_geo_wkt set status='zero_len_wkt' where geog_auth_rec_id=#geog_auth_rec_id#
		</cfquery>
	</cfif>
</cfloop>
------------------>
</cfoutput>
