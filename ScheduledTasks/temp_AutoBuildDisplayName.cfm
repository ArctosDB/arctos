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
	display_name,
	cid
) (
	select distinct
		taxon_term.taxon_name_id,
		taxon_name.scientific_name,
		taxon_term.term display_name,
		taxon_term.classification_id
	from
		taxon_term,
		taxon_name
	where
		taxon_term.taxon_name_id=taxon_name.taxon_name_id and
		taxon_term.term_type='display_name' and
		taxon_term.source in ('Arctos','Arctos Plants')
	);


select
	--'"' || display_name || '"' || chr(9) || '"' || gdisplay_name || '"'
	display_name || '------>' ||  gdisplay_name
from
	temp_dnametest where
	gdisplay_name not like 'ERROR%' and gdisplay_name is not null and display_name!=gdisplay_name
	order by display_name;

	select count(*) from temp_dnametest;
	select count(*) from temp_dnametest where gdisplay_name is  null;
  select count(*) from temp_dnametest where gdisplay_name  like 'ERROR%';
  select distinct (gdisplay_name) from temp_dnametest where gdisplay_name  like 'ERROR%';

update temp_dnametest set gdisplay_name=null where gdisplay_name not like 'ERROR%' and gdisplay_name!=display_name;

------------------------------------------------------------------------------------------------------------------------
ERROR: The string v_subsp. is not a valid ColdFusion variable name.
ERROR: The string v_convar. is not a valid ColdFusion variable name.
ERROR: The string v_canonical name is not a valid ColdFusion variable name.
ERROR: The string v_nothof. is not a valid ColdFusion variable name.
ERROR: The string v_subvar. is not a valid ColdFusion variable name.
ERROR: The string v_prol. is not a valid ColdFusion variable name.
ERROR: The string v_subhybr. is not a valid ColdFusion variable name.
ERROR: The string v_var. is not a valid ColdFusion variable name.
ERROR: The string v_subsubvar. is not a valid ColdFusion variable name.
ERROR: The string v_nothosubsp. is not a valid ColdFusion variable name.
ERROR: The string v_lus. is not a valid ColdFusion variable name.
ERROR: The string v_modif. is not a valid ColdFusion variable name.
ERROR: The string v_nothovar. is not a valid ColdFusion variable name.
ERROR: The string v_monstr. is not a valid ColdFusion variable name.
ERROR: The string v_name string is not a valid ColdFusion variable name.
ERROR: The string v_nm. is not a valid ColdFusion variable name.
ERROR: The string v_agamovar. is not a valid ColdFusion variable name.
ERROR: The string v_mut. is not a valid ColdFusion variable name.
ERROR: The string v_agamosp. is not a valid ColdFusion variable name.
ERROR: The string v_canonical string is not a valid ColdFusion variable name.
ERROR: The string v_subf. is not a valid ColdFusion variable name.



select scientific_name from temp_dnametest where gdisplay_name = 'ERROR: The string v_canonical name is not a valid ColdFusion variable name.';

update temp_dnametest set gdisplay_name=null where gdisplay_name ='ERROR: The request has exceeded the allowable time limit Tag: CFLOOP';
update temp_dnametest set gdisplay_name=null where gdisplay_name ='ERROR: The request has exceeded the allowable time limit Tag: CFQUERY';
update temp_dnametest set gdisplay_name=null where gdisplay_name ='ERROR: The string v_subsp. is not a valid ColdFusion variable name.';
update temp_dnametest set gdisplay_name=null where gdisplay_name ='ERROR: The string v_var. is not a valid ColdFusion variable name.';
update temp_dnametest set gdisplay_name=null where gdisplay_name ='xxxxxx';
update temp_dnametest set gdisplay_name=null where gdisplay_name ='xxxxxx';
update temp_dnametest set gdisplay_name=null where gdisplay_name ='xxxxxx';

update temp_dnametest set gdisplay_name=null where gdisplay_name ='ERROR: The string v_scientific name is not a valid ColdFusion variable name.';

select scientific_name from temp_dnametest where gdisplay_name='ERROR: The string v_canonical_ name is not a valid ColdFusion variable name.';
update temp_dnametest set gdisplay_name=null where gdisplay_name ='ERROR: The string v_canonical_ name is not a valid ColdFusion variable name.';

-- I hate you so much, ITIS....

declare
	hasKingdom number;
begin
	for r in (select * from temp_dnametest where gdisplay_name='ERROR: The string v_subsp. is not a valid ColdFusion variable name.') loop
		select count(*) into hasKingdom from taxon_term where taxon_name_id=r.taxon_name_id and
			source='Arctos' and term_type='kingdom' and term='Animalia';
		if hasKingdom=1 then
			dbms_output.put_line('yup');
			dbms_output.put_line(r.scientific_name);
			update taxon_term set term_type='subspecies',term=replace(term,' subsp.') where
				  taxon_name_id=r.taxon_name_id and
				source='Arctos' and term_type='subsp.'
				;
		end if;
	end loop;
end;
/
-- next...
-- Arthropoda (phylum)

declare
	c number;
begin
	for r in (select * from temp_dnametest where gdisplay_name='ERROR: The string v_subsp. is not a valid ColdFusion variable name.') loop
		select count(*) into c from taxon_term where taxon_name_id=r.taxon_name_id and
			source='Arctos' and term_type='phylum' and term='Arthropoda';
		if c=1 then
			dbms_output.put_line('yup: ' || r.scientific_name);
			update taxon_term set term_type='subspecies',term=replace(term,' subsp.') where
				  taxon_name_id=r.taxon_name_id and
				source='Arctos' and term_type='subsp.'
				;

		else
			dbms_output.put_line('nope: ' || r.scientific_name);

		end if;
	end loop;
end;
/
declare
	c number;
begin
	for r in (select * from temp_dnametest where gdisplay_name='ERROR: The string v_subsp. is not a valid ColdFusion variable name.') loop
		select count(*) into c from taxon_term where taxon_name_id=r.taxon_name_id and
			source='Arctos' and term_type='nomenclatural_code' and term='ICZN';
		if c=1 then
			dbms_output.put_line('yup: ' || r.scientific_name);
			update taxon_term set term_type='subspecies',term=replace(term,' subsp.') where
				  taxon_name_id=r.taxon_name_id and
				source='Arctos' and term_type='subsp.'
				;


		else
			dbms_output.put_line('nope: ' || r.scientific_name);

		end if;
	end loop;
end;
/

declare
	c number;
begin
	for r in (select * from temp_dnametest where gdisplay_name='ERROR: The string v_subsp. is not a valid ColdFusion variable name.') loop
		select count(*) into c from taxon_term where taxon_name_id=r.taxon_name_id and
			source='Arctos' and term_type='nomenclatural_code' and term='ICNB';
		if c=1 then
			dbms_output.put_line('yup: ' || r.scientific_name);



		else
			dbms_output.put_line('nope: ' || r.scientific_name);

		end if;
	end loop;
end;
/



select count(*) from temp_dnametest where gdisplay_name=null;


select taxon_name_id,count(*) from temp_dnametest having count(*) > 1 group by taxon_name_id;





select * from temp_dnametest where nvl(DISPLAY_NAME,'null') != nvl(GDISPLAY_NAME,'null');



select
	--'"' || display_name || '"' || chr(9) || '"' || gdisplay_name || '"'
	display_name || '------>' ||  gdisplay_name
from
	temp_dnametest where
	gdisplay_name not like 'ERROR%' and gdisplay_name is not null and display_name!=gdisplay_name
	order by display_name;

	select count(*) from temp_dnametest;


select display_name || '------>' ||  gdisplay_name from temp_dnametest where
gdisplay_name not like 'ERROR%' and gdisplay_name is not null and
nvl(DISPLAY_NAME,'null') != nvl(GDISPLAY_NAME,'null')
order by display_name;


create table temp_gdnerr as select * from temp_dnametest where gdisplay_name like 'ERROR%';



create table temp_dname_diff as select * from temp_dnametest where
gdisplay_name not like 'ERROR%' and gdisplay_name is not null and
nvl(DISPLAY_NAME,'null') != nvl(GDISPLAY_NAME,'null');

alter table temp_dname_diff add arctoslink varchar2(4000);
update temp_dname_diff set arctoslink='http://arctos.database.museum/name/' || urlescape(scientific_name);



SET TERMOUT OFF
SET ECHO OFF
SET LINES 1000
SET FEEDBACK off
SET HEADING OFF
SET ARRAYSIZE 10000
SET NEWPAGE NONE
SET PAGESIZE 0
SET TRIMSPOOL ON
spool temp_dname_diff.csv
select  '"' || SCIENTIFIC_NAME || '","' || replace(DISPLAY_NAME,'"','""') || '","' || replace(GDISPLAY_NAME,'"','""')|| '","' || ARCTOSLINK || '"'
 from temp_dname_diff where rownum<100;
Spool OFF;
EXIT



spool off;



create index ix_temp_junk on temp_dnametest (taxon_name_id) tablespace uam_idx_1;

---->
<cfset utilities = CreateObject("component","component.utilities")>
<cfquery name="d" datasource="uam_god">
	select * from temp_dnametest where gdisplay_name is null and rownum<1000
</cfquery>
<cfoutput>
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
			update temp_dnametest set gdisplay_name='#x#' where taxon_name_id=#taxon_name_id#
		</cfquery>

	</cfloop>
</cfoutput>

