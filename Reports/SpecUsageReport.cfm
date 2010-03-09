<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfdump var=#url#>
	<cfloop list="#url.p#" index="l" delimiters="&">
		<cfset k=listgetat(l,1,"=")>
		<cfset v=listgetat(l,2,"=")>
		<cfset "#k#"=v>
	</cfloop>
	<cfdump var=#variables#>
</cfoutput>