
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

select status, count(*) from cf_temp_worms_stale group by status;

--->
<cfset sdate=now()>

<cfquery name="d" datasource="uam_god">
	select
		taxon_name_id,
		aphiaid
	from
		cf_temp_worms_stale
	where
		status='used_in_id' and
		sysdate-lastdate > 7 and
		rownum<25
</cfquery>

<cfdump var=#d#>


<cfoutput>
	<cfset tc = CreateObject("component","component.taxonomy")>

	<cfloop query="d">
		<cfset x=tc.updateWormsArctosByAphiaID(aphiaid,taxon_name_id)>
		<cfif isdefined("x.STATUS") and x.STATUS is "success">
			success
			<cfset ps=1>
		<cfelse>
			fail
				<cfdump var=#x#>

			<cfset ps=0>
		</cfif>
		<!----
		<cfquery name="g" datasource="uam_god">
			update temp_worms set init_pull=#ps# where taxon_name_id='#taxon_name_id#'
		</cfquery>
		---->
		<cfquery name="g" datasource="uam_god">
			select scientific_name from taxon_name where taxon_name_id=#d.taxon_name_id#
		</cfquery>
		<cfquery name="mud" datasource="uam_god">
			update cf_temp_worms_stale set lastdate=sysdate ,status='refreshed' where taxon_name_id=#d.taxon_name_id# and aphiaid='#d.aphiaid#'
		</cfquery>





		<br><a target="_blank" href="/name/#g.scientific_name###WoRMSviaArctos">#g.scientific_name#</a>
		<!--- be nice, take a short nap
		<cfset sleep(5000)>
		--->
		<cfset sleep(1000)>

	</cfloop>


<cfset fdate=now()>

<cfset ctime=datediff('s',sdate,fdate)>
<p>
	time: #ctime# s
</p>

</cfoutput>
