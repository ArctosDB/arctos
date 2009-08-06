<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
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