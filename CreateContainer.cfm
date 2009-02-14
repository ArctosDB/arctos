<cfinclude template = "includes/_header.cfm">
<!---- this is an internal use page and needs a security wrapper --->
 This form is obsolete. Please file a bug report detailing how you got here.
 <p>
 	The current form is <a href="EditContainer.cfm?action=newContainer">here</a>
 </p>
<cfabort>
 

<cfset title="Create Container">
<cfif URL.action is "CreateNew">

<!--- Make sure we have required values--->
<cfif #container_type# is not ""><!--- always required-got that, so we can make the container--->
<cfset mkCont = "valid">
<cfelse><cfset mkCont = "invalid">
</cfif>
<cfif #checked_date# is not ""
		OR #fluid_type# is not ""
		OR #concentration# is not ""
		OR #fluid_remarks# is not ""><!--- They are trying to make a fluid container, make sure they have all required values--->
			<cfif #checked_date# is "" 
				OR #fluid_type# is ""
				OR #concentration# is ""><!--- They put in all the required fields--->
				<cfset mkFluid = "invalid">
			<cfelse><cfset mkFluid = "valid">
			</cfif>
		<cfelse><cfset mkFluid = "noTry">
	</cfif>

<cfoutput>
		
	<cfif #mkCont# is "valid" and #mkFluid# is "noTry">
			<cfquery name="nextContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				SELECT sq_container_id.nextval newid FROM dual
			</cfquery>
			<cfset container_id = "#nextContainer.newid#">
			<!--- clean up nulls --->
			<cfif #label# is "">
				<cfset label = "null">
				<cfelse><cfset label = "'#label#'">
			</cfif>
			<cfif #description# is "">
				<cfset description = "null">
				<cfelse><cfset description = "'#description#'">
			</cfif>
			<cfif isdate("#parent_install_date#")>
				<cfset parent_install_date = "'#Dateformat(parent_install_date, "DD-Mmm-YYYY")#'">
				
				<cfelse>
				Need a date <cfabort>
				<cfset parent_install_date = "null">
			</cfif>
			<cfif #container_remarks# is "">
				<cfset container_remarks = "null">
				<cfelse><cfset container_remarks = "'#container_remarks#'">
			</cfif>
			<cfif #barcode# is "">
				<cfset barcode = "null">
				<cfelse><cfset barcode = "'#barcode#'">
			</cfif>
			<cfif #width# is "">
				<cfset width = "null">
				<cfelse><cfset width = "#width#">
			</cfif>
			<cfif #height# is "">
				<cfset height = "null">
				<cfelse><cfset height = "#height#">
			</cfif>
			<cfif #length# is "">
				<cfset length = "null">
				<cfelse><cfset length = "#length#">
			</cfif>
			<cfif #number_positions# is "">
				<cfset number_positions = "null">
				<cfelse><cfset number_positions = "#number_positions#">
			</cfif>
      <cfquery name="setDate" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					alter session set nls_date_format = 'DD-Mon-YYYY HH24:MI:SS'	
		</cfquery>
	  <cfset newContainerSQL="INSERT INTO 
					container 
						(container_id, 
						parent_container_id, 
						container_type, 
						label, 
						description, 
						parent_install_date, 
						container_remarks, 
						barcode,
						width,
						height,
						length,
						number_positions,
						locked_position,
						institution_acronym)
					VALUES
						(#container_id#, 
						0, 
						'#container_type#',
						#label#,
						#description#,
						#parent_install_date#,
						#container_remarks#,
						#barcode#,
						#width#,
						#height#,
						#length#,
						#number_positions#,
						0,
						'#institution_acronym#')">
				<cftransaction>
					<cfquery name="newContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						#preservesinglequotes(newContainerSQL)#
					</cfquery>
				</cftransaction>
				<font color="##00FF00"><br>
      You created a new dry container: <br>
      ID: #container_id# <br>
      Type: #container_type# <br>
      Description: #description# <br>
      Barcode: #barcode# <br>
      Install Date: #parent_install_date# <br>
      Remarks: #container_remarks#</font> <br>
		</cfif>
			
		<cfif #mkCont# is "valid" and #mkFluid# is "valid">
			<!--- Get the next container_id --->
			<cfquery name="nextContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				SELECT sq_container_id.nextval newid FROM dual
			</cfquery>
			<cfset container_id = "#nextContainer.newid#">
			<!--- clean up nulls --->
			<cfif #label# is "">
				<cfset label = "null">
				<cfelse><cfset label = "'#label#'">
			</cfif>
			<cfif #description# is "">
				<cfset description = "null">
				<cfelse><cfset description = "'#description#'">
			</cfif>
			<cfif isdate("#parent_install_date#")>
				<cfset parent_install_date = "'#Dateformat(parent_install_date, "DD-Mmm-YYYY")#'">
				<cfelse><cfset parent_install_date = "null">
			</cfif>
			<cfif #container_remarks# is "">
				<cfset container_remarks = "null">
				<cfelse><cfset container_remarks = "'#container_remarks#'">
			</cfif>
			<cfif #barcode# is "">
				<cfset barcode = "null">
				<cfelse><cfset barcode = "'#barcode#'">
			</cfif>
			
			<cfif #fluid_remarks# is "">
				<cfset fluid_remarks = "null">
				<cfelse><cfset fluid_remarks = "'#fluid_remarks#'">
			</cfif>
      <cfif #width# is "">
				<cfset width = "null">
				<cfelse><cfset width = "'#width#'">
			</cfif>
			<cfif #height# is "">
				<cfset height = "null">
				<cfelse><cfset height = "'#height#'">
			</cfif>
			<cfif #length# is "">
				<cfset length = "null">
				<cfelse><cfset length = "'#length#'">
			</cfif>
			<cfif #number_positions# is "">
				<cfset number_positions = "null">
				<cfelse><cfset number_positions = "'#number_positions#'">
			</cfif>
    <cfset newContainerSQL="INSERT INTO 
					container 
						(container_id, 
						parent_container_id, 
						container_type, 
						label, 
						description, 
						parent_install_date, 
						container_remarks, 
						barcode,
						width,
						height,
						length,
						number_positions)
					VALUES
						(#container_id#, 
						0, 
						'#container_type#',
						#label#,
						#description#,
						#parent_install_date#,
						#container_remarks#,
						#barcode#,
						#width#,
						#height#,
						#length#,
						#number_positions#)">
				
				<cfset newFlSql = "INSERT INTO 
					fluid_container_history
						(container_id,
						checked_date,
						fluid_type,
						concentration,
						fluid_remarks)
					VALUES
						(#container_id#,
						'#checked_date#',
						'#fluid_type#',
						#concentration#,
						#fluid_remarks#)">
	<cftransaction>
	 	<cfquery name="newFluidContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				#preservesinglequotes(newFlSql)#
		</cfquery>
		<cfquery name="newContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						#preservesinglequotes(newContainerSQL)#
					</cfquery>
	</cftransaction>
	<font color="##00FF00"><br>
      You created a new fluid container: <br>
      ID: #container_id# <br>
      Type: #container_type# <br>
      Description: #description# <br>
      Barcode: #barcode# <br>
      Install Date: #parent_install_date# <br>
      Remarks: #container_remarks# <br>
      Fluid Checked Date: #checked_date# <br>
      Fluid Type: #fluid_type# <br>
      Concentration: #concentration# <br>
      Fluid Remarks: #fluid_remarks#</font> <br>
		</cfif>
				
		<cfif #mkCont# is "invalid">
      <font color="##FF0000"><br>
      You have not entered enough data to create a container. Container Type is 
      a required field.</font> 
    </cfif>
		<cfif #mkCont# is "valid" and #mkFluid# is "invalid">
      <font color="##FF0000"><br>
      It appears that you are trying to create a fluid container, but you have 
      not entered enough information to do so.</font> 
    </cfif>
</cfoutput>
</cfif><!---end of <cfif URL.action is "CreateNew">--->





<cfquery name="ContType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
select container_type as ctContType from ctcontainer_type
</cfquery>
<cfquery name="FluidType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
select fluid_type from ctFluid_Type ORDER BY fluid_type
</cfquery>

 <form name="form1" method="post" action="CreateContainer.cfm?&action=CreateNew">
<table border="0">
  <tr>
    <td colspan="2" align="center">
		<b>Create Container</b>

	</td>
	</tr>
	<tr>
		<td align="right"><b>Container Type:</b></td>
		<td>
			  <select name="Container_Type" size="1" class="reqdClr">
				<option value=""></option>
					<cfoutput query="ContType"> 
						 <cfif #ContType.ctContType# is not "collection object">
			            <option value="#ContType.ctContType#">#ContType.ctContType#</option>
						</cfif>
          			</cfoutput> 
			</select>
		</td>
	</tr>
	<tr>
		<td align="right"><b>Dimensions:</b></td>
		<td>
			W: <input name="width" type="text" value="" size="6">
			H: <input name="height" type="text" value="" size="6">
			L: <input name="length" type="text" value="" size="6">
		</td>
	</tr>
	<tr>
		<td align="right"><b>Number of Positions:</b></td>
		<td>
			<input name="number_positions" type="text" value="">
			
		</td>
	</tr>
	<tr>
		<td align="right"><b>Description:</b></td>
		<td>
			<input name="description" type="text" value="">
		</td>
	</tr>
	<tr>
		<td align="right"><b>Barcode:</b></td>
		<td><input name="barcode" type="text" value=""></td>
	</tr>
	<tr>
		<td align="right"><b>Label:</b></td>
		<td><input name="label" type="text" value="" class="reqdClr"></td>
	</tr>
	<tr>
		<td align="right"><b>Install Date:</b></td>
		<td><input name="parent_install_date" type="text" value="" class="reqdClr"></td>
	</tr>
	<tr>
		<td align="right"><b>Remarks:</b></td>
		<td><input name="container_remarks" type="text" value=""></td>
	</tr>
	<tr>
		<td align="right"><b>Fluid Checked Date:</b></td>
		<td><input name="checked_date" type="text" value=""></td>
	</tr>
	<tr>
		<td align="right"><b>Fluid Type:</b></td>
		<td> 
			<select name="Fluid_Type" size="1">
				<option value=""></option>
		          <cfoutput query="FluidType"> 
        		    <option value="#FluidType.Fluid_Type#">#FluidType.Fluid_Type#</option>
		          </cfoutput>
				 </select>
		</td>
	</tr>
	<tr>
		<td align="right"><b>Fluid Concentration:</b></td>
		<td><input name="concentration" type="text" value=""></td>
	</tr>
	<tr>
		<td align="right"><b>Fluid Remarks: </b></td>
		<td>
			<input name="fluid_remarks" type="text" value="">
		</td>
	</tr>
	<tr>
		
		<td colspan="2" align="center"> 
			<cfoutput>
			  <input type="submit" value="Create Container" class="insBtn"
				onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">	
			</cfoutput>
	  </td>
	</tr>
</table>

      
 </form>

<cfinclude template = "includes/_footer.cfm">