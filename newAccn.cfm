<cfinclude template="includes/_header.cfm">
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		$(".reqdClr:visible").each(function(e){
		    $(this).prop('required',true);
		});
		$("#rec_date").datepicker();
		$("#ent_Date").datepicker();
		$("#newAccn").submit(function(event){
			// just call the function - it will prevent submission if necessary
			checkReplaceNoPrint(event,'nature_of_material');
			checkReplaceNoPrint(event,'remarks');
		});
	});
</script>
<cfset title = "Create Accession">
<cfif #action# is "nothing">
<cfoutput>
	<cfquery name="ctcoll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select guid_prefix,collection_id from collection order by guid_prefix
	</cfquery>
	<cfquery name="ctStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select accn_status from ctaccn_status order by accn_status
	</cfquery>
	<cfquery name="ctType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select accn_type from ctaccn_type order by accn_type
	</cfquery>
	<cfset thisDate = #dateformat(now(),"yyyy-mm-dd")#>
	<form action="newAccn.cfm" method="post" name="newAccn" id="newAccn">
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
											<option value="#ctcoll.collection_id#">#ctcoll.guid_prefix#</option>
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
								<input type="text" name="rec_date" id="rec_date" class="reqdClr">
							</td>
						</tr>
						<tr>
							<td colspan="9">
								<label for="nature_of_material">Nature of Material:</label>
								<textarea name="nature_of_material" id="nature_of_material" rows="5" cols="90" class="reqdClr"></textarea>
							</td>
						</tr>
						<tr>
							<td>
								<label for="rec_agent">Received From:</label>
								<input type="text" name="rec_agent" class="reqdClr"
									onchange="getAgent('received_agent_id','rec_agent','newAccn',this.value); return false;"
								 	onKeyPress="return noenter(event);">
								<input type="hidden" name="received_agent_id">
							</td>
							<td>
								<label for="rec_agent">From Agency:</label>
								<input type="text" name="trans_agency"
									onchange="getAgent('trans_agency_id','trans_agency','newAccn',this.value); return false;"
								 	onKeyPress="return noenter(event);">
								<input type="hidden" name="trans_agency_id">
							</td>
							<td>
								<label for="accn_type">How Obtained?</label>
								<select name="accn_type" size="1"  class="reqdClr">
									<cfloop query="cttype">
										<option value="#cttype.accn_type#">#cttype.accn_type#</option>
									</cfloop>
								</select>
							</td>
							<td>
								<label for="estimated_count" class="helpLink" data-helplink="estimated_count">Est. Cnt.</label>
								<input type="text" id="estimated_count" name="estimated_count">
							</td>
						</tr>
						<tr>
							<td colspan="6">
								<label for="remarks">Remarks:</label>
								<textarea name="remarks" id="remarks" rows="5" cols="90"></textarea>
							</td>
						</tr>
						<tr>
							<td>&nbsp;</td>
							<td colspan="2">
								<label for="ent_Date">Entry Date:</label>
								<input type="text" name="ent_Date" id="ent_Date" value="#thisDate#">
							</td>
							<td>
								<label for="">Has Correspondence?</label>
								<select name="correspFg">
									<option value="1">Yes</option>
									<option value="0">No</option>
								</select>
							</td>
							<td>
								<label for="is_public_fg">Public?</label>
								<select name="is_public_fg">
									<option value="1">public</option>
									<option selected="selected" value="0">private</option>
								</select>
							</td>
							<td>&nbsp;</td>
						</tr>
						<tr>
							<td colspan="6" align="center">
							<input type="submit"
								value="Save this Accession"
								class="savBtn">
							<input type="button"
									value="Quit without saving"
									class="qutBtn"
									onClick="document.location = 'editAccn.cfm'">

							</td>
						</tr>
					</table>
				</td>
				<td valign="top">
					<label for=""><a href="/contact.cfm">Contact us</a> to request collection-specific next accession number suggestions.</label>
					<table id="sugnTabl" border="1">
						<tr>
							<td>Collection</td>
							<td>Next Number</td>
						</tr>
						<cfquery name="all_coll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							select * from collection order by guid_prefix
						</cfquery>
						<cfloop query="all_coll">
							<cfif (institution_acronym is 'UAM' and collection_cde is 'Mamm') or
									(institution_acronym is 'MSB' and collection_cde is 'Mamm') or
									(institution_acronym is 'MSB' and collection_cde is 'Bird') or
									(institution_acronym is 'UAM' and collection_cde is 'Fish')>
								<!---- these collections use a YYYY.001.COLLECTIONCODE format --->
								<cfset stg="'#dateformat(now(),"yyyy")#.' || nvl(lpad(max(to_number(substr(accn_number,6,3))) + 1,3,0),'001') || '.#collection_cde#'">
								<cfset whr=" AND accn_number like '%.#collection_cde#' AND
									substr(accn_number,1,4) = '#dateformat(now(),"yyyy")#'">
							<cfelseif (institution_acronym is 'UAM' and collection_cde is 'Ento')>
								<!--- unpredictable format, but want to know what the last accession created was ---->
								<cfset stg="'last was ' || accn_number">
								<cfset whr=" AND accn.transaction_id = (select max(transaction_id) from accn where accn_number like '%Ento')">
							<cfelseif (institution_acronym is 'UAM' and collection_cde is 'ES')>
								<!---- Earth Science uses a wonky suffix rather than collection code ---->
								<cfset stg="'#dateformat(now(),"yyyy")#.' || lpad(max(to_number(substr(accn_number,6,3))) + 1,3,0) || '.ESCI'">
								<cfset whr=" AND accn_number like '%.ESCI'">
							<cfelseif institution_acronym is 'MVZ' or institution_acronym is "MVZObs">
								<!--- MVZ collections share accessions ---->
								<cfset stg="max(to_number(accn_number)) + 1">
								<cfset whr=" AND is_number(accn_number)=1">

							<cfelseif institution_acronym is 'CUMV'>
								<!--- MVZ collections share accessions ---->
								<cfset stg="max(to_number(accn_number)) + 1">
								<cfset whr=" AND is_number(accn_number)=1">

							<cfelseif institution_acronym is 'UAMObs' and collection_cde is 'Mamm'>
									<cfset stg="'#dateformat(now(),"yyyy")#.' || nvl(lpad(max(to_number(substr(accn_number,6,3))) + 1,3,0),'001') || '.#collection_cde#'">
								<cfset whr=" AND accn_number like '%.MammObs' AND
									substr(accn_number,1,4) = '#dateformat(now(),"yyyy")#'">



							<cfelse>
								<!--- collections who have not asked for a next number suggestion - just show them the last accn used ---->
								<cfset stg="'last created: ' || accn_number">
								<cfset whr=" AND accn.transaction_id = (select max(accn.transaction_id) from accn,trans where trans.transaction_id=accn.transaction_id and
								trans.collection_id=#collection_id#)">

							</cfif>
							<cftry>
								<cfquery name="thisq" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
											and collection.collection_id=#collection_id#
										<cfelse>
											and collection.institution_acronym in ( 'MVZ','MVZObs')
										</cfif>
										#preservesinglequotes(whr)#
								</cfquery>
								<cfcatch>
									<hr>
									#cfcatch.detail#
									<br>
									#cfcatch.sql#
									<cfquery name="thisq" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
										select
											 'check data' nn
										from
											dual
									</cfquery>
								</cfcatch>
							</cftry>
							<tr>
								<td>#guid_prefix#</td>
								<td>
									<cfif len(thisq.nn) is 0>
										nothing found
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
			<cfquery name="n" datasource="user_login" username="#session.username#" password="#decrypt(session.epw,session.sessionKey)#">
				select sq_transaction_id.nextval n from dual
			</cfquery>
			<cfquery name="newTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
					</cfif>,
					is_public_fg
				) VALUES (
					#n.n#,
					'#ent_Date#',
					#correspFg#,
					'#collection_id#',
					'accn'
					<cfif len(#NATURE_OF_MATERIAL#) gt 0>
						,'#NATURE_OF_MATERIAL#'
					</cfif>
					<cfif len(#REMARKS#) gt 0>
						,'#REMARKS#'
					</cfif>,
					#is_public_fg#
				)
				</cfquery>
				<cfquery name="newAccn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO accn (
						TRANSACTION_ID,
						ACCN_TYPE
						,accn_number
						,RECEIVED_DATE,
						ACCN_STATUS,
						estimated_count
						)
					VALUES (
						#n.n#,
						'#accn_type#'
						,'#accn_number#'
						,'#rec_date#',
						'#accn_status#',
						<cfif len(estimated_count) gt 0>
							#estimated_count#
						<cfelse>
							null
						</cfif>
						)
				</cfquery>
				<cfquery name="newAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
					<cfquery name="newAgent" datasource="user_login" username="#session.username#" password="#decrypt(session.epw,session.sessionKey)#">
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
		<cflocation url="editAccn.cfm?Action=edit&transaction_id=#n.n#" addtoken="false">
  </cfoutput>
</cfif>
<cfinclude template="includes/_footer.cfm">