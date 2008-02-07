<cfset str2fix = attributes.str2fix>

<cfset str2fix = #replace(str2fix,"'","''","all")#>
<cfset str2fix = #replace(str2fix,"''","'","first")#>
<cfset str2fix = #replace(reverse(str2fix),"''","'","first")#>
<cfset caller.fixedstring = #reverse(str2fix)#>

	
	