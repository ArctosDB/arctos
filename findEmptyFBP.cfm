<cfinclude template = "/includes/_header.cfm">
<cfset title='Empty Positions'>
	<script src="/includes/sorttable.js"></script>

	Find empty freezer box positions.

	<p>
		INPUT: container containing containers of type "freeer box."
	</p>
	<p>
		OUTPUT: freezer boxes with number of type "postition" children which do not have children.
	</p>
	<cfoutput>
		<cfquery name="fb" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				label,
				barcode,
				container_id
			FROM
				container
			where
				container_type='freezer box'
				START WITH container_id=#container_id#
			CONNECT BY PRIOR
				container_id = parent_container_id
		</cfquery>
		<table border id="t" class="sortable">
			<tr>
				<th>Box Barcode</th>
				<th>Box Label</th>
				<th>## Empty Positions</th>
				<th>Positions</th>
			</tr>
		<cfloop query="fb">
			<cfquery name="nep" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				SELECT count(*) c
				FROM (
				  select * from container where parent_container_id=#fb.container_id#
				) x
				WHERE NOT EXISTS (
				    SELECT 1 FROM container
				    WHERE container.parent_container_id = x.container_id
				)
			</cfquery>
			<tr>
				<td>#barcode#</td>
				<td>#label#</td>
				<td>#nep.c#</td>
				<td><a href="/containerPositions.cfm?container_id=#fb.container_id#">open</a></td>
			</tr>


		</cfloop>

		</table>

	</cfoutput>




<cfinclude template = "/includes/_footer.cfm">