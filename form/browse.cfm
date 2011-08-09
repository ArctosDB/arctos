<!--- exclude UAM Mammals users --->
<cfoutput>
<cfif session.portal_id is 1 or session.username is "pub_usr_uam_mamm">
	
	session.portal_id=#session.portal_id#
	<br>
	session.username=#session.username#
	<cfabort>
</cfif>
session.block_suggest: #session.block_suggest#
</cfoutput>
<cftry>
	<!---- ---->
<cfif session.block_suggest neq 1>
	<cfquery name="links" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,15,0)#">
		select link,display from (
			select 
				'/guid/' || guid link,
				collection || ' ' || cat_num || ' <i>' || scientific_name || '</i>' display
			from
				filtered_flat
			 	sample(1)
			 where scientific_name != 'unidentifiable'
			 order by
			 	dbms_random.value
			)
		WHERE rownum <= 5
		union
		select link,display from (
			select 
				formatted_publication display,
				'/publication/' || formatted_publication.publication_id link
			from
				formatted_publication,
				citation,
				filtered_flat
				sample(5)
			where 
				format_style='long' and
				formatted_publication not like '%Field Notes%' and
				formatted_publication.publication_id=citation.publication_id and
				citation.collection_object_id=filtered_flat.collection_object_id
			order by 
				dbms_random.value
		)
		WHERE rownum <= 5
		union
		select link,display from (
			select 
				'<img style="max-height:150px;" src="' || preview_uri || '">' display,
				'/media/' || media.media_id link
			from
				media,
				media_relations,
				filtered_flat
				sample(5)
			where
				mime_type not in ('image/dng') and
				preview_uri is not null and
				media_relations.media_relationship='shows cataloged_item' and
				media.media_id=media_relations.media_id and
				media_relations.related_primary_key=filtered_flat.collection_object_id
			order by 
				dbms_random.value
		)
		WHERE rownum <= 5
		union
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
		)
		WHERE rownum <= 5
		union
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
					length(project.project_detail) > 100
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
					sample(5)
				where
					project.project_id=project_trans.project_id and
					project_trans.transaction_id=loan_item.transaction_id and
					loan_item.collection_object_id=specimen_part.collection_object_id and
					specimen_part.derived_from_cat_item=filtered_flat.collection_object_id
			)
		group by link,display
		order by dbms_random.value)
		WHERE rownum <= 5
	</cfquery>
	<cfoutput>
		<cfset rslts="">
		<cfloop from="1" to="#links.recordcount#" index="i">
			<cfset rslts=listappend(rslts,i)>
		</cfloop>
		<div id="browseArctos">
			<div class="title">Try something random
			<span class="infoLink" onclick="blockSuggest(1)">Hide This</span></div>
			<ul>
				<cfloop from="1" to="#links.recordcount#" index="i">
					<cfset thisIndex=randrange(1,listlen(rslts))>
					<cfset thisRecord=listgetat(rslts,thisIndex)>
					<li><a href="#links.link[thisRecord]#">#links.display[thisRecord]#</a></li>
					<cfset rslts=listdeleteat(rslts,thisIndex)>
				</cfloop>
			</ul>
		</div>
	</cfoutput>
</cfif>
<cfcatch>
<!--- not fatal - ignore --->
</cfcatch>
</cftry>