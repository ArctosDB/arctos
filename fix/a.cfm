<cfoutput>


<cfloop from="1" to="#len(x)#" index="i">
	<p>
		#i#
		<br>mid(x,i,1): #mid(x,i,1)#
		<br>asc(mid(x,i,1)): #asc(mid(x,i,1))#
	</p>
</cfloop>
</cfoutput>