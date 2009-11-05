<!---
create table bad_taxonomy (
	taxon_name_id number,
	chkDate date default sysdate,
	scientific_name varchar2(255) not null,
	species varchar2(255),
	problem varchar2(255),
	probcode varchar2(20),
	used_in_id number
);

--->
<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfif action is "nothing">
	<br><a href="bad_taxonomy.cfm?action=findBadSpecies">findBadSpecies</a>
	<br><a href="bad_taxonomy.cfm?action=showBadSpecies">showBadSpecies</a>
	<br><a href="bad_taxonomy.cfm?action=setUsedInIds">setUsedInIds</a>
	<br><a href="bad_taxonomy.cfm?action=resetAll">resetAll</a>

</cfif>
<cfif action is "resetAll">
	<cfquery name="d" datasource="uam_god">
		delete from bad_taxonomy
	</cfquery>
</cfif>
<cfif action is "setUsedInIds">
	<cfquery name="d" datasource="uam_god">
		update bad_taxonomy set used_in_id=1 where 
		taxon_name_id in (select taxon_name_id from identification_taxonomy)
	</cfquery>
</cfif>
<cfif action is "showBadSpecies">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from bad_taxonomy where probcode='badspecies'
		</cfquery>
		Everything on this page does not match the rules:
		<ol>
			<li>species must start with #chr(215)# or a lowercase a-z character</li>
			<li>species must contain only #chr(215)#, lowercase a-z characters, and -</li>
			<li>species must end with a lowercase a-z character</li>
		</ol>
		<table border id="t" class="sortable">
			<tr>
				<th>edit</th>
				<th>name</th>
				<th>species</th>
				<th>used?</th>
			</tr>
			<cfloop query="d">
				<tr>
					<td><a href="/Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#">edit</a></td>
					<td>
						<a href="/name/#scientific_name#">#scientific_name#</a>
					</td>
					<td>#species#</td>
					<td>#used_in_id#</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<cfif action is "findBadSpecies">
	<cfquery name="u" datasource="uam_god">
		delete from bad_taxonomy where probcode='badspecies'
	</cfquery>
	<cfquery name="i" datasource="uam_god">
		insert into bad_taxonomy (
			taxon_name_id,
			scientific_name,
			species,
			probcode,
			problem
		) (
			select
				taxon_name_id,
				scientific_name,
				species,
				'badspecies',
				'species no match: starts/ends with lowercase, contains only lowercase and dash)'
			from taxonomy where
				not(regexp_like(replace(SPECIES,CHR (215 USING NCHAR_CS)),'^[a-z][a-z-]*[a-z]$'))
		)
	</cfquery>
	spiffy. Use your back button to view badspecies
</cfif>
<cfinclude template="/includes/_footer.cfm">
