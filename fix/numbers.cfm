<cfset nl = "1,2,3,1.01,1.001,1.02">

<cfoutput>
<br>
#nl#
<br>
	<cfloop list="nl" index="i">
		#i#<br>
	</cfloop>
</cfoutput>