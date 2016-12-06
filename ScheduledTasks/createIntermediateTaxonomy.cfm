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

create table temp_new_class_temp as select * from CF_TEMP_CLASSIFICATION where 1=2;

-- huge bit of duplication caused by terms coming from lots of sources - ignore that for now, but keep it around in case it's useful later

create table temp_new_names_nos as select SCIENTIFIC_NAME,SOURCE_RANK  from temp_new_names group by SCIENTIFIC_NAME,SOURCE_RANK;
alter table temp_new_names_nos add status varchar2(4000);

-- so we can writeSQL

create public synonym temp_new_class_temp for temp_new_class_temp;
grant select on temp_new_class_temp to dlm;
----------->


<!----
	get some stuff that only needs to run once per call

	Nothing much is likely to change while this is running, and we'll probably
		run the same query over and over, so cache like crazy
---->
<cfquery name="CTTAXON_TERM" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
	select
		*
	from
		CTTAXON_TERM
</cfquery>
<cfquery name="classterms" dbtype="query">
	select TAXON_TERM from CTTAXON_TERM where IS_CLASSIFICATION=1 order by RELATIVE_POSITION
</cfquery>
<cfset ctl=valueList(classterms.TAXON_TERM)>
<cfset ctl_ro=replace(ctl,',order,',',phylorder,')>
<cfquery name="temp" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
	select * from  temp_new_class_temp where 1=2
</cfquery>
<cfquery name="d" datasource="uam_god">
	select * from temp_new_names_nos where status is null and rownum <= 200
</cfquery>
<cfoutput>
	<cfloop query="d">
		<cftransaction>
			<cfset thisStatus=''>
			<cfquery name="temp"dbtype="query">
				select * from temp where 1=2
			</cfquery>
			<cfset queryaddrow(temp,1)>
			<cfset querysetcell(temp,"scientific_name",SCIENTIFIC_NAME,1)>
			<cfset querysetcell(temp,"username",session.username,1)>
			<cfset querysetcell(temp,"source",'Arctos',1)>
			<cfif listfindnocase(ctl,SOURCE_RANK)>
				<cfset thisPosn=listfind(ctl,SOURCE_RANK)>
				<cfloop from="1" to="#thisPosn#" index="i">
					<cfset thisTerm=listgetat(ctl,i)>
					<cfquery name="thisDist" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
						select
							b.term,b.term_type
						from
							taxon_term a,
							taxon_term b
						where
							a.source='Arctos' and
							a.classification_id=b.classification_id and
							a.taxon_name_id=b.taxon_name_id and
							a.TERM_TYPE='#SOURCE_RANK#' and
							a.term='#SCIENTIFIC_NAME#' and
							b.term_type='#thisTerm#'
						group by
							b.term,b.term_type
					</cfquery>
					<cfif thisTerm is "order">
						<cfset thisTerm="phylorder">
					</cfif>
					<cfif thisDist.recordcount is 0>
					<cfelseif thisDist.recordcount is 1>
						<cfset querysetcell(temp,"#thisTerm#",thisDist.term,1)>
					<cfelse>
						<cfset querysetcell(temp,"#thisTerm#",valuelist(thisDist.term,';'),1)>
						<cfset thisStatus=listappend(thisStatus,'nohierarchical')>
					</cfif>
				</cfloop>
			<cfelse>
				<cfset thisStatus=listappend(thisStatus,'funky_source_rank')>
			</cfif>
			<!--- see if we can get a nomenclatural code ---->
			<cfquery name="thisNC" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
				select
					b.term
				from
					taxon_term a,
					taxon_term b
				where
					a.source='Arctos' and
					a.classification_id=b.classification_id and
					a.taxon_name_id=b.taxon_name_id and
					a.TERM_TYPE='#SOURCE_RANK#' and
					a.term='#SCIENTIFIC_NAME#' and
					b.term_type='nomenclatural_code'
				group by
					b.term
			</cfquery>

			<cfif len(valuelist(thisNC.term)) gt 0>
				<cfset querysetcell(temp,"nomenclatural_code",valuelist(thisNC.term),1)>
			<cfelse>
				<cfset querysetcell(temp,"NOMENCLATURAL_CODE",'idk',1)>
			</cfif>
			<cfset querysetcell(temp,"status",thisStatus,1)>

			<cfquery name="nr" datasource="uam_god">
				insert into temp_new_class_temp (
				<cfloop list="#temp.columnlist#" index="t">
					#t#
					<cfif listlast(temp.columnlist) is not t>,</cfif>
				</cfloop>
				) values (
				<cfloop list="#temp.columnlist#" index="t">
					'#evaluate("temp." & t)#'
					<cfif listlast(temp.columnlist) is not t>,</cfif>
				</cfloop>
				)
			</cfquery>
			<cfquery name="g" datasource="uam_god">
				update temp_new_names_nos set status ='k' where scientific_name='#scientific_name#'
			</cfquery>
		</cftransaction>
	</cfloop>
</cfoutput>
