<!---

table to record where we've been; this can take a while to run since we can only get 50 records at a time
drop table cf_worms_refresh_job;
create table cf_worms_refresh_job (
	last_run_date date,
	last_status varchar2(255),
	last_page number
);
-- initial seed
insert into cf_worms_refresh_job(last_run_date,last_status,last_page) values (to_date('2018-12-20'),'new',0);

update cf_worms_refresh_job set last_run_date=to_date('2018-12-21'),last_status='new',last_page=0;

create table cf_worms_refreshed (
	aphiaid varchar2(255),
	name varchar2(255)
);

delete from cf_worms_refreshed;

		<br>insert into cf_worms_refreshed (aphiaid,name) values ('#rec.AphiaID#','#rec.scientificname#')

alter table cf_worms_refreshed add changed_date date;

update cf_worms_refreshed set changed_date=sysdate-4 where changed_date is null;

alter table cf_worms_refreshed add key number;

update cf_worms_refreshed set key=somerandomsequence.nextval;

alter table cf_worms_refreshed modify key not null;



alter table cf_worms_refreshed add status varchar2(255);
alter table cf_worms_refreshed add taxon_name_id number;

update cf_worms_refreshed set taxon_name_id=(
	select taxon_name.taxon_name_id from
	taxon_name,
	taxon_term
	where
	taxon_name.taxon_name_id=taxon_term.taxon_name_id and
	taxon_term.source='WoRMS (via Arctos)' and
	taxon_term.term_type='aphiaid' and
	taxon_name.scientific_name=cf_worms_refreshed.name and
	taxon_term.term=cf_worms_refreshed.aphiaid
) where taxon_name_id is null and status is null;

	update cf_worms_refreshed set taxon_name_id=null,status=null;


select status,count(*) from cf_worms_refreshed group by status;
--->
<p>
	<br><a href="get_worms_changed.cfm?action=process_get_aid">process_get_aid</a>
	<br><a href="get_worms_changed.cfm?action=process_changed_get_tid">process_changed_get_tid</a>
	<br><a href="get_worms_changed.cfm?action=process_changed_get_tid">get_changed</a>
</p>



<cfif action is "process_get_aid">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_worms_refreshed where status is null and taxon_name_id is not null
		</cfquery>
		<cfloop query="d">
			<cfquery name="n" datasource="uam_god">
				select classification_id from taxon_term where
					taxon_name_id=#d.taxon_name_id# and
					taxon_term.source='WoRMS (via Arctos)' and
					taxon_term.term_type='aphiaid' and
					taxon_term.term='#aphiaid#'
			</cfquery>
			<cfif len(n.classification_id) gt 0>
				<cfquery name="u" datasource="uam_god">
					update cf_worms_refreshed set status='found_classification' where key=#key#
				</cfquery>
			<cfelse>
				<cfquery name="u" datasource="uam_god">
					update cf_worms_refreshed set status='classification_not_found' where key=#key#
				</cfquery>
			</cfif>
		</cfloop>
	</cfoutput>
</cfif>




<cfif action is "process_changed_get_tid">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_worms_refreshed where status is null
		</cfquery>
		<cfloop query="d">
			<cfquery name="n" datasource="uam_god">
				select taxon_name_id from taxon_name where scientific_name='#name#'
			</cfquery>
			<cfif len(n.taxon_name_id) gt 0>
				<cfquery name="u" datasource="uam_god">
					update cf_worms_refreshed set status='found_taxon_id',taxon_name_id=#n.taxon_name_id# where key=#key#
				</cfquery>
			<cfelse>
				<cfquery name="u" datasource="uam_god">
					update cf_worms_refreshed set status='taxon_not_in_arctos' where key=#key#
				</cfquery>
			</cfif>
		</cfloop>
	</cfoutput>
</cfif>

<cfif action is "get_changed">
	<cfparam name="debug" default="false">
	<cfoutput>
		<cfquery name="rs" datasource="uam_god">
			select * from cf_worms_refresh_job
		</cfquery>
		<cfdump var=#rs#>
		<cfif rs.last_run_date eq dateformat(now(),"YYYY-MM-DD")>
			<br>last run was today; abort
			<cfabort>
		</cfif>
		<cfif rs.last_status is "204">
			<br>last status was 204; increment the date and reset status
			<cfset edate=DateAdd("d", 1, rs.last_run_date)>
			<cfquery name="irs" datasource="uam_god">
				update cf_worms_refresh_job set
					last_run_date='#dateformat(edate,"YYYY-MM-DD")#',
					last_status='incremented',
					last_page=0
			</cfquery>
			<cfabort>
		</cfif>

		<!--- if we made it here, we haven't caught up yet; pull a page--->
		<cfset thedate=dateformat(rs.last_run_date,"YYYY-MM-DD")>
		<cfset st=thedate & "T00%3A00%3A00%2B00%3A00">
		<cfset et=thedate & "T24%3A00%3A00%2B00%3A00">
		<cfset o=rs.last_page+1>
		<cfset lrn=o * 50>
		<cfset theURL="http://www.marinespecies.org/rest/AphiaRecordsByDate?startdate=#st#&enddate=#et#&marine_only=false&offset=#lrn#">
		<cfdump var=#theURL#>
		<cfhttp result="ga" url="#theURL#" method="get"></cfhttp>
		<!----
		<cfdump var=#ga#>
		---->
		<cfif debug is true>
			<cfdump var=#ga#>
		</cfif>
		<cfif left(ga.Statuscode,3) is "200">
			<br>found some stuff; going to process it below, do nothing here
		<cfelseif left(ga.Statuscode,3) is "204">
			<br>nothing left, update status
			<cfquery name="irs" datasource="uam_god">
				update cf_worms_refresh_job set last_status='204'
			</cfquery>
			<cfabort>
		<cfelse>
			<br>some sort of error
			<cfquery name="irs" datasource="uam_god">
				update cf_worms_refresh_job set last_status='random error'
			</cfquery>
			<cfabort>
		</cfif>
		here we go now....
		<cfset gao=DeserializeJSON(ga.filecontent)>
		<!----
		<cfdump var=#gao#>
		---->
		<cfif debug is true>
			<cfdump var=#gao#>
		</cfif>
		<cfloop from="1" to="#ArrayLen(gao)#" index="i">
			<cfset rec=gao[i]>

			<cfif debug is true>
				<cfdump var=#rec#>
			</cfif>
			<!----
			<cfdump var=#rec#>
			---->
			<!----
			<cfset theAID=rec.AphiaID>
			<cfset theName=rec.scientificname>
			---->
			<cfif isdefined("rec.AphiaID") and isdefined("rec.scientificname")>
				<cfquery name="icr" datasource="uam_god">
					insert into cf_worms_refreshed (aphiaid,name,changed_date,key) values ('#rec.AphiaID#','#rec.scientificname#',sysdate,somerandomsequence.nextval)
				</cfquery>
			<cfelse>
				wat??
				<cfdump var=#rec#>
			</cfif>
		</cfloop>
		<cfquery name="irs" datasource="uam_god">
			update cf_worms_refresh_job set last_page='#o#'
		</cfquery>

	</cfoutput>
</cfif>