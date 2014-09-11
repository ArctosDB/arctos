
<cfquery name="addr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select * from addr where addr+id=#addr_id#
</cfquery>

<cfif addr.recordcount is not 1>
	not found<cfabort>
<cfelse>ok
</cfif>
	Edit Address:
	<cfoutput>
	<form name="editAddr" method="post" action="editAllAgent.cfm">
		<input type="hidden" name="agent_id" value="#agent_id#">
		<input type="hidden" name="action" value="saveEditsAddr">
		<input type="hidden" name="addr_id" value="#addr_id#">
			<table>
				<tr>
					<td>
						<label for="addr_type">Address Type</label>
						<select name="addr_type" id="addr_type" size="1">
							<cfloop query="ctAddrType">
							<option 
								<cfif addrtype is ctAddrType.addr_type> selected="selected" </cfif>
								value="#ctAddrType.addr_type#">#ctAddrType.addr_type#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<label for="job_title">Job Title</label>
						<input type="text" name="job_title" id="job_title" value="#job_title#">
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="institution">Institution</label>
						<input type="text" name="institution" id="institution" size="50"  value="#institution#">
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="department">Department</label>
						<input type="text" name="department" id="department" size="50"  value="#department#">
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="street_addr1">Street Address 1</label>
						<input type="text" name="street_addr1" id="street_addr1" size="50" class="reqdClr" value="#street_addr1#">
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="street_addr2">Street Address 2</label>
						<input type="text" name="street_addr2" id="street_addr2" size="50" value="#street_addr2#">
					</td>
				</tr>
				<tr>
					<td>
						<label for="city">City</label>
						<input type="text" name="city" id="city" class="reqdClr" value="#city#">
					</td>
					<td>
						<label for="state">State</label>
						<input type="text" name="state" id="state" class="reqdClr" value="#state#">
					</td>
				</tr>
				<tr>
					<td>
						<label for="zip">Zip</label>
						<input type="text" name="zip" id="zip" class="reqdClr" value="#zip#">
					</td>
					<td>
						<label for="country_cde">Country Code</label>
						<input type="text" name="country_cde" id="country_cde" class="reqdClr" value="#country_cde#">
					</td>
				</tr>
				<tr>
					<td>
						<label for="mail_stop">Mail Stop</label>
						<input type="text" name="mail_stop" id="mail_stop" value="#mail_stop#">
					</td>
					<td>
						<label for="valid_addr_fg">Valid?</label>
						<select name="valid_addr_fg" id="valid_addr_fg" size="1">
							<option <cfif validfg IS "1"> selected="selected" </cfif>value="1">yes</option>
							<option <cfif validfg IS "0"> selected="selected" </cfif>value="0">no</option>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="addr_remarks">Address Remark</label>
						<input type="text" name="addr_remarks" id="addr_remarks" size="50" value="#addr_remarks#">
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<input type="submit" class="savBtn" value="Save Edits">
					</td>
				</tr>
			</table>
		</form>
	</cfoutput>