<!----
	drop table cf_speciesplus_status;

	create table cf_speciesplus_status (
		last_date date,
		number_recs number,
		lastpage number
	);
---------->
<cfoutput>
	<!--- this should be a number that we can process in a minute ---->
	<cfset pgsize="25">
	<cfquery name="auth" datasource='uam_god'  cachedwithin="#createtimespan(0,0,60,0)#">
		select SPECIESPLUS_TOKEN from cf_global_settings
	</cfquery>
	<cfset today=dateformat(now(),'YYYY-MM-DD')>
	<cfset y=DateAdd("d", -1, now())>
	<cfset yesterday=dateformat(y,'YYYY-MM-DD')>
	<cfquery name="s" datasource='uam_god'>
		select * from cf_speciesplus_status
	</cfquery>
	<cfif dateformat(s.last_date,'YYYY-MM-DD') neq today>
		<!---- we have not been here today---->
		<cfhttp result="ga" url="https://api.speciesplus.net/api/v1/taxon_concepts?updated_since=#yesterday#&per_page=1&page=1" method="get">
			<cfhttpparam type = "header" name = "X-Authentication-Token" value = "#auth.SPECIESPLUS_TOKEN#">
		</cfhttp>
		<cfif ga.statusCode is "200 OK" and len(ga.filecontent) gt 0 and isjson(ga.filecontent)>
			<cfset rslt=DeserializeJSON(ga.filecontent)>
			<cfset ttlrecs=rslt.pagination.total_entries>
			<cfquery name="flush" datasource='uam_god'>
				delete from cf_speciesplus_status
			</cfquery>
			<cfquery name="seed" datasource='uam_god'>
				insert into cf_speciesplus_status (last_date,number_recs,lastpage) values (sysdate,#ttlrecs#,0)
			</cfquery>
			<!--- just abort this run --->
			<cfabort>
		</cfif>
	</cfif>
	<!--- see if there's anything we need to process ---->

	<cfif (pgsize * s.lastpage) gte s.number_recs>
		<!---already processed everything; abort--->
		<cfabort>
	</cfif>

	<!---made it here we can do stuff---->
	<cfset tc = CreateObject("component","component.taxonomy")>
	<cfset nextpage=s.lastpage+1>
	<cfhttp result="ga" url="https://api.speciesplus.net/api/v1/taxon_concepts?updated_since=#yesterday#&per_page=#pgsize#&page=#nextpage#" method="get">
		<cfhttpparam type = "header" name = "X-Authentication-Token" value = "#auth.SPECIESPLUS_TOKEN#">
	</cfhttp>
	<cfif ga.statusCode is "200 OK" and len(ga.filecontent) gt 0 and isjson(ga.filecontent)>
		<cfset rslt=DeserializeJSON(ga.filecontent)>
		<!--- loop over results --->
		<cfloop from="1" to ="#arraylen(rslt.taxon_concepts)#" index="i">
			<cfset tid="">
			<cfset thisConcept=rslt.taxon_concepts[i]>
			<cfset thisName=thisConcept.full_name>
			<br>thisName:#thisName#
			<!--- do we already have it? --->
			<cfquery name="ag1" datasource='uam_god'>
				select taxon_name_id from taxon_name where scientific_name='#thisName#'
			</cfquery>
			<cfif len(ag1.taxon_name_id) lt 1>
				<br>=============================need to make=====================
				<cfquery name="vtn" datasource='uam_god'>
					select isValidTaxonName('#thisName#') v from dual
				</cfquery>
				<cfif vtn.v is 'valid'>
					<br>is valid can make
					<cfquery name="mknm" datasource='uam_god'>
						insert into taxon_name(taxon_name_id,scientific_name) values (sq_taxon_name_id.nextval,'#thisName#')
					</cfquery>
					<cfquery name="ag1" datasource='uam_god'>
						select taxon_name_id from taxon_name where scientific_name='#thisName#'
					</cfquery>
					<cfset tid=ag1.taxon_name_id>
				</cfif>
			<cfelse>
				<cfset tid=ag1.taxon_name_id>
			</cfif>
			<cfif len(tid) gt 0>
				<cfset x=tc.updateArctosLegalClassData_guts(tid="#tid#",thisConcept="#thisConcept#",debug="false")>
			</cfif>
		</cfloop>
		<cfquery name="incr" datasource='uam_god'>
			update cf_speciesplus_status set lastpage=#nextpage#
		</cfquery>
	<cfelse>
		fail
		<cfthrow message="speciesplus_cites fail">
	</cfif>
</cfoutput>

