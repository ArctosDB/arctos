<!----

in oracle land...


create table temp_ArcTaxName as select distinct taxon_name.taxon_name_id,taxon_name.scientific_name from taxon_name,taxon_term where taxon_name.taxon_name_id=taxon_term.taxon_name_id and taxon_term.source='Arctos';

alter table temp_ArcTaxName add gotit number;

drop table temp_new_names;
create table temp_new_names (scientific_name varchar2(255),source_rank varchar2(255),source_name varchar2(255));

update temp_ArcTaxName set gotit = null where gotit is not null;

CREATE OR REPLACE PROCEDURE temp_update_junk IS
  c number;
begin
  for recs in (select * from temp_ArcTaxName where gotit is null) loop
    --dbms_output.put_line(recs.scientific_name);
    for r in (select * from taxon_term,CTTAXON_TERM where taxon_term.TERM_TYPE=CTTAXON_TERM.TAXON_TERM and taxon_term.source='Arctos' and taxon_term.taxon_name_id=recs.taxon_name_id) loop
       -- dbms_output.put_line('    ' || r.TERM_TYPE || ' = ' || r.term);
        -- don't make new names for not-name data
        if r.IS_CLASSIFICATION = 1 then
          select count(*) into c from taxon_name where scientific_name=r.term;
          if c=0 then
            -- make sure we haven't already hit this one
            select count(*) into c from temp_new_name_class where scientific_name=r.term;
             if c=0 then
              -- doesn't exist, we haven't already found it, add it to the temp table
              --dbms_output.put_line('            this is new lets make one');
              insert into temp_new_names (scientific_name,source_rank,source_name) values (r.term,r.term_type,recs.scientific_name);
              end if;
            end if;
        end if;
    end loop;
    update temp_ArcTaxName set gotit=1 where taxon_name_id=recs.taxon_name_id;
  end loop;
end;
/



BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_temp_update_junk',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/


select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';


create table temp_new_names_fd as select SCIENTIFIC_NAME,SOURCE_RANK,SOURCE_NAME from temp_new_names group by SCIENTIFIC_NAME,SOURCE_RANK,SOURCE_NAME;

alter table temp_new_names_fd add status varchar2(4000);


create table temp_new_names_fd as select SCIENTIFIC_NAME,SOURCE_RANK,SOURCE_NAME from temp_new_names group by SCIENTIFIC_NAME,SOURCE_RANK,SOURCE_NAME;



----------->
<cfquery name="oClassTerms" datasource="uam_god">
	select
		*
	from
		CTTAXON_TERM
</cfquery>


<cfquery name="d" datasource="uam_god">
	select * from temp_new_names_fd where status is null and rownum < 2
</cfquery>
<cfoutput>
	<cfloop query="d">
		<br>SCIENTIFIC_NAME: #SCIENTIFIC_NAME#
		<br>SOURCE_RANK: #SOURCE_RANK#
		<br>SOURCE_NAME: #SOURCE_NAME#
	</cfloop>
</cfoutput>


