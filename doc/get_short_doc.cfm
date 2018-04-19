
<cfif not isdefined("fld")>
	<cfthrow message="get_doc called without field">
	<cfabort>
</cfif>
<cfset fld=trim(fld)>
<cfif left(fld,1) is "_" and len(fld) gt 2>
	<cfset fld=right(fld,len(fld)-1)>
</cfif>
<cfparam name="action" default="nothing">
<cfparam name="addCtl" default="1">
<cfif action is "nothing">
	<!---
		this should be hard-coded - all installations should call the same docs, arctos.database.museum hosts everything
		for testing:

			<cfhttp url="http://arctos.database.museum/doc/get_short_doc.cfm" charset="utf-8" method="get">

			<cfhttp url="http://arctos-test.tacc.utexas.edu/doc/get_short_doc.cfm" charset="utf-8" method="get">
	---->
	<cfhttp url="http://arctos-test.tacc.utexas.edu/doc/get_short_doc.cfm" charset="utf-8" method="get">
		<cfhttpparam type="url" name="action" value="getDoc">
		<cfhttpparam type="url" name="fld" value="#fld#">
		<cfhttpparam type="url" name="addCtl" value="#addCtl#">
	</cfhttp>
	<cfoutput>
		<cfdump var=#cfhttp#>

		<cfif cfhttp.fileContent contains "clickthrough">
			<br>got clickthrough

			<cfsavecontent variable="s"> This is some text. It is true that <a href="http://www.cnn.com">Harry Potter</a> is a good magician, but the real <a href="http://www.raymondcamden.com">question</a> is how he would stand up against Godzilla. That is what I want to <a href="http://www.adobe.com">see</a> - a Harry Potter vs Godzilla grudge match. Harry has his wand, Godzilla has his <a href="http://www.cfsilence.com">breath</a>, it would be <i>so</i> cool. </cfsavecontent>
			<br>s: #s#


			<cfset matches = reMatch("<[aA].?>.?</[aA]>",s)>
			<cfdump var="#matches#">




			<cfscript>
			result = REMatch("https?://([-\w\.]+)+(:\d+)?(/([\w/_\.]*(\?\S+)?)?)?", cfhttp.filecontent);
			</cfscript>

			<cfdump var=#result#>

			<!----

			cfhttp.Filecontent
			---->

		</cfif>








		#cfhttp.fileContent#
	</cfoutput>
</cfif>
<cfif action is "getDoc">
	<!---
		This part runs ONLY on arctos.database.museum, the one and only source of this information.
	--->
	<cftry>
		<cfquery name="d" datasource="cf_dbuser">
			select * from ssrch_field_doc where cf_variable = '#lcase(fld)#'
		</cfquery>
		<cfset r="">
		<cfif d.recordcount is not 1>
			<cfset r=r & '<div>No documentation is available for #fld#.</div>'>
			<!---
			<cfset probs=listappend(probs,'short doc not found for #fld#',';')>
			--->
		<cfelse>
			<cfset r=r & '<h2>#d.DISPLAY_TEXT#</h2>'>
			<cfset r=r & '<div style="margin:1em;padding:1em;" id="sd_definition">#d.definition#</div>'>
			<!---
			<cfif len(d.definition) is 0 or listlen(d.definition,' ') lt 5>
				<cfset probs=listappend(probs,'definition for #fld# seems shady',';')>
			</cfif>
			--->
			<cfif len(d.search_hint) gt 0>
				<cfset r=r & '<div style="margin:1em;background: ##ffffe6;padding:1em;"><strong>Search Hint:</strong> '>
				<cfif left(d.search_hint,4) is 'http'>
					<cfset r=r & '<a href="#d.search_hint#" target="_blank">[ Search Hint ]</a></div>'>
				<cfelse>
					<cfset r=r & '#d.search_hint#</div>'>
				</cfif>
				<!---
			<cfelse>
				<cfif d.SPECIMEN_QUERY_TERM is 1>
					<cfset probs=listappend(probs,'#fld# is marked as a SPECIMEN_QUERY_TERM and does not have a search_hint',';')>
				</cfif>
				--->
			</cfif>
			<cfif len(d.DOCUMENTATION_LINK) gt 0>
				<cfset r=r & '<div style="margin:1em;padding:1em;"><a id="sd_doclink" href="#d.DOCUMENTATION_LINK#" target="_blank">[ More Information ]</a></div>'>
				<!----
				<!--- anchor? ---->
				<cfif d.DOCUMENTATION_LINK contains "##">
					<cfhttp url="#d.DOCUMENTATION_LINK#" method="GET"></cfhttp>
					<cfif left(cfhttp.statuscode,3) is not "200">
						<cfset probs=listappend(probs,'DOCUMENTATION_LINK for #fld# is broken',';')>
					</cfif>
					<cfset anchor=listlast(d.DOCUMENTATION_LINK,'##')>
					<cfif cfhttp.fileContent does not contain 'id="#anchor#"'>
						<cfset probs=listappend(probs,'DOCUMENTATION_LINK anchor for #fld# is broken',';')>
					</cfif>
				<cfelse>
					<!--- just HEAD ---->
					<cfhttp url="#d.DOCUMENTATION_LINK#" method="HEAD"></cfhttp>
					<cfif left(cfhttp.statuscode,3) is not "200">
						<cfset probs=listappend(probs,'DOCUMENTATION_LINK for #fld# is broken',';')>
					</cfif>
				</cfif>
			<cfelse>
				<cfset probs=listappend(probs,'#fld# has no DOCUMENTATION_LINK',';')>
				---->
			</cfif>
			<cfif len(d.CONTROLLED_VOCABULARY) gt 0>
				<cfset r=r & '<div><a href="/info/ctDocumentation.cfm?table=#d.CONTROLLED_VOCABULARY#" target="_blank">[ Controlled Vocabulary ]</a></div>'>
			</cfif>
		</cfif>
		<!----
		<cfif len(probs) gt 0>
			<cfoutput>
			<cfmail subject="documentation problems" to="#Application.bugReportEmail#,#Application.DataProblemReportEmail#" from="docprobs@#Application.fromEmail#" type="html">
				Potential problems for #fld#.
				<p>
					Fix under Manage/Field-Level Documentation
				</p>
				<cfloop list="#probs#" delimiters=";" index="i">
					<p>
						#i#
					</p>
				</cfloop>
			</cfmail>
			</cfoutput>
		</cfif>
		---->
		<cfsavecontent variable="response"><cfoutput>#r#</cfoutput></cfsavecontent>
		<cfcatch>
			<cfsavecontent variable="response"><cfoutput>Error: No further information available.</cfoutput><cfdump var=#cfcatch#></cfsavecontent>
		</cfcatch>
	</cftry>
	<cfscript>
        getPageContext().getOut().clearBuffer();
        writeOutput(response);
	</cfscript>

	<!----
	<cfset r='<div position="relative">'>
	<cfif addCtl is 1>
		<cfset r=r & '<span class="docControl" onclick="removeHelpDiv()">X</span>'>
	</cfif>
	<cfif d.recordcount is 1>
		<cfset r=r & '<div class="docTitle">#d.DISPLAY_TEXT#</div><div class="docDef">#d.definition#</div><div class="docSrchTip">#d.search_hint#</div>'>
		<cfif len(d.DOCUMENTATION_LINK) gt 0>

			<!---- switch this in after dealing with data bits of https://github.com/ArctosDB/arctos/issues/1044

			<cfset r=r & '<span class="likeLink" onclick="removeHelpDiv();getDocs(''publications'',''full_citation'')" >Full Citation</label>'>

			----->

				<cfset r=r & '<a class="docMoreInfo" href="#d.DOCUMENTATION_LINK#"'>
				<cfif addCtl is 1>
					<cfset r=r & 'target="_blank" onclick="removeHelpDiv()"'>
				</cfif>
				<cfset r=r & '>[ More Information ]</div>'>
		</cfif>

		<cfif len(d.CONTROLLED_VOCABULARY) gt 0>
			<cfif left(d.CONTROLLED_VOCABULARY,2) is "CT">
				<cfset vocab='<a class="docMoreInfo" href="/info/ctDocumentation.cfm?table=#d.CONTROLLED_VOCABULARY#"'>
				<cfif addCtl is 1>
					<cfset vocab=vocab & ' target="_docMoreWin" onclick="removeHelpDiv()"'>
				</cfif>
				<cfset vocab=vocab & '>[ Controlled Vocabulary ]</a>'>
			<cfelse>
				<cfset vocab='<div class="docSrchTip">Vocabulary: #d.CONTROLLED_VOCABULARY#</div>'>
			</cfif>
			<cfset r=r & '#vocab#'>
		</cfif>
	<cfelse>
		<cfset r=r & '<div class="docTitle">No documentation is available for #fld#.</div>'>
		<cfmail subject="doc not found" to="#Application.bugReportEmail#,#Application.DataProblemReportEmail#" from="docMIA@#Application.fromEmail#" type="html">
			short doc not found for #fld#
		</cfmail>
	</cfif>
	<cfset r=r & '</div>'>
	<cfsavecontent variable="response"><cfoutput>#r#</cfoutput></cfsavecontent>
	<cfcatch>
		<cfsavecontent variable="response"><cfoutput>Error: No further information available.</cfoutput><cfdump var=#cfcatch#></cfsavecontent>
	</cfcatch>
	</cftry>
	<cfscript>
        getPageContext().getOut().clearBuffer();
        writeOutput(response);
	</cfscript>
	---->
</cfif>