<cfif not isdefined("action")><cfset action="nothing"></cfif>
<cfinclude template="/includes/functionLib.cfm">
<cfquery name="ctAddrType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select addr_type from ctaddr_type order by addr_type
</cfquery>
<span class="likeLink" onClick="getDocs('address')">Help</span>
<cfif action is "newAddress">
	<script>		
		$(document).ready(function() {
			$(".reqdClr:visible").each(function(e){
			    $(this).prop('required',true);
			});
			$("#newAddress").submit(function(event){
				event.preventDefault();
				$.ajax({
					url: "/component/agent.cfc?queryformat=column&method=newAgentAddr&returnformat=json",
					type: "GET",
					dataType: "json",
					data:  $("#newAddress").serialize(),
					success: function(r) {
						if (r=='success'){
							$(".ui-dialog-titlebar-close").trigger('click');
							loadEditAgent( $("#agent_id").val() );
						} else {
							alert('An error occurred: ' + r);
						}
					},
					error: function (xhr, textStatus, errorThrown){
					    alert(errorThrown + ': ' + textStatus + ': ' + xhr);
					}
				});
			});
		});
	</script>
	<cfoutput>
		<form name="newAddress" id="newAddress" method="post" action="editAllAgent.cfm">
			<input type="hidden" name="agent_id" value="#agent_id#">
			<input type="hidden" name="Action" value="newAddress">
			<table>
				<tr>
					<td>
						<label for="addr_type">Address Type</label>
						<select name="addr_type" id="addr_type" size="1">
							<cfloop query="ctAddrType">
							<option value="#ctAddrType.addr_type#">#ctAddrType.addr_type#</option>
							</cfloop>
						</select>
						<span class="infoLink" onclick="getCtDoc('CTADDR_TYPE');">Define</span>
					</td>
					<td>
						<label for="job_title">Job Title</label>
						<input type="text" name="job_title" id="job_title">
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="institution">Institution</label>
						<input type="text" name="institution" id="institution"size="50" >
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="department">Department</label>
						<input type="text" name="department" id="department" size="50" >
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="street_addr1">Street Address 1</label>
						<input type="text" name="street_addr1" id="street_addr1" size="50" class="reqdClr">
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="street_addr2">Street Address 2</label>
						<input type="text" name="street_addr2" id="street_addr2" size="50">
					</td>
				</tr>
				<tr>
					<td>
						<label for="city">City</label>
						<input type="text" name="city" id="city" class="reqdClr">
					</td>
					<td>
						<label for="state">State</label>
						<input type="text" name="state" id="state" class="reqdClr">
					</td>
				</tr>
				<tr>
					<td>
						<label for="zip">Zip</label>
						<input type="text" name="zip" id="zip" class="reqdClr" maxlength="10">
					</td>
					<td>
						<label for="country_cde">Country Code</label>
						<input type="text" name="country_cde" id="country_cde">
					</td>
				</tr>
				<tr>
					<td>
						<label for="mail_stop">Mail Stop</label>
						<input type="text" name="mail_stop" id="mail_stop">
					</td>
					<td>
						<label for="valid_addr_fg">Valid?</label>
						<select name="valid_addr_fg" id="valid_addr_fg" size="1">
							<option value="1">yes</option>
							<option value="0">no</option>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="addr_remarks">Address Remark</label>
						<textarea class="mediumtextarea" name="addr_remarks" id="addr_remarks"></textarea>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<input type="submit" class="insBtn" value="Create Address">
					</td>
				</tr>
			</table>
		</form>
	</cfoutput>
</cfif>
<!--------------------------->
<cfif action is "editAddress">
	<cfquery name="addr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" >
		select * from addr where addr_id=<cfqueryparam value = "#addr_id#" CFSQLType = "CF_SQL_INTEGER">
	</cfquery>
	<cfif addr.recordcount is not 1>
		not found<cfabort>
	</cfif>
	<script>
		function deleteAgentAddress(aid){
			$.ajax({
				url: "/component/agent.cfc?queryformat=column&method=deleteAgentAddrEdit&returnformat=json",
				type: "GET",
				dataType: "json",
				data: {
					addr_id:  aid
				},
				success: function(r) {
					if (r=='success'){
						$("#aow_" + aid).remove();
						$(".ui-dialog-titlebar-close").trigger('click');
					} else {
						alert('An error occurred: ' + r);
					}
				},
				error: function (xhr, textStatus, errorThrown){
				    alert(errorThrown + ': ' + textStatus + ': ' + xhr);
				}
			});
		}
	
		$(document).ready(function() {
			$(".reqdClr:visible").each(function(e){
		   		$(this).prop('required',true);
			});
			$("#editAddr").submit(function(event){
				event.preventDefault();
				$.ajax({
					url: "/component/agent.cfc?queryformat=column&method=saveAgentAddrEdit&returnformat=json",
					type: "GET",
					dataType: "json",
					data:  $("#editAddr").serialize(),
					success: function(r) {
						if (r.DATA.STATUS[0]=='success'){
							var x=r.DATA.FORMATTED_ADDR[0];
							x = x.replace(/\n/g, '<br>');	
							$("#dvaddr_" + (r.DATA.ADDR_ID[0])).html(x);
	
							x=r.DATA.ADDR_TYPE[0] + ' Address (' + r.DATA.VALID_ADDR_FG[0] + ')';
							$("#atype_" + (r.DATA.ADDR_ID[0])).html(x);
							if (r.DATA.VALID_ADDR_FG[0]=='valid'){
								$("#aow_" + (r.DATA.ADDR_ID[0])).removeClass().addClass('validAddress');
							} else {
								$("#aow_" + (r.DATA.ADDR_ID[0])).removeClass().addClass('invalidAddress');
							}
	
							$(".ui-dialog-titlebar-close").trigger('click');
						} else {
							alert('An error occurred: ' + r.DATA.STATUS[0]);
						}
					},
					error: function (xhr, textStatus, errorThrown){
					    alert(errorThrown + ': ' + textStatus + ': ' + xhr);
					}
				});
			});
		});
	</script>
	<cfoutput>
		<form name="editAddr" id="editAddr" method="post" action="editAllAgent.cfm">
			<input type="hidden" name="addr_id" id="addr_id" value="#addr_id#">
			<table>
				<tr>
					<td>
						<label for="addr_type">Address Type</label>
						<select name="addr_type" id="addr_type" size="1">
							<cfloop query="ctAddrType">
							<option 
								<cfif addr.addr_type is ctAddrType.addr_type> selected="selected" </cfif>
								value="#ctAddrType.addr_type#">#ctAddrType.addr_type#</option>
							</cfloop>
						</select>
						<span class="infoLink" onclick="getCtDoc('CTADDR_TYPE');">Define</span>
					</td>
					<td>
						<label for="job_title">Job Title</label>
						<input type="text" name="job_title" id="job_title" value="#addr.job_title#">
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="institution">Institution</label>
						<input type="text" name="institution" id="institution" size="50"  value="#addr.institution#">
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="department">Department</label>
						<input type="text" name="department" id="department" size="50"  value="#addr.department#">
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="street_addr1">Street Address 1</label>
						<input type="text" name="street_addr1" id="street_addr1" size="50" class="reqdClr" value="#addr.street_addr1#">
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="street_addr2">Street Address 2</label>
						<input type="text" name="street_addr2" id="street_addr2" size="50" value="#addr.street_addr2#">
					</td>
				</tr>
				<tr>
					<td>
						<label for="city">City</label>
						<input type="text" name="city" id="city" class="reqdClr" value="#addr.city#">
					</td>
					<td>
						<label for="state">State</label>
						<input type="text" name="state" id="state" class="reqdClr" value="#addr.state#">
					</td>
				</tr>
				<tr>
					<td>
						<label for="zip">Zip</label>
						<input type="text" name="zip" id="zip" class="reqdClr" value="#addr.zip#"  maxlength="10">
					</td>
					<td>
						<label for="country_cde">Country Code</label>
						<input type="text" name="country_cde" id="country_cde" value="#addr.country_cde#">
					</td>
				</tr>
				<tr>
					<td>
						<label for="mail_stop">Mail Stop</label>
						<input type="text" name="mail_stop" id="mail_stop" value="#addr.mail_stop#">
					</td>
					<td>
						<label for="valid_addr_fg">Valid?</label>
						<select name="valid_addr_fg" id="valid_addr_fg" size="1">
							<option <cfif addr.valid_addr_fg IS "1"> selected="selected" </cfif>value="1">yes</option>
							<option <cfif addr.valid_addr_fg IS "0"> selected="selected" </cfif>value="0">no</option>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="addr_remarks">Address Remark</label>
						<textarea class="mediumtextarea" name="addr_remarks" id="addr_remarks">#stripQuotes(addr.addr_remarks)#</textarea>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<input type="submit" class="savBtn" value="Save Edits">
						<input type="button" class="delBtn" onclick="deleteAgentAddress('#addr_id#');" value="Delete Address">
					</td>
				</tr>
			</table>
		</form>
	</cfoutput>
</cfif>