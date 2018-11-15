<!-----

desc dlm.my_temp_cf;

create table temp_qn as select * from dlm.my_temp_cf;

alter table temp_qn add quad varchar2(255);

update temp_qn set quad=filename;
update temp_qn set quad=replace(quad,'.wkt');
  update temp_qn set quad=replace(quad,'_',' ');

select quad from temp_qn;

select quad from temp_qn where quad not in (select upper(quad) from geog_auth_rec);

  alter table temp_qn add hg varchar2(255);
  alter table temp_qn add foundwith varchar2(255);
update temp_qn set foundwith='stateplusquad' where hg is not null;


declare
  c number;
  g varchar2(255);
begin
  for r in (select * from temp_qn where hg is null) loop
  select count(*)  into c from geog_auth_rec where upper(replace(quad,'.'))=trim(r.quad)  and state_prov='Alaska' and COUNTY is null and  FEATURE is null
  -- ignore island for second pass
  --and  ISLAND is null
  -- and ISLAND_GROUP is null
  and SEA is null and DRAINAGE is null;

      dbms_output.put_line(r.quad);
      dbms_output.put_line(c);

      if c=1 then
         select HIGHER_GEOG into g from geog_auth_rec where upper(replace(quad,'.'))=trim(r.quad) and state_prov='Alaska' and
          COUNTY is null and
          FEATURE is null and
          ISLAND is null and
          ISLAND_GROUP is null and
          SEA is null and
          DRAINAGE is null;
          update temp_qn set hg=g ,foundwith='noislandorgroup' where quad=r.quad;
      end if;
    end loop;
  end;
  /

-- already got it
update temp_qn set quad=trim(quad);

select quad from temp_qn where hg is null;

begin
  for r in (select quad from temp_qn where hg is null) loop
    dbms_output.put_line(r.quad);
    for q in ( select HIGHER_GEOG from geog_auth_rec where upper(replace(quad,'.'))=trim(r.quad) and state_prov='Alaska' ) loop

    dbms_output.put_line(q.HIGHER_GEOG);
    end loop;
  end loop;
end;
/

-- manual


update temp_qn set hg=trim('North America, Bering Sea, United States, Alaska, Unalaska Quad, Aleutian Islands') where quad='UNALASKA';
update temp_qn set hg=trim('North America, Bering Sea, United States, Alaska, Umnak Quad, Aleutian Islands') where quad='UMNAK';
update temp_qn set hg=trim('North America, United States, Alaska, Simeonof Island Quad, Shumagin Islands') where quad='SIMEONOF ISLAND';
update temp_qn set hg=trim('North America, Bering Sea, United States, Alaska, Seguam Quad, Aleutian Islands') where quad='SEGUAM';
update temp_qn set hg=trim('North America, United States, Alaska, Petersburg Quad, Alexander Archipelago') where quad='PETERSBURG';
update temp_qn set hg=trim('North America, United States, Alaska, Mt. St. Elias Quad, Tongass National Forest') where quad='MT ST ELIAS';
update temp_qn set hg=trim('North America, Bering Sea, United States, Alaska, Kiska Quad, Aleutian Islands') where quad='KISKA';
update temp_qn set hg=trim('North America, Gulf of Alaska, United States, Alaska, Kaguyak Quad') where quad='KAGUYAK';
update temp_qn set hg=trim('North America, United States, Alaska, Dixon Entrance Quad, Alexander Archipelago') where quad='DIXON ENTRANCE';
update temp_qn set hg=trim('North America, United States, Alaska, Craig Quad, Alexander Archipelago') where quad='CRAIG';
update temp_qn set hg=trim('North America, Bering Sea, United States, Alaska, Black Quad') where quad='BLACK';
update temp_qn set hg=trim('North America, Bering Sea, United States, Alaska, Baird Inlet Quad') where quad='BAIRD INLET';
update temp_qn set hg=trim('North America, Bering Sea, United States, Alaska, Attu Quad, Aleutian Islands') where quad='ATTU';
update temp_qn set hg=trim('North America, Bering Sea, United States, Alaska, Atka Quad, Andreanof Islands, Aleutian Islands') where quad='ATKA';
update temp_qn set hg=trim('xxxx') where quad='xxxxxx';

alter table temp_qn add media_id number;

---->

<cfoutput>
	<cfquery name="d" datasource="uam_god">
		select * from temp_qn where media_id is null and rownum<2
	</cfquery>
	<cfloop query="d">

		<cfset tmuri='https://raw.githubusercontent.com/BNHM/spatial-layers/master/wkt/US_Alaska/#FILENAME#'>
		<br>#tmuri#
		<cfquery name="ag1" datasource="uam_god">
			select media_id from media where media_uri='#tmuri#'
		</cfquery>
		<cfif len(ag1.media_id) gt 0>
			<cfquery name="ag1" datasource="uam_god">
				update temp_qn set media_id=#ag1.media_id# where FILENAME='#FILENAME#'
			</cfquery>
		<cfelse>
			<cfquery name="k" datasource="uam_god">
				select sq_media_id.nextval k from dual
			</cfquery>
			<cfquery name="m" datasource="uam_god">
				insert into media (
					MEDIA_ID,
					MEDIA_URI,
					MIME_TYPE,
					MEDIA_TYPE
				) values (
					#k.k#,
					'#tmuri#',
					'text/plain',
					'text'
				)
			</cfquery>

			<cfquery name="cb" datasource="uam_god">
				insert into media_relations (
					MEDIA_RELATIONS_ID,
					MEDIA_ID,
					MEDIA_RELATIONSHIP,
					CREATED_BY_AGENT_ID,
					RELATED_PRIMARY_KEY,
					CREATED_ON_DATE
				) values (
					sq_MEDIA_RELATIONS_ID.nextval,
					#k.k#,
					'created by agent',
					2072,
					10014199,
					sysdate
				)
			</cfquery>

			<cfquery name="md" datasource="uam_god">
				insert into media_labels (
					MEDIA_LABEL_ID,
					MEDIA_ID,
					MEDIA_LABEL,
					LABEL_VALUE,
					ASSIGNED_BY_AGENT_ID,
					ASSIGNED_ON_DATE
				) values (
					sq_MEDIA_LABEL_ID.nextval,
					#k.k#,
					'made date',
					'#dateformat(now(),'YYYY-MM-DD')#',
					2072,
					sysdate
				)
			</cfquery>

			<cfquery name="mct" datasource="uam_god">
				insert into media_labels (
					MEDIA_LABEL_ID,
					MEDIA_ID,
					MEDIA_LABEL,
					LABEL_VALUE,
					ASSIGNED_BY_AGENT_ID,
					ASSIGNED_ON_DATE
				) values (
					sq_MEDIA_LABEL_ID.nextval,
					#k.k#,
					'description',
					'Polygon for #quad# Quad, Alaska',
					2072,
					sysdate
				)
			</cfquery>
			<cfquery name="ag1" datasource="uam_god">
				update temp_qn set media_id=#k.k# where FILENAME='#FILENAME#'
			</cfquery>
		</cfif>
	</cfloop>
</cfoutput>