<cfinclude template="includes/_header.cfm">
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		jQuery("#made_date_after").datepicker();
		jQuery("#made_date_before").datepicker();
		jQuery("#expiration_date_after").datepicker();
		jQuery("#made_date").datepicker();
		jQuery("#expiration_date_before").datepicker();
		jQuery("#expiration_date").datepicker();
	});
</script>
<cfif not isdefined("table_name")>
	<cfset table_name="">
</cfif>
<cfif not isdefined("collection_object_id")>
	<cfset collection_object_id="">
</cfif>
<cfquery name="ctEncAct" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select encumbrance_action from ctencumbrance_action order by encumbrance_action
</cfquery>
<!---------------------------------------------------------------------------->
<cfif action is "create">
	<strong><br>Create a new encumbrance.</strong>
	<cfset title="Create Encumbrance">
	<cfoutput>
		<form name="encumber" method="post" action="Encumbrances.cfm">
			<input type="hidden" name="action" value="createEncumbrance">
			<label for="encumberingAgent" class="likeLink" onclick="getDocs('encumbrance','encumbrancer')">
				Encumbering Agent
			</label>
			<input type="text" name="encumberingAgent" id="encumberingAgent" class="reqdClr"
				onchange="getAgent('encumberingAgentId','encumberingAgent','encumber',this.value); return false;"
			  	onKeyPress="return noenter(event);">
			<input type="hidden" name="encumberingAgentId" id="encumberingAgentId">
			<label for="made_date">Made Date</label>
			<input type="text" name="made_date" id="made_date" class="reqdClr">
			<label for="expiration_date" class="likeLink" onclick="getDocs('encumbrance','expiration')">
				Expiration Date
			</label>
			<input type="text" name="expiration_date" id="expiration_date">
	        <label for="expiration_event" class="likeLink" onclick="getDocs('encumbrance','expiration')">
				Expiration Event
			</label>
			<input type="text" name="expiration_event" id="expiration_event">
			<label for="encumbrance" class="likeLink" onclick="getDocs('encumbrance','encumbrance_name')">
				Encumbrance
			</label>
			<input type="text" name="encumbrance" id="encumbrance" size="50" class="reqdClr">
			<label for="encumbrance_action">Encumbrance Action</label>
	        <select name="encumbrance_action" id="encumbrance_action" size="1" class="reqdClr">
	            <cfloop query="ctEncAct">
	              <option value="#ctEncAct.encumbrance_action#">#ctEncAct.encumbrance_action#</option>
	            </cfloop>
	         </select>
			<label for="remarks">Remarks</label>
			<textarea name="remarks" rows="3" cols="50"></textarea>
			<br><input type="submit" value="Create New Encumbrance"	class="insBtn">
		</form>
	</cfoutput>
</cfif>
<!-------------------------------------------------->
<cfif action is "nothing">
	<cfoutput>
		<cfset title = "Search for specimens or encumbrances">
		<p>
			<cfif len(table_name) gt 0 or len(collection_object_id) gt 0>
				Now find an encumbrance to apply to the specimens below. If you need a new encumbrance, create it
				first then come back here.
			<cfelse>
				Locate Encumbrances (or <a href="/Encumbrances.cfm?action=create">Create a new encumbrance</a>)
			</cfif>
		</p>
		<cfform name="encumber" method="post" action="Encumbrances.cfm">
			<input type="hidden" name="Action" value="listEncumbrances">
			<input type="hidden" name="table_name" value="#table_name#">
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">
			<label for="">Encumbering Agent</label>
			<input name="encumberingAgent" id="encumberingAgent" type="text">
			<label for="made_date_after">Made Date After</label>
			<input type="text" name="made_date_after" id="made_date_after">
			<label for="made_date_before">Made Date Before</label>
			<input type="text" name="made_date_before" id="made_date_before">
			<label for="expiration_date_after">Expiration Date After</label>
			<input type="text" name="expiration_date_after" id="expiration_date_after">
			<label for="expiration_date_before">Expiration Date Before</label>
			<input type="text" name="expiration_date_before" id="expiration_date_before">
			<label for="expiration_event">Expiration Event</label>
			<input type="text" id="expiration_event" name="expiration_event">
			<label for="encumbrance">Encumbrance Event</label>
			<input type="text" name="encumbrance" id="encumbrance">
			<label for="encumbrance_action">Encumbrance Action</label>
			<select name="encumbrance_action" id="encumbrance_action" size="1">
				<option value=""></option>
				<cfloop query="ctEncAct">
					<option value="#ctEncAct.encumbrance_action#">#ctEncAct.encumbrance_action#</option>
				</cfloop>
			</select>
			<label for="remarks">Remarks</label>
			<textarea name="remarks" id="remarks" rows="3" cols="50"></textarea>
			<br><input type="submit" value="Find Encumbrance" class="schBtn">
		</cfform>
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------->
<cfif action is "createEncumbrance">
	<cfoutput>
		<cfquery name="nextEncumbrance" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select sq_encumbrance_id.nextval nextEncumbrance from dual
		</cfquery>
		<cfquery name="newEncumbrance" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO encumbrance (
				ENCUMBRANCE_ID,
				ENCUMBERING_AGENT_ID,
				ENCUMBRANCE,
				ENCUMBRANCE_ACTION
				<cfif len(#expiration_date#) gt 0>
					,EXPIRATION_DATE
				</cfif>
				<cfif len(#EXPIRATION_EVENT#) gt 0>
					,EXPIRATION_EVENT
				</cfif>
				<cfif len(#MADE_DATE#) gt 0>
					,MADE_DATE
				</cfif>
				<cfif len(#REMARKS#) gt 0>
					,REMARKS
				</cfif>
			) VALUES (
				#nextEncumbrance.nextEncumbrance#,
				#encumberingAgentId#,
				'#ENCUMBRANCE#',
				'#ENCUMBRANCE_ACTION#'
				<cfif len(#expiration_date#) gt 0>
					,'#dateformat(EXPIRATION_DATE,"yyyy-mm-dd")#'
				</cfif>
				<cfif len(#EXPIRATION_EVENT#) gt 0>
					,'#EXPIRATION_EVENT#'
				</cfif>
				<cfif len(#MADE_DATE#) gt 0>
					,'#dateformat(MADE_DATE,"yyyy-mm-dd")#'
				</cfif>
				<cfif len(#REMARKS#) gt 0>
					,'#REMARKS#'
				</cfif>
				)
		</cfquery>
		<cflocation url="Encumbrances.cfm?action=listEncumbrances&encumbrance_id=#nextEncumbrance.nextEncumbrance#" addtoken="false">
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------------->
<cfif action is "listEncumbrances">
	<cfset title="Encumbrance Search Results">
	<a href="Encumbrances.cfm">Back to Search Encumbrances</a>
	<br>
	<cfoutput>
		<cfset s="select
				encumbrance.encumbrance_id,
				encumbrance.encumbrance,
				encumbrance.encumbrance_action,
				preferred_agent_name.agent_name,
				encumbrance.made_date,
				encumbrance.expiration_date,
				encumbrance.expiration_event,
				encumbrance.remarks
			from
				encumbrance,
				preferred_agent_name">
		<cfset q = "
			WHERE
				encumbrance.encumbering_agent_id = preferred_agent_name.agent_id">
		<cfset sql=" ">
		<cfif isdefined("encumberingAgent") and len(encumberingAgent) gt 0>
			<cfset s=s & ",agent_name">
			<cfset q=q & " AND agent_name.agent_id=encumbrance.encumbering_agent_id ">
			<cfset sql = "#sql# AND upper(agent_name.agent_name) like '%#ucase(encumberingAgent)#%'">
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
		<cfif isdefined("encumbrance_id") and len(encumbrance_id) gt 0>
			<cfset sql = "#sql# AND encumbrance_id = #encumbrance_id#">
		</cfif>
		<cfif isdefined("encumbrance") and len(encumbrance) gt 0>
			<cfset sql = "#sql# AND upper(encumbrance) like '%#ucase(encumbrance)#%'">
		</cfif>
		<cfif isdefined("encumbrance_action") and len(encumbrance_action) gt 0>
			<cfset sql = "#sql# AND encumbrance_action = '#encumbrance_action#'">
		</cfif>
		<cfif isdefined("remarks") and len(remarks) gt 0>
			<cfset sql = "#sql# AND upper(remarks) like '%#ucase(remarks)#%'">
		</cfif>
		<cfset sql=s & q & sql & " group by encumbrance.encumbrance_id,
				encumbrance.encumbrance,
				encumbrance.encumbrance_action,
				preferred_agent_name.agent_name,
				encumbrance.made_date,
				encumbrance.expiration_date,
				encumbrance.expiration_event,
				encumbrance.remarks">
		<cfquery name="getEnc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#preservesinglequotes(sql)#
		</cfquery>
		<cfif getEnc.recordcount is 0>
			<div class="error">Nothing Found</div>
			<cfabort>
		</cfif>
		<cfset i = 1>
		<cfloop query="getEnc">
			<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
			<form name="listEnc#i#" method="post" action="Encumbrances.cfm">
				<input type="hidden" name="Action">
				<input type="hidden" name="encumbrance_id" value="#encumbrance_id#">
				<input type="hidden" name="table_name" value="#table_name#">
				<input type="hidden" name="collection_object_id" value="#collection_object_id#">
				#encumbrance# (#encumbrance_action#) by #agent_name# made #dateformat(made_date,"yyyy-mm-dd")#, expires #dateformat(expiration_date,"yyyy-mm-dd")# #expiration_event# #remarks#
				<br>
				<cfif len(table_name) gt 0 or len(collection_object_id) gt 0>
					<span class="likeLink" onclick="listEnc#i#.Action.value='saveEncumbrances';listEnc#i#.submit();">
						[ Add All Items To This Encumbrance ]
					</span>
					<span class="likeLink" onclick="listEnc#i#.Action.value='remListedItems';listEnc#i#.submit();">
						[ Remove Listed Items From This Encumbrance ]
					</span>
				</cfif>
				<span class="likeLink" onclick="listEnc#i#.Action.value='deleteEncumbrance';confirmDelete('listEnc#i#');">
					[ Delete This Encumbrance ]
				</span>
				<span class="likeLink" onclick="listEnc#i#.Action.value='updateEncumbrance';listEnc#i#.submit();">
					[ Modify This Encumbrance ]
				</span>
				<a href="/SpecimenResults.cfm?encumbrance_id=#encumbrance_id#">[ See Specimens ]</a>
				<a href="/Admin/deleteSpecByEncumbrance.cfm?encumbrance_id=#encumbrance_id#">[ Delete Encumbered Specimens ]</a>
			</form>
			</div>
			<cfset i = #i#+1>
		</cfloop>
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------------->
<cfif #Action# is "remListedItems">
	<cfoutput>
	<cfif len(encumbrance_id) is 0>
		Didn't get an encumbrance_id!!<cfabort>
	</cfif>
	<cfif len(table_name) is 0>
		Didn't get specimens - abort<cfabort>
	</cfif>

	<cfquery name="encSpecs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		DELETE FROM coll_object_encumbrance
		WHERE
		encumbrance_id = #encumbrance_id# AND
		collection_object_id in
		<cfif len(table_name) gt 0>
			(select collection_object_id from #table_name#)
		<cfelse>
			(#collection_object_id#)
		</cfif>
	</cfquery>

	<p>
		All items listed below have been removed from this encumbrance.
		 <a href="Encumbrances.cfm?action=listEncumbrances&encumbrance_id=#encumbrance_id#&table_name=#table_name#&collection_object_id=#collection_object_id#">Return to Encumbrance.</a>
	</p>
</cfoutput>
</cfif>


<!-------------------------------------------------------------------------------------------->
<cfif #Action# is "updateEncumbrance">
<cfset title = "Update Encumbrance">
<cfoutput>

<p><a href="Encumbrances.cfm?action=listEncumbrances&encumbrance_id=#encumbrance_id#">Back to Encumbrance</a></p>
Edit Encumbrance:
<cfquery name="encDetails" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
			<td><input type="hidden" name="encumberingAgentId" id="encumberingAgentId" value="#encumbering_agent_id#">

		<input type="text" name="encumberingAgent" class="reqdClr" value="#agent_name#"
		 onchange="getAgent('encumberingAgentId','encumberingAgent','updateEncumbrance',this.value); return false;"
		  onKeyPress="return noenter(event);">
		  </td>
			<td align="right">
				Made Date:
			</td>
			<td><input type="text" name="made_date" id="made_date" value="#dateformat(made_date,'yyyy-mm-dd')#"></td>
		</tr>
		<tr>
			<td align="right">
			<a href="javascript:void(0);"
				class="novisit"
				onClick="getDocs('encumbrance','expiration')">Expiration Date:</a>
				</td>
			<td><input type="text" name="expiration_date" id="expiration_date"  value="#dateformat(expiration_date,'yyyy-mm-dd')#"></td>
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


<cfquery name="newEncumbrance" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
UPDATE encumbrance SET
	encumbrance_id = #encumbrance_id#
	,ENCUMBERING_AGENT_ID = #encumberingAgentId#
	,ENCUMBRANCE = '#ENCUMBRANCE#'
	,ENCUMBRANCE_ACTION = '#ENCUMBRANCE_ACTION#'
	<cfif len(expiration_date) gt 0>
		,EXPIRATION_DATE = '#dateformat(EXPIRATION_DATE,"yyyy-mm-dd")#'
	<cfelse>
		,expiration_date=null
	</cfif>
	,EXPIRATION_EVENT = '#EXPIRATION_EVENT#'
	<cfif len(#MADE_DATE#) gt 0>
		,MADE_DATE = '#dateformat(MADE_DATE,'yyyy-mm-dd')#'
	</cfif>
	,REMARKS = '#REMARKS#'
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
	<cfquery name="isUsed" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) as cnt from coll_object_encumbrance where encumbrance_id=#encumbrance_id#
	</cfquery>
	<cfif #isUsed.cnt# gt 0>
		You can't delete this encumbrance because specimens are using it!<cfabort>
	</cfif>
	<cfquery name="deleteEnc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		DELETE FROM encumbrance WHERE encumbrance_id = #encumbrance_id#
	</cfquery>

	Deleted.

	<a href="Encumbrances.cfm">Return to Encumbrances</a>

</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------------->


<!-------------------------------------------------------------------------------------------->
<cfif #Action# is "saveEncumbrances">
<cfoutput>
	<cfif len(encumbrance_id) is 0>
		Didn't get an encumbrance_id!!<cfabort>
	</cfif>
	<cfif  len(table_name) is 0 and len(collection_object_id) is 0>
		Didn't get specimens<cfabort>
	</cfif>

	<cfquery name="unencumberedSpecimens" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		<cfif len(table_name) gt 0>
			select
				collection_object_id
			from
				#table_name#
			where
				collection_object_id not in (
					select
						collection_object_id
					from
						coll_object_encumbrance
					where
						encumbrance_id=#encumbrance_id#
				)
		<cfelse>
			select
				collection_object_id
			from
				cataloged_item
			where
				collection_object_id in ( #collection_object_id# ) and
				collection_object_id not in (
					select collection_object_id from coll_object_encumbrance where encumbrance_id=#encumbrance_id#
				)
		</cfif>
	</cfquery>
	<cfif unencumberedSpecimens.recordcount gt 1000>
		1000 record limit on creating encumbrances
		<cfabort>
	</cfif>
	<cftransaction>
		<cfloop query="unencumberedSpecimens">
			<cfquery name="encSpecs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO coll_object_encumbrance (encumbrance_id, collection_object_id) values (
					#encumbrance_id#,#unencumberedSpecimens.collection_object_id#)
			</cfquery>
		</cfloop>
	</cftransaction>


	<p>
		All items listed below have been encumbered.
		 <a href="Encumbrances.cfm?action=listEncumbrances&encumbrance_id=#encumbrance_id#&table_name=#table_name#&collection_object_id=#collection_object_id#">Return to Encumbrance.</a>
	</p>
</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------------->
<!-------------------------------------------------------------------------------------------->
<cfif len(table_name) gt 0 or len(collection_object_id) gt 0>

	<Cfset title = "Encumber these specimens">
		<cfoutput>
			<cfquery name="getData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				 SELECT
					flat.collection_object_id,
					flat.guid,
					flat.cat_num,
					concatSingleOtherId(flat.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
					flat.scientific_name,
					flat.higher_geog,
					flat.collection,
					flat.parts,
					getPreferredAgentName(encumbering_agent_id) encumbering_agent,
					expiration_date,
					expiration_event,
					encumbrance,
					encumbrance.made_date AS encumbered_date,
					encumbrance.remarks AS remarks,
					encumbrance_action,
					encumbrance.encumbrance_id
				FROM
					flat,
					coll_object_encumbrance,
					encumbrance
				WHERE
					flat.collection_object_id=coll_object_encumbrance.collection_object_id (+) AND
					coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id (+) AND
					flat.collection_object_id IN (
						<cfif len(table_name) gt 0>
							(select collection_object_id from #table_name#)
						<cfelse>
							( #collection_object_id# )
						</cfif>
					)
				ORDER BY
					flat.collection_object_id
			</cfquery>
		<hr>
		<br><strong>Cataloged Items being encumbered:</strong>
			<table width="95%" border="1">
				<tr>
					<td><strong>Specimen</strong></td>
					<td><strong>#session.CustomOtherIdentifier#</strong></td>
					<td><strong>Scientific Name</strong></td>
					<td><strong>Geog</strong></td>
					<td><strong>Parts</strong></td>
					<td><strong>Existing Encumbrances</strong></td>
				</tr>
						</cfoutput>
		<cfoutput query="getData" group="collection_object_id">
			<tr>
				<td>
					<a href="/guid/#guid#">#guid#</a>
				</td>
				<td>#CustomID#&nbsp;</td>
				<td><i>#Scientific_Name#</i></td>
				<td>#higher_geog#&nbsp;</td>
				<td>
					#parts#
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
						#dateformat(encumbered_date,"yyyy-mm-dd")#,
						expires #dateformat(expiration_date,"yyyy-mm-dd")#
						#expiration_event# #remarks#<br>
						<form name="nothing#e#">
							<input type="button"
								value="Remove This Encumbrance"
								class="delBtn"
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
<cfinclude template = "includes/_footer.cfm">
<cf_customizeIFrame>