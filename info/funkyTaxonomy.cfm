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

---->


<cfoutput>


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
				<cfdump var=#flt#>
				<cfif len(flt.v) gt 0>
					<p>
						found something break
					</p>
					<cfquery name="fit" datasource="uam_god" result="x">
						update temp_tax_funk set lowest_term='#flt.v#' where sciname='#d.sciname#'
					</cfquery>
					<cfdump var=#x#>
					<cfbreak>
				</cfif>

			</cfloop>
		</cfloop>

	</cfif>


<cfif action is "findOne">



<cfset diff_term="nomenclatural_code">
<cfset src_term="Asilini">


<cfquery name="f" datasource="uam_god">
	select distinct
		scientific_name,
		term
	from
		taxon_term,
		taxon_name
	where
		taxon_term.taxon_name_id=taxon_name.taxon_name_id and
		term_type='#diff_term#' and
		source='Arctos' and
		taxon_term.taxon_name_id in (
			select taxon_name_id from taxon_term where term='#src_term#' and source='Arctos'
		)
	order by term,scientific_name
</cfquery>



results for source_term=#src_term#, differences in #diff_term#
<cfquery name="f" datasource="uam_god">
	select distinct
		scientific_name,
		term
	from
		taxon_term,
		taxon_name
	where
		taxon_term.taxon_name_id=taxon_name.taxon_name_id and
		term_type='#diff_term#' and
		source='Arctos' and
		taxon_term.taxon_name_id in (
			select taxon_name_id from taxon_term where term='#src_term#' and source='Arctos'
		)
	order by term,scientific_name
</cfquery>
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
</cfoutput>

<cfinclude template = "/includes/_footer.cfm">
