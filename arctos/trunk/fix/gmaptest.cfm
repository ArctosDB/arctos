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
#session.resultColumnList#
<hr>
<cfif in_or_out is "in">
in<br>
		<cfloop list="#ColumnList#" index="i">
		i=#i#<br>
		<cfif not ListFindNoCase(session.resultColumnList,i,",")>
			not there<br>
			<cfset session.resultColumnList = ListAppend(session.resultColumnList, i,",")>
		<cfelse>
			<cfset nothere=ListFindNoCase(session.resultColumnList,i,",")>
			nothere:#nothere#<br>
		</cfif>
		</cfloop>
	<cfelse>
	out<br>
		<cfloop list="#ColumnList#" index="i">
		i=#i#<br>
		<cfif ListFindNoCase(session.resultColumnList,i,",")>
			is there <br>
			<cfset session.resultColumnList = ListDeleteAt(session.resultColumnList, ListFindNoCase(session.resultColumnList,i,","),",")>
		</cfif>
		</cfloop>
	</cfif>
<hr>
#session.resultColumnList#
<hr>
</cfif>

</cfoutput>