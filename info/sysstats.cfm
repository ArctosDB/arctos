<!----
	this form is crazy-slow
	cache stuff

drop table cache_sysstats_global;
drop table cache_sysstats_coln;

	create table cache_sysstats_global (
		lastdate date,
		number_collections number,
		number_institutions number,
		number_specimens number,
		number_taxa number,
		number_taxon_relations number,
		number_localities number,
		number_georef_localities number,
		number_collecting_events number,
		number_media number,
		number_agents number,
		number_publications number,
		number_publication_doi number,
		number_projects number,
		--number_tables number,
		--number_codetables number,
		number_genbank number,
		number_spec_relns number,
		number_annotations number,
		number_rvwd_annotations number
	);
	create table cache_sysstats_coln (
		lastdate date,
		guid_prefix varchar2(255),
		number_specimens number,
		number_individuals number,
		number_taxa number,
		number_localities number,
		number_georef_localities number,
		number_collecting_events number,
		number_specimen_media number,
		number_cit_pubs number,
		number_citations number,
		number_loaned_items number,
		number_genbank number,
		number_spec_relns number,
		number_annotations number,
		number_rvwd_annotations number
	);

	CREATE OR REPLACE PROCEDURE proc_cache_stats
	AS
		-- global
		v_number_collections number;
		v_number_institutions number;
		v_number_specimens number;
		v_number_taxa number;
		v_number_taxon_relations number;
		v_number_localities number;
		v_number_georef_localities number;
		v_number_collecting_events number;
		v_number_media number;
		v_number_agents number;
		v_number_publications number;
		v_number_publication_doi number;
		v_number_projects number;
		v_number_tables number;
		v_number_codetables number;
		v_number_genbank number;
		v_number_spec_relns number;
		v_number_annotations number;
		v_number_rvwd_annotations number;
		-- coln
		vc_number_specimens number;
		vc_number_individuals number;
		vc_number_taxa number;
		vc_number_localities number;
		vc_number_georef_localities number;
		vc_number_collecting_events number;
		vc_number_specimen_media number;
		vc_number_cit_pubs number;
		vc_number_citations number;
		vc_number_loaned_items number;
		vc_number_genbank number;
		vc_number_spec_relns number;
		vc_number_annotations number;
		vc_number_rvwd_annotations number;
	BEGIN
		select count(*) into v_number_collections from collection;
		select count(distinct(institution_acronym)) into v_number_institutions from collection;
		select count(*) into v_number_specimens from cataloged_item;
		select count(*) into v_number_taxa from taxon_name;
		select count(*) into v_number_taxon_relations from taxon_relations;
		select count(*) into v_number_localities from locality;
		select count(*) into v_number_georef_localities from locality where dec_lat is not null;
		select count(*) into v_number_collecting_events from collecting_event;
		select count(*) into v_number_media from media;
		select count(*) into v_number_agents from agent;
		select count(*) into v_number_publications from publication;
		select count(*) into v_number_publication_doi from publication where doi is not null;
		select count(*) into v_number_projects from project;
		select count(*) into v_number_genbank from coll_obj_other_id_num where OTHER_ID_TYPE = 'GenBank';
		select count(*) into v_number_spec_relns from coll_obj_other_id_num where ID_REFERENCES != 'self';

		select count(*) into v_number_annotations from annotations;
		select count(*) into v_number_rvwd_annotations from annotations where REVIEWER_AGENT_ID is not null;

		-- flush all
		delete from cache_sysstats_global;

		-- insert
		insert into cache_sysstats_global (
			lastdate,
			number_collections,
			number_institutions,
			number_specimens,
			number_taxa,
			number_taxon_relations,
			number_localities,
			number_georef_localities,
			number_collecting_events,
			number_media,
			number_agents,
			number_publications,
			number_publication_doi,
			number_projects,
			number_genbank,
			number_spec_relns,
			number_annotations,
			number_rvwd_annotations
		) values (
			sysdate,
			v_number_collections,
			v_number_institutions,
			v_number_specimens,
			v_number_taxa,
			v_number_taxon_relations,
			v_number_localities,
			v_number_georef_localities,
			v_number_collecting_events,
			v_number_media,
			v_number_agents,
			v_number_publications,
			v_number_publication_doi,
			v_number_projects,
			v_number_genbank,
			v_number_spec_relns,
			v_number_annotations,
			v_number_rvwd_annotations
		);

	-- pre-delete everything
	delete from cache_sysstats_coln;

	for r in (select guid_prefix,collection_id from collection) loop
		select count(*) into vc_number_specimens from cataloged_item where collection_id=r.collection_id;
		select sum(INDIVIDUALCOUNT) into vc_number_individuals from flat where collection_id=r.collection_id;
		select
			count(distinct(identification_taxonomy.taxon_name_id)) into vc_number_taxa
		from
			cataloged_item,
			identification,
			identification_taxonomy
		where
			cataloged_item.collection_object_id=identification.collection_object_id and
			identification.identification_id=identification_taxonomy.identification_id and
			cataloged_item.collection_id=r.collection_id
		;
		select
			count(distinct(collecting_event.locality_id)) into vc_number_localities
		from
			cataloged_item,
			specimen_event,
			collecting_event
		where
			cataloged_item.collection_object_id=specimen_event.collection_object_id and
			specimen_event.collecting_event_id=collecting_event.collecting_event_id and
			cataloged_item.collection_id=r.collection_id
		;
		select
			count(distinct(locality.locality_id)) into vc_number_georef_localities
		from
			cataloged_item,
			specimen_event,
			collecting_event,
			locality
		where
			cataloged_item.collection_object_id=specimen_event.collection_object_id and
			specimen_event.collecting_event_id=collecting_event.collecting_event_id and
			collecting_event.locality_id=locality.locality_id and
			locality.dec_lat is not null and
			cataloged_item.collection_id=r.collection_id
		;
		select
			count(distinct(specimen_event.collecting_event_id)) into vc_number_collecting_events
		from
			cataloged_item,
			specimen_event
		where
			cataloged_item.collection_object_id=specimen_event.collection_object_id and
			cataloged_item.collection_id=r.collection_id
		;
		select
			count(distinct(media_relations.media_id)) into vc_number_specimen_media
		from
			cataloged_item,
			media_relations
		where
			cataloged_item.collection_object_id=media_relations.RELATED_PRIMARY_KEY and
			media_relations.MEDIA_RELATIONSHIP ='shows cataloged_item' and
			cataloged_item.collection_id=r.collection_id
		;
		select
			count(distinct(citation.publication_id)) into vc_number_cit_pubs
		from
			cataloged_item,
			citation
		where
			cataloged_item.collection_object_id=citation.collection_object_id and
			cataloged_item.collection_id=r.collection_id
		;
		select
			count(*) into vc_number_citations
		from
			cataloged_item,
			citation
		where
			cataloged_item.collection_object_id=citation.collection_object_id and
			cataloged_item.collection_id=r.collection_id
		;
		select
			sum(c) into vc_number_loaned_items
		from (
			-- data loan
			select count(*) c from
				cataloged_item,
				loan_item
			where
				cataloged_item.collection_object_id=loan_item.collection_object_id and
				cataloged_item.collection_id=r.collection_id
			union
			-- part-loans
			select count(*) c from
				cataloged_item,
				specimen_part,
				loan_item
			where
				cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
				specimen_part.collection_object_id =loan_item.collection_object_id and
				cataloged_item.collection_id=r.collection_id
			)
		;
		select
			count(*) into vc_number_genbank
		from
			cataloged_item,
			coll_obj_other_id_num
		where
			cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id and
			coll_obj_other_id_num.OTHER_ID_TYPE = 'GenBank' and
			cataloged_item.collection_id=r.collection_id
		;
		select
			count(*) into vc_number_spec_relns
		from
			cataloged_item,
			coll_obj_other_id_num
		where
			cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id and
			coll_obj_other_id_num.ID_REFERENCES != 'self' and
			cataloged_item.collection_id=r.collection_id
		;
		select
			count(*) into vc_number_annotations
		from
			cataloged_item,
			annotations
		where
			cataloged_item.collection_object_id=annotations.collection_object_id and
			cataloged_item.collection_id=r.collection_id
		;
		select
			count(*) into vc_number_rvwd_annotations
		from
			cataloged_item,
			annotations
		where
			cataloged_item.collection_object_id=annotations.collection_object_id and
			annotations.REVIEWER_AGENT_ID is not null and
			cataloged_item.collection_id=r.collection_id
		;
		insert into cache_sysstats_coln (
			lastdate,
			guid_prefix,
			number_specimens,
			number_individuals,
			number_taxa,
			number_localities,
			number_georef_localities,
			number_collecting_events,
			number_specimen_media,
			number_cit_pubs,
			number_citations,
			number_loaned_items,
			number_genbank,
			number_spec_relns,
			number_annotations,
			number_rvwd_annotations
		) values (
			sysdate,
			r.guid_prefix,
			vc_number_specimens,
			vc_number_individuals,
			vc_number_taxa,
			vc_number_localities,
			vc_number_georef_localities,
			vc_number_collecting_events,
			vc_number_specimen_media,
			vc_number_cit_pubs,
			vc_number_citations,
			vc_number_loaned_items,
			vc_number_genbank,
			vc_number_spec_relns,
			vc_number_annotations,
			vc_number_rvwd_annotations
		);
	end loop;
end;
/
sho err;




	exec proc_cache_stats;

---->
	<cfinclude template="/includes/_header.cfm">
<cfset title="system statistics">




<style>
.table-header-rotated th.row-header{
  width: auto;
}

.table-header-rotated td{
  width: 40px;
  border-top: 1px solid #dddddd;
  border-left: 1px solid #dddddd;
  border-right: 1px solid #dddddd;
  vertical-align: middle;
  text-align: center;
}

.table-header-rotated th.rotate-45{
  height: 80px;
  width: 40px;
  min-width: 40px;
  max-width: 40px;
  position: relative;
  vertical-align: bottom;
  padding: 0;
  font-size: 12px;
  line-height: 0.8;
}

.table-header-rotated th.rotate-45 > div{
  position: relative;
  top: 0px;
  left: 40px; /* 80 * tan(45) / 2 = 40 where 80 is the height on the cell and 45 is the transform angle*/
  height: 100%;
  -ms-transform:skew(-45deg,0deg);
  -moz-transform:skew(-45deg,0deg);
  -webkit-transform:skew(-45deg,0deg);
  -o-transform:skew(-45deg,0deg);
  transform:skew(-45deg,0deg);
  overflow: hidden;
  border-left: 1px solid #dddddd;
  border-right: 1px solid #dddddd;
  border-top: 1px solid #dddddd;
}

.table-header-rotated th.rotate-45 span {
  -ms-transform:skew(45deg,0deg) rotate(315deg);
  -moz-transform:skew(45deg,0deg) rotate(315deg);
  -webkit-transform:skew(45deg,0deg) rotate(315deg);
  -o-transform:skew(45deg,0deg) rotate(315deg);
  transform:skew(45deg,0deg) rotate(315deg);
  position: absolute;
  bottom: 30px; /* 40 cos(45) = 28 with an additional 2px margin*/
  left: -25px; /*Because it looked good, but there is probably a mathematical link here as well*/
  display: inline-block;
  // width: 100%;
  width: 85px; /* 80 / cos(45) - 40 cos (45) = 85 where 80 is the height of the cell, 40 the width of the cell and 45 the transform angle*/
  text-align: left;
  // white-space: nowrap; /*whether to display in one line or not*/
}
</style>


<cfquery name="g" datasource="uam_god" cachedwithin="#createtimespan(0,0,600,0)#">
	select * from cache_sysstats_global
</cfquery>

<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,600,0)#">
	select * from cache_sysstats_coln order by guid_prefix
</cfquery>
<cfoutput>
<h2>Global</h2>


<div class="scrollable-table">
  <table class="table table-striped table-header-rotated">
    <thead>
      <tr>
        <th class="rotate-45"><div><span>##Collections</span></div></th>
        <th class="rotate-45"><div><span>##Institutions</span></div></th>
        <th class="rotate-45"><div><span>##Specimens</span></div></th>
        <th class="rotate-45"><div><span>##Taxa</span></div></th>
        <th class="rotate-45"><div><span>##TaxonRelations</span></div></th>
        <th class="rotate-45"><div><span>##Localities</span></div></th>
        <th class="rotate-45"><div><span>##GeoreferencedLocalities</span></div></th>
        <th class="rotate-45"><div><span>##CollectingEvents</span></div></th>
        <th class="rotate-45"><div><span>##Media</span></div></th>
        <th class="rotate-45"><div><span>##Agents</span></div></th>
        <th class="rotate-45"><div><span>##Publications</span></div></th>
        <th class="rotate-45"><div><span>##PublicationsWithDOI</span></div></th>
        <th class="rotate-45"><div><span>##Projects</span></div></th>
        <th class="rotate-45"><div><span>##GenBankLinks</span></div></th>
        <th class="rotate-45"><div><span>##SpecimenRelationships</span></div></th>
        <th class="rotate-45"><div><span>##Annotations</span></div></th>
        <th class="rotate-45"><div><span>##ReviewedAnnotations</span></div></th>
      </tr>
    </thead>
    <tbody><cfloop query="g">
      <tr>

				<td>#number_collections#</td>
				<td>#number_institutions#</td>
				<td>#number_specimens#</td>
				<td>#number_taxa#</td>
				<td>#number_taxon_relations#</td>
				<td>#number_localities#</td>
				<td>#number_georef_localities#</td>
				<td>#number_collecting_events#</td>
				<td>#number_media#</td>
				<td>#number_agents#</td>
				<td>#number_publications#</td>
				<td>#number_publication_doi#</td>
				<td>#number_projects#</td>
				<td>#number_genbank#</td>
				<td>#number_spec_relns#</td>
				<td>#number_annotations#</td>
				<td>#number_rvwd_annotations#</td>



      </tr>
	</cfloop>
    </tbody>
  </table>
</div>

</cfoutput>


<div class="scrollable-table">
  <table class="table table-striped table-header-rotated">
    <thead>
      <tr>
        <!-- First column header is not rotated -->
        <th></th>
        <!-- Following headers are rotated -->
        <th class="rotate-45"><div><span>Column header 1</span></div></th>
        <th class="rotate-45"><div><span>Column header 2</span></div></th>
        <th class="rotate-45"><div><span>Column header 3</span></div></th>
        <th class="rotate-45"><div><span>Column header 4</span></div></th>
        <th class="rotate-45"><div><span>Column header 5</span></div></th>
        <th class="rotate-45"><div><span>Column header 6</span></div></th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <th class="row-header">Row header 1</th>
        <td><input checked="checked" name="column1[]" type="radio" value="row1-column1"></td>
        <td><input checked="checked" name="column2[]" type="radio" value="row1-column2"></td>
        <td><input name="column3[]" type="radio" value="row1-column3"></td>
        <td><input name="column4[]" type="radio" value="row1-column4"></td>
        <td><input name="column5[]" type="radio" value="row1-column5"></td>
        <td><input name="column6[]" type="radio" value="row1-column6"></td>
      </tr>
      <tr>
        <th class="row-header">Row header 2</th>
        <td><input name="column1[]" type="radio" value="row2-column1"></td>
        <td><input name="column2[]" type="radio" value="row2-column2"></td>
        <td><input checked="checked" name="column3[]" type="radio" value="row2-column3"></td>
        <td><input checked="checked" name="column4[]" type="radio" value="row2-column4"></td>
        <td><input name="column5[]" type="radio" value="row2-column5"></td>
        <td><input name="column6[]" type="radio" value="row2-column6"></td>
      </tr>
      <tr>
        <th class="row-header">Row header 3</th>
        <td><input name="column1[]" type="radio" value="row3-column1"></td>
        <td><input name="column2[]" type="radio" value="row3-column2"></td>
        <td><input name="column3[]" type="radio" value="row3-column3"></td>
        <td><input name="column4[]" type="radio" value="row3-column4"></td>
        <td><input checked="checked" name="column5[]" type="radio" value="row3-column5"></td>
        <td><input checked="checked" name="column6[]" type="radio" value="row3-column6"></td>
      </tr>
    </tbody>
  </table>
</div>



<div class="scrollable-table">
  <table class="table table-striped table-header-rotated">
    <thead>
      <tr>
        <!-- First column header is not rotated -->
        <!-- Following headers are rotated -->
        <th class="rotate-45"><div><span>Column header 1</span></div></th>
        <th class="rotate-45"><div><span>Column header 2</span></div></th>
        <th class="rotate-45"><div><span>Column header 3</span></div></th>
        <th class="rotate-45"><div><span>Column header 4</span></div></th>
        <th class="rotate-45"><div><span>Column header 5</span></div></th>
        <th class="rotate-45"><div><span>Column header 6</span></div></th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><input checked="checked" name="column1[]" type="radio" value="row1-column1"></td>
        <td><input checked="checked" name="column2[]" type="radio" value="row1-column2"></td>
        <td><input name="column3[]" type="radio" value="row1-column3"></td>
        <td><input name="column4[]" type="radio" value="row1-column4"></td>
        <td><input name="column5[]" type="radio" value="row1-column5"></td>
        <td><input name="column6[]" type="radio" value="row1-column6"></td>
      </tr>
    </tbody>
  </table>
</div>


<cfinclude template="/includes/_footer.cfm">

<!----



<cfset title="system statistics">
<style>
th.rotate > div
{
 margin-left: -85px;
 position: absolute;
 width: 215px;
 transform: rotate(-90deg);
 -webkit-transform: rotate(-90deg); /* Safari/Chrome */
 -moz-transform: rotate(-90deg); /* Firefox */
 -o-transform: rotate(-90deg); /* Opera */
 -ms-transform: rotate(-90deg); /* IE 9 */
}

th.rotate
{
 height: 220px;
 line-height: 14px;
 padding-bottom: 20px;
 text-align: left;
}
</style>





	<div class="tblscroll">

		<table border="1" id="t" class="">
	<thead>
		<!----

		<tr class="bigtable">
			<th class="rotate">##Collections</th>
			<th class="rotate">##Institutions</th>
			<th class="rotate">##Specimens</th>
			<th class="rotate">##Taxa</th>
			<th class="rotate">##TaxonRelations</th>
			<th class="rotate">##Localities</th>
			<th class="rotate">##GeoreferencedLocalities</th>
			<th class="rotate">##CollectingEvents</th>
			<th class="rotate">##Media</th>
			<th class="rotate">##Agents</th>
			<th class="rotate">##Publications</th>
			<th class="rotate">##PublicationsWithDOI</th>
			<th class="rotate">##Projects</th>
			<th class="rotate">##GenBankLinks</th>
			<th class="rotate">##SpecimenRelationships</th>
			<th class="rotate">##Annotations</th>
			<th class="rotate">##ReviewedAnnotations</th>
		</tr>
		---->
		<tr class="">
			<th class="rotate"><div><span>##Collections</span></div></th>
			<th class="rotate"><div><span>##Institutions</span></div></th>
			<th class="rotate"><div><span>##Specimens</span></div></th>
			<th class="rotate"><div><span>##Taxa</span></div></th>
			<th class="rotate"><div><span>##TaxonRelations</span></div></th>
			<th class="rotate"><div><span>##Localities</span></div></th>
			<th class="rotate"><div><span>##GeoreferencedLocalities</span></div></th>
			<th class="rotate"><div><span>##CollectingEvents</span></div></th>
			<th class="rotate"><div><span>##Media</span></div></th>
			<th class="rotate"><div><span>##Agents</span></div></th>
			<th class="rotate"><div><span>##Publications</span></div></th>
			<th class="rotate"><div><span>##PublicationsWithDOI</span></div></th>
			<th class="rotate"><div><span>##Projects</span></div></th>
			<th class="rotate"><div><span>##GenBankLinks</span></div></th>
			<th class="rotate"><div><span>##SpecimenRelationships</span></div></th>
			<th class="rotate"><div><span>##Annotations</span></div></th>
			<th class="rotate"><div><span>##ReviewedAnnotations</span></div></th>
		</tr>
	</thead>
	<cfloop query="g">
		<tbody class="">
			<tr>
				<td>#number_collections#</td>
				<td>#number_institutions#</td>
				<td>#number_specimens#</td>
				<td>#number_taxa#</td>
				<td>#number_taxon_relations#</td>
				<td>#number_localities#</td>
				<td>#number_georef_localities#</td>
				<td>#number_collecting_events#</td>
				<td>#number_media#</td>
				<td>#number_agents#</td>
				<td>#number_publications#</td>
				<td>#number_publication_doi#</td>
				<td>#number_projects#</td>
				<td>#number_genbank#</td>
				<td>#number_spec_relns#</td>
				<td>#number_annotations#</td>
				<td>#number_rvwd_annotations#</td>
			</tr>
		</tbody>
	</cfloop>
</table>

	</div>

</cfoutput>












<!----










<cfif action is "oldstuff">
<script>
	$(document).ready(function() {
		$("#thisIsSlowYo").hide();
	});
</script>
<cfoutput>
	<cfquery name="d" datasource="uam_god" cachedwithin="#createtimespan(0,0,600,0)#">
		select * from collection order by guid_prefix
	</cfquery>
	<br>this form caches
	<table border>
		<tr><th>
				Metric
			</th>
			<th>
				Value
			</th></tr>
		<tr>
			<td>
				Number Collections
				<a href="##collections" class="infoLink">list</a>
			</td>
			<td><input value="#d.recordcount#"></td>
		</tr>
		<cfquery name="inst" dbtype="query">
			select institution from d group by institution order by institution
		</cfquery>
		<tr>
			<td>Number Institutions<a href="##rawinst" class="infoLink">list</a></td>
			<td><input value="#inst.recordcount#"></td>
		</tr>

		<cfquery name="cataloged_item" datasource="uam_god" cachedwithin="#createtimespan(0,0,600,0)#">
			select count(*) c from cataloged_item
		</cfquery>
		<tr>
			<td>Total Number Specimen Records</td>
			<td><input value="#NumberFormat(cataloged_item.c)#"></td>
		</tr>


		<cfquery name="citype" datasource="uam_god" cachedwithin="#createtimespan(0,0,600,0)#">
			select
				CATALOGED_ITEM_TYPE,
				count(*) c
			from
				cataloged_item
			group by
				CATALOGED_ITEM_TYPE
		</cfquery>
		<tr>
			<td>Number Specimen Records by cataloged_item_type</td>
			<td>
				<cfloop query="citype">
					<input value="#NumberFormat(c)#"> #CATALOGED_ITEM_TYPE#<br>
				</cfloop>
			</td>
		</tr>

		<cfquery name="taxonomy" datasource="uam_god" cachedwithin="#createtimespan(0,0,600,0)#">
			select count(*) c from taxon_name
		</cfquery>
		<tr>
			<td>Number Taxon Names</td>
			<td><input value="#NumberFormat(taxonomy.c)#"></td>
		</tr>
		<cfquery name="locality" datasource="uam_god" cachedwithin="#createtimespan(0,0,600,0)#">
			select count(*) c from locality
		</cfquery>
		<tr>
			<td>Number Localities</td>
			<td><input value="#NumberFormat(locality.c)#"></td>
		</tr>

		<cfquery name="collecting_event" datasource="uam_god" cachedwithin="#createtimespan(0,0,600,0)#">
			select count(*) c from collecting_event
		</cfquery>
		<tr>
			<td>Number Collecting Events</td>
			<td><input value="#NumberFormat(collecting_event.c)#"></td>
		</tr>

		<cfquery name="media" datasource="uam_god" cachedwithin="#createtimespan(0,0,600,0)#">
			select count(*) c from media
		</cfquery>
		<tr>
			<td>Number Media</td>
			<td><input value="#NumberFormat(media.c)#"></td>
		</tr>
		<cfquery name="agent" datasource="uam_god" cachedwithin="#createtimespan(0,0,600,0)#">
			select count(*) c from agent
		</cfquery>
		<tr>
			<td>Number Agents</td>
			<td><input value="#NumberFormat(agent.c)#"></td>
		</tr>
		<cfquery name="publication" datasource="uam_god"  cachedwithin="#createtimespan(0,0,600,0)#">
			select count(*) c from publication
		</cfquery>
		<tr>
			<td>
				Number Publications
				<cfif session.roles contains "coldfusion_user">
					(<a href="/info/MoreCitationStats.cfm">more detail</a>)
				</cfif>
			</td>
			<td><input value="#NumberFormat(publication.c)#"></td>
		</tr>
		<cfquery name="project" datasource="uam_god" cachedwithin="#createtimespan(0,0,600,0)#">
			select count(*) c from project
		</cfquery>
		<tr>
			<td>
				Number Projects
				<cfif session.roles contains "coldfusion_user">
					(<a href="/info/MoreCitationStats.cfm">more detail</a>)
				</cfif>
			</td>
			<td><input value="#NumberFormat(project.c)#"></td>
		</tr>

		<!----
		<cfquery name="user_tables" datasource="uam_god"  cachedwithin="#createtimespan(0,0,60,0)#">
			select TABLE_NAME from user_tables
		</cfquery>
		<tr>
			<td>Number Tables *</td>
			<td><input value="#user_tables.recordcount#"></td>
		</tr>
		<cfquery name="ct" dbtype="query">
			select TABLE_NAME from user_tables where table_name like 'CT%'
		</cfquery>
		<tr>
			<td>Number Code Tables *</td>
			<td><input value="#ct.recordcount#"></td>
		</tr>
		---->
		<cfquery name="gb"  datasource="uam_god"  cachedwithin="#createtimespan(0,0,600,0)#">
			select count(*) c from coll_obj_other_id_num where OTHER_ID_TYPE = 'GenBank'
		</cfquery>
		<tr>
			<td>Number GenBank Linkouts</td>
			<td><input value="#NumberFormat(gb.c)#"></td>
		</tr>
		<cfquery name="reln"  datasource="uam_god"  cachedwithin="#createtimespan(0,0,600,0)#">
			select count(*) c from coll_obj_other_id_num where ID_REFERENCES != 'self'
		</cfquery>
		<tr>
			<td>Number Inter-Specimen Relationships</td>
			<td><input value="#NumberFormat(reln.c)#"></td>
		</tr>
	</table>





	<!----
	* The numbers above represent tables owned by the system owner.
	There are about 85 "data tables" which contain primary specimen data. They're pretty useless by themselves - the other several hundred tables are user info,
	 VPD settings, user settings and customizations, temp CF bulkloading tables, CF admin stuff, cached data (collection-type-specific code tables),
	 archives of deletes from various places, snapshots of system objects (eg, audit), and the other stuff that together makes Arctos work. Additionally,
	 there are approximately 100,000 triggers, views, procedures, system tables, etc. - think of them as the duct tape that holds Arctos together.
	 Arctos is a deeply-integrated system which heavily uses Oracle functionality; it is not a couple tables loosely held together by some
	 middleware, a stark contrast to any other system with which we are familiar.
	 ---->

	<p>Query and Download stats are available under the Reports tab.</p>
	<a name="growth"></a>
	<hr>
	<cfif isdefined('getCSV') and getCSV is true>
		<cfset fileDir = "#Application.webDirectory#">
		<cfset variables.encoding="UTF-8">
		<cfset fname = "arctos_by_year.csv">
		<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
	</cfif>
	Specimen Records and collection by year

	<a href="/info/sysstats.cfm?getCSV=true">CSV</a>

<!---
	<cfquery name="sby" datasource="uam_god">
		select
	    to_number(to_char(COLL_OBJECT_ENTERED_DATE,'YYYY')) yr,
	    count(*) numberSpecimens,
	    count(distinct(collection_id)) numberCollections
	  from
	    cataloged_item,
	    coll_object
	  where cataloged_item.collection_object_id=coll_object.collection_object_id
	  group by
	    to_number(to_char(COLL_OBJECT_ENTERED_DATE,'YYYY'))
		order by to_number(to_char(COLL_OBJECT_ENTERED_DATE,'YYYY'))
	</cfquery>
	<cfdump var=#sby#>

	<cfset cCS=0>
	<cfset cCC=0>

	<cfloop query="sby">
		<cfquery name="thisyear" dbtype="query">
			select * from sby where yr <= #yr#
		</cfquery>
		<cfdump var=#thisyear#>

		<cfset cCS=ArraySum(thisyear['numberSpecimens'])>
		<cfset cCC=ArraySum(thisyear['numberCollections'])>

		<p>
			y: #yr#; cCS: #cCS#; cCC: #cCC#
		</p>

	</cfloop>
	---->
	<cfif not isdefined('getCSV') or getCSV is not true>
		<div id="thisIsSlowYo">
			Fetching data....<img src="/images/indicator.gif">
		</div>
		<cfflush>
	</cfif>
<table border>
		<tr>
			<th>Year</th>
			<th>Number Collections</th>
			<th>Number Specimen Records</th>
		</tr>
	<cfif isdefined('getCSV') and getCSV is true>
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			variables.joFileWriter.writeLine("year,NumberCollections,NumberSpecimens");
		</cfscript>
	</cfif>
	<cfloop from="1995" to="#dateformat(now(),"YYYY")#" index="y">
		<cfquery name="qy" datasource="uam_god" cachedwithin="#createtimespan(0,0,600,0)#">
 			select
				count(*) numberSpecimens,
				count(distinct(collection_id)) numberCollections
			from
				cataloged_item,
				coll_object
			where cataloged_item.collection_object_id=coll_object.collection_object_id and
		 		to_number(to_char(COLL_OBJECT_ENTERED_DATE,'YYYY')) between 1995 and #y#
		</cfquery>
		<tr>
			<td>#y#</td>
			<td>#qy.numberCollections#</td>
			<td>#NumberFormat(qy.numberSpecimens)#</td>
		</tr>
		<cfif isdefined('getCSV') and getCSV is true>
			<cfscript>
				variables.joFileWriter.writeLine('"#y#","#qy.numberCollections#","#qy.numberSpecimens#"');
			</cfscript>
		</cfif>
	</cfloop>
	</table>
		<cfif isdefined('getCSV') and getCSV is true>
			<cfscript>
				variables.joFileWriter.close();
			</cfscript>
			<cflocation url="/download.cfm?file=#fname#" addtoken="false">
		</cfif>
	<hr>
	<a name="collections"></a>
	<p>List of collections in Arctos:</p>
	<ul>
		<cfloop query="d">
			<li>#guid_prefix#: #institution# #collection#</li>
		</cfloop>
	</ul>
	<hr>
	<a name="rawinst"></a>
	<p>List of institutions in Arctos:</p>
	<ul>
		<cfloop query="inst">
			<li>#institution#</li>
		</cfloop>
	</ul>
</cfoutput>
</cfif>
---->
<cfinclude template="/includes/_footer.cfm">
---->