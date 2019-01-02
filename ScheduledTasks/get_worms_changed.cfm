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

--->
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
				insert into cf_worms_refreshed (aphiaid,name,changed_date) values ('#rec.AphiaID#','#rec.scientificname#',sysdate)
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