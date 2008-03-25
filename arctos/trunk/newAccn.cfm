<cfinclude template="includes/_header.cfm">
	<script language="JavaScript" src="includes/CalendarPopup.js" type="text/javascript"></script>
	<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
		var cal1 = new CalendarPopup("theCalendar");
		cal1.showYearNavigation();
		cal1.showYearNavigationInput();
	</SCRIPT>
	<SCRIPT LANGUAGE="JavaScript" type="text/javascript">document.write(getCalendarStyles());</SCRIPT>
<cfset title = "Create Accession">
<cfif #action# is "nothing">
<cfoutput>
		<cfquery name="ctcoll" datasource="#Application.web_user#">
				select collection_cde from ctcollection_cde
			</cfquery>
			<cfquery name="ctStatus" datasource="#Application.web_user#">
				select accn_status from ctaccn_status
			</cfquery>
			<cfquery name="ctType" datasource="#Application.web_user#">
				select accn_type from ctaccn_type
			</cfquery>
			<cfquery name="ctInst" datasource="#Application.web_user#">
				select distinct(institution_acronym)  from collection
			</cfquery>
			<cfset thisDate = #dateformat(now(),"dd-mmm-yyyy")#>
					
<form action="newAccn.cfm" method="post" name="newAccn">
<input type="hidden" name="Action" value="createAccession">
<table>
<tr>
<td>
<table class="newRec">
	<tr>
		<td colspan="6">
			Create Accession
		</td>
	</tr>
	<tr>
		<td>
			<label for="institution_acronym">Institution:</label>
			<select name="institution_acronym" size="1" id="institution_acronym" class="reqdClr">
					<option selected value="">Pick One...</option>
					<cfloop query="ctInst">
						<option value="#ctInst.institution_acronym#">#ctInst.institution_acronym#</option>
					</cfloop>
			</select>
		</td>
		<td>
			<label for="accn_number">Accn Number:</label>
			<input type="text" name="accn_number" id="accn_number" class="reqdClr">
		</td>
		<td>
			<label for="accn_status">Status:</label>
			<select name="accn_status" size="1" class="reqdClr">
				<cfloop query="ctStatus">
					<option 
						<cfif #ctStatus.accn_status# is "in process">selected </cfif>
						value="#ctStatus.accn_status#">#ctStatus.accn_status#</option>
				</cfloop>
			</select>
		</td>
		<td>
			<label for="rec_date">Rec. Date:</label>
			<input type="text" name="rec_date" class="reqdClr">
			<img src="images/pick.gif" 
						class="likeLink" 
						border="0" 
						alt="[calendar]"
						name="anchor1"
						id="anchor1"
						onClick="cal1.select(document.newAccn.rec_date,'anchor1','dd-MMM-yyyy'); return false;"/>			
		</td>
	</tr>
	<tr>
		<td colspan="9">
			<label for="nature_of_material">Nature of Material:</label>
			<textarea name="nature_of_material" rows="5" cols="90" class="reqdClr"></textarea>
		</td>		
	</tr>
	<tr>
		<td colspan="2">
			<label for="rec_agent">Received From:</label>
			<input type="text" name="rec_agent" class="reqdClr" 
				onchange="getAgent('received_agent_id','rec_agent','newAccn',this.value); return false;"
			 	onKeyPress="return noenter(event);">
			<input type="hidden" name="received_agent_id">
		</td>
		<td colspan="2">
			<label for="rec_agent">From Agency:</label>
			<input type="text" name="trans_agency"
				onchange="getAgent('trans_agency_id','trans_agency','newAccn',this.value); return false;"
			 	onKeyPress="return noenter(event);">
			<input type="hidden" name="trans_agency_id">
		</td>
		<td colspan="2">
			<label for="accn_type">How Obtained?</label>
			<select name="accn_type" size="1"  class="reqdClr">
				<cfloop query="cttype">
					<option value="#cttype.accn_type#">#cttype.accn_type#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td colspan="6">
			<label for="remarks">Remarks:</label>
			<textarea name="remarks" rows="5" cols="90"></textarea>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td colspan="2">
			<label for="ent_Date">Entry Date:</label>
			<input type="text" name="ent_Date"  value="#thisDate#">
		</td>
		<td colspan="2">
			<label for="">Has Correspondence?</label>
			<select name="correspFg">
				<option value="1">Yes</option>
				<option value="0">No</option>
			</select>
		</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td colspan="6" align="center">
		<input type="submit" 
				value="Save this Accession" 
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'" 
				onmouseout="this.className='savBtn'">
				
		<input type="button" 
				value="Quit without saving" 
				class="qutBtn"
				onmouseover="this.className='qutBtn btnhov'" 
				onmouseout="this.className='qutBtn'"
				onClick="document.location = 'editAccn.cfm'">
				
		</td>
	</tr>
</table>
</td>
<td valign="top">
<cfif #cgi.HTTP_HOST# contains "database.museum">
	<cfquery name="uam_mamm" datasource="#Application.web_user#">
		select lpad(max(to_number(substr(accn_number,6,3))) + 1,3,0) nn from accn,trans where
		accn.transaction_id = trans.transaction_id and
		substr(accn_number,1,4)='#dateformat(now(),"yyyy")#' and
		institution_acronym='UAM' and
		substr(accn_number,10,4)='Mamm'
	</cfquery>
	<cfquery name="msb_mamm" datasource="#Application.web_user#">
		select lpad(max(to_number(substr(accn_number,6,3))) + 1,3,0) nn from accn,trans where
		accn.transaction_id = trans.transaction_id and
		substr(accn_number,1,4)='#dateformat(now(),"yyyy")#' and
		institution_acronym='MSB' and
		substr(accn_number,10,4)='Mamm'
	</cfquery>
	<cfquery name="msb_bird" datasource="#Application.web_user#">
		select lpad(max(to_number(substr(accn_number,6,3))) + 1,3,0) nn from accn,trans where
		accn.transaction_id = trans.transaction_id and
		substr(accn_number,1,4)='#dateformat(now(),"yyyy")#' and
		institution_acronym='MSB' and
		substr(accn_number,10,4)='Bird'
	</cfquery>
	
	<table border="1">
		<tr>
			<td>Collection</td>
			<td>Next Number</td>
		</tr>
		<tr>
			<td>UAM Mammal</td>
			<td><span class="likeLink" onclick="document.getElementById('institution_acronym').value='UAM';document.getElementById('accn_number').value='#dateformat(now(),"yyyy")#.#uam_mamm.nn#.Mamm';">
				#dateformat(now(),"yyyy")#.#uam_mamm.nn#.Mamm
				</span>
			</td>
				
		</tr>
		<tr>
			<td>MSB Mammal</td>
			<td>
				<span class="likeLink" onclick="document.getElementById('institution_acronym').value='MSB';document.getElementById('accn_number').value='#dateformat(now(),"yyyy")#.#msb_mamm.nn#.Mamm';">
				#dateformat(now(),"yyyy")#.#msb_mamm.nn#.Mamm
				</span>
			</td>
		</tr>
		<tr>
			<td>MSB Bird</td>
			<td>
				<span class="likeLink" onclick="document.getElementById('institution_acronym').value='MSB';document.getElementById('accn_number').value='#dateformat(now(),"yyyy")#.#msb_bird.nn#.Bird';">
				#dateformat(now(),"yyyy")#.#msb_bird.nn#.Bird
				</span>
			</td>
		</tr>
	</table>
<cfelseif #cgi.HTTP_HOST# contains "harvard.edu">
	<cfquery name="mcz" datasource="#Application.web_user#">
		select max(to_number(accn_number)) + 1 as nn from accn
	</cfquery>
	<table border="1">
		<tr>
			<td>Collection</td>
			<td>Next Number</td>
		</tr>
		<tr>
			<td>MCZ</td>
			<td><span class="likeLink" onclick="document.getElementById('institution_acronym').value='MCZ';document.getElementById('accn_number').value='#mcz.nn#';">
				#mcz.nn#
				</span>
			</td>
		</tr>
	</table>
<cfelse>
	<cfquery name="mvz" datasource="#Application.web_user#">
		select max(to_number(accn_number)) + 1 as nn from accn
	</cfquery>
	<table border="1">
		<tr>
			<td>Collection</td>
			<td>Next Number</td>
		</tr>
		<tr>
			<td>MVZ</td>
			<td><span class="likeLink" onclick="document.getElementById('institution_acronym').value='MVZ';document.getElementById('accn_number').value='#mvz.nn#';">
				#mvz.nn#
				</span>
			</td>
				
		</tr>
	</table>
</cfif>
</td>
</tr>
</table>
</form>
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "createAccession">
	<cfoutput>
		
			<cfif not #isdate(rec_date)# OR NOt #isdate(ent_Date)#>
				Entry data and received date must be in date format.
				<cfabort>
			</cfif>
			
		<cfquery name="nextTrans" datasource="#Application.web_user#">
			select max(transaction_id) + 1 as nextTrans from trans
		</cfquery>
		<cfquery name="TRANS_ENTERED_AGENT_ID" datasource="#Application.web_user#">
			select agent_id from agent_name where agent_name = '#client.username#'
		</cfquery>
		
		
	
	<cftransaction>
	
		<cfquery name="newTrans" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		INSERT INTO trans (
			TRANSACTION_ID,
			TRANS_DATE,
			CORRESP_FG,
			institution_acronym,
			TRANSACTION_TYPE
			<cfif len(#NATURE_OF_MATERIAL#) gt 0>
				,NATURE_OF_MATERIAL
			</cfif>
			<cfif len(#REMARKS#) gt 0>
				,TRANS_REMARKS
			</cfif>
			<cfif len(#trans_agency_id#) gt 0>
				,trans_agency_id
			</cfif> )
		VALUES (
			#nextTrans.nextTrans#,
			'#dateformat(ent_Date,"dd-mmm-yyyy")#',
			#correspFg#,
			'#institution_acronym#',
			'accn'
			<cfif len(#NATURE_OF_MATERIAL#) gt 0>
				,'#NATURE_OF_MATERIAL#'
			</cfif>
			<cfif len(#REMARKS#) gt 0>
				,'#REMARKS#'
			</cfif> 
			<cfif len(#trans_agency_id#) gt 0>
				,#trans_agency_id#
			</cfif>)
		</cfquery>
		
		<cfquery name="newAccn" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		INSERT INTO accn (
			TRANSACTION_ID,
			ACCN_TYPE
			,accn_number
			,RECEIVED_DATE,
			ACCN_STATUS       
			)
		VALUES (
			#nextTrans.nextTrans#,
			'#accn_type#'
			,'#accn_number#'
			,'#dateformat(rec_date,"dd-mmm-yyyy")#',
			'#accn_status#' 
			)
		</cfquery>
		<cfquery name="newAgent" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			insert into trans_agent (
				transaction_id,
				agent_id,
				trans_agent_role
			) values (
				#nextTrans.nextTrans#,
				#received_agent_id#,
				'received from'
			)
		</cfquery>
	  </cftransaction>
		
		
		
		<cflocation url="editAccn.cfm?Action=edit&transaction_id=#nextTrans.nextTrans#">
	
		
  </cfoutput>
</cfif>
<DIV ID="theCalendar" STYLE="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></DIV>
<cfinclude template="includes/_footer.cfm">