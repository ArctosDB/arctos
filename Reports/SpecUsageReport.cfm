<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfdump var=#url#>
	<cfloop list="#url.p#" index="l">
		<cfset k=listgetat(l,1,"=")>
		<cfset v=listgetat(l,2,"=")>
	</cfloop>
	<cfdump var=#variables#>
</cfoutput>