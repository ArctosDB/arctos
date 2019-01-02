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


alter table cf_worms_refreshed add taxon_status varchar2(255);


--->
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
	<cfparam name="debug" default="false">
	<cfoutput>
		<cfquery name="rs" datasource="uam_god">
			select * from cf_worms_refresh_job
		</cfquery>
		<cfdump var=#rs#>
		<cfif rs.last_run_date eq dateformat(now(),"YYYY-MM-DD")>
			<!---- last run was today; we're current, see if there's other stuff to do ---->
			<br>last run was today; we're current, see if there's other stuff to do
			<!---- first job: see if there's anything that's just been inserted, and find a taxon_name_id for it if so ---->
			<br>first job: see if there's anything that's just been inserted, and find a taxon_name_id for it if so
			<cfquery name="d" datasource="uam_god">
				select * from cf_worms_refreshed where status is null and rownum < 1000
			</cfquery>
			<cfif d.recordcount gt 0>
				<br>going....
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
			<br>second job: for anything that we just got taxon_name_id, see if we have a matching classification
			<cfif d.recordcount gt 0>
				<br>going....
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
							update cf_worms_refreshed set status='needs_refreshed' where key=#key#
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
				<!--- if we did something here just abort so as not to push available resources. If we didn't we'll move on to the next job --->
				<cfabort>
			</cfif>
			<!---- END::second job: for anything that we just got taxon_name_id, see if we have a matching classification ---->

			<!---- third job: set taxon_status to indicate whether we can make the name or not ---->
			<br>third job: set taxon_status to indicate whether we can make the name or not
			<cfquery name="d" datasource="uam_god">
				update cf_worms_refreshed set taxon_status=isValidTaxonName(name) where status ='taxon_not_in_arctos' and taxon_status is null
			</cfquery>
			<!---- END::third job: set taxon_status to indicate whether we can make the name or not ---->

			<!---- fourth job: make any taxa that we can ---->
			<br>fourth job: make any taxa that we can
			<cfquery name="d" datasource="uam_god">
				select * from cf_worms_refreshed where taxon_status='valid' and status='taxon_not_in_arctos' and rownum < 20
			</cfquery>
			<cfif d.recordcount gt 0>
				<br>making name
				<cfloop query="d">
					<cftry>
						<cftransaction>
							<br>making #name#
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
								update cf_worms_refreshed set status='needs_refreshed' where key=#key#
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







			<!---- END::last run was today; we're current, see if there's other stuff to do ---->
		<cfelse>
			<br>we're checking worms
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
		</cfif>
	</cfoutput>
</cfif>


<!------------



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