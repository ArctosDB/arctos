<cfinclude template="/includes/functionLib.cfm">
<cfset list = "1999,1.234,1.23,bob">
<cfoutput>
<cfloop list="#list#" index="s">
#yesNoFormat(isYear(s))# - #s#<br>
</cfloop>
</cfoutput>