<!---
create table tacc_folder (
	folder varchar2(255),
	file_count number
	);
	
create table tacc_check (
	collection_object_id number,
	barcode varchar2(255),
	folder varchar2(255),
	chkdate date default sysdate)
	;
	
alter table tacc_check add status varchar2(255);


----------------------------------------------------- -------- ------------------------------------
 COLLECTION_OBJECT_ID						NUMBER
 BARCODE							VARCHAR2(255)
 FOLDER 							VARCHAR2(255)
 CHKDATE							DATE
 STATUS 							VARCHAR2(255)

select folder ||chr(9) || barcode from tacc_check where barcode in ( select barcode from tacc_check having count(barcode) > 1 group by barcode)
	order by barcode;


create table tcb2 as select * from tacc_check_bak;

select jpg_status,count(*) from tacc_check group by jpg_status;
select folder from tacc_check where jpg_status='all_done' group by folder order by folder;

select folder from tacc_check where jpg_status='not_there'group by folder order by folder;



select collection_object_id from tacc_check where status='all_done' and jpg_status='all_done' and collection_object_id in (
	select collection_object_id from tacc_check_dlm where status='all_done' and jpg_status is null);
	
	
delete from tcb2 where barcode in ( select barcode from tcb2 having count(barcode) > 1 group by barcode);


update tacc_check set status = (select status from tcb2 where tcb2.barcode=tacc_check.barcode);

select status ||chr(9) || count(*) from tacc_check group by status;


alter table tacc_check add jpg_status varchar2(20);

select jpg_status,count(*) from tacc_check where jpg_status is not null group by jpg_status;

-- move to new JPG server
update media set media_uri=replace(media_uri,'http://irods.tacc.teragrid.org:8000/UAF/','http://goodnight.corral.tacc.utexas.edu/UAF/') where
media_uri like 'http://irods.tacc.teragrid.org:8000/UAF/%.jpg';

update media set preview_uri=replace(preview_uri,'http://irods.tacc.teragrid.org:8000/UAF/','http://goodnight.corral.tacc.utexas.edu/UAF/') where
preview_uri like 'http://irods.tacc.teragrid.org:8000/UAF/%.jpg';


select media_uri,replace(media_uri,'http://irods.tacc.teragrid.org:8000/UAF/','http://goodnight.corral.tacc.utexas.edu/UAF/') from media where
media_uri like 'http://irods.tacc.teragrid.org:8000/UAF/%.jpg';
--->



<cfoutput>
	<cfquery name="data" datasource="uam_god">
		select *
			from
				tacc_check
			where
				collection_object_id > 0
			and jpg_status is null
			and status='all_done'
			and rownum<501
	</cfquery>
	<hr>
	<br>data.recordcount: #data.recordcount#
	<cfloop query="data">
		<br>collection_object_id=#collection_object_id#
		<cfquery name="izaplant" datasource="uam_god">
			select collection_id from cataloged_item where collection_object_id=#collection_object_id#
		</cfquery>
		<cfif izaplant.collection_id is 6>
			<cfquery name="dng_id" datasource="uam_god">
				select 
					media.media_id 
				from 
					media,
					media_relations 
				where
					media.media_id = media_relations.media_id and
					media_relationship='shows cataloged_item' and
					related_primary_key=#collection_object_id# and
					media_uri='http://goodnight.corral.tacc.utexas.edu/UAF/#folder#/#barcode#.dng'
			</cfquery>
			<cfif len(dng_id.media_id) is 0 or dng_id.recordcount is not 1>
				<cfquery name="spiffy" datasource="uam_god">
					update tacc_check set jpg_status='bad_dng_id' where collection_object_id=#collection_object_id#
				</cfquery>
				<br>bad DNG
			<cfelse>
				<cfhttp url="http://goodnight.corral.tacc.utexas.edu/UAF/#folder#/jpegs/#barcode#.jpg" charset="utf-8" method="head">
				</cfhttp>
				<cfif left(cfhttp.statusCode,3) is "200">
					<br>200: file exists (http://goodnight.corral.tacc.utexas.edu/UAF/#folder#/jpegs/#barcode#.jpg)
					<cftransaction>
							<cfquery name="ala" datasource="uam_god">
								 select
									decode(ConcatSingleOtherId(coll_obj_other_id_num.collection_object_id,'ALAAC'),
										null,'UAM:Herb:' || cat_num || ' (ALA)',
										'ALA ' || ConcatSingleOtherId(coll_obj_other_id_num.collection_object_id,'ALAAC')
									)  || ': ' ||
									get_taxonomy(coll_obj_other_id_num.collection_object_id,'display_name') descr
								from 
									coll_obj_other_id_num
								where 
									other_id_type='ALAAC' and 
									coll_obj_other_id_num.collection_object_id=#collection_object_id#
							</cfquery>
							<cfif ala.recordcount is not 1>
								<cfquery name="ala" datasource="uam_god">
									select
										decode(ConcatSingleOtherId(coll_obj_other_id_num.collection_object_id,'ALAAC'),
											null,'UAM:Herb:' || cat_num || ' (ALA)',
											'ALA ' || ConcatSingleOtherId(coll_obj_other_id_num.collection_object_id,'ALAAC')
										)  || ': ' ||
										get_taxonomy(coll_obj_other_id_num.collection_object_id,'display_name') descr
									from 
										coll_obj_other_id_num
									where 
										other_id_type='ISC: Ada Hayden Herbarium, Iowa State University' and 
										coll_obj_other_id_num.collection_object_id=#collection_object_id#
								</cfquery>
							</cfif>
							<cfquery name="nid" datasource="uam_god">
								select sq_media_id.nextval media_id from dual
							</cfquery>
							<cfset muri='http://goodnight.corral.tacc.utexas.edu/UAF/#folder#/jpegs/#barcode#.jpg'>
							<cfhttp url="http://goodnight.corral.tacc.utexas.edu/UAF/#folder#/jpegs/tn_#barcode#.jpg" charset="utf-8" method="head">
							</cfhttp>
							<cfif left(cfhttp.statusCode,3) is "200">
								<cfset preview_uri="http://goodnight.corral.tacc.utexas.edu/UAF/#folder#/jpegs/tn_#barcode#.jpg">
							<cfelse>
								<cfset preview_uri=''>
							</cfif>
							<cftry>
								<cfquery name="media" datasource="uam_god">	
									insert into media (
										media_id,
										media_uri,
										preview_uri,
										mime_type,
										media_type
									) values (
										#nid.media_id#,
										'#muri#',
										'#preview_uri#',
										'image/jpeg',
										'image'
									)
								</cfquery>
								<cfif len(preview_uri) gt 0>
									<cfquery name="prev_dngmedia" datasource="uam_god">
										update media set preview_uri='#preview_uri#'
										where preview_uri is null and 
										media_id=#dng_id.media_id#
									</cfquery>								
								</cfif>
								<cfquery name="mr_cat" datasource="uam_god">
									insert into media_relations (
										MEDIA_ID,
										MEDIA_RELATIONSHIP,
										CREATED_BY_AGENT_ID,
										RELATED_PRIMARY_KEY
									) values (
										#nid.media_id#,
										'shows cataloged_item',
										2072,
										#collection_object_id#
									)
								</cfquery>
								<cfquery name="mr_agnt" datasource="uam_god">
									insert into media_relations (
										MEDIA_ID,
										MEDIA_RELATIONSHIP,
										CREATED_BY_AGENT_ID,
										RELATED_PRIMARY_KEY
									) values (
										#nid.media_id#,
										'created by agent',
										2072,
										1016226
									)
								</cfquery>
								<cfquery name="mr_media" datasource="uam_god">
									insert into media_relations (
										MEDIA_ID,
										MEDIA_RELATIONSHIP,
										CREATED_BY_AGENT_ID,
										RELATED_PRIMARY_KEY
									) values (
										#nid.media_id#,
										'derived from media',
										2072,
										#dng_id.media_id#
									)
								</cfquery>
								<cfquery name="lbl" datasource="uam_god">
									insert into  media_labels (
										MEDIA_ID,
										MEDIA_LABEL,
										LABEL_VALUE,
										ASSIGNED_BY_AGENT_ID
									) values (
										#nid.media_id#,
										'description',
										'#ala.descr#',
										2072
									)
								</cfquery>
								<cfquery name="spiffy" datasource="uam_god">
									update tacc_check set jpg_status='all_done' where collection_object_id=#collection_object_id#
								</cfquery>
							<cfcatch>
								<cfquery name="notspiffy" datasource="uam_god">
									update tacc_check set jpg_status='fail: #cfcatch.message#' where collection_object_id=#collection_object_id#
								</cfquery>
							</cfcatch>
							</cftry>	
						</cftransaction>
				<cfelse><!--- status=200 --->
					<br>no file (http://goodnight.corral.tacc.utexas.edu/UAF/#folder#/jpegs/#barcode#.jpg)
					<cfquery name="spiffy" datasource="uam_god">
						update tacc_check set jpg_status='not_there' where collection_object_id=#collection_object_id#
					</cfquery>		
				</cfif><!--- status=200 --->
			</cfif><!--- bad DNG ID --->
		<cfelse>
			<cfquery name="spiffy" datasource="uam_god">
				update tacc_check set jpg_status='not_a_plant' where collection_object_id=#collection_object_id#
			</cfquery>
			<br>not a plant
		</cfif>
	</cfloop>
</cfoutput>