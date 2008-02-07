<cfinclude template="/includes/_header.cfm">
<cfoutput>
<form method="post" action="gmaptest.cfm">
<input type="hidden" name="action" value="go">
e:<input type="text" name="ColumnList">
<br>
<input type="text" name="in_or_out">
<input type="submit">

</form>
<cfif #action# is "go">
<hr>
#client.resultColumnList#
<hr>
<cfif in_or_out is "in">
in<br>
		<cfloop list="#ColumnList#" index="i">
		i=#i#<br>
		<cfif not ListFindNoCase(client.resultColumnList,i,",")>
			not there<br>
			<cfset client.resultColumnList = ListAppend(client.resultColumnList, i,",")>
		<cfelse>
			<cfset nothere=ListFindNoCase(client.resultColumnList,i,",")>
			nothere:#nothere#<br>
		</cfif>
		</cfloop>
	<cfelse>
	out<br>
		<cfloop list="#ColumnList#" index="i">
		i=#i#<br>
		<cfif ListFindNoCase(client.resultColumnList,i,",")>
			is there <br>
			<cfset client.resultColumnList = ListDeleteAt(client.resultColumnList, ListFindNoCase(client.resultColumnList,i,","),",")>
		</cfif>
		</cfloop>
	</cfif>
<hr>
#client.resultColumnList#
<hr>
</cfif>

</cfoutput>