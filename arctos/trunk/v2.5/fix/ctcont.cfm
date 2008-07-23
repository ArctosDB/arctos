<cfif isdefined("session.bob")>i see bob

<cfoutput query="session.bob" startrow="#session.startrow#" maxrows="#session.maxrows#">
#cat_num#<br>

</cfoutput>
<cfelse>

no bob

</cfif>
<cfdump var=#session#>
