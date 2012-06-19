<cfif not isdefined("guid")>
	<cfset guid="uam:mamm:1">
</cfif>
<cfif not isdefined("chs")>
	<cfset chs="100x100">
</cfif>
<cfoutput>

<p>
<br><a href="demo.cfm?guid=UAM:Ento:1">?guid=UAM:Ento:1</a>
<br><a href="demo.cfm?guid=UAM:Ento:1&chs=200x200">?guid=UAM:Ento:1&chs=200x200</a>
<br><a href="demo.cfm?guid=MVZ:Mamm:1234&chs=400x400">?guid=MVZ:Mamm:1234&chs=400x400</a>
</p>
<cfhttp url="https://chart.googleapis.com/chart" getasbinary="yes" path="/#application.webDirectory#/download" file="#guid#.png">
	<cfhttpparam type = "URL" name = "cht" value = "qr">
	<cfhttpparam type = "URL" name = "chs" value = "#chs#">
	<cfhttpparam type = "URL" name = "chl" value = "#guid#">
</cfhttp>



<img src="/download/#guid#.png">



</cfoutput>
