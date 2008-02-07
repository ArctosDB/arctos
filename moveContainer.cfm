<cfinclude template="/includes/_header.cfm">
<!----------------->
<div style="float:right; position:absolute; right:0; top:100;">
	<cfinclude template="container_nav.cfm">
</div>
<cfif #action# is "nothing">
<cfoutput>
<table>
	<tr>
		
	
	<cfset thisDate = dateformat(now(),"dd mmm yyyy")>
	<form name="moveIt" method="post" action="moveContainer.cfm">
		<input type="hidden" name="action" value="moveIt">
		<cfparam name="parent_barcode" default="">
		<td><font size="-1">Parent Barcode:<br></font><input type="text" name="parent_barcode" value="#parent_barcode#"></td>
		<td><font size="-1">Child Barcode:<br></font>
		  <input type="text" name="child_barcode" id="child_barcode"></td>		
		<td><font size="-1">Timestamp:<br></font> <input type="text" name="timestamp" value="#thisDate#"></td>
		<td><font size="-1">&nbsp;<br></font>
		<input type="submit" 
					value="Move Container" 
					class="savBtn"
					onmouseover="this.className='savBtn btnhov'"
					onmouseout="this.className='savBtn'"></td>
		<td><font size="-1">&nbsp;<br></font>
		<input type="reset" 
					value="Clear Form" 
					class="clrBtn"
					onmouseover="this.className='clrBtn btnhov'"
					onmouseout="this.className='clrBtn'"></td>
		
		
	</form>
	<script>
	document.moveIt.child_barcode.focus();
</script>
</tr>
</table>
</cfoutput>
</cfif>
<!----------------->
<cfif #action# is "moveIt">
<cfoutput>
	<cfquery name="timeFormat" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		ALTER SESSION SET nls_date_format = 'DD-Mon-YYYY hh24:mi:ss' 
	</cfquery>
	<cfparam name="locked_position" default="">

	<cfquery name="c" datasource="#Application.web_user#">
		select container_id from container where barcode = '#child_barcode#'
	</cfquery>
	<cfquery name="p" datasource="#Application.web_user#">
		select container_id from container where barcode = '#parent_barcode#'
	</cfquery>
<!---
<cfquery name="cleanup" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	delete from cf_temp_container_location
</cfquery>
--->
	<cfif #c.recordcount# is 1 AND #p.recordcount# is 1>
		<cfquery name="new" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		INSERT INTO cf_temp_container_location (
			container_id,
			parent_container_id,
			timestamp)
			VALUES (
				#c.container_id#,
				#p.container_id#,
				'#timestamp#')
		</cfquery>
		Load to temp table was successful.
		<p></p>
		<a href="moveContainer.cfm?parent_barcode=#parent_barcode#">Move another container</a>
		OR <a href="checkContainerMovement.cfm">Load to data tables</a>
	<cfelse>
		Bad pair; nothing has been saved
	</cfif>
</cfoutput>
	 <!---
		<cfquery name="getDump" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				SELECT container_id, parent_container_id, timestamp FROM cf_temp_container_location
	group by
	container_id, parent_container_id, timestamp
		</cfquery>
		<cfloop query="getDump">
			<!---- don't do anything if it's already been done ---->
			<cfquery name="itsThere" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				select count(*) cnt from container where
				parent_container_id = #parent_container_id# and
				to_char(parent_install_date,'DD-Mon-YYYY')='#dateformat(timeStamp,"dd-mmm-yyyy")#' and
				container_id=#container_id#
			</cfquery>
			<cfif #itsThere.cnt# is 0>
				<!--- format the timestamp ---->
				<cfset ts = '#dateformat(timestamp,"dd-mmm-yyyy")# #timeformat(timestamp,"HH:mm:ss")#'>
				
						<cfquery name="upCont" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
					UPDATE container SET
						parent_container_id = #parent_container_id#,
						parent_install_date='#ts#'
						<cfif len(#locked_position#) gt 0>
							,locked_position = #locked_position#
						</cfif>
					WHERE
						container_id=#container_id#
				</cfquery>
			</cfif>
		
		</cfloop>
		--->
		

</cfif>
<!----------------->
<cfinclude template="/includes/_footer.cfm">
