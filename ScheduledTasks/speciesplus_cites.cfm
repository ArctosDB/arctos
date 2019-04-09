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






















UAM@ARCTOS> select distinct term from temp_speciesplus_meta;

TERM
------------------------------------------------------------------------------------------------------------------------
common_name
class
synonym
phylum
order
kingdom
family
cites_appendix



alter table temp_speciesplus_core add arctosstuff varchar2(4000);



     14101



--->

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
			no kingdom die<cfabort>
		</cfif>
		<cfquery name="exist"  datasource='uam_god'>
			select  TERM, TERM_TYPE	from taxon_term where source='#src#' and taxon_name_id=(select taxon_name_id from taxon_name where scientific_name='#name#')
		</cfquery>
		<cfdump var=#exist#>
	</cfloop>
</cfoutput>









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