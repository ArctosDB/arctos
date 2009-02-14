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
	<cfquery name="ctcoll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection,collection_id from collection order by collection
	</cfquery>
	<cfquery name="ctStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select accn_status from ctaccn_status order by accn_status
	</cfquery>
	<cfquery name="ctType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select accn_type from ctaccn_type order by accn_type
	</cfquery>
	<cfset thisDate = #dateformat(now(),"dd-mmm-yyyy")#>
	<form action="newAccn.cfm" method="post" name="newAccn">
		<input type="hidden" name="Action" value="createAccession">
		<table>
			<tr>
				<td valign="top">
					<table class="newRec">
						<tr>
							<td colspan="6">
								Create Accession
							</td>
						</tr>
						<tr>
							<td>
								<label for="collection_id">Collection:</label>
								<select name="collection_id" size="1" id="collection_id" class="reqdClr">
										<option selected value="">Pick One...</option>
										<cfloop query="ctcoll">
											<option value="#ctcoll.collection_id#">#ctcoll.collection#</option>
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
					<table border="1">
						<tr>
							<td>Collection</td>
							<td>Next Number</td>
						</tr>
						<cfquery name="all_coll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							select * from collection order by collection
						</cfquery>
						<cfloop query="all_coll">
							<cfif (institution_acronym is 'UAM' and collection_cde is 'Mamm') or
									(institution_acronym is 'MSB' and collection_cde is 'Mamm') or
									(institution_acronym is 'MSB' and collection_cde is 'Bird') or
									(institution_acronym is 'UAM' and collection_cde is 'Fish')>
								<cfset stg="'#dateformat(now(),"yyyy")#.' || lpad(max(to_number(substr(accn_number,6,3))) + 1,3,0) || '.#collection_cde#'">
								<cfset whr=" AND accn_number like '%.#collection_cde#' AND
									trans.institution_acronym='#institution_acronym#' and
									substr(accn_number,1,4) = '#dateformat(now(),"yyyy")#'">
							<cfelseif (institution_acronym is 'UAM' and collection_cde is 'ES')>
								<cfset stg="'#dateformat(now(),"yyyy")#.' || lpad(max(to_number(substr(accn_number,6,3))) + 1,3,0) || '.ESCI'">
								<cfset whr=" AND accn_number like '%.ESCI'">
							<cfelse>
								<cfset stg="max(to_number(accn_number)) + 1">
								<cfset whr=" AND is_number(accn_number)=1">
							</cfif>
							<cftry>
								<cfquery name="thisq" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
									select 
										 #preservesinglequotes(stg)# nn 
									from 
										accn,
										trans,
										collection
									where 
										accn.transaction_id=trans.transaction_id and
										trans.collection_id=collection.collection_id 
										<cfif institution_acronym is not "MVZ" and institution_acronym is not "MVZObs">
										and
										collection.collection_id=#collection_id#
										</cfif>
										#preservesinglequotes(whr)#
								</cfquery>
								<cfcatch>
									<hr>
									#cfcatch.detail#
									<br>
									#cfcatch.sql#
									<cfquery name="thisq" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
										select 
											 'check data' nn 
										from 
											dual
									</cfquery>
								</cfcatch>
							</cftry>
							<tr>
								<td>#collection#</td>
								<td>
									<cfif len(thisq.nn) is 0>
										check data
									<cfelse>
										<span class="likeLink" 
											onclick="document.getElementById('collection_id').value='#collection_id#';
											document.getElementById('accn_number').value='#thisq.nn#';">
											#thisq.nn#
										</span>
									</cfif>
									
								</td>
									
							</tr>
						</cfloop>
					</table>
				</td>
			</tr>
		</table>
	</form>
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "createAccession">
	<cfoutput>
		<cftransaction>
			<cfquery name="n" datasource="user_login" username="#session.username#" password="#decrypt(session.epw,cfid)#">
				select sq_transaction_id.nextval n from dual
			</cfquery>
			<cfquery name="newTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO trans (
					TRANSACTION_ID,
					TRANS_DATE,
					CORRESP_FG,
					collection_id,
					TRANSACTION_TYPE
					<cfif len(#NATURE_OF_MATERIAL#) gt 0>
						,NATURE_OF_MATERIAL
					</cfif>
					<cfif len(#REMARKS#) gt 0>
						,TRANS_REMARKS
					</cfif>)
				VALUES (
					#n.n#,
					'#dateformat(ent_Date,"dd-mmm-yyyy")#',
					#correspFg#,
					'#collection_id#',
					'accn'
					<cfif len(#NATURE_OF_MATERIAL#) gt 0>
						,'#NATURE_OF_MATERIAL#'
					</cfif>
					<cfif len(#REMARKS#) gt 0>
						,'#REMARKS#'
					</cfif>)
				</cfquery>
				<cfquery name="newAccn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					INSERT INTO accn (
						TRANSACTION_ID,
						ACCN_TYPE
						,accn_number
						,RECEIVED_DATE,
						ACCN_STATUS       
						)
					VALUES (
						#n.n#,
						'#accn_type#'
						,'#accn_number#'
						,'#dateformat(rec_date,"dd-mmm-yyyy")#',
						'#accn_status#' 
						)
				</cfquery>
				<cfquery name="newAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					insert into trans_agent (
						transaction_id,
						agent_id,
						trans_agent_role
					) values (
						#n.n#,
						#received_agent_id#,
						'received from'
					)
				</cfquery>
				<cfif len(#trans_agency_id#) gt 0>
					<cfquery name="newAgent" datasource="user_login" username="#session.username#" password="#decrypt(session.epw,cfid)#">
						insert into trans_agent (
							transaction_id,
							agent_id,
							trans_agent_role
						) values (
							#n.n#,
							#trans_agency_id#,
							'associated with agency'
						)
					</cfquery>
				</cfif>
				
		</cftransaction>
		<cflocation url="editAccn.cfm?Action=edit&transaction_id=#n.n#">		
  </cfoutput>
</cfif>
<DIV ID="theCalendar" STYLE="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></DIV>
<cfinclude template="includes/_footer.cfm">