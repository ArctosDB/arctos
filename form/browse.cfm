<style>
	#browseArctos {
		font-size:small;
border:1px solid green;
margin:1em;
padding:1em;
overflow:hidden;
max-width:250px;
	}
	
	#browseArctos ul {
	
	}
	
	#browseArctos ul li {
		text-indent:-2em;
		padding-left:2em;
	}
	
</style>
<cfoutput>
<cfquery name="rSpec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,10,0)#">
	select * from (
		select 
			guid,
			collection,
			cat_num,
			scientific_name
		from
			filtered_flat
		ORDER BY dbms_random.value
	)
	WHERE rownum <= 10
</cfquery>
<div id="browseArctos">
	<ul>
<cfloop query="rSpec">
	<li><a href="/guid/#guid#">#collection# #cat_num# <i>#scientific_name#</i></a></li>
</cfloop>

<cfquery name="rTax" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,10,0)#">
	select * from (
		select 
			scientific_name,
			display_name
		from
			taxonomy
		ORDER BY dbms_random.value
	)
	WHERE rownum <= 10
</cfquery>
<cfloop query="rTax">
	<li><a href="/name/#scientific_name#">#display_name#</a></li>
</cfloop>

<cfquery name="rPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,10,0)#">
	select * from (
		select 
			formatted_publication,
			publication_id
		from
			formatted_publication
		where format_style='long' and
		formatted_publication not like '%Field Notes%'
		ORDER BY dbms_random.value
	)
	WHERE rownum <= 10
</cfquery>
<cfloop query="rPub">
	<li><a href="/SpecimenUsage.cfm?action=search&publication_id=#publication_id#">#formatted_publication#</a><br>
</cfloop>

<cfquery name="rProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,10,0)#">
	select * from (
		select 
			niceURL(project_name) nproject_name,
			project_name
		from
			project
		ORDER BY dbms_random.value
	)
	WHERE rownum <= 10
</cfquery>
<cfloop query="rProj">
	<li><a href="/project/#nproject_name#">#project_name#</a></li>
</cfloop>

<cfquery name="media" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,10,0)#">
	select * from (
		select 
			preview_uri,
			media_id
		from
			media
		where
			mime_type not in ('image/dng') and
			preview_uri is not null
		ORDER BY dbms_random.value
	)
	WHERE rownum <= 10
</cfquery>
<cfloop query="media">
	<li><a href="/media/#media_id#"><img src="#preview_uri#"></a></li>
</cfloop>
	</ul>
</div>
</cfoutput>