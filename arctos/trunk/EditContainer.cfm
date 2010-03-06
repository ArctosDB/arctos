<cfinclude template="includes/_header.cfm">

<!--- 
	add container check
	2 Aug 2007 - DLM
	
	create table container_check (
		container_check_id number not null,
		container_id number not null,
		check_date date not null,
		checked_agent_id number not null,
		check_remark varchar2(255)
	);
	create public synonym container_check for container_check;
	grant select on container_check to public;
	grant insert on container_check to manage_specimens,manage_transactions;
	
	ALTER TABLE container_check
		add CONSTRAINT pkey_container_check PRIMARY KEY (container_check_id);
	

    ALTER TABLE container_check
    	add CONSTRAINT fkey_cont_chk_container
     	FOREIGN KEY (container_id)
     	REFERENCES container (container_id);
	
	ALTER TABLE container_check
    	add CONSTRAINT fkey_cont_agnt_agent
     	FOREIGN KEY (checked_agent_id)
     	REFERENCES agent (agent_id);

	CREATE OR REPLACE TRIGGER container_check_id                                         
 	before insert  ON container_check  
 for each row 
    begin     
    	if :NEW.container_check_id is null then                                                                                      
    		select somerandomsequence.nextval into :new.container_check_id from dual;
    	end if;
		if :NEW.check_date is null then                                                                                      
    		:NEW.check_date:= sysdate;
    	end if;                                 
    end;                                                                                            
/
sho err
--->

<script>
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
		var contTypeEl = document.getElementById('Container_Type');
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







<cfif #Action# is "update">
<!--- set date format --->
<cfif len(#newParentBarcode#) gt 0>
	<cfquery name="isGoodParent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select container_id from  container where 
		barcode = '#newParentBarcode#'
	</cfquery>
	<cfif #isGoodParent.recordcount# is 1>
		<cfset newParentId = #isGoodParent.container_id#>
	<cfelse>
		<cfoutput>
		A container with barcode #newParentBarcode# was not found!
		</cfoutput>
		<cfabort>
	</cfif>
</cfif>
<cfoutput>
<!--- build the SQL to update container with values passed from this form to itself--->
<cfset uds="UPDATE container SET container_id = #container_id#">
<cfset udQual="">
<cfif len(#newParentBarcode#) gt 0>
	<cfset udQual="#udqual#, parent_container_id = #newParentId#">
</cfif>
<cfif #container_type# is not "">
	<cfset udQual="#udqual#, container_type = '#container_type#'">
	</cfif>
<cfif #description# is not "">
	<cfset #udQual# = "#udqual#, description = '#escapeQuotes(description)#'">
<cfelse>
	<cfset #udQual# = "#udqual#, description = NULL">
</cfif>
<cfif #barcode# is not "">
	<cfset #udQual# = "#udQual# , barcode = '#barcode#'">
  <cfelse>
  	<cfset #udQual# = "#udQual# , barcode = null">
</cfif>
<cfif #width# is not "">
	<cfset #udQual# = "#udQual# , width = #width#">
  <cfelse>
  	<cfset #udQual# = "#udQual# , width = null">
</cfif>
<cfif #height# is not "">
	<cfset #udQual# = "#udQual# , height = #height#">
  <cfelse>
  	<cfset #udQual# = "#udQual# , height = null">
</cfif>
<cfif #length# is not "">
	<cfset #udQual# = "#udQual# , length = #length#">
  <cfelse>
  	<cfset #udQual# = "#udQual# , length = null">
</cfif>
<cfif #number_positions# is not "">
	<cfset #udQual# = "#udQual# , number_positions = #number_positions#">
  <cfelse>
  	<cfset #udQual# = "#udQual# , number_positions = null">
</cfif>
<cfset #udQual# = "#udQual# , locked_position = #locked_position#">
<cfif #label# is not "">
	<cfset #udQual# = "#udQual# , label = '#label#'">
</cfif>
<cfif #parent_install_date# is not "">
<cfif isdate("#parent_install_date#")>
				<cfset parent_install_date = "'#Dateformat(parent_install_date, "DD-Mmm-YYYY")#'">
				<cfelse><cfset parent_install_date = "null">
			</cfif>
	<cfset #udQual# = "#udQual# , parent_install_date = #parent_install_date#">
</cfif>
<cfif #container_remarks# is not "">
	<cfset #udQual# = "#udQual# , container_remarks = '#escapeQuotes(container_remarks)#'">
<cfelse>
	<cfset #udQual# = "#udQual# , container_remarks = null">
</cfif>
<cfset udWhere = "WHERE container_id = #container_id#">
<cfset contSqlStr="#uds# #udQual# #udWhere#">
<!--- Now build SQL to update Fluid_Container_History
First, make sure that this is a fluid container--->
<cfquery name="isFluid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT * FROM fluid_container_history WHERE container_id = #container_id#
</cfquery>
<cfif #isFluid.recordcount# gt 0 AND len(#isFluid.container_id#) gt 0>
		<cfset chUp = "UPDATE Fluid_Container_History SET container_id = #container_id#">
		<cfset chQual="">
		<cfif #Checked_Date# is not "">
			<cfset #chQual# = "#chQual# , Checked_Date = '#dateformat(Checked_Date,'dd-mmm-yyyy')#'">
		</cfif>
		<cfif #Fluid_Type# is not "">
			<cfset #chQual# = "#chQual# , Fluid_Type = '#Fluid_Type#'">
		</cfif>
		<cfif #Concentration# is not "">
			<cfset #chQual# = "#chQual# , Concentration = #Concentration#">
		</cfif>
		<cfif #Fluid_Remarks# is not "">
			<cfset #chQual# = "#chQual# , Fluid_Remarks = '#Fluid_Remarks#'">
		</cfif>
		<cfset chWhere = "WHERE container_id = #container_id#">
		<cfset chSqlStr = "#chUp# #chQual# #chWhere#">
		<cfquery name="updateFluidContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				#preservesinglequotes(chSqlStr)#
		</cfquery>
	<cfelse>
		<cfif len(#checked_date#) GT 0 OR len(#fluid_type#) GT 0 OR len(#concentration#) GT 0>
			<!--- make a new fluid container --->
      <cfset fch = "INSERT INTO Fluid_Container_History (
	  		container_id,
			checked_date,
			fluid_type,
			concentration">
		<cfif len(#Fluid_Remarks#) gt 0>
			<cfset #fch# = "#fch# , Fluid_Remarks">
		</cfif>
		<cfset #fch# = "#fch# ) VALUES (
			#container_id#,
			'#dateformat(checked_date,'dd-mmm-yyyy')#',
			'#fluid_type#',
			#concentration#">
		<cfif len(#Fluid_Remarks#) gt 0>
			<cfset #fch# = "#fch# , '#Fluid_Remarks#'">
		</cfif>
		<cfset #fch# = "#fch# )">
		<cfquery name="updateContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(fch)#
		</cfquery>
		</cfif>
    </cfif>




	<cfquery name="updateContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(contsqlStr)#
	</cfquery>
	<cflocation url="EditContainer.cfm?container_id=#container_id#">
</cfoutput>
	
</cfif>
<!---------------------------------------------------------------->
<cfif #action# is "nothing">
<cfset title="Edit Container">
<!---Get the data to fill this page --->
<cfset getCD="
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
locked_position
FROM
container,
fluid_container_history
WHERE
container.container_id = fluid_container_history.container_id (+) AND
container.container_id = #container_id#
">

<cfquery name="getCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(getCD)#
</cfquery>

<cfquery name="ContType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
select container_type from ctcontainer_type
</cfquery>
<cfquery name="FluidType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
select fluid_type from ctFluid_Type ORDER BY fluid_type
</cfquery>
<cfquery name="ctConc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from ctfluid_concentration
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
				 <cfif #getCont.container_type# is not "collection object">
				 <select name="container_type" id="container_type" size="1" class="reqdClr" onChange="magicNumbers(this.value);">
			          <cfloop query="ContType"> 
		  				<cfif #ContType.container_type# is not "collection object">
            				<option
							<cfif #thisType# is #ContType.container_type#> selected </cfif>
							value="#ContType.container_type#">#ContType.container_type#</option>
						</cfif>
         			 </cfloop> 
				</select>
				<cfelse>
					<cfquery name="findItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
				<input name="parent_install_date" id="parent_install_date" type="text" value="#Dateformat(getCont.parent_install_date, "DD-Mmm-YYYY")#">
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
							value="#dateformat(getCont.checked_date,'dd mmmm yyyy')#" 
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
								onmouseover="this.className='savBtn btnhov'"
								onmouseout="this.className='savBtn'"
								onclick="form1.action.value='update';submit();">
						</td>
						<td>
							<input type="button" 
								value="Delete" 
								class="delBtn"
								onmouseover="this.className='delBtn btnhov';"
								onmouseout="this.className='delBtn';"
								onclick="form1.action.value='delete';confirmDelete('form1');" >
						</td>
						<td>
							<input type="button"
								value="Clone" 
								class="insBtn"
								onmouseover="this.className='insBtn btnhov'"
								onmouseout="this.className='insBtn'"
								onclick="form1.action.value='newContainer';submit();">
						</td>
						<td>
							<cfif #getCont.parent_container_id# gt 0>
								<input type="button"
									value="Edit Parent"
									class="lnkBtn"
									onmouseover="this.className='lnkBtn btnhov'"
									onmouseout="this.className='lnkBtn'"
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
<cfquery name="me" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select preferred_agent_name.agent_name,preferred_agent_name.agent_id from preferred_agent_name,
	agent_name
	where preferred_agent_name.agent_id = agent_name.agent_id and
	agent_name.agent_name_type='login' and
	agent_name.agent_name='#session.username#'
</cfquery>
<form name="checked" method="post" action="EditContainer.cfm">
	<input type="hidden" name="action" value="saveChecked">
	<input type="hidden" name="container_id" value="#getCont.container_id#">
<table border="1">
		<tr>
			<td>
				<label for="checkedBy">Checked By</label>
				<input type="text" 
					name="checked_by" id="checked_by" class="reqdClr" value="#me.agent_name#"
					 onchange="getAgent('checked_agent_id','checked_by','checked',this.value); return false;"
					 onKeyPress="return noenter(event);">
					<input type="hidden" name="checked_agent_id" value="#me.agent_id#">
			</td>
			<td>
				<label for="check_date">Checked Date</label>
				<input type="text" 
					name="check_date" id="check_date" class="reqdClr" value="#dateformat(now(),'dd mmm yyyy')#" >
			</td>
			<td>
				<label for="check_remark">Check Remark</label>
				<input type="text" 
					name="check_remark" id="check_remark">
			</td>
			<td>
				<input type="submit"
									value="Save Check"
									class="savBtn"
									onmouseover="this.className='savBtn btnhov'"
									onmouseout="this.className='savBtn'">
			</td>
			
		</tr>
	</table>

<cfquery name="checked" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from container_check,
	preferred_agent_name
	 where 
	 checked_agent_id = agent_id and
	 container_id=#container_id# order by check_date
</cfquery>
<cfif #checked.recordcount# is 0>
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
				<td>#dateformat(check_date,"dd mmm yyyy")#</td>
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
		<cfquery name="saveCheck" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into container_check ( 
				CONTAINER_ID,
				CHECK_DATE,
				CHECKED_AGENT_ID,
				CHECK_REMARK
			) values (
				#container_id#,
				to_date('#dateformat(check_date,"dd-mmm-yyyy")#'),
				#checked_agent_id#,
				'#check_remark#'
			)
		</cfquery>
		<cflocation url="EditContainer.cfm?container_id=#container_id#">
	</cfoutput>
</cfif>

<!-------------------------------------------------------------->
<cfif #Action# is "delete">
	<cfquery name="isUsed" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from container where parent_container_id=#container_id#
	</cfquery>
	<cfif isUsed.recordcount gt 0>
    <div align="center"><font color="#FF0000" size="+6">That container is used! 
      You can't delete it! <br>
      This is a really bad place to play around if you don't know what you're 
      doing!</font> </div>
    <cfabort>
	<cfelseif isUsed.recordcount is 0>
	<cfquery name="deleContHist" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		DELETE FROM container_history WHERE container_id = #container_id#
	</cfquery>
	<cfquery name="deleCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		DELETE FROM container WHERE container_id = #container_id#
	</cfquery>
	<div align="center"><font color="#0066FF" size="+6">You've deleted this container!</font> </div>
	</cfif>
</cfif>
<!----------------------------->

<cfif #action# is "CreateNew">
<cfset title="Create Container">
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
			<cfif len(#new_parent_barcode#) gt 0>
				<cfquery name="gpid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select container_id from container where barcode='#new_parent_barcode#'
				</cfquery>
			</cfif>
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
				<cfset locked_position = "1">
			<cfelse>
				<cfset locked_position = "0">
			</cfif>			
			<cfif #container_type# is "position">
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
						number_positions,
						institution_acronym,
						locked_position)
					VALUES
						(#container_id#,"> 
						<cfif len(#new_parent_barcode#) gt 0>
							<cfset newContainerSQL="#newContainerSQL# #gpid.container_id#">
						<cfelse>
							<cfset newContainerSQL="#newContainerSQL# 0">
						</cfif>
						<cfset newContainerSQL="#newContainerSQL# 
						,'#container_type#',
						#label#,
						#description#,
						to_date(#parent_install_date#),
						#escapeQuotes(container_remarks)#,
						#barcode#,
						#width#,
						#height#,
						#length#,
						#number_positions#,
						'UAM'">
						<cfif #container_type# is "position">
							<cfset newContainerSQL="#newContainerSQL# ,1)">
						<cfelse>
							<cfset newContainerSQL="#newContainerSQL# ,0)">
						</cfif>
				<cftransaction>
					<cfquery name="newContainer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						#preservesinglequotes(newContainerSQL)#
					</cfquery>
				</cftransaction>
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
<cflocation url="EditContainer.cfm?action=nothing&container_id=#container_id#">
</cfif><!---end of <cfif URL.action is "CreateNew">--->
<!---------------------------------------------->
<cfif #action# is "newContainer">

<cfoutput>

<cfquery name="ContType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
select container_type as ctContType from ctcontainer_type
</cfquery>
<cfquery name="FluidType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
select fluid_type from ctFluid_Type ORDER BY fluid_type
</cfquery>

 <form name="form1" method="post" action="EditContainer.cfm">
 	<input type="hidden" name="action" value="CreateNew" />
<table border="0">
  <tr>
    <td colspan="2" align="center">
		<b>Create Container</b>

	</td>
	</tr>
	<tr>
		<td align="right"><b>Container Type:</b></td>
		<td>
		<cfparam name="container_type" default="">
			  <select name="Container_Type" size="1" id="Container_Type" class="reqdClr" onchange="isThisAPosition();">
				<option value=""></option>
					<cfloop query="ContType"> 
						 <cfif #ContType.ctContType# is not "collection object">
			            <option 
							<cfif #container_type# is #ctContType#> selected </cfif>value="#ContType.ctContType#">#ContType.ctContType#</option>
						</cfif>
          			</cfloop> 
			</select>
		</td>
	</tr>
	<tr>
		<td align="right">Parent Barcode:</td>
		<td><input type="text" name="new_parent_barcode" id="new_parent_barcode" value="" /></td>
	</tr>
	<tr>
		<td align="right"><b>Dimensions:</b></td>
		<td>
			<cfparam name="width" default="">
			<cfparam name="height" default="">
			<cfparam name="length" default="">
			W: <input name="width" type="text" value="#width#" size="6">
			H: <input name="height" type="text" value="#height#" size="6">
			L: <input name="length" type="text" value="#length#" size="6">
		</td>
	</tr>
	<tr>
		<td align="right"><b>Number of Positions:</b></td>
		<td>
			<cfparam name="number_positions" default="">
			<input name="number_positions" id="number_positions" type="text" value="#number_positions#">
			
		</td>
	</tr>
	<tr>
		<td align="right"><b>Description:</b></td>
		<td>
			<cfparam name="description" default="">
			<input name="description" type="text" value="#description#">
		</td>
	</tr>
	<tr>
		<td align="right"><b>Barcode:</b></td>
		<td><cfparam name="barcode" default="">
		<input name="barcode" type="text" value="#barcode#"></td>
	</tr>
	<tr>
		<td align="right"><b>Label:</b></td>
		<td><cfparam name="label" default="">
		<input name="label" type="text" value="#label#" class="reqdClr"></td>
	</tr>
	<tr>
		<td align="right"><b>Install Date:</b></td>
		<td><cfparam name="parent_install_date" default="">
		<input name="parent_install_date" type="text" value="#dateformat(now(),'dd-mmm-yyyy')#" class="reqdClr"></td>
	</tr>
	<tr>
		<td align="right"><b>Remarks:</b></td>
		<td><cfparam name="container_remarks" default="">
		<input name="container_remarks" type="text" value="#container_remarks#"></td>
	</tr>
	<tr>
		<td align="right"><b>Fluid Checked Date:</b></td>
		<td><cfparam name="checked_date" default="">
		<input name="checked_date" type="text" value="#checked_date#"></td>
	</tr>
	<tr>
		<td align="right"><b>Fluid Type:</b></td>
		<td> 
			<cfparam name="Fluid_Type" default="">
			<cfset thisFluidType = #Fluid_Type#>
			<select name="Fluid_Type" size="1">
				<option value=""></option>
		          <cfloop query="FluidType"> 
        		    <option <cfif #thisFluidType# is #Fluid_Type#> <selected> </cfif>value="#FluidType.Fluid_Type#">#FluidType.Fluid_Type#</option>
		          </cfloop>
				 </select>
		</td>
	</tr>
	<tr>
		<td align="right"><b>Fluid Concentration:</b></td>
		<td>
		<cfparam name="concentration" default="">
		<input name="concentration" type="text" value="#concentration#"></td>
	</tr>
	<tr>
		<td align="right"><b>Fluid Remarks: </b></td>
		<td>
			<cfparam name="fluid_remarks" default="">
			<input name="fluid_remarks" type="text" value="#fluid_remarks#">
		</td>
	</tr>
	<tr>
		
		<td colspan="2" align="center"> 
			
			  <input type="submit" value="Create Container" class="insBtn"
				onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">	
			
	  </td>
	</tr>
</table>

      
 </form>
<script>
	isThisAPosition();
</script>
</cfoutput>
</cfif>
<!---------------------------------------------->
<!---------------------------------------------------->
<cfinclude template="/includes/_pickFooter.cfm">
