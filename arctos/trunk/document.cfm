<cfinclude template="/includes/_header.cfm">

<cfif not isdefined("pg")>
	<cfset pg=1>
</cfif>
<cfif not isdefined("tag_id")>
	<cfset tag_id="">
</cfif>
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
			<cfheader name="Location" value="/document/#r.ttl#/#r.pg#/###tag_id#">
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
	<cfif listlen(request.rdurl,"/") gte gPos+2>
		<cftry>
		<cfset p=listgetat(request.rdurl,gPos+2,"/")>
		<cfif listlen(p,"?&") gt 1>
			<cfset pg=listgetat(p,1,"?&")>
			<cfset tag_id=listgetat(p,2,"?&")>
			<cfif listlen(tag_id,"=") gt 1>
				<cfset tag_id=listgetat(tag_id,2,"=")>
			<cfelse>
				<cfset tag_id="">
			</cfif>			
		<cfelse>
			<cfset pg=p>
		</cfif>
		<cfif len(tag_id) gt 0>
			<cfoutput>
			<div style="border:2px solid red;">
				You got here with a deprecated URL.
				Please update your records to <a href="/document/#ttl#/#pg#/###tag_id#">#application.serverRootURL#/document/#ttl#/#pg#/###tag_id#</a>
			</div>
			</cfoutput>
		</cfif>
		<cfcatch>
			<cfset pg=1>
			<cfset tag_id="">
		</cfcatch>
	</cftry>
	</cfif>
	<cfset action="show">
</cfif>

<cfif action is 'findDocumentPage'>
	<cfif not isdefined("urltitle") or len(urltitle) is 0 or not isdefined("description") or len(description) is 0>
		<cfabort>
	</cfif>
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				l_page.label_value pg,
				l_description.label_value description,
				l_title.label_value title
			from
				media_labels l_title,
				media_labels l_page,
				media_labels l_description
			where
				l_title.media_id=l_page.media_id and 
				l_title.media_id=l_description.media_id and
				l_title.media_label='title' and
				l_page.media_label='page' and
				l_description.media_label='description' and
				niceURLNumbers(l_title.label_value)='#urltitle#' and
				l_description.label_value like '#description#'
			group by
				l_page.label_value,
				l_description.label_value,
				l_title.label_value
			order by
				to_number(l_page.label_value),
				l_description.label_value,
				l_title.label_value
		</cfquery>
		
		<cfif d.recordcount is 0>
			Nothing matched your query. Use your back button and try again.
		<cfelseif d.recordcount is 1>
			<cflocation url="/document/#urltitle#/#d.pg#" addtoken="false">
		<cfelse>
			<cfset title="document search results">
			<p>Results: Description #description# in #d.title#</p>
			<cfloop query="d">
				<a href="/document/#urltitle#/#d.pg#">Pg. #d.pg#: #d.description#</a><br>
			</cfloop>
		</cfif>
	</cfoutput>
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
	
	<cfif isdefined("urltitle") and len(urltitle) gt 0>
		<cfset basQ=basQ & " and niceURLNumbers(l_title.label_value)='#urltitle#'">
	</cfif>
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
	
	<cfif isdefined("description") and len(description) gt 0>
		<cfif basFrm does not contain "l_description">
			<cfset basFrm=basFrm & ',media_labels l_description'>
			<cfset basWhr=basWhr & " and media.media_id=l_description.media_id and
				l_description.media_label='description'">
		</cfif>
		<cfset basQ=basQ & " and l_description.label_value = '#description#'">
	</cfif>

	<cfset ssql=basSQL & basFrm & basWhr & basQ & " group by l_title.label_value">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preservesinglequotes(ssql)#
	</cfquery>
	
	
	
	<cfdump var=#d#>
	
	<cfabort>
	
	
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
<cfif action is 'nothing' and (not isdefined("media_id") or len(media_id) is 0)>
	<cfheader statuscode="301" statustext="Moved permanently">
	<cfheader name="Location" value="/MediaSearch.cfm">
</cfif>
<!------------------------------->
<cfif action is 'show'>
<cfoutput>
	<cfquery name="doc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			media_uri,
			title.label_value mtitle,
			to_number(page.label_value) page,
			media.media_id,
			count(tag.media_id) numTags
		from
			media,
			media_labels title,
			media_labels page,
			tag
		where
			media.media_id=title.media_id and
			media.media_id=tag.media_id (+) and
			media.media_id=page.media_id and
			title.media_label='title' and
			page.media_label='page' and
			media_type='multi-page document' and
			niceURLNumbers(title.label_value)='#ttl#'
		group by
			media_uri,
			title.label_value,
			to_number(page.label_value),
			media.media_id
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
	<cfquery name="qmaxpage" dbtype="query">
		select max(page) npgs from doc
	</cfquery>
	<cfset maxPage=qmaxpage.npgs>
	<cfset title=doc.mtitle>
	<strong>#doc.mtitle#</strong>
		<form method="post" action="/document.cfm">
			<input type="hidden" name="action" value="findDocumentPage">
			<input type="hidden" name="urltitle" value="#ttl#">
			<label for="description">Search document by Description</label>
			<input type="text" size="50" name="description" id="description" placeholder="Description; prefix/suffix with % for substring">
			<input type="submit" value="search document" class="srchBtn">
		</form>
	<cfquery name="cpg" dbtype="query">
		select media_uri,media_id from doc where page=#pg#
	</cfquery>
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
	<cfquery name="mDet" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from media_flat where media_id=#cpg.media_id#
	</cfquery>
	
	
	



	<cfsavecontent variable="controls">
		<table>
			<tr>
				<td>Page</td>
				<td>
					<cfif pg gt 1>
						<cfset pp=pg-1>
						<a class="likeLink" href="/document/#ttl#/#pp#">Previous</a>
					</Cfif>
				</td>
				<td>
					<select name="pg" id="pg" onchange="document.location=this.value">
						<cfloop query="doc">
							<option <cfif doc.page is pg> selected="selected" </cfif>value="/document/#ttl#/#doc.page#">#doc.page#<cfif doc.numTags gt 0> (#doc.numTAGs# TAGs)</cfif></option>
						</cfloop>
					</select>
				</td>
				<td>
					<cfif pg lt maxPage>
						<cfset np=pg+1>
						<a class="likeLink" href="/document/#ttl#/#np#">Next</a>
					</Cfif>
				</td>
				<td> of #maxPage#</td>
			</tr>
		</table>
	</cfsavecontent>
	<table width="50%">
		<tr>
			<td>
				#controls#
			</td>
			<td align="right" class="valigntop">
				<div style="text-align:left">
				<cfset attrList="">
				<cfloop list="#mDet.labels#" index="i" delimiters="|">
					<cfset x=replace(i,"==",chr(7),"all")>
					<cfset r=listgetat(x,1,chr(7))>
					<cfset v=listgetat(x,2,chr(7))>
					<cfif r is not "title" and r is not "page">
						<cfif not listfind(attrList,"#r#: <strong>#v#</strong>","|")>
							<cfset attrList=listappend(attrList,"#r#: <strong>#v#</strong>","|")>
						</cfif>
					</cfif>
				</cfloop>
				<cfloop list="#attrList#" index="i" delimiters="|">
					<br>#i#
				</cfloop>					
				<cfset rattrList="">
				<cfloop list="#mDet.RELATIONSHIPS#" index="i" delimiters="|">
					<cfset x=replace(i,"==",chr(7),"all")>
					<cfset r=listgetat(x,1,chr(7))>
					<cfset v=listgetat(x,2,chr(7))>
					<cfif not listfind(rattrList,"#r#: <strong>#v#</strong>","|")>
						<cfset rattrList=listappend(rattrList,"#r#: <strong>#v#</strong>","|")>
					</cfif>
				</cfloop>
				<cfloop list="#rattrList#" index="i" delimiters="|">
					<br>#i#
				</cfloop>
				</div>
			</td>
		</tr>
		<tr>
			<td>
				<a href="/media/#cpg.media_id#">[ Media Details ]</a>
				<cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
					<a href="/media.cfm?action=edit&media_id=#cpg.media_id#">[ edit media ]</a>
				</cfif>
				<cfif relMedia.recordcount is 1>
					<a target="_blank" href="/exit.cfm?target=#relMedia.media_uri#">[ download master ]</a>
				</cfif>
			</td>
		</tr>
	</table>
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
				if ($("##pg").val()!=$("##pt").val()){
					$("##pt").val('');
				}
				loadTAG(#cpg.media_id#,'#cpg.media_uri#');
			});
		</script>
	</cfif>
	<div>#controls#</div>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">