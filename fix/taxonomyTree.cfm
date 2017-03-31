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
	alter table htax_dataset add constraint ck_htax_dataset_status
   	CHECK (status IN(
		'working',
		'process_to_bulkloader'
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

	ALTER TABLE hierarchical_taxonomy ADD CONSTRAINT fk_parent_tid  FOREIGN KEY (dataset_id)
  REFERENCES htax_dataset(dataset_id);
	-- do not accept terms we can't deal with

	-- in test anyway..
	create unique index IU_CTTAXTERM_TERM on cttaxon_term(taxon_term) tablespace uam_idx_1;
		ALTER TABLE cttaxon_term ADD PRIMARY KEY (taxon_term);

	ALTER TABLE hierarchical_taxonomy ADD CONSTRAINT fk_term_type  FOREIGN KEY (rank) REFERENCES cttaxon_term(taxon_term);

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








CREATE OR REPLACE PROCEDURE proc_hierac_tax IS
	-- note: https://github.com/ArctosDB/arctos/issues/1000#issuecomment-290556611
	--declare
		v_pid number;
		v_tid number;
		v_c number;
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
				insert into htax_temp_hierarcicized (taxon_name_id,dataset_id,status) values (t.taxon_name_id,t.dataset_id,'success');
				exception when others then
					insert into htax_temp_hierarcicized (taxon_name_id,dataset_id,status) values (t.taxon_name_id,t.dataset_id,'fail');
				end;
		end loop;
	end;
	/
sho err;

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
		qerltcInsertSelectRop_bad_state prevents ignoring them) - contact us if you need help.
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
		we probably need a link to view failures here
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
		When you are done seeding, you may manage these data in the classification tree editor. Link to tree here....
	</p>





	</cfoutput>

<p>
	Find records with which to "seed" the dataset. Large datasets (tested to 1.4m records) are manageable,
	but come with performance limitations; smaller datasets are much
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
	<br><input type="button" id="inspect" value="inspect">
	<p>
		After using the "inspect" button, and having found a reasonable number of taxa,
		<input type="submit" onclick="goPullSeed" value="pull seed data">
	</p>
</form>


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
	</cfquery>
	<p>
		The following terms do not exist as taxon names in Arctos. You may need to delete your dataset, add them, and import again.
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


<cfif action is "manageLocalTree">
	<div id="statusDiv" style="position:fixed;top:100;right:0;margin-right:2em;padding:.2em;border:1px solid red;z-index:9999999;">status</div>

	<script type='text/javascript' src='/includes/dhtmlxtree.js'><!-- --></script>
	<script type="text/javascript" src="/includes/dhtmlxTree_v50_std/codebase/dhtmlxtree.js"></script>
	<link rel="STYLESHEET" type="text/css" href="/includes/dhtmlxTree_v50_std/codebase/dhtmlxtree.css">

	<script>


		jQuery(document).ready(function() {

			myTree = new dhtmlXTreeObject('treeBox', '100%', '100%', 0);
			myTree.setImagesPath("/includes/dhtmlxTree_v50_std/codebase/imgs/dhxtree_material/");


			myTree.enableDragAndDrop(true);
			myTree.enableCheckBoxes(true);
			myTree.enableTreeLines(true);
			myTree.enableTreeImages(false);

			initTree();

			myTree.attachEvent("onDblClick", function(id){
				$("#statusDiv").html('working...');


			    $.getJSON("/component/test.cfc",
					{
						method : "getTaxTreeChild",
						id : id,
						returnformat : "json",
						queryformat : 'column'
					},
					function (r) {
						for (i=0;i<r.ROWCOUNT;i++) {
							//insertNewChild(var) does not work for some insane reason, so.....
							var d="myTree.insertNewChild(" + r.DATA.PARENT_TID[i]+','+r.DATA.TID[i]+',"'+r.DATA.TERM[i]+' (' + r.DATA.RANK[i] + ')",0,0,0,0)';
							eval(d);
						}
						$("#statusDiv").html('done');

					}
				);


			});



			myTree.attachEvent("onDrop", function(sId, tId, id, sObject, tObject){
				$("#statusDiv").html('working....');
			    $.getJSON("/component/test.cfc",
					{
						method : "saveParentUpdate",
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
						}

					}
				);
			});



			myTree.attachEvent("onCheck", function(id){
			    alert('this should edit ' + id);
			    // uncheck everything
			    var ids=myTree.getAllSubItems(0).split(",");
	    		for (var i=0; i<ids.length; i++){
	       			myTree.setCheck(ids[i],0);
	    		}
			});







			$( "#srch" ).change(function() {
				// blank canvas
				myTree.deleteChildItems(0);
				 $.getJSON("/component/test.cfc",
					{
						method : "getTaxTreeSrch",
						q: $( "#srch" ).val(),
						returnformat : "json",
						queryformat : 'column'
					},
					function (r) {
						console.log(r);
						//myTree.parse(r, "jsarray");
						myTree.parse(r, "jsarray");
						myTree.openAllItems(0);

					}
				);
			});
		});


		function initTree(){
			myTree.deleteChildItems(0);
			$.getJSON("/component/test.cfc",
				{
					method : "getInitTaxTree",
					returnformat : "json",
					queryformat : 'column'
				},
				function (r) {
					myTree.parse(r, "jsarray");

				}
			);
		}

	//tree.insertNewChild(0,1,"New Node 1",0,0,0,0,"SELECT,CALL,TOP,CHILD,CHECKED");

	</script>

	<label for="srch">search (starts with)</label>
	<input id="srch">
	<br>
	<input type="button" value="reset tree" onclick="initTree()">


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