<cfinclude template="includes/_frameHeader.cfm">
<cfquery name="ctagent_name_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select agent_name_type from ctagent_name_type order by agent_name_type
</cfquery>
<cfquery name="ctagent_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select agent_type from ctagent_type order by agent_type
</cfquery>
<cfquery name="ctagent_status" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select agent_status from ctagent_status order by agent_status
</cfquery>
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		jQuery("#status_date").datepicker();
	});
</script>
<span class="infoLink pageHelp" onclick="getDocs('agent');">Page Help</span>
Agent Search
<cfoutput>
<form name="agntSearch" action="AgentGrid.cfm" method="post" target="_pick">
	<input type="hidden" name="Action" value="search">
	<label for="anyName"><a href="javascript:void(0);" onClick="getDocs('agent','anynamesearch')">Any part of any name</a></label>
	<input type="text" name="anyName" id="anyName" size="75">
	<table>
		<tr>
			<td>
				<label for="agent_type">Agent Type</label>
				<select name="agent_type" size="1" id="agent_type">
					<option value=""></option>
					<cfloop query="ctagent_type">
						<option value="#agent_type#">#agent_type#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<label for="agent_id">AgentID</label>
				<input type="text" name="agent_id" size="6" id="agent_id">
			</td>
		</tr>
	</table>
	<label for="address"><a href="javascript:void(0);" onClick="getDocs('agent','address')">Address</a></label>
	<input type="text" name="address" id="address" size="75">
			<label for="agent_status">Agent Status</label>
			<select name="agent_status" size="1" id="agent_status">
				<option value=""></option>
				<cfloop query="ctagent_status">
					<option value="#agent_status#">#agent_status#</option>
				</cfloop>
			</select>
			
			<label for="status_date">
				Status Date
			</label>
			<select name="status_date_oper" size="1" id="status_date_oper">
				<option value="<=">Before</option>
				<option selected value="=" >Is</option>
				<option value=">=">After</option>
			</select>
			<input type="text" size="6" name="status_date" id="status_date">
			
			
	
			<div style="border:2px solid green;">
				<label for="agent_name_type">Agent Name Type (pairs with name below)</label>
				<select name="agent_name_type" size="1" id="agent_name_type">
					<option value=""></option>
					<cfloop query="ctagent_name_type">
						<option value="#agent_name_type#">#agent_name_type#</option>
					</cfloop>
				</select>
				<label for="agent_name">Agent Name (pairs with type above)</label>
				<input type="text" name="agent_name" id="agent_name" size="50">
				
			</div>
			<br>
			<input type="submit" 
				value="Search" 
				class="schBtn">
			<input type="reset" 
				value="Clear Form" 
				class="clrBtn">
				<br>
				<input type="button" 
					value="New Agent" 
					class="insBtn"
					onClick="window.open('editAllAgent.cfm?action=newAgent','_person');">
				

</form>
</cfoutput>	
<cfinclude template="includes/_pickFooter.cfm">