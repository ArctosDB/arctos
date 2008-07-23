<cfinclude template = "includes/_header.cfm">

<script language="JavaScript" src="includes/CalendarPopup.js" type="text/javascript"></script>
<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
	var cal1 = new CalendarPopup("theCalendar");
	cal1.showYearNavigation();
	cal1.showYearNavigationInput();
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript" type="text/javascript">document.write(getCalendarStyles());</SCRIPT>


<cfquery name="ctEncAct" datasource="#Application.web_user#">
	select encumbrance_action from ctencumbrance_action
</cfquery>

<strong>
	<br>Create a new encumbrance.
</strong>
<cfoutput>
<form name="encumber" method="post" action="newEncumbrance.cfm">
	<input type="hidden" name="Action" value="createEncumbrance">
	
	<table>
      <tr> 
        <td><div align="right"><a href="javascript:void(0);" 
				class="novisit" 
				onClick="getDocs('encumbrance','encumbrancer')">Encumbering Agent:</a></div></td>
        <td colspan="3">
		
		<input type="text" name="encumberingAgent" class="reqdClr"
		 onchange="getAgent('encumberingAgentId','encumberingAgent','encumber',this.value); return false;"
		  onKeyPress="return noenter(event);">
		  <input type="hidden" name="encumberingAgentId"> 
		
        </td>
      </tr>
      <tr> 
        <td> <div align="right">Made Date: </div></td>
        <td><input type="text" name="made_date">
		<span class="infoLink"
				name="anchor1"
				id="anchor1"
				onClick="cal1.showCalendar('anchor1'); 
					cal1.select(document.encumber.made_date,'anchor1','d NNN yyyy'); 
						return false;">
					Pick
			</span>
		</td>
      </tr>
      <tr> 
        <td><div align="right"><a href="javascript:void(0);" 
				class="novisit" 
				onClick="getDocs('encumbrance','expiration')">Expiration Date:</a></div></td>
        <td><input type="text" name="expiration_date">
		<span class="infoLink"
				name="anchor2"
				id="anchor2"
				onClick="cal1.showCalendar('anchor2'); 
					cal1.select(document.encumber.expiration_date,'anchor2','d NNN yyyy'); 
						return false;">
					Pick
			</span>
		</td>
        <td><div align="right"><a href="javascript:void(0);" 
				class="novisit" 
				onClick="getDocs('encumbrance','expiration')">Expiration Event:</a></div></td>
        <td><input type="text" name="expiration_event"></td>
      </tr>
      <tr> 
        <td><div align="right"><a href="javascript:void(0);" 
				class="novisit" 
				onClick="getDocs('encumbrance','encumbrance_name')">Encumbrance:</a></div></td>
        <td><input type="text" name="encumbrance"></td>
        <td><div align="right">Encumbrance Action</div></td>
        <td><select name="encumbrance_action" size="1">
            <cfloop query="ctEncAct">
              <option value="#ctEncAct.encumbrance_action#">#ctEncAct.encumbrance_action#</option>
            </cfloop>
          </select></td>
      </tr>
      <tr> 
        <td><div align="right">Remarks:</div></td>
        <td colspan="3"><textarea name="remarks" rows="3" cols="50"></textarea></td>
      </tr>
      <tr> 
        <td colspan="4"><div align="center">
		<input type="submit" 
			value="Create New Encumbrance"
			class="insBtn"
			onmouseover="this.className='insBtn btnhov'" />
										
          </div></td>
      </tr>
    </table>
</form>
</cfoutput>

<!-------------------------------------------------------------------------------------------->

<!-------------------------------------------------------------------------------------------->
<cfif #Action# is "createEncumbrance">
	
	<cfoutput>
<cfquery name="nextEncumbrance" datasource="#Application.web_user#">
	select max(encumbrance_id) +1 as nextEncumbrance from encumbrance
</cfquery>

<cfquery name="newEncumbrance" datasource="user_login" username="#session.username#" password="#decrypt(session.epw,cfid)#">
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
	
	)
VALUES (
	#nextEncumbrance.nextEncumbrance#,
	#encumberingAgentId#,
	'#ENCUMBRANCE#',
	'#ENCUMBRANCE_ACTION#'
	<cfif len(#expiration_date#) gt 0>
		,'#dateformat(EXPIRATION_DATE,"dd-mmm-yyyy")#'
	</cfif>
	<cfif len(#EXPIRATION_EVENT#) gt 0>
		,'#EXPIRATION_EVENT#'
	</cfif>
	<cfif len(#MADE_DATE#) gt 0>
		,'#dateformat(MADE_DATE,"dd-mmm-yyyy")#'
	</cfif>
	<cfif len(#REMARKS#) gt 0>
		,'#REMARKS#'
	</cfif>
	)
</cfquery>

<br>New encumbrance created: 
	<blockquote>
		<br>ID: #nextEncumbrance.nextEncumbrance#
		<br>Agent ID: #encumberingAgentId#
		<br>Encumbrance: #ENCUMBRANCE#'
		<br>Action: #ENCUMBRANCE_ACTION#
		<cfif len(#expiration_date#) gt 0>
			<br>Expires: #dateformat(EXPIRATION_DATE,"dd-mmm-yyyy")#
		</cfif>
		<cfif len(#EXPIRATION_EVENT#) gt 0>
			<br>Expires: #EXPIRATION_EVENT#
		</cfif>
		<cfif len(#MADE_DATE#) gt 0>
			<br>Made Date: #dateformat(MADE_DATE,"dd-mmm-yyyy")#
		</cfif>
		<cfif len(#REMARKS#) gt 0>
			<br>Remarks: #REMARKS#
		</cfif>
	</blockquote>
	<br>Create another encumbrance or close this window/use your BACK button to add items to existing encumbrances.
	 </cfoutput>
</cfif>
	 
	 
	 
	 
	 
	 <!---     
	<cfif len(#encumberingAgent#) gt 0>
		<cfset sql = "#sql# AND upper(agent_name) like '#ucase(encumberingAgent)#'">	
	</cfif>
	<cfif len(#made_date#) gt 0>
		<cfset sql = "#sql# AND upper(made_date) like '%#ucase(made_date)#%'">	
	</cfif>
	<cfif len(#expiration_date#) gt 0>
		<cfset sql = "#sql# AND upper(expiration_date) like '%#ucase(expiration_date)#%'">	
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
	
	<cfquery name="getEnc" datasource="#Application.web_user#">
		#preservesinglequotes(sql)#
	</cfquery>
	</cfoutput>
	<cfoutput query="getEnc">
		<br>
		<form name="encs" method="post" action="Encumbrances.cfm">
			<input type="hidden" name="Action" value="saveEncumbrances">
			<input type="hidden" name="encumbrance_id" value="#encumbrance_id#">
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">
			#encumbrance# (#encumbrance_action#) by #agent_name# made #dateformat(made_date,"dd mmm yyyy")#, expires #dateformat(expiration_date,"dd mmm yyyy")# #expiration_event# #remarks#
			<br><input type="submit" value="Add All Items To This Encumbrance">
			
		</form>
		
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
	<br>INSERT INTO coll_object_encumbrance (encumbrance_id, collection_object_id)
		VALUES (#encumbrance_id#, #i#)
	</cfloop>
</cfoutput>	
</cfif>
<!-------------------------------------------------------------------------------------------->



<!-------------------------------------------------------------------------------------------->
<cfoutput>

<cfquery name="getData" datasource="#Application.web_user#">
 SELECT 
 	cataloged_item.collection_object_id as collection_object_id, 
	cat_num, 
	af_num, 
	scientific_name, 
	country, 
	state_prov, 
	county, 
	cataloged_item.collection_object_id, 
	quad, 
	institution_acronym, 
	collection.collection_cde, 
	part_name, 
	specimen_part.collection_object_id as partID, 
	tissue_type, 
	tissue_sample.collection_object_id as tissueID, 
	encumbering_agent.agent_name as encumbering_agent, 
	expiration_date, expiration_event, encumbrance, encumbrance.made_date as encumbered_date, encumbrance.remarks as remarks, encumbrance_action, encumbrance.encumbrance_id FROM identification, collecting_event, locality, geog_auth_rec, cataloged_item, taxonomy, collection, specimen_part, tissue_sample, coll_object_encumbrance, encumbrance, agent_name encumbering_agent WHERE locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND collecting_event.locality_id = locality.locality_id AND cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND identification.taxon_name_id = taxonomy.taxon_name_id AND cataloged_item.accepted_identification_id = identification.identification_id AND cataloged_item.collection_object_id = specimen_part.derived_from_biol_indv (+) AND cataloged_item.collection_object_id = tissue_sample.DERIVED_FROM_BIOL_INDIV (+) AND cataloged_item.collection_id = collection.collection_id AND cataloged_item.collection_object_id=coll_object_encumbrance.collection_object_id (+) AND coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id (+) AND encumbrance.encumbering_agent_id = encumbering_agent.agent_id (+) AND 
	cataloged_item.collection_object_id IN ( #collection_object_id# ) ORDER BY cataloged_item.collection_object_id

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
		<a href="SpecimenDetail.cfm?collection_object_id=#collection_object_id#">#collection_cde#&nbsp;#cat_num#</a><br>
	</td>
	<td>
		#af_num#&nbsp;
	</td>
	<td><i>#Scientific_Name#</i></td>
	<td>#Country#&nbsp;</td>
	<td>#State_Prov#&nbsp;</td>
	<td>
		#county#&nbsp;
	</td>
	<td>
		#quad#&nbsp;
	</td>
	<td>

	<cfquery name="getParts" dbtype="query">
		select part_name, partID
		from getData where collection_object_id = #collectioN_object_id# group by part_name, partID
	</cfquery>
	<cfquery name="getTissue" dbtype="query">
		select tissue_type, tissueID
		from getData where collection_object_id = #collectioN_object_id# group by tissue_type, tissueID
	</cfquery>
	
	<cfloop query="getParts">
		<cfif len (#getParts.partID#) gt 0>
			#getParts.part_name#<br>
		</cfif>
	</cfloop>
	<cfloop query="getTissue">
		<cfif len (#getTissue.tissueID#) gt 0>
			#getTissue.tissue_type#&nbsp;
		</cfif>
	</cfloop>
</td>
<td>
	<cfif len(#encumbrance#) gt 0>
		#encumbrance# (#encumbrance_action#) 
		by #encumbering_agent# made 
		#dateformat(encumbered_date,"dd mmm yyyy")#, 
		expires #dateformat(expiration_date,"dd mmm yyyy")# 
		#expiration_event# #remarks#<br>
		<img src="images/check.gif" onClick="deleteEncumbrance(#encumbrance_id#,#collection_object_id#);">
	deleteEncumbrance(#encumbrance_id#,#collection_object_id#);
	<cfelse>
		None
	</cfif> 
</td>



	</tr>
</cfoutput>
</table>
	--->
<DIV ID="theCalendar" STYLE="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></DIV>
<cfinclude template = "includes/_footer.cfm">