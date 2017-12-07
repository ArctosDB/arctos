	<!--- just in case, cached queries don't cost anything .. --->

	<cfquery name="ctPermitType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select permit_type from ctpermit_type order by permit_type
	</cfquery>
	<cfquery name="ctPermitRegulation" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select permit_regulation from ctpermit_regulation order by permit_regulation
	</cfquery>
	<cfquery name="ctPermitAgentRole" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select permit_agent_role from ctpermit_agent_role order by permit_agent_role
	</cfquery>
	<cfoutput>
	<label for="permit_num">Permit Identifier/Number</label>
	<input type="text" name="permit_num" id="permit_num">
	<span class="infoLink" onclick="var e=document.getElementById('permit_num');e.value='='+e.value;">Add = for exact match</span>


	<label for="permit_type">Permit Type</label>
	<select name="permit_type" size="1">
		<option value=""></option>
		<cfloop query="ctPermitType">
			<option value = "#ctPermitType.permit_type#">#ctPermitType.permit_type#</option>
		</cfloop>
	</select>

	<label for="permit_regulation">Permit Regulation</label>
	<select name="permit_regulation" size="1">
		<option value=""></option>
		<cfloop query="ctPermitRegulation">
			<option value = "#ctPermitRegulation.permit_regulation#">#ctPermitRegulation.permit_regulation#</option>
		</cfloop>
	</select>

	<label for="IssuedByAgent">Issued By</label>
	<input type="text" name="IssuedByAgent">

	<label for="IssuedToAgent">Issued To</label>
	<input type="text" name="IssuedToAgent">

	<label for="ContactAgent">Contact</label>
	<input type="text" name="ContactAgent">

	<label for="IssuedAfter">Issued On/After Date</label>
	<input type="datetime" name="IssuedAfter">

	<label for="IssuedBefore">Issued On/Before Date</label>
	<input type="datetime" name="IssuedBefore">

	<label for="ExpiresAfter">Expires On/After Date</label>
	<input type="datetime" name="ExpiresAfter">

	<label for="ExpiresBefore">Expires On/Before Date</label>
	<input type="datetime" name="ExpiresBefore">

	<label for="permit_remarks">Remarks</label>
	<input type="text" name="permit_remarks">
	<p>
		<input type="submit" value="Search" class="schBtn">
	</p>
	<p>
		<input type="reset" value="Clear Form" class="clrBtn">
	</p>
	</cfoutput>