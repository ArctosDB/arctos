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
	
	
 curl -i "https://api.speciesplus.net/api/v1/taxon_concepts?page=&per_page50" -H "X-Authentication-Token:7rPCCN0EuIlD13QD2YJ6QAtt" 

--->
<cfoutput>
	<cfquery name="pg" datasource='uam_god'>
		select lastpage+1 nextpage from temp_sp_iteration
	</cfquery>
	
</cfoutput>