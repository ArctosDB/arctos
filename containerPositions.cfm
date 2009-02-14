<script type='text/javascript' src='/ajax/core/engine.js'></script>
<script type='text/javascript' src='/ajax/core/util.js'></script>
<script type='text/javascript' src='/ajax/core/settings.js'></script>	
<cfinclude template="/includes/_header.cfm">
<style>
	input.activeCell {
		background-color:#FF0000;
		}
	input.hasData {
		background-color:#FFFF00;
		}
	div.cellDiv {
		width:100%; 
		height:100%; 
		border:1px solid black; 
		background-color:#F4F4F4;
		}
	span.labelSpan {
		 border:1px solid black;
		 font-size:x-small;
		 background-color:#CCCCCC;
		 }
	span.innerSpan {
		 font-size:x-small;
		 text-align:center;
		 }
</style>
<script>
	function checkSave (boxID,content) {
		var boxID;
		var content;
		if (content.length > 0) {
			alert(content)
		}
	}
	function moveContainer (boxID,barcode) {
		//alert('leaving');
		var container_id = document.getElementById('container_id').value;
		var box_position = boxID.replace('barcode','');
		var psnIdEl = "position_id" + box_position;
		var position_idStr = "document.getElementById('" + psnIdEl + "').value";
		var position_id = eval(position_idStr);
		//alert("box_position: " + box_position + "; position_id: " + position_id + "; barcode: " + barcode );
		DWREngine._execute(_cfscriptLocation, null, 'moveContainer', box_position,position_id,barcode, success_moveContainer);
		/*
		var boxID;
		var content;
		
		var p=document.getElementById(boxID);
		//var theBox = 'document.newScans.' + boxID + '.className=\'c\'';
		if (content.length > 0) {
			p.className='hasData';
		} else {
			p.className='';
		}
		*/
	}
	function success_moveContainer (result) {
		//alert(result);
		var resArray=result.split("|");
		var box_position = resArray[0];
		var msg = resArray[1];
		//alert("p: " + box_position);
		//alert("m: " + msg);
		if (box_position > 0) {
			var thePositionStr = "document.getElementById('barcode" + box_position + "')";
			var thisBarcodeTextBox = eval(thePositionStr);
			//alert(thePositionStr);
			//alert(thisBarcodeTextBox);
			//alert('s');
			var thisVal = thisBarcodeTextBox.value;
			//alert('s2');
			thisBarcodeTextBox.style.display = 'none';
			//alert('s3');
			var theSpanStr = "document.getElementById('theSpan" + box_position + "')";
			var theSpan = eval(theSpanStr);
			var nn = document.createTextNode(thisVal);
			var br = document.createElement("BR");
			var label = document.createTextNode(msg);
			
			//nn.value = thisVal;
			theSpan.appendChild(nn);
			theSpan.appendChild(br);
			theSpan.appendChild(label);
			
			
			
			//thePosition.className = 'readClr';
			//thePosition.readOnly= true;
			//thePostion.setAttribute('readOnly',true);
		} else{
			var absPosn = Math.abs(box_position);
			alert("Error! Position " + absPosn + " save was not successful. The error is: \n" + msg);
		}
		
	}
	//	="checkSave('barcode#thisLabel#')"
</script>

<cfif #action# is "nothing">
	<cfoutput>
	<cfquery name="aBox" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from container where container_id=#container_id#
	</cfquery>
	
	<!---- figure out what they're trying to do and set some variables ---->
	<cfif #aBox.number_positions# is 100 AND #aBox.container_type# is "freezer box">
		<cfset goodPositionType = "position">
		<cfset numberRows = 10>
		<cfset numberColumns = 10>
	<cfelseif #aBox.number_positions# is 81 AND #aBox.container_type# is "freezer box">
		<cfset goodPositionType = "position">
		<cfset numberRows = 9>
		<cfset numberColumns = 9>
	<cfelseif #aBox.number_positions# is 48 AND #aBox.container_type# is "freezer">
		<cfset goodPositionType = "position">
		<cfset numberRows = 12>
		<cfset numberColumns = 4>
	<cfelseif #aBox.number_positions# is 33 AND #aBox.container_type# is "freezer">
		<cfset goodPositionType = "position">
		<cfset numberRows = 11>
		<cfset numberColumns = 3>
	<cfelse>
		<p>
			<strong><font color="##FF0000">This application won't do what you want to do. 
				<ul>
					<li>
						 You must have a container with positons.
					</li>
					<li>
						Position labels must be numeric
					</li>
					<li>
						Position labels must be less than the number
			of positions in the box.
					</li>
				</ul>
			<p>
			If you have that and you're still getting this error, submit a <a href="/info/bugs.cfm">bug report</a>.
			</font></strong>	 
			<cfabort>
	</cfif>
	<!---global--->
	<cfset thisLabel = 1>
		<!---- see is positions are used ---->
		<cfquery name="whatPosAreUsed" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select container_id, container_type, label from container
			where parent_container_id = #aBox.container_id#
		</cfquery>
		<cfif #whatPosAreUsed.recordcount# is 0>
			There's nothing in this container.
			<form name="allnewPos" method="post" action="containerPositions.cfm">
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
			<cfif #uContentType.recordcount# is 1 AND 
				#uContentType.container_type# is '#goodPositionType#'>
				<!--- keep moving, nothing to see here .... ---->
			<cfelse>
				<hr>
					<font color="##FF0000">
						There is a problem with the positions in this box. 
						<br>It contains things other than positions, or inappropriate position types. 
						This application can't handle that! Get rid of things that 
						aren't container_type '#goodPositionType#' or submit a bug report if you feel this container should
						hold the things listed below:
						<ul>
							<cfloop query="uContentType">
								<li>#container_type#</li>
							</cfloop>
						</ul>
					</font>	
					<cfabort>
			</cfif>
			<!----it's all positions ---->
			<cfif #whatPosAreUsed.recordcount# is not #aBox.number_positions#>
				<hr>
				<font color="##FF0000">
					There is a problem with the positions in this box. Aborting....
				</font>			
				<cfabort>
			<cfelse>
					<!---- do nothing
						all positions are used - yea!! 
						Now we need to be sure that the labels are numeric. They should be
						if the box positions have been built by this application.
					---->
			</cfif>
			<cfloop query="whatPosAreUsed">
				<cfif not isnumeric(#label#)>
					<hr><font color="##FF0000">Some position labels aren't numeric!</font>						  					<cfabort>
				</cfif>
			</cfloop>
			<!---- made it through the checks, now actually do stuff --->
			<cfquery name="positionContents" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					posCon.container_id ,
					posCon.label contentLabel,
					posCon.barcode posConBc,
					pos.label label,
					pos.container_id position_id
				from 
					container posCon,
					container pos
				where
					pos.container_id = posCon.parent_container_id (+) and
					pos.parent_container_id = #container_id#
			</cfquery>
			<form name="newScans" method="post" action="containerPositions.cfm" onsubmit="return noenter();">
			<table border>
				<tr>
					<td>
			<table cellpadding="0" cellspacing="0" border="1">
					
					<input type="hidden" name="action" value="moveScans">
					<input type="hidden" name="number_positions" value="#aBox.number_positions#">
					<input type="hidden" name="container_id" id="container_id" value="#aBox.container_id#">
					<cfloop from="1" to="#numberColumns#" index="col">
						<tr height="50" valign="top">
							<cfloop from="1" to="#numberRows#" index="row">
								<td width="60" align="left">
									<!--- now, we can get the contents of this cell 
											First, get the container_id for this label from a 
											cached query, then get the contents from the DB
									---->
									<cfquery name="thisPos" dbtype="query">
										select container_id, position_id,contentLabel,posConBc from positionContents
										where label = '#thisLabel#'
									</cfquery>
									<div class="cellDiv">
									<span class="labelSpan">
											#thisLabel#
									</span>
									<span class="innerSpan" id="theSpan#thisLabel#">
											<cfif len(#thisPos.container_id#) gt 0>
												<br>#thisPos.contentLabel#
												<br>#thisPos.posConBc#
											<cfelse>
												Barcode:<br>
												
												<input type="hidden" 
													name="position_id#thisLabel#" 
													id="position_id#thisLabel#" 
													value="#thisPos.position_id#">
												<input type="text" 
													onFocus="this.className='activeCell'"
													onChange="moveContainer('barcode#thisLabel#',this.value)"
													name="barcode#thisLabel#"
													id="barcode#thisLabel#"
													size="6" 
													style="font-size:small;">
											</cfif>
										</span>
									</div>
									<cfset thisLabel = #thisLabel# + 1>
								</td>
							</cfloop>
						</tr>							
					</cfloop>
						
					</table>
				
			</cfif>
		</td>
	<td nowrap valign="top">
	<font size="-1">
		Label: <strong>#abox.label#</strong>
		<br>Barcode: 
		<strong>#aBox.barcode#</strong>
		<br> Type: 
		<strong>#aBox.container_type#</strong>
	</font>
	<p>
							
	</form>
	</td>
	
	
				</tr>
			</table>
			</cfoutput>

</cfif>
<!------------------------------------------------------------------------------>
<cfif #action# is "moveScans">
	<!--- generate a list of child/parent/timestamp and put it into the standard container upload table ---->
	<cfoutput>
		<cfset thisDate = dateformat(now(),"dd-mmm-yyyy")>
		<cfset oops = "">
		<cfquery name="cleanup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from cf_temp_container_location
		</cfquery>
		<cftransaction>
		<cfloop from="1" to="#number_positions#" index="bc">
			<cfset thisContainerId = "">
		 	<cfif isdefined("barcode" & bc)>
				<cfset thisBarcode = #evaluate("barcode" & bc)#>
				<cfset thisParentId = #evaluate("position_id" & bc)#>
				<cfif len(#thisBarcode#) gt 0>
					
						<cfquery name="thisID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							select container_id from container where barcode='#thisBarcode#'
							<!--- we should only be putting cyrovials in box positions ---->
							AND container_type = 'cryovial'						
						</cfquery>
							
						<cfif #thisID.recordcount# is 0>
								<!--- see if it's a label --->
								<cfquery name="isLabel" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
									select container_id from container where barcode='#thisBarcode#'
									AND container_type = 'cryovial label'
								</cfquery>
								<cfif #isLabel.recordcount# is 1>
									<!--- switch --->
									<cfquery name="update" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
										update container set container_type='cryovial'
										where container_id=#isLabel.container_id#
									</cfquery>
									<cfset thisContainerId = #isLabel.container_id#>	
								</cfif>
								<cfset thisContainerId = #isLabel.container_id#>	
						<cfelseif #thisID.recordcount# is 1>
							<cfset thisContainerId = #thisID.container_id#>	
						<cfelse>
							bad juju<cfabort>
						</cfif>
						
					<cfif len(#thisContainerId#) gt 0>
						
						<cfquery name="putItIn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
						<cfset oops = "#oops#; no container matched barcode #thisBarcode#!">
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		</cftransaction>
		<CFIF LEN(#oops#) gt 0>
			<!--- cleanup on isle no container.... ---->
			<cfquery name="cleanup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				delete from cf_temp_container_location
			</cfquery>
			<hr><font color="##FF0000">#oops#</font>			
		<cfelse>
			<!--- check these, move them, and tell the user to go back ---->
			<!---- include the mover over application ---->
			<cfset action="update">
			<cfinclude template="/LoadBarcodes.cfm">
			<cflocation url="containerPositions.cfm?container_id=#container_id#">
		</CFIF>
	</cfoutput>
</cfif>


<!------------------------------------------------------------------------------>
<cfif #action# is "allNewPositions">
	<cfoutput>
		<cfif #number_positions# is 100 and #container_type# is "freezer box">
			<cfset position_label = "position">
			<cfset width = 1.2>
			<cfset length = 1.2>
			<cfset height = 4.9>
		<cfelseif #number_positions# is "48" and #container_type# is "freezer">
			<cfset position_label = "position">
			<cfset width = 14>
			<cfset height = 80>
			<cfset length = 14>
		<cfelseif #number_positions# is "33" and #container_type# is "freezer">
			<cfset position_label = "position">
			<cfset width = 14>
			<cfset height = 80>
			<cfset length = 14>
		<cfelseif #number_positions# is 81 AND #container_type# is "freezer box">
			<cfset position_label = "position">
			<cfset width = 1.2>
			<cfset length = 1.2>
			<cfset height = 4.9>		
		<cfelse>
			<hr><font color="##FF0000">I can't deal with #number_positions# positions in a #container_type#!</font>			
			<cfabort>
		</cfif>
		<!--- there is nothing in this box, make all positions ---->
		<cftransaction>
			<!---- next container ID ---->
			<cfquery name="nid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select sq_container_id container_id from dual
			</cfquery>
			<cfset contID = #nid.container_id# + 1>
			<cfset thisDate = dateformat(now(),"dd-mmm-yyyy")>
			<!--- make number_positions new containers, lock them, and put them in this box ---->
			<cfloop from="1" to="#number_positions#" index="i">
				<cfquery name="new" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO container (
					CONTAINER_ID,
					PARENT_CONTAINER_ID,
					CONTAINER_TYPE,
					LABEL,
					PARENT_INSTALL_DATE,
					WIDTH,
					HEIGHT,
					length,
					NUMBER_POSITIONS,
					LOCKED_POSITION,
					institution_acronym)
				VALUES (
					#contID#,
					#container_id#,
					'#position_label#',
					'#i#',
					'#thisDate#',
					#width#,
					#height#,
					#length#,
					1,
					1,
					'UAM')
					</cfquery>
					<cfset contID = #contID# + 1>
			</cfloop>
		</cftransaction>
		<cflocation url="containerPositions.cfm?container_id=#container_id#">
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">