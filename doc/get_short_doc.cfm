<cffunction
    name="ParseHTMLTag"
    access="public"
    returntype="struct"
    output="false"
    hint="Parses the given HTML tag into a ColdFusion struct.">

    <!--- Define arguments. --->
    <cfargument
        name="HTML"
        type="string"
        required="true"
        hint="The raw HTML for the tag."
        />

    <!--- Define the local scope. --->
    <cfset var LOCAL = StructNew() />

    <!--- Create a structure for the taget tag data. --->
    <cfset LOCAL.Tag = StructNew() />

    <!--- Store the raw HTML into the tag. --->
    <cfset LOCAL.Tag.HTML = ARGUMENTS.HTML />

    <!--- Set a default name. --->
    <cfset LOCAL.Tag.Name = "" />

    <!---
        Create an structure for the attributes. Each
        attribute will be stored by it's name.
    --->
    <cfset LOCAL.Tag.Attributes = StructNew() />


    <!---
        Create a pattern to find the tag name. While it
        might seem overkill to create a pattern just to
        find the name, I find it easier than dealing with
        token / list delimiters.
    --->
    <cfset LOCAL.NamePattern = CreateObject(
        "java",
        "java.util.regex.Pattern"
        ).Compile(
            "^<(\w+)"
            )
        />

    <!--- Get the matcher for this pattern. --->
    <cfset LOCAL.NameMatcher = LOCAL.NamePattern.Matcher(
        ARGUMENTS.HTML
        ) />

    <!---
        Check to see if we found the tag. We know there
        can only be ONE tag name, so using an IF statement
        rather than a conditional loop will help save us
        processing time.
    --->
    <cfif LOCAL.NameMatcher.Find()>

        <!--- Store the tag name in all upper case. --->
        <cfset LOCAL.Tag.Name = UCase(
            LOCAL.NameMatcher.Group( 1 )
            ) />

    </cfif>


    <!---
        Now that we have a tag name, let's find the
        attributes of the tag. Remember, attributes may
        or may not have quotes around their values. Also,
        some attributes (while not XHTML compliant) might
        not even have a value associated with it (ex.
        disabled, readonly).
    --->
    <cfset LOCAL.AttributePattern = CreateObject(
        "java",
        "java.util.regex.Pattern"
        ).Compile(
            "\s+(\w+)(?:\s*=\s*(""[^""]*""|[^\s>]*))?"
            )
        />

    <!--- Get the matcher for the attribute pattern. --->
    <cfset LOCAL.AttributeMatcher = LOCAL.AttributePattern.Matcher(
        ARGUMENTS.HTML
        ) />


    <!---
        Keep looping over the attributes while we
        have more to match.
    --->
    <cfloop condition="LOCAL.AttributeMatcher.Find()">

        <!--- Grab the attribute name. --->
        <cfset LOCAL.Name = LOCAL.AttributeMatcher.Group( 1 ) />

        <!---
            Create an entry for the attribute in our attributes
            structure. By default, just set it the empty string.
            For attributes that do not have a name, we are just
            going to have to store this empty string.
        --->
        <cfset LOCAL.Tag.Attributes[ LOCAL.Name ] = "" />

        <!---
            Get the attribute value. Save this into a scoped
            variable because this might return a NULL value
            (if the group in our name-value pattern failed
            to match).
        --->
        <cfset LOCAL.Value = LOCAL.AttributeMatcher.Group( 2 ) />

        <!---
            Check to see if we still have the value. If the
            group failed to match then the above would have
            returned NULL and destroyed our variable.
        --->
        <cfif StructKeyExists( LOCAL, "Value" )>

            <!---
                We found the attribute. Now, just remove any
                leading or trailing quotes. This way, our values
                will be consistent if the tag used quoted or
                non-quoted attributes.
            --->
            <cfset LOCAL.Value = LOCAL.Value.ReplaceAll(
                "^""|""$",
                ""
                ) />

            <!---
                Store the value into the attribute entry back
                into our attributes structure (overwriting the
                default empty string).
            --->
            <cfset LOCAL.Tag.Attributes[ LOCAL.Name ] = LOCAL.Value />

        </cfif>

    </cfloop>


    <!--- Return the tag. --->
    <cfreturn LOCAL.Tag />
</cffunction>


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




<cfdump
    var="#ParseHTMLTag( Trim( cfhttp.fileCOntent ) )#"
    label="ParseHTMLTag() For Input"
/>








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