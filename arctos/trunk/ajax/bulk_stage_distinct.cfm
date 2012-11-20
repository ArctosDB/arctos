<cfoutput>
	Distinct values of #col#
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select #col# data,count(*) c from bulkloader_stage group by #col# order by #col#
	</cfquery>
	<table border>
		<tr><th>
				#col#
			</th>
			<th>
				##
			</th></tr>
		<cfloop query="d"><tr>
				<td>
					#data#
				</td>
				<td>
					#c#
				</td>
			</tr></cfloop>
	</table>
</cfoutput>
