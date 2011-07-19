<!----create table taxupfail (
    genus varchar2(255),
    fail varchar2(255)
);
create index temp_taxup_g on taxupfail(genus) tablespace uam_idx_1;

alter table taxupfail add family varchar2(255);
create index temp_taxup_f on taxupfail(family) tablespace uam_idx_1;

alter table taxupfail add phylorder varchar2(255);
update taxupfail set phylorder=' ';
create index temp_taxup_po on taxupfail(phylorder) tablespace uam_idx_1;


alter table taxupfail add phylum varchar2(255);
update taxupfail set phylum=' ';
create index temp_taxup_ph on taxupfail(phylum) tablespace uam_idx_1;




select phylum from taxonomy where phylum is not null and kingdom is null and phylum not in (select phylum from taxupfail) group by phylum;






drop procedure fix_tax_by_ph;




create or replace procedure fix_tax_by_ph is
    c number;
begin
    for r in (select phylum from taxonomy where phylum is not null and kingdom is null and rownum < 10 and phylum not in (select phylum from taxupfail) group by phylum) loop
        dbms_output.put_line('------------------------------------------------');
        dbms_output.put_line(r.phylum);
        select count(distinct(kingdom)) into c from taxonomy where kingdom is not null and phylum=r.phylum;
        --dbms_output.put_line(c);
        if c=1 then
        dbms_output.put_line('update happy  ' || r.phylum);

            update taxonomy set kingdom= (select distinct(kingdom) from taxonomy where kingdom is not null and phylum=r.phylum) where phylum= r.phylum and kingdom is null;
        else
            insert into taxupfail (phylum,fail) values (r.phylum,'found ' || c || ' phylum');
            dbms_output.put_line('found ' || c || ' kingdom for  ' || r.phylum);

        end if;
    end loop;
end;
/





select phylorder from taxonomy where phylorder is not null and phylum is null and phylorder not in (select phylorder from taxupfail) group by phylorder;


create or replace procedure fix_tax_by_ord is
    c number;
begin
    for r in (select phylorder from taxonomy where phylorder is not null and phylum is null and rownum < 10 and phylorder not in (select phylorder from taxupfail) group by phylorder) loop
        dbms_output.put_line('------------------------------------------------');
        dbms_output.put_line(r.phylorder);
        select count(distinct(phylum)) into c from taxonomy where phylum is not null and phylorder=r.phylorder;
        --dbms_output.put_line(c);
        if c=1 then
        dbms_output.put_line('update happy  ' || r.phylorder);

            update taxonomy set phylum= (select distinct(phylum) from taxonomy where phylum is not null and phylorder=r.phylorder) where phylorder= r.phylorder and phylum is null;
        else
            insert into taxupfail (phylorder,fail) values (r.phylorder,'found ' || c || ' phylorder');
            dbms_output.put_line('found ' || c || ' order for  ' || r.phylorder);

        end if;
    end loop;
end;
/


exec DBMS_SCHEDULER.DROP_JOB (JOB_NAME => 'j_fix_tax_by_ord', FORCE => TRUE);

drop procedure fix_tax_by_ord;




exec DBMS_SCHEDULER.DROP_JOB (JOB_NAME => 'j_fix_tax_by_genus', FORCE => TRUE);
exec DBMS_SCHEDULER.DROP_JOB (JOB_NAME => 'j_fix_tax_by_fam', FORCE => TRUE);
drop procedure fix_tax_by_genus;
drop procedure fix_tax_by_fam;


BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'j_fix_tax_by_ord',
    job_type           =>  'STORED_PROCEDURE',
    job_action         =>  'fix_tax_by_ord',
    start_date         =>  SYSTIMESTAMP,
    repeat_interval    =>  'freq=minutely; interval=2',
    enabled            =>  TRUE,
    end_date           =>  NULL,
    comments           =>  'taxonomy gap filler-inner');
END;
/








create or replace procedure fix_tax_by_fam is
    c number;
begin
    for r in (select family from taxonomy where family is not null and phylorder is null and rownum < 10 and family not in (select family from taxupfail) group by family) loop
        dbms_output.put_line('------------------------------------------------');
        dbms_output.put_line(r.family);
        select count(distinct(phylorder)) into c from taxonomy where phylorder is not null and family=r.family;
        --dbms_output.put_line(c);
        if c=1 then
        dbms_output.put_line('update happy  ' || r.family);

            update taxonomy set phylorder= (select distinct(phylorder) from taxonomy where phylorder is not null and family=r.family) where family= r.family and phylorder is null;
        else
            insert into taxupfail (family,fail) values (r.family,'found ' || c || ' families');
            dbms_output.put_line('found ' || c || ' order for  ' || r.family);

        end if;
    end loop;
end;
/






BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'j_fix_tax_by_fam',
    job_type           =>  'STORED_PROCEDURE',
    job_action         =>  'fix_tax_by_fam',
    start_date         =>  SYSTIMESTAMP,
    repeat_interval    =>  'freq=minutely; interval=2',
    enabled            =>  TRUE,
    end_date           =>  NULL,
    comments           =>  'taxonomy gap filler-inner');
END;
/

update taxonomy set phylorder= (select distinct(phylorder) from taxonomy where phylorder is not null and family=r.family) where family= r.family and phylorder is null;


select family from taxonomy where family is not null and phylorder is null and family not in (select family from taxupfail) group by family




create or replace procedure fix_tax_by_fam is
    c number;
begin
    for r in (select family from taxonomy where family is not null and phylorder is null and rownum < 10 and family not in (select family from taxupfail) group by family) loop
        dbms_output.put_line('------------------------------------------------');
        dbms_output.put_line(r.family);
        select count(distinct(phylorder)) into c from taxonomy where phylorder is not null and family=r.family;
        --dbms_output.put_line(c);
        if c=1 then
        dbms_output.put_line('update happy  ' || r.family);

            update taxonomy set phylorder= (select distinct(phylorder) from taxonomy where phylorder is not null and family=r.family) where family= r.family and phylorder is null;
        else
            insert into taxupfail (family,fail) values (r.family,'found ' || c || ' families');
            dbms_output.put_line('found ' || c || ' order for  ' || r.family);

        end if;
    end loop;
end;
/






create or replace procedure fix_tax_by_genus is
    c number;
begin
    for r in (select genus from taxonomy where genus is not null and family is null and rownum < 101 and genus not in (select genus from taxupfail) group by genus) loop
        dbms_output.put_line('------------------------------------------------');
        dbms_output.put_line(r.genus);
        select count(distinct(family)) into c from taxonomy where family is not null and genus=r.genus;
        --dbms_output.put_line(c);
        if c=1 then
            update taxonomy set family= (select distinct(family) from taxonomy where family is not null and genus=r.genus) where genus= r.genus and family is null;
        else
            insert into taxupfail (genus,fail) values (r.genus,'found ' || c || ' families');
            dbms_output.put_line('found ' || c || ' families for  ' || r.genus);

        end if;
    end loop;
end;
/
---->
<cfinclude template="/includes/_header.cfm">
<cfset title="Taxonomy is still a mess">
<cfif action is "nothing">
	Taxonomy gaps that cannot be scripted in.
	<br>
	<a href="TaxonomyScriptGap.cfm?action=duGenus">genus with !=1 family</a>
	<br>
	<a href="TaxonomyScriptGap.cfm?action=duFam">family with !=1 order</a>
	<br>
	<a href="TaxonomyScriptGap.cfm?action=duOrd">order with !=1 phylum</a>
	<br>
	<a href="TaxonomyScriptGap.cfm?action=duPhy">phylum with !=1 kingdom</a>
		
</cfif>

<cfif action is 'duPhy'>
	
	<br>Letter-links are first letter of phylum
	<cfoutput>
		<cfif not isdefined("l")>
			<cfset l='A'>
		</cfif>
	    <cfloop index="strLetter" list="A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z" delimiters=",">
	     <a href="TaxonomyScriptGap.cfm?action=#action#&l=#strLetter#">#strLetter#</a>-     
	    </cfloop>	
		<cfquery name="d" datasource="uam_god">
				select
					taxonomy.phylum,
					taxonomy.kingdom,
					taxupfail.fail
				from
					taxonomy,
					taxupfail
				where
					taxonomy.phylum=taxupfail.phylum and
					taxupfail.phylum like '#l#%'
				group by
					taxonomy.phylum,
					taxonomy.kingdom,
					taxupfail.fail
				order by
					taxonomy.phylum
		</cfquery>
		<cfquery name="g" dbtype="query">
			select phylum,fail from d group by phylum,fail order by phylum
		</cfquery>
		<table border>
			<tr>
				<th>phylum</th>
				<th>##</th>
				<th>kingdom</th>
			</tr>
			<cfloop query="g">
				<cfquery name="f" dbtype="query">
					select kingdom,count(*) n from d where phylum='#g.phylum#' group by kingdom order by kingdom
				</cfquery>
				<tr>
					<td>
						<a href="/TaxonomyResults.cfm?phylum==#phylum#">#phylum#</a>
					</td>
					<td>#f.n#</td>
					<td>
						
						<cfloop query="f">
							<div>
								<a href="/TaxonomyResults.cfm?kingdom==#kingdom#&phylum==#g.phylum#">#kingdom#</a>
							</div>
						</cfloop>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<cfif action is 'duOrd'>
	
	<br>Letter-links are first letter of order
	<cfoutput>
		<cfif not isdefined("l")>
			<cfset l='A'>
		</cfif>
	    <cfloop index="strLetter" list="A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z" delimiters=",">
	     <a href="TaxonomyScriptGap.cfm?action=#action#&l=#strLetter#">#strLetter#</a>-     
	    </cfloop>	
		<cfquery name="d" datasource="uam_god">
				select
					taxonomy.phylorder,
					taxonomy.phylum,
					taxupfail.fail
				from
					taxonomy,
					taxupfail
				where
					taxonomy.phylorder=taxupfail.phylorder and
					taxupfail.phylorder like '#l#%'
				order by
					taxonomy.phylorder
		</cfquery>
		<cfquery name="g" dbtype="query">
			select phylorder,fail from d group by phylorder,fail order by phylorder
		</cfquery>
		<table border>
			<tr>
				<th>phylorder</th>
				<th>##</th>
				<th>phylum</th>
			</tr>
			<cfloop query="g">
				<cfquery name="f" dbtype="query">
					select phylum,count(*) n from d where phylorder='#phylorder#' group by phylum order by phylum
				</cfquery>
				<tr>
					<td>
						<a href="/TaxonomyResults.cfm?phylorder==#phylorder#">#phylorder#</a>
					</td>
					<td>#f.n#</td>
					<td>
						
						<cfloop query="f">
							<div>
								<a href="/TaxonomyResults.cfm?phylorder==#g.phylorder#&phylum=#phylum#">#phylum#</a>
							</div>
						</cfloop>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<cfif action is 'duFam'>
	
	<br>Letter-links are first letter of family
	<cfoutput>
		<cfif not isdefined("l")>
			<cfset l='A'>
		</cfif>
	    <cfloop index="strLetter" list="A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z" delimiters=",">
	     <a href="TaxonomyScriptGap.cfm?action=#action#&l=#strLetter#">#strLetter#</a>-     
	    </cfloop>	
		<cfquery name="d" datasource="uam_god">
				select
					taxonomy.family,
					taxonomy.phylorder,
					taxupfail.fail
				from
					taxonomy,
					taxupfail
				where
					taxonomy.family=taxupfail.family and
					taxupfail.family like '#l#%'
				order by
					taxonomy.family
		</cfquery>
		<cfquery name="g" dbtype="query">
			select family,fail from d group by family,fail order by family
		</cfquery>
		<table border>
			<tr>
				<th>family</th>
				<th>##</th>
				<th>order</th>
			</tr>
			<cfloop query="g">
				<cfquery name="f" dbtype="query">
					select phylorder,count(*) n from d where family='#family#' group by phylorder order by phylorder
				</cfquery>
				<tr>
					<td>
						<a href="/TaxonomyResults.cfm?family==#family#">#family#</a>
					</td>
					<td>#f.n#</td>
					<td>
						
						<cfloop query="f">
							<div>
								<a href="/TaxonomyResults.cfm?family==#g.family#&phylorder=#phylorder#">#phylorder#</a>
							</div>
						</cfloop>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<cfif action is 'duGenus'>
	
	<br>Letter-links are first letter of genus
	<cfoutput>
		<cfif not isdefined("l")>
			<cfset l='A'>
		</cfif>
	    <cfloop index="strLetter" list="A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z" delimiters=",">
	     <a href="TaxonomyScriptGap.cfm?action=#action#&l=#strLetter#">#strLetter#</a>-     
	    </cfloop>	
		<cfquery name="d" datasource="uam_god">
				select
					taxonomy.genus,
					taxonomy.family,
					taxupfail.fail
				from
					taxonomy,
					taxupfail
				where
					taxonomy.genus=taxupfail.genus and
					taxupfail.genus like '#l#%'
				order by
					taxonomy.genus
		</cfquery>
		<cfquery name="g" dbtype="query">
			select genus,fail from d group by genus,fail order by genus
		</cfquery>
		<table border>
			<tr>
				<th>genus</th>
				<th>##Sp</th>
				<th>Family</th>
			</tr>
			<cfloop query="g">
				<cfquery name="f" dbtype="query">
					select family,count(*) n from d where genus='#genus#' group by family order by family
				</cfquery>
				<tr>
					<td>
						<a href="/TaxonomyResults.cfm?genus==#genus#">#genus#</a>
					</td>
					<td>#f.n#</td>
					<td>
						
						<cfloop query="f">
							<div>
								<a href="/TaxonomyResults.cfm?genus==#g.genus#&family=#family#">#family#</a>
							</div>
						</cfloop>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
	
		<!---
	<cfoutput>
		<cfif not isdefined("start")>
			<cfset start=0>
		</cfif>
		<cfif not isdefined("stop")>
			<cfset stop=50>
		</cfif>
		this form will return <=1000 rows
		<cfquery name="g" datasource="uam_god">
			Select * from (
				Select a.*, rownum rnum From (
					select
					genus,
					fail,
					rownum r
				from
					taxupfail order by genus
				) a where rownum <= #stop#
			) where rnum >= #start#
		</cfquery>
		<table border>
			<cfloop query="g">
				<tr>
					<td>#fail#</td>
					<td>
						<a href="/TaxonomyResults.cfm?genus==#genus#">#genus#</a>
					</td>
					<td>
						<cfquery name="f" datasource="uam_god">
							select family from taxonomy where genus='#genus#' group by family order by family
						</cfquery>
						<cfloop query="f">
							<div>
								<a href="/TaxonomyResults.cfm?genus==#g.genus#&family=#family#">#family#</a>
							</div>
						</cfloop>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
	--->
</cfif>
<cfinclude template="/includes/_footer.cfm">