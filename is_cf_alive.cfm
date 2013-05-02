<!--- set up a timer --->
<cfset tickBegin = GetTickCount()>
<!--- fetch arctos ---->
<cfhttp url="http://arctos.database.museum" method="head"></cfhttp>
<cfset tickEnd = GetTickCount()>
<cfset eTime = tickEnd - tickBegin>
<cfif etime lt 5000>
true
</cfif>