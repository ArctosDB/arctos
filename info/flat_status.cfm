<cfinclude template="/includes/_header.cfm">
	<p>
		Updates and specimen record entries are processed (roughly!) in the order they enter the queue.
	</p>
	<p>
		Records are processed at a rate of (roughly!) 1500 per minute.
	</p>

<cfquery name="fs" datasource="uam_god">
	select
		decode(STALE_FLAG,
			1,'flat_processing',
			0,'filtered_flat_processing',
			2,'current',
			'error_in_processing'
		)
		stale_flag,count(*) c from flat group by decode(STALE_FLAG,
			1,'flat_processing',
			0,'filtered_flat_processing',
			2,'current',
			'error_in_processing'
		)
</cfquery>
<cfoutput>
	<table border>
		<tr>
			<th>Status</th>
			<th>NumberRecords</th>
		</tr>
		<cfloop query="fs">

			<tr>
				<td>#stale_flag#</td>
				<td>#c#</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>

<cfinclude template="/includes/_footer.cfm">
