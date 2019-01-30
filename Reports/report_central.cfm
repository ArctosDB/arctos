<!----
report_central.cfm
for https://github.com/ArctosDB/arctos/issues/1419

create table cf_report_cache (
	cf_report_cache_id number not null,
	guid_prefix varchar2(255),
	report_name varchar2(255),
	report_URL varchar2(255),
	report_descr varchar2(255),
	report_date date,
	summary_data varchar2(4000)
);

create public synonym  cf_report_cache for cf_report_cache;

create unique index pk_cf_report_cache on cf_report_cache (cf_report_cache_id) tablespace uam_idx_1;


CREATE OR REPLACE TRIGGER tr_cf_report_cache_bi before insert ON cf_report_cache for each row
   begin
       IF :new.cf_report_cache_id IS NULL THEN
           select somerandomsequence.nextval into :new.cf_report_cache_id from dual;
       END IF;
   end;
/

sho err;

-- Overdue loans


select
	guid_prefix,
	count(*) c
from
	loan,
	trans,
	collection
where
	loan.transaction_id=trans.transaction_id and
	trans.collection_id=collection.collection_id and
	loan.loan_status != 'closed' and
	(loan.RETURN_DUE_DATE is null or loan.RETURN_DUE_DATE > sysdate)
group by
	guid_prefix
order by
	guid_prefix;


set define off;

CREATE OR REPLACE PROCEDURE proc_rept_cache_loan IS
	BEGIN
		delete from cf_report_cache where report_name='overdue_loan';
		for x in (
			select
				collection.guid_prefix,
				collection.collection_id,
				count(*) c
			from
				loan,
				trans,
				collection
			where
				loan.transaction_id=trans.transaction_id and
				trans.collection_id=collection.collection_id and
				loan.loan_status != 'closed' and
				(loan.RETURN_DUE_DATE is null or loan.RETURN_DUE_DATE > sysdate)
			group by
				collection.guid_prefix,
				collection.collection_id
			order by
				guid_prefix
			) loop

				insert into cf_report_cache (
					guid_prefix,
					report_name,
					report_URL,
					report_descr,
					report_date,
					summary_data
				) values (
					x.guid_prefix,
					'overdue_loan',
					'/Loan.cfm?action=listLoans&collection_id=' || x.collection_id || '&notClosed=true&return_due_date=1400-01-01&to_return_due_date=' || to_char(sysdate,'YYYY-MM-DD'),
					'Overdue loans with a not-closed status',
					to_char(sysdate,'YYYY-MM-DD'),
					x.c || ' ' || x.guid_prefix || ' loans are not closed and have a due date before ' || to_char(sysdate,'YYYY-MM-DD') || '.'
				);
		end loop;
	END;
/
show err;

Unresolved annotations

UAM@ARCTOS> desc annotations
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 ANNOTATION_ID							   NOT NULL NUMBER
 ANNOTATE_DATE							   NOT NULL DATE
 CF_USERNAME								    VARCHAR2(255)
 COLLECTION_OBJECT_ID							    NUMBER
 TAXON_NAME_ID								    NUMBER
 PROJECT_ID								    NUMBER
 PUBLICATION_ID 							    NUMBER
 ANNOTATION							   NOT NULL VARCHAR2(4000)
 REVIEWER_AGENT_ID							    NUMBER
 REVIEWED_FG							   NOT NULL NUMBER(1)
 REVIEWER_COMMENT							    VARCHAR2(255)
 ANNOTATION_GROUP_ID						   NOT NULL NUMBER
 EMAIL									    VARCHAR2(255)
 MEDIA_ID								    NUMBER


set define off;

CREATE OR REPLACE PROCEDURE proc_rept_cache_s_anno IS
	BEGIN
		delete from cf_report_cache where report_name='specimen_annotation';
		for x in (
			select
				collection.guid_prefix,
				count(*) c
			from
				annotations,
				cataloged_item,
				collection
			where
				annotations.COLLECTION_OBJECT_ID=cataloged_item.COLLECTION_OBJECT_ID and
				cataloged_item.collection_id=collection.collection_id and
				annotations.reviewer_comment is null
			group by
				collection.guid_prefix
		) loop

			insert into cf_report_cache (
				guid_prefix,
				report_name,
				report_URL,
				report_descr,
				report_date,
				summary_data
			) values (
				x.guid_prefix,
				'specimen_annotation',
				'/info/reviewAnnotation.cfm?action=show&atype=specimen&guid_prefix=' || x.guid_prefix || '&reviewer_comment=NULL',
				'Unreviewed specimen annotations',
				to_char(sysdate,'YYYY-MM-DD'),
				x.c || ' unreviewed annotations refer to ' || x.guid_prefix || ' specimens.'
			);
		end loop;
	end;
/
sho err;

exec proc_rept_cache_s_anno;

select * from cf_report_cache;



CREATE OR REPLACE PROCEDURE proc_rept_cache_prj_anno IS
	BEGIN
		delete from cf_report_cache where report_name='specimen_annotation';
		for x in (
			select
				collection.guid_prefix,
				count(*) c
			from
				annotations,
				cataloged_item,
				collection
			where
				annotations.COLLECTION_OBJECT_ID=cataloged_item.COLLECTION_OBJECT_ID and
				cataloged_item.collection_id=collection.collection_id and
				annotations.reviewer_comment is null
			group by
				collection.guid_prefix
		) loop

			insert into cf_report_cache (
				guid_prefix,
				report_name,
				report_URL,
				report_descr,
				report_date,
				summary_data
			) values (
				x.guid_prefix,
				'specimen_annotation',
				'/info/reviewAnnotation.cfm?action=show&atype=specimen&guid_prefix=' || x.guid_prefix || '&reviewer_comment=NULL',
				'Unreviewed specimen annotations',
				to_char(sysdate,'YYYY-MM-DD'),
				x.c || ' unreviewed annotations refer to ' || x.guid_prefix || ' specimens.'
			);
		end loop;
	end;
/
sho err;

---->