<!--- deal with the f-in retarded rankid 
alter table lichen add rank varchar2(255);

update lichen set rank='Genus' where rankid='180';
update lichen set rank='Species' where rankid='220';
update lichen set rank='Form' where rankid='260';
update lichen set rank='Order' where rankid='100';
update lichen set rank='Family' where rankid='140';
update lichen set rank='Subspecies' where rankid='230';
update lichen set rank='Variety' where rankid='240';
update lichen set rank='Kingdom' where rankid='10';
update lichen set rank='Class' where rankid='60';
update lichen set rank='Division' where rankid='30';

subspecific ranks are an inintelligible mess - kill em

update lichen set rank='Subspecies' where rank in (
	'Form',
	'Variety'
	);

useless duplicates

begin
 for r in (select sciname from lichen having count(*) > 1 group by sciname) loop
	delete from lichen where sciname=r.sciname and rownum=1;
	end loop;
	end;
	/
	
--->
	<script src="/includes/sorttable.js"></script>

<cfquery name="d" datasource="uam_god">
	select * from lichen
</cfquery>
<cfoutput>
	<table border id="t" class="sortable">
		<tr>
			<td>tid</td>
			<td>parenttid</td>
			<td>tidaccepted</td>
			<td>full</td>
			<td>rank</td>
			<td>sciname</td>
			<td>author</td>
			<td>source</td>
			<td>uppertaxonomy</td>
			<td>family</td>
		</tr>
		<cfloop query="d">
			<cfset forever=1>
			<cfset l="">
			<cfif len(parenttid) gt 0>
				<cfloop condition="forever=1">
					<cfquery name="p" datasource="query">
						select parenttid,sciname from d where tid=#parenttid#
					</cfquery>
					<cfif len(p.parenttid) eq 0>
						<cfset forever=0>
					<cfelse>
						<cfset l=listprepend(l,p.sciname)>
					</cfif>
				</cfloop>
			</cfif>
			<tr>
				<td>#tid#</td>
				<td>#parenttid#</td>
				<td>#tidaccepted#</td>
				<td>#l#</td>
				<td>#rank#</td>
				<td>#sciname#</td>
				<td>#author#</td>
				<td>#source#</td>
				<td>#uppertaxonomy#</td>
				<td>#family#</td>
			</tr>
		</cfloop>
	</table>
	
</cfoutput>

