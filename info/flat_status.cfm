<cfinclude template="/includes/_header.cfm">
	<p>
		Updates and specimen record entries are processed (roughly!) in the order they enter the queue.
	</p>
	<p>
		Records are processed at a rate of (roughly!) 1500 per minute.
	</p>

<cfquery name="fs" datasource="uam_god">
	select stale_flag,count(*) c from flat group by stale_flag
</cfquery>
<cfquery name="nc" dbtype="query">
	select c from fs where stale_flag=1
</cfquery>
<cfquery name="c" dbtype="query">
	select c from fs where stale_flag=0
</cfquery>
<table border>
	<tr>
		<th>Status</th>
		<th>NumberRecords</th>
	</tr>
	<tr>
		<td>Current</td>
		<td>#c.c#</td>
	</tr>
	<tr>
		<td>Processing</td>
		<td>#nc.c#</td>
	</tr>
</table>


<cfinclude template="/includes/_footer.cfm">
