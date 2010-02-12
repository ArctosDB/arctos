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
--->

<cfquery name="d" datasource="uam_god">
	select * from lichen
</cfquery>
<cfoutput>
	<table border>
		<tr>
			<td>tid</td>
			<td>rank</td>
			<td>sciname</td>
			<td>author</td>
			<td>source</td>
			<td>tidaccepted</td>
			<td>uppertaxonomy</td>
			<td>family</td>
			<td>parenttid</td>
		</tr>
		<cfloop query="d">
			<tr>
				<td>#tid#</td>
				<td>#rank#</td>
				<td>#sciname#</td>
				<td>#author#</td>
				<td>#source#</td>
				<td>#tidaccepted#</td>
				<td>#uppertaxonomy#</td>
				<td>#family#</td>
				<td>#parenttid#</td>
			</tr>
		</cfloop>
	</table>
	
</cfoutput>

