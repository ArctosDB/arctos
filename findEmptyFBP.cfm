<cfinclude template = "/includes/_header.cfm">
<cfset title='Empty Positions'>
<script src="/includes/sorttable.js"></script>
<h2>Find empty positions.</h2>
<cfquery name="ctcontainer_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select container_type from ctcontainer_type order by container_type
</cfquery><cfoutput>
<cfquery name="ctr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select getContainerParentage(#container_id#) thisP from dual
</cfquery>
<cfparam name="hptype" default="">
Within container
<blockquote>
#ctr.thisP#
</blockquote>
find empty positions within containers of type....
<form name="x" method="get" action='findEmptyFBP.cfm'>
	<input type="hidden" name="container_id" value="#container_id#">
	<label for="hptype">Container Type in which to find empty positions</label>
	<select name="hptype" id="hptype">
		<option value="">pick one</option>
		<cfloop query="ctcontainer_type">
			<option <cfif hptype is container_type> selected="selected" </cfif>value="#container_type#">#container_type#</option>
		</cfloop>
	</select>
	<br><input type="submit" value="go">
</form>
<!----
... with empty
<p>
	INPUT: container containing containers of type "freeer box."
</p>
<p>
	OUTPUT: freezer boxes with number of type "postition" children which do not have children - empty positions.
</p>
------>
<cfif not isdefined("hptype") or len(hptype) is 0>
	<cfabort>
</cfif>

	<cfquery name="fb" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT
			label,
			barcode,
			container_id,
			getContainerParentage(container_id) plp
		FROM
			container
		where
			container_type='#hptype#'
			START WITH container_id=#val(container_id)#
		CONNECT BY PRIOR
			container_id = parent_container_id
	</cfquery>
	<table border id="t" class="sortable">
		<tr>
			<th>Parent Barcode</th>
			<th>Parent Label</th>
			<th>## Empty Positions</th>
			<th>ParentPath</th>
			<th>CTL</th>
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
		<cfif nep.c gt 0>
			<tr>
				<td>#barcode#</td>
				<td>#label#</td>
				<td>#nep.c#</td>
				<td>#plp#</td>
				<td>
					<a href="/containerPositions.cfm?container_id=#fb.container_id#">[&nbsp;position&nbsp;]</a>&nbsp;
					<a href="/findContainer.cfm?container_id=#fb.container_id#">[&nbsp;tree&nbsp;]</a>
				</td>
			</tr>
		</cfif>
	</cfloop>
	</table>
</cfoutput>
<cfinclude template = "/includes/_footer.cfm">