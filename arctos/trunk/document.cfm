<cfinclude template="/includes/_header.cfm">
<cfif isdefined("media_id") and media_id gt 0>
	<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			p.label_value pg,
			niceURLNumbers(t.label_value) ttl
		from
			media_labels p,
			media_labels t
		where
			p.media_id=#media_id# and
			p.media_label='page' and
			t.media_id=#media_id# and
			t.media_label='title'
	</cfquery>
	<cfoutput>
		<cfif r.pg gt 0 and len(r.ttl) gt 0>
			<cfheader statuscode="301" statustext="Moved permanently">
			<cfheader name="Location" value="/document/#r.ttl#/#r.pg#">
		<cfelse>
			fail
			<cfabort>
		</cfif>
	</cfoutput>
</cfif>
<cfif listlen(request.rdurl,"/") gt 1>
	<cfset gPos=listfindnocase(request.rdurl,"document","/")>
	<cftry>
		<cfset ttl = listgetat(request.rdurl,gPos+1,"/")>
		<cfcatch>
			fail@can't get title
		</cfcatch>
	</cftry>
	<cftry>
		<cfset p=listgetat(request.rdurl,gPos+2,"/")>
		<cfcatch>
			<cfset p=1>
		</cfcatch>
	</cftry>
	<cfif action is not "pdf">
		<cfset action="show">
	</cfif>
</cfif>
<cfif action is 'srchResult'>
<cfoutput >
	<cfset basSQL="select
		l_title.label_value,
		niceURLNumbers(l_title.label_value) ttl ">
	<cfset basFrm="from
		media_labels l_title,
		media">
	<cfset basWhr="
		where
			media.media_id=l_title.media_id and
			media_type='multi-page document' and
			l_title.media_label='title'">
	<cfset basQ="">
	<cfif isdefined("mtitle") and len(mtitle) gt 0>
		<cfset basQ=basQ & " and l_title.label_value='#mtitle#'">
	</cfif>
	<cfif isdefined("author") and len(author) gt 0>
		<cfset basFrm=basFrm & ',media_relations,agent_name'>
		<cfset basWhr=basWhr & " and media.media_id=media_relations.media_id and
			media_relations.media_relationship='created by agent' and
			media_relations.related_primary_key=agent_name.agent_id ">
		<cfset basQ=basQ & "and upper(agent_name) like '%#ucase(escapeQuotes(author))#%'">
	</cfif>
	<cfif isdefined("b_year") and len(b_year) gt 0>
		<cfif not isnumeric(b_year) or len(b_year) neq 4>
			<div class="error">
				Years must be given as 4-digit integers. Use your back button.
			</div>
			<cfabort>
		</cfif>
		<cfset basFrm=basFrm & ',media_labels l_year'>
		<cfset basWhr=basWhr & " and media.media_id=l_year.media_id and
			l_year.media_label='published year'">
		<cfset basQ=basQ & "and l_year.label_value >= #b_year#">
	</cfif>
	<cfif isdefined("e_year") and len(e_year) gt 0>
		<cfif not isnumeric(e_year) or len(e_year) neq 4>
			<div class="error">
				Years must be given as 4-digit integers. Use your back button.
			</div>
			<cfabort>
		</cfif>
		<cfif basFrm does not contain "l_year">
			<cfset basFrm=basFrm & ',media_labels l_year'>
			<cfset basWhr=basWhr & " and media.media_id=l_year.media_id and
				l_year.media_label='published year'">
		</cfif>
		<cfset basQ=basQ & " and l_year.label_value <= #e_year#">
	</cfif>



	<cfset ssql=basSQL & basFrm & basWhr & basQ & " group by l_title.label_value">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preservesinglequotes(ssql)#
	</cfquery>
	<cfif d.recordcount is 0>
		Nothing matched your query.
	<cfelseif d.recordcount is 1>
		<cflocation url="/document/#d.ttl#" addtoken="false">
	<cfelse>
		<cfset title="document search results">
		Results:<p></p>
		<cfloop query="d">
			<a href="/document/#ttl#">#label_value#</a><br>
		</cfloop>
	</cfif>
</cfoutput>
</cfif>
<cfif action is 'nothing'>
	<cfset title='Document Viewer'>
<cfoutput>
	<cfquery name="titles" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			label_value
		from
			media_labels,
			media
		where
			media.media_id=media_labels.media_id and
			media_type='multi-page document' and
			media_label='title'
		group by
			label_value
		order by label_value
	</cfquery>
	<form name="g" method="post" action="document.cfm">
		<input type="hidden" name="action" value="srchResult">
		<label for="mtitle">Title</label>
		<select name="mtitle" id="mtitle" size="1">
			<option value=""></option>
			<cfloop query="titles">
				<option value="#label_value#">#label_value#</option>
			</cfloop>
		</select>
		<label for="author">Author</label>
		<input type="text" id="author" name="author">
		<label for="b_year">Year (minimum)</label>
		<input type="text" id="b_year" name="b_year">
		<label for="e_year">Year (maximum)</label>
		<input type="text" id="e_year" name="e_year">
		<input type="submit" class="lnkBtn" value="Go">
	</form>
</cfoutput>
</cfif>
<cfif action is 'pdf'>
<cfoutput>
	<cfquery name="doc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			media_uri,
			title.label_value mtitle,
			to_number(page.label_value) page
		from
			media,
			media_labels title,
			media_labels page
		where
			media.media_id=title.media_id and
			media.media_id=page.media_id and
			title.media_label='title' and
			page.media_label='page' and
			media_type='multi-page document' and
			niceURLNumbers(title.label_value)='#ttl#'
		order by
			to_number(page.label_value)
	</cfquery>
	<cfloop query="doc">
		<cfdocument format="PDF" name="p#page#">
			<img src="#media_uri#" alt="Page #page#">
		</cfdocument>
 	</cfloop>
	<cfpdf action="merge" name="mergedpdf">
		<cfloop query="doc">
			<cfset thisName="p#page#">
			 <cfpdfparam source="#thisName#">
		</cfloop>
	</cfpdf>
	<cfset fname = ttl>
	<cfset filePath="#application.webDirectory#/temp/#fname#.pdf">
	<cffile action="write" file="#filePath#" output="#toBinary(mergedpdf)#">
	<cfheader name="Content-Disposition" value="attachment; filename=#getFileFromPath(filePath)#">
	<cfcontent file="#filePath#" type="application/pdf">
</cfoutput>
</cfif>
<!------------------------------->
<cfif action is 'show'>
<cfoutput>
	<cfquery name="doc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			media_uri,
			title.label_value mtitle,
			to_number(page.label_value) page,
			media.media_id
		from
			media,
			media_labels title,
			media_labels page
		where
			media.media_id=title.media_id and
			media.media_id=page.media_id and
			title.media_label='title' and
			page.media_label='page' and
			media_type='multi-page document' and
			niceURLNumbers(title.label_value)='#ttl#'
		order by
			to_number(page.label_value)
	</cfquery>
	<cfif doc.recordcount is 0>
		<div class="error">
			Document #ttl# was not found.
			<br>Try <a href="/document.cfm">searching</a>.
		</div>
		<cfthrow message="missing document" detail="document title #ttl# not found">
		<cfabort>
	</cfif>
	<cfquery name="pg" dbtype="query">
		select max(page) npgs from doc
	</cfquery>
	<cfset maxPage=pg.npgs>
	<cfset title=doc.mtitle>
	<strong>#doc.mtitle#</strong>
	<cfsavecontent variable="controls">
	<table>
		<tr>
			<td>Page</td>
			<td>
				<cfif p gt 1>
					<cfset pp=p-1>
					<a class="infoLink" href="/document/#ttl#/#pp#">Previous</a>
				</Cfif>
			</td>
			<td>
				<select name="p" id="p" onchange="document.location=this.value">
					<cfloop from="1" to="#maxPage#" index="pg">
						<option <cfif pg is p> selected="selected" </cfif>value="/document/#ttl#/#pg#">#pg#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<cfif p lt maxPage>
					<cfset np=p+1>
					<a class="infoLink" href="/document/#ttl#/#np#">Next</a>
				</Cfif>
			</td>
			<td> of #maxPage#</td>
		</tr>
	</table>
	</cfsavecontent>
	#controls#
	<cfquery name="cpg" dbtype="query">
		select media_uri,media_id from doc where page=#p#
	</cfquery>
	<a href="/document.cfm?ttl=#ttl#&action=pdf">[ PDF ]</a>
	<a href="/media/#cpg.media_id#">[ Media Details ]</a>
	<cfquery name="relMedia" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			media_uri,
			media_type,
			related_primary_key from
			media,media_relations where
			media.media_id=media_relations.related_primary_key and
			mime_type in ('image/tiff','image/dng') and
			media_relationship = 'derived from media' and media_relations.media_id=#cpg.media_id#
	</cfquery>
	<cfif relMedia.recordcount is 1>
		<a target="_blank" href="/exit.cfm?target=#relMedia.media_uri#">[ download master ]</a>
	</cfif>
	 <cfquery name="tag" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) n from tag where media_id=#cpg.media_id#
	</cfquery>
	<cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
		<script language="JavaScript" src="/includes/jquery/jquery.imgareaselect.pack.js" type="text/javascript"></script>
		<link rel="stylesheet" type="text/css" href="/includes/jquery/css/imgareaselect-default.css">
		<script language="JavaScript" src="/includes/jquery/scrollTo.js" type="text/javascript"></script>
		<script language="JavaScript" src="/includes/TAG.js" type="text/javascript"></script>
		<!----
		<link rel="stylesheet" type="text/css" href="/includes/jquery/css/ui-lightness/jquery-ui-1.7.2.custom.css">
		<script language="JavaScript" src="/includes/jquery/jquery-ui-1.7.2.custom.min.js" type="text/javascript"></script>
		---->
	<cfelse><!--- public user --->
		<cfif tag.n gt 0>
			<script language="JavaScript" src="/includes/jquery/jquery.imgareaselect.pack.js" type="text/javascript"></script>
			<link rel="stylesheet" type="text/css" href="/includes/jquery/css/imgareaselect-default.css">
			<link rel="stylesheet" type="text/css" href="/includes/jquery/css/ui-lightness/jquery-ui-1.7.2.custom.css">
			<script language="JavaScript" src="/includes/jquery/jquery-ui-1.7.2.custom.min.js" type="text/javascript"></script>
			<script language="JavaScript" src="/includes/jquery/scrollTo.js" type="text/javascript"></script>
			<script language="JavaScript" src="/includes/showTAG.js" type="text/javascript"></script>
		</cfif>
	</cfif>
	<div id="imgDiv">
		<img src="#cpg.media_uri#" alt="This should be a field notebook page" id="theImage">
	</div>
	<cfif (isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")) or tag.n gt 0>
		<script type="text/javascript" language="javascript">
			jQuery(document).ready(function () {
				loadTAG(#cpg.media_id#,'#cpg.media_uri#');
			});
		</script>
	</cfif>
	<div>#controls#</div>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">