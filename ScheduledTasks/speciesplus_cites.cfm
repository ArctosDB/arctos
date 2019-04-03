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
	<cfif ga.statusCode is "200 OK" and len(ga.filecontent) gt 0 and isjson(ga.filecontent)>
		<cfset rslt=DeserializeJSON(ga.filecontent)>
		<cfdump var=#rslt#>
		<cfloop from="1" to ="#arraylen(rslt.taxon_concepts)#" index="i">
			<cfset thisConcept=rslt.taxon_concepts[i]>
			<p>#i#</p>
			<cfdump var=#thisConcept#>

			<cfset thisID=thisConcept.id>
			<cfset thisName=thisConcept.full_name>
			<br>thisID=#thisID#
			<br>thisName=#thisName#
			<cfloop from="1" to ="#arraylen(thisConcept.cites_listings)#" index="cli">
				<cfset thisCitesAppendix=thisConcept.cites_listings[cli].appendix>
				<br>thisCitesAppendix=#thisCitesAppendix#
			</cfloop>

			<cfloop from="1" to ="#arraylen(thisConcept.common_names)#" index="cni">
				<cfset thisCommonName=thisConcept.common_names[cni].name>
				<br>thisCommonName=#thisCommonName#
			</cfloop>


			<cfloop collection="#thisConcept.higher_taxa#" item="key">
				<cftry>
			    <br>higher_taxa:: #key#: #thisConcept.higher_taxa[key]#<br />
			    <cfcatch><br>fail....</cfcatch>
			    </cftry>
			</cfloop>




		</cfloop>
	<cfelse>
		<cfthrow message='speciesplus json parse failure'>
	</cfif>
</cfoutput>