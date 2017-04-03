<!----------
-- intent:

	--	import Arctos data
	-- manage that stuff here
	-- periodically re-export to Arctos (or globalnames????)

	-- eventually including non-classification stuff (???)
		-- maybe in another table linked by tid


	- keys (tid, parent_tid) are assigned at import and have no realationship to taxon_name_id/anything



-- create a half-key and metadata; make this a multi-user multi-classification environment

	create table htax_dataset (
		dataset_id number not null,
		dataset_name varchar2(255) not null,
		created_by varchar2(255) not null,
		created_date date not null,
		source varchar2(255) not null,
		comments varchar2(4000),
		status varchar2(255)  default 'working' not null
	);
	alter table htax_dataset add source varchar2(255) not null;


	-- status does stuff, so...

	alter table htax_dataset drop constraint ck_htax_dataset_status;

	alter table htax_dataset add constraint ck_htax_dataset_status
   	CHECK (status IN(
		'working',
		'process_to_bulkloader',
		'inserted_term',
		'inserted_noclassterm'
		)
	);



	ALTER TABLE htax_dataset ADD PRIMARY KEY (dataset_id);

	create or replace public synonym htax_dataset for htax_dataset;
	grant all on htax_dataset to manage_taxonomy;

	--	create a hierarchical data structure for classification data

	drop table hierarchical_taxonomy;

	create table hierarchical_taxonomy (
		tid number not null,
		parent_tid number,
		term varchar2(255),
		rank varchar2(255),
		dataset_id number not null
	);


	ALTER TABLE hierarchical_taxonomy ADD PRIMARY KEY (tid);


	--------------------- awaiting help from LKV

	ALTER TABLE hierarchical_taxonomy ADD CONSTRAINT fk_parent_tid  FOREIGN KEY (dataset_id) REFERENCES htax_dataset(dataset_id);
	-- do not accept terms we can't deal with

	-- in test anyway..
	create unique index IU_CTTAXTERM_TERM on cttaxon_term(taxon_term) tablespace uam_idx_1;
		ALTER TABLE cttaxon_term ADD PRIMARY KEY (taxon_term);

	ALTER TABLE hierarchical_taxonomy ADD CONSTRAINT fk_term_type  FOREIGN KEY (rank) REFERENCES cttaxon_term(taxon_term);

	-- unique within dataset

	create unique index iu_term_ds on hierarchical_taxonomy (term,dataset_id);



	SELECT DBMS_METADATA.GET_DDL('CONSTRAINT','PK_CTTAXON_TERM') FROM DUAL;
	SELECT DBMS_METADATA.GET_DDL('CONSTRAINT','SYS_C0024359') FROM DUAL;
	SELECT DBMS_METADATA.GET_DDL('CONSTRAINT','SYS_C0024358') FROM DUAL;
	SELECT DBMS_METADATA.GET_DDL('CONSTRAINT','IS_CLASS_BOOL') FROM DUAL;

	SELECT DBMS_METADATA.GET_DDL('INDEX','IU_CTTAXTERM_TERM') FROM DUAL;


ALTER TABLE cttaxon_term DROP INDEX IU_CTTAXTERM_TERM;

------------------------------------------------------------------------------------------
IU_CTTAXTERM_TERM
IU_TAXONTERM_RELPOS
PK_CTTAXON_TERM




UAM@ARCTEST> select CONSTRAINT_NAME from all_constraints where table_name='CTTAXON_TERM';

CONSTRAINT_NAME
------------------------------------------------------------------------------------------
PK_CTTAXON_TERM
SYS_C0024359
SYS_C0024358
IS_CLASS_BOOL

------------------- /awaiting LKV








	ALTER TABLE hierarchical_taxonomy ADD CONSTRAINT fk_dataset_id  FOREIGN KEY (dataset_id)
  REFERENCES htax_dataset(dataset_id);


	create or replace public synonym hierarchical_taxonomy for hierarchical_taxonomy;
	grant all on hierarchical_taxonomy to manage_taxonomy;


	-- add permissions and error logging

	drop table htax_temp_hierarcicized;

	create table htax_temp_hierarcicized (
		taxon_name_id number not null,
		dataset_id number not null,
		status varchar2(255)
	);

	create or replace public synonym htax_temp_hierarcicized for htax_temp_hierarcicized;
	grant all on htax_temp_hierarcicized to manage_taxonomy;


	ALTER TABLE htax_temp_hierarcicized ADD CONSTRAINT fk_th_dataset_id  FOREIGN KEY (dataset_id)
  REFERENCES htax_dataset(dataset_id);


	-- "seed" table
	create table htax_seed (
		scientific_name varchar2(255) not null,
		taxon_name_id number not null,
		dataset_id number not null,

	);
	create or replace public synonym htax_seed for htax_seed;
	grant all on htax_seed to manage_taxonomy;

	ALTER TABLE htax_seed ADD CONSTRAINT fk_htax_dataset_id  FOREIGN KEY (dataset_id)
  REFERENCES htax_dataset(dataset_id);

create unique index htax_seed_taxdataset on htax_seed (scientific_name,taxon_name_id,dataset_id) tablespace uam_idx_1;



 -- table for nonclassification terms

create table htax_noclassterm (
	nc_tid number not null,
	tid number not null,
	term_type varchar2(255) not null,
	term_value varchar2(255) not null
);

	create or replace public synonym htax_noclassterm for htax_noclassterm;
	grant all on htax_noclassterm to manage_taxonomy;

	ALTER TABLE htax_noclassterm ADD PRIMARY KEY (nc_tid);

	ALTER TABLE htax_noclassterm ADD CONSTRAINT fk_htaxnc_dataset_id  FOREIGN KEY (tid) REFERENCES hierarchical_taxonomy(tid);


CREATE OR REPLACE PROCEDURE proc_hierac_tax IS
	-- note: https://github.com/ArctosDB/arctos/issues/1000#issuecomment-290556611
	--declare
		v_pid number;
		v_tid number;
		v_c number;
		 err_num varchar2(4000);
			      err_msg varchar2(4000);
	begin
		v_pid:=NULL;
		for t in (
			select
				htax_seed.taxon_name_id,
				htax_seed.scientific_name,
				htax_seed.dataset_id,
				htax_dataset.source
			from
				htax_seed,
				htax_dataset
			where
				htax_seed.dataset_id=htax_dataset.dataset_id and
				-- make sure we haven't already processed this record
				(htax_seed.taxon_name_id,htax_seed.dataset_id) not in (select taxon_name_id,dataset_id from htax_temp_hierarcicized) and
				rownum<10000
		) loop
			--dbms_output.put_line(t.scientific_name);
			begin
				for r in (
					select
						term,
						term_type
					from
						taxon_term
					where
						taxon_term.taxon_name_id=t.taxon_name_id and
						source=t.source and
						position_in_classification is not null and
						term_type != 'scientific_name'
					order by
						position_in_classification ASC
				) loop
					--dbms_output.put_line(r.term_type || '=' || r.term);
					-- see if we already have one
					select /*+ result_cache */ count(*) into v_c from hierarchical_taxonomy where term=r.term and rank=r.term_type;
					if v_c=1 then
						-- grab the ID for use on the next record, move on
						select /*+ result_cache */ tid into v_pid from hierarchical_taxonomy where term=r.term and rank=r.term_type;
					else
						-- create the term
						-- first grab the current ID
						select someRandomSequence.nextval into v_tid from dual;
						insert into hierarchical_taxonomy (
							tid,
							parent_tid,
							term,
							rank,
							dataset_id
						) values (
							v_tid,
							v_pid,
							r.term,
							r.term_type,
							t.dataset_id
						);

						-- now assign the term we just made's ID to parent so we can use it in the next loop
						v_pid:=v_tid;
					end if;
				end loop;
				-- log
				insert into htax_temp_hierarcicized (taxon_name_id,dataset_id,status) values (t.taxon_name_id,t.dataset_id,'inserted_term');
				exception when others then
				  err_num := SQLCODE;
			      err_msg := SUBSTR(SQLERRM, 1, 100);


				insert into htax_temp_hierarcicized (taxon_name_id,dataset_id,status) values (t.taxon_name_id,t.dataset_id,'fail: ' || err_msg);
				end;
		end loop;
	end;
	/
sho err;


BEGIN
DBMS_SCHEDULER.DROP_JOB('J_PROC_HIERAC_TAX');
END;
/

BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'J_PROC_HIERAC_TAX',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'proc_hierac_tax',
   start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=3',
   enabled             =>  TRUE,
   end_date           =>  NULL,
   comments           =>  'PROCESS HIERARCHICAL TAXONOMY');
END;
/

CREATE OR REPLACE PROCEDURE proc_hierac_tax_noclass IS
begin


	 -- first get tid and DATASET_ID of inserted_term records
	for r in (
		select distinct
			hierarchical_taxonomy.tid,
			hierarchical_taxonomy.DATASET_ID,
			htax_dataset.source,
			htax_temp_hierarcicized.TAXON_NAME_ID
		from
			htax_temp_hierarcicized,
			htax_seed,
			htax_dataset,
			hierarchical_taxonomy
		where
			htax_temp_hierarcicized.status='inserted_term' and
			htax_temp_hierarcicized.TAXON_NAME_ID=htax_seed.TAXON_NAME_ID and
			htax_temp_hierarcicized.DATASET_ID=htax_seed.DATASET_ID and
			htax_seed.SCIENTIFIC_NAME=hierarchical_taxonomy.TERM and
			htax_seed.DATASET_ID = hierarchical_taxonomy.DATASET_ID and
			htax_seed.DATASET_ID = htax_dataset.DATASET_ID and
			rownum < 10000
	) loop
		--dbms_output.put_line(r.tid || '=>' || r.TAXON_NAME_ID);
		-- now get terms from Arctos
		for t in (
			select
				term,
				TERM_TYPE
			from
				taxon_term
			where
				TAXON_NAME_ID=r.TAXON_NAME_ID and
				source=r.source and
				POSITION_IN_CLASSIFICATION is null
		) loop
			--dbms_output.put_line('-----' || t.term || '=' || t.TERM_TYPE);
			insert into  htax_noclassterm (
				nc_tid,
				tid,
				term_type,
				term_value
			) values (
				somerandomsequence.nextval,
				r.tid,
				t.TERM_TYPE,
				t.term
			);
		end loop;
		update htax_temp_hierarcicized set status='inserted_noclassterm' where TAXON_NAME_ID=r.TAXON_NAME_ID and DATASET_ID=r.DATASET_ID;
	end loop;
end;
/
sho err;



BEGIN
DBMS_SCHEDULER.DROP_JOB('J_PROC_HIERAC_TAX_NC');
END;
/

BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'J_PROC_HIERAC_TAX_NC',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'proc_hierac_tax_noclass',
   start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=3',
   enabled             =>  TRUE,
   end_date           =>  NULL,
   comments           =>  'PROCESS HIERARCHICAL TAXONOMY (noclassification)');
END;
/

exec proc_hierac_tax_noclass

select STATE,LAST_RUN_DURATION,MAX_RUN_DURATION,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_PROC_HIERAC_TAX';
select STATE,LAST_RUN_DURATION,MAX_RUN_DURATION,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_PROC_HIERAC_TAX_NC';



exec proc_hierac_tax;

BEGIN
DBMS_SCHEDULER.DROP_JOB('J_PROC_HIERAC_TAX');
END;
/

BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'J_PROC_HIERAC_TAX',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'proc_hierac_tax',
   start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=3',
   enabled             =>  TRUE,
   end_date           =>  NULL,
   comments           =>  'PROCESS HIERARCHICAL TAXONOMY');
END;
/

select STATE,LAST_RUN_DURATION,MAX_RUN_DURATION,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_PROC_HIERAC_TAX';

















------------------ old-n-busted follows -------------------------
alter table hierarchical_taxonomy add status varchar2(255);

update hierarchical_taxonomy set status='ready_to_push_bl' where status is null and rownum<20000;


-- temp_ht is a list of terms we need to get data and make it hierarchical for
drop table temp_ht;

create table temp_ht (
	TAXON_NAME_ID number not null,
	SCIENTIFIC_NAME varchar2(255) not null,
	dataset_name varchar2(255) not null,
	source varchar2(255) not null
);



-- temp_hierarcicized is a log table so we can avoid weird oracle errors
drop table temp_hierarcicized;
create table temp_hierarcicized (taxon_name_id number,dataset_name varchar2(255));



-- small test

insert into temp_ht (scientific_name,taxon_name_id,dataset_name,source) (
			select distinct
				scientific_name,
				taxon_name.taxon_name_id,
				'small_test',
				'Arctos Plants'
			from
				taxon_name,
				taxon_term
			where
				taxon_name.taxon_name_id=taxon_term.taxon_name_id and
				taxon_term.source='Arctos Plants' and
				scientific_name like 'Veronica %'
			);

-- wut?

select count(*) from temp_ht;

commit;

-- performance is awesome, so move on to...

-- very large test

delete from temp_hierarcicized;
delete from temp_ht;
delete from hierarchical_taxonomy;

insert into temp_ht (scientific_name,taxon_name_id,dataset_name,source) (
	select distinct
		scientific_name,
		taxon_name.taxon_name_id,
		'small_test',
		'Arctos'
	from
		taxon_name,
		taxon_term
	where
		taxon_name.taxon_name_id=taxon_term.taxon_name_id and
		taxon_term.source='Arctos'
	);




-- unprocessed
select count(*) from temp_ht where scientific_name not in (select TERM from hierarchical_taxonomy);


1402338 rows created.

Elapsed: 00:03:56.85

-- running for 10000 rows...
exec proc_hierac_tax;
00:00:56.33
Elapsed: 00:02:05.43

select count(*) from hierarchical_taxonomy;
select count(*) from temp_hierarcicized;

-- yea that's slow - will run in ~day or so tho - try more realistic import

delete from temp_ht;

delete from temp_hierarcicized;
delete from hierarchical_taxonomy;

insert into temp_ht (scientific_name,taxon_name_id,dataset_name,source) (
	select distinct
		scientific_name,
		taxon_name.taxon_name_id,
		'med_test',
		'Arctos'
	from
		taxon_name,
		taxon_term
	where
		taxon_name.taxon_name_id=taxon_term.taxon_name_id and
		taxon_term.source='Arctos' and
		term_type='class' and
		term='Aves'
	);

-- now let the stored procedure chew on things



select count(*) from temp_hierarcicized;
select count(*) from hierarchical_taxonomy;

delete from temp_hierarcicized;
delete from hierarchical_taxonomy;



--------->
<cfinclude template="/includes/_header.cfm">
<cfset title="hierarchical taxonomy editor">
<p>
	<a href="taxonomyTree.cfm?action=nothing">home</a>
</p>

<cfif action is "nothing">
	<p>
		ABOUT:
	</p>
	<ul>
		<li>
			This is a classification editor; it will NOT create, delete, or alter taxon_name.
		</li>
		<li>
			This form creates hierarchical data from Arctos. Not all data in Arctos can be transformed, and some will be transformed
				unpredictably. For example, given
				<ul><li><strong>genus</strong>--><strong>family</strong>--><strong>order</strong></li></ul>
				 and
				 <ul><li><strong>othergenus</strong>--><strong>family</strong>--><strong>otherorder</strong></li></ul>
				 that is, inconsistent hierarchies - here one family split between two orders - then all <strong>family</strong> will end up
				 as a child of either <strong>order</strong> or <strong>otherorder</strong>, whichever is encountered first.
		</li>
	</ul>

	<p>
		DEPENDANCIES & COMPONENTS
	</p>
	<ul>
		<li>Oracle table temp_ht holds "seed" records; those selected by the user to be hierarchicalicized.</li>
		<li>Oracle table temp_hierarcicized is an internal processing log table</li>
		<li>Oracle table cf_temp_classification is the hierarchical data</li>
		<li>Oracle Procedure proc_hierac_tax populates cf_temp_classification from temp_ht</li>
		<li>Oracle Job J_PROC_HIERAC_TAX runs proc_hierac_tax</li>
		<li>CF Scheduled Task hier_to_bulk flattens the hierarchical data for re-import to Arctos</li>
		<li>
			cf_temp_classification_fh is populated by hier_to_bulk
			<p>IMPORTANT: we may want to let hier_to_bulk write directly to the classification bulkloader table
				with status set to autoinsert. That would fully automate repatriation. Check results THOROUGHLY first. </p>
		</li>
	</ul>


	<cfquery name="mg" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select distinct (dataset_name) from htax_dataset
	</cfquery>
	<cfoutput>
		select a dataset to edit...
		<cfloop query="mg">
			<p>
				<a href="taxonomyTree.cfm?action=manageDataset&dataset_name=#dataset_name#">#dataset_name#</a>
			</p>
		</cfloop>

		... or <a href="taxonomyTree.cfm?action=createDataset">create a new dataset</a>
	</cfoutput>
</cfif>

<cfif action is "createDataset">
	<cfoutput>
	Create a dataset. A dataset is a list of terms from an Arctos classification which will be made hierarchical, and accompanying metadata/
	<form method="post" action="taxonomyTree.cfm">
		<input type="hidden" name="action" value="saveCreateDataset">
		<label for="dataset_name">dataset_name</label>
		<input type="text" name="dataset_name" placeholder="dataset_name">
		<cfquery name="ctsource" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select source from CTTAXONOMY_SOURCE order by source
		</cfquery>
		<label for="source">source</label>
		<select name="source">
			<option value=""></option>
			<cfloop query="ctsource">
				<option value="#source#">#source#</option>
			</cfloop>
		</select>

		<label for="comments">comments</label>
		<input type="text" name="comments" placeholder="comments">
		<br><input type="submit" value="create dataset">

	</form>
	</cfoutput>
</cfif>
<cfif action is "saveCreateDataset">
	<cfquery name="saveCreateDataset" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into htax_dataset (
			dataset_id,
			dataset_name,
			created_by,
			created_date,
			source,
			comments
		) values (
			somerandomsequence.nextval,
			'#dataset_name#',
			'#session.username#',
			'#dateformat(now(),"yyyy-mm-dd")#',
			'#source#',
			'#comments#'
		)
	</cfquery>
	<cflocation url="taxonomyTree.cfm?action=manageDataset&dataset_name=#dataset_name#" addtoken="false">

</cfif>
<!------------------------------------------------------------------------------------------------->
<cfif action is "manageDataset">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from htax_dataset where dataset_name='#dataset_name#'
	</cfquery>
	<cfoutput>
		Managing #d.dataset_name# created #d.created_by# on #d.created_date#

		<p>
			Source: #d.source#
		</p>
		<p>
			comments: #d.comments#
		</p>

	<cfquery name="nht" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from htax_seed where dataset_id=#d.dataset_id#
	</cfquery>
	<p>
		#nht.c# records have been seeded. You may add more (use the form below). Duplicates are disallowed (and Oracle bug
		qerltcInsertSelectRop_bad_state prevents silently ignoring them) - contact us if you need help.
	</p>

	<cfquery name="nht_il" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select status,count(*) c from htax_temp_hierarcicized where dataset_id=#d.dataset_id# group by status order by status
	</cfquery>

	<p>
		Import Status:
	</p>
	<cfloop query="nht_il">
		<br>#status# : #c#
	</cfloop>

	<p>
		<a href="taxonomyTree.cfm?action=noSuccessimport&dataset_name=#dataset_name#">list not-success</a>
	</p>


	<cfquery name="ht" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from hierarchical_taxonomy where dataset_id=#d.dataset_id#
	</cfquery>

	<cfquery name="procSuccess" dbtype="query">
		select c from nht_il where status='success'
	</cfquery>
	<cfif ht.c gt procSuccess.c>
		<p>
			trying to create names.... The import has resulted in more terms than you seeded. Something is missing from
			Arctos. This form will not create taxa. <a href="taxonomyTree.cfm?action=mismatch_import&dataset_name=#dataset_name#">click here</a>
		</p>
	</cfif>
	<cfif ht.c lt procSuccess.c>
		<p>
			 The import has resulted in fewer terms than you seeded.
			 <a href="taxonomyTree.cfm?action=mismatch_import&dataset_name=#dataset_name#">click here</a>
			 and that needs added....

		</p>
	</cfif>

	<p>
		#ht.c# records are available to manage hierarchically. Everything you've seeded should match what's here. The conversion
		process is automatic and should happen at the rate of a few thousand records per minute. Reload or return to this page to see
		progress.
	</p>

	<p>
		When you are done seeding, you may
		<a href="taxonomyTree.cfm?action=manageLocalTree&dataset_name=#dataset_name#">manage these data in the classification tree editor</a>
	</p>

	<p>
		<a href="taxonomyTree.cfm?action=deleteDataset&dataset_name=#dataset_name#">Delete this dataset</a>. This cannot be undone.
	</p>





	</cfoutput>

<p>
	Find records with which to "seed" the dataset. Large datasets (tested to 1.4m records) are manageable,
	but come with performance limitations; you may need DBA assistance and a lot of memory. Smaller datasets are much
	easier to work with. Consider limiting your query to around 10,000 names.
	<p>
		Note that data in Arctos are independent; classifications are not related in any way.
		This app will only update the records for which the taxon name
		appears as a term here.
	</p>
</p>
<script>


$(function() { //shorthand document.ready function
    $('#inspect').on('click', function(e) { //use on if jQuery 1.7+
       // var data = $("#f_ds_filter :input").serializeArray();
        //console.log(data); //use the console for debugging, F12 in Chrome, not alerts
         $.getJSON("/component/test.cfc",
			{
				method : "getSeedTaxSum",
				source: $("#source").val(),
				kingdom: $("#kingdom").val(),
				phylum: $("#phylum").val(),
				class: $("#class").val(),
				order: $("#order").val(),
				family: $("#family").val(),
				genus: $("#genus").val(),
				returnformat : "json",
				queryformat : 'column'
			},
			function (r) {
				console.log(r);
				alert('your search found ' + r.DATA.C[0] + ' taxa');
				//myTree.parse(r, "jsarray");
				//myTree.parse(r, "jsarray");
				//myTree.openAllItems(0);

			}
		);

    });
});


</script>

<p>
	Find seed taxonomy. Terms are exact-match case-sensitive.
</p>
<form id="f_ds_filter" method="post" action="taxonomyTree.cfm">
	<cfoutput>
		<input type="hidden" name="dataset_id" id="dataset_id" value="#d.dataset_id#">
		<input type="hidden" name="dataset_name" id="dataset_name" value="#d.dataset_name#">
		<input type="hidden" name="action" id="action" value="go_seed_ds">
		<input type="hidden" name="source" id="source" value="#d.source#">
	</cfoutput>



	<label for="kingdom">kingdom</label>
	<input type="text" name="kingdom" id="kingdom" placeholder="kingdom" size="60">

	<label for="phylum">phylum</label>
	<input type="text" name="phylum" id="phylum" placeholder="phylum" size="60">

	<label for="class">class</label>
	<input type="text" name="class" id="class" placeholder="class" size="60">

	<label for="order">order</label>
	<input type="text" name="order" id="order" placeholder="order" size="60">


	<label for="family">family</label>
	<input type="text" name="family" id="family" placeholder="family" size="60">

	<label for="genus">genus</label>
	<input type="text" name="genus" id="genus" placeholder="genus" size="60">
	<p>
		Click this ONCE! to get a recordcount. It may take some time. You'll get an alert when it's done.
	</p>
	<br><input type="button" id="inspect" value="inspect">
	<p>
		After using the "inspect" button, and having found a reasonable number of taxa,
		<input type="submit" onclick="goPullSeed" value="pull seed data">
	</p>
</form>


</cfif>
<!------------------------------------------------------------------------------------------------->

<cfif action is "noSuccessimport">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				htax_temp_hierarcicized.status,
				taxon_name.scientific_name
			from
				taxon_name,
				htax_temp_hierarcicized,
				htax_dataset
			where
				taxon_name.TAXON_NAME_ID=htax_temp_hierarcicized.TAXON_NAME_ID and
				htax_dataset.dataset_name='#dataset_name#' and
				htax_dataset.dataset_id=htax_temp_hierarcicized.dataset_id and
				htax_temp_hierarcicized.status != 'success'
			group by
				htax_temp_hierarcicized.status,
				taxon_name.scientific_name
			order by
				htax_temp_hierarcicized.status,
				taxon_name.scientific_name

		</cfquery>
		<cfloop query="d">
			<br>#status#: <a href="/name/#scientific_name#">#scientific_name#</a>
		</cfloop>
	</cfoutput>
</cfif>

<cfif action is "deleteDataset">
	<cfoutput>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from htax_dataset where dataset_name='#dataset_name#'
	</cfquery>
	<cftransaction>
		<cfquery name="d_nc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from htax_noclassterm where tid in ( select tid from hierarchical_taxonomy where dataset_id=#d.dataset_id#)
		</cfquery>
		<cfquery name="d_htax_temp_hierarcicized" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from htax_temp_hierarcicized where dataset_id =#d.dataset_id#
		</cfquery>
		<cfquery name="d_htax_seed" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from htax_seed where dataset_id =#d.dataset_id#
		</cfquery>
		<cfquery name="d_hierarchical_taxonomy" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from hierarchical_taxonomy where dataset_id =#d.dataset_id#
		</cfquery>
		<cfquery name="d_htax_dataset" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from htax_dataset where dataset_id =#d.dataset_id#
		</cfquery>

	</cftransaction>

	</cfoutput>








</cfif>
<cfif action is "mismatch_import">
	<cfquery name="mia" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select distinct
			term
		from
			hierarchical_taxonomy,
			htax_seed,
			htax_dataset
		where
			hierarchical_taxonomy.dataset_id=htax_seed.dataset_id and
			htax_seed.dataset_id=htax_dataset.dataset_id and
			htax_dataset.dataset_name='#dataset_name#' and
			term not in (
				select scientific_name from taxon_name
			)
		order by
			term
	</cfquery>
	<p>
		This app will not create taxon names.
		The following terms do not exist as taxon names in Arctos but are terms in your import.
		These probably exist because they're used in other terms - eg, a species (binomial) used as
		a term in a subspecies and which does not exist as a name will appear here. Bad spellings of
		Family etc. will also appear here.

		You may need to delete your dataset, fix the problems (by adding taxa or correcting mistakes), and import again.
	</p>
	<cfoutput>
		<cfloop query="mia">
			<br>#term#
		</cfloop>
	</cfoutput>
</cfif>


<cfif action is "go_seed_ds">
	<cfquery name="seed" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" result="r">
		insert
		into htax_seed (scientific_name,taxon_name_id,dataset_id) (
		select distinct
			scientific_name,
			taxon_name.taxon_name_id,
			#dataset_id#
		from
			taxon_name,
			taxon_term
		where
			taxon_name.taxon_name_id=taxon_term.taxon_name_id and
			taxon_term.source='#source#'
			<cfif len(kingdom) gt 0>
				and term_type='kingdom' and term='#kingdom#'
			</cfif>
			<cfif len(phylum) gt 0>
				and term_type='phylum' and term='#phylum#'
			</cfif>
			<cfif len(class) gt 0>
				and term_type='class' and term='#class#'
			</cfif>
			<cfif len(order) gt 0>
				and term_type='order' and term='#order#'
			</cfif>
			<cfif len(family) gt 0>
				and term_type='family' and term='#family#'
			</cfif>
			<cfif len(genus) gt 0>
				and term_type='genus' and term='#genus#'
			</cfif>
		)
	</cfquery>
	<cfoutput>
		<cflocation url="taxonomyTree.cfm?action=manageDataset&dataset_name=#dataset_name#" addtoken="false">
	</cfoutput>


</cfif>
<!------------------------------------------------------>

<cfif action is "manageLocalTree">

	<cfif not isdefined("dataset_name") or len(dataset_name) is 0>
		bad call<cfabort>
	</cfif>
	<cfquery name="did" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select dataset_id from htax_dataset where dataset_name='#dataset_name#'
	</cfquery>
	<cfif did.recordcount is not 1>
		bad call: recordset not found<cfabort>
	</cfif>


	<cfoutput>
		<input type="hidden" name="dataset_id" id="dataset_id" value="#did.dataset_id#">
	</cfoutput>
	<div id="statusDiv" style="position:fixed;top:100;right:0;margin-right:2em;padding:.2em;border:1px solid red;z-index:9999999;">status</div>

	<script type='text/javascript' src='/includes/dhtmlxtree.js'><!-- --></script>
	<script type="text/javascript" src="/includes/dhtmlxTree_v50_std/codebase/dhtmlxtree.js"></script>
	<link rel="STYLESHEET" type="text/css" href="/includes/dhtmlxTree_v50_std/codebase/dhtmlxtree.css">

	<script>



function deletedRecord(theID){
	// deleted something
	// remove it from the view
	myTree.deleteItem(theID,false);
	$("#statusDiv").html('delete successful');
	$(".ui-dialog-titlebar-close").trigger('click');
}
function createdNewTerm(id){
	//alert('am createdNewTerm have id=' + id);
	//alert(' close the modal');
	// close the modal
	$(".ui-dialog-titlebar-close").trigger('click');
	// expand the node
	//alert(' closed the modal; expanding node');
	expandNode(id);
	//alert(' expanded;updatestatus');
	// update status
	$("#statusDiv").html('created new term');
	myTree.selectItem(id);
	myTree.focusItem(id);
}
function expandNode(id){
	//alert('am expandNode');
	$("#statusDiv").html('working...');
    $.getJSON("/component/test.cfc",
		{
			method : "getTaxTreeChild",
			dataset_id: $("#dataset_id").val(),
			id : id,
			returnformat : "json",
			queryformat : 'column'
		},
		function (r) {
			if (r.toString().substring(0,5)=='ERROR'){
				$("#statusDiv").html(r);
				alert(r);
			} else {
				for (i=0;i<r.ROWCOUNT;i++) {
					//insertNewChild(var) does not work for some insane reason, so.....
					// delete (if exists)
					myTree.deleteItem(r.DATA.TID[i],false);

					var d="myTree.insertNewChild(" + r.DATA.PARENT_TID[i]+','+r.DATA.TID[i]+',"'+r.DATA.TERM[i]+' (' + r.DATA.RANK[i] + ')",0,0,0,0)';
					eval(d);
				}
				$("#statusDiv").html('done');
			}
		}
	);

		//alert('am expandNode DONE');

}



function savedMetaEdit(tid,newVal){
		//alert('t');
		//alert('am parent t with tid=' + tid + ' i got newVal=' + newVal);

		//onclick="var d=new Date(); myTree.setItemText(myTree.getSelectedItemId(),document.getElementById('ed1').value);"
		//var myTree= window.parent.document.myTree;
		myTree.setItemText(tid,newVal);

		// now close the edit box
		$("#statusDiv").html('term edits saved');

		$(".ui-dialog-titlebar-close").trigger('click');

	}

		jQuery(document).ready(function() {

			myTree = new dhtmlXTreeObject('treeBox', '100%', '100%', 0);
			myTree.setImagesPath("/includes/dhtmlxTree_v50_std/codebase/imgs/dhxtree_material/");


			myTree.enableDragAndDrop(true);
			myTree.enableCheckBoxes(true);
			myTree.enableTreeLines(true);
			myTree.enableTreeImages(false);
			myTree.enableItemEditor(false);

			initTree();


			myTree.attachEvent("onCheck", function(id){
			  //  alert('this should edit ' + id);


			    var guts = "/form/hierarchicalTaxonomyEdit.cfm?tid=" + id;
				$("<iframe src='" + guts + "' id='dialog' class='popupDialog' style='width:800px;height:600px;'></iframe>").dialog({
					autoOpen: true,
					closeOnEscape: true,
					height: 'auto',
					modal: true,
					position: ['center', 'center'],
					title: 'Edit Term',
						width:800,
			 			height:600,
					close: function() {
						$( this ).remove();
					}
				}).width(800-10).height(600-10);
				$(window).resize(function() {
					$(".ui-dialog-content").dialog("option", "position", ['center', 'center']);
				});
				$(".ui-widget-overlay").click(function(){
				    $(".ui-dialog-titlebar-close").trigger('click');
				});



			    // uncheck everything
			    var ids=myTree.getAllSubItems(0).split(",");
	    		for (var i=0; i<ids.length; i++){
	       			myTree.setCheck(ids[i],0);
	    		}
	    		//leave this checked for easy reference; uncheck on close
			});


			myTree.attachEvent("onDblClick", function(id){
				expandNode(id);


			});

			myTree.attachEvent("onDrop", function(sId, tId, id, sObject, tObject){
				$("#statusDiv").html('working....');
			    $.getJSON("/component/test.cfc",
					{
						method : "saveParentUpdate",
						dataset_id: $("#dataset_id").val(),
						tid : sId,
						parent_tid : tId,
						returnformat : "json",
						queryformat : 'column'
					},
					function (r) {
						console.log(r);
						if (r=='success') {
							$("#statusDiv").html('successful save');
						}else{
							alert(r);
							$("#statusDiv").html(r);
						}
					}
				);
			});
			$( "#srch" ).change(function() {
				performSearch();
			});
			$( "#srchBtn" ).click(function() {
				performSearch();
			});
		});
		// end ready function


		function performSearch(){
			$("#statusDiv").html('working...');
			myTree.deleteChildItems(0);
			$.getJSON("/component/test.cfc",
				{
					method : "getTaxTreeSrch",
					dataset_id: $("#dataset_id").val(),
					q: $( "#srch" ).val(),
					returnformat : "json",
					queryformat : 'column'
				},
				function (r) {
					if (r.toString().substring(0,5)=='ERROR'){
						$("#statusDiv").html(r);
						alert(r);
					} else {
						console.log(r);
						//myTree.parse(r, "jsarray");
						myTree.parse(r, "jsarray");
						myTree.openAllItems(0);
						$("#statusDiv").html('done');
					}
				}
			);
		}


		function initTree(){
			$("#statusDiv").html('initializing');
			myTree.deleteChildItems(0);
			$.getJSON("/component/test.cfc",
				{
					method : "getInitTaxTree",
					dataset_id: $("#dataset_id").val(),
					returnformat : "json",
					queryformat : 'column'
				},
				function (r) {
					myTree.parse(r, "jsarray");
				}
			);
			$("#statusDiv").html('ready');
		}

	//tree.insertNewChild(0,1,"New Node 1",0,0,0,0,"SELECT,CALL,TOP,CHILD,CHECKED");

	</script>

	<label for="srch">search (starts with)</label>
	<input id="srch">
	<input type="button" value="search" id="srchBtn">

	<br>
	<input type="button" value="reset tree" onclick="initTree()">
	<br>
	<input type="button" value="add a node" onclick="addNewNode()">


	<div id="treeBox" style="width:200;height:200"></div>
</cfif>

<cfinclude template="/includes/_footer.cfm">

<!----

	-- everything below here is old-n-busted and can probably be deleted
	-- but keep it for not
	-- because im a packrat

	--- oldcrap

				-- populate
				-- first a root node
				insert into hierarchical_taxonomy (tid,parent_tid,term,rank) values (someRandomSequence.nextval,NULL,'everything',NULL);

				-- now go through CTTAXON_TERM
				-- first one is sorta weird
				declare
					pid number;
				begin
					for r in (select distinct(term) term from taxon_term where source='Arctos' and term_type='superkingdom') loop
						select tid into pid from hierarchical_taxonomy where term='everything';
						dbms_output.put_line(r.term);

						insert into hierarchical_taxonomy (tid,parent_tid,term,rank) values (someRandomSequence.nextval,pid,r.term,'superkingdom');

					end loop;
				end;
				/
				-- shit, that don't work...

				Plan Bee:

				loop from 1 to....
				select max(POSITION_IN_CLASSIFICATION) from taxon_term where source='Arctos';
				MAX(POSITION_IN_CLASSIFICATION)
				-------------------------------
						     28


				- grab distinct terms
				- insert them
				--- uhh, I get lost here

				Plan Cee:

				grab one whole record. Insert it. Grab another, reuse what's possible. Do not need "everything" for this - "the tree" will have
					many roots.







				-- blargh, tooslow
				create table temp_ht  as
						select
							scientific_name,
							taxon_name.taxon_name_id
						from
							taxon_name,
							taxon_term
						where
							taxon_name.taxon_name_id=taxon_term.taxon_name_id and
							taxon_term.source='Arctos' and
							term_type='superkingdom' and
							taxon_name.taxon_name_id not in (select taxon_name_id from temp_hierarcicized)
							;

					insert into temp_ht (scientific_name,taxon_name_id) (
						select distinct
							scientific_name,
							taxon_name.taxon_name_id
						from
							taxon_name,
							taxon_term
						where
							taxon_name.taxon_name_id=taxon_term.taxon_name_id and
							taxon_term.source='Arctos' and
							term_type='kingdom' and
							taxon_name.taxon_name_id not in (select taxon_name_id from temp_hierarcicized)
						);






	CREATE OR REPLACE PROCEDURE temp_update_junk IS
	--declare
		v_pid number;
		v_tid number;
		v_c number;
	begin
		v_pid:=NULL;
		for t in (
			select
				*
			from
				temp_ht
			where
				taxon_name_id not in (select taxon_name_id from temp_hierarcicized) and
				rownum<10000
		) loop
			--dbms_output.put_line(t.scientific_name);
			-- we'll never have this, just insert
			-- actually, I don't think we need this at all, it should usually be handled by eg, species (lowest-ranked term)

			for r in (
				select
					term,
					term_type
				from
					taxon_term
				where
					taxon_term.taxon_name_id =t.taxon_name_id and
					source='Arctos' and
					position_in_classification is not null and
					term_type != 'scientific_name'
				order by
					position_in_classification ASC
			) loop
				--dbms_output.put_line(r.term_type || '=' || r.term);
				-- see if we already have one
				select count(*) into v_c from hierarchical_taxonomy where term=r.term and rank=r.term_type;
				if v_c=1 then
					-- grab the ID for use on the next record, move on
					select tid into v_pid from hierarchical_taxonomy where term=r.term and rank=r.term_type;
				else
					-- create the term
					-- first grab the current ID
					select someRandomSequence.nextval into v_tid from dual;
					insert into hierarchical_taxonomy (
						tid,
						parent_tid,
						term,
						rank
					) values (
						v_tid,
						v_pid,
						r.term,
						r.term_type
					);
					-- now assign the term we just made's ID to parent so we can use it in the next loop
					v_pid:=v_tid;
				end if;


			end loop;
			-- log
			insert into temp_hierarcicized (taxon_name_id) values (t.taxon_name_id);
		end loop;
	end;
	/


	exec temp_update_junk;



SELECT  LPAD(' ', 2 * LEVEL - 1) || term ,
SYS_CONNECT_BY_PATH(term, '/')  FROM hierarchical_taxonomy
 START WITH parent_tid is null  CONNECT BY PRIOR tid = parent_tid;

SELECT  LPAD(' ', 2 * LEVEL - 1) || term   FROM hierarchical_taxonomy   START WITH tid in ( select tid from hierarchical_taxonomy where term like 'Latia%') CONNECT BY PRIOR tid = parent_tid;

SELECT TID,PARENT_TID,TERM term   FROM hierarchical_taxonomy   START WITH parent_tid is null  CONNECT BY PRIOR tid = parent_tid;


SELECT TID,PARENT_TID,TERM term   FROM hierarchical_taxonomy   START WITH tid=82796159  CONNECT BY PRIOR parent_tid=tid ;

SELECT TID,PARENT_TID,TERM term   FROM hierarchical_taxonomy   START WITH
tid in (select tid from hierarchical_taxonomy where term like 'Latia%')
CONNECT BY PRIOR tid=parent_tid ;

SELECT TID,PARENT_TID,TERM term   FROM hierarchical_taxonomy   START WITH
tid in (select tid from hierarchical_taxonomy where term like 'Latia%')
CONNECT BY PRIOR parent_tid=tid ;

SELECT TID,PARENT_TID,TERM ,SYS_CONNECT_BY_PATH(term, '/')    FROM hierarchical_taxonomy   START WITH
 term like 'Latia%'
CONNECT BY PRIOR tid=parent_tid ;

SELECT TID,PARENT_TID,TERM term   FROM hierarchical_taxonomy where term like 'Latia%'
CONNECT BY PRIOR tid=parent_tid ;

SELECT  LPAD(' ', 2 * LEVEL - 1) || term   FROM hierarchical_taxonomy
where term like 'Latia%' START WITH parent_tid is null  CONNECT BY root tid = parent_tid;

nocycle
SELECT term , CONNECT_BY_ROOT parent_tid "Manager",
   LEVEL-1 "Pathlen", SYS_CONNECT_BY_PATH(parent_tid, '/') "Path"
   FROM hierarchical_taxonomy
   WHERE  term like 'Latia%'
   CONNECT BY PRIOR tid = parent_tid;

SELECT
term,
 tid,
  parent_tid
FROM hierarchical_taxonomy
start with term like 'Latia%'
CONNECT BY PRIOR tid = parent_tid;

SELECT
term,
 tid,
  parent_tid
FROM hierarchical_taxonomy
start with tid in (select tid from hierarchical_taxonomy where term like 'Latia%')
CONNECT BY PRIOR tid = parent_tid;

SELECT
term,
 tid,
  parent_tid
FROM hierarchical_taxonomy
start with parent_tid in (select parent_tid from hierarchical_taxonomy where term like 'Latia%')
CONNECT BY PRIOR tid = parent_tid;


select rpad('*',2*level,'*') || TID idstr, parent_tid, score,
           (select sum(score)
                  from hierarchical_taxonomy t2
                     start with t2.TID = hierarchical_taxonomy.TID
                     connect by prior TID = parent_tid) score2
      from hierarchical_taxonomy
    start with parent_tid is null
    connect by prior TID = parent_tid
    ;





select *
from EMP
start with EMPNO = :x
connect by prior MGR = EMPNO;





select * from (
	SELECT  LPAD(' ', 2 * LEVEL - 1) || term term,
	SYS_CONNECT_BY_PATH(term, '/') x  FROM hierarchical_taxonomy
	 START WITH parent_tid is null  CONNECT BY PRIOR tid = parent_tid
) where term like '%Latia%';


select
	lpad(' ',level*2,' ')||term term,
SYS_CONNECT_BY_PATH(term, '/') x
      from hierarchical_taxonomy
     START WITH parent_tid is null
    CONNECT BY PRIOR tid = parent_tid
	;


SELECT TID,PARENT_TID,TERM term   FROM hierarchical_taxonomy   START WITH parent_tid in (select parent_tid from hierarchical_taxonomy where term like 'Latia%')  CONNECT BY PRIOR parent_tid=tid ;

select term from hierarchical_taxonomy where term like 'Latia%'


	start with container_id IN (
					#sql#
				)
				connect by prior parent_container_id = container_id




 TID								   NOT NULL NUMBER
 PARENT_TID								    NUMBER
 TERM



SELECT LEVEL,
  2   LPAD(' ', 2 * LEVEL - 1) || first_name || ' ' ||
  3   last_name AS employee
  4  FROM employee
  5  START WITH employee_id = 1
  6  CONNECT BY PRIOR employee_id = manager_id;

		create table hierarchical_taxonomy (
		tid number not null,
		parent_tid number,
		term varchar2(255),
		rank varchar2(255)
	);


			select
				scientific_name,
				term,
				term_type,
				position_in_classification
			from
				taxon_name,
				taxon_term
			where
				taxon_name.taxon_name_id=taxon_term.taxon_name_id and
				source='Arctos' and
				position_in_classification is not null and
				-- ignore scientific_name, we're getting it from taxon_name
				taxon_name.taxon_name_id not in (select taxon_name_id from temp_hierarcicized) and
				rownum=1
			order by position_in_classification
		) loop
			dbms_output.put_line(r.term || '=' || r.term_type);

UAM@ARCTOS> desc taxon_term
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 TAXON_TERM_ID							   NOT NULL NUMBER
 TAXON_NAME_ID							   NOT NULL NUMBER
 CLASSIFICATION_ID							    VARCHAR2(4000)
 TERM								   NOT NULL VARCHAR2(4000)
 TERM_TYPE								    VARCHAR2(255)
 SOURCE 							   NOT NULL VARCHAR2(255)
 GN_SCORE								    NUMBER
 POSITION_IN_CLASSIFICATION						    NUMBER
 LASTDATE							   NOT NULL DATE
 MATCH_TYPE								    VARCHAR2(255)



-- got a decent sample in temp_hierarcicized, write some tree code maybe....

---->













<!------------------

not very happy with jstree, try something else




<link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/jstree/3.3.3/themes/default/style.min.css" />
<script src="//cdnjs.cloudflare.com/ajax/libs/jstree/3.3.3/jstree.min.js"></script>

<script>
function doATree(q)
{

	console.log('dt; q=' + q);
		  $('#container').jstree({
		    'core' : {
		      'data' : {
		        "url" : "/ajax/ttree.cfm?q=" + q,
		        "dataType" : "json",
		        "data" : function (node) {
		          return {
		          	"id" : node.id
		          };
		        }
		      }
		    }
		  });


		}


	jQuery(document).ready(function() {
		doATree('');

		$( "#srchTerm" ).click(function() {
	console.log('clicky');
	//var newData='[{"id": "animal", "parent": "#", "text": "Animals2"} ]';
 //$('#container').jstree(true).destroy();
	//	$('#container').jstree(true).settings.core.data = newData;
   // $('#container').jstree(true).refresh();
   $('#container').jstree(true).destroy();
   doATree($("#term").val());
  // $('#container').jstree(true).refresh();

/*
		$('#container').jstree(true).settings.core.data = newData;

		console.log('redataed');



		console.log('refreshed');



		$(function() {
		  $('#container').jstree({
		    'core' : {
		      'data' : {
		        "url" : "/ajax/ttree.cfm",
		        "dataType" : "json",
		        "data" : function (node) {
		          return {
		          	test: "ttteeessstttt",
		          	"id" : node.id
		          };
		        }
		      }
		    }
		  });
		});





		*/
});



	});



</script>

<!-----

$( "#srchTerm" ).click(function() {
		 // alert( "Handler for .click() called." );
		 $(function() {
		  $('#container').jstree({
		    'core' : {
		      'data' : {
		        "url" : "/ajax/ttree.cfm?getChild=true",
		        "dataType" : "json",
		        "data" : function (node) {
		          return { "id" : node.id };
		        }
		      }
		    }
		  });
		});




                           "dataType" : "json" // needed only if you do not supply JSON headers
      }
    }
  });
});

----->

<input type="button" value="Expand All" onclick="$('#container').jstree('open_all');">


<label for="term">Search</label>
<input name="term" id="term" placeholder="search">
<input type="button" value='go' id="srchTerm">
doubleclick
<div id="container">
</div>
-------------------->