<cfquery name="d" datasource="uam_god">
	select * from da
</cfquery>
<cfoutput>
<!----
<table border>
	<cfloop query="d">
		<tr>
			<td>#WPT#</td>
			<td>#LLSTR#</td>
			<td>#ALT#</td>
			<cfset daSpace = find(" ",alt)>
			<cfset altFt = left(alt,daSpace)>
			<td>#altFt#</td>
			<cfset lat = mid(llstr,2,9)>
			<cfset latd = left(lat,2)>
			<cfset latm = right(lat,6)>
			<td>#lat#</td>
			<td>#latd#</td>
			<td>#latm#</td>
			<cfset long = mid(llstr,13,10)>
			<cfset lond = left(long,3)>
			<cfset lonm = right(long,6)>
			<td>#long#</td>
			<td>#lond#</td>
			<td>#lonm#</td>
		</tr>
	</cfloop>
</table>
---->
<cfloop query="d">
		
			<cfset daSpace = find(" ",alt)>
			<cfset altFt = left(alt,daSpace)>
			
			<cfset lat = mid(llstr,2,9)>
			<cfset latd = left(lat,2)>
			<cfset latm = right(lat,6)>
			
			<cfset long = mid(llstr,13,10)>
			<cfset lond = left(long,3)>
			<cfset lonm = right(long,6)>
			#WPT#|#altFt#|#latd#|#latm#|#lond#|#lonm#<br>
	</cfloop>
</cfoutput>