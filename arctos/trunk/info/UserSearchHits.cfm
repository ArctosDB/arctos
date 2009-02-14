<cfinclude template="/includes/_header.cfm">
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT * FROM cf_user_log
</cfquery>
<cfquery name="ip" dbtype="query">
	select distinct(ip) from data
</cfquery>
<cfquery name="username" dbtype="query">
	select distinct(username) from data
</cfquery>
<cfquery name="totalRecords" dbtype="query">
	select sum(numrecords) totalRecords from data
</cfquery>
<cfquery name="totalUserRecords" dbtype="query">
	select sum(numrecords) totalUserRecords from data
	where username is not null
</cfquery>
<cfquery name="notUs" dbtype="query">
	select sum(numrecords) notUs from data
	where username not in ('dusty','gordon')
</cfquery>
<cfoutput>
The following data represent logged user activity from selected forms. It is not all-inclusive, complete, or necessarily accurate.
<table border>
	<tr>
		<td>Distinct IP Count</td>
		<td>#ip.recordcount#</td>
	</tr>
	<tr>
		<td>Distinct Username Count</td>
		<td>#username.recordcount#</td>
	</tr>
	<tr>
		<td>Total Records Accessed</td>
		<td>#totalRecords.totalRecords#</td>
	</tr>
	<tr>
		<td>Total Records Accessed by known users</td>
		<td>#totalUserRecords.totalUserRecords#</td>
	</tr>
	<tr>
		<td>Total Records Accessed by someone other than dusty or gordon</td>
		<td>#notUs.notUs#</td>
	</tr>
</table>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">