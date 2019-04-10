<cfif not isdefined("action")><cfset action='nothing'></cfif>


<!---
	stash everything

	https://www.speciesplus.net/species

	download

	fix the horrid header

	create table temp_speciesplus  as select * from dlm.my_temp_cf ;
	-- doesn't work
	delete from temp_speciesplus;

	scp spldl.csv dustylee@arctos-test.tacc.utexas.edu:/usr/local/tmp/data.csv

	shit nevermind their CSV is garbage

	drop table temp_speciesplus;



	-- keep track of iteration
	create table temp_sp_iteration (lastpage number);
	insert into temp_sp_iteration(lastpage) values (0);

	-- this is likely to get complicated, so just cache everything via webservice and deal with it later

	create table temp_speciesplus_core (concept_id number, name varchar2(255));

	create table temp_speciesplus_meta (concept_id number, term varchar2(255), value varchar2(255));

	-- flush/start over
	delete from temp_speciesplus_meta;
	delete from temp_speciesplus_core;
	update temp_sp_iteration set lastpage=0;


	desc temp_speciesplus_core

	select name from temp_speciesplus_core order by name;

	select count(distinct(name)) from temp_speciesplus_core;

	begin
		for r in (select * from temp_speciesplus_core order by name) loop

			dbms_output.put_line('[' || r.name || '](https://speciesplus.net/#/taxon_concepts/' ||r.concept_id || ')');
			for c in (select term,value from temp_speciesplus_meta where concept_id=r.concept_id group by term,value order by term,value) loop
				dbms_output.put_line('    ' || c.term ||' = ' || c.value);
			end loop;
			dbms_output.put_line('');
			dbms_output.put_line('----------------------------------');
			dbms_output.put_line('');
		end loop;
	end;
	/


alter table temp_speciesplus_core add status varchar2(255);

update temp_speciesplus_core set status='in_arctos' where name in (select scientific_name from taxon_name);

update temp_speciesplus_core set status=isvalidtaxonname(name) where status is null;

select status,count(*) from temp_speciesplus_core group by status;

select name,status from temp_speciesplus_core where status not in ('in_arctos','valid');

-- meh, ignore the garbage

create table temp_makethis as select name from temp_speciesplus_core where status='valid' group by name;

drop table temp_makethis2;

create table temp_makethis2 as select value name from temp_speciesplus_meta where term='synonym' group by value;

select count(*) from temp_makethis2;

alter table temp_makethis2 add status varchar2(255);
update temp_makethis2 set status='in_arctos' where name in (select scientific_name from taxon_name);
update temp_makethis2 set status=isvalidtaxonname(name) where status is null;
update temp_makethis2 set status=isvalidtaxonname(name) where status ='valid';

select status,count(*) from temp_makethis2 group by status;
select name from temp_makethis2  where status='valid'

insert into taxon_name (scientific_name,taxon_name_id) (select name,sq_taxon_name_id.nextval from temp_makethis2 where status='valid');

select scientific_name,isvalidtaxonname(scientific_name) from taxon_name where to_char(CREATED_DATE,'YYYY-MM-DD')='2019-04-09' and isvalidtaxonname(scientific_name)!='valid';

update temp_speciesplus_core set arctosstuff='create_taxa_need_class' where name in (select scientific_name from taxon_name where to_char(CREATED_DATE,'YYYY-MM-DD')='2019-04-09');






















UAM@ARCTOS> select distinct term from temp_speciesplus_meta;

TERM
------------------------------------------------------------------------------------------------------------------------
common_name
class
synonym
phylum
order
family
cites_appendix



alter table temp_speciesplus_core add arctosstuff varchar2(4000);

alter table temp_speciesplus_core add taxon_name_id number;
update temp_speciesplus_core set taxon_name_id=(select taxon_name_id from taxon_name where scientific_name=name);


alter table temp_speciesplus_core add source varchar2(255);
update temp_speciesplus_core set source='Arctos' where concept_id in (select concept_id from temp_speciesplus_meta where term='kingdom' and value='Animalia');
update temp_speciesplus_core set source='Arctos Plants' where concept_id in (select concept_id from temp_speciesplus_meta where term='kingdom' and value='Plantae');


select count(*) from temp_speciesplus_core where taxon_name_id is not null and source is null;
select count(*) from temp_speciesplus_meta where concept_id=11896900;

alter table temp_speciesplus_core add arctos_kingdom varchar2(255);

update temp_speciesplus_core set arctos_kingdom=(
	select distinct term from taxon_term where
		taxon_term.source=temp_speciesplus_core.source and
		taxon_term.taxon_name_id=temp_speciesplus_core.taxon_name_id and
		term_type='kingdom'
	);

	select distinct arctos_kingdom from temp_speciesplus_core;


alter table temp_speciesplus_core add arctos_phylum varchar2(255);

update temp_speciesplus_core set arctosstuff='multiple_arctos_phylum' where taxon_name_id in (select taxon_name_id from (
select term, taxon_name_id from taxon_term where
		taxon_term.source in ('Arctos','Arctos Plants') and
		term_type='phylum'
		having count(*) > 1 group by term, taxon_name_id
	));


update temp_speciesplus_core set arctos_phylum=(
	select distinct term from taxon_term where
		taxon_term.source=temp_speciesplus_core.source and
		taxon_term.taxon_name_id=temp_speciesplus_core.taxon_name_id and
		term_type='phylum' and
		 arctosstuff is null
	) where arctosstuff is null;



declare t varchar2(255);
begin
	for r in (select name,source,taxon_name_id from temp_speciesplus_core where arctos_phylum is null and arctosstuff is null and taxon_name_id is not null and rownum<20000) loop
	--dbms_output.put_line(r.name);
	--dbms_output.put_line(r.source);
	--dbms_output.put_line(r.taxon_name_id);

		begin
			select term into t from taxon_term where
				taxon_term.source=r.source and
				taxon_term.taxon_name_id=r.taxon_name_id and
				term_type='phylum' group by term;

			update temp_speciesplus_core set arctos_phylum=t where taxon_name_id=r.taxon_name_id;

		--	dbms_output.put_line('t:'||t);
		exception when others then
		--	dbms_output.put_line('fail@'||r.name);
			update temp_speciesplus_core set arctosstuff='arctos_phylum_fail' where taxon_name_id=r.taxon_name_id;
		end;
	end loop;
end;
/


alter table temp_speciesplus_core add arctos_class varchar2(255);


declare t varchar2(255);
begin
	for r in (select name,source,taxon_name_id from temp_speciesplus_core where arctos_class is null and arctosstuff is null and taxon_name_id is not null and rownum<20000) loop
	--dbms_output.put_line(r.name);
	--dbms_output.put_line(r.source);
	--dbms_output.put_line(r.taxon_name_id);

		begin
			select term into t from taxon_term where
				taxon_term.source=r.source and
				taxon_term.taxon_name_id=r.taxon_name_id and
				term_type='class' group by term;

			update temp_speciesplus_core set arctos_class=t where taxon_name_id=r.taxon_name_id;

		--	dbms_output.put_line('t:'||t);
		exception when others then
		--	dbms_output.put_line('fail@'||r.name);
			update temp_speciesplus_core set arctosstuff='arctos_class_fail' where taxon_name_id=r.taxon_name_id;
		end;
	end loop;
end;
/


create table temp_has_both as select taxon_name_id from temp_speciesplus_core where taxon_name_id is not null and taxon_name_id in (select taxon_name_id from taxon_term where source='Arctos')
and taxon_name_id in (select taxon_name_id from taxon_term where source='Arctos Plants');

----------------- stopped here -------------

select term  from taxon_term where
				taxon_term.source='Arctos' and
				taxon_term.taxon_name_id=12 and
				term_type='phylum';


update temp_speciesplus_core set arctosstuff='multiple_arctos_class' where arctosstuff is null and taxon_name_id is not null and taxon_name_id in (select taxon_name_id from (
select term, taxon_name_id from taxon_term where
		taxon_term.source in ('Arctos','Arctos Plants') and
		term_type='class'
		having count(*) > 1 group by term, taxon_name_id
	));




	select term, taxon_name_id from taxon_term where
		taxon_term.source in ('Arctos','Arctos Plants') and
		term_type='phylum'
		having count(*) > 1 group by term, taxon_name_id;

	) where arctosstuff is null;


alter table temp_speciesplus_core add arctos_class varchar2(255);

update temp_speciesplus_core set arctos_class=(
	select distinct term from taxon_term where
		taxon_term.source=temp_speciesplus_core.source and
		taxon_term.taxon_name_id=temp_speciesplus_core.taxon_name_id and
		term_type='class'
	);





create index ix_tmp_spm_cid on temp_speciesplus_meta (concept_id) tablespace uam_idx_1;
create index ix_tmp_spm_trm on temp_speciesplus_meta (term) tablespace uam_idx_1;

update temp_speciesplus_core set arctosstuff='create_taxa_need_class' where name in (select scientific_name from taxon_name where to_char(CREATED_DATE,'YYYY-MM-DD')='2019-04-09');

drop table temp_ttl;
drop table temp_ttl2;


create table temp_ttl as select distinct name scientific_name, concept_id from temp_speciesplus_core where arctosstuff='create_taxa_need_class';




alter table temp_ttl add USERNAME varchar2(255);
alter table temp_ttl add SOURCE varchar2(255);
alter table temp_ttl add NOMENCLATURAL_CODE varchar2(255);
alter table temp_ttl add SOURCE_AUTHORITY varchar2(255);
alter table temp_ttl add KINGDOM varchar2(255);
alter table temp_ttl add PHYLUM varchar2(255);
alter table temp_ttl add PHYLORDER varchar2(255);
alter table temp_ttl add FAMILY varchar2(255);
alter table temp_ttl add class varchar2(255);


update temp_ttl set USERNAME='dlm';
update temp_ttl set KINGDOM=(select distinct VALUE from temp_speciesplus_meta where temp_speciesplus_meta.concept_id=temp_ttl.concept_id and TERM='kingdom');

update temp_ttl set PHYLUM=(select distinct VALUE from temp_speciesplus_meta where temp_speciesplus_meta.concept_id=temp_ttl.concept_id and TERM='phylum');

update temp_ttl set PHYLORDER=(select distinct VALUE from temp_speciesplus_meta where temp_speciesplus_meta.concept_id=temp_ttl.concept_id and TERM='order');

update temp_ttl set class=(select distinct VALUE from temp_speciesplus_meta where temp_speciesplus_meta.concept_id=temp_ttl.concept_id and TERM='class');

update temp_ttl set family=(select distinct VALUE from temp_speciesplus_meta where temp_speciesplus_meta.concept_id=temp_ttl.concept_id and TERM='family');



update temp_ttl set NOMENCLATURAL_CODE='ICBN',SOURCE='Arctos Plants' where kingdom='Plantae';
update temp_ttl set NOMENCLATURAL_CODE='ICZN',SOURCE='Arctos' where kingdom='Animalia';












create table temp_ttl2 as select * from temp_ttl where kingdom is not null;

alter table temp_ttl2 drop column concept_id;



select scientific_name, count(*) from temp_ttl2 having count(*) > 1 group by scientific_name;


select * from temp_ttl where kingdom is null;


BAH don't have enough info to use this!!

update temp_speciesplus_core set ARCTOSSTUFF =null;



--->

<cfif action is "nothing">
	<!-- Plan Lots:
		shove this stuff in the Arctos Legal source classification
	---->
<cfoutput>
	<cfquery name="d" datasource='uam_god'>
		select name,concept_id from temp_speciesplus_core where arctosstuffis null  and rownum<2 group by name,concept_id
	</cfquery>
	<cfloop query="d">
		<br>#name#
		<cfquery name="m" datasource='uam_god'>
			select distinct TERM,VALUE vlu from temp_speciesplus_meta where concept_id='#concept_id#'
		</cfquery>
		<cfdump var=#m#>
	</cfloop>

</cfoutput>

</cfif>

<cfif action is "old_garbage">
<cfoutput>
	<cfquery name="d" datasource='uam_god'>
		select name,concept_id from temp_speciesplus_core where status='in_arctos' and arctosstuff is null and rownum<5 group by name,concept_id
	</cfquery>
	<cfloop query="d">
		<br>#name#
		<cfquery name="m" datasource='uam_god'>
			select distinct TERM,VALUE vlu from temp_speciesplus_meta where concept_id='#concept_id#'
		</cfquery>
		<cfdump var=#m#>
		<cfquery name="k" dbtype="query">
			select vlu from m where term='kingdom'
		</cfquery>
		<cfif k.vlu is 'Animalia'>
			<cfset src='Arctos'>
		<cfelseif k.vlu is 'Plantae'>
			<cfset src='Arctos Plants'>
		<cfelse>
			no kingdom, not sure what do to....<cfabort>
		</cfif>
		<cfquery name="exist"  datasource='uam_god'>
			select  TERM, TERM_TYPE	from taxon_term where source='#src#' and taxon_name_id=(select taxon_name_id from taxon_name where scientific_name='#name#')
		</cfquery>
		<cfdump var=#exist#>
		<cfif exist.recordcount is 0>

		</cfif>
	</cfloop>
</cfoutput>
</cfif>








<cfif action is "fetch_original">
<cfoutput>
	<cfquery name="pg" datasource='uam_god'>
		select lastpage,lastpage+1 nextpage from temp_sp_iteration
	</cfquery>
	<cfquery name="auth" datasource='uam_god'>
		select SPECIESPLUS_TOKEN from cf_global_settings
	</cfquery>
	<cfhttp result="ga" url="https://api.speciesplus.net/api/v1/taxon_concepts?page=#pg.nextpage#&per_page=50" method="get">
		<cfhttpparam type = "header" name = "X-Authentication-Token" value = "#auth.SPECIESPLUS_TOKEN#">
	</cfhttp>
	<cfif isdefined("debug") and debug is true>
		<cfdump var=#ga#>
	</cfif>
	<cfif ga.statusCode is "200 OK" and len(ga.filecontent) gt 0 and isjson(ga.filecontent)>
		<cfset rslt=DeserializeJSON(ga.filecontent)>

		<cfif isdefined("debug") and debug is true>
			<cfdump var=#rslt#>
		</cfif>
		<cfset numberAvailablePages=rslt.pagination.total_entries / rslt.pagination.per_page>
		<cfif isdefined("debug") and debug is true>
			<br>numberAvailablePages::#numberAvailablePages#
			<br>pg.lastpage::#pg.lastpage#
		</cfif>
		<cfif pg.lastpage gte numberAvailablePages>
			<br>numberAvailablePages::#numberAvailablePages#
			<br>pg.lastpage::#pg.lastpage#
			<br>all done aborting
			<cfabort>
		</cfif>

		<cfloop from="1" to ="#arraylen(rslt.taxon_concepts)#" index="i">
			<cfset thisConcept=rslt.taxon_concepts[i]>
			<!----
			<p>#i#</p>
			<cfdump var=#thisConcept#>
			---->
			<cfif isdefined("debug") and debug is true>
				<cfdump var=#thisConcept#>
			</cfif>
			<cfset thisID=thisConcept.id>
			<cfset thisName=thisConcept.full_name>
			<cfquery name="insCore" datasource="uam_god">
				insert into temp_speciesplus_core (concept_id,name) values (#thisID#,'#thisName#')
			</cfquery>
			<!----
			<br>thisID=#thisID#
			<br>thisName=#thisName#
			---->
			<cfif structkeyexists(thisConcept,"cites_listings")>
				<cfloop from="1" to ="#arraylen(thisConcept.cites_listings)#" index="cli">
					<cfset thisCitesAppendix=thisConcept.cites_listings[cli].appendix>
					<!----
					<br>thisCitesAppendix=#thisCitesAppendix#
					---->
					<cfquery name="insMeta" datasource="uam_god">
						insert into temp_speciesplus_meta (concept_id,term,value) values (#thisID#,'cites_appendix','#thisCitesAppendix#')
					</cfquery>
				</cfloop>
			</cfif>


			<cfif structkeyexists(thisConcept,"cites_listings")>
				<cfloop from="1" to ="#arraylen(thisConcept.common_names)#" index="cni">
					<cfset thisCommonName=thisConcept.common_names[cni].name>
					<cfquery name="insMeta" datasource="uam_god">
						insert into temp_speciesplus_meta (concept_id,term,value) values (#thisID#,'common_name','#thisCommonName#')
					</cfquery>
					<!---
					<br>thisCommonName=#thisCommonName#
					---->
				</cfloop>
			</cfif>
			<cfif structkeyexists(thisConcept,"higher_taxa")>
				<cfloop collection="#thisConcept.higher_taxa#" item="key">
					<cftry>
						<!----
				    <br>higher_taxa:: #key#: #thisConcept.higher_taxa[key]#<br />
				    ---->
				    <cfquery name="insMeta" datasource="uam_god">
						insert into temp_speciesplus_meta (concept_id,term,value) values (#thisID#,'#key#','#thisConcept.higher_taxa[key]#')
					</cfquery>
				    <cfcatch><br>fail....</cfcatch>
				    </cftry>
				</cfloop>
			</cfif>
			<cfif structkeyexists(thisConcept,"synonyms")>
				<cfloop from="1" to ="#arraylen(thisConcept.synonyms)#" index="syi">
					<cfset thisSynonym=thisConcept.synonyms[syi].full_name>
					<!----
					<br>thisSynonym=#thisSynonym#
					---->
					<cfquery name="insMeta" datasource="uam_god">
						insert into temp_speciesplus_meta (concept_id,term,value) values (#thisID#,'synonym','#thisSynonym#')
					</cfquery>
				</cfloop>
			</cfif>






		</cfloop>
				<cfquery name="logit" datasource="uam_god">
					update temp_sp_iteration set lastpage=lastpage+1
				</cfquery>
	<cfelse>
		<cfthrow message='speciesplus json parse failure'>
	</cfif>
</cfoutput>

</cfif>