<cfinclude template="includes/_header.cfm">
<cfset title='Edit Container'>
<!-----------
/*
			<select name="parameter_type" id="parameter_type" size="1" required class="reqdClr">
					<option value="">pick one</option>
					<cfloop query="ctcontainer_env_parameter">
						<option value="#parameter_type#">#parameter_type#</option>
					</cfloop>
				</select>
			</td>
			<td><input type="number" name="parameter_value" id="parameter_value"></td>
			<td><textarea class="mediumtextarea" name="remark" id="remark"></textarea></td>
			<td><input type="submit" value="save"></td>

			*/

------------>
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		$("#check_date").datepicker();
		$("#parameter_type").change(function() {
			console.log($( this ).val());
			if ($(this).val()=='checked'){
				$("#parameter_value").val('1').attr({
					"max" : 1,
					"min" : 1
 				});
			} else if ($(this).val()=='ethanol concentration' || $(this).val()=='isopropanol concentration'){
				$("#parameter_value").attr({
					"max" : 1,
					"min" : 0,
					"step" : 0.01
 				});
			} else if ($(this).val()=='relative humidity (%)'){
				$("#parameter_value").attr({
					"max" : 100,
					"min" : 0,
					"step" : 0.01
 				});
			} else {
				$("#parameter_value").attr({
					"step" : "any"
 				});
 				$("#parameter_value").removeAttr("min");
 				$("#parameter_value").removeAttr("max");
			}
		});
		getContainerHistory($("#container_id").val());
	});
	function getContainerHistory(cid,exclagnt,pg,feh_ptype){
		var ptl='/component/container.cfc?method=getEnvironment&container_id=' + cid;
		if (typeof exclagnt === "undefined") {
			exclagnt='';
		}
		if (typeof pg === "undefined") {
					pg='1';
		}
		if (typeof feh_ptype === "undefined") {
					feh_ptype='';
		}
		ptl+='&exclagnt=' + exclagnt;
		ptl+='&pg=' + pg;
		ptl+='&feh_ptype=' + feh_ptype;
	    jQuery.get(ptl, function(data){
			jQuery("#cehisttgt").html(data);
		});
	}

	function magicNumbers (type) {
		var type;
		var h=document.getElementById('height');
		var d=document.getElementById('length');
		var w=document.getElementById('width');
		var p=document.getElementById('number_positions');

		var isH=h.value.length;
		var isD=d.value.length;
		var isW=w.value.length;
		var isP=p.value.length;
		if (type == 'freezer box') {
			if (isH == 0) {
				h.value='5';
			}
			if (isD == 0) {
				d.value='13';
			}
			if (isW == 0) {
				w.value='13';
			}
			if (isP == 0) {
				p.value='100';
			}
		}
	}
	function isThisAPosition(){
		var parBcEl = document.getElementById('new_parent_barcode');
		var nPosEl = document.getElementById('number_positions');
		var contTypeEl = document.getElementById('container_type');
		var ct = contTypeEl.value;
		if (ct == 'position') {
			parBcEl.className = 'reqdClr';
			nPosEl.className = 'readClr';
			nPosEl.value = '0';
			nPosEl.readOnly=true;
		} else {
			parBcEl.className = '';
			nPosEl.className = '';
			//nPosEl.value = '';
			nPosEl.readOnly=false;
		}
	}
	function quickCheck(){
		$("#parameter_type").val('checked');
		$("#parameter_value").val('1');
		$("#envcheck").submit();
	}
</script>

<!---------------------------------------------------------------->
<cfif action is "saveEnvCheck">
	<cfquery name="ec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into container_environment (
			container_id,
			parameter_type,
			parameter_value,
			remark
		) values (
			#container_id#,
			'#parameter_type#',
			'#parameter_value#',
			'#escapeQuotes(remark)#'
		)
	</cfquery>
	<cflocation url="EditContainer.cfm?container_id=#container_id#" addtoken="false">
</cfif>
<!---------------------------------------------------------------->
<cfif action is "nothing">
	<cfset title="Edit Container">
	<cfquery name="getCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT
			container.container_id as container_id,
			container.parent_container_id as parent_container_id,
			container_type,
			label,
			description,
			container_remarks,
			barcode,
			parent_install_date,
			width,
			length,
			height,
			number_positions,
			locked_position,
			institution_acronym
		FROM
			container
		WHERE
			container.container_id = #container_id#
	</cfquery>
	<cfquery name="ctInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select distinct(institution_acronym) institution_acronym from collection order by institution_acronym
	</cfquery>
	<cfquery name="ContType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select container_type from ctcontainer_type where container_type != 'collection object' order by container_type
	</cfquery>
	<cfquery name="ctcontainer_env_parameter" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select parameter_type from ctcontainer_env_parameter ORDER BY parameter_type
	</cfquery>
	<cfoutput>
	<h2>Edit Container</h2>
	<a href="/findContainer.cfm?container_id=#container_id#">view in tree</a>
	<table><tr><td valign="top"><!---- left column ---->


	<cfif len(getCont.barcode) is 0 and  (session.username is "dlm" or session.username is "campmlc")>
						<div class="importantNotification">

			<form name="formDangerousBarcodeThingee" method="post" action="EditContainer.cfm">
				<input type="hidden" name="container_id" id="container_id" value="#getCont.container_id#">
				<input type="hidden" name="action" value="DGR_add_barcode">
					DO NOT USE THIS UNLESS YOU KNOW WHAT YOU'RE DOING!!
					<br>enter the barcode of a "donor" container.
					<br>That container will be DELETED and the barcode will be assigned to this container.
					<br>maybe we should only do this for % label container types??

				<label for="donorBarcode">Donor Barcode</label>
				<input type="text" name="donorBarcode">
				<input type="submit" value="merge containers">
								</div>
			</form>

	</cfif>


	<form name="form1" method="post" action="EditContainer.cfm">
		<input type="hidden" name="container_id" id="container_id" value="#getCont.container_id#">
		<table cellpadding="0" cellspacing="0">
	 		<tr>
				<td>
					<label for="label">Label</label>
					<input name="label" id="label" type="text" value="#getCont.label#" size="30" class="reqdClr">
				</td>
				<td>
					<label for="barcode">Barcode</label>
					<input name="barcode" type="text" value="#getCont.barcode#" id="barcode">
				</td>
			</tr>

			<tr>
				<td>
					 <label for="container_type">Container Type</label>
					 <cfif getCont.container_type is not "collection object">
						 <select name="container_type" id="container_type" size="1" class="reqdClr" onChange="magicNumbers(this.value);">
					          <cfloop query="ContType">
		            			<option
									<cfif getCont.Container_Type is ContType.container_type> selected="selected" </cfif>
									value="#ContType.container_type#">#ContType.container_type#</option>
		         			 </cfloop>
						</select>
					<cfelse>
						<cfquery name="findItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							select
								guid,
								part_name
							FROM
								coll_obj_cont_hist,
								specimen_part,
								flat
							WHERE
								coll_obj_cont_hist.collection_object_id = specimen_part.collection_object_id AND
								specimen_part.derived_from_cat_item = flat.collection_object_id AND
								coll_obj_cont_hist.container_id = #container_id#
						</cfquery>
						<input type="text" name="container_type" id="container_type" value="collection object" readonly="yes" />
						<cfif findItem.recordcount is 1>
							<a href="/guid/#findItem.guid#" target="_blank">
								#findItem.guid# (#findItem.part_name#)</a>
						<cfelse>
							Something is goofy - this containers matches #findItem.recordcount# items. File a bug report.
							<br />#findItem.guid#
						</cfif>
					</cfif>
				</td>
				<td>
					 <label for="institution_acronym">Institution</label>
					 <select name="institution_acronym" id="institution_acronym" size="1" class="reqdClr">
				          <cfloop query="ctInst">
	            				<option
	            					<cfif getCont.institution_acronym is ctInst.institution_acronym> selected="selected" </cfif>
	            					value="#institution_acronym#">#institution_acronym#</option>
	         			 </cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td>
					<label for="parent_install_date">Last Moved Date</label>
					<div id="parent_install_date">#Dateformat(getCont.parent_install_date, "yyyy-mm-dd")#</div>
				</td>
				<td>
					<label for="locked_position">Locked?</label>
						<select name="locked_position" id="locked_position" size="1">
							<option <cfif getCont.locked_position is 0> selected </cfif>value="0">no</option>
							<option <cfif getCont.locked_position is 1> selected </cfif>value="1">yes</option>
						</select>
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<label for="dimTbl">Dimensions</label>
					<table cellspacing="0" cellpadding="0" width="100%" id="dimTbl">
						<tr>
							<td>
								<label for="width">Width (cm)</label>
								<input type="text" id="width" name="width" value="#getCont.width#" size="4">
							</td>
							<td>
								<label for="height">Height (cm)</label>
								<input type="text" id="height" name="height" value="#getCont.height#" size="4">
							</td>
							<td>
								<label for="length">Length (cm)</label>
								<input type="text" id="length" name="length" value="#getCont.length#" size="4">
							</td>
							<td>
								<label for="number_positions">## Positions</label>
								<input type="text" name="number_positions" value="#getCont.number_positions#" size="2" id="number_positions">
							</td>
						</tr>
					</table>
				</td>
			</tr>
	  		<tr>
				<td colspan="2">
					<label for="description">Description</label>
					<textarea rows="2" cols="60" name="description" id="description">#getCont.Description#</textarea>
				</td>
			</tr>
	 		<tr>
				<td colspan="2">
					<label for="container_remarks">Remarks?</label>
					<textarea rows="2" cols="60" id="container_remarks" name="container_remarks">#getCont.container_remarks#</textarea>
				</td>
			</tr>

			<tr>
				<td colspan="2">
					<table cellpadding="0" cellspacing="0" width="100%">
						<tr>
							<td>
								<input type="button"
									value="Print"
									class="lnkBtn"
									onclick="window.open('Reports/report_printer.cfm?container_id=#getCont.container_id#');">
							</td>
							<td>
								<input type="button"
									value="Update"
									class="savBtn"
									onclick="form1.action.value='update';submit();">
							</td>
							<td>
								<input type="button"
									value="Delete"
									class="delBtn"
									onclick="form1.action.value='delete';confirmDelete('form1');" >
							</td>
							<td>
								<input type="button"
									value="Clone"
									class="insBtn"
									onclick="form1.action.value='newContainer';submit();">
							</td>
							<td>
								<cfif getCont.parent_container_id gt 0>
									<input type="button"
										value="Edit Parent"
										class="lnkBtn"
										onclick="document.location='EditContainer.cfm?container_id=#getCont.parent_container_id#';">
								</cfif>
							</td>
							<td>
								<label for="newParentBarcode">Move To Barcode</label>
								<input type="hidden" name="parent_container_id" id="parent_container_id" value="#getCont.parent_container_id#">
								<input type="text" name="newParentBarcode" id="newParentBarcode" />
							</td>
						</tr>
					</table>
					<input type="hidden" name="action" value="update">
				</td>
			</tr>
	</table>
</form>
<h2>Container Environment</h2>

<h3>Create Environment Record</h3>
<form name="envcheck" id="envcheck" method="post" action="EditContainer.cfm">
	<input type="hidden" name="action" value="saveEnvCheck">
	<input type="hidden" name="container_id" value="#getCont.container_id#">
	<table border>
		<tr>
			<th>
				Parameter
				<span class="infoLink" onclick="getCtDoc('CTCONTAINER_ENV_PARAMETER');">Define</span>
			</th>
			<th>Value</th>
			<th>Remark</th>
			<th></th>
		</tr>
		<tr>
			<td>
				<select name="parameter_type" id="parameter_type" size="1" required class="reqdClr">
					<option value="">pick one</option>
					<cfloop query="ctcontainer_env_parameter">
						<option value="#parameter_type#">#parameter_type#</option>
					</cfloop>
				</select>
			</td>
			<td><input type="number" name="parameter_value" id="parameter_value"></td>
			<td><textarea class="mediumtextarea" name="remark" id="remark"></textarea></td>
			<td><input type="submit" class="insBtn" value="save"></td>
		</tr>
	</table>
</form>
<input type="button" onclick="quickCheck()" class="insBtn" value="quick-insert container check">
<h3>History</h3>
<div id="cehisttgt"></div>
</td>
<td valign="top"><!---- right column ---->
	<cfquery name="children" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			container_id,
			barcode,
			container_type,
			label
		from
			container
		where
			parent_container_id=#container_id#
		order by
			container_type,barcode,label
	</cfquery>
	<h3>Contents</h3>
	<form name="moveChillun" method="post" action="EditContainer.cfm">
		<input type="hidden" name="action" value="moveChillun">
		<input type="hidden" name="container_id" value="#getCont.container_id#">
		<label for="newParentBarcode">Move all children of this container to barcode:</label>
		<input type="text" name="newParentBarcode" id="newParentBarcode" class="reqdClr">
		<br><input type="submit" value="Move all children of this container to scanned barcode" class="savBtn">
	</form>
	<p></p>
	<label for ="ctabl">Children of this container</label>
	<table border>
		<tr>
			<th>Barcode</th>
			<th>Label</th>
			<th>Container Type</th>
			<th>Tools</th>
		</tr>
		<cfloop query="children">
			<tr>
				<td>#barcode#</td>
				<td>#label#</td>
				<td>#container_type#</td>
				<td>
					<a href="/EditContainer.cfm?container_id=#container_id#">[ edit ]</a>
					<a href="/findContainer.cfm?container_id=#container_id#">[ find ]</a>
				</td>
			</tr>
		</cfloop>
	</table>
</td>
</tr></table>
</cfoutput>
</cfif>


<!-------------------------------------------------------------->


<cfif action is "DGR_add_barcode">
	<cfoutput>
		<cfquery name="dc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from container where barcode='#donorBarcode#'
		</cfquery>
		<cfif dc.recordcount is not 1>
			donor notfound<cfabort>
		</cfif>
		<cfquery name="dcc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from container where parent_container_id=#dc.container_id#
		</cfquery>
		<cfif ddc.recordcount is not 1>
			donor has children<cfabort>
		</cfif>

		<cftransaction>
			<cfquery name="ddnr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from container where container_id=#dc.container_id#
			</cfquery>
			<cfquery name="abc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update container set barcode='#donorBarcode#' where  container_id=#container_id#
			</cfquery>

		</cftransaction>

		<cflocation url="EditContainer.cfm?container_id=#container_id#" addtoken="false">

	</cfoutput>
</cfif>




<!-------------------------------------------------------------->


<cfif action is "update">
	<cfoutput>
		<cfif len(newParentBarcode) gt 0>
			<cfquery name="isGoodParent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select container_id from  container where
				barcode = '#newParentBarcode#'
			</cfquery>
			<cfset parent_container_id=isGoodParent.container_id>
		</cfif>
		<cftransaction>
			<cfstoredproc procedure="updateContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				<cfprocparam cfsqltype="cf_sql_varchar" value="#container_id#"><!---- v_container_id ---->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#parent_container_id#"><!---- v_parent_container_id ---->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#container_type#"><!---- v_container_type ---->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#label#"><!---- v_label ---->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#escapeQuotes(description)#"><!---- v_description ---->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#escapeQuotes(container_remarks)#"><!---- v_container_remarks ---->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#barcode#"><!---- v_barcode ---->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#width#"><!---- v_width ---->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#height#"><!---- v_height ---->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#length#"><!---- v_length ---->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#number_positions#"><!---- v_number_positions ---->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#locked_position#"><!---- v_locked_position ---->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#institution_acronym#"><!---- v_institution_acronym ---->
			</cfstoredproc>
		</cftransaction>
		<cflocation url="EditContainer.cfm?container_id=#container_id#" addtoken="false">
	</cfoutput>
</cfif>
<!-------------------------------------------------------------->
<cfif action is "moveChillun">
	<cfoutput>
		<cfquery name="cidOfnewParentBarcode" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select container_id from container where barcode='#newParentBarcode#'
		</cfquery>
		<cfstoredproc procedure="updateAllChildrenContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			<cfprocparam cfsqltype="CF_SQL_FLOAT" value="#cidOfnewParentBarcode.container_id#"><!---- v_new_parent_container_id --->
			<cfprocparam cfsqltype="CF_SQL_FLOAT" value="#container_id#"><!--- v_current_parent_container_id ---->
		</cfstoredproc>
		<p>
			Children moved to barcode #newParentBarcode#.
		</p>
		<ul>
			<li><a href="/EditContainer.cfm?container_id=#container_id#">continue editing</a></li>
			<li><a href="/EditContainer.cfm?container_id=#cidOfnewParentBarcode.container_id#">edit the new parent</a></li>
		</ul>
	</cfoutput>
</cfif>
<!-------------------------------------------------------------->
<cfif Action is "delete">
	<cfstoredproc procedure="deleteContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		<cfprocparam cfsqltype="cf_sql_number" value="#container_id#"><!---- v_container_id --->
	</cfstoredproc>
	<div align="center"><font color="#0066FF" size="+6">You've deleted the container!</font> </div>
</cfif>
<!----------------------------->

<cfif action is "CreateNew">

	<cfoutput>
		<cftransaction>
			<cfstoredproc procedure="createContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				<cfprocparam cfsqltype="cf_sql_varchar" value="#container_type#"><!---- v_container_type --->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#label#"><!---- v_label --->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#description#"><!---- v_description --->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#escapeQuotes(container_remarks)#"><!---- v_container_remarks --->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#barcode#"><!---- v_barcode --->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#width#"><!---- v_width --->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#height#"><!---- v_height --->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#length#"><!---- v_length --->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#number_positions#"><!---- v_number_positions --->
				<cfprocparam cfsqltype="cf_sql_varchar" value="#institution_acronym#"><!---- v_institution_acronym --->
				<cfprocparam cfsqltype="cf_sql_varchar" value="0"><!---- v_parent_container_id --->
			</cfstoredproc>
			<cfquery name="nextContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				SELECT sq_container_id.currval newid FROM dual
			</cfquery>
		</cftransaction>
		<cflocation url="EditContainer.cfm?action=nothing&container_id=#nextContainer.newid#" addtoken="false">
	</cfoutput>
</cfif>
<!---------------------------------------------->
<cfif action is "newContainer">
	<cfset title="Create Container">
	<cfparam name="ctype" default="">
	<cfparam name="width" default="">
	<cfparam name="height" default="">
	<cfparam name="length" default="">
	<cfparam name="number_positions" default="">
	<cfparam name="description" default="">
	<cfparam name="barcode" default="">
	<cfparam name="label" default="">
	<cfparam name="checked_date" default="">
	<cfparam name="container_remarks" default="">
	<cfif isdefined("container_type")>
		<cfset ctype=container_type>
	</cfif>

	<cfoutput>
		<cfquery name="ctInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select distinct(institution_acronym) institution_acronym from collection order by institution_acronym
		</cfquery>
		<cfquery name="ContType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select container_type from ctcontainer_type order by container_type
		</cfquery>

		<h2>Create Container</h2>
		<div style="margin:2em; padding:2em; border:5px solid red;font-size: xx-large;font-weight: bold; text-align: center;">
			<p>
				You probably should not be here.
			</p>
			<p>
				A lot of problems start here.
			</p>
			<p>
				Containers should be created as batches.
			</p>
			<p>
				Proceed only with great caution.
			</p>
			<p>
				Create only barcodes claimed in the barcode spreadsheet.
			</p>
		</div>
		<form name="form1" method="post" action="EditContainer.cfm">
			<input type="hidden" name="action" value="CreateNew" />
			<label for="container_type">Container Type</label>
			<select name="Container_Type" size="1" id="container_type" class="reqdClr" onchange="isThisAPosition();">
				<option value=""></option>
				<cfloop query="ContType">
					 <cfif ContType.container_type is not "collection object">
			            <option <cfif ctype is ContType.container_type> selected="selected" </cfif>value="#ContType.container_type#">#ContType.container_type#</option>
					</cfif>
          		</cfloop>
			</select>
			<!---
			<label for="new_parent_barcode">Parent Barcode</label>
			<input type="text" name="new_parent_barcode" id="new_parent_barcode" value="" />
			---->
			<label for="dTab">Dimensions</label>
			<table border>
				<tr>
					<th>W</th>
					<th>H</th>
					<th>L</th>
				</tr>
				<tr>
					<td><input name="width" type="text" value="#width#" size="6"></td>
					<td><input name="height" type="text" value="#height#" size="6"></td>
					<td><input name="length" type="text" value="#length#" size="6"></td>
				</tr>
			</table>
			<label for="number_positions">Number of Positions</label>
			<input name="number_positions" id="number_positions" type="text" value="#number_positions#">
			<label for="description">Description</label>
			<input name="description" type="text" value="#description#">
			<label for="institution_acronym">Institution</label>
			<select name="institution_acronym" id="institution_acronym" size="1" class="reqdClr">
				<option value=""></option>
				<cfloop query="ctInst">
	            	<option value="#institution_acronym#">#institution_acronym#</option>
	         	</cfloop>
			</select>
			<label for="barcode">Barcode</label>
			<input name="barcode" type="text" value="#barcode#">
			<label for="label">Label</label>
			<input name="label" type="text" value="#label#" class="reqdClr">
			<label for="container_remarks">Remarks</label>
			<input name="container_remarks" type="text" value="#container_remarks#">

			<br><input type="submit" value="Create Container" class="insBtn">
		</form>
		<script>
			isThisAPosition();
		</script>
	</cfoutput>
</cfif>
<!---------------------------------------------------->
<cfinclude template="/includes/_footer.cfm">
