<cfinclude template="/includes/_header.cfm">
<cfset title='vertnet tableizer thingee'>
<cfoutput>
<script src="/includes/sorttable.js"></script>
<cfif len(CGI.query_string) is 0>need some url stuff<cfabort></cfif>
<cfset getThis="http://canary.vert-net.appspot.com/api/search?#CGI.query_string#">
fetching #getThis#
<cfhttp method="get" url="#getThis#"></cfhttp>
<cfset cfo=DeserializeJSON(cfhttp.FileContent)>
<br>found #ArrayLen(cfo)# records
<table border id="t" class="sortable">
<cfloop from="1" to="#ArrayLen(cfo)#" index="o">
	<cfset thisLine=cfo[o]>
	<cfif o is 1>
		<tr>
		<cfloop list="#StructKeyList(thisLine)#" index="h">
			<th>#h#</th>
		</cfloop>
		</tr>
	</cfif>
	<tr>
	<cfloop list="#StructKeyList(thisLine)#" index="h">
		<td>#thisLine[h]#</td>
	</cfloop>
	</tr>
</cfloop>
</table>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">