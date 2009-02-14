<cfinclude template="/includes/_header.cfm">

<cfif len(#session.username#) is 0>
		You aren't a registered user. Please sign in.
		<cfabort>
</cfif>
Your address is required before you accept a loan.

<cfquery name="ctNameType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select storedvalue as agent_name_type from ctagent_name_type
</cfquery>
<cfquery name="ctAddrType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select addr_type from ctaddr_type
</cfquery>
<cfquery name="ctElecAddrType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select electronic_addr_type from ctelectronic_addr_type
</cfquery>
<cfquery name="ctprefix" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select prefix from ctprefix order by prefix
</cfquery>
<cfquery name="ctsuffix" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select suffix from ctsuffix order by suffix
</cfquery>

<cfquery name="addr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select
		 ADDR_ID,
		 STREET_ADDR1,
		 STREET_ADDR2,
		 CITY ,
		 STATE ,
		 ZIP ,
		 COUNTRY_CDE,
		 MAIL_STOP,
		 ADDR_TYPE,
		 JOB_TITLE ,
		 VALID_ADDR_FG,
		 ADDR_REMARKS ,
		 INSTITUTION,
		 DEPARTMENT,
		 cf_users.user_id
	FROM
		cf_address, cf_users where
		cf_users.user_id = cf_address.user_id (+) and
		username='#session.username#'
</cfquery>
<cfoutput>
<cfset i=1>
<cfif len(#addr.addr_id#) gt 0>
<table>

<cfloop query="addr">
<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
<td>
<table>
<form name="addr#i#" method="post" action="user_addr.cfm">
				<input type="hidden" name="action">
				<input type="hidden" name="addr_id" value="#addr_id#">
				
					<tr>
						<td>Address Type:</td>
						<td>
							<cfset thisType = #addr_type#>
							#thisType#
							<select name="addr_type" size="1">
								<cfloop query="ctAddrType">
								<option 
									<cfif #thisType# is "#ctAddrType.addr_type#"> selected </cfif>value="#ctAddrType.addr_type#">#ctAddrType.addr_type#</option>
								</cfloop>
							</select>
						</td>
						<td>Job Title</td>
						<td><input type="text" name="job_title" value="#job_title#"></td>
					</tr>
					<tr>
						<td>Institution</td>
						<td colspan="3">
							<input type="text" name="Institution" size="50" value="#Institution#" >
						</td>
					</tr>
					<tr>
						<td>Department</td>
						<td colspan="3">
							<input type="text" name="Department" size="50" value="#Department#" >
						</td>
					</tr>
					<tr>
						<td>Address 1</td>
						<td colspan="3">
							<input type="text" name="street_addr1" size="50" value="#street_addr1#" >
						</td>
					</tr>
					<tr>
						<td>Address 2</td>
						<td colspan="3">
							<input type="text" name="street_addr2" size="50" value="#street_addr2#">
						</td>
					</tr>
					<tr>
						<td>City</td>
						<td>
							<input type="text" name="city" value="#city#">
						</td>
						<td>State</td>
						<td>
							<input type="text" name="state" value="#state#">
						</td>
					</tr>
					<tr>
						<td>Zip</td>
						<td><input type="text" name="zip" value="#zip#"></td>
						<td>Country</td>
						<td>
							<input type="text" name="country_cde" value="#country_cde#">
						</td>
					</tr>
					<tr>
						<td>Mail Stop</td>
						<td>
							<input type="text" name="mail_stop" value="#mail_stop#">
						</td>
						<td>Valid?</td>
						<td>
							<select name="valid_addr_fg" size="1">
									<option <cfif #valid_addr_fg# is 1> selected </cfif>value="1">yes</option>
									<option  <cfif #valid_addr_fg# is 0> selected </cfif>value="0">no</option>
								</select>
						</td>
					</tr>
					<tr>				
						<td>Remarks</td>
						<td colspan="3">
							<input type="text" name="addr_remarks" size="50" value="#addr_remarks#">
						</td>
					</tr>
					<tr>
						<td colspan="2">
						<input type="submit" 
							value="Save Update" 
							class="savBtn"
							onmouseover="this.className='savBtn btnhov'"
							onmouseout="this.className='savBtn'"
							onclick="addr#i#.action.value='update';submit();">
							
							<input type="submit" 
							value="Delete Address" 
							class="delBtn"
							onmouseover="this.className='delBtn btnhov'"
							onmouseout="this.className='delBtn'"
							onclick="addr#i#.action.value='delete';submit();">
						</td>
					</tr>
					</table>
</form>
<cfset i=#i#+1>
</td></tr>
</cfloop>
</table>
</cfif>
<table class="newRec"><tr><td>
Add Address for <b>#session.username#</b>:		
		
			<cfform name="newAddress" method="post" action="user_addr.cfm">
				<input type="hidden" name="Action" value="newAddress">
				<input type="hidden" name="user_id" value="#addr.user_id#">
				<tr><td>
				<table>
					<tr>
						<td>Address Type:</td>
						<td>
							<select name="addr_type" size="1">
								<cfloop query="ctAddrType">
								<option value="#ctAddrType.addr_type#">#ctAddrType.addr_type#</option>
								</cfloop>
							</select>
						</td>
						<td>Job Title</td>
						<td><input type="text" name="job_title"></td>
					</tr>
					<tr>
						<td>Institution</td>
						<td colspan="3">
							<input type="text" name="Institution" size="50" >
						</td>
					</tr>
					<tr>
						<td>Department</td>
						<td colspan="3">
							<input type="text" name="Department" size="50" >
						</td>
					</tr>
					<tr>
						<td>Address 1</td>
						<td colspan="3">
							<input type="text" name="street_addr1" size="50" >
						</td>
					</tr>
					<tr>
						<td>Address 2</td>
						<td colspan="3">
							<input type="text" name="street_addr2" size="50">
						</td>
					</tr>
					<tr>
						<td>City</td>
						<td>
							<input type="text" name="city">
						</td>
						<td>State</td>
						<td>
							<input type="text" name="state">
						</td>
					</tr>
					<tr>
						<td>Zip</td>
						<td><input type="text" name="zip"></td>
						<td>Country</td>
						<td>
							<input type="text" name="country_cde">
						</td>
					</tr>
					<tr>
						<td>Mail Stop</td>
						<td>
							<input type="text" name="mail_stop">
						</td>
						<td>Valid?</td>
						<td>
							<select name="valid_addr_fg" size="1">
									<option value="1">yes</option>
									<option value="0">no</option>
								</select>
						</td>
					</tr>
					<tr>				
						<td>Remarks</td>
						<td colspan="3">
							<input type="text" name="addr_remarks" size="50">
						</td>
					</tr>
					<tr>
						<td>
						<input type="submit" 
							value="Save this Address" 
							class="savBtn"
							onmouseover="this.className='savBtn btnhov'"
							onmouseout="this.className='savBtn'">
						</td>
					</tr>
					</table>
</cfform>
</cfoutput>
<!------------------------------------------------------------------------------>
<cfif #Action# is "delete">
<cfoutput>
	<cfquery name="killAddr" datasource="#uam_dbo#">
		delete from cf_address where addr_id = #addr_id#
	</cfquery>
	
	<cflocation url="user_addr.cfm">
	
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------>
<cfif #Action# is "newAddress">
	<cfoutput>
		<cfquery name="nextAddr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select max(addr_id) + 1 as nextAddrId from cf_address
		</cfquery>
		<cfquery name="prefName" datasource="#uam_dbo#">
			select first_name, last_name from cf_user_data where user_id=#user_id#
		</cfquery>
	<cftransaction>
	<cfquery name="addr" datasource="#uam_dbo#">
		INSERT INTO cf_address (
			 ADDR_ID
			 <cfif len(#STREET_ADDR1#) gt 0>
			 	,STREET_ADDR1
			 </cfif>
			 <cfif len(#STREET_ADDR2#) gt 0>
			 	,STREET_ADDR2
			 </cfif>
			 <cfif len(#institution#) gt 0>
			 	,institution
			 </cfif>
			 <cfif len(#department#) gt 0>
			 	,department
			 </cfif>
			 <cfif len(#CITY#) gt 0>
			 	,CITY
			 </cfif>
			 <cfif len(#state#) gt 0>
			 	,state
			 </cfif>
			 <cfif len(#ZIP#) gt 0>
			 	,ZIP
			 </cfif>
			 <cfif len(#COUNTRY_CDE#) gt 0>
			 	,COUNTRY_CDE
			 </cfif>
			 <cfif len(#MAIL_STOP#) gt 0>
			 	,MAIL_STOP
			 </cfif>
			 <cfif len(#user_id#) gt 0>
			 	,user_id
			 </cfif>
			 <cfif len(#addr_type#) gt 0>
			 	,addr_type
			 </cfif>
			 <cfif len(#job_title#) gt 0>
			 	,job_title
			 </cfif>
			 <cfif len(#valid_addr_fg#) gt 0>
			 	,valid_addr_fg
			 </cfif>
			  <cfif len(#addr_remarks#) gt 0>
			 	,addr_remarks
			 </cfif>
			 <cfif len(#addr_remarks#) gt 0>
			 	,addr_remarks
			 </cfif>
			  )
			VALUES (
			#nextAddr.nextAddrId#
			 <cfif len(#STREET_ADDR1#) gt 0>
			 	,'#STREET_ADDR1#'
			 </cfif>
			 <cfif len(#STREET_ADDR2#) gt 0>
			 	,'#STREET_ADDR2#'
			 </cfif>
			 <cfif len(#institution#) gt 0>
			 	,'#institution#'
			 </cfif>
			 <cfif len(#department#) gt 0>
			 	,'#department#'
			 </cfif>
			 <cfif len(#CITY#) gt 0>
			 	,'#CITY#'
			 </cfif>
			  <cfif len(#state#) gt 0>
			 	,'#state#'
			 </cfif>
			 <cfif len(#ZIP#) gt 0>
			 	,'#ZIP#'
			 </cfif>
			 <cfif len(#COUNTRY_CDE#) gt 0>
			 	,'#COUNTRY_CDE#'
			 </cfif>
			 <cfif len(#MAIL_STOP#) gt 0>
			 	,'#MAIL_STOP#'
			 </cfif>
			 <cfif len(#user_id#) gt 0>
			 	,#user_id#
			 </cfif>
			 <cfif len(#addr_type#) gt 0>
			 	,'#addr_type#'
			 </cfif>
			 <cfif len(#job_title#) gt 0>
			 	,'#job_title#'
			 </cfif>
			 <cfif len(#valid_addr_fg#) gt 0>
			 	,#valid_addr_fg#
			 </cfif>
			  <cfif len(#addr_remarks#) gt 0>
			 	,'#addr_remarks#'
			 </cfif>
		)
	</cfquery>
	</cftransaction>
	
		<cflocation url="user_addr.cfm">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------------>
<cfif #action# is "update">
<cfoutput>
<cfquery name="addr" datasource="#uam_dbo#">
			UPDATE cf_address SET 
				addr_id = #addr_id#
			 <cfif len(#STREET_ADDR1#) gt 0>
			 	,STREET_ADDR1 = '#STREET_ADDR1#'
			 </cfif>
			  <cfif len(#job_title#) gt 0>
			 	,job_title = '#job_title#'
			 </cfif>
			 <cfif len(#institution#) gt 0>
			 	,institution = '#institution#'
			 </cfif>
			 <cfif len(#department#) gt 0>
			 	,department = '#department#'
			 </cfif>
			 <cfif len(#STREET_ADDR2#) gt 0>
			 	,STREET_ADDR2 = '#STREET_ADDR2#'
			 </cfif>
			 <cfif len(#CITY#) gt 0>
			 	,CITY = '#CITY#'
			 </cfif>
			 <cfif len(#state#) gt 0>
			 	,state = '#state#'
			 </cfif>
			 <cfif len(#ZIP#) gt 0>
				,ZIP = '#ZIP#'
			 </cfif>
			 <cfif len(#COUNTRY_CDE#) gt 0>
			 	,COUNTRY_CDE = '#COUNTRY_CDE#'
			 </cfif>
			 <cfif len(#MAIL_STOP#) gt 0>
			 	,MAIL_STOP = '#MAIL_STOP#'
			 </cfif>
			  <cfif len(#addr_remarks#) gt 0>
			 	,addr_remarks = '#addr_remarks#'
			 </cfif>
			  <cfif len(#addr_type#) gt 0>
			 	,addr_type = '#addr_type#'
			 </cfif>
			 <cfif len(#valid_addr_fg#) gt 0>
			 	,valid_addr_fg = '#valid_addr_fg#'
			 </cfif>
			 where addr_id = #addr_id#
	</cfquery>	
	<cflocation url="user_addr.cfm">
	</cfoutput>
</cfif>