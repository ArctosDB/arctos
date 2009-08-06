<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<div style="color:gray;background-color:lightgray;border:1px solid gray;">
	The following are potential specimen records that are in GenBank but not in Arctos.
	<bb>The insanely large numbers for unregistered collections (WNMU, Observations collections)
	are an artifact of the collections being unregistered.
	<br><strong>wild</strong> query types are limited to 600 records by GenBank - the numbers you see here may make no sense.	
</div>
	<cfoutput>
		<cfquery name="gb" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from cf_genbank_crawl order by owner
		</cfquery>
		<table border id="t" class="sortable">
			<tr>
				<th>Owner</th>
				<th>Count</th>
				<th>Run Date</th>
				<th>Query Type</th>
				<th>Link</th>
			</tr>
			<cfloop query="gb">
				<tr>
					<td>#owner#</td>
					<td>#found_count#</td>
					<td>#dateformat(run_date,"dd mmm yyyy")#</td>
					<td>#query_type#</td>
					<td><a href="#link_url#" target="_blank">open GenBank</a></td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">