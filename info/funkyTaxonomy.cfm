<cfinclude template = "/includes/_header.cfm">


<!--- from the effort to create names for all terms

https://github.com/ArctosDB/arctos/issues/891

a lot of ambiguity popped up. Provide access here.

First, get funky terms, put them into an accessible format


create table temp_tax_funk (
	sciname varchar2(4000),
	funky_term_type varchar2(4000),
	lowest_term varchar2(4000)
);


insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'NOMENCLATURAL_CODE' from temp_new_class_temp where NOMENCLATURAL_CODE like '%,%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'KINGDOM' from temp_new_class_temp where KINGDOM like '%;%');



	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'SUPERKINGDOM' from temp_new_class_temp where SUPERKINGDOM like '%;%');





	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'SUBKINGDOM' from temp_new_class_temp where SUBKINGDOM like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'INFRAKINGDOM' from temp_new_class_temp where INFRAKINGDOM like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'SUPERPHYLUM' from temp_new_class_temp where SUPERPHYLUM like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'PHYLUM' from temp_new_class_temp where PHYLUM like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'SUBPHYLUM' from temp_new_class_temp where SUBPHYLUM like '%;%');




	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'SUBDIVISION' from temp_new_class_temp where SUBDIVISION like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'INFRAPHYLUM' from temp_new_class_temp where INFRAPHYLUM like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'SUPERCLASS' from temp_new_class_temp where SUPERCLASS like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'CLASS' from temp_new_class_temp where CLASS like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'SUBCLASS' from temp_new_class_temp where SUBCLASS like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'INFRACLASS' from temp_new_class_temp where INFRACLASS like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'HYPERORDER' from temp_new_class_temp where HYPERORDER like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'SUPERORDER' from temp_new_class_temp where SUPERORDER like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'PHYLORDER' from temp_new_class_temp where PHYLORDER like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'SUBORDER' from temp_new_class_temp where SUBORDER like '%;%');




	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'INFRAORDER' from temp_new_class_temp where INFRAORDER like '%;%');

insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'HYPORDER' from temp_new_class_temp where HYPORDER like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'SUBHYPORDER' from temp_new_class_temp where SUBHYPORDER like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'SUPERFAMILY' from temp_new_class_temp where SUPERFAMILY like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'FAMILY' from temp_new_class_temp where FAMILY like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'SUBFAMILY' from temp_new_class_temp where SUBFAMILY like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'SUPERTRIBE' from temp_new_class_temp where SUPERTRIBE like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'TRIBE' from temp_new_class_temp where TRIBE like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'SUBTRIBE' from temp_new_class_temp where SUBTRIBE like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'GENUS' from temp_new_class_temp where GENUS like '%;%');

	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'SUBGENUS' from temp_new_class_temp where SUBGENUS like '%;%');





	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'FORMA' from temp_new_class_temp where FORMA like '%;%');


	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'SUBSP' from temp_new_class_temp where SUBSP like '%;%');


	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'SUBSPECIES' from temp_new_class_temp where SUBSPECIES like '%;%');


	insert into temp_tax_funk (sciname,funky_term_type)
(select scientific_name,'SPECIES' from temp_new_class_temp where SPECIES like '%;%');



-- now findLowestTerm



-- this form is too slow, precompile into table

alter table temp_tax_funk add gotit number;

create table temp_funky_taxonomy (
	source_term varchar2(255),
	conflicting_term_type varchar2(255),
	name_using_term varchar2(255),
	names_term_val varchar2(255)
);

delete from temp_funky_taxonomy;
update temp_tax_funk set gotit=null;



exec DBMS_SCHEDULER.DROP_JOB('J_TEMP_UPDATE_JUNK');

CREATE OR REPLACE PROCEDURE temp_update_junk IS
tt varchar2(255);
begin
	for r in (select * from temp_tax_funk where gotit is null) loop
		if lower(r.funky_term_type) = 'pylorder' then
			tt:='ORDER';
		else
			tt:=r.funky_term_type;
		end if;
		--dbms_output.put_line(r.sciname);
		--dbms_output.put_line(r.funky_term_type);
		for c in (
			select distinct
				scientific_name,
				term
			from
				taxon_term,
				taxon_name
			where
				taxon_term.taxon_name_id=taxon_name.taxon_name_id and
				upper(term_type)=upper(tt) and
				source='Arctos' and
				taxon_term.taxon_name_id in (
					select taxon_name_id from taxon_term where upper(term)=upper(r.sciname) and source='Arctos'
				)
			order by term,scientific_name
		) loop
			insert into temp_funky_taxonomy (
				source_term,
				conflicting_term_type,
				name_using_term,
				names_term_val
			) values (
				r.sciname,
				r.funky_term_type,
				c.scientific_name,
				c.term
			);
		end loop;
		update temp_tax_funk set gotit=1 where sciname=r.sciname and funky_term_type=r.funky_term_type;
		commit;
	end loop;
end;
/



select * from temp_tax_funk where gotit is not null;
select count(*) from temp_funky_taxonomy;

select conflicting_term_type,count(*) from temp_funky_taxonomy group by conflicting_term_type;

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_TEMP_UPDATE_JUNK',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/

select * from temp_funky_taxonomy;






alter table temp_tax_funk add resolvedby varchar2(255);


---->

	<script src="/includes/sorttable.js"></script>

<cfoutput>



	<cfif action is "markFixed">
		<cfloop list="#mf#" index="pp" delimiters=",">

		<cftransaction>
			<cfloop list="#mf#" index="pp" delimiters=",">
				<cfquery name="mr" datasource='uam_god'>
					update temp_tax_funk set RESOLVEDBY='#session.username#' where
						SCINAME='#listGetAt(pp,1,'|')#' and
						FUNKY_TERM_TYPE='#listGetAt(pp,2,'|')#'
				</cfquery>

			</cfloop>
		</cftransaction>
		<cflocation url="funkyTaxonomy.cfm" addtoken="false">
	</cfif>


	<cfif action is "findLowestTerm">
		<cfquery name="cols" datasource="uam_god">
			select column_name from user_tab_cols where table_name='TEMP_NEW_CLASS_TEMP' ORDER BY INTERNAL_COLUMN_ID desc
		</cfquery>

		<cfquery name="d" datasource="uam_god">
			select * from temp_tax_funk where lowest_term is null
		</cfquery>
		<cfloop query="d">
			<cfloop query="cols">
				<cfquery name="flt" datasource="uam_god">
					select
						#cols.column_name# v
					from
						temp_new_class_temp
					where scientific_name='#d.sciname#' and
					#cols.column_name# is not null
				</cfquery>
				<cfif len(flt.v) gt 0>
					<p>
						found something break
					</p>
					<cfquery name="fit" datasource="uam_god" result="x">
						update temp_tax_funk set lowest_term='#flt.v#' where sciname='#d.sciname#'
					</cfquery>
					<cfbreak>
				</cfif>

			</cfloop>
		</cfloop>

	</cfif>


<cfif action is "findOne">


<p>
	This page is cached.
	<a href="funkyTaxonomy.cfm?action=findOneLive&diff_term=#diff_term#&src_term=#src_term#">click here for live data</a>
	and to refresh the cache.
</p>



results for source_term=#src_term#, differences in #diff_term#


<cfquery name="f" datasource="uam_god">
	select *
	from
		temp_related_funky_taxonomy
	where
		wonky_term='#src_term#' and used_as_rank='#diff_term#'
	order by used_as_rank,using_name
</cfquery>

<table id="t" border  class="sortable">
	<tr>
		<th>ScientificName</th>
		<th>#diff_term#</th>
	</tr>

<cfloop query="f">
	<tr>
		<td><a href="/name/#USING_NAME#" target="_blank">#USING_NAME#</a></td>
		<td>#USED_VALUE#</td>
	</tr>
</cfloop>

</table>
</cfif>
<cfif action is "findOneLive">




results for source_term=#src_term#, differences in #diff_term#
<cfif diff_term is "phylorder">
	<cfset dterm='order'>
<cfelse>
	<cfset dterm=diff_term>

</cfif>
<cfquery name="f" datasource="uam_god">
	select distinct
		scientific_name,
		term
	from
		taxon_term,
		taxon_name
	where
		taxon_term.taxon_name_id=taxon_name.taxon_name_id and
		upper(term_type)='#ucase(dterm)#' and
		source='Arctos' and
		taxon_term.taxon_name_id in (
			select taxon_name_id from taxon_term where term='#src_term#' and source='Arctos'
		)
	order by term,scientific_name
</cfquery>
<!--- refresh while we're here --->
<cftransaction>
	<cfquery name="flush" datasource="uam_god">
		delete from temp_related_funky_taxonomy where wonky_term='#src_term#' and used_as_rank='#diff_term#'
	</cfquery>
	<cfloop query="f">
		<cfquery name="ins" datasource="uam_god">
			insert into temp_related_funky_taxonomy (
				wonky_term,
				using_name,
				used_as_rank,
				used_value
			) values (
				'#src_term#',
				'#f.scientific_name#',
				'#diff_term#',
				'#f.term#'
			)
		</cfquery>
	</cfloop>
</cftransaction>
<br>cache refreshed
<table border>
	<tr>
		<th>ScientificName</th>
		<th>#diff_term#</th>
	</tr>

<cfloop query="f">
	<tr>
		<td><a href="/name/#scientific_name#" target="_blank">#scientific_name#</a></td>
		<td>#term#</td>
	</tr>
</cfloop>

</table>
</cfif>

<cfif action is "nothing">
	<cfquery name="d" datasource="uam_god">
		select sciname,funky_term_type,RESOLVEDBY from temp_tax_funk order by sciname
	</cfquery>
	<form name="d" method="post" action="funkyTaxonomy.cfm">
		<input type="submit" value="save markFixed">
				<input type="hidden" name="action" value="markFixed">


		<table id="t" border  class="sortable">
			<tr>
				<th>ScientificName</th>
				<th>TermType</th>
				<th>resolved</th>
			</tr>

			<cfloop query="d">
				<tr>
					<td><a href="funkyTaxonomy.cfm?action=findOne&diff_term=#funky_term_type#&src_term=#sciname#">#sciname#</a></td>
					<td>#funky_term_type#</td>
					<td>
						<cfif len(RESOLVEDBY) gt 0>
							by #RESOLVEDBY#
						<cfelse>
							<input type="checkbox" name="mf" value="#sciname#|#funky_term_type#">
						</cfif>
					</td>
				</tr>
			</cfloop>
		</table
						<input type="submit" value="save markFixed">
			</form>
	</cfif>


</cfoutput>

<cfinclude template = "/includes/_footer.cfm">
