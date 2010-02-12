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

--subspecific ranks are an inintelligible mess - kill em

update lichen set rank='Subspecies' where rank in (
	'Form',
	'Variety'
	);

--useless duplicates

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



alter table lichen add ht varchar2(4000);


alter table lichen add g varchar2(255);
alter table lichen add sp varchar2(255);
alter table lichen add ssp varchar2(255);
alter table lichen add irnk varchar2(255);

alter table lichen add wtf varchar2(255);


alter table lichen add pOrder varchar2(255);
alter table lichen add nFamily varchar2(255);
alter table lichen add Kingdom varchar2(255);
alter table lichen add Class varchar2(255);
alter table lichen add Division varchar2(255);

update lichen set rank='porder' where rank='Order';
update lichen set rank='nFamily' where rank='Family';

--->
	<script src="/includes/sorttable.js"></script>
<cfoutput>
	




<!----


first step
<cfquery name="d" datasource="uam_god">
	select * from lichen where rank='Subspecies'
</cfquery>
<cfloop query="d">
	<cftransaction>
		<cfif listlen(sciname," ") is 4>
			<cfset gv=listgetat(sciname,1," ")>
			<cfset sv=listgetat(sciname,2," ")>
			<cfset irv=listgetat(sciname,3," ")>
			<cfset ssv=listgetat(sciname,4," ")>
			<cfquery name="u" datasource="uam_god">
				update lichen set
				g='#gv#',
				sp='#sv#',
				ssp='#ssv#',
				irnk='#irv#'
				where
				tid=#tid#
			</cfquery>
		<cfelse>
			<cfquery name="u" datasource="uam_god">
				update lichen set wtf='r=ssp + #listlen(sciname)# part name' where tid=#tid#
			</cfquery>
		</cfif>
	</cftransaction>
</cfloop>

3rd step:

update lichen set g=sciname where rank='Genus' and wtf is null;








2nd step
<cfquery name="d" datasource="uam_god">
	select * from lichen where rank='Species'
</cfquery>
<cfloop query="d">
	<cftransaction>
		<cfif listlen(sciname," ") is 2>
			<cfset cr=replace(sciname," ",",","all")>
			<cfset gv=listgetat(cr,1,",")>
			<cfset sv=listgetat(cr,2,",")>
			<cfquery name="u" datasource="uam_god">
				update lichen set
				g='#gv#',
				sp='#sv#'
				where
				tid=#tid#
			</cfquery>
			<br>sciname:#sciname#
			<br>cr:#cr#
			<br>gv:#gv#
			<br>sv:#sv#
			<hr>
		<cfelse>
			<cfquery name="u" datasource="uam_god">
				update lichen set wtf='r=sp + #listlen(sciname)# part name' where tid=#tid#
			</cfquery>
		</cfif>
	</cftransaction>
</cfloop>



step4:

declare s varchar2(4000);

begin
for r in (select tid from lichen) loop

	SELECT 
		max(SYS_CONNECT_BY_PATH(rank || ':' || sciname,'|')) into s
FROM lichen
CONNECT BY tid = PRIOR parenttid
START WITH tid= r.tid;

update lichen set ht=s where tid=r.tid;

end loop;
end;
/


---->



<cfquery name="d" datasource="uam_god">
	select * from lichen
</cfquery>
	<table border id="t" class="sortable">
		<tr>
			
			<td>wtf</td>
			<td>tid</td>
			<td>parenttid</td>
			<td>tidaccepted</td>
			<td>g</td>
			<td>sp</td>
			<td>ir</td>
			<td>ssp</td>
			<td>ht</td>
			<td>rank</td>
			<td>sciname</td>
			<td>author</td>
			<td>source</td>
			<td>uppertaxonomy</td>
			<td>family</td>
		</tr>
		<cfloop query="d">
			<!---
			<cftransaction>
			<cfquery name="r" datasource="uam_god">
				SELECT sciname || '|' || rank t
				FROM lichen
				CONNECT BY tid = PRIOR parenttid
				 START WITH tid=#tid#
			</cfquery>
			
			<cfset h=valuelist(r.t)>
			<cfquery name="u" datasource="uam_god">
				update lichen set ht='#h#' where tid=#tid#
			</cfquery>
			</cftransaction>
			--->
			
			
			<tr>
				<td>#wtf#</td>
				<td>#tid#</td>
				<td>#parenttid#</td>
				<td>#tidaccepted#</td>
				<td>#g#</td>
				<td>#sp#</td>
				<td>#irnk#</td>
				<td>#ssp#</td>
				<td>#ht#</td>
				<td>#rank#</td>
				<td>#sciname#</td>
				<td>#author#</td>
				<td>#source#</td>
				<td>#uppertaxonomy#</td>
				<td>#family#</td>
			</tr>
			
		</cfloop>
	</table>
	--->
</cfoutput>

