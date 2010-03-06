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

delete from tcb2 where barcode in ( select barcode from tcb2 having count(barcode) > 1 group by barcode);


update tacc_check set status = (select status from tcb2 where tcb2.barcode=tacc_check.barcode);

select status ||chr(9) || count(*) from tcb2 group by status;

--->

<cfoutput>
	<cfquery name="data" datasource="uam_god">
		select *
			from
				tacc_check
			where
				collection_object_id > 0
			and status is null
			and rownum<10000
	</cfquery>
	<cfloop query="data">
		<cfquery name="izaplant" datasource="uam_god">
			select collection_id from cataloged_item where collection_object_id=#collection_object_id#
		</cfquery>
		<cfif izaplant.collection_id is 6>
			<cfquery name="ixrel" datasource="uam_god">
				select count(*) c from biol_indiv_relations where related_coll_object_id = #collection_object_id#
			</cfquery>
			<cfif ixrel.c is 0>
				<cftransaction>
				<cfquery name="ala" datasource="uam_god">
					select 
						'ALA Accession ' || display_value ala,
						scientific_name
					from 
						coll_obj_other_id_num,
						identification
					where 
						coll_obj_other_id_num.collection_object_id=identification.collection_object_id and
						accepted_id_fg=1 and
						other_id_type='ALAAC' and 
						coll_obj_other_id_num.collection_object_id=#collection_object_id#
				</cfquery>
				<cfif ala.recordcount is not 1>
					<cfquery name="ala" datasource="uam_god">
						select 
							'ISC ' || display_value ala,
							scientific_name
						from 
							coll_obj_other_id_num,
							identification
						where 
							coll_obj_other_id_num.collection_object_id=identification.collection_object_id and
							accepted_id_fg=1 and
							other_id_type='ISC: Ada Hayden Herbarium, Iowa State University' and 
							coll_obj_other_id_num.collection_object_id=#collection_object_id#
					</cfquery>
				</cfif>
				<cfquery name="nid" datasource="uam_god">
					select sq_media_id.nextval media_id from dual
				</cfquery>
				<cfset muri='http://goodnight.corral.tacc.utexas.edu/UAF/#folder#/#barcode#.dng'>
				<cfquery name="media" datasource="uam_god">
					insert into media (
						media_id,
						media_uri,
						mime_type,
						media_type
					) values (
						#nid.media_id#,
						'#muri#',
						'image/dng',
						'image'
					)
				</cfquery>
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
				<cfquery name="lbl" datasource="uam_god">
					insert into  media_labels (
						MEDIA_ID,
						MEDIA_LABEL,
						LABEL_VALUE,
						ASSIGNED_BY_AGENT_ID
					) values (
						#nid.media_id#,
						'description',
						'Original DNG of #ala.ala# (#ala.scientific_name#).',
						2072
					)
				</cfquery>
				<br>made #ala.display_value#
				<cfquery name="spiffy" datasource="uam_god">
					update tacc_check set status='all_done' where collection_object_id=#collection_object_id#
				</cfquery>							
				</cftransaction>
			<cfelse><!--- in rel --->
				<cfquery name="izaplant" datasource="uam_god">
					update tacc_check set status='in_relations' where collection_object_id=#collection_object_id#
				</cfquery>
			</cfif><!--- in rel --->
		<cfelse><!--- not a plant --->
			<cfquery name="izaplant" datasource="uam_god">
				update tacc_check set status='not_a_plant' where collection_object_id=#collection_object_id#
			</cfquery>
		</cfif><!--- not a plant --->
	</cfloop>
</cfoutput>