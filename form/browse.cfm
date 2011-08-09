<!-----------
create table browse (
	insdate timestamp default systimestamp,
	link varchar2(4000),
	display varchar2(4000)
);
create or replace public synonym browse for browse;

grant select on browse to public;

CREATE OR REPLACE PROCEDURE set_browse
is
BEGIN
	insert into browse (link,display) (
		select link,display from (
			select 
				'/guid/' || guid link,
				collection || ' ' || cat_num || ' <i>' || scientific_name || '</i>' display
			from
				filtered_flat
			 	sample(3)
			 where scientific_name != 'unidentifiable'
			 order by
			 	dbms_random.value
			)
		WHERE rownum <= 500
	);
	
	insert into browse (link,display) (
		select link,display from (
			select 
				formatted_publication display,
				'/publication/' || formatted_publication.publication_id link
			from
				formatted_publication,
				citation,
				filtered_flat
				sample(20)
			where 
				format_style='long' and
				formatted_publication not like '%Field Notes%' and
				formatted_publication.publication_id=citation.publication_id and
				citation.collection_object_id=filtered_flat.collection_object_id
			order by 
				dbms_random.value
		)
		WHERE rownum <= 500
	);
	
	insert into browse (link,display) (
		select link,display from (
			select 
				'<img style="max-height:150px;" src="' || preview_uri || '">' display,
				'/media/' || media.media_id link
			from
				media,
				media_relations
				sample(5)
			where
				mime_type not in ('image/dng') and
				media_relationship not like '% project' and				
				preview_uri is not null and
				media.media_id=media_relations.media_id
			order by 
				dbms_random.value
		)
		WHERE rownum <= 500
	);
	
	
	insert into browse (link,display) (
		select link,display from (
			select 
				'/name/' || taxonomy.scientific_name link,
				display_name display
			from
				taxonomy,
				identification,
				identification_taxonomy,
				filtered_flat
				sample(1)
			where
				taxonomy.taxon_name_id > 0 and
				taxonomy.taxon_name_id=identification_taxonomy.taxon_name_id and
				identification_taxonomy.identification_id=identification.identification_id and
				identification.collection_object_id=filtered_flat.collection_object_id
			order by 
				dbms_random.value
		) WHERE rownum <= 500
	);
	
	insert into browse (link,display) (
		select link,display from (
			select link,display from (
				select 
					'/project/' || niceURL(project_name) link,
					project_name display
				from
					project,
					project_trans,
					filtered_flat
					sample(5)
				where
					project.project_id=project_trans.project_id and
					project_trans.transaction_id=filtered_flat.accn_id and
					length(project.project_description) > 100
				union
				select 
					'/project/' || niceURL(project_name) link,
					project_name display
				from
					project,
					project_trans,
					loan_item,
					specimen_part,
					filtered_flat
					sample(50)
				where
					project.project_id=project_trans.project_id and
					project_trans.transaction_id=loan_item.transaction_id and
					loan_item.collection_object_id=specimen_part.collection_object_id and
					specimen_part.derived_from_cat_item=filtered_flat.collection_object_id
			)
		group by link,display
		order by dbms_random.value)
		WHERE rownum <= 500
	);
	
	-- only keep stuff around for 2 hours
	delete from browse where ((cast(systimestamp as date)-cast(insdate as date))*24*60)>120;
end;
/


BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'j_set_browse',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'set_browse',
		start_date		=> systimestamp,
		repeat_interval	=> 'freq=HOURLY;interval=1',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'grab a random sample of the good stuff for the TSR widget');
END;
/ 


		
------------>

<!--- exclude UAM Mammals users --->
<cfif session.portal_id is 1 or session.username is "pub_usr_uam_mamm">
	<cfabort>
</cfif>
	<!---- <cftry>
---->
<cfif session.block_suggest neq 1>
	<cfquery name="links" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" >
		select link,display from (
			select 
				link,display
			from
				browse
			 	sample(25)
			 order by
			 	dbms_random.value
			)
		WHERE rownum <= 25
	</cfquery>
	<cfoutput>
		<div id="browseArctos">
			<div class="title">Try something random
			<span class="infoLink" onclick="blockSuggest(1)">Hide This</span></div>
			<ul>
				<cfloop query="links">
					<li><a href="#link#">#display#</a></li>
				</cfloop>
			</ul>
		</div>
	</cfoutput>
</cfif>
<!---

<cfcatch>
<!--- not fatal - ignore --->
</cfcatch>
</cftry>

--->