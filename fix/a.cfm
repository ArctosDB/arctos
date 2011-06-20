<cfinclude template="/includes/functionLib.cfm">
<cfset list = "www.foo.com,http://www.foo.com,http://intranet/foo/foo.htm,http:/noslash.com">
<cfoutput>
<cfloop list="#list#" index="s">
#yesNoFormat(isURL(s))# - #s#<br>
</cfloop>
</cfoutput>