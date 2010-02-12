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

alter table lichen add temp number;
update lichen set temp=tid;
alter table lichen drop column tid;
alter table lichen rename column temp to tid;



alter table lichen add temp number;
update lichen set temp=parenttid;
alter table lichen drop column parenttid;
alter table lichen rename column temp to parenttid;


alter table lichen modify tid number;

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
			<cfquery name="r" datasource="uam_god">
				SELECT sciname
				FROM lichen
				CONNECT BY tid = PRIOR parenttid
				 START WITH tid=#tid#
			</cfquery>
			<tr>
				<td>#tid#</td>
				<td>#parenttid#</td>
				<td>#tidaccepted#</td>
				<td><cfdump var=#r#></td>
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

