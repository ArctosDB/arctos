<!---
	create table ocr_text (
		collection_object_id number not null,
		try_date date,
		ocr_date date,
		ocr_text varchar2(4000)
	);
	
	create public synonym ocr_text for ocr_text;
	
	grant select on ocr_text to public;
	
	create unique index iu_ocr_text_coid on ocr_text (collection_object_id) tablespace uam_idx_1;
	create index ix_ocr_text_text_upr on ocr_text (upper(ocr_text)) tablespace uam_idx_1;

	
	alter table ocr_text modify try_date null;
--->
<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
	<a href="tacc_ocr.cfm?action=getSpecs">getSpecs</a>
	<a href="tacc_ocr.cfm?action=crawl">crawl</a>
</cfif>
<cfif action is "getSpecs">
	<cfquery name="specs" datasource="uam_god">
		insert into ocr_text (
			collection_object_id
		) (
			select 
				distinct(cataloged_item.collection_object_id)
			from
				cataloged_item,
				media_relations,
				ocr_text
			where
				cataloged_item.collection_id=6 and
				cataloged_item.collection_object_id = media_relations.related_primary_key and
				media_relations.media_relationship='shows cataloged_item' and
				cataloged_item.collection_object_id=ocr_text.collection_object_id (+) and
				ocr_text.collection_object_id is null
		)
	</cfquery>
</cfif>
<cfif action is "crawl">
	<cfquery name="bc" datasource="uam_god">
		select 
			ocr_text.collection_object_id,
			sheet.barcode 
		from 
			ocr_text,
			specimen_part,
			coll_obj_cont_hist,
			container part,
			container sheet
		where
			ocr_date is null and
			(try_date is null OR sysdate-try_date>1) and
			ocr_text.collection_object_id=specimen_part.derived_from_cat_item and
			specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
			coll_obj_cont_hist.container_id=part.container_id and
			part.parent_container_id=sheet.container_id and
			rownum<1000
	</cfquery>
	<cfloop query="bc">
		<cfquery name="ocr" datasource="taccocr">
			select label from output where barcode = '#barcode#'
		</cfquery>
		<cfif len(ocr.label) gt 0>
			<cftry>
				<cfquery name="add" datasource="uam_god">
					update ocr_text set 
						try_date=sysdate,
						ocr_date=sysdate,
						ocr_text='#escapeQuotes(ocr.label)#'
					where
						collection_object_id=#collection_object_id#
				</cfquery>
			<cfcatch>
				<cfquery name="add" datasource="uam_god">
					update ocr_text set 
						try_date=sysdate,
						ocr_date=sysdate,
						ocr_text='ERROR: #cfcatch.message#'
					where
						collection_object_id=#collection_object_id#
				</cfquery>
			</cfcatch>
			</cftry>
		<cfelse>
			<cfquery name="fail" datasource="uam_god">
				update ocr_text set 
					try_date=sysdate
				where
					collection_object_id=#collection_object_id#
			</cfquery>
		</cfif>
	</cfloop>
</cfif>