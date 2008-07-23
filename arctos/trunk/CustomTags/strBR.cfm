<cfset str2fix = attributes.str2fix>

<cfset str2fix = #replace(str2fix,"<br>","; ","all")#>

<cfset caller.fixedstring = #reverse(str2fix)#>

	
	