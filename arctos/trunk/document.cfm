<cfinclude template="/includes/_header.cfm">
<cfif isdefined("media_id") and media_id gt 0>
	<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			<!---
			<cflocation url="/document.cfm?action=show&showpage=#r.pg#&mtitle=#r.ttl#" addtoken="false">
			<cfif isdefined("cgi.REDIRECT_URL") and len(cgi.REDIRECT_URL) gt 0>

			---->
		<cfelse>
			fail
			<cfabort>
		</cfif>
	</cfoutput>
</cfif>

Nothing to see here yet. Documents are still at 
<a href="http://bscit.berkeley.edu/mvz/volumes.html" target="_blank">http://bscit.berkeley.edu/mvz/volumes.html</a>.
 <hr>
<cfif action is 'nothing'>
	<cfset title='Document Viewer'>
<cfoutput>
	<cfquery name="titles" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	</cfquery>
	<form name="g" method="post" action="document.cfm">
		<input type="hidden" name="action" value="show">
		<label for="mtitle">Title</label>
		<select name="mtitle" id="mtitle" size="1">
			<cfloop query="titles">
				<option value="#label_value#">#label_value#</option>
			</cfloop>
		</select>
		<input type="submit">
	</form>
</cfoutput>
</cfif>
<cfif action is 'pdf'>
<cfoutput>
	<cfquery name="doc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			title.label_value='#mtitle#'
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
	<cfset fname = replace(mtitle, " ", "_", "ALL") />
	<cfset fname = REReplace(fname, "[^a-zA-Z0-9-_]", "", "ALL") />
	<cfset filePath="#application.webDirectory#/temp/#fname#.pdf"> 
	<cffile action="write" file="#filePath#" output="#toBinary(mergedpdf)#">
	<cfheader name="Content-Disposition" value="attachment; filename=#getFileFromPath(filePath)#">
	<cfcontent file="#filePath#" type="application/pdf">
</cfoutput>
</cfif>
<!------------------------------->
<cfif action is 'show'>
<cfoutput>
	<cfset title=mtitle>
	<cfif not isdefined("showPage")>
		<cfset showPage=1>
	</cfif>
	<cfquery name="doc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			title.label_value='#mtitle#'
		order by
			to_number(page.label_value)			
	</cfquery>
	<cfquery name="pg" dbtype="query">
		select max(page) npgs from doc
	</cfquery>
	<cfset maxPage=pg.npgs>
	<strong>#mtitle#</strong>
	<a href="document.cfm?action=pdf&mtitle=#mtitle#">PDF</a>
	<form name="fn" method="post" action="document.cfm">
		<input type="hidden" name="mtitle" value="#mtitle#">
		<input type="hidden" name="action" value="show">
		<table>
			<tr>
				<td>Page</td>
				<td>
					<cfif showPage gt 1>
						<span class="infoLink" 
							onclick="fn.showPage.value=fn.showPage.value-1;fn.submit();">Previous</span>
					</Cfif>
				</td>
				<td>
					<select name="showPage" id="showPage" onchange="fn.submit();">
						<cfloop from="1" to="#maxPage#" index="p">
							<option <cfif p is showPage> selected </cfif>value="#p#">#p#</option>
						</cfloop>
					</select>
				</td>			
				<td>
					<cfif showPage lt maxPage>
						<span class="infoLink" 
							onclick="fn.showPage.value=parseInt(fn.showPage.value)+1;fn.submit();">Next</span>
					</Cfif>
				</td>
				<td> of #maxPage#</td>
			</tr>
		</table>
	</form>
	<cfquery name="cpg" dbtype="query">
		select media_uri,media_id from doc where page=#showPage#
	</cfquery>
	 <cfquery name="tag" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) n from tag where media_id=#cpg.media_id#
	</cfquery>
	<cfif tag.n gt 0>
		<input type="hidden" id="media_id" value="#cpg.media_id#">		
		<input type="hidden" id="imgURL" value="#cpg.media_uri#">
		<script language="JavaScript" src="/includes/jquery/jquery.imgareaselect.pack.js" type="text/javascript"></script>
		<link rel="stylesheet" type="text/css" href="/includes/jquery/css/imgareaselect-default.css">
		<link rel="stylesheet" type="text/css" href="/includes/jquery/css/ui-lightness/jquery-ui-1.7.2.custom.css">
		<script language="JavaScript" src="/includes/jquery/jquery-ui-1.7.2.custom.min.js" type="text/javascript"></script>
		<script language="JavaScript" src="/includes/jquery/scrollTo.js" type="text/javascript"></script>
		<cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
			<script language="JavaScript" src="/includes/TAG.js" type="text/javascript"></script>
		<cfelse>
			<script language="JavaScript" src="/includes/showTAG.js" type="text/javascript"></script>
		</cfif>		
		<div id="navDiv">
		<a href="MediaSearch.cfm?action=search&media_id=#cpg.media_id#">Back to Media</a>
		<div id="info"></div>
		<cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
			<form name="f">
			<label for="RefType_new">Create TAG type....</label>
			<div id="newRefCell" class="newRec">
			<select id="RefType_new" name="RefType_new" onchange="pickRefType(this.id,this.value);">
				<option value=""></option>
				<option value="comment">Comment Only</option>
				<option value="cataloged_item">Cataloged Item</option>
				<option value="collecting_event">Collecting Event</option>
				<option value="locality">Locality</option>
				<option value="agent">Agent</option>
			</select>
			<span id="newRefHidden" style="display:none">
				<label for="RefStr_new">Reference</label>
				<input type="text" id="RefStr_new" name="RefStr_new" size="50">
				<input type="hidden" id="RefId_new" name="RefId_new">
				<label for="Remark_new">Remark</label>
				<input type="text" id="Remark_new" name="Remark_new" size="50">
				<input type="hidden" id="t_new">
				<input type="hidden" id="l_new">
				<input type="hidden" id="h_new">
				<input type="hidden" id="w_new">
				<br>
				<input type="button" id="newRefBtn" value="create TAG">
			</span>
			</div>
		</form>
		<hr>
		<form name="ef" method="post" action="TAG.cfm">
		<input type="submit" value="save all">
		<input type="hidden" name="imgH" id="imgH">
		<input type="hidden" name="imgW" id="imgW">
		<div id="editRefDiv"></div>
		<input type="hidden" id="media_id" name="media_id" value="#cpg.media_id#">
		<input type="hidden" name="action" value="fd">
		<input type="submit" value="save all">
		</form>
		</cfif>
		<div id="editRefDiv"></div>
	</div>
	</cfif>
	<div id="imgDiv">
		<img src="#cpg.media_uri#" alt="This should be a field notebook page" id="theImage">
	</div>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">