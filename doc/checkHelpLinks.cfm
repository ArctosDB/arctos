<!---
	dependencies:

		create table cf_temp_doc_page_link (frm varchar2(4000),rawtag varchar2(4000),id varchar2(4000));

---->


<cfinclude template="/includes/_header.cfm">


<cfquery name="d" datasource="uam_god">
				create table cf_temp_doc_page_link (frm varchar2(4000),rawtag varchar2(4000),id varchar2(4000))
		</cfquery>

		made a table....
<cfset title="find broke stuff">
<p>
	This is an iterative (because it's slow) single-user form.
</p>

<p>
	<a href="checkHelpLinks.cfm?action=getLinks">getLinks</a> - do this first, it crawls through Arctos code and
	finds all helpLinks.
</p>

<p>
	<a href="checkHelpLinks.cfm?action=showGetLinks">showGetLinks</a> - see the results of getLinks
</p>
<p>
	<a href="checkHelpLinks.cfm?action=checkUsedExists">checkUsedExists</a> - see if everything in the code has an entry in the doc table
</p>
<p>
	<a href="checkHelpLinks.cfm?action=checkLinks">checkLinks</a> - fetch all distinct DOCUMENTATION_LINKs from the doc table; check anchors
</p>
<p>
	<a href="checkHelpLinks.cfm?action=showDocs">showDocs</a> - tableify documentation used in code
</p>

<cfif action is "showDocs">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from ssrch_field_doc where cf_variable in (select id from cf_temp_doc_page_link)
			order by cf_variable
		</cfquery>
		<p>
			Click variable to edit. READ THE EDIT FORM CAREFULLY BEFORE DOING ANYTHING!!
		</p>
		<table border>
			<tr>
				<th>CF_VARIABLE</th>
				<th>DEFINITION</th>
				<th>DOCUMENTATION_LINK</th>
				<th>DISPLAY_TEXT</th>
				<th>CONTROLLED_VOCABULARY</th>
				<th>PLACEHOLDER_TEXT</th>
				<th>SEARCH_HINT</th>
				<th>DATA_TYPE</th>
				<th>SQL_ELEMENT</th>
				<th>SPECIMEN_RESULTS_COL</th>
				<th>SPECIMEN_QUERY_TERM</th>
				<th>DISP_ORDER</th>
			</tr>
			<cfloop query="d">
				<tr>
					<td>
						<a href="/doc/field_documentation.cfm?cf_variable=#CF_VARIABLE#&popEdit=true" target="_blank">#CF_VARIABLE#</a>
					</td>
					<td>#DEFINITION#</td>
					<td>
						<cfif len(DOCUMENTATION_LINK) gt 0>
							<a href="#DOCUMENTATION_LINK#" target="_blank">#DOCUMENTATION_LINK#</a>
						</cfif>
					</td>
					<td>#DISPLAY_TEXT#</td>
					<td>#CONTROLLED_VOCABULARY#</td>
					<td>#PLACEHOLDER_TEXT#</td>
					<td>#SEARCH_HINT#</td>
					<td>#DATA_TYPE#</td>
					<td>#SQL_ELEMENT#</td>
					<td>#SPECIMEN_RESULTS_COL#</td>
					<td>#SPECIMEN_QUERY_TERM#</td>
					<td>#DISP_ORDER#</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<cfif action is "checkLinks">
	<cfquery name="d" datasource="uam_god">
		select distinct DOCUMENTATION_LINK from ssrch_field_doc where DOCUMENTATION_LINK is not null
	</cfquery>
	<p>
		splat-f "ALERT"
	</p>
	<cfoutput>
		<cfloop query="d">
			<hr>
			<p>checking #DOCUMENTATION_LINK#....</p>
			<cfhttp url="#d.DOCUMENTATION_LINK#" method="GET"></cfhttp>
			<br>status: #cfhttp.statuscode#
			<cfif left(cfhttp.statuscode,3) is not "200">
				<br>ALERT: DOCUMENTATION_LINK seems to be broken; http dump follows
				<cfdump var=#cfhttp#>
			</cfif>
			<cfif d.DOCUMENTATION_LINK contains "##">
			<br>link has anchor....
				<cfset anchor=listlast(d.DOCUMENTATION_LINK,'##')>
				<br>anchor is #anchor#
				<cfif cfhttp.fileContent does not contain 'id="#anchor#"'>
					<br>ALERT: anchor appears to be busted; http dump follows
					<cfdump var=#cfhttp#>
				</cfif>
			</cfif>
		</cfloop>
	</cfoutput>
</cfif>

<cfif action is "checkUsedExists">
	<cfoutput>
		<cfquery name="incode" datasource="uam_god">
			select id from cf_temp_doc_page_link where id not in (select cf_variable from ssrch_field_doc)
		</cfquery>
		<p>
			Anything listed here is used in the code but does NOT exist in the documentation. Add it. Now!
		</p>
		<cfdump var=#incode#>
	</cfoutput>
</cfif>

<cfif action is "showGetLinks">
	<cfquery name="d" datasource="uam_god">
		select * from cf_temp_doc_page_link
	</cfquery>
	<cfquery name="did" dbtype="query">
		select id from d group by id order by id
	</cfquery>
	<cfoutput>
		<table border>
			<tr>
				<th>cf_variable</th>
				<th>called from</th>
				<th>raw tag</th>
			</tr>
			<cfloop query="did">
				<tr>
					<td>#id#</td>
					<cfquery name="qid" dbtype="query">
						select frm from d where id='#id#' group by frm
					</cfquery>
					<td>
						<cfloop query="qid">
							<div style="font-size:small;white-space: nowrap;">#replace(frm,Application.webDirectory,'','all')#</div>
						</cfloop>
					</td>
					<cfquery name="r" dbtype="query">
						select rawtag from d where id='#id#' group by rawtag
					</cfquery>
					<cfset tgs="">
					<cfloop query='r'>
						<cfset rt=rawtag>
						<cfset rt=replace(rt,'\s\s+',' ','all')>
						<cfset rt=replace(rt,chr(10),'',"all")>
						<cfset rt=replace(rt,chr(9),'',"all")>
						<cfset rt=replace(rt,chr(13),'',"all")>
						<cfset tgs=listappend(tgs,rt,chr(10))>
					</cfloop>
					<td><xmp>#tgs#</xmp></td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>

<cfif action is "getLinks">
<cfset res=  DirectoryList(Application.webDirectory,true,"path","*.cf*")>
<cfoutput>
	<cfquery name="d" datasource="uam_god">
		delete from cf_temp_doc_page_link
	</cfquery>
	<cftransaction>
		<cfloop array="#res#" index="f">
			<!--- ignore cfr etc --->
			<cfif listlast(f,".") is "cfm" or listlast(f,".") is "cfc">
				<cffile action = "read" file = "#f#" variable = "fc">
				<cfif fc contains "helpLink">
					<!----<br>-------------------------- something to check here -------------------->
					<cfset l = REMatch('(?i)<[^>]+class="helpLink"[^>]*>(.+?)>', fc)>
					<cfloop array="#l#" index='h'>
						<!----
						h: <textarea rows="4" cols="80">#h#</textarea>
						---->
						<cfset go=false>
						<cfif h contains 'id='>
							<cfset go=true>
							<cfset idSPos=find("id=",h)+4>
							<cfset nqPos=find('"',h,idsPos)>
							<cfset theID=mid(h,idSPos,nqPos-idSPos)>
							<cfif left(theID,1) is "_">
								<cfset theID=right(theID,len(theID)-1)>
							</cfif>
						<cfelseif h contains 'data-helplink='>
							<cfset go=true>
							<cfset idSPos=find("data-helplink=",h)+15>
							<cfset nqPos=find('"',h,idsPos)>
							<cfset theID=mid(h,idSPos,nqPos-idSPos)>
							<cfif left(theID,1) is "_">
								<cfset theID=right(theID,len(theID)-1)>
							</cfif>
						</cfif>
						<cfif go is true>
							<cfquery name="d" datasource="uam_god">
								insert into cf_temp_doc_page_link(frm,rawtag,id) values ('#f#','#h#','#theID#')
							</cfquery>
						</cfif>
					</cfloop>
				</cfif>
			</cfif>
		</cfloop>
	</cftransaction>
	all done
</cfoutput>
</cfif>















<cfinclude template="/includes/_footer.cfm">
