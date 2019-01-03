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



update cf_worms_refreshed set status='found_taxon_id' where status in ('alternative_classification_found','classification_not_found');

update cf_worms_refreshed set status='found_taxon_id' where status in ('found_classification');


select status,count(*) from cf_worms_refreshed group by status;

select to_char(CHANGED_DATE,'YYYY-MM-DD'),count(*) from cf_worms_refreshed group by to_char(CHANGED_DATE,'YYYY-MM-DD');

select SCIENTIFIC_NAME from taxon_name where CREATED_DATE > sysdate-48 order by scientific_name;
select count(*) from taxon_name where CREATED_DATE < sysdate-48 order by scientific_name;

Elapsed: 00:00:00.00
UAM@ARCTOS> desc taxon_name;
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 TAXON_NAME_ID							   NOT NULL NUMBER
 SCIENTIFIC_NAME						   NOT NULL VARCHAR2(255)
 CREATED_BY_AGENT_ID						   NOT NULL NUMBER
 CREATED_DATE							   NOT NULL DATE




alter table cf_worms_refreshed add taxon_status varchar2(255);

select * from cf_worms_refreshed where name='Streptaxis footei';

update cf_worms_refreshed set status='needs_refreshed' where status='refresh_fail';


select count(*) from cf_worms_refreshed where status='needs_refreshed' and taxon_name_id is null;


	update cf_worms_refreshed set taxon_name_id=(select taxon_name_id from taxon_name where scientific_name=name) where
	status='needs_refreshed' and taxon_name_id is null;


	#n.taxon_name_id# where key=#key#



--->

<!--------

<p>
	<p>
		send email; daily
		<br><a href="get_worms_changed.cfm?action=notify">notify</a>
	</p>

	<p>
		Indicate if a name might be valid in Arctos. Do this last, before notifying.

		<br><a href="get_worms_changed.cfm?action=set_taxon_status">set_taxon_status</a>
	</p>


	<p>
		see how changed and local classifications line up. this is a little slow,
		but usually completes in one run. A few times per day should be sufficient.

		<br><a href="get_worms_changed.cfm?action=process_get_aid">process_get_aid</a>
	</p>


	<p>
		get taxon_name_id for stuff that's changed. This is fast, once per day is sufficient
		<br><a href="get_worms_changed.cfm?action=process_changed_get_tid">process_changed_get_tid</a>
	</p>

	<p>
		see what's changed in worms. This should run several times per day - once per hour is PROBABLY enough
		<br><a href="get_worms_changed.cfm?action=process_changed_get_tid">get_changed</a>
	</p>
</p>


<cfif action is "notify">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_worms_refreshed where status in ('taxon_not_in_arctos','classification_not_found')
		</cfquery>
		<cfquery name="tnf" dbtype="query">
			select * from d where status='taxon_not_in_arctos'
		</cfquery>
		<p>
			The following taxa have changed in WoRMS recently and are not in Arctos
		</p>
		<cfloop query="tnf">
			<br>#name# - #taxon_status#
		</cfloop>

		<cfquery name="cnf" dbtype="query">
			select * from d where status='classification_not_found'
		</cfquery>
		<p>
			The following taxa have changed in WoRMS recently, are not in Arctos, but do not have a classification in "Arctos (via WoRMS)"
		</p>
		<cfloop query="cnf">
			<br>#name#
		</cfloop>


	</cfoutput>
</cfif>






<cfif action is "get_changed">

--------->
	<cfparam name="debug" default="false">
	<cfoutput>
		<cfquery name="rs" datasource="uam_god">
			select * from cf_worms_refresh_job
		</cfquery>
		<cfif debug is true>
			<cfdump var=#rs#>
		</cfif>
		<cfif rs.last_run_date eq dateformat(now(),"YYYY-MM-DD")>
			<cfif debug is true>
				<!---- last run was today; we're current, see if there's other stuff to do ---->
				<br>last run was today; we're current, see if there's other stuff to do
				<!---- first job: see if there's anything that's just been inserted, and find a taxon_name_id for it if so ---->
				<br>first job: see if there's anything that's just been inserted, and find a taxon_name_id for it if so
			</cfif>
			<cfquery name="d" datasource="uam_god">
				select * from cf_worms_refreshed where status is null and rownum < 1000
			</cfquery>
			<cfif d.recordcount gt 0>
				<cfif debug is true>
					<br>going....
				</cfif>
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
				<!--- if we did something here just abort so as not to push available resources. If we didn't we'll move on to the next job --->
				<cfabort>
			</cfif>
			<!---- END::first job: see if there's anything that's just been inserted, and find a taxon_name_id for it if so ---->

			<!---- second job: for anything that we just got taxon_name_id, see if we have a matching classification ---->
			<cfquery name="d" datasource="uam_god">
				select * from cf_worms_refreshed where status ='found_taxon_id' and taxon_name_id is not null and rownum < 100
			</cfquery>
			<cfif debug is true>
				<br>second job: for anything that we just got taxon_name_id, see if we have a matching classification
			</cfif>
			<cfif d.recordcount gt 0>
				<cfif debug is true>
					going...
				</cfif>
				<cfloop query="d">

					<cfif debug is true>
						<br>#name#....
						<br>#aphiaid#
					</cfif>

					<cfquery name="n" datasource="uam_god">
						select term from taxon_term where
							taxon_name_id=#d.taxon_name_id# and
							taxon_term.source='WoRMS (via Arctos)' and
							taxon_term.term_type='aphiaid'
					</cfquery>
					<cfif listfind(valuelist(n.term),'#aphiaid#')>
						<!--- found an exact match ---->
						<cfquery name="u" datasource="uam_god">
							update cf_worms_refreshed set status='needs_refreshed' where key=#key#
						</cfquery>
						<cfif debug is true>
							needs_refreshed
						</cfif>
					 <cfelseif n.recordcount gt 0 and not listfind(valuelist(n.term),'#aphiaid#')>
					 	<!--- we have something, they have something, it's not the same ---->
						<cfquery name="u" datasource="uam_god">
							update cf_worms_refreshed set status='alternative_classification_found' where key=#key#
						</cfquery>
						<cfif debug is true>
							alternative_classification_found
						</cfif>

					 <cfelse>
						<cfquery name="u" datasource="uam_god">
							update cf_worms_refreshed set status='classification_not_found' where key=#key#
						</cfquery>
						<cfif debug is true>
							classification_not_found
						</cfif>

					</cfif>
				</cfloop>
				<!--- if we did something here just abort so as not to push available resources. If we didn't we'll move on to the next job --->
				<cfabort>
			</cfif>
			<!---- END::second job: for anything that we just got taxon_name_id, see if we have a matching classification ---->

			<!---- third job: set taxon_status to indicate whether we can make the name or not ---->

			<cfif debug is true>
				<br>third job: set taxon_status to indicate whether we can make the name or not
			</cfif>
			<cfquery name="d" datasource="uam_god">
				update cf_worms_refreshed set taxon_status=isValidTaxonName(name) where status ='taxon_not_in_arctos' and taxon_status is null
			</cfquery>
			<!---- END::third job: set taxon_status to indicate whether we can make the name or not ---->

			<!---- fourth job: make any taxa that we can ---->

			<cfif debug is true>
				<br>fourth job: make any taxa that we can
			</cfif>
			<cfquery name="d" datasource="uam_god">
				select * from cf_worms_refreshed where taxon_status='valid' and status='taxon_not_in_arctos' and rownum < 100
			</cfquery>
			<cfif d.recordcount gt 0>
				<cfif debug is true>
					<br>making name
				</cfif>
				<cfloop query="d">
					<cftry>
						<cftransaction>
							<cfif debug is true>
								<br>making name
							</cfif>
							<!---- create the name ---->
							<cfquery name="mkname" datasource="uam_god">
								INSERT INTO taxon_name (TAXON_NAME_ID,SCIENTIFIC_NAME) VALUES (sq_TAXON_NAME_ID.nextval,'#name#')
							</cfquery>
							<!---- seed the classification ---->

							<cfset thisSourceID=CreateUUID()>

							<cfquery name="seedClassification" datasource="uam_god">
								insert into taxon_term (
									TAXON_NAME_ID,
									CLASSIFICATION_ID,
									TERM,
									TERM_TYPE,
									SOURCE,
									POSITION_IN_CLASSIFICATION
								) values (
									sq_TAXON_NAME_ID.currval,
									'#thisSourceID#',
									'#aphiaid#',
									'aphiaid',
									'WoRMS (via Arctos)',
									NULL
								)
							</cfquery>
							<!---- mark to be refreshed ---->
							<cfquery name="mkmd" datasource="uam_god">
								update cf_worms_refreshed set taxon_name_id=sq_TAXON_NAME_ID.currval,status='needs_refreshed' where key=#key#
							</cfquery>
						</cftransaction>
					<cfcatch>
						<cfdump var=#cfcatch#>
						<cfquery name="mkmd" datasource="uam_god">
							update cf_worms_refreshed set status='create_name_fail' where key=#key#
						</cfquery>
					</cfcatch>
					</cftry>
				</cfloop>
				<!--- if we did something here just abort so as not to push available resources. If we didn't we'll move on to the next job --->
				<cfabort>
			</cfif>

			<!---- fifth job: seed a classification for anything that we DO have taxa and DO NOT have any worms classification ---->

			<cfif debug is true>
				<br>fifth job: seed a classification for anything that we DO have taxa and DO NOT have any worms classification
			</cfif>
			<cfquery name="d" datasource="uam_god">
				select * from cf_worms_refreshed where taxon_name_id is not null and status='classification_not_found' and rownum < 200
			</cfquery>
			<cfif d.recordcount gt 0>
				<cfif debug is true>
					<br>making classifications
				</cfif>

				<cfloop query="d">
					<cfif debug is true>
						<br>#name#
					</cfif>

					<cfset thisSourceID=CreateUUID()>
					<cfquery name="seedClassification" datasource="uam_god">
						insert into taxon_term (
							TAXON_NAME_ID,
							CLASSIFICATION_ID,
							TERM,
							TERM_TYPE,
							SOURCE,
							POSITION_IN_CLASSIFICATION
						) values (
							#taxon_name_id#,
							'#thisSourceID#',
							'#aphiaid#',
							'aphiaid',
							'WoRMS (via Arctos)',
							NULL
						)
					</cfquery>
					<!---- mark to be refreshed ---->
					<cfquery name="mkmd" datasource="uam_god">
						update cf_worms_refreshed set status='needs_refreshed' where key=#key#
					</cfquery>
				</cfloop>
				<!--- if we did something here just abort so as not to push available resources. If we didn't we'll move on to the next job --->
				<cfabort>
			</cfif>

			<!---- END::fifth job: seed a classification for anything that we DO have taxa and DO NOT have any worms classification ---->


			<!---- sixth job: refresh stuff ---->

			<cfif debug is true>
				<br>sixth job: refresh stuff
			</cfif>

			<cfquery name="d" datasource="uam_god">
				select * from cf_worms_refreshed where status='needs_refreshed' and rownum<20
			</cfquery>
			<cfif d.recordcount gt 0>
				<cfset tc = CreateObject("component","component.taxonomy")>
				<cfloop query="d">
					<cfif debug is true>
						<br><a href="/name/#name#">#name#</a>
					</cfif>

					<cfset x=tc.updateWormsArctosByAphiaID(aphiaid,taxon_name_id)>
					<cfif isdefined("x.STATUS") and x.STATUS is "success">
						<cfquery name="mud" datasource="uam_god">
							update cf_worms_refreshed set status='refreshed' where key=#key#
						</cfquery>
					<cfelse>
						<cfquery name="mud" datasource="uam_god">
							update cf_worms_refreshed set status='refresh_fail' where key=#key#
						</cfquery>
						<cfif debug is true>
							<p>FAIL!!</p>
							<cfdump var=#x#>
						</cfif>

					</cfif>
					<!--- by request, one query per second at most ---->
					<cfset sleep(1000)>
				</cfloop>
				<!--- if we did something here just abort so as not to push available resources. If we didn't we'll move on to the next job --->
				<cfabort>
			</cfif>

			<!---- END::sixth job: refresh stuff ---->



			<!---- END::last run was today; we're current, see if there's other stuff to do ---->
		<cfelse>

			<cfif debug is true>
				<br>we're checking worms
			</cfif>
			<cfif rs.last_status is "204">
				<cfif debug is true>
					<br>last status was 204; increment the date and reset status
				</cfif>

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
			<cfif debug is true>
				<cfdump var=#theURL#>
			</cfif>

			<cfhttp result="ga" url="#theURL#" method="get"></cfhttp>
			<!----
			<cfdump var=#ga#>
			---->
			<cfif debug is true>
				<cfdump var=#ga#>
			</cfif>
			<cfif left(ga.Statuscode,3) is "200">
				<cfif debug is true>
					<br>found some stuff; going to process it below, do nothing here
				</cfif>

			<cfelseif left(ga.Statuscode,3) is "204">
				<cfif debug is true>
					<br>nothing left, update status
				</cfif>

				<cfquery name="irs" datasource="uam_god">
					update cf_worms_refresh_job set last_status='204'
				</cfquery>
				<cfabort>
			<cfelse>
				<cfif debug is true>
					<br>some sort of error
				</cfif>

				<cfquery name="irs" datasource="uam_god">
					update cf_worms_refresh_job set last_status='random error'
				</cfquery>
				<cfabort>
			</cfif>
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
					<cfif debug is true>
						wat??
						<cfdump var=#rec#>
					</cfif>
				</cfif>
			</cfloop>
			<cfquery name="irs" datasource="uam_god">
				update cf_worms_refresh_job set last_page='#o#'
			</cfquery>
		</cfif>
	</cfoutput>

	<!------------



</cfif>





<cfif action is "process_get_aid">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_worms_refreshed where status ='found_taxon_id' and taxon_name_id is not null and rownum < 200
		</cfquery>
		<cfloop query="d">
			<cfquery name="n" datasource="uam_god">
				select term from taxon_term where
					taxon_name_id=#d.taxon_name_id# and
					taxon_term.source='WoRMS (via Arctos)' and
					taxon_term.term_type='aphiaid'
			</cfquery>

			<cfif listfind(valuelist(n.term),'#aphiaid#')>
				<!--- found an exact match ---->
				<cfquery name="u" datasource="uam_god">
					update cf_worms_refreshed set status='found_classification' where key=#key#
				</cfquery>
			 <cfelseif n.recordcount gt 0 and len(n.term) gt 0>
			 	<!--- we have something, they have something, it's not the same ---->
				<cfquery name="u" datasource="uam_god">
					update cf_worms_refreshed set status='alternative_classification_found' where key=#key#
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


<cfif action is "set_taxon_status">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			update cf_worms_refreshed set taxon_status=isValidTaxonName(name) where status ='taxon_not_in_arctos' and taxon_status is null
		</cfquery>
	</cfoutput>

</cfif>

------------->