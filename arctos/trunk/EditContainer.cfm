<cfinclude template="includes/_header.cfm">
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		$("#parent_install_date").datepicker();
		$("#checked_date").datepicker();
		$("#check_date").datepicker();
	});
	function toggleFluid(oo){
		if (oo==1){
			$("#fluidDiv").show();
			$("#fluidCtl").html('<span class="likeLink" onclick="toggleFluid(0)">Is Not Fluid</span>');
		} else {
			$("#fluidDiv").hide();
			$("#fluidCtl").html('<span class="likeLink" onclick="toggleFluid(1)">Is Fluid</span>');
			$("#checked_date").val('');
			$("#fluid_type").val('');
			$("#concentration").val('');
			$("#fluid_remarks").val('');
		}
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
</script>
<cfif action is "update">
	<cfif len(newParentBarcode) gt 0>
		<cfquery name="isGoodParent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select container_id from  container where 
			barcode = '#newParentBarcode#'
		</cfquery>
		<cfif isGoodParent.recordcount is 1>
			<cfset newParentId = isGoodParent.container_id>
		<cfelse>
			<cfoutput>
				A container with barcode #newParentBarcode# was not found!
			</cfoutput>
			<cfabort>
		</cfif>
	</cfif>
	<cfoutput>
		<cftransaction>
			<cfset sql="UPDATE container SET 
				container_type = '#container_type#',
				description = '#escapeQuotes(description)#',
				barcode = '#barcode#',
				institution_acronym = '#institution_acronym#',
				label = '#label#',
				parent_install_date = '#parent_install_date#',
				container_remarks = '#escapeQuotes(container_remarks)#',
				locked_position = #locked_position#">
			<cfif len(newParentBarcode) gt 0>
				<cfset sql=sql & ",parent_container_id = #newParentId#">
			</cfif>
			<cfif len(width) gt 0>
				<cfset sql=sql & ",width = #width#">
			<cfelse>
				<cfset sql=sql & ",width = NULL">
			</cfif>
			<cfif len(height) gt 0>
				<cfset sql=sql & ",height = #height#">
			<cfelse>
				<cfset sql=sql & ",height = NULL">
			</cfif>
			<cfif len(length) gt 0>
				<cfset sql=sql & ",length = #length#">
			<cfelse>
				<cfset sql=sql & ",length = NULL">
			</cfif>
			<cfif len(number_positions) gt 0>
				<cfset sql=sql & ",number_positions = #number_positions#">
			<cfelse>
				<cfset sql=sql & ",number_positions = NULL">
			</cfif>
			<cfset sql=sql & " WHERE container_id = #container_id#">
			<cfquery name="updateContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				#preservesinglequotes(sql)#
			</cfquery>
			<cfquery name="isFluid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				SELECT * FROM fluid_container_history WHERE container_id = #container_id#
			</cfquery>	
			<cfif isFluid.recordcount gt 0 AND len(isFluid.container_id) gt 0>
				<cfquery name="updateFluidContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					UPDATE 
						Fluid_Container_History 
					SET 
						Checked_Date = '#dateformat(Checked_Date,'yyyy-mm-dd')#',
						Fluid_Type = '#Fluid_Type#',
						Concentration = #Concentration#,
						Fluid_Remarks = '#Fluid_Remarks#'
					WHERE 
						container_id = #container_id#
				</cfquery>
			<cfelse>
				<cfif len(checked_date) GT 0 OR len(fluid_type) GT 0 OR len(concentration) GT 0>
					<!--- make a new fluid container --->
					<cfquery name="updateContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						INSERT INTO Fluid_Container_History (
			  				container_id,
							checked_date,
							fluid_type,
							concentration,
							Fluid_Remarks
						) VALUES (
							#container_id#,
							'#dateformat(checked_date,'yyyy-mm-dd')#',
							'#fluid_type#',
							#concentration#,
							'#Fluid_Remarks#'
						)
					</cfquery>
				</cfif>
		    </cfif>
		</cftransaction>
	<cflocation url="EditContainer.cfm?container_id=#container_id#" addtoken="false">
</cfoutput>
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
			checked_date,
			fluid_type,
			concentration,
			fluid_remarks,
			width,
			length,
			height,
			number_positions,
			locked_position,
			institution_acronym
		FROM
			container,
			fluid_container_history
		WHERE
			container.container_id = fluid_container_history.container_id (+) AND
			container.container_id = #container_id#
	</cfquery>
	<cfquery name="ctInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select distinct(institution_acronym) institution_acronym from collection order by institution_acronym
	</cfquery>
	<cfquery name="ContType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select container_type from ctcontainer_type order by container_type
	</cfquery>
	<cfquery name="FluidType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select fluid_type from ctFluid_Type ORDER BY fluid_type
	</cfquery>
	<cfquery name="ctConc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select concentration from ctfluid_concentration order by concentration
	</cfquery>
	<cfoutput>
	<form name="form1" method="post" action="EditContainer.cfm">
		<input type="hidden" name="container_id" value="#getCont.container_id#">
		<span style="font-size:large; font-weight:bolder;">Edit Container</span>
		<table cellpadding="0" cellspacing="0">
	 		<tr>
				<td>
					<label for="label">Label</label>
					<input name="label" id="label" type="text" value="#getCont.label#" size="30" class="reqdClr">
				</td>
				<td>
					 <cfset thisType = "#getCont.Container_Type#">
					 <label for="container_type">Container Type</label>
					 <cfif getCont.container_type is not "collection object">
					 <select name="container_type" id="container_type" size="1" class="reqdClr" onChange="magicNumbers(this.value);">
				          <cfloop query="ContType"> 
			  				<cfif ContType.container_type is not "collection object">
	            				<option
								<cfif #thisType# is #ContType.container_type#> selected </cfif>
								value="#ContType.container_type#">#ContType.container_type#</option>
							</cfif>
	         			 </cfloop> 
					</select>
					<cfelse>
						<cfquery name="findItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							select 
								cataloged_item.collection_object_id,
								cat_num,
								collection.collection_cde,
								collection.institution_acronym,
								part_name
							FROM
								coll_obj_cont_hist,
								specimen_part,
								cataloged_item,
								collection
							WHERE
								coll_obj_cont_hist.collection_object_id = specimen_part.collection_object_id AND
								specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
								cataloged_item.collection_id = collection.collection_id and
								coll_obj_cont_hist.container_id = #container_id#
						</cfquery>
						<input type="text" name="container_type" id="container_type" value="collection object" readonly="yes" />
						<cfif #findItem.recordcount# is 1>
							<a href="/SpecimenDetail.cfm?collection_object_id=#findItem.collection_object_id#" target="_blank">
								#findItem.institution_acronym# #findItem.collection_cde# #findItem.cat_num#</a>
						<cfelse>
							Something is goofy - this containers matches #findItem.recordcount# items. File a bug report.
							<br />#findItem.institution_acronym# #findItem.collection_cde# #findItem.cat_num#
						</cfif>
					</cfif>
				</td>
			</tr>
			<tr>
				<td>
					 <label for="institution_acronym">Institution</label>
					 <select name="institution_acronym" id="institution_acronym" size="1" class="reqdClr">
				          <cfloop query="ctInst"> 
	            				<option <cfif getCont.institution_acronym is ctInst.institution_acronym> selected="selected" </cfif>value="#institution_acronym#">#institution_acronym#</option>
	         			 </cfloop> 
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<table cellspacing="0" cellpadding="0" width="100%">
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
					<textarea rows="2" cols="40" name="description" id="description">#getCont.Description#</textarea>
				</td>
			</tr>
	 		<tr>
				<td>
					<label for="barcode">Barcode</label>
					<input name="barcode" type="text" value="#getCont.barcode#" id="barcode">
				</td>
				<td>
					<label for="parent_install_date">Install Date</label>
					<input name="parent_install_date" id="parent_install_date" type="text" value="#Dateformat(getCont.parent_install_date, "yyyy-mm-dd")#">
				</td>
			</tr>
	  		<tr>
				<td>
					<label for="locked_position">Locked?</label>
						<select name="locked_position" id="locked_position" size="1">
							<option <cfif #getCont.locked_position# is 0> selected </cfif>value="0">no</option>
							<option <cfif #getCont.locked_position# is 1> selected </cfif>value="1">yes</option>
						</select>
				</td>
			</tr>
	 		<tr>
				<td colspan="2">
					<label for="container_remarks">Remarks?</label>
					<textarea rows="2" cols="40" id="container_remarks" name="container_remarks">#getCont.container_remarks#</textarea>
				</td>
			</tr>
	  		<tr>
				<td colspan="2">
					<table cellspacing="0" cellpadding="0" width="100%">
						<tr>
							<td>
								<label for="checked_date">Fluid Check Date</label>
								<input name="checked_date" id="checked_date" 
								type="text" 
								value="#dateformat(getCont.checked_date,'yyyy-mm-dd')#" 
								size="6">
							</td>
							<td>
								<label for="fluid_type">Fluid Type</label>
								<cfset thisFluid="#getCont.fluid_type#">
								 <select name="fluid_type" id="fluid_type" size="1">
									<option value=""></option>
										<cfloop query="FluidType"> 
											<option 
												<cfif #thisFluid# is "#FluidType.Fluid_Type#"> selected </cfif>		
												value="#FluidType.Fluid_Type#">#FluidType.Fluid_Type#
											</option>
										</cfloop>
								</select>
							</td>
							<td>
								<label for="concentration">Fluid Concentration</label>
								<select name="concentration" id="concentration" size="1">
									<option value=""></option>
										<cfloop query="ctConc">
											<option 
												<cfif #ctConc.concentration# is #getCont.concentration#> 
													selected 
												</cfif>
												value="#ctConc.concentration#">#ctConc.concentration#
											</option>
										</cfloop>
								</select>
							</td>
						</tr>
					</table>
				</td>
			<tr>
			<tr>
				<td colspan="2">
					<label for="fluid_remarks">Fluid Remarks</label>
					<input name="fluid_remarks" id="fluid_remarks" type="text" value="#getCont.fluid_remarks#" size="80">
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
								<input type="text" name="newParentBarcode" id="newParentBarcode" />
							</td>
						</tr>
					</table>
					<input type="hidden" name="action" value="update">
				</td>
			</tr>
	</table>
</form>
<form name="checked" method="post" action="EditContainer.cfm">
	<input type="hidden" name="action" value="saveChecked">
	<input type="hidden" name="container_id" value="#getCont.container_id#">
<table border="1">
		<tr>
			<td>
				<label for="checkedBy">Checked By</label>
				<input type="text" 
					name="checked_by" id="checked_by" class="reqdClr" value="#session.username#"
					 onchange="getAgent('checked_agent_id','checked_by','checked',this.value); return false;"
					 onKeyPress="return noenter(event);">
					<input type="hidden" name="checked_agent_id" value="#session.MyAgentId#">
			</td>
			<td>
				<label for="check_date">Checked Date</label>
				<input type="text" 
					name="check_date" id="check_date" class="reqdClr" value="#dateformat(now(),'yyyy-mm-dd')#" >
			</td>
			<td>
				<label for="check_remark">Check Remark</label>
				<input type="text" name="check_remark" id="check_remark">
			</td>
			<td>
				<input type="submit" value="Save Check" class="savBtn">
			</td>
			
		</tr>
	</table>

<cfquery name="checked" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from container_check,
	preferred_agent_name
	 where 
	 checked_agent_id = agent_id and
	 container_id=#container_id# order by check_date
</cfquery>
<cfif checked.recordcount is 0>
	No checked history.
<cfelse>
	<table border="1">
		<tr>
			<td>Date</td>
			<td>Checked By</td>
			<td>Remark</td>
		</tr>
		<cfloop query="checked">
			<tr>
				<td>#dateformat(check_date,"yyyy-mm-ddy")#</td>
				<td>#agent_name#</td>
				<td>#check_remark#</td>
			</tr>
		</cfloop>
	</table>
</cfif>

</cfoutput>
 </form>
</cfif>
<!-------------------------------------------------------------->
<cfif #Action# is "saveChecked">
	<cfoutput>
		<cfquery name="saveCheck" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into container_check ( 
				CONTAINER_ID,
				CHECK_DATE,
				CHECKED_AGENT_ID,
				CHECK_REMARK
			) values (
				#container_id#,
				to_date('#dateformat(check_date,"yyyy-mm-dd")#'),
				#checked_agent_id#,
				'#check_remark#'
			)
		</cfquery>
		<cflocation url="EditContainer.cfm?container_id=#container_id#" addtoken="false">
	</cfoutput>
</cfif>

<!-------------------------------------------------------------->
<cfif Action is "delete">
	<cfquery name="isUsed" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from container where parent_container_id=#container_id#
	</cfquery>
	<cfif isUsed.recordcount gt 0>
    <div align="center"><font color="#FF0000" size="+6">That container is used! 
      You can't delete it! <br>
      This is a really bad place to play around if you don't know what you're 
      doing!</font> </div>
    <cfabort>
	<cfelseif isUsed.recordcount is 0>
	<cftransaction>
		<cfquery name="deleContHist" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			DELETE FROM container_history WHERE container_id = #container_id#
		</cfquery>
		<cfquery name="deleCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			DELETE FROM container WHERE container_id = #container_id#
		</cfquery>
		<cfquery name="deleCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			DELETE FROM container_check WHERE container_id = #container_id#
		</cfquery>
	</cftransaction>
	<div align="center"><font color="#0066FF" size="+6">You've deleted this container!</font> </div>
	</cfif>
</cfif>
<!----------------------------->

<cfif action is "CreateNew">
	<cfif len(container_type) IS 0>
		<div class="error">
			Container type is required.
		</div>
		<cfabort>
	</cfif>
	<cfoutput>
		<cftransaction>
			<cfquery name="nextContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				SELECT sq_container_id.nextval newid FROM dual
			</cfquery>
			<cfif len(new_parent_barcode) gt 0>
				<cfquery name="gpid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select container_id from container where barcode='#new_parent_barcode#'
				</cfquery>
				<cfif len(gpid.container_id) is 0>
					<div class="error">Parent Container not found.</div>
					<cfabort>
				</cfif>
			</cfif>
			<cfquery name="newContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO container (
					container_id, 
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
					institution_acronym,
					locked_position
				) VALUES (
					#nextContainer.newid# 
					<cfif len(new_parent_barcode) gt 0>
						,#gpid.container_id#
					<cfelse>
						,0
					</cfif>
					,'#container_type#',
					'#label#',
					'#description#',
					to_date('#parent_install_date#'),
					'#escapeQuotes(container_remarks)#',
					'#barcode#'
					<cfif len(width) gt 0>
						,#width#
					<cfelse>
						,NULL
					</cfif>
					<cfif len(height) gt 0>
						,#height#
					<cfelse>
						,NULL
					</cfif>
					<cfif len(length) gt 0>
						,#length#
					<cfelse>
						,NULL
					</cfif>
					<cfif len(number_positions) gt 0>
						,#number_positions#
					<cfelse>
						,NULL
					</cfif>
					,'#institution_acronym#'
					<cfif container_type is "position">
						,1
					<cfelse>
						,0
					</cfif>
				)
			</cfquery>
			<cfif len(fluid_type) gt 0>
				<cfquery name="fluid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO fluid_container_history (
						container_id,
						checked_date,
						fluid_type,
						concentration,
						fluid_remarks
					) VALUES (
						#nextContainer.newid#,
						'#checked_date#',
						'#fluid_type#',
						#concentration#,
						'#fluid_remarks#'
					)
				</cfquery>
			</cfif>
		</cftransaction>
		<cflocation url="EditContainer.cfm?action=nothing&container_id=#nextContainer.newid#">
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
	<cfparam name="parent_install_date" default="">
	<cfparam name="container_remarks" default="">
	<cfparam name="Fluid_Type" default="">
	<cfparam name="concentration" default="">
	<cfparam name="fluid_remarks" default="">
	<cfif isdefined("container_type">
		<cfset ctype=container_type>
	</cfif>
	<cfif isdefined("fluid_type">
		<cfset ftype=fluid_type>
	</cfif>
	<cfoutput>
		<cfquery name="ctInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select distinct(institution_acronym) institution_acronym from collection order by institution_acronym
		</cfquery>
		<cfquery name="ContType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select container_type from ctcontainer_type order by container_type
		</cfquery>
		<cfquery name="FluidType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select fluid_type from ctFluid_Type ORDER BY fluid_type
		</cfquery>
		
		<cfquery name="ctConc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select concentration from ctfluid_concentration order by concentration
		</cfquery>
		<h2>Create Container</h2>
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
			<label for="new_parent_barcode">Parent Barcode</label>
			<input type="text" name="new_parent_barcode" id="new_parent_barcode" value="" />
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
			<label for="parent_install_date">Install Date</label>
			<input name="parent_install_date" type="text" value="#dateformat(now(),'yyyy-mm-dd')#" class="reqdClr">
			<label for="container_remarks">Remarks</label>
			<input name="container_remarks" type="text" value="#container_remarks#">
			<div id="fluidCtl">
				<span class="likeLink" onclick="toggleFluid(1)">Is Fluid</span>
			</div> 
			<div id="fluidDiv" style="display:none">
				<label for="checked_date">Fluid Type</label>
				<select name="Fluid_Type" size="1" class="reqdClr" id="fluid_type">
					<option value=""></option>
		          	<cfloop query="FluidType"> 
        		    	<option <cfif ftype is FluidType.Fluid_Type> <selected="selected"> </cfif>value="#FluidType.Fluid_Type#">#FluidType.Fluid_Type#</option>
		          	</cfloop>
				</select>
				<label for="checked_date">Fluid Checked Date</label>
				<input name="checked_date" id="checked_date" type="text" value="#checked_date#" class="reqdClr">
				<label for="concentration">Fluid Concentration</label>
				<select name="concentration" id="concentration" size="1">
					<option value=""></option>
					<cfloop query="ctConc">
						<option value="#ctConc.concentration#">#ctConc.concentration#</option>
					</cfloop>
				</select>
				<label for="fluid_remarks">Fluid Remarks</label>
				<input name="fluid_remarks" id="fluid_remarks" type="text" value="#fluid_remarks#">
			</div>
			<br><input type="submit" value="Create Container" class="insBtn">
		</form>
		<script>
			isThisAPosition();
		</script>
	</cfoutput>
</cfif>
<!---------------------------------------------------->
<cfinclude template="/includes/_pickFooter.cfm">
