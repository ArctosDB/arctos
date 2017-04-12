<!----------

-- see DDL/migration for SQL

--------->
<cfinclude template="/includes/_header.cfm">
<cfset title="hierarchical taxonomy editor">
<cfoutput>
<select id="lclNav" onchange="document.location=this.value">
	<option value="">go to....</option>
	<option value="taxonomyTree.cfm">home</option>
	<cfif isdefined("dataset_name") and len(dataset_name) gt 0>
		<option value="taxonomyTree.cfm?action=manageDataset&dataset_name=#dataset_name#">manage #dataset_name#</option>
		<option value="taxonomyTree.cfm?action=manageLocalTree&dataset_name=#dataset_name#">tree for #dataset_name#</option>
	</cfif>
</select>
</cfoutput>

<!------------------------------------------------------------------------------------------------->
<cfif action is "advancedSeed">
	<p>
		Maybe this will be a form someday.... it's just SQL for now
	</p>



<h3>
	find terms which are used by bird collections but do not have a class=Aves term, possibly because they have no classification anything
</h3>

<pre>

	-- First a temp table, because

	drop table temp_missedh;

	create table temp_missedh as select distinct
		taxon_name.scientific_name,
		taxon_name.taxon_name_id
	from
		taxon_name,
		(select * from taxon_term where term_type='class' and term='Aves') taxon_term ,
		identification_taxonomy,
		identification,
		cataloged_item,
		collection
	where
		taxon_name.taxon_name_id=identification_taxonomy.taxon_name_id and
		identification_taxonomy.identification_id=identification.identification_id and
		identification.collection_object_id=cataloged_item.collection_object_id and
		cataloged_item.collection_id=collection.collection_id and
		collection.collection_cde='Bird' and
		taxon_name.taxon_name_id =taxon_term.taxon_name_id (+) and
		taxon_term.taxon_name_id is null;

	insert into htax_seed (
		SCIENTIFIC_NAME,
		TAXON_NAME_ID,
		DATASET_ID
	) (
		select
			scientific_name,
			TAXON_NAME_ID,
			114013137
		from
			temp_missedh
		where
			rank in (select taxon_term from cttaxon_term where IS_CLASSIFICATION=1)
	);

</pre>
<hr>Old-n-busted</h3>

<pre>
	-- this isn't really necessary; the import procedure now tries to guess at rank. Just leaving it here
	in case it becomes useful somehow.

	<p>
	everything that follows is for historical purposes only
	</p>
	alter table temp_missedh add rank varchar2(255);

	declare
		hs number;
		rk varchar2(255);
	begin
		for r in (select * from temp_missedh) loop
			rk:=null;
			dbms_output.put_line(r.scientific_name);
			select count(*) into hs from taxon_term where source='Arctos' and taxon_name_id=r.taxon_name_id;
			dbms_output.put_line('class terms: ' || hs);
			if hs > 0 then
			dbms_output.put_line('gotsomething');
				-- has classification, might have rank
				select count(*) into hs from taxon_term where source='Arctos' and
					term_type != 'scientific_name' and
					term=r.scientific_name and
					taxon_name_id=r.taxon_name_id;
				if hs>0 then
					-- yay, got rank
					select term_type into rk from taxon_term where source='Arctos' and
					term_type != 'scientific_name' and
					term=r.scientific_name and
					taxon_name_id=r.taxon_name_id;
					dbms_output.put_line('using rank ' || rk);
				end if;
			end if;
			if rk is null then
				dbms_output.put_line('didnt find rank try to guess by structure');
				if r.scientific_name like '% % %' then
					rk:='subspecies';
					dbms_output.put_line('subspecies');
				elsif r.scientific_name like '% %' then
					rk:='species';
					dbms_output.put_line('species');
				elsif r.scientific_name like '% % % %' then
					rk:='too_many_spaces';
					dbms_output.put_line('too_many_spaces');
				else
					rk:='genus or something maybe IDK';
					dbms_output.put_line('genus or something maybe IDK');
				end if;
			end if;
			update temp_missedh set rank=rk where taxon_name_id=r.taxon_name_id;
		end loop;
	end;
	/


	select scientific_name,rank from temp_missedh where rank not in (select taxon_term from cttaxon_term where IS_CLASSIFICATION=1);

	--- deal with those manually



	<br>Insert them into the hierarchy directly under kingdom
	<br>No other insert point is safe
	<br>
	select dataset_id from htax_dataset where dataset_name='bird';
	<br> >	114013137

	<br>
	select tid from hierarchical_taxonomy where term='Animalia' and dataset_id=114013137;
	<br> > 114013138

	insert into hierarchical_taxonomy (
		TID,
		PARENT_TID,
		TERM,
		RANK,
		DATASET_ID
	) (
		select
			someRandomSequence.nextval,
			114013138,
			scientific_name,
			rank,
			114013137
		from
			temp_missedh
		where
			rank in (select taxon_term from cttaxon_term where IS_CLASSIFICATION=1)
	);

	-- well that sucks - try different path...
	delete from hierarchical_taxonomy where DATASET_ID=114013137 and TERM in (select scientific_name from temp_missedh);


UAM@ARCTOS> desc hierarchical_taxonomy
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 TID								   NOT NULL NUMBER
 PARENT_TID								    NUMBER
 TERM									    VARCHAR2(255)
 RANK									    VARCHAR2(255)
 DATASET_ID							   NOT NULL NUMBER


	select distinct
		taxon_name.scientific_name
	from
		taxon_name,
		taxon_term,
		identification_taxonomy,
		identification,
		cataloged_item,
		collection
	where
		taxon_name.taxon_name_id=identification_taxonomy.taxon_name_id and
		identification_taxonomy.identification_id=identification.identification_id and
		identification.collection_object_id=cataloged_item.collection_object_id and
		cataloged_item.collection_id=collection.collection_id and
		collection.collection_cde='Bird' and
		taxon_name.taxon_name_id =taxon_term.taxon_name_id (+) and
		taxon_term.taxon_name_id is null;


		select distinct
		taxon_name.scientific_name
	from
		taxon_name,
		(select * from taxon_term where term_type='class' and term='Aves')taxon_term ,
		identification_taxonomy,
		identification,
		cataloged_item,
		collection
	where
		taxon_name.taxon_name_id=identification_taxonomy.taxon_name_id and
		identification_taxonomy.identification_id=identification.identification_id and
		identification.collection_object_id=cataloged_item.collection_object_id and
		cataloged_item.collection_id=collection.collection_id and
		collection.collection_cde='Bird' and
		taxon_name.taxon_name_id =taxon_term.taxon_name_id (+) and
		taxon_term.taxon_name_id is null;




	select
		taxon_name.scientific_name
	from
		taxon_name,
		taxon_term,
		identification_taxonomy,
		identification,
		cataloged_item,
		collection
	where
		taxon_name.taxon_name_id=identification_taxonomy.taxon_name_id and
		identification_taxonomy.identification_id=identification.identification_id and
		identification.collection_object_id=cataloged_item.collection_object_id and
		cataloged_item.collection_id=collection.collection_id and
		collection.collection_cde='Bird' and
		taxon_name.taxon_name_id not in (
			select taxon_name_id from taxon_term,CTTAXONOMY_SOURCE
				where taxon_term.source=CTTAXONOMY_SOURCE.source and
				taxon_term.term_type='class' and
				taxon_term.term='Aves'
		)


	select distinct
		taxon_name.scientific_name
	from
		taxon_name,
		taxon_term,
		identification_taxonomy,
		identification,
		cataloged_item,
		collection
	where
		taxon_name.taxon_name_id=identification_taxonomy.taxon_name_id and
		identification_taxonomy.identification_id=identification.identification_id and
		identification.collection_object_id=cataloged_item.collection_object_id and
		cataloged_item.collection_id=collection.collection_id and
		collection.collection_cde='Bird' and
		taxon_name.taxon_name_id =taxon_term.taxon_name_id (+) and
		taxon_term.taxon_name_id is null;


			select taxon_name_id from taxon_term,CTTAXONOMY_SOURCE
				where taxon_term.source=CTTAXONOMY_SOURCE.source and
				taxon_term.term_type='class' and
				taxon_term.term='Aves'
		)

		</pre>
</cfif>
<!------------------------------------------------------------------------------------------------->
<cfif action is "nothing">
	<p>
		ABOUT:
	</p>
	<ul>
		<li>
			This is a classification editor; it will NOT create, delete, or alter taxon_name.
		</li>
		<li>
			This form creates hierarchical data from Arctos classification data.
			Not all data in Arctos can be transformed into a hierarchy, and some will be transformed
			unpredictably. For example, given
				<ul><li><strong>genus</strong>--><strong>family</strong>--><strong>order</strong></li></ul>
				 and
				 <ul><li><strong>othergenus</strong>--><strong>family</strong>--><strong>otherorder</strong></li></ul>
				 that is, inconsistent hierarchies - here one family split between two orders - then all <strong>family</strong> will end up
				 as a child of either <strong>order</strong> or <strong>otherorder</strong>, whichever is encountered first.
		</li>
		<li>
			The hierarchical data structure exists independently of "real Arctos." It is created using the data you specify
			in the seed process as they exist at the time. Changes here to nothing to "real Arctos" classification data until
			you repatriate them, and subsequent changes to "real Arctos" classification data will not be reflected here.
			You may need to employ an iterative approach: seed, fix stuff in Arctos, delete your dataset, re-seed, repeat.
		</li>
		<li>
			When you repatriate these data, local data in real Arctos will be REPLACED with the data from the hierarchical classification.
		</li>
	</ul>
	<cfquery name="mg" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select distinct (dataset_name) from htax_dataset
	</cfquery>
	<cfoutput>
		<a href="taxonomyTree.cfm?action=createDataset">Create a new dataset</a>
		or select an existing dataset to edit:
		<ul>
		<cfloop query="mg">
			<li>
				<a href="taxonomyTree.cfm?action=manageDataset&dataset_name=#dataset_name#">#dataset_name#</a>
			</li>
		</cfloop>
		</ul>
	</cfoutput>
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
			<ul>
				<li>needs tested with real/not-test data</li>
				<li>definitely needs to write directly to classification bulkloader once proven to play nicely</li>
				<li>
					MAY want a "just load stuff" (eg -->cf_classloader status=autoinsert) option; biggest hurdle is display name, which people are NOT
					going to see (it's in the single-term editor) and which can be autogenerated by the
					classification loaded. https://github.com/ArctosDB/arctos/issues/1086 may provide a solution:
					IF we can reliably generate display name (eg, after loading), maybe full automation
					starts to make more sense.
				</li>
			</ul>
		</li>
	</ul>
</cfif>
<!------------------------------------------------------------------------------------------------->
<cfif action is "createDataset">
	<cfoutput>
	Create a dataset. A dataset is a list of terms from an Arctos classification which will be made hierarchical, and accompanying metadata.
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
<!------------------------------------------------------------------------------------------------->
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
	<script>
		$(function() { //shorthand document.ready function
		    $('#inspect').on('click', function(e) { //use on if jQuery 1.7+
		       // var data = $("#f_ds_filter :input").serializeArray();
		        //console.log(data); //use the console for debugging, F12 in Chrome, not alerts
		        $('#inspect').val('working - be patient!');
		         $.getJSON("/component/taxonomy.cfc",
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
						//console.log(r);
						 $('#inspect').val('done - click to re-inspect');
						alert('your search found ' + r.DATA.C[0] + ' taxa');
						//myTree.parse(r, "jsarray");
						//myTree.parse(r, "jsarray");
						//myTree.openAllItems(0);

					}
				);

		    });
		});
	</script>

	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from htax_dataset where dataset_name='#dataset_name#'
	</cfquery>
	<cfoutput>
		Managing <strong>#d.dataset_name#</strong> created #d.created_by# on #d.created_date#

		<p>
			Source: <strong>#d.source#</strong>
		</p>
		<p>
			<form id="f_ds_filter" method="post" action="taxonomyTree.cfm">
				<input type="hidden" name="dataset_id" value="#d.dataset_id#">
				<input type="hidden" name="dataset_name" value="#d.dataset_name#">
				<input type="hidden" name="action" value="saveCommentUpdate">
				<label for="comments">Comments</label>
				<textarea name="comments" rows="10" cols="50">#d.comments#</textarea>
				<br><input type="submit" value="save comment changes" class="savBtn">
			</form>
		</p>

		<hr>
		Step One: Find records with which to "seed" the dataset. Large datasets (tested to ~1m records) are manageable,
		but come with performance limitations; the automated steps
		(data to hierarchies, data to bulkloader, etc.) will take much longer (perhaps days) to complete, your browser may
		have difficulty processing larger trees, and queries (eg, expanding nodes) are slow. Small datasets are much
		easier to work with; consider limiting your query to around 50,000 names if at all possible. Contact us to discuss
		strategies.
		<p>
			Note that data in Arctos are independent; classifications are not related in any way.
			This app will only update the records for which the taxon name
			appears as a term here.
		</p>
		<p>
			You may return to this step and add names to your dataset at any time. Don't confuse yourself.
		</p>
		<p>
			Find seed taxonomy. Terms are exact-match case-sensitive.
		</p>
		<form id="f_ds_filter" method="post" action="taxonomyTree.cfm">
				<input type="hidden" name="dataset_id" id="dataset_id" value="#d.dataset_id#">
				<input type="hidden" name="dataset_name" id="dataset_name" value="#d.dataset_name#">
				<input type="hidden" name="action" id="action" value="go_seed_ds">
				<input type="hidden" name="source" id="source" value="#d.source#">



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
				Click this ONCE! to get a recordcount. Nothing obvious will happen, and it may take some time.
				You'll get an alert when it's done.
			</p>
			<br><input type="button" id="inspect" value="get match count">
			<p>
				After using the "get match count" button, and having found a reasonable number of taxa,
				click to
				<input type="submit" value="pull seed data">. The form will reload, and again may be slow.
			</p>
		</form>
		<p>
			Anything you can search here is almost certainly incomplete. There are no taxonomy "minimum data" standards in Arctos Proper.
			Contact a DBA and we can help you find these data. There's some SQL on the
			Use the	<a href="taxonomyTree.cfm?action=advancedSeed&dataset_name=#dataset_name#">advanced seed form</a>.

		</p>
		<hr>
		<p>
			Step Two: Do nothing. Grab a donut maybe. The records you seeded will auto-process into a hierarchy at the rate of
			a few thousand per minute. Then click reload and scroll down for summary statistics.
		</p>
		<hr>
		<cfquery name="nht" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select count(*) c from htax_seed where dataset_id=#d.dataset_id#
		</cfquery>
		<cfquery name="nht_il" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select status,count(*) c from htax_temp_hierarcicized where dataset_id=#d.dataset_id# group by status order by status
		</cfquery>
		<cfquery name="ht" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select count(*) c from hierarchical_taxonomy where dataset_id=#d.dataset_id#
		</cfquery>
		<p>Statistics</p>
		<table border>
			<tr>
				<th>Operation</th>
				<th>Status</th>
			</tr>
			<tr>
				<td>Seed</td>
				<td>
					#nht.c# records have been seeded. You may add more (use the form above). Duplicates are disallowed (and Oracle bug
					qerltcInsertSelectRop_bad_state prevents silently ignoring them) - contact us if you need help.
				</td>
			</tr>
			<tr>
				<td>
					Import
				</td>
				<td>
					<cfloop query="nht_il">
						<div>
							<cfif status is "inserted_noclassterm">
								SUCCESS : #c#
							<cfelse>
								#status# : #c#
							</cfif>
						</div>
					</cfloop>
					<p>

						<br>
					</p>
				</td>
			</tr>
			<tr>
				<td>
					Funky Data
				</td>
				<td>
					<div>
						Various ways of finding unpredictable data. Expect overlap between these reports;
						fix incrementally.
					</div>
					<div>
						<a href="taxonomyTree.cfm?action=mismatch_import&dataset_name=#dataset_name#">Click here</a>
						to view records which are in your import but not in Arctos. These are classification
						terms which do not exist as names and should be corrected or created.
					</div>
					<div>
						<a href="taxonomyTree.cfm?action=noSuccessimport&dataset_name=#dataset_name#">import error details</a>
					</div>
					<div>
						<a href="taxonomyTree.cfm?action=seedMIA&dataset_name=#dataset_name#">Seeded taxa not in your dataset</a>
					</div>
				</td>
			</tr>
			<tr>
				<td>hierarchical terms</td>
				<td>
					#ht.c# records are available to manage hierarchically. This should match seed count (#nht.c#);
					if it doesn't, there are errors or the import scripts are still running.
					 Reload or return to this page to see progress. If nothing changes for ~5 minutes it's probably done all that can be done,
					 or something is stuck. Contact us if you need help.
				</td>
			</tr>
		</table>

		<hr>

		<p>
			When you are done seeding and the import scripts are done (numbers above have stopped changing), you may
			<a href="taxonomyTree.cfm?action=manageLocalTree&dataset_name=#dataset_name#">manage these data in the classification tree editor</a>
		</p>
		<hr>
		<p>
			If you've made some sort of horrible mistake, you may
			<a href="taxonomyTree.cfm?action=deleteDataset&dataset_name=#dataset_name#">delete this dataset</a>. This cannot be undone.
		</p>
		<hr>
		<p>
			After the data have been edited into a satisfactory hierarchy, you may mark them for export to the classification bulkloader.
			<p>
				this needs more work before going live
				<br>do this:
				<br>update hierarchical_taxonomy set status='ready_to_push_bl' where dataset_id in (
					select dataset_id from 	 htax_dataset where dataset_name='#dataset_name#'
				)
				<br>and make sure the task is in the scheduler
			</p>
		</p>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------->
<cfif action is "seedMIA">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				SCIENTIFIC_NAME
			from
				htax_seed
			where
				dataset_id=(select dataset_id from htax_dataset where dataset_name='#dataset_name#') and
				SCIENTIFIC_NAME not in (
					select term from hierarchical_taxonomy where dataset_id=(
						select dataset_id from htax_dataset where dataset_name='#dataset_name#'
					)
				)
		</cfquery>
		<cfloop query="d">
			<div>
				<a href="/name/#SCIENTIFIC_NAME#">#SCIENTIFIC_NAME#</a>
			</div>
		</cfloop>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------->
<cfif action is "saveCommentUpdate">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update htax_dataset set comments='#comments#' where dataset_id='#dataset_id#'
		</cfquery>
		<cflocation url="taxonomyTree.cfm?action=manageDataset&dataset_name=#dataset_name#" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------->
<cfif action is "findInconsistentData">
	<cfquery name="dsid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select dataset_id,source from htax_dataset where dataset_name='#dataset_name#'
	</cfquery>

	<cfquery name="flush" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from htax_inconsistent_terms where dataset_id=#dsid.dataset_id#
	</cfquery>

	<cfquery name="repop" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into htax_inconsistent_terms (
			dataset_id,
			term,
			rank,
			fkey
		) (
			select
				#dsid.dataset_id#,
				term,
				term_type,
				term || '|' || term_type
			from
				taxon_term,
				htax_temp_hierarcicized
			where
				htax_temp_hierarcicized.dataset_id=#dsid.dataset_id# and
				htax_temp_hierarcicized.status='fail: ORA-00001: unique constraint (UAM.IU_TERM_DS) violated' and
				htax_temp_hierarcicized.taxon_name_id=taxon_term.TAXON_NAME_ID and
				taxon_term.position_in_classification is not null and
				taxon_term.source='#dsid.source#' and
				taxon_term.term_type != 'scientific_name'
		)
	</cfquery>
	<cfquery name="dups" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select distinct term,rank from htax_inconsistent_terms where dataset_id=#dsid.dataset_id# and term in
		 (select term from  (select distinct term, rank from htax_inconsistent_terms) group by term having count(*) > 1) order by term,rank
	</cfquery>
	<cfoutput>
		<table border>
			<tr>
				<td>Term</td>
				<td>Rank</td>
				<td>Arctos</td>
			</tr>
			<cfloop query="dups">
				<tr>
					<td>#term#</td>
					<td>#rank#</td>
					<td>
						<div>
							<a href="/taxonomy.cfm?taxon_term=#term#&term_type=%3D#rank#&source=#dsid.source#">search term+rank+source</a>
						</div>
						<div>
							<a href="/taxonomy.cfm?taxon_term=#term#&source=#dsid.source#">search term+source</a>
						</div>
					</td>

				</tr>
			</cfloop>
		</table>
	</cfoutput>



	<!----
	<cfquery name="repop" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			htax_temp_hierarcicized.TAXON_NAME_ID,
			taxon_name.scientific_name,
			taxon_term.term,
			taxon_term.term_type
		from
			htax_temp_hierarcicized,
			htax_dataset,
			taxon_name,
			taxon_term
		where
			htax_temp_hierarcicized.dataset_id=htax_dataset.dataset_id and
			htax_dataset.dataset_name='#dataset_name#' and
			htax_temp_hierarcicized.status='fail: ORA-00001: unique constraint (UAM.IU_TERM_DS) violated' and
			htax_temp_hierarcicized.TAXON_NAME_ID=taxon_name.TAXON_NAME_ID and
			taxon_name.TAXON_NAME_ID=taxon_term.TAXON_NAME_ID and
			taxon_term.position_in_classification is not null and
			taxon_term.source=htax_dataset.source
	</cfquery>
	<cfdump var=#d#>
	---->
</cfif>


<!------------------------------------------------------------------------------------------------->
<cfif action is "findTermSource">
	<!--- pass in a term, figure out where it came from ---->

	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			taxon_term.term_type,
			count(*) timesUsed
		from
			taxon_name,
			taxon_term,
			CTTAXONOMY_SOURCE
		where
			taxon_name.taxon_name_id=taxon_term.taxon_name_id and
			taxon_term.source=CTTAXONOMY_SOURCE.source and
			taxon_term.position_in_classification is not null and
			taxon_term.term='#term#'
		group by taxon_term.term_type
		order by count(*)
	</cfquery>
	<cfoutput>
		<p>
			Usage of #term# (in local classifications):
		</p>
		<table border>
			<tr>
				<td>Rank</td>
				<td>TimesUsed</td>
				<td>Arctos</td>
			</tr>
			<cfloop query="d">
				<tr>
					<td>#term_type#</td>
					<td>#timesUsed#</td>
					<td>
						<div>
							<cfif len(term_type) is 0>
								<cfset stt='=NULL'>
							<cfelse>
								<cfset stt='==#term_type#'>
							</cfif>
							<a href="/taxonomy.cfm?source=LOCAL&taxon_term==#term#&term_type#stt#">search term@rank</a>
						</div>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>



	<!----
	<cfquery name="repop" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			htax_temp_hierarcicized.TAXON_NAME_ID,
			taxon_name.scientific_name,
			taxon_term.term,
			taxon_term.term_type
		from
			htax_temp_hierarcicized,
			htax_dataset,
			taxon_name,
			taxon_term
		where
			htax_temp_hierarcicized.dataset_id=htax_dataset.dataset_id and
			htax_dataset.dataset_name='#dataset_name#' and
			htax_temp_hierarcicized.status='fail: ORA-00001: unique constraint (UAM.IU_TERM_DS) violated' and
			htax_temp_hierarcicized.TAXON_NAME_ID=taxon_name.TAXON_NAME_ID and
			taxon_name.TAXON_NAME_ID=taxon_term.TAXON_NAME_ID and
			taxon_term.position_in_classification is not null and
			taxon_term.source=htax_dataset.source
	</cfquery>
	<cfdump var=#d#>
	---->
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
				htax_temp_hierarcicized.status != 'inserted_noclassterm'
			group by
				htax_temp_hierarcicized.status,
				taxon_name.scientific_name
			order by
				htax_temp_hierarcicized.status,
				taxon_name.scientific_name

		</cfquery>
		<p>
			These are terms you seeded or terms from the classifications of terms you seeded which were not successfully imported.
			If you continue without these, you will ultimately exclude them from the final update and create inconsistent data in Arctos.

		</p>
		<p>
			<ul>
				<!----

				the key on (term,rank) acused huge amounts of errors; drop it, just import the term the first time it's encountered
				as whatever rank it's encountered as


				<li>
					fail: ORA-00001:
					 unique constraint (UAM.IU_TERM_DS) violated errors are an indication of inconsistent data
					(eg, TERM is ranked family in some records and subfamily in others, which cannnot happen in hierarchical data).
					Hierarchical data is structurally-consistent so these inconsistencies will be resolved when the data are pushed back to Arctos.
					<br>EDIT:
					<br>
					<a href="taxonomyTree.cfm?action=findInconsistentData&dataset_name=#dataset_name#">
						click here to locate the inconsistent data
					</a>
				</li>
				------->
				<li>
					missed_taxonname errors are those in which all classification terms excepting scientific_name (which should always be
					redundant with other terms) was inserted, but the taxon name does not exist as a term (and so were not found
					by the nonclassification-term-inserter). These are due to missing
					or garbage classifications and are indications that the hierarchy you are trying to manage is incomplete or inconsistent.
					These errors are probably not limited to, but have been detected with:
					<ul>
						<li>Trinomial names (Anas platyrhynchos domestic) with malformed species (platyrhynchos domestic)</li>
						<li>Plant-like names in taxon terms: "Lagopus leucurus subsp. saxatilis"</li>
						<li>
							No match between the taxon name and classification data (eg, someone who should REALLY not have admin powers
							has admin powers): The species for "Acrulia tumidula" given as "Acruliopsis tumidula."
						</li>
						<li>
							The presence of subgenus data - see Issue ##1000.
						</li>
						<li>
							Missing terms - genus=Disogmus, [no species data exists], scientific_name=Disogmus areolator
						</li>
					</ul>

				</li>
			</ul>
		</p>
		<table border>
			<tr>
				<th>Status</th>
				<th>Term</th>
				<th>Arctos Taxonomy</th>
				<th>Tree</th>
			</tr>
			<cfloop query="d">
				<tr>
					<td>#status#</td>
					<td>#scientific_name#</td>
					<td><a href="/name/#scientific_name#" target="_blank">Arctos Taxonomy (new tab)</a></td>
					<td><a href="/tools/taxonomyTree.cfm?action=manageLocalTree&dataset_name=#dataset_name#&autosearch=#scientific_name#" target="_blank">tree (new tab)</a></td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------->

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
<!--------------------------------------------------------------------------------------->
<cfif action is "mismatch_import">
	<cfquery name="mia" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select distinct
	      term
	    from
	      hierarchical_taxonomy,
	      htax_seed,
	      htax_dataset,
	      taxon_name
	    where
	      hierarchical_taxonomy.dataset_id=htax_seed.dataset_id and
	      htax_seed.dataset_id=htax_dataset.dataset_id and
	      htax_dataset.dataset_name='#dataset_name#' and
	      hierarchical_taxonomy.term=taxon_name.scientific_name (+) and
	      taxon_name.taxon_name_id is null
	    order by
	      term
	</cfquery>
	<p>
		This app will not create taxon names.
		The following terms do not exist as taxon names in Arctos but are terms in your import. This happens for two reasons:
		<ol>
			<li>
				A term does not exist as a name. The Family of a record does not exist by itself, there is no genus above a species,
				binomial for trinomial, etc. These should be created.
				<a href="taxonomyTree.cfm?action=mismatch_importCSV&dataset_name=#dataset_name#">Click here for CSV</a>,
				VERY carefully review, and send to a DBA for taxon creation BEFORE attempting to repatriate these data.
			</li>
			<li>
				A cat wandered across someone's keyboard while they were creating classifications; the name is garbage and should
				not exist anywhere for any reason. Be very sure that these are NOT included in the CSV of names to create, and
				are NOT repatriated with your data (eg, you need to delete them from your dataset).
			</li>
		</ol>
	<cfoutput>
		<cfloop query="mia">
			<br>#term#
		</cfloop>
	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------->
<cfif action is "mismatch_importCSV">
	<cfquery name="mia" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select distinct
	      term
	    from
	      hierarchical_taxonomy,
	      htax_seed,
	      htax_dataset,
	      taxon_name
	    where
	      hierarchical_taxonomy.dataset_id=htax_seed.dataset_id and
	      htax_seed.dataset_id=htax_dataset.dataset_id and
	      htax_dataset.dataset_name='#dataset_name#' and
	      hierarchical_taxonomy.term=taxon_name.scientific_name (+) and
	      taxon_name.taxon_name_id is null
	    order by
	      term
	</cfquery>

	<cfset  util = CreateObject("component","component.utilities")>
	<cfset csv = util.QueryToCSV2(Query=mia,Fields=mia.columnlist)>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/funkyClassTerms.csv"
    	output = "#csv#"
    	addNewLine = "no">
	<cflocation url="/download.cfm?file=funkyClassTerms.csv" addtoken="false">
	<a href="taxonomyTree.cfm?action=mismatch_import&dataset_name=#dataset_name#">return</a>
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
	<div id="statusDiv" class="default">loading...</div>

	<script type='text/javascript' src='/includes/dhtmlxtree.js'><!-- --></script>
	<script type="text/javascript" src="/includes/dhtmlxTree_v50_std/codebase/dhtmlxtree.js"></script>
	<link rel="STYLESHEET" type="text/css" href="/includes/dhtmlxTree_v50_std/codebase/dhtmlxtree.css">
	<style>
		.default {
			background:white;
			position:fixed;
			top:100;
			right:0;
			margin-right:2em;
			padding:.2em;
			z-index:9999999;
			max-width:20em;
		}
		.working {
			border:2px solid yellow;
		}
		.working:after {
		    content: url('/images/indicator.gif');
		}
		.done {
			border:2px solid green;
		}
		.err {
			border:5px solid red;
		}

		.caution {
			border:2px solid yellow;
		}
	</style>
	<script>
		function setStatus(msg,st){
			$("#statusDiv").html(msg).removeClass().addClass('default').addClass(st).html(msg);
			if (st=='err'){
				alert(msg);
			}
		}

		function deletedRecord(theID){
			// deleted something
			// remove it from the view
			myTree.deleteItem(theID,false);
			setStatus('delete successful','done');
			$(".ui-dialog-titlebar-close").trigger('click');
		}

		function movedToNewParent(c,p){
			// remove the child
			myTree.deleteItem(c,false);
			// expand the new parent
			expandNode(p);
			setStatus('move success','done');
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
			setStatus('created new term','done');
			myTree.selectItem(id);
			myTree.focusItem(id);
		}
		function expandNode(id){
			//alert('am expandNode');
			setStatus('working','working');
		    $.getJSON("/component/taxonomy.cfc",
				{
					method : "getTaxTreeChild",
					dataset_id: $("#dataset_id").val(),
					id : id,
					returnformat : "json",
					queryformat : 'column'
				},
				function (r) {
					if (r.toString().substring(0,5)=='ERROR'){
						setStatus(r,'error','err');
					} else {
						for (i=0;i<r.ROWCOUNT;i++) {
							//insertNewChild(var) does not work for some insane reason, so.....
							// delete (if exists)
							myTree.deleteItem(r.DATA.TID[i],false);

							var d="myTree.insertNewChild(" + r.DATA.PARENT_TID[i]+','+r.DATA.TID[i]+',"'+r.DATA.TERM[i]+' (' + r.DATA.RANK[i] + ')",0,0,0,0)';
							eval(d);
						}
						setStatus('expansion done','done');
					}
				}
			);
		}

		function savedMetaEdit(tid,newVal){
			myTree.setItemText(tid,newVal);
			setStatus('term edits saved','done');
			$(".ui-dialog-titlebar-close").trigger('click');
		}

		function performSearch(){

			if ($( "#srch" ).val().length < 3){
				setStatus('Enter at least three letters to search.','caution');
				return;
			}
			setStatus('working','working');
			myTree.deleteChildItems(0);

			$.getJSON("/component/taxonomy.cfc",
				{
					method : "getTaxTreeSrch",
					dataset_id: $("#dataset_id").val(),
					q: $( "#srch" ).val(),
					returnformat : "json",
					queryformat : 'column'
				},
				function (r) {
					if (r.toString().substring(0,5)=='ERROR'){
						setStatus(r,'err');
					} else if (r.length==0){
						setStatus('Search found nothing','err');
					} else {
						//console.log(r);
						//myTree.parse(r, "jsarray");
						myTree.parse(r, "jsarray");
						myTree.openAllItems(0);
						setStatus('done','done');
					}
				}
			);
		}


		function initTree(){
			setStatus('initializing','working');
			myTree.deleteChildItems(0);
			$.getJSON("/component/taxonomy.cfc",
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
			setStatus('ready','done');
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
				setStatus('working','working');
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
			});

			myTree.attachEvent("onDblClick", function(id){
				expandNode(id);
			});

			myTree.attachEvent("onRightClick", function(id){
				myTree.closeItem(id);
			});

			myTree.attachEvent("onDrop", function(sId, tId, id, sObject, tObject){
				setStatus('working','working');
			    $.getJSON("/component/taxonomy.cfc",
					{
						method : "saveParentUpdate",
						dataset_id: $("#dataset_id").val(),
						tid : sId,
						parent_tid : tId,
						returnformat : "json",
						queryformat : 'column'
					},
					function (r) {
						//console.log(r);
						if (r=='success') {
							setStatus('successful save','done');
						}else{
							setStatus(r,'err');
						}
					}
				);
			});

			/*
			sort of annoying....
			$( "#srch" ).change(function() {
				performSearch();
			});
			*/
			$("#srch").keyup(function(e){
			    if(e.keyCode == 13) {
		      		performSearch();
		    	}
			});
			$( "#srchBtn" ).click(function() {
				performSearch();
			});
			if ($("#autosearch").val().length>0){
				console.log('go go autosearch');
				// grab the term, stuff it in the search box so as to not confuse people
				$("#srch").val($("#autosearch").val());
				// do nothing for a while, let stuff happen
				// doopty-doo
				// wheeee
				// done yet?
				// hope so

				// and kick off search

				setTimeout(performSearch,1000);

			}
		});
		// end ready function

	</script>
	<p>
		<strong>Doubleclick</strong> terms to expand.
		<br><strong>Check</strong> the box to edit.
		<br><strong>Drag</strong> to re-order.
		<br><strong>Rightclick</strong> to close a node.
		<br>All edits propagate to all children.
	</p>
	<p style="width:70%">
		IMPORTANT: This form cannot deal with homonyms of any form. You will most likely find these by the presence of weird higher taxonomy.
		If you simply "fix" these, they (and their children!) are exceedingly likely to be subsequently "fixed" by collections using the
		homonym in different ways. Coordinate updates, which may require splitting classifications.
	</p>
	<p style="width:70%">
		Search is case-sensitive contains;
		<br>"<strong>Mus</strong>" finds "<strong>Mus</strong>" and "<strong>Mus</strong>tela";
		<br>"<strong>mus</strong>" finds "Microtus oecono<strong>mus</strong>, NOT "Mustela" (but will find "Mustela <strong>mus</strong>tela").
		 <br>Large searches may be slow, and possibly cause local memory problem (but "mus" in Insecta
		 returned 20K usable results in 30s on test).
		 <br>Re-searching while a previous search is still "working" can cause strange behavior.
	</p>
	<cfif not isdefined("autosearch")>
		<cfset autosearch="">
	</cfif>
	<input type="hidden" name="autosearch" id="autosearch" value="<cfoutput>#autosearch#</cfoutput>">

	<label for="srch">search <cfoutput>#dataset_name#</cfoutput></label>
	<input id="srch">
	<input type="button" value="search" id="srchBtn">

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

						insert into hierarchical_taxonomy (tid,parent_tid,term,rank) values (
							someRandomSequence.nextval,pid,r.term,'superkingdom');

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