<cfinclude template="/includes/_header.cfm">
<cfset title="missed GenBank records">
<script src="/includes/sorttable.js"></script>
<div style="color:gray;background-color:lightgray;border:1px solid gray;margin:1em;">
	The following are potential specimen records that are in GenBank but not in Arctos.
	<br>The insanely large numbers for unregistered collections (WNMU, Observations collections)
	are an artifact of the collections being unregistered. with GenBank.
	<br><strong>wild</strong> query types are limited to 600 records by GenBank - the numbers you see here may make no sense.
	<br>Instructions for avoiding unnecessary pain are available from the 
		<a href="http://groups.google.com/group/Arctos/browse_thread/thread/8b99cc25141be232/8e5472c667cca95d"
			target="_blank">Arctos list</a>.
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