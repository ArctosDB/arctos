<cfquery name="f" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select label,container_id,container_type from container where container_type='freezer' order by label
</cfquery>
<cfoutput>
	<table border>
	
	<cfloop query="f">
		<tr>
			<td valign="top">#label# - #container_type#</td>
			<td>
				<cfquery name="cont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select label,container_id,container_type from container where parent_container_id=#container_id#
					order by label
				</cfquery>
				<table border>
				<cfloop query="cont">
					<tr>
						<td valign="top">#label# - #container_type#</td>
						<td>
							<cfquery name="c3" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
								select label,container_id,container_type from container where parent_container_id=#container_id#
								order by label
							</cfquery>
							<table border>
								<cfloop query="c3">
								<tr>
									<td valign="top">#label# - #container_type#</td>
								</tr>
								</cfloop>
							</table>
						</td>
					</tr>
				</cfloop>
				</table>
			</td>
		</tr>
	</cfloop>
	</table>
</cfoutput>