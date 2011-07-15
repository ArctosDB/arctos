<!-------------
CREATE table taxupfail (
  genus varchar2(255),
    fail varchar2(255)
);

create index temp_taxup_g on taxupfail(genus) tablespace uam_idx_1;

exec DBMS_SCHEDULER.DROP_JOB (JOB_NAME => 'j_fix_tax_by_genus', FORCE => TRUE);



BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'j_fix_tax_by_genus',
    job_type           =>  'STORED_PROCEDURE',
    job_action         =>  'fix_tax_by_genus',
    start_date         =>  SYSTIMESTAMP,
    repeat_interval    =>  'freq=minutely; interval=2',
    enabled            =>  TRUE,
    end_date           =>  NULL,
    comments           =>  'taxonomy gap filler-inner');
END;
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

------------>
<cfinclude template="/includes/_header.cfm">
<cfset title="Taxonomy is still a mess">
<cfset action='duGenus'>
<cfif action is 'duGenus'>
	Taxonomy gaps that cannot be scripted in.
	This form/data does not auto-update - pick on an admin if you want a refresh - code in the header
	<br>Letter-links are first letter of genus
	<cfoutput>
		<cfif not isdefined("l")>
			<cfset l='A'>
		</cfif>
	    <cfloop index="strLetter" list="A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z" delimiters=",">
	     <a href="TaxonomyScriptGap.cfm?l=#strLetter#">#strLetter#</a>-     
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