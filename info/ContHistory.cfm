<cfinclude template="/includes/_pickHeader.cfm">
<script src="/includes/sorttable.js"></script>
<cfoutput>
	<cfif not isdefined("container_id")>
		Container ID not found. Aborting....<cfabort>
	</cfif>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			thisc.label clabel,
			thisc.description cdesc,
			thisc.container_type ctype,
			thisc.barcode cbarcode,
			container_history.install_date,
			container_history.USERNAME,
			container_history.location_stack,
			parent.container_type ptype,
			parent.label plabel,
			parent.description pdesc,
			parent.barcode pbarcode,
			parent.container_id pid
		from
			container thisc,
			container_history,
			container parent
		where
			thisc.container_id=#container_id# and
			thisc.container_id=container_history.container_id (+) and
			container_history.parent_container_id = parent.container_id (+)
		ORDER BY
			install_date DESC
	</cfquery>
	<strong>Current Container</strong>
	<div style="margin:1em">
		<strong>Label:</strong> #d.clabel#
		<br><strong>Barcode:</strong> #d.cbarcode#
		<br><strong>Description:</strong> #d.cdesc#
		<br><strong>Type:</strong> #d.ctype#
	</div>
	<strong>Scan Into Parent History</strong>
	<table border id="t" class="sortable">
		<tr>
			<th>Date</th>
			<th>Barcode</th>
			<th>User</th>
			<th>Type</th>
			<th>Label</th>
			<th>Description</th>
			<th>Link</th>
			<th>Stack</th>
		</tr>
		<cfloop query="d">
			<tr>
				<td>#install_date#</td>
				<td>#pbarcode#</td>
				<td>#username#</td>
				<td>#ptype#</td>
				<td>#plabel#</td>
				<td>#pdesc#</td>
				<td><a target="_parent" href="/findContainer.cfm?container_id=#pid#">details</a></td>
				<td>#location_stack#</td>
				</tr>
			</cfloop>
	</table>
</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">