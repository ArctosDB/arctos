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
</script>

<cfif action is "nothing">
<cfoutput>
	<cfset title = 'scan items into positions in containers'>
	<cfquery name="aBox" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from container where container_id=#container_id#
	</cfquery>
	<!--- default is....---->
	<cfset taborder="horizontal">
	<!---- figure out what they're trying to do and set some variables ---->
	<cfif aBox.number_positions is 100 AND aBox.container_type is "freezer box">
		<cfset acceptableChildContainerType="cryovial">
		<cfset goodPositionType = "position">
		<cfset numberRows = 10>
		<cfset numberColumns = 10>
	<cfelseif aBox.number_positions is 81 AND aBox.container_type is "freezer box">
		<cfset acceptableChildContainerType="cryovial">
		<cfset goodPositionType = "position">
		<cfset numberRows = 9>
		<cfset numberColumns = 9>
	<cfelseif aBox.number_positions is 25 AND aBox.container_type is "freezer box">
		<cfset acceptableChildContainerType="cryovial">
		<cfset goodPositionType = "position">
		<cfset numberRows = 5>
		<cfset numberColumns = 5>
	<cfelseif aBox.number_positions is 169 AND aBox.container_type is "freezer box">
		<cfset acceptableChildContainerType="cryovial">
		<cfset goodPositionType = "position">
		<cfset numberRows = 13>
		<cfset numberColumns = 13>
	<cfelseif aBox.number_positions is 48 AND aBox.container_type is "freezer">
		<cfset acceptableChildContainerType="freezer rack">
		<cfset goodPositionType = "position">
		<cfset numberRows = 12>
		<cfset numberColumns = 4>
	<cfelseif aBox.number_positions is 33 AND aBox.container_type is "freezer">
		<cfset acceptableChildContainerType="freezer rack">
		<cfset goodPositionType = "position">
		<cfset numberRows = 11>
		<cfset numberColumns = 3>
	<cfelseif aBox.number_positions is 100 AND aBox.container_type is "slide box">
		<cfset acceptableChildContainerType="slide">
		<cfset goodPositionType = "position">
		<cfset numberRows = 50>
		<cfset numberColumns = 2>
		<cfset taborder="vertical">
	<cfelse>
		<!--- this form can do nothing useful ---->
		<div class="error">
			This application won't do what you want to do.

			<p>
				You must have a container with positons. (Edit Container, set number of positions.)
			</p>
			What this form will scan into or create positions for:


			<ul>
				<li>freezer box - 100 positions - 10 rows, 10 columns, holds <strong>cryovial</strong></li>
				<li>freezer box - 81 positions - 9 rows, 9 columns, holds <strong>cryovial</strong></li>
				<li>freezer box - 25 positions - 5 rows, 5 columns, holds <strong>cryovial</strong></li>
				<li>freezer box - 169 positions - 13 rows, 13 columns, holds <strong>cryovial</strong></li>
				<li>freezer - 48 positions - 12 rows, 4 columns, holds <strong>freezer rack</strong></li>
				<li>freezer - 33 positions - 11 rows, 3 columns, holds <strong>freezer rack</strong></li>
				<li>slide box - 100 positions - 50 rows, 2 columns, holds <strong>slide</strong></li>
			</ul>


			<p>
			If you have that and you're still getting this error, <a href="/contact.cfm">contact us</a>.
			</p>
		</div>
		<cfabort>
	</cfif>
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

		<form name="allnewPos" method="post" action="containerPositions.cfm">
			<input type="hidden" name="action" value="allNewPositions">
			<input type="hidden" name="container_type" value="#aBox.container_type#">
			<input type="hidden" name="container_id" value="#aBox.container_id#">
			<input type="hidden" name="number_positions" value="#aBox.number_positions#">
			<input type="hidden" name="institution_acronym" value="#aBox.institution_acronym#">
			<input type="submit" value="Create all new positions" class="insBtn">
		</form>
		<cfabort>
	</cfif>
	<!--- there's something in the box - what? ---->
	<cfquery name="uContentType" dbtype="query">
		select container_type from whatPosAreUsed
		group by container_type
	</cfquery>
	<cfif uContentType.recordcount is not 1 or uContentType.container_type is not goodPositionType>
		<div class="error">
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
		</div>
		<cfabort>
	</cfif>
	<!----it's all positions ---->
	<cfif whatPosAreUsed.recordcount is not aBox.number_positions>
		<div class="error">
			There is a problem with the positions in this box. Aborting....
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
	<form name="newScans" method="post" action="containerPositions.cfm" onsubmit="return false;">
		<input type="hidden" name="action" value="moveScans">
		<input type="hidden" name="number_positions" value="#aBox.number_positions#">
		<input type="hidden" name="container_id" id="container_id" value="#aBox.container_id#">
		<input type="hidden" name="acceptableChildContainerType" id="acceptableChildContainerType" value="#acceptableChildContainerType#">
		<cfset thisCellNumber=1>
		<table cellpadding="0" cellspacing="0" border="1">
			<cfloop from="1" to="#numberRows#" index="currentrow">
				<tr>
					<cfloop from="1" to="#numberColumns#" index="currentcolumn">
						<td>
							<!--- now, we can get the contents of this cell
									First, get the container_id for this label from a
									cached query, then get the contents from the DB
							---->

							<cfif taborder is "vertical">
								<cfset thisTabIndex=((currentcolumn -1) *  numberRows) + currentrow>

								<br>currentcolumn: #currentcolumn#
								<br>numberRows: #numberRows#
								<br>currentrow: #currentrow#
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
								thisCellNumber: #thisCellNumber#
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
		<cfelseif #number_positions# is 25 AND #container_type# is "freezer box">
			<cfset position_label = "position">
			<cfset width = 1.2>
			<cfset length = 1.2>
			<cfset height = 4.9>
		<cfelseif #number_positions# is 81 AND #container_type# is "freezer box">
			<cfset position_label = "position">
			<cfset width = 1.2>
			<cfset length = 1.2>
			<cfset height = 4.9>
		<cfelseif number_positions is 169 AND container_type is "freezer box">
			<cfset position_label = "position">
			<cfset width = 1.2>
			<cfset length = 1.2>
			<cfset height = 4.9>
		<cfelseif #number_positions# is 100 AND #container_type# is "slide box">
			<cfset position_label = "position">
			<cfset width = 3>
			<cfset length = 78>
			<cfset height = 27>
		<cfelse>
			<hr><font color="##FF0000">I can't deal with #number_positions# positions in a #container_type#!</font>
			<cfabort>
		</cfif>
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
			<!--- make number_positions new containers, lock them, and put them in this box ---->
			<cfloop from="1" to="#number_positions#" index="i">
				<cfstoredproc procedure="createContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					<cfprocparam cfsqltype="cf_sql_varchar" value="#position_label#"><!--- v_container_type ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#i#"><!---- v_label --->
					<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_description ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_container_remarks ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value=""><!---- v_barcode ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#width#"><!---- v_width ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#height#"><!---- v_height ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#length#"><!---- v_length ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="1"><!---- v_number_positions ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#institution_acronym#"><!---- v_institution_acronym ---->
					<cfprocparam cfsqltype="cf_sql_varchar" value="#container_id#"><!---- v_parent_container_id ---->
				</cfstoredproc>
			</cfloop>
		</cftransaction>
		<cflocation url="containerPositions.cfm?container_id=#container_id#" addtoken="false">
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">