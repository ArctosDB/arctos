<cfsilent>
<!--- 
|| BEGIN FUSEDOC ||

|| PROPERTIES ||
Author: Erki Esken, erki@dreamdrummer.com
Version: 1.2
Server Requirements: ColdFusion 4.5+

|| RESPONSIBILITIES ||
I clean input string from CF tags, SCRIPT blocks, dangerous HTML tags,
HTML form tags and disable DOM event handlers. You can explicitly tell
me not to remove some of the things named above. Or alternativly I can
just escape all tags so that <table> becomes &lt;table&gt; etc.

|| HISTORY ||
25.04.2001, first created
25.04.2001, added "javascript:" and "vbscript:" removing, also SERVER and BUTTON tag removing
07.09.2001, added META and PARAM tags, improved SCRIPT block removing, added BODY tags removing, also added CFEXIT if an end tag was found

|| ATTRIBUTES ||
--> input: a STRING
--> [r_output]: a STRING (returned variable name) default=clean_code
--> [escapeAllTags]: a BOOLEAN default=no
--> [removeCFtags]: a BOOLEAN default=yes
--> [removeBodyTags]: a BOOLEAN default=no
--> [removeScriptBlocks]: a BOOLEAN default=yes
--> [removeScripts]: a BOOLEAN default=yes
--> [removeDangerousHTMLtags]: a BOOLEAN default=yes
--> [removeHTMLformTags]: a BOOLEAN default=yes
--> [removeDOMeventHandlers]: a BOOLEAN default=yes
<-- caller.&r_output&: a STRING

|| END FUSEDOC ||
--->

<!--- Check if CodeCleaner was called as a Custom Tag or module --->
<cfif NOT IsDefined("ThisTag.ExecutionMode")>
	<cfthrow type="CustomTags.CodeCleaner" message="CodeCleaner was not called as a Custom Tag or module.">
<!--- Check for end tag, if found and in end mode, then just exit tag --->
<cfelseif ThisTag.HasEndTag AND ThisTag.ExecutionMode EQ "end">
	<cfexit method="EXITTAG">
</cfif>

<!--- Parameters --->
<cftry>
	<cfparam name="attributes.input" type="string">
	<cfparam name="attributes.r_output" default="clean_code" type="string">
	<cfparam name="attributes.escapeAllTags" default="no" type="boolean">
	<cfparam name="attributes.removeCFtags" default="yes" type="boolean">
	<cfparam name="attributes.removeBodyTags" default="no" type="boolean">
	<cfparam name="attributes.removeScriptBlocks" default="yes" type="boolean">
	<cfparam name="attributes.removeScripts" default="yes" type="boolean">
	<cfparam name="attributes.removeDangerousHTMLtags" default="yes" type="boolean">
	<cfparam name="attributes.removeHTMLformTags" default="yes" type="boolean">
	<cfparam name="attributes.removeDOMeventHandlers" default="yes" type="boolean">
    <cfparam name="attributes.removeSqlNoNo" default="yes" type="boolean">
	<cfcatch>
		<cfthrow type="CustomTags.CodeCleaner" message="Required attributes not defined or error in attributes formating.">
	</cfcatch>
</cftry>

<cftry>
	<cfscript>
	// Set attributes.input to local variable
	tmp = attributes.input;
	
	if (attributes.escapeAllTags) {
		// Just escape all tags
		tmp = Replace(tmp, "<", "&lt;", "ALL");
		tmp = Replace(tmp, ">", "&gt;", "ALL");
	} else {
		// Remove CF tags
		if (attributes.removeSqlNoNo)
			tmp = REReplaceNoCase(tmp, "(/?(update|insert|delete|drop|create|alter|dba_|user_|all_|set|execute|exec|begin|end|declare)[^>]*)", "", "ALL");
		
		if (attributes.removeCFtags)
			tmp = REReplaceNoCase(tmp, "(<CF[^>]*>)(.*(</CF[^>]*>))?", "", "ALL");
		
		// Remove BODY tags (leaves only what was between <body> and </body>, everything else is removed)
		if (attributes.removeBodyTags) {
			tmp = REReplaceNoCase(tmp, ".*<BODY[^>]*>", "", "ALL");
			tmp = REReplaceNoCase(tmp, "</BODY[^>]*>.*", "", "ALL");
		}

		// Remove SCRIPT blocks
		if (attributes.removeScriptBlocks)
			tmp = REReplaceNoCase(tmp, "(<SCRIPT[^>]*>)(.*(</SCRIPT[^>]*>))?", "", "ALL");
		
		// Remove dangerous HTML tags
		if (attributes.removeDangerousHTMLtags)
			tmp = REReplaceNoCase(tmp, "(</?(APPLET|EMBED|FRAME|FRAMESET|IFRAME|ILAYER|LAYER|META|OBJECT|PARAM|SERVER)[^>]*>)", "", "ALL");
		
		// Remove HTML form tags
		if (attributes.removeHTMLformTags)
			tmp = REReplaceNoCase(tmp, "(</?(BUTTON|FORM|INPUT|KEYGEN|OPTION|SELECT|TEXTAREA)[^>]*>)", "", "ALL");
		
		// Remove "javascript:" and "vbscript:"
		if (attributes.removeScripts)
			tmp = REReplaceNoCase(tmp, "javascript:|vbscript:", "", "ALL");
		
		// Disable DOM event handlers by changing them to innocent foo attribute that gets ignored by the browser
		if (attributes.removeDOMeventHandlers) {
			// All DOM event handlers
			domEventsRegExp = "onabort|onafterupdate|onbeforeunload|onbeforeupdate|onblur|onbounce|onchange|onclick|ondataavailable|ondatasetchanged|ondatasetcomplete|ondblclick|ondragdrop|ondragstart|onerror|onerrorupdate|onfilterchange|onfinish|onfocus|onhelp|onkeydown|onkeypress|onkeyup|onload|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|onmove|onreadystatechange|onreset|onresize|onrowenter|onrowexit|onscroll|onselect|onselectstart|onstart|onsubmit|onunload";
			tmp = REReplaceNoCase(tmp, domEventsRegExp, "foo", "ALL");
		}
	}
	</cfscript>
	<cfcatch>
		<cfthrow type="CustomTags.CodeCleaner" message="Error executing regular expressions on input string.">
	</cfcatch>
</cftry>

<!--- Set the return variable --->
<cfset dummy = SetVariable("caller." & attributes.r_output, tmp)>

</cfsilent>
