
<div id="theHead">
	<cfinclude template="includes/_header.cfm">
</div>
</div><!--- kill content div --->

<!---><cfinclude template="/includes/functionLib.cfm">--->
<script language="JavaScript" src="includes/CalendarPopup.js" type="text/javascript"></script>
<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
	var cal1 = new CalendarPopup("theCalendar");
	cal1.showYearNavigation();
	cal1.showYearNavigationInput();
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript" type="text/javascript">document.write(getCalendarStyles());</SCRIPT>

<cfset title = "Search for specimens or encumbrances">
<cfif not isdefined("collection_object_id")>
	<cfset collection_object_id=-1>
	<cfobjectcache action="clear">
</cfif>
<cfquery name="ctEncAct" datasource="#Application.web_user#">
	select encumbrance_action from ctencumbrance_action
</cfquery>
<cfif #action# is "nothing">
<cfoutput>
<strong>Manage Encumbrances</strong>
<cfform name="encumber" method="post" action="Encumbrances.cfm">
<strong>
	<br>Search for an encumbrance <cfif isdefined("collection_object_id")>
										to add these items to
								<cfelse>
										to alter below
								</cfif>
	<br> OR  
	 <input type="button" value="Find Specimens to encumber" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
   onClick="window.open('SpecimenSearch.cfm?Action=encumber','#client.target#');">	

	
	<br> OR 
	<input type="button" value="Create A New Encumbrance" class="insBtn"
   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'"
   onClick="window.open('newEncumbrance.cfm','#client.target#')">	

</strong>


	<input type="hidden" name="Action" value="listEncumbrances">
	<input type="hidden" name="collection_object_id" value="#collection_object_id#">
	<table border="0">
		<tr>
			<td colspan="2">
				<label for="">Encumbering Agent</label>
				<input name="encumberingAgent" id="encumberingAgent" type="text">
			</td>
		</tr>
		<tr>
			<td>
				<label for="made_date_after">Made Date After</label>
				<input type="text" name="made_date_after" id="made_date_after">
				<span class="infoLink"
					name="anchor1"
					id="anchor1"
					onClick="cal1.showCalendar('anchor1'); 
						cal1.select(document.encumber.made_date_after,'anchor1','d NNN yyyy'); 
							return false;">
						Pick
				</span>
			</td>
			<td>
				<label for="made_date_before">Made Date Before</label>
				<input type="text" name="made_date_before" id="made_date_before">
				<span class="infoLink"
					name="anchor1"
					id="anchor1"
					onClick="cal1.showCalendar('anchor1'); 
						cal1.select(document.encumber.made_date_before,'anchor1','d NNN yyyy'); 
							return false;">
						Pick
				</span>
			</td>
		</tr>
		<tr>
			<td>
				<label for="expiration_date_after">Expiration Date After</label>
				<input type="text" name="expiration_date_after" id="expiration_date_after">
				<span class="infoLink"
					name="anchor1"
					id="anchor1"
					onClick="cal1.showCalendar('anchor1'); 
						cal1.select(document.encumber.expiration_date_after,'anchor1','d NNN yyyy'); 
							return false;">
						Pick
				</span>
			</td>
			<td>
				<label for="expiration_date_before">Expiration Date Before</label>
				<input type="text" name="expiration_date_before" id="expiration_date_before">
				<span class="infoLink"
					name="anchor1"
					id="anchor1"
					onClick="cal1.showCalendar('anchor1'); 
						cal1.select(document.encumber.expiration_date_before,'anchor1','d NNN yyyy'); 
							return false;">
						Pick
				</span>
			</td>
		</tr>	
			<td colspan="2">
				<label for="expiration_event">Expiration Event</label>
				<input type="text" id="expiration_event" name="expiration_event">
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<label for="encumbrance">Encumbrance Event</label>
				<input type="text" name="encumbrance" id="encumbrance">
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<label for="encumbrance_action">Encumbrance Action</label>
				<select name="encumbrance_action" id="encumbrance_action" size="1">
					<option value=""></option>
					<cfloop query="ctEncAct">
						<option value="#ctEncAct.encumbrance_action#">#ctEncAct.encumbrance_action#</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<label for="remarks">Remarks</label>
				<textarea name="remarks" id="remarks" rows="3" cols="50"></textarea>
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center">
			
			 <input type="submit" value="Find Encumbrance" class="schBtn"
   onmouseover="this.className='schBtn btnhov'" onmouseout="this.className='schBtn'">	
			</td>
		</tr>
	</table>
</cfform>
</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------------->

<!-------------------------------------------------------------------------------------------->
<cfif #Action# is "listEncumbrances">

	<cfif len(#collection_object_id#) is 0>
		Didn't get a collection_object_id!!<cfabort>
	</cfif>
	<cfoutput>
	<cfset sql = "select * from encumbrance, preferred_agent_name WHERE
					encumbrance.encumbering_agent_id = preferred_agent_name.agent_id">
	<cfif len(#encumberingAgent#) gt 0>
		<cfset sql = "#sql# AND upper(agent_name) like '%#ucase(encumberingAgent)#%'">	
	</cfif>
	<cfif isdefined("made_date_after") and len(#made_date_after#) gt 0>
		<cfset sql = "#sql# AND made_date >= to_date('#made_date_after#')">	
	</cfif>
	<cfif isdefined("made_date_before") and len(#made_date_before#) gt 0>
		<cfset sql = "#sql# AND made_date <= to_date('#made_date_before#')">	
	</cfif>
	<cfif isdefined("expiration_date_after") and len(#expiration_date_after#) gt 0>
		<cfset sql = "#sql# AND expiration_date >= to_date('#expiration_date_after#')">	
	</cfif>
	<cfif isdefined("expiration_date_before") and len(#expiration_date_before#) gt 0>
		<cfset sql = "#sql# AND expiration_date <= to_date('#expiration_date_before#')">	
	</cfif>
				
	<cfif len(#encumbrance#) gt 0>
		<cfset sql = "#sql# AND upper(encumbrance) like '%#ucase(encumbrance)#%'">	
	</cfif>
	<cfif len(#encumbrance_action#) gt 0>
		<cfset sql = "#sql# AND encumbrance_action = '#encumbrance_action#'">	
	</cfif>
	<cfif len(#remarks#) gt 0>
		<cfset sql = "#sql# AND upper(remarks) like '%#ucase(remarks)#%'">	
	</cfif>
	<hr>#preservesinglequotes(sql)#<hr>
	<cfquery name="getEnc" datasource="#Application.web_user#">
		#preservesinglequotes(sql)#
	</cfquery>
	</cfoutput>
	<cfset i = 1>
	<cfloop query="getEnc">
	<cfoutput>
		<br>
		<form name="listEnc#i#" method="post" action="Encumbrances.cfm">
			<input type="hidden" name="Action">
			<input type="hidden" name="encumbrance_id" value="#encumbrance_id#">
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">
			#encumbrance# (#encumbrance_action#) by #agent_name# made #dateformat(made_date,"dd mmm yyyy")#, expires #dateformat(expiration_date,"dd mmm yyyy")# #expiration_event# #remarks#
			<br>
			<cfif #collection_object_id# gt 0>
			<input type="button" 
		value="Add All Items To This Encumbrance" 
		class="savBtn"
		onmouseover="this.className='savBtn btnhov'"
		onmouseout="this.className='savBtn'"
		onClick="listEnc#i#.Action.value='saveEncumbrances';submit();">
		
		<input type="button" 
		value="Remove Listed Items From This Encumbrance" 
		class="delBtn"
		onmouseover="this.className='delBtn btnhov'"
		onmouseout="this.className='delBtn'"
		onClick="listEnc#i#.Action.value='remListedItems';submit();">
		
			</cfif>
				<input type="button" 
		value="Delete This Encumbrance" 
		class="delBtn"
		onmouseover="this.className='delBtn btnhov'"
		onmouseout="this.className='delBtn'"
		onClick="listEnc#i#.Action.value='deleteEncumbrance';confirmDelete('listEnc#i#');">
		
		<input type="button" 
		value="Modify This Encumbrance" 
		class="lnkBtn"
		onmouseover="this.className='lnkBtn btnhov'"
		onmouseout="this.className='lnkBtn'"
		onClick="listEnc#i#.Action.value='updateEncumbrance';submit();">
		
		<input type="button" 
		value="See Specimens" 
		class="lnkBtn"
		onmouseover="this.className='lnkBtn btnhov'"
		onmouseout="this.className='lnkBtn'"
		onClick="document.location='/SpecimenResults.cfm?encumbrance_id=#encumbrance_id#','#client.target#'">
		
		<input type="button" 
		value="Delete Encumbered Specimens" 
		class="delBtn"
		onmouseover="this.className='delBtn btnhov'"
		onmouseout="this.className='delBtn'"
		onClick="document.location='/Admin/deleteSpecByEncumbrance.cfm?encumbrance_id=#encumbrance_id#','#client.target#'">
		</form>
		<cfset i = #i#+1>
	</cfoutput>
	</cfloop>
	
	
</cfif>
<!-------------------------------------------------------------------------------------------->
<cfif #Action# is "remListedItems">
	<cfoutput>
	<cfif len(#encumbrance_id#) is 0>
		Didn't get an encumbrance_id!!<cfabort>
	</cfif>
	<cfif len(#collection_object_id#) is 0>
		Didn't get a collection_object_id!!<cfabort>
	</cfif>
	<cftry>
	
	<cfloop index="i" 
		list="#collection_object_id#" 
		delimiters=",">
	
	<cfquery name="encSpecs" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		DELETE FROM coll_object_encumbrance
		WHERE
		encumbrance_id = #encumbrance_id# AND
		collection_object_id =#i#
	</cfquery>
	
	
	</cfloop>
	<cfcatch type="database">
		stuff
	</cfcatch>

	</cftry>
</cfoutput>	
</cfif>


<!-------------------------------------------------------------------------------------------->
<cfif #Action# is "updateEncumbrance">
<cfset title = "Update Encumbrance">
Edit Encumbrance:
<cfoutput>
<cfquery name="encDetails" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	SELECT
		 * 
	FROM
		encumbrance, 
		preferred_agent_name 
	WHERE 
	encumbering_agent_id = agent_id AND
	encumbrance_id = #encumbrance_id#
</cfquery>
</cfoutput>
<cfoutput query="encDetails">
<form name="updateEncumbrance" method="post" action="Encumbrances.cfm">
	<input type="hidden" name="Action" value="updateEncumbrance2">
	<input name="encumbrance_id" value="#encumbrance_id#" type="hidden">
	
	<table border="1">
		<tr>
			<td align="right">
			<a href="javascript:void(0);" 
				class="novisit" 
				onClick="getDocs('encumbrance','encumbrancer')">Encumbering Agent:</a></td>
				</td>
			<td><input type="hidden" name="encumberingAgentId">
			
		<input type="text" name="encumberingAgent" class="reqdClr" value="#agent_name#"
		 onchange="getAgent('encumberingAgentId','encumberingAgent','updateEncumbrance',this.value); return false;"
		  onKeyPress="return noenter(event);">
		  </td>
			<td align="right">
				Made Date:
			</td>
			<td><input type="text" name="made_date" value="#dateformat(made_date,'dd-mmm-yyyy')#"></td>
		</tr>
		<tr>
			<td align="right">
			<a href="javascript:void(0);" 
				class="novisit" 
				onClick="getDocs('encumbrance','expiration')">Expiration Date:</a>
				</td>
			<td><input type="text" name="expiration_date"  value="#dateformat(expiration_date,'dd-mmm-yyyy')#"></td>
			<td align="right">
			<a href="javascript:void(0);" 
				class="novisit" 
				onClick="getDocs('encumbrance','expiration')">Expiration Event:</a>
			</td>
			<td><input type="text" name="expiration_event" value="#expiration_event#"></td>
		</tr>
		<tr>
			<td align="right">
			<a href="javascript:void(0);" 
				class="novisit" 
				onClick="getDocs('encumbrance','encumbrance_name')">Encumbrance:</a>
				</td>
			<td><input type="text" name="encumbrance" value="#encumbrance#"></td>
			<td align="right">Encumbrance Action</td>
			<td>
			<select name="encumbrance_action" size="1">
				<cfloop query="ctEncAct">
					<option 
						<cfif #ctEncAct.encumbrance_action# is "#encDetails.encumbrance_action#"> selected </cfif> value="#ctEncAct.encumbrance_action#">#ctEncAct.encumbrance_action#</option>
				</cfloop>
			
			</select>
			</td>
		</tr>
		<tr>
			<td align="right">Remarks:</td>
			<td colspan="3"><textarea name="remarks" rows="3" cols="50">#remarks#</textarea></td>
		</tr>
		<tr>
			<td colspan="4" align="center">
			
			<input type="submit" 
		value="Save Edits" 
		class="savBtn"
		onmouseover="this.className='savBtn btnhov'"
		onmouseout="this.className='savBtn'">
		
		<input type="button" 
		value="Quit" 
		class="qutBtn"
		onmouseover="this.className='qutBtn btnhov'"
		onmouseout="this.className='qutBtn'"
		onClick="document.location='Encumbrances.cfm'">
		
		
		</td>
		</tr>
	</table>
</form>
</cfoutput>

</cfif>
<!-------------------------------------------------------------------------------------------->
<cfif #Action# is "updateEncumbrance2">
	
	<cfoutput>


<cfquery name="newEncumbrance" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
UPDATE encumbrance SET
	encumbrance_id = #encumbrance_id#
	<cfif len(#encumberingAgentId#) gt 0>
		,ENCUMBERING_AGENT_ID = #encumberingAgentId#	
	</cfif>
	,ENCUMBRANCE = '#ENCUMBRANCE#'
	,ENCUMBRANCE_ACTION = '#ENCUMBRANCE_ACTION#'
	<cfif len(#expiration_date#) gt 0>
		,EXPIRATION_DATE = '#dateformat(EXPIRATION_DATE,"dd-mmm-yyyy")#'	
	</cfif>
	<cfif len(#EXPIRATION_EVENT#) gt 0>
		,EXPIRATION_EVENT = '#EXPIRATION_EVENT#'	
	</cfif>
	<cfif len(#MADE_DATE#) gt 0>
		,MADE_DATE = '#dateformat(MADE_DATE,'dd-mmm-yyyy')#'	
	</cfif>
	<cfif len(#REMARKS#) gt 0>
		,REMARKS = '#REMARKS#'	
	</cfif>
	where encumbrance_id = #encumbrance_id#
</cfquery>

	 <cflocation url="Encumbrances.cfm?Action=updateEncumbrance&encumbrance_id=#encumbrance_id#">
	 </cfoutput>

	 	
</cfif>
<!-------------------------------------------------------------------------------------------->
<!-------------------------------------------------------------------------------------------->
<cfif #Action# is "deleteEncumbrance">
<cfoutput>
	<cfif len(#encumbrance_id#) is 0>
		Didn't get an encumbrance_id!!<cfabort>
	</cfif>
	<cfquery name="isUsed" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		select count(*) as cnt from coll_object_encumbrance where encumbrance_id=#encumbrance_id#
	</cfquery>
	<cfif #isUsed.cnt# gt 0>
		You can't delete this encumbrance because specimens are using it!<cfabort>
	</cfif>
	<cfquery name="deleteEnc" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		DELETE FROM encumbrance WHERE encumbrance_id = #encumbrance_id#
	</cfquery>
</cfoutput>	
</cfif>
<!-------------------------------------------------------------------------------------------->


<!-------------------------------------------------------------------------------------------->
<cfif #Action# is "saveEncumbrances">
<cfoutput>
	<cfif len(#encumbrance_id#) is 0>
		Didn't get an encumbrance_id!!<cfabort>
	</cfif>
	<cfif len(#collection_object_id#) is 0>
		Didn't get a collection_object_id!!<cfabort>
	</cfif>

	
	<cfloop index="i" 
		list="#collection_object_id#" 
		delimiters=",">
	
	<cfquery name="encSpecs" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	INSERT INTO coll_object_encumbrance (encumbrance_id, collection_object_id)
		VALUES (#encumbrance_id#, #i#)
	</cfquery>
	
	
	</cfloop>
	
</cfoutput>	
</cfif>
<!-------------------------------------------------------------------------------------------->
<!-------------------------------------------------------------------------------------------->
<cfif #collection_object_id# gt 0>
	<Cfset title = "Encumber these specimens">
		<cfoutput>
			<cfquery name="getData" datasource="#Application.web_user#">
				 SELECT 
					cataloged_item.collection_object_id as collection_object_id, 
					cat_num, 
					af_num.af_num, 
					identification.scientific_name, 
					country, 
					state_prov, 
					county, 
					cataloged_item.collection_object_id, 
					quad, 
					institution_acronym, 
					collection.collection_cde, 
					part_name, 
					specimen_part.collection_object_id AS partID, 
					encumbering_agent.agent_name AS encumbering_agent, 
					expiration_date, 
					expiration_event, 
					encumbrance, 
					encumbrance.made_date AS encumbered_date, 
					encumbrance.remarks AS remarks, 
					encumbrance_action, 
					encumbrance.encumbrance_id 
				FROM 
					identification, 
					collecting_event, 
					locality, 
					geog_auth_rec, 
					cataloged_item, 
					collection, 
					specimen_part, 
					coll_object_encumbrance, 
					encumbrance, 
					preferred_agent_name encumbering_agent,
					af_num
				WHERE 
					locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND 
					collecting_event.locality_id = locality.locality_id AND 
					cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
					cataloged_item.collection_object_id = identification.collection_object_id AND 
					identification.accepted_id_fg = 1 AND
					cataloged_item.collection_object_id = specimen_part.derived_from_cat_item (+) AND 
					cataloged_item.collection_id = collection.collection_id AND 
					cataloged_item.collection_object_id=coll_object_encumbrance.collection_object_id (+) AND 
					cataloged_item.collection_object_id=af_num.collection_object_id (+) AND 
					coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id (+) AND 
					encumbrance.encumbering_agent_id = encumbering_agent.agent_id (+) AND 
					cataloged_item.collection_object_id 
				IN 
					( #collection_object_id# ) 
				ORDER BY 
					cataloged_item.collection_object_id

			</cfquery>
		</cfoutput>
		<hr>
		<br><strong>Cataloged Items being encumbered:</strong>
			<table width="95%" border="1">
				<tr>
					<td><strong>Catalog Number</strong></td>
					<td><strong>AF Number</strong></td>
					<td><strong>Scientific Name</strong></td>
					<td><strong>Country</strong></td>
					<td><strong>State</strong></td>
					<td><strong>County</strong></td>
					<td><strong>Quad</strong></td>
					<td><strong>Part</strong></td>
					<td><strong>Existing Encumbrances</strong></td>
				</tr>
		<cfoutput query="getData" group="collection_object_id">
			<tr>
				<td>
					<a href="SpecimenDetail.cfm?collection_object_id=#collection_object_id#">
					#collection_cde#&nbsp;#cat_num#</a><br>
				</td>
				<td>#af_num#&nbsp;</td>
				<td><i>#Scientific_Name#</i></td>
				<td>#Country#&nbsp;</td>
				<td>#State_Prov#&nbsp;</td>
				<td>#county#&nbsp;</td>
				<td>#quad#&nbsp;</td>
				<td>
					<cfquery name="getParts" dbtype="query">
						SELECT 
							part_name, 
							partID
						FROM 
							getData 
						WHERE 
							collection_object_id = #collection_object_id# 
						GROUP BY
							part_name, 
							partID
					</cfquery>
					
					<cfloop query="getParts">
						<cfif len (#getParts.partID#) gt 0>
							#getParts.part_name#<br>
						</cfif>
					</cfloop>
					
				</td>
				<td>
					<cfquery name="encs" dbtype="query">
						select 
							collection_object_id,
							encumbrance_id,
							encumbrance,
							encumbrance_action,
							encumbering_agent,
							encumbered_date,
							expiration_date,
							expiration_event,
							remarks
						FROM getData
						WHERE 
							collection_object_id = #collection_object_id# 
						GROUP BY
							collection_object_id,
							encumbrance_id,
							encumbrance,
							encumbrance_action,
							encumbering_agent,
							encumbered_date,
							expiration_date,
							expiration_event,
							remarks
					</cfquery>
					<cfset e=1>
					<cfloop query="encs">
					
					<cfif len(#encumbrance#) gt 0>
						#encumbrance# (#encumbrance_action#) 
						by #encumbering_agent# made 
						#dateformat(encumbered_date,"dd mmm yyyy")#, 
						expires #dateformat(expiration_date,"dd mmm yyyy")# 
						#expiration_event# #remarks#<br>
						<form name="nothing#e#">
							<input type="button" 
								value="Delete Encumbrance" 
								class="delBtn"
								onmouseover="this.className='delBtn btnhov'"
								onmouseout="this.className='delBtn'"
								onClick="deleteEncumbrance(#encumbrance_id#,#encs.collection_object_id#);">
		
						</form>
					<cfelse>
						None
					</cfif> 
						<cfset e=#e#+1>
					</cfloop>
				</td>
			</tr>
		</cfoutput>
	</table>
</cfif>
<!------------------------------------------------------------------------------------------------------->	
<DIV ID="theCalendar" STYLE="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></DIV>
<div id="theFoot">
	<cfinclude template = "includes/_footer.cfm">
</div>
<script type="text/javascript" language="javascript">
	if (self != top) {
		changeStyle('#getItems.institution_acronym#');
		parent.dyniframesize();
		document.getElementById("theHead").style.display='none';
		document.getElementById("theFoot").style.display='none';
	}
</script>