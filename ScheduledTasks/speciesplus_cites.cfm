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

	create table temp_speciesplus (concept_id number, name varchar2(255));


	-- keep track of iteration
	create table temp_sp_iteration (lastpage number);
	insert into temp_sp_iteration(lastpage) values (0);



--->
<cfoutput>
	<cfquery name="pg" datasource='uam_god'>
		select lastpage+1 nextpage from temp_sp_iteration
	</cfquery>
	<cfquery name="auth" datasource='uam_god'>
		select SPECIESPLUS_TOKEN from cf_global_settings
	</cfquery>
	<cfhttp result="ga" url="https://api.speciesplus.net/api/v1/taxon_concepts?page=#pg.nextpage#&per_page=50" method="get">
		<cfhttpparam type = "header" name = "X-Authentication-Token" value = "#auth.SPECIESPLUS_TOKEN#">
	</cfhttp>
	<cfdump var=#ga#>
	<cfif ga.statusCode is "200 OK" and len(ga.filecontent) gt 0 and isjson(ga.filecontent)>
		<cfset rslt=DeserializeJSON(ga.filecontent)>
		<cfdump var=#rslt#>
	<cfelse>
		<cfthrow message='speciesplus json parse failure'>
	</cfif>
</cfoutput>