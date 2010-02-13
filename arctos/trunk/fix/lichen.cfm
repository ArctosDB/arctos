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

alter table lichen add dht varchar2(4000);



------------ for loading

insert into cttaxonomic_authority (SOURCE_AUTHORITY) values ('USDA');
update lichen set source='USDA' where source='USDA PLANTS DB';
insert into cttaxonomic_authority (SOURCE_AUTHORITY) values ('ASU Herbarium');
update lichen set source='ASU Herbarium' where source='ASU Lichens';
update lichen set source='ASU Herbarium' where source='ASU Lichen Herbarium';
insert into cttaxonomic_authority (SOURCE_AUTHORITY) values ('Ted Esslinger');
insert into cttaxonomic_authority (SOURCE_AUTHORITY) values ('Tom Nash');
update lichen set source='Tom Nash' where source is null;


alter table lichen add ifa varchar2(255);
update lichen set ifa=AUTHOR,author=null where ssp is not null;
update lichen set 
	author=(select author from lichen p where p.g=lichen.g and p.sp=lichen.sp and p.ssp is null) where ssp is not null; 


update lichen set nfamily = null where nfamily='Uncertain Lichen Family';

select g,sp,ssp from lichen where genus like '% %';
-- somehow missed some split genera
update lichen set 
g=SUBSTR(g, 1  ,INSTR(g, ' ', 1, 1)-1),
sp=SUBSTR(g, INSTR(g,' ', 1, 1)+1)
where g like '% %';


-- nonprinting
update lichen set g='Vermilacinia' where g like 'Vermilacinia%' and g != 'Vermilacinia';
update lichen set irnk='forma' where irnk='f.';
update lichen set ssp='hirta' where ssp='Hirta';
update lichen set sp='tornoensis' where sp like 'torno_nsis%';

uam> select count(*) from taxonomy;

  COUNT(*)
----------
   1530603

Elapsed: 00:00:01.56
uam> select max(taxon_name_id) from taxonomy;

MAX(TAXON_NAME_ID)
------------------
	  10030411







declare n number :=0;
begin
for r in (select * from lichen) loop
BEGIN
	 insert into taxonomy(
	 	PHYLCLASS,
	 	PHYLORDER,
	 	FAMILY,
	 	GENUS	,
	 	SPECIES,
	 	SUBSPECIES,
	 	VALID_CATALOG_TERM_FG,
	 	SOURCE_AUTHORITY,
	 	AUTHOR_TEXT,
	 	INFRASPECIFIC_RANK,
	 	PHYLUM,
	 	KINGDOM,
	 	NOMENCLATURAL_CODE,
	 	INFRASPECIFIC_AUTHOR
	 ) VALUES (
	 	 r.CLASS,
	 	 r.PORDER,
	 	 r.NFAMILY,
	 	 r.G,
	 	 r.SP,
	 	 r.SSP,
	 	 1,
	 	 r.source,
	 	 r.author,
	 	 r.IRNK,
	 	 r.DIVISION,
	 	 r.KINGDOM,
	 	 'ICBN',
	 	 r.ifa
	 	);
	 	exception when DUP_VAL_ON_INDEX then
	 		dbms_output.put_line('already got a ' || r.ht);
	 		n:=n+1;
	 	end;
	 end loop;
	 dbms_output.put_line('skipped ' || n || ' existing records');
end;
/

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





<cfquery name="d" datasource="uam_god">
	select * from lichen where dht is null
</cfquery>

<cfloop query="d">
	<cftransaction>
		<cfloop list="#ht#" index="i" delimiters="|">
			<cfset rnk=listgetat(i,1,":")>
			<cfset trm=listgetat(i,2,":")>
			<cfif rnk is not "Subspecies" and
				rnk is not "Species" and
				rnk is not "Genus">
				<cfquery name="u" datasource="uam_god">
					update lichen set #rnk#='#trm#'
					where tid=#tid#
				</cfquery>
		
			</cfif>
		</cfloop>
		<cfquery name="u" datasource="uam_god">
			update lichen set dht=1
			where tid=#tid#
		</cfquery>
	</cftransaction>
</cfloop>

---->
<cfquery name="d" datasource="uam_god">
	select * from lichen
</cfquery>


	<table border id="t" class="sortable">
		<tr>
			<!---	
			<td>tid</td>
			<td>parenttid</td>
			<td>tidaccepted</td>
			--->
			<td>genus</td>
			<td>species</td>
			<td>infRank</td>
			<td>subsp</td>
			<td>flat_family</td>
			<td>nFamily</td>
			<td>pOrder</td>
			<td>Kingdom</td>
			<td>Class</td>
			<td>Division</td>
			<td>author</td>
			<td>source</td>
			<td>term</td>
			<td>uppertaxonomy</td>
		</tr>
		<cfloop query="d">
			<tr>
				<!---
				<td>#tid#</td>
				<td>#parenttid#</td>
				<td>#tidaccepted#</td>
				--->
				<td>#g#</td>
				<td>#sp#</td>
				<td>#irnk#</td>
				<td>#ssp#</td>
				<td>#family#</td>
				<td>#nFamily#</td>
				<td>#pOrder#</td>
				<td>#Kingdom#</td>
				<td>#Class#</td>
				<td>#Division#</td>
				<td>#author#</td>
				<td>#source#</td>
				<td>#sciname#</td>
				<td>#uppertaxonomy#</td>
			</tr>		
		</cfloop>
	</table>
</cfoutput>

