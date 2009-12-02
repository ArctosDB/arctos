<cfinclude template="/includes/_header.cfm">


Nothing to see here yet. Documents are still at <a href="http://bscit.berkeley.edu/mvz/" target="_blank">http://bscit.berkeley.edu/mvz/</a>.
 <hr>
<cfif action is 'nothing'>
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
	<cfif not isdefined("showPage")>
		<cfset showPage=1>
	</cfif>
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
		select media_uri from doc where page=#showPage#
	</cfquery>
	<img src="#cpg.media_uri#" alt="This should be a field notebook page">
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">