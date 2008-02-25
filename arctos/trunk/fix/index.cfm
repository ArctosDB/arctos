<!--- no security --->
<cfdirectory action="list" directory="/var/www/html/fix" name="d" sort="name ASC">
<cfoutput>
	<cfloop query="d">
		<a href="#name#">#name#</a><br>
	</cfloop>
</cfoutput>