<!---

table to record where we've been; this can take a while to run since we can only get 50 records at a time
drop table cf_worms_refresh_job;
create table cf_worms_refresh_job (
	last_run_date date,
	last_status varchar2(255)
);
-- initial seed
insert into cf_worms_refresh_job(last_run_date,last_status) values (to_date('2018-12-20'),'new');

--->
<cfoutput>
	<cfquery name="rs" datasource="uam_god">
		select * from cf_worms_refresh_job
	</cfquery>
	<cfdump var=#rs#>
	<cfif rs.last_run_date eq dateformat(now(),"YYYY-MM-DD")>
		<br>last run was today; abort
		<cfabort>
	</cfif>
	<cfset thedate=dateformat(rs.last_run_date,"YYYY-MM-DD")>
	<cfset st=thedate & "T00%3A00%3A00%2B00%3A00">
	<cfset et=thedate & "T24%3A00%3A00%2B00%3A00">

	<cfset o=1>
	<cfset theURL="http://www.marinespecies.org/rest/AphiaRecordsByDate?startdate=#st#&enddate=#et#&marine_only=false&offset=#o#">
	<cfdump var=#theURL#>


</cfoutput>