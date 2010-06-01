<cfquery name="links" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,10,0)#">
	select link,display from (
		select 
			'/guid/' || guid link,
			collection || ' ' || cat_num || ' <i>' || scientific_name || '</i>' display
		from
			filtered_flat
		ORDER BY dbms_random.value
	)
	WHERE rownum <= 5
	union
	select link,display from (
		select 
			formatted_publication display,
			'/SpecimenUsage.cfm?action=search&publication_id=' || publication_id link
		from
			formatted_publication
		where format_style='long' and
		formatted_publication not like '%Field Notes%'
		ORDER BY dbms_random.value
	)
	WHERE rownum <= 5
	union
	select link,display from (
		select 
			'<img src="' || preview_uri || '">' display,
			'/media/' || media_id link
		from
			media
		where
			mime_type not in ('image/dng') and
			preview_uri is not null
		ORDER BY dbms_random.value
	)
	WHERE rownum <= 5
	union
	select link,display from (
		select 
			'/name/' || scientific_name link,
			display_name display
		from
			taxonomy
		ORDER BY dbms_random.value
	)
	WHERE rownum <= 5
	union
	select link,display from (
		select 
			'/project/' || niceURL(project_name) link,
			project_name display
		from
			project
		ORDER BY dbms_random.value
	)
	WHERE rownum <= 5
</cfquery>
<cfoutput>
	<cfset rslts="">
	<cfloop from="1" to="#links.recordcount#" index="i">
		<cfset rslts=listappend(rslts,i)>
	</cfloop>
	<div id="browseArctos">
		<div class="title">Try something random</div>
		<ul>
			<cfloop from="1" to="#links.recordcount#" index="i">
				<cfset thisIndex=randrange(1,listlen(rslts))>
				<cfset thisRecord=listgetat(rslts,thisIndex)>
				<li><a href="#links.link[thisRecord]#">#links.display[thisRecord]#</a></li>
				<cfset rslts=listdeleteat(rslts,thisIndex)>
			</cfloop>
		</ul>
	</div>
			
		
	
	
	
	
	<!----
	
	<br>rslts: #rslts#
	
		
		
			<cfloop from="1" to="#links.recordcount#" index="i">
				<cfset thisRecord=randrange(1,listlen(rslts))>
				<br>thisRecord: #thisRecord#
				<li><a href="#links.link[thisRecord]#">#links.display[thisRecord]#</a></li>
				<cfset rslts=listdeleteat(rslts,listfind(rslts,thisRecord))>
				<br>afterdelete: #rslts#
			</cfloop>
		</ul>
	</div>
	
	---->
</cfoutput>	