<cfoutput>

<cfset x="sjöstedti">



<cfloop from="1" to="#length(x)#" index="i">
	<p>
		#i#
		<br>mid(x,i,1): #mid(x,i,1)#
		<br>asc(mid(x,i,1)): #asc(mid(x,i,1))#
	</p>
</cfloop>
</cfoutput>