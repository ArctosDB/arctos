<cfinclude template="/includes/_header.cfm">


<cfoutput>
	<cfloop from="1" to="100" index="i">
		<br>#i#: #chr(i)#
	</cfloop>
</cfoutput>