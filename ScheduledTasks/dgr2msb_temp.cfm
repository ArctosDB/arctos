<!---
	processing table

	create table temp_dgr_box as select distinct freezer, rack, box from dgr_locator;

	delete from temp_dgr_box where freezer='2';
	delete from temp_dgr_box where freezer='12';
	delete from temp_dgr_box where freezer='10';


	delete from temp_dgrloc where freezer='2';
	delete from temp_dgrloc where freezer='12';
	delete from temp_dgrloc where freezer='10';


	alter table temp_dgr_box add status varchar2(255);

	update temp_dgr_box set status='done-before' where freezer=1 and rack=1 and box=1;
	update temp_dgr_box set status='done-before' where freezer=1 and rack=1 and box=2;
	update temp_dgr_box set status='done-before' where freezer=1 and rack=1 and box=2;


	select status, count(*) from temp_dgr_box group by status;
	select * from temp_dgr_box where status='box_create_success';





<cfoutput>

--->



	<!---

		we have tube's container_id in tube_container_id

		we have part ID in CPART_PID

		put the part into the tube


		alter table temp_dgrloc add part_is_containerized number;

		alter table temp_dgrloc add p2c_status varchar2(255);


		make sure none of the currently-identified parts are in containers

		update temp_dgrloc set p2c_status='in container' where CURRENT_PART_BARCODE is not null;
		update temp_dgrloc set p2c_status='in container_subquery' where key in (
				select key
		from
			temp_dgrloc,
			coll_obj_cont_hist,
			container
		where
			p2c_status is not null and
			temp_dgrloc.CPART_PID=coll_obj_cont_hist.collection_object_id and
			coll_obj_cont_hist.container_id=container.container_id and
			container.parent_container_id >0);



		select
			CPART_PID,
			container.parent_container_id,
			CURRENT_PART_BARCODE
		from
			temp_dgrloc,
			coll_obj_cont_hist,
			container
		where
			p2c_status is not null and
			temp_dgrloc.CPART_PID=coll_obj_cont_hist.collection_object_id and
			coll_obj_cont_hist.container_id=container.container_id and
			container.parent_container_id >0;



		select distinct CURRENT_PART_BARCODE from temp_dgrloc where CPART_PID is not null;


		alter table temp_dgrloc add part_container_id number;


		update temp_dgrloc set part_container_id=(
			select container_id from coll_obj_cont_hist where
				coll_obj_cont_hist.collection_object_id=temp_dgrloc.CPART_PID)
				where CPART_PID is not null;


select count(*) from temp_dgrloc where p2c_status='autoinstalled-1';

select count(*) from temp_dgrloc where p2c_status is null;

create table temp_dgrlog_m1 as select
	FREEZER,
	RACK,
	BOX,
	PLACE,
	NK,
	TISSUE_TYPE
from  temp_dgrloc where p2c_status is null;


select tissue_type,count(*) from temp_dgrlog_m1 group by tissue_type;



UAM@ARCTOS> desc temp_dgrloc
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 LOCATOR_ID							   NOT NULL NUMBER
 COLLECTION_OBJECT_ID							    NUMBER
 FREEZER							   NOT NULL NUMBER
 								   NOT NULL NUMBER
 								   NOT NULL NUMBER
 								   NOT NULL NUMBER
 									    NUMBER
 								    VARCHAR2(255)
 PART_TRANSLATED							    VARCHAR2(255)
 GUID									    VARCHAR2(255)
 ARCTOS_PARTS								    VARCHAR2(4000)
 CPART									    VARCHAR2(255)
 CPART_FROMARCTOS							    VARCHAR2(255)
 CPART_PID								    NUMBER
 CPART_STATUS								    VARCHAR2(255)
 KEY									    NUMBER
 CURRENT_PART_BARCODE							    VARCHAR2(255)
 PART_PARENT_CID							    NUMBER
 TUBE_CONTAINER_ID							    NUMBER
 PART_IS_CONTAINERIZED							    NUMBER
 P2C_STATUS								    VARCHAR2(255)
 PART_CONTAINER_ID							    NUMBER



<cfif not isdefined("action") or action is "nothing">
	<cfabort>
</cfif>

<cfif action is "findmp">
</cfif>



select tissue_type, CPART, count(*) from temp_dgrloc where p2c_status='zero_part_match' group by tissue_type ,CPART order by count(*);

select tissue_type, CPART, ARCTOS_PARTS from temp_dgrloc where p2c_status='zero_part_match' order by tissue_type;


select distinct nk from temp_dgrloc where p2c_status is null;
select distinct guid from temp_dgrloc where p2c_status is null;

create table temp_dgr_from_nk as select guid from temp_dgrloc where guid like 'DGR%';


select count(*) from temp_dgrloc where guid is not null and p2c_status='found_guid_no_dgr';
select count(*) from temp_dgrloc where guid is null and p2c_status='found_guid_no_dgr';
select count(*) from temp_dgrloc where collection_object_id is not null and p2c_status='found_guid_no_dgr';
select count(*) from temp_dgrloc where collection_object_id is null and p2c_status='found_guid_no_dgr';

select min(collection_object_id) from temp_dgrloc where p2c_status='found_guid_no_dgr';


update temp_dgrloc set collection_object_id=(select collection_object_id from flat where flat.guid=temp_dgrloc.guid)
 where  guid is not null and p2c_status='found_guid_no_dgr';



select tube_container_id from temp_dgrloc where p2c_status='no_specimens_with_nk_found';

<cfif action is "multiple_specimens_with_nk_found">
	</cfif>


<cfif not isdefined("action") or action is "nothing">
	<cfabort>
</cfif>


select tissue_type || ' @ ' || count(*) from temp_dgrloc where p2c_status='zero_part_match' group by tissue_type order by count(*);

create table temp_dgrlog_stilltodo as select * from temp_dgrloc where p2c_status='zero_part_match';

create table temp_dgrlog_stilltodo_uc as select tissue_type, arctos_parts from temp_dgrloc where p2c_status='zero_part_match' group by tissue_type, arctos_parts;


select cpart, count(*) from temp_dgrlog_stilltodo where cpart not in (select part_name from ctspecimen_part_name) group by cpart;


select count(*) from temp_dgrlog_stilltodo where lower(cpart) not in (select part_name from ctspecimen_part_name);

 group by cpart;

	update temp_dgrloc set cpart='ear clip' where cpart='EAR-PUNCH';
	update temp_dgrloc set p2c_status='got_part_1' where p2c_status='zero_part_match' and CPART_PID is not null;



						where
							key=#key#
					</cfquery>
select p2c_status,count(*) from temp_dgrloc group by p2c_status order by count(*);

	---->


<!----






	<!--------- deal with empbryos ---------------------------->

	<cfquery datasource='uam_god' name='d'>
		select * from temp_dgrloc where
			guid is not null and
			CPART_PID is null and
			use_part_1 like '%embryo%' and
			p2c_status ='fail_find_part_1' and
			rownum<2000
	</cfquery>
	<cfloop query="d">
		<cftransaction>


				<!--- try with no parens --->
				<cfquery datasource='uam_god' name='p'>
					select
						parent_container_id,
						specimen_part.part_name,
						specimen_part.collection_object_id part_id,
						container.container_id
					from
						specimen_part,
						flat,
						coll_obj_cont_hist,
						container
					where
						flat.collection_object_id= specimen_part.derived_from_cat_item and
						specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
						coll_obj_cont_hist.container_id=container.container_id and
						flat.guid='#guid#' and
						SAMPLED_FROM_OBJ_ID is null and
						container.parent_container_id=0 and
					 	part_name like '%organism%'
				</cfquery>
				<cfif p.recordcount gte 1>
					<br>gonna use #p.part_name# (#p.part_id#) because noparens match - #guid#...
					<cfquery datasource='uam_god' name='x'>
						update temp_dgrloc set
							CPART_PID=#p.part_id#,
							part_container_id=#p.container_id#,
							p2c_status='got_part_1'
						where
							key=#key#
					</cfquery>
				</cfif>

		</cftransaction>
	</cfloop>


	<!--------- END deal with empbryos ---------------------------->



<!---
		install things where we have a SECOND partID and a containerID
	---->

	<cfquery datasource='uam_god' name='d'>
		select
			key,
			tube_container_id,
			CPART_PID2 CPART_PID,
			PART_CONTAINER_ID2 part_container_id
		from
			temp_dgrloc
		where
			tube_container_id is not null and
			CPART_PID2 is not null and
			PART_CONTAINER_ID2 is not null
	</cfquery>



	<cfloop query="d">
		<cftransaction>
			<br>#tube_container_id#
			<cfquery datasource='uam_god' name='uppc'>
				update
					container
				set
					parent_container_id=#tube_container_id#
				where
					container_id=#part_container_id#
			</cfquery>
			<cfquery datasource='uam_god' name='uptc'>
				update
					container
				set
					CONTAINER_REMARKS=CONTAINER_REMARKS || '; part auto-installed from DGR locator data'
				where
					container_id=#tube_container_id#
			</cfquery>
		</cftransaction>
	</cfloop>

	<!---
		END install things where we have SECOND a partID and a containerID
	---->












<!--- find part2 when possible --->
	<cfquery datasource='uam_god' name='d'>
		select * from temp_dgrloc where
			guid is not null and
			CPART_PID2 is null and
			use_part_2 is not null and
			p2c_status ='zero_part_match'
	</cfquery>
	<cfloop query="d">
		<cftransaction>

			<cfset p2id="">
			<br>use_part_2=#use_part_2#
			<cfquery datasource='uam_god' name='p'>
				select
					parent_container_id,
					specimen_part.part_name,
					specimen_part.collection_object_id part_id,
					container.container_id
				from
					specimen_part,
					flat,
					coll_obj_cont_hist,
					container
				where
					flat.collection_object_id= specimen_part.derived_from_cat_item and
					specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
					coll_obj_cont_hist.container_id=container.container_id and
					flat.guid='#guid#' and
					SAMPLED_FROM_OBJ_ID is null and
					container.parent_container_id=0 and
				 	part_name='#use_part_2#'
			</cfquery>
			<cfif p.recordcount gte 1>
				<br> gonna use #p.part_name# (#p.part_id#) because exact match....
				<cfset p2id=p.part_id>
			<cfelse>
				<!--- try with no parens --->
				<cfquery datasource='uam_god' name='p'>
					select
						parent_container_id,
						specimen_part.part_name,
						specimen_part.collection_object_id part_id,
						container.container_id
					from
						specimen_part,
						flat,
						coll_obj_cont_hist,
						container
					where
						flat.collection_object_id= specimen_part.derived_from_cat_item and
						specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
						coll_obj_cont_hist.container_id=container.container_id and
						flat.guid='#guid#' and
						SAMPLED_FROM_OBJ_ID is null and
						container.parent_container_id=0 and
					 	trim(substr(part_name, 0, instr(part_name,'(')-1))=trim(substr('#use_part_2#', 0, instr('#use_part_2#','(')-1))
				</cfquery>
				<cfif p.recordcount gte 1>
					<br>gonna use #p.part_name# (#p.part_id#) because noparens match....
					<cfset p2id=p.part_id>
				</cfif>
			</cfif>
			<cfif len(p2id) is 0>
				<br>nodice for part2
			<cfelse>
			<br>updating....
					<cfquery datasource='uam_god' name='x'>
						update temp_dgrloc set
							CPART_PID2=#p.part_id#,
							part_container_id2=#p.container_id#
						where
							key=#key#
					</cfquery>
			</cfif>





		</cftransaction>
	</cfloop>

	<!--- END find part2 when possible --->











<!---
		find things with multiple parts; choose one
	--->


	<cfquery datasource='uam_god' name='d'>
		select * from temp_dgrloc where
			guid is not null and
			CPART_PID is null and
			p2c_status ='zero_part_match' and
			cpart='ear clip' and
			rownum<2000
	</cfquery>
	<cfloop query="d">
		<cftransaction>
		<cfquery datasource='uam_god' name='p'>
			select
				parent_container_id,
				specimen_part.part_name,
				specimen_part.collection_object_id part_id,
				container.container_id
			from
				specimen_part,
				flat,
				coll_obj_cont_hist,
				container
			where
				flat.collection_object_id= specimen_part.derived_from_cat_item and
				specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
				coll_obj_cont_hist.container_id=container.container_id and
				flat.guid='#guid#' and
				SAMPLED_FROM_OBJ_ID is null and
				container.parent_container_id=0 and
			 	trim(replace(part_name,'(frozen)'))=lower(trim('#cpart#'))
		</cfquery>

		<cfif p.recordcount gte 1>
			<!--- can we eliminate anything that's in a container?? ---->
			<br>gonna use #p.part_name# (#p.part_id#) because reasons....
			<cfquery datasource='uam_god' name='x'>
				update temp_dgrloc set
					CPART_PID=#p.part_id#,
					part_container_id=#p.container_id#,
					p2c_status='found_random_dup_part'
				where
					key=#key#
			</cfquery>
		</cfif>
		<cfif p.recordcount is 0>
			<br>nodice
			<cfquery datasource='uam_god' name='x'>
				update temp_dgrloc set p2c_status='zero_part_match' where key=#key#
			</cfquery>
		</cfif>

		</cftransaction>
	</cfloop>
	<!---
		END find things with multiple parts; choose one
	--->
























<!--- now loop through and find the tube's contianer_id --->





















<!--- find part1 when possible --->
	<cfquery datasource='uam_god' name='d'>
		select * from temp_dgrloc where
			guid is not null and
			CPART_PID is null and
			use_part_1 is not null and
			p2c_status ='fail_find_part_1' and
			rownum<2000
	</cfquery>
	<cfloop query="d">
		<cftransaction>

			<cfset p1id="">
			<br>use_part_1=#use_part_1#
			<cfquery datasource='uam_god' name='p'>
				select
					parent_container_id,
					specimen_part.part_name,
					specimen_part.collection_object_id part_id,
					container.container_id
				from
					specimen_part,
					flat,
					coll_obj_cont_hist,
					container
				where
					flat.collection_object_id= specimen_part.derived_from_cat_item and
					specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
					coll_obj_cont_hist.container_id=container.container_id and
					flat.guid='#guid#' and
					SAMPLED_FROM_OBJ_ID is null and
					container.parent_container_id=0 and
				 	part_name='#use_part_1#'
			</cfquery>
			<cfif p.recordcount gte 1>
				<br> gonna use #p.part_name# (#p.part_id#) because exact match....
				<cfset p1id=p.part_id>
			<cfelse>
				<!--- try with no parens --->
				<cfquery datasource='uam_god' name='p'>
					select
						parent_container_id,
						specimen_part.part_name,
						specimen_part.collection_object_id part_id,
						container.container_id
					from
						specimen_part,
						flat,
						coll_obj_cont_hist,
						container
					where
						flat.collection_object_id= specimen_part.derived_from_cat_item and
						specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
						coll_obj_cont_hist.container_id=container.container_id and
						flat.guid='#guid#' and
						SAMPLED_FROM_OBJ_ID is null and
						container.parent_container_id=0 and
					 	decode(instr(part_name,'('),0,part_name,trim(substr(part_name, 0, instr(part_name,'(')-1)))
					 	=
					 	decode(instr('#use_part_1#','('),0,'#use_part_1#',trim(substr('#use_part_1#', 0, instr('#use_part_1#','(')-1)))
				</cfquery>



				<cfif p.recordcount gte 1>
					<br>gonna use #p.part_name# (#p.part_id#) because noparens match....
					<cfset p1id=p.part_id>
				</cfif>
			</cfif>




			<cfif len(p1id) is 0>
				<br>nodice for part1
					<cfquery datasource='uam_god' name='x'>
						update temp_dgrloc set
							p2c_status='refail_find_part_1'
						where
							key=#key#
					</cfquery>

			<cfelse>
			<br>updating....
					<cfquery datasource='uam_god' name='x'>
						update temp_dgrloc set
							CPART_PID=#p.part_id#,
							part_container_id=#p.container_id#,
							p2c_status='got_part_1'
						where
							key=#key#
					</cfquery>
			</cfif>




		</cftransaction>
	</cfloop>

	<!--- END find part2 when possible --->




<!---
		install things where we have a partID and a containerID
	---->

	<cfquery datasource='uam_god' name='d'>
		select
			key,
			tube_container_id,
			CPART_PID,
			part_container_id,
			USE_PART_1,
			guid
		from
			temp_dgrloc
		where
			tube_container_id is not null and
			CPART_PID is not null and
			part_container_id is not null and
			p2c_status ='foundmatch: substring' and
			rownum<500
	</cfquery>



	<cfloop query="d">
		<cftransaction>
			<br>#tube_container_id#

			<br>#guid#
			<cfquery datasource='uam_god' name='uppc'>
				update
					container
				set
					parent_container_id=#tube_container_id#
				where
					container_id=#part_container_id#
			</cfquery>
			<cfquery datasource='uam_god' name='uptc'>
				update
					container
				set
					CONTAINER_REMARKS=CONTAINER_REMARKS || '; part auto-installed from DGR locator data'
				where
					container_id=#tube_container_id#
			</cfquery>
			<cfquery datasource='uam_god' name='hpr'>
				select count(*) c from coll_object_remark where COLLECTION_OBJECT_ID=#CPART_PID#
			</cfquery>
			<cfif hpr.c is 0>
				<cfquery datasource='uam_god' name='nt'>
					insert into coll_object_remark (COLLECTION_OBJECT_ID,COLL_OBJECT_REMARKS
					) values (
					#CPART_PID#,'Part given as #USE_PART_1# in DGR Locator; possible mismatch'
					)
				</cfquery>
			<cfelse>
				<cfquery datasource='uam_god' name='unt'>
					update
					coll_object_remark
					set
					COLL_OBJECT_REMARKS=COLL_OBJECT_REMARKS || '; Part given as #USE_PART_1# in DGR Locator; possible mismatch'
					where
					COLLECTION_OBJECT_ID=#CPART_PID#
				</cfquery>
			</cfif>


			<cfquery datasource='uam_god' name='ups'>
				update temp_dgrloc set p2c_status='autoinstalled-foundmatchsubstring' where key=#key#
			</cfquery>


		</cftransaction>
	</cfloop>

	<!---
		END install things where we have a partID and a containerID
	---->



<!---
		install things where we have a partID and a containerID
	---->

	<cfquery datasource='uam_god' name='d'>
		select
			key,
			tube_container_id,
			CPART_PID,
			part_container_id,
			USE_PART_1,
			guid
		from
			temp_dgrloc
		where
			tube_container_id is not null and
			CPART_PID is not null and
			part_container_id is not null and
			p2c_status like 'autoinstalled-p_-nocontainer' and
			rownum<2
	</cfquery>



	<cfloop query="d">
		<cftransaction>
			<br>#tube_container_id#

			<br>#guid#
			<cfquery datasource='uam_god' name='uppc'>
				update
					container
				set
					parent_container_id=#tube_container_id#
				where
					container_id=#part_container_id#
			</cfquery>
			<cfquery datasource='uam_god' name='uptc'>
				update
					container
				set
					CONTAINER_REMARKS=CONTAINER_REMARKS || '; part auto-installed from DGR locator data'
				where
					container_id=#tube_container_id#
			</cfquery>
			<cfquery datasource='uam_god' name='hpr'>
				select count(*) c from coll_object_remark where COLLECTION_OBJECT_ID=#CPART_PID#
			</cfquery>



			<cfquery datasource='uam_god' name='ups'>
				update temp_dgrloc set p2c_status='autoinstalled-madepart' where key=#key#
			</cfquery>


		</cftransaction>
	</cfloop>

	<!---
		END install things where we have a partID and a containerID
	---->



select p2c_status,count(*) from temp_dgrloc group by p2c_status order by count(*);

alter table temp_dgrloc add partial_match_part varchar2(255);

---->
<cfoutput>

<cfquery datasource='uam_god' name='d'>
		select
			*
		from
			temp_dgrloc
		where
			p2c_status  like 'autoinstalled-p2-nocontainer-MULTIPLE' and
			rownum<2
	</cfquery>
	<cfloop query="d">
		<cftransaction>
		<cfquery datasource='uam_god' name='p'>
			select
				specimen_part.collection_object_id part_id
			from
				specimen_part,
				flat,
				coll_obj_cont_hist,
				container,
				coll_object,
				coll_object_remark
			where
				flat.collection_object_id= specimen_part.derived_from_cat_item and
				specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
				specimen_part.collection_object_id=coll_object.collection_object_id and
				coll_obj_cont_hist.container_id=container.container_id and
				coll_object.COLL_OBJ_DISPOSITION != 'transfer of custody' and
				flat.guid='#guid#' and
				specimen_part.part_name='#use_part_1#' and
				SAMPLED_FROM_OBJ_ID is null and
				coll_object.collection_object_id=coll_object_remark.collection_object_id and
				coll_object_remarks like 'part autocreated and installed from DGR Locator data%' and
				(container.parent_container_id=0 or container.parent_container_id=17361530)
				specimen_part.collection_object_id not in (select CPART_PID from temp_dgrloc)
		</cfquery>
		<cfif p.recordcount is 1>
			<cfquery datasource='uam_god' name='ups'>
				update temp_dgrloc set CPART_PID=#p.part_id#, p2c_status='autoinstalled-p2-nocontainer-gpid' where key=#key#
			</cfquery>
		<cfelse>
			<cfquery datasource='uam_god' name='ups'>
				update temp_dgrloc set CPART_PID=NULL, p2c_status='autoinstalled-p2-nocontainer-STILLMULTIPLE' where key=#key#
			</cfquery>
		</cfif>
		</cftransaction>
	</cfloop>
</cfoutput>


<!------------


<!---
		create and install whatever's left; last step here


		IMPORTANTE: create one part on first pass;
		create second with a modified version of this where necessary


	---->

	<cfquery datasource='uam_god' name='d'>
		select
			*
		from
			temp_dgrloc
		where
			p2c_status ='autoinstalled-p1-nocontainer' and
			USE_PART_2 is not null and
			rownum<2000
	</cfquery>



	<cfloop query="d">
		<cftransaction>
			<br>#tube_container_id#

			<br>#guid#
			<!--- create a part ---->
			<cfquery name= "pid" datasource="uam_god">
				SELECT sq_collection_object_id.nextval pid FROM dual
			</cfquery>
			<cfquery name="updateColl" datasource="uam_god">
				INSERT INTO coll_object (
					COLLECTION_OBJECT_ID,
					COLL_OBJECT_TYPE,
					ENTERED_PERSON_ID,
					COLL_OBJECT_ENTERED_DATE,
					LAST_EDITED_PERSON_ID,
					COLL_OBJ_DISPOSITION,
					LOT_COUNT,
					CONDITION)
				VALUES (
					#pid.pid#,
					'SP',
					2072,
					sysdate,
					2072,
					'in collection',
					1,
					'unchecked')
			</cfquery>
			<cfquery name="newTiss" datasource="uam_god">
				INSERT INTO specimen_part (
					  COLLECTION_OBJECT_ID,
					  PART_NAME,
					  DERIVED_FROM_cat_item
				) VALUES (
					#pid.pid#,
					 '#USE_PART_2#'
					,#collection_object_id#)
			</cfquery>
			<cfif len(USE_PART_REMARK) gt 0>
				<cfset premk='part autocreated and installed from DGR Locator data; #USE_PART_REMARK#'>
			<cfelse>
				<cfset premk='part autocreated and installed from DGR Locator data'>
			</cfif>
			<cfquery name="newCollRem" datasource="uam_god">
				INSERT INTO coll_object_remark (collection_object_id, coll_object_remarks)
				VALUES (#pid.pid#, '#premk#')
			</cfquery>
			<!----
				part-container is auto-created
				install part later to avoid pissing off any triggers
			---->

			<cfquery datasource='uam_god' name='ups'>
				update temp_dgrloc set CPART_PID=#pid.pid#, p2c_status='autoinstalled-p2-nocontainer' where key=#key#
			</cfquery>



		</cftransaction>
	</cfloop>

	<!---
		END create and install whatever's left; last step here
	---->



<!---
		create and install whatever's left; last step here


		IMPORTANTE: create one part on first pass;
		create second with a modified version of this where necessary


	---->

	<cfquery datasource='uam_god' name='d'>
		select
			*
		from
			temp_dgrloc
		where
			p2c_status ='ready_create_part' and
			rownum<2000
	</cfquery>



	<cfloop query="d">
		<cftransaction>
			<br>#tube_container_id#

			<br>#guid#
			<!--- create a part ---->
			<cfquery name= "pid" datasource="uam_god">
				SELECT sq_collection_object_id.nextval pid FROM dual
			</cfquery>
			<cfquery name="updateColl" datasource="uam_god">
				INSERT INTO coll_object (
					COLLECTION_OBJECT_ID,
					COLL_OBJECT_TYPE,
					ENTERED_PERSON_ID,
					COLL_OBJECT_ENTERED_DATE,
					LAST_EDITED_PERSON_ID,
					COLL_OBJ_DISPOSITION,
					LOT_COUNT,
					CONDITION)
				VALUES (
					#pid.pid#,
					'SP',
					2072,
					sysdate,
					2072,
					'in collection',
					1,
					'unchecked')
			</cfquery>
			<cfquery name="newTiss" datasource="uam_god">
				INSERT INTO specimen_part (
					  COLLECTION_OBJECT_ID,
					  PART_NAME,
					  DERIVED_FROM_cat_item
				) VALUES (
					#pid.pid#,
					 '#USE_PART_1#'
					,#collection_object_id#)
			</cfquery>
			<cfif len(USE_PART_REMARK) gt 0>
				<cfset premk='part autocreated and installed from DGR Locator data; #USE_PART_REMARK#'>
			<cfelse>
				<cfset premk='part autocreated and installed from DGR Locator data'>
			</cfif>
			<cfquery name="newCollRem" datasource="uam_god">
				INSERT INTO coll_object_remark (collection_object_id, coll_object_remarks)
				VALUES (#pid.pid#, '#premk#')
			</cfquery>
			<!----
				part-container is auto-created
				install part later to avoid pissing off any triggers
			---->

			<cfquery datasource='uam_god' name='ups'>
				update temp_dgrloc set CPART_PID=#pid.pid#, p2c_status='autoinstalled-p1-nocontainer' where key=#key#
			</cfquery>



		</cftransaction>
	</cfloop>

	<!---
		END create and install whatever's left; last step here
	---->



	<!---
		find things with ONE parts in locator
		see if we can find a corresponding multi-part part in Arctos



		create table temp_dgr_single_parts (
			guid varchar2(255),
			dgr_parts varchar2(4000),
			arctos_parts varchar2(4000)
		);


	---->

	<cfquery datasource='uam_god' name='d'>
		select * from temp_dgrloc where guid is not null and
		CPART_PID is null and
		USE_PART_1 like '%,%' and
		p2c_status like 'fail_find_part_1%' and
		rownum<5000
	</cfquery>
	<cfloop query="d">
	<cftransaction>
		<hr>#USE_PART_1#
		<br>#guid#
		<cfset sp1=trim(replace(use_part_1,'(frozen)',''))>
		<br>sp1: #sp1#
		<cfquery datasource='uam_god' name='parts'>
			select
				parent_container_id,
				specimen_part.part_name,
				specimen_part.collection_object_id part_id,
				container.container_id
			from
				specimen_part,
				flat,
				coll_obj_cont_hist,
				container,
				coll_object
			where
				flat.collection_object_id= specimen_part.derived_from_cat_item and
				specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
				specimen_part.collection_object_id=coll_object.collection_object_id and
				coll_obj_cont_hist.container_id=container.container_id and
				coll_object.COLL_OBJ_DISPOSITION != 'transfer of custody' and
				flat.guid='#guid#' and
				SAMPLED_FROM_OBJ_ID is null and
				(container.parent_container_id=0 or container.parent_container_id=17361530)
		</cfquery>
		<cfset psts='no_part_found'>
		<cfset pid='NULL'>
		<cfset cid='NULL'>
		<cfset usepart=''>
		<!--- first try tissue--->
		<cfloop query="parts">
			<br>--#part_name#
			<cfif part_name contains 'tissue'>
				<br>gonna just use tissue.....
				<cfset psts='foundmatch: tissue'>
				<cfset pid=part_id>
				<cfset cid=container_id>
				<cfset usepart=part_name>
			</cfif>
		</cfloop>
		<!--- now try partial match; overwrite 'tissue' if we find something --->
		<cfloop query="parts">
			<br>--#part_name#
			<cfif part_name contains sp1>
				<br>substringmatch gonna use #part_name#
				<cfset psts='foundmatch: substring'>
				<cfset pid=part_id>
				<cfset cid=container_id>
				<cfset usepart=part_name>
			</cfif>
		</cfloop>
		<p>
		update temp_dgrloc set
							CPART_PID=#pid#,
							part_container_id=#cid#,
							p2c_status='#psts#',
							partial_match_part='#usepart#'
						where
							key=#key#
	</p>

		<cfquery datasource='uam_god' name='upf'>
			update temp_dgrloc set
				CPART_PID=#pid#,
				part_container_id=#cid#,
				p2c_status='#psts#',
				partial_match_part='#usepart#'
			where
				key=#key#
		</cfquery>

	</cftransaction>
	</cfloop>




<!---
		find things with multiple parts in locator
		see if we can find a corresponding multi-part part in Arctos



		create table temp_dgr_multiple_parts (
			guid varchar2(255),
			dgr_parts varchar2(4000),
			arctos_parts varchar2(4000)
		);


	---->
	<cfinclude template="/includes/functionLib.cfm">


	<cfquery datasource='uam_god' name='d'>
		select distinct guid from temp_dgrloc where
			guid is not null and
			CPART_PID is null and
			p2c_status ='fail_find_part_1' and
			rownum<2000
	</cfquery>
	<cfloop query="d">
		<cftransaction>

		<cfquery datasource='uam_god' name='a'>
			select * from temp_dgrloc where p2c_status ='fail_find_part_1' and guid='#d.guid#'
		</cfquery>
		<cfif a.recordcount is 1>
			<cfquery datasource='uam_god' name='x'>
				update temp_dgrloc set p2c_status='fail_find_part_1-singleRecord' where guid='#d.guid#'
			</cfquery>
		<cfelse>
			<cfquery datasource='uam_god' name='parts'>
				select
					parent_container_id,
					specimen_part.part_name,
					specimen_part.collection_object_id part_id,
					container.container_id
				from
					specimen_part,
					flat,
					coll_obj_cont_hist,
					container,
					coll_object
				where
					flat.collection_object_id= specimen_part.derived_from_cat_item and
					specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
					specimen_part.collection_object_id=coll_object.collection_object_id and
					coll_obj_cont_hist.container_id=container.container_id and
					coll_object.COLL_OBJ_DISPOSITION != 'transfer of custody' and
					flat.guid='#guid#' and
					SAMPLED_FROM_OBJ_ID is null and
					(container.parent_container_id=0 or container.parent_container_id=17361530)
			</cfquery>
			<cfquery datasource='uam_god' name='svM'>
				insert into temp_dgr_multiple_parts (guid,dgr_parts,arctos_parts) values (
				'#d.guid#','#escapeQuotes(valuelist(a.USE_PART_1,"|"))#','#escapeQuotes(valuelist(parts.part_name,"|"))#')
			</cfquery>
			<cfquery datasource='uam_god' name='x'>
				update temp_dgrloc set p2c_status='fail_find_part_1-gotMultiple' where guid='#d.guid#'
			</cfquery>



		</cfif>
		<!----
		<cfquery datasource='uam_god' name='p'>
			select
				parent_container_id,
				specimen_part.part_name,
				specimen_part.collection_object_id part_id,
				container.container_id
			from
				specimen_part,
				flat,
				coll_obj_cont_hist,
				container
			where
				flat.collection_object_id= specimen_part.derived_from_cat_item and
				specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
				coll_obj_cont_hist.container_id=container.container_id and
				flat.guid='#guid#' and
				SAMPLED_FROM_OBJ_ID is null and
				container.parent_container_id=0 and
			 	trim(replace(part_name,'(frozen)'))=lower(trim('#cpart#'))
		</cfquery>

		<cfif p.recordcount gte 1>
			<!--- can we eliminate anything that's in a container?? ---->
			<br>gonna use #p.part_name# (#p.part_id#) because reasons....
			<cfquery datasource='uam_god' name='x'>
				update temp_dgrloc set
					CPART_PID=#p.part_id#,
					part_container_id=#p.container_id#,
					p2c_status='found_random_dup_part'
				where
					key=#key#
			</cfquery>
		</cfif>
		<cfif p.recordcount is 0>
			<br>nodice
			<cfquery datasource='uam_god' name='x'>
				update temp_dgrloc set p2c_status='zero_part_match' where key=#key#
			</cfquery>
		</cfif>
		---->
		</cftransaction>
	</cfloop>
	<!---
		END find things with multiple parts; choose one
	--->


<!--- weird mapping --->
	<cfquery datasource='uam_god' name='d'>
		select * from temp_dgrloc where
			guid is not null and
			CPART_PID is null and
			use_part_1  like 'heart, kidney, lung, spleen%' and
			p2c_status ='refail_find_part_1' and
			rownum<2000
	</cfquery>
	<cfloop query="d">
		<cftransaction>

			<cfset p1id="">
			<br>use_part_1=#use_part_1#
			<cfquery datasource='uam_god' name='p'>
				select
					parent_container_id,
					specimen_part.part_name,
					specimen_part.collection_object_id part_id,
					container.container_id
				from
					specimen_part,
					flat,
					coll_obj_cont_hist,
					container
				where
					flat.collection_object_id= specimen_part.derived_from_cat_item and
					specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
					coll_obj_cont_hist.container_id=container.container_id and
					flat.guid='#guid#' and
					SAMPLED_FROM_OBJ_ID is null and
					container.parent_container_id=0 and
				 	part_name like 'heart, kidney, liver, lung, spleen%'
			</cfquery>
			<cfif p.recordcount gte 1>
				<br> gonna use #p.part_name# (#p.part_id#) because exact match....
				<cfquery datasource='uam_god' name='x'>
						update temp_dgrloc set
							CPART_PID=#p.part_id#,
							part_container_id=#p.container_id#,
							p2c_status='got_part_1'
						where
							key=#key#
					</cfquery>
			<cfelse>
				<br>nope
				<cfquery datasource='uam_god' name='x'>
					update temp_dgrloc set
						p2c_status='rerefail_find_part_1'
					where
						key=#key#
				</cfquery>
			</cfif>


		</cftransaction>
	</cfloop>

	<!--- END weird mapping --->
	<cfquery datasource='uam_god' name='d'>
		select * from temp_dgrloc where
			guid is not null and
			CPART_PID is null and
			p2c_status ='found_guid_no_dgr' and
			rownum<2000
	</cfquery>
	<cfloop query="d">
		<cftransaction>
		<cfquery datasource='uam_god' name='p'>
			select
				parent_container_id,
				specimen_part.part_name,
				specimen_part.collection_object_id part_id,
				container.container_id
			from
				specimen_part,
				flat,
				coll_obj_cont_hist,
				container
			where
				flat.collection_object_id= specimen_part.derived_from_cat_item and
				specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
				coll_obj_cont_hist.container_id=container.container_id and
				flat.guid='#guid#' and
				SAMPLED_FROM_OBJ_ID is null and
				container.parent_container_id=0 and
			 	trim(replace(part_name,'(frozen)'))=lower(trim('#cpart#'))
		</cfquery>

		<cfif p.recordcount gte 1>
			<!--- can we eliminate anything that's in a container?? ---->
			<br>gonna use #p.part_name# (#p.part_id#) because reasons....
			<cfquery datasource='uam_god' name='x'>
				update temp_dgrloc set
					CPART_PID=#p.part_id#,
					part_container_id=#p.container_id#,
					p2c_status='found_random_dup_part'
				where
					key=#key#
			</cfquery>
		</cfif>
		<cfif p.recordcount is 0>
			<br>nodice
			<cfquery datasource='uam_god' name='x'>
				update temp_dgrloc set p2c_status='zero_part_match' where key=#key#
			</cfquery>
		</cfif>

		</cftransaction>
	</cfloop>
	<!---
		END find things with multiple parts; choose one
	--->


<!---
	move no_specimens_with_nk_found records out of the way
--->
	<cfquery datasource='uam_god' name='d'>
		select * from temp_dgrloc where p2c_status='no_specimens_with_nk_found' and rownum<2000
	</cfquery>
	<cfloop query="d">
		<cftransaction>
			<br>#tube_container_id#
			<cfquery datasource='uam_god' name='upc'>
				update container set CONTAINER_REMARKS=CONTAINER_REMARKS || '; No specimens with NK #nk# found on ' || sysdate
				where container_id=#tube_container_id#
			</cfquery>
			<cfquery datasource='uam_god' name='ups'>
				update temp_dgrloc set p2c_status='no_specimens_with_nk_found-wroteToTubeContainer' where key=#key#
			</cfquery>
		</cftransaction>
	</cfloop>
<!---
	END move no_specimens_with_nk_found records out of the way
--->

<!---
	move multiple_specimens_with_nk_found records out of the way
--->
	<cfquery datasource='uam_god' name='d'>
		select * from temp_dgrloc where p2c_status like 'multiple_specimens_with_nk_found|%' and rownum<2000
	</cfquery>
	<cfloop query="d">
		<cftransaction>
			<cfset guidlist=listgetat(p2c_status,2,"|")>

			<br>#tube_container_id#
			<br>#guidlist#
			<cfquery datasource='uam_god' name='upc'>
				update container set CONTAINER_REMARKS=CONTAINER_REMARKS || '; Multiple specimens with NK #nk# found on ' || sysdate || ': #guidlist#'
				where container_id=#tube_container_id#
			</cfquery>
			<cfquery datasource='uam_god' name='ups'>
				update temp_dgrloc set p2c_status='multiple_specimens_with_nk_found-wroteToTubeContainer' where key=#key#
			</cfquery>
		</cftransaction>
	</cfloop>

<!---
	END move multiple_specimens_with_nk_found records out of the way
--->



	<!--- get some more GUIDs, ignoring DGR collections ---->

		<cfquery datasource='uam_god' name='d'>
			select nk, key from temp_dgrloc where guid is null and p2c_status like 'multiple_specimens_with_nk_found%'
		</cfquery>
		<cfloop query="d">
			<cfquery datasource='uam_god' name='gg'>
				 select distinct
	        		guid_prefix || ':' || cat_num guid
			      from
			        collection,
			        cataloged_item,
			        coll_obj_other_id_num
			      where
			        collection.collection_id=cataloged_item.collection_id and
			        cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id and
			        coll_obj_other_id_num.other_id_type='NK' and
			        collection.guid_prefix not like '%Para%' and
			        collection.guid_prefix not like '%DGR%' and
			        coll_obj_other_id_num.display_value='#NK#'
			</cfquery>
			<cfif gg.recordcount is 1>
				<cfquery datasource='uam_god' name='gud'>
					update temp_dgrloc set guid='#gg.guid#',p2c_status='found_guid_no_dgr' where key=#key#
				</cfquery>
			<cfelseif gg.recordcount lt 1>
				<cfquery datasource='uam_god' name='gud'>
					update temp_dgrloc set p2c_status='no_specimens_with_nk_found' where key=#key#
				</cfquery>
			<cfelse>
				<cfquery datasource='uam_god' name='gud'>
					update temp_dgrloc set p2c_status='multiple_specimens_with_nk_found|#valuelist(gg.guid)#' where key=#key#
				</cfquery>

			</cfif>

		</cfloop>

	<!--- END some more GUIDs, ignoring DGR collections ---->





		<cfquery datasource='uam_god' name='srcbx'>
			select distinct freezer,rack,box from temp_dgrloc where tube_container_id is null and rownum<2000
		</cfquery>
		<cfloop query="srcbx">
			<cftransaction>
				<cfquery datasource='uam_god' name='d'>
					select * from temp_dgrloc where tube_container_id is null and
					 freezer='#srcbx.freezer#' and rack='#srcbx.rack#' and box='#srcbx.box#'
				</cfquery>
				<cfquery datasource='uam_god' name='d_b'>
					select container_id from container where container_type='freezer box' and
					label='DGR-#srcbx.freezer#-#srcbx.rack#-#srcbx.box#'
				</cfquery>
				<cfif d_b.recordcount is not 1>
					<cfthrow message="box_not_found" detail="DGR-#srcbx.freezer#-#srcbx.rack#-#srcbx.box#">
				</cfif>

				<!---
				<cfdump var=#d#>
				--->
				<cfloop query="d">
					<cfquery datasource='uam_god' name='t'>
						select
							t.container_id
						from
							container t,
							container p
						where
							t.container_type='cryovial' and
							p.container_type='position' and
							t.parent_container_id=p.container_id and
							p.parent_container_id=#d_b.container_id# and
							t.label='NK #nk# #tissue_type#' and
							p.label='#place#'
					</cfquery>

					<cfquery datasource='uam_god' name='reup'>
						update temp_dgrloc set TUBE_CONTAINER_ID=#t.container_id# where key=#d.key#
					</cfquery>
				</cfloop>
			</cftransaction>
		</cfloop>


	<cfif action is "confirm_freezers_exist">

	all done<cfabort>


		<cfquery datasource='uam_god' name='d'>
			select distinct freezer from temp_dgr_box
		</cfquery>
		<cfloop query="d">
			<cfquery datasource='uam_god' name='f'>
				select * from container where label='DGR-#freezer#'
			</cfquery>
			<cfif f.recordcount is 1>
				<br>DGR-#freezer# is happy...
				<br>update container set parent_container_id=18230103 where container_id=#f.container_id#
			<cfelse>
				<br>BAD!!!!!!!!!!!!!!!!!!<cfdump var=#f#>
			</cfif>
			<cfquery datasource='uam_god' name='fc'>
				select container_type, label from container where parent_container_id=#f.container_id#
			</cfquery>
			<cfif fc.recordcount gt 0>
				<br>!!!!! bad <cfdump var=#fc#>
			<cfelse>
				<br>happy - no contents
			</cfif>
		</cfloop>
	</cfif>


	<cfif action is "make_freezer_racks">
		done<cfabort>
		<cftransaction>
		<cfquery datasource='uam_god' name='d'>
			select distinct freezer, rack from temp_dgr_box where status is null order by freezer,rack
		</cfquery>

		<cfdump var=#d#>

		<cfquery name="f" dbtype="query">
			select freezer from d group by freezer order by freezer
		</cfquery>
		<cfloop query="#f#">
			<cfquery datasource='uam_god' name='fi'>
				select * from container where label='DGR-#freezer#'
			</cfquery>
			<cfdump var=#fi#>
			<cfquery name="rs" dbtype="query">
				select rack from d where freezer=#freezer#
			</cfquery>
			<cfloop query="#rs#">

				<cfquery name="makerack" datasource='uam_god'>
					insert into container (
						CONTAINER_ID,
						PARENT_CONTAINER_ID,
						CONTAINER_TYPE,
						LABEL,
						DESCRIPTION,
						INSTITUTION_ACRONYM
					) values (
						sq_container_id.nextval,
						#fi.container_id#,
						'freezer rack',
						'DGR-#f.freezer#-#rs.rack#',
						'rack autocreated from DGR Locator',
						'MSB'
					)
				</cfquery>
			</cfloop>
		</cfloop>
		</cftransaction>

	</cfif>



	<cfif action is "dgr_to_objecttracking">

	done<cfabort>
<cfoutput>
		<cfquery datasource='uam_god' name='srcbx'>
			select * from temp_dgr_box where status is null and rownum <200
		</cfquery>
		<cfloop query="srcbx">
			<br>freezer='#srcbx.freezer#' and rack='#srcbx.rack#' and box='#srcbx.box#'
			<cfquery name="d" datasource="uam_god">
				select * from dgr_locator where freezer='#srcbx.freezer#' and rack='#srcbx.rack#' and box='#srcbx.box#'
			</cfquery>
			<cftransaction>
				<cfquery name="box" dbtype="query">
					select freezer, rack, box from d group by freezer, rack, box
				</cfquery>
				<cfquery name="isbox" datasource="uam_god">
					select * from container where label='DGR-#box.freezer#-#box.rack#-#box.box#'
				</cfquery>
				<cfif len(isbox.container_id) gt 0>
					box DGR-#box.freezer#-#box.rack#-#box.box# already exists - aborting
					<cfquery name="ss" datasource="uam_god">
						update temp_dgrbox set status=status || 'box_already_exists' where box='#box.box#' and rack='#rack.rack#' and freezer='#freezer.freezer#'
					</cfquery>
					<cfabort>
				</cfif>
				<cfquery name="cid" datasource="uam_god">
					select sq_container_id.nextval id from dual
				</cfquery>
				<cfquery name="grack" datasource="uam_god">
					select container_id from container where container_type='freezer rack' and label='DGR-#box.freezer#-#box.rack#'
				</cfquery>

				<cfquery name="mkbox" datasource="uam_god">
					insert into container (
						container_id,
						parent_container_id,
						container_type,
						label,
						institution_acronym,
						NUMBER_POSITIONS
					) values (
						#cid.id#,
						#grack.container_id#,
						'freezer box',
						'DGR-#box.freezer#-#box.rack#-#box.box#',
						'MSB',
						100
					)
				</cfquery>
				<cfset boxid=cid.id>
				<p>
					make box with label DGR-#box.freezer#-#box.rack#-#box.box#
				</p>

				<!---
					Mariel can we make these all 100-position boxes, even if that's not quite true??
					Yes, approved, they prefer this
				--->
				<cfloop from ="1" to="100" index="p">
					<p>
						 insert into new box position #p#
					</p>
					<cfquery name="cid" datasource="uam_god">
						select sq_container_id.nextval id from dual
					</cfquery>
					<cfquery name="mkbp" datasource="uam_god">
						insert into container (
							container_id,
							parent_container_id,
							container_type,
							label,
							institution_acronym
						) values (
							#cid.id#,
							#boxid#,
							'position',
							'#p#',
							'MSB'
						)
					</cfquery>
					<cfset lpid=cid.id>
					<!--- if and only if there's a tissue, make a cryovial ---->
					<cfquery name="ist" dbtype="query">
						select * from d where place=#p#
					</cfquery>
					<cfif len(ist.nk) gt 0>
						<cfquery name="cid" datasource="uam_god">
							select sq_container_id.nextval id from dual
						</cfquery>
						<cfquery name="mkbp" datasource="uam_god">
							insert into container (
								container_id,
								parent_container_id,
								container_type,
								label,
								institution_acronym,
								CONTAINER_REMARKS
							) values (
								#cid.id#,
								#lpid#,
								'cryovial',
								'NK #ist.nk# #ist.tissue_type#',
								'MSB',
								'autocreated from DGR Locator data'
							)
						</cfquery>
					</cfif>
				</cfloop>
				<cfquery name="ss" datasource="uam_god">
					update temp_dgr_box set status=status || 'box_create_success' where box='#box.box#' and rack='#box.rack#' and freezer='#box.freezer#'
				</cfquery>
			</cftransaction>
		</cfloop>

		</cfoutput>
	</cfif>
--------->
