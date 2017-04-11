temp_AutoBuildDisplayName.cfm

<!----
drop table temp_dnametest;

create table temp_dnametest (
	taxon_name_id number,
	scientific_name varchar2(255),
	display_name varchar2(255),
	gdisplay_name varchar2(255),
	cid varchar2(255)
);

-- data
-- only get stuff with display name
-- for stuff that doesn't match, figure out why


delete from temp_dnametest where gdisplay_name is null;


insert into temp_dnametest (
	taxon_name_id,
	scientific_name,
	--display_name,
	cid
) (
	select distinct
		taxon_term.taxon_name_id,
		taxon_name.scientific_name,
		--taxon_term.term display_name,
		taxon_term.classification_id
	from
		taxon_term,
		taxon_name
	where
		taxon_term.taxon_name_id=taxon_name.taxon_name_id and
		--taxon_term.term_type='display_name' and
		taxon_term.source in ('Arctos','Arctos Plants')
	);


create index ix_temp_dname_tid on temp_dnametest (taxon_name_id) tablespace uam_idx_1;
create index ix_temp_dname_cid on temp_dnametest (cid) tablespace uam_idx_1;


-- now see what we have for later comparison

update temp_dnametest set display_name=(
	select taxon_term.term from taxon_term where
		taxon_term.term_type='display_name' and
		taxon_term.taxon_name_id=temp_dnametest.taxon_name_id and
		taxon_term.classification_id=temp_dnametest.cid
	);

select
	--'"' || display_name || '"' || chr(9) || '"' || gdisplay_name || '"'
	display_name || '------>' ||  gdisplay_name
from
	temp_dnametest where
	gdisplay_name not like 'ERROR%' and gdisplay_name is not null and display_name!=gdisplay_name
	order by display_name;

	select count(*) from temp_dnametest;
	select count(*) from temp_dnametest where gdisplay_name is not null;


update temp_dnametest set gdisplay_name=null where gdisplay_name not like 'ERROR%' and gdisplay_name!=display_name;

select count(*) from temp_dnametest where gdisplay_name=null;


select taxon_name_id,count(*) from temp_dnametest having count(*) > 1 group by taxon_name_id;


create index ix_temp_junk on temp_dnametest (taxon_name_id) tablespace uam_idx_1;

---->
<cfset utilities = CreateObject("component","component.utilities")>
<cfquery name="d" datasource="uam_god">
	select * from temp_dnametest where gdisplay_name is null and rownum<1000
</cfquery>
<cfoutput>
	<cftransaction>
	<cfloop query="d">

		<cfset x=utilities.generateDisplayName(cid)>
		<cfif len(x) is 0>
			<cfset x='NORETURN'>
		</cfif>

	<!----
		<br>scientific_name=#scientific_name#
		<br>display_name=<pre>#display_name#</pre>
		<br>x=<pre>#x#</pre>
			<cfif x is not display_name>
			<br>NOMATCH!!
		</cfif>
		--->

		<cfquery name="b" datasource="uam_god">
			update temp_dnametest set
				gdisplay_name='#x#',
				display_name=(select term from taxon_term where
				taxon_name_id=#taxon_name_id# and classification_id='#cid#' and
				term_type='display_name')
				 where taxon_name_id=#taxon_name_id# and cid='#cid#'
		</cfquery>

	</cfloop>
	</cftransaction>
</cfoutput>

