<cfinclude template="/includes/_header.cfm">
<style>
	input.activeCell {
		background-color:#FF0000;
		}
	input.hasData {
		background-color:#FFFF00;
		}
	div.ccellDiv {
		width:100%;
		height:100%;
		border:1px solid black;
		background-color:#F4F4F4;
		}
	span.labelSpanOLD {
		 border:1px solid black;
		 font-size:x-small;
		 background-color:#CCCCCC;
		 }
	span.labelSpan {
		 border:1px solid black;
		 background-color:#CCCCCC;
		 }
	span.innerSpan {
		 text-align:center;
		 }
	span.innerSpanOLD {
		 font-size:x-small;
		 text-align:center;
		 }
	.xsmallFont{
		font-size:x-small;
	}
	.smallFont{
		font-size:small;
	}
	.mediumFont{
		font-size:medium;
	}
	.largeFont{
		font-size:large;
	}
	.xlargeFont{
		font-size:x-large;
	}
	.xxlargeFont{
		font-size:xx-large;
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
		var container_id = document.getElementById('container_id').value;
		var box_position = boxID.replace('barcode','');
		var psnIdEl = "position_id" + box_position;
		var position_idStr = "document.getElementById('" + psnIdEl + "').value";
		var position_id = eval(position_idStr);
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "moveContainer",
				box_position : box_position,
				position_id : position_id,
				barcode : barcode,
				acceptableChildContainerType: $("#acceptableChildContainerType").val(),
				returnformat : "json",
				queryformat : 'column'
			},
			success_moveContainer
		);
	}
	function success_moveContainer (result) {
		var resArray=result.split("|");
		var box_position = resArray[0];
		var msg = resArray[1];
		if (box_position > 0) {
			var thePositionStr = "document.getElementById('barcode" + box_position + "')";
			var thisBarcodeTextBox = eval(thePositionStr);
			var thisVal = thisBarcodeTextBox.value;
			thisBarcodeTextBox.style.display = 'none';
			var theSpanStr = "document.getElementById('theSpan" + box_position + "')";
			var theSpan = eval(theSpanStr);
			var nn = document.createTextNode(thisVal);
			var br = document.createElement("BR");
			var label = document.createTextNode(msg);
			theSpan.appendChild(nn);
			theSpan.appendChild(br);
			theSpan.appendChild(label);
		} else{
			var absPosn = Math.abs(box_position);
			alert("Error! Position " + absPosn + " save was not successful. The error is: \n" + msg);
		}
	}
	function changeTableFont(s){

		$(".ccellDiv").removeClass().addClass('ccellDiv').addClass(s);
	}
</script>

<cfif action is "nothing">
<cfoutput>
	<cfset title = 'scan items into positions in containers'>
	<cfquery name="aBox" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from container where container_id=#container_id#
	</cfquery>
	<!--- require sufficient data --->
	<cfif len(aBox.NUMBER_ROWS) is 0 or len(aBox.NUMBER_COLUMNS) is 0 or len(aBox.ORIENTATION) is 0 or len(aBox.POSITIONS_HOLD_CONTAINER_TYPE) is 0>
		insufficient data to proceed; you must have
		<ul>
			<li>NUMBER_ROWS</li>
			<li>NUMBER_COLUMNS</li>
			<li>ORIENTATION</li>
			<li>POSITIONS_HOLD_CONTAINER_TYPE</li>
		</ul>
		to use this form
		<cfabort>
	</cfif>

	<cfset taborder=aBox.ORIENTATION>
	<cfset acceptableChildContainerType=aBox.POSITIONS_HOLD_CONTAINER_TYPE>
	<cfset numberRows = aBox.NUMBER_ROWS>
	<cfset numberColumns = aBox.NUMBER_COLUMNS>

	<!---global--->
	<!---- see is positions are used ---->
	<cfquery name="whatPosAreUsed" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select container_id, container_type, label from container
		where parent_container_id = #aBox.container_id#
	</cfquery>
	<cfif whatPosAreUsed.recordcount is 0>
		There's nothing in this container.
		<br>You can create positions in empty position-appropriate containers.
		<br>(Positions will use the parent's institution.)
		<cfif abox.container_type is "freezer box">
			<cfset width = 1.2>
			<cfset length = 1.2>
			<cfset height = 4.9>
		<cfelseif abox.container_type is "freezer">
			<cfset width = 14>
			<cfset height = 80>
			<cfset length = 14>
		<cfelseif abox.container_type is "slide box">
			<cfset width = 3>
			<cfset length = 78>
			<cfset height = 27>
		<cfelse>
			<cfset width = 0>
			<cfset length = 0>
			<cfset height = 0>
		</cfif>

		<p>
			IMPORTANT
			<ul>
				<li>
					Position size controls content size. These values must be set appropriately before proceeding. File an Issue
					to expand the defaults (eg, if all dimensions are 0 below).
				</li>
				<li>
					Containers with postions may be edited in very limited ways. Proceed with caution.
				</li>
				<li>
					Positions may not be edited. Proceed with caution.
				</li>
			</ul>
		</p>
		Container Summary
		<table border>
			<tr>
				<th>Column</th>
				<th>Value</th>
			</tr>
			<cfloop list="#abox.columnlist#" index="i">
				<tr>
					<td>#i#</td>
					<td>#evaluate("aBox." & i)#</td>
				</tr>
			</cfloop>
		</table>


		<form name="allnewPos" method="post" action="containerPositions.cfm">
			<input type="hidden" name="action" value="allNewPositions">
			<input type="hidden" name="container_type" value="#aBox.container_type#">
			<input type="hidden" name="container_id" value="#aBox.container_id#">

			<input type="hidden" name="NUMBER_ROWS" value="#aBox.NUMBER_ROWS#">
			<input type="hidden" name="NUMBER_COLUMNS" value="#aBox.NUMBER_COLUMNS#">
			<input type="hidden" name="ORIENTATION" value="#aBox.ORIENTATION#">
			<input type="hidden" name="POSITIONS_HOLD_CONTAINER_TYPE" value="#aBox.POSITIONS_HOLD_CONTAINER_TYPE#">
			<input type="hidden" name="institution_acronym" value="#aBox.institution_acronym#">
			<label for="width">New Position Width</label>
			<input type="text" name="width" value="#width#">
			<label for="length">New Position Length</label>
			<input type="text" name="length" value="#length#">
			<label for="height">New Position Height</label>
			<input type="text" name="height" value="#height#">
			<br><input type="submit" value="Create all new positions" class="insBtn">
		</form>
		<cfabort>
	</cfif>
	<!--- there's something in the box - what? ---->
	<cfquery name="uContentType" dbtype="query">
		select container_type from whatPosAreUsed
		group by container_type
	</cfquery>
	<cfif uContentType.recordcount is not 1 or uContentType.container_type is not 'position'>
		<div class="error">
			This container holds non-positions; this form cannot be used.
			<ul>
				<cfloop query="uContentType">
					<li>#container_type#</li>
				</cfloop>
			</ul>
		</div>
		<cfabort>
	</cfif>

	<!----it's all positions ---->
	<cfset npos=aBox.NUMBER_ROWS * aBox.NUMBER_COLUMNS>
	<cfif whatPosAreUsed.recordcount is not npos>
		<div class="error">
			This container holds #whatPosAreUsed.recordcount# but is marked to hold #npos#.
		</div>
		<cfabort>
	</cfif>
	<cfloop query="whatPosAreUsed">
		<cfif not isnumeric(label)>
			<div class="error">
				Some position labels aren't numeric
			</div>
			<cfabort>
		</cfif>
	</cfloop>
	<!---- made it through the checks, now actually do stuff --->
	<cfquery name="positionContents" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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

	<p style="font-weight: bold;">
		This parent container is:
		<br>Label: <strong>#abox.label#</strong>
		<br>Barcode:
		<strong>#aBox.barcode#</strong>
		<br> Type:
		<strong>#aBox.container_type#</strong>
		<br><a href="EditContainer.cfm?container_id=#abox.container_id#">Edit</a>
		<br><a href="findContainer.cfm?container_id=#abox.container_id#">Tree View</a>
	</p>

	<p>
		Use this form to:
		<ul>
			<li>Scan cryovials into freezer boxes</li>
			<li>Turn cryovial labels into cryovials while scanning them into freezer boxes</li>
			<li>Turn slide labels into slides while scanning them into slide boxes</li>
			<li>Scan slides into slide boxes</li>
		</ul>
	</p>
	<p>
		Save happens when you tab out of a cell. You can set your scanner to send a tab after data. Make sure you deal with anything
		that turns red.
	</p>
	<p>
		<label for="cfs">Table Font Size</label>
		<select id="tfs" onchange="changeTableFont(this.value);">
			<option value="xsmallFont">xsmallFont</option>
			<option value="smallFont">smallFont</option>
			<option selected="selected" value="mediumFont">mediumFont</option>
			<option value="largeFont">largeFont</option>
			<option value="xlargeFont">xlargeFont</option>
			<option value="xxlargeFont">xxlargeFont</option>
		</select>
	</p>
	<form name="newScans" method="post" action="containerPositions.cfm" onsubmit="return false;">
		<input type="hidden" name="action" value="moveScans">
		<input type="hidden" name="container_id" id="container_id" value="#aBox.container_id#">
		<input type="hidden" name="acceptableChildContainerType" id="acceptableChildContainerType" value="#acceptableChildContainerType#">
		<cfset thisCellNumber=1>
		<table id="grid_table" cellpadding="0" cellspacing="0" border="1">
			<cfloop from="1" to="#numberRows#" index="currentrow">
				<tr>
					<cfloop from="1" to="#numberColumns#" index="currentcolumn">
						<td>
							<!--- now, we can get the contents of this cell
									First, get the container_id for this label from a
									cached query, then get the contents from the DB

									need to make adjustments for verticality first
							---->
							<cfif taborder is "vertical">
								<cfset thisTabIndex=((currentcolumn -1) *  numberRows) + currentrow>
							<cfelse>
								<cfset thisTabIndex=thisCellNumber>
							</cfif>
							<cfquery name="thisPos" dbtype="query">
								select container_id, position_id,contentLabel,posConBc from positionContents
								where label = '#thisTabIndex#'
							</cfquery>

							<div class="ccellDiv">
								<span class="labelSpan">
									#thisTabIndex#
								</span>
								<span class="innerSpan" id="theSpan#thisTabIndex#">
									<cfif len(thisPos.container_id) gt 0>
										<br>#thisPos.contentLabel#
										<br>#thisPos.posConBc#
									<cfelse>
										Barcode:<br>
										<input type="hidden"
											name="position_id#thisTabIndex#"
											id="position_id#thisTabIndex#"
											value="#thisPos.position_id#">
										<input type="text"
											onFocus="this.className='activeCell'"
											onChange="moveContainer('barcode#thisTabIndex#',this.value)"
											name="barcode#thisTabIndex#"
											id="barcode#thisTabIndex#"
											size="6"
											style="font-size:small;"
											tabindex="#thisTabIndex#">
									</cfif>
								</span>
							</div>
							<cfset thisCellNumber=thisCellNumber+1>
						</td>
					</cfloop>
				</tr>
			</cfloop>
		</table>
	</form>
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------>
<cfif #action# is "allNewPositions">
	<cfoutput>

		<cfquery name="isThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select count(*) c from container where parent_container_id=#container_id#
		</cfquery>
		<cfif isThere.c gt 0>
			<div class="error">
				There are already #isThere.recordcount# containers in this container. Aborting....
			</div>
			<cfabort>
		</cfif>
		<!--- there is nothing in this box, make all positions ---->
		<cftransaction>


		<cfset number_positions=NUMBER_ROWS * NUMBER_COLUMNS>

			<!--- make number_positions new containers, lock them, and put them in this box ---->
			<cfloop from="1" to="#number_positions#" index="i">
				<cfstoredproc procedure="createContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					<cfprocparam cfsqltype="cf_sql_varchar" value="position"><!--- v_container_type ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#i#"><!---- v_label --->
					<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_description ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_container_remarks ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_barcode ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#width#"><!---- v_width ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#height#"><!---- v_height ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#length#"><!---- v_length ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_number_rows ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_number_columns ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_orientation ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_posn_hld_ctr_typ ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#institution_acronym#"><!---- v_institution_acronym ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#container_id#"><!---- v_parent_container_id ---->
				</cfstoredproc>
			</cfloop>
		</cftransaction>
		<cflocation url="containerPositions.cfm?container_id=#container_id#" addtoken="false">
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">