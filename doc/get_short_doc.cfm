<cfif not isdefined("fld")>bad call<cfabort></cfif>
<cfset fld=trim(fld)>
<cfif left(fld,1) is "_" and len(fld) gt 2>
	<cfset fld=right(fld,len(fld)-1)>
</cfif>
<cfparam name="action" default="nothing">
<cfparam name="addCtl" default="1">
<cfif action is "nothing">
	<!--- this should be hard-coded - all installations should call the same docs, arctos.database.museum hosts everything --->

	<!----  for testing
	<cfhttp url="http://arctos-test.tacc.utexas.edu/doc/get_short_doc.cfm" charset="utf-8" method="get">
	---->
		<cfhttp url="http://arctos.database.museum/doc/get_short_doc.cfm" charset="utf-8" method="get">

		<cfhttpparam type="url" name="action" value="getDoc">
		<cfhttpparam type="url" name="fld" value="#fld#">
		<cfhttpparam type="url" name="addCtl" value="#addCtl#">
	</cfhttp>
<cfoutput>#cfhttp.fileContent#</cfoutput>
</cfif>
<cfif action is "getDoc">
	<!---
		This part runs ONLY on arctos.database.museum, the one and only source of this information.
	--->
	<cftry>
	<cfquery name="d" datasource="cf_dbuser">
		select * from ssrch_field_doc where cf_variable = '#lcase(fld)#'
	</cfquery>
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
</cfif>