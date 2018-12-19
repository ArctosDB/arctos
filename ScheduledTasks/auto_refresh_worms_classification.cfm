<cfsetting requestTimeOut = "120">
<!---------
for the first run get this from the temp table
needs rebuilt to something like this once that's done


do not do this.....
<cfquery name="d" datasource="uam_god">
	select
		taxon_name_id,
		term aphiaid ,
		sysdate-lastdate,
		lastdate
	from
		taxon_term
	where
		source='WoRMS (via Arctos)' and
		term_type='aphiaid' and
		sysdate-lastdate > 7 and
		rownum<13
</cfquery>


... because worms has a AphiaRecordsByDate service to find changed things

First Run:

pull everything we need to update into a temp table


SUBSEQUENT/TODO

- use the service to find things that have changed
- stuff them in the temp table

create table cf_temp_worms_stale as select
	taxon_name_id,
	term aphiaid ,
	lastdate,
	'init_import' status
from
	taxon_term
where
	source='WoRMS (via Arctos)' and
	term_type='aphiaid'
;

update cf_temp_worms_stale set status='used_in_id' where taxon_name_id in (select taxon_name_id from identification_taxonomy);
alter table cf_temp_worms_stale modify  status varchar2(4000);
update cf_temp_worms_stale set status=trim(status);




select status, count(*) from cf_temp_worms_stale group by status;


update cf_temp_worms_stale set status='pause' where status='init_import';


<cfset sdate=now()>


select scientific_name from taxon_name where taxon_name_id in (select taxon_name_id from cf_temp_worms_stale where status='refresh_fail');
select scientific_name from taxon_name where taxon_name_id in (select taxon_name_id from cf_temp_worms_stale where status='refreshed') and taxon_name_id in (select taxon_name_id from taxon_relations);


update cf_temp_worms_stale set status='init_import' where status='refresh_fail';

update cf_temp_worms_stale set status='init_import' where status='used_in_id';

------------------------------------------------------------------------------------------------------------------------
  COUNT(*)
----------
used_in_id
	17

refreshed
     16497

init_import
    528915

refresh_fail
	12

--->


<cfquery name="d" datasource="uam_god">
	select * from (
		select
			lastdate,
			taxon_name_id,
			aphiaid
		from
			cf_temp_worms_stale
		where
			status='init_import' order by lastdate
	) where rownum<20
</cfquery>

<cfoutput>
	<cfset tc = CreateObject("component","component.taxonomy")>
	<cfloop query="d">
		<cfset x=tc.updateWormsArctosByAphiaID(aphiaid,taxon_name_id)>
		<cfif isdefined("x.STATUS") and x.STATUS is "success">
			<cfquery name="mud" datasource="uam_god">
				update cf_temp_worms_stale set lastdate=sysdate ,status='refreshed' where taxon_name_id=#d.taxon_name_id# and aphiaid='#d.aphiaid#'
			</cfquery>
		<cfelse>
			<cfquery name="mud" datasource="uam_god">
				update cf_temp_worms_stale set lastdate=sysdate ,status='refresh_fail' where taxon_name_id=#d.taxon_name_id# and aphiaid='#d.aphiaid#'
			</cfquery>
		</cfif>
		<!--- by request, one query per second at most ---->
		<cfset sleep(1000)>
	</cfloop>
<!----

	<cfset fdate=now()>

	<cfset ctime=datediff('s',sdate,fdate)>

		<p>
			elapsed time: #ctime# s
		</p>
	---->
</cfoutput>
