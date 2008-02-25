obsolete<cfabort>



<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">

<cfoutput>
	<cfquery name="aBox" datasource="#Application.web_user#">
		select * from container where container_id=#container_id#
	</cfquery>
	<font size="-1">Label: <strong>#abox.label#</strong> Barcode: <strong>#aBox.barcode#</strong> Type: <strong>#aBox.container_type#</strong></font>
	<cfif #aBox.number_positions# is 100 AND #aBox.container_type# is "freezer box">
		<!---- see is positions are used ---->
		<cfquery name="whatPosAreUsed" datasource="#Application.web_user#">
			select container_id, container_type, label from container
			where parent_container_id = #aBox.container_id#
		</cfquery>
		<cfif #whatPosAreUsed.recordcount# is 0>
			There's nothing in this container.
			<form name="allnewPos" method="post" action="boxPositions.cfm">
				<input type="hidden" name="action" value="allNewPositions">				
				<input type="hidden" name="container_type" value="#aBox.container_type#">
				<input type="hidden" name="container_id" value="#aBox.container_id#">
				<input type="hidden" name="number_positions" value="#aBox.number_positions#">
				<input type="submit" 
					value="Create all new positions" 
					class="insBtn"
					onmouseover="this.className='insBtn btnhov'"
					onmouseout="this.className='insBtn'">
			</form>
		<cfelse>
			<!--- there's something in the box - what? ---->
			<cfquery name="uContentType" dbtype="query">
				select container_type from whatPosAreUsed
				group by container_type
			</cfquery>
			<cfif #uContentType.recordcount# is 1 AND #uContentType.container_type# is 'freezer box position'>
				<!----it's all positions ---->
				<cfif #whatPosAreUsed.recordcount# is #aBox.number_positions#>
					<!---- all positions are used - yea!! 
						Now we need to be sure that the labels are numeric. They should be
						if the box positions have been built by this application.
					---->
					<cfloop query="whatPosAreUsed">
						<cfif not isnumeric(#label#)>
							<hr><font color="##FF0000">Some box position labels aren't numeric!</font>						  
							<cfabort>
						</cfif>
					</cfloop>
							<cfset numberRows = 10>
							<cfset numberColumns = 10>
							<cfset thisLabel = 1>
							<cfquery name="positionContents" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
								select 
									posCon.container_id ,
									posCon.label contentLabel,
									pos.label label,
									pos.container_id position_id
								from 
									container posCon,
									container pos
								where
									pos.container_id = posCon.parent_container_id (+) and
									pos.parent_container_id = #container_id#
							</cfquery>
							
							<table cellpadding="0" cellspacing="0" border="1">
							<form name="newScans" method="post" action="boxPositions.cfm">
								<input type="hidden" name="action" value="moveScans">
								<input type="hidden" name="number_positions" value="#aBox.number_positions#">
								<input type="hidden" name="container_id" value="#aBox.container_id#">
							<cfloop from="1" to="#numberColumns#" index="col">
								<tr height="50" valign="top">
									<cfloop from="1" to="#numberRows#" index="row">
										<td width="60" align="left">
											<!--- now, we can get the contents of this cell 
											First, get the container_id for this label from a 
											cached query, then get the contents from the DB
											
											<cfquery name="thisID" dbtype="query">
												select container_id from whatPosAreUsed
												where label = '#thisLabel#'
											</cfquery>
											<cfquery name="thisPosHolds" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
												select container_id from container
												where parent_container_id = #thisID.container_id#
											</cfquery>
											---->
											<cfquery name="thisPos" dbtype="query">
												select container_id, position_id,contentLabel from positionContents
												where label = '#thisLabel#'
											</cfquery>
											<div style="width:100%; height:100%; border:1px solid black; background-color:##E5E5E5">
											<span style="border:1px solid black; font-size:x-small; background-color:##CCCCCC">
												#thisLabel#
											</span>
											<span style="font-size:x-small;">
												<cfif len(#thisPos.container_id#) gt 0>
														<br>#thisPos.contentLabel#
													<cfelse>
														Barcode:<br>
														<input type="hidden" name="position_id#thisLabel#" value="#thisPos.position_id#">
														<input type="text" name="barcode#thisLabel#" size="6" style="font-size:small; ">
										  </cfif>
											</span>
											 </div>
												<cfset thisLabel = #thisLabel# + 1>
											
										</td>
									</cfloop>
								</tr>							
							</cfloop>
							<tr>
								<td colspan="10" align="center">
									<input type="submit" 
										value="Save" 
										class="savBtn"
										onmouseover="this.className='savBtn btnhov'"
										onmouseout="this.className='savBtn'">
				
								</td>
							</tr>
							</form>
							
						</table>
				<cfelse>
					<hr><font color="##FF0000">There is a problem with the positions in this box. 
					</font>			
					<cfabort>
				</cfif>
			<cfelse>
				<hr><font color="##FF0000">There is a problem with the positions in this box. 
				</font>			
					<cfabort>
			</cfif>
		</cfif>
	<cfelseif #aBox.number_positions# is 48 AND #aBox.container_type# is "freezer">
		<!--- it's a freezzer --->
		<!---- see is positions are used ---->
		<cfquery name="whatPosAreUsed" datasource="#Application.web_user#">
			select container_id, container_type, label from container
			where parent_container_id = #aBox.container_id#
		</cfquery>
		<cfif #whatPosAreUsed.recordcount# is 0>
			There's nothing in this container.
			<form name="allnewPos" method="post" action="boxPositions.cfm">
				<input type="hidden" name="action" value="allNewPositions">
				<input type="hidden" name="container_type" value="#aBox.container_type#">
				<input type="hidden" name="container_id" value="#aBox.container_id#">
				<input type="hidden" name="number_positions" value="#aBox.number_positions#">
				<input type="submit" 
					value="Create all new positions" 
					class="insBtn"
					onmouseover="this.className='insBtn btnhov'"
					onmouseout="this.className='insBtn'">
			</form>
		<cfelse>
			<!--- there's something in the box - what? ---->
			<cfquery name="uContentType" dbtype="query">
				select container_type from whatPosAreUsed
				group by container_type
			</cfquery>
			<cfif #uContentType.recordcount# is 1 AND #uContentType.container_type# is 'rack position'>
				<!----it's all positions ---->
				<cfif #whatPosAreUsed.recordcount# is #aBox.number_positions#>
					<!---- all positions are used - yea!! 
						Now we need to be sure that the labels are numeric. They should be
						if the box positions have been built by this application.
					---->
					<cfloop query="whatPosAreUsed">
						<cfif not isnumeric(#label#)>
							<hr><font color="##FF0000">Some position labels aren't numeric!</font>						  
							<cfabort>
						</cfif>
					</cfloop>
							<cfset numberRows = 12>
							<cfset numberColumns = 4>
							<cfset thisLabel = 1>
							<cfquery name="positionContents" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
								select 
									posCon.container_id ,
									posCon.label contentLabel,
									pos.label label,
									pos.container_id position_id
								from 
									container posCon,
									container pos
								where
									pos.container_id = posCon.parent_container_id (+) and
									pos.parent_container_id = #container_id#
							</cfquery>
							
							<table cellpadding="0" cellspacing="0" border="1">
							<form name="newScans" method="post" action="boxPositions.cfm">
								<input type="hidden" name="action" value="moveScans">
								<input type="hidden" name="number_positions" value="#aBox.number_positions#">
								<input type="hidden" name="container_id" value="#aBox.container_id#">
							<cfloop from="1" to="#numberColumns#" index="col">
								<tr height="50" valign="top">
									<cfloop from="1" to="#numberRows#" index="row">
										<td width="60" align="left">
											<!--- now, we can get the contents of this cell 
											First, get the container_id for this label from a 
											cached query, then get the contents from the DB
											
											<cfquery name="thisID" dbtype="query">
												select container_id from whatPosAreUsed
												where label = '#thisLabel#'
											</cfquery>
											<cfquery name="thisPosHolds" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
												select container_id from container
												where parent_container_id = #thisID.container_id#
											</cfquery>
											---->
											<cfquery name="thisPos" dbtype="query">
												select container_id, position_id,contentLabel from positionContents
												where label = '#thisLabel#'
											</cfquery>
											<div style="width:100%; height:100%; border:1px solid black; background-color:##E5E5E5">
											<span style="border:1px solid black; font-size:x-small; background-color:##CCCCCC">
												#thisLabel#
											</span>
											<span style="font-size:x-small;">
												<cfif len(#thisPos.container_id#) gt 0>
														<br>#thisPos.contentLabel#
													<cfelse>
														Barcode:<br>
														<input type="hidden" name="position_id#thisLabel#" value="#thisPos.position_id#">
														<input type="text" name="barcode#thisLabel#" size="6" style="font-size:small; ">
										  </cfif>
											</span>
											 </div>
												<cfset thisLabel = #thisLabel# + 1>
											
										</td>
									</cfloop>
								</tr>							
							</cfloop>
							<tr>
								<td colspan="10" align="center">
									<input type="submit" 
										value="Save" 
										class="savBtn"
										onmouseover="this.className='savBtn btnhov'"
										onmouseout="this.className='savBtn'">
				
								</td>
							</tr>
							</form>
							
						</table>
				<cfelse>
					<hr><font color="##FF0000">There is a problem with the positions in this box. 	
					<br>Most likely, it contains things other than positions. You can't do that!</font>			
					<cfabort>
				</cfif>
			<cfelse>
				<hr><font color="##FF0000">There is a problem with the positions in this box. 
				
				<br>Most likely, it contains something other than positions. You can't do that!</font>			
					<cfabort>
			</cfif>
		</cfif>	
	<cfelse><!--- not a box and/or unknown positions---->
		<hr><font color="##FF0000">This container is not a freezer box, or it does not have 100 positions. This application can't 
		deal with that!</font>			
		<cfabort>
	</cfif>
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------>
<cfif #action# is "moveScans">
	<!--- generate a list of child/parent/timestamp and put it into the standard container upload table ---->
	<cfoutput>
		<cfset thisDate = dateformat(now(),"dd-mmm-yyyy")>
		<cfset oops = "">
		<cfquery name="cleanup" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			delete from cf_temp_container_location
		</cfquery>
		<cftransaction>
		<cfloop from="1" to="#number_positions#" index="bc">
			<cfset thisContainerId = "">
		 	<cfif isdefined("barcode" & bc)>
				<cfset thisBarcode = #evaluate("barcode" & bc)#>
				<cfset thisParentId = #evaluate("position_id" & bc)#>
				<cfif len(#thisBarcode#) gt 0>
					
						<cfquery name="thisID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
							select container_id from container where barcode='#thisBarcode#'
							<!--- we should only be putting cyrovials in box positions ---->
							AND container_type = 'cryovial'						
						</cfquery>
							
						<cfif #thisID.recordcount# is 0>
								<!--- see if it's a label --->
								<cfquery name="isLabel" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
									select container_id from container where barcode='#thisBarcode#'
									AND container_type = 'cryovial label'
								</cfquery>
								<cfif #isLabel.recordcount# is 1>
									<!--- switch --->
									<cfquery name="update" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
										update container set container_type='cryovial'
										where container_id=#isLabel.container_id#
									</cfquery>
									<cfset thisContainerId = #isLabel.container_id#>	
								</cfif>
						<cfelseif #thisID.recordcount# is 1>
							<cfset thisContainerId = #thisID.container_id#>	
						<cfelse>
							bad juju<cfabort>
						</cfif>
						
					<cfif len(#thisContainerId#) gt 0>
						
						<cfquery name="putItIn" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
							INSERT INTO cf_temp_container_location (
								CONTAINER_ID,
								PARENT_CONTAINER_ID,
								TIMESTAMP )
							VALUES (
								#thisContainerId#,
								#thisParentId#,
								'#thisDate#')
						</cfquery>
					<cfelse>
						<cfset oops = "#oops#; no appropriate container matched barcode #thisBarcode#!">
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		</cftransaction>
		<CFIF LEN(#oops#) gt 0>
			<!--- cleanup on isle no container.... ---->
			<cfquery name="cleanup" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				delete from cf_temp_container_location
			</cfquery>
			<hr><font color="##FF0000">#oops#</font>			
		<cfelse>
			<!--- check these, move them, and tell the user to go back ---->
			<!---- include the mover over application ---->
			<cfset action="update">
			<cfinclude template="/LoadBarcodes.cfm">
			<cflocation url="boxPositions.cfm?container_id=#container_id#">
		</CFIF>
	</cfoutput>
</cfif>


<!------------------------------------------------------------------------------>
<cfif #action# is "allNewPositions">
	<cfoutput>
		<cfif #number_positions# is 100 and #container_type# is "freezer box">
			<cfset position_label = "freezer box position">
			<cfset width = 1.2>
			<cfset depth = 1.2>
			<cfset height = 4.9>
		<cfelseif #number_positions# is "48" and #container_type# is "freezer">
			<cfset position_label = "rack position">
			<cfset width = 14>
			<cfset height = 80>
			<cfset depth = 14>
		<cfelse>
			<hr><font color="##FF0000">I can't deal with #number_positions# positions in a #container_type#!</font>			
			<cfabort>
		</cfif>
		<!--- there is nothing in this box, make all positions ---->
		<cftransaction>
			<!---- next container ID ---->
			<cfquery name="nid" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				select max(container_id) container_id from container
			</cfquery>
			<cfset contID = #nid.container_id# + 1>
			<cfset thisDate = dateformat(now(),"dd-mmm-yyyy")>
			<!--- make number_positions new containers, lock them, and put them in this box ---->
			<cfloop from="1" to="#number_positions#" index="i">
				<cfquery name="new" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				INSERT INTO container (
					CONTAINER_ID,
					PARENT_CONTAINER_ID,
					CONTAINER_TYPE,
					LABEL,
					PARENT_INSTALL_DATE,
					WIDTH,
					HEIGHT,
					depth,
					NUMBER_POSITIONS,
					LOCKED_POSITION)
				VALUES (
					#contID#,
					#container_id#,
					'#position_label#',
					'#i#',
					'#thisDate#',
					#width#,
					#height#,
					#depth#,
					1,
					1)
					</cfquery>
					<cfset contID = #contID# + 1>
			</cfloop>
		</cftransaction>
		<cflocation url="boxPositions.cfm?container_id=#container_id#">
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">