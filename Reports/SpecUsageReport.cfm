<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfdump var=#url#>
	<cfloop list="#StructKeyList(url)#" index="key">
		<cfset "#key#"=url[key]>
	</cfloop>
		
		<hr>
	<!---
	<cfloop list="#url#" index="l" delimiters="&">
		------#l#-------
		<cfset k=listgetat(l,1,"=")>
		<cfset v=listgetat(l,2,"=")>
		-------#k#--------
		----------#v#--------
		<cfset "#k#"=v>
	</cfloop>
	--->
	<cfdump var=#variables#>
</cfoutput>