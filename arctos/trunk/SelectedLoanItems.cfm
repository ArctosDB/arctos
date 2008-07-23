<cfif not isdefined("item")>
	<cfset item = "">
</cfif>
<cfif not isdefined("subsample")>
	<cfset subsample = "">
</cfif>

<cfoutput>
#item#
<br>#subsample#
</cfoutput>

