<cfif not isdefined("agent_id")>
	<cfset agent_id=-1>
</cfif>
<cfinclude template="/includes/_header.cfm">
<cfset title='Manage Agents'>
<cfoutput>
<script>
	
</script>
<table>
	<tr>
		<td>
			<iframe src="/AgentSearch.cfm"></iframe>
			search
		</td>
		<td colspan="2">
			<iframe src="/AgentSearch.cfm" name="aEdit"></iframe>
		</td>
	</tr>
	<tr>
		<td>
			<iframe src="/AgentGrid.cfm" name="_pick"></iframe>
		</td>
	</tr>
</table>
</cfoutput>
