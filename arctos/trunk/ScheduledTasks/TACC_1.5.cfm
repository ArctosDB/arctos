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
	
	
	update tacc_check set collection_object_id = (select collection_object_id from tcb2 where tcb2.barcode=tacc_check.barcode);
--->
<cfsetting requesttimeout="600"> 
<!---- 
	4 June 2013: Modify to deal with "barcode" (=filename) multiples
		- Actual barcode: ABC123
			deal with filenames:
				ABC123
				ABC123_1
				ABC123_n (where n is an integer)
------->
<cfoutput>
	<cfquery name="fldr" datasource="uam_god">
		select
			folder,
			file_count
		from
			tacc_folder
	</cfquery>
	<cfloop query="fldr">
		<cfquery name="fl" datasource="uam_god">
			select
				count(*) c
			from
				tacc_check
			where
				folder = '#folder#'
		</cfquery>
		<cfif fldr.file_count is not (fl.c + 2)>
			Something hinky is going on with #folder#
			<br>
			fldr.file_count: #fldr.file_count#
			<br>
			fl.c: #fl.c#
		
			<hr>
		</cfif>
	</cfloop>
	<cfquery name="data" datasource="uam_god">
		select *
			from
				tacc_check
			where
				collection_object_id is null
			and status is null
	</cfquery>
	<cfloop query="data">
		<cftransaction>
			<cfquery name="bc" datasource="uam_god">
				select 
					cataloged_item.collection_object_id 
				from
					cataloged_item,
					specimen_part,
					coll_obj_cont_hist,
					container pc,
					container prnt
				where
					cataloged_item.collection_object_id = specimen_part.derived_from_cat_item and
					specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id and
					coll_obj_cont_hist.container_id = pc.container_id and
					pc.parent_container_id = prnt.container_id and
					prnt.barcode='listgetat(barcode,1,"_")##'
			</cfquery>
			<cfif bc.collection_object_id is "">
				<cfquery name="data" datasource="uam_god">
					update tacc_check set collection_object_id=-1 where barcode='#barcode#'
				</cfquery>
			<cfelseif bc.recordcount is not 1>
				<cfquery name="data" datasource="uam_god">
					update tacc_check set collection_object_id=-2 where barcode='#barcode#'
				</cfquery>
			<cfelse>
				<cfquery name="data" datasource="uam_god">
					update tacc_check set collection_object_id=#bc.collection_object_id# where barcode='#barcode#'
				</cfquery>
			</cfif>
		</cftransaction>
	</cfloop>
</cfoutput>