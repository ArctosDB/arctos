<cfinclude template="includes/_header.cfm">
<Cfset title="Bulk Coll Event">
<!----------------------------------------------------------------------------------->
<cfif action is "deleteAll">
	<cfquery name="upSE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from specimen_event where collection_object_id in (select collection_object_id from #table_name#)
	</cfquery>
	<cflocation url="bulkCollEvent.cfm?table_name=#table_name#" addtoken="false">
</cfif>
<!----------------------------------------------------------------------------------->
<cfif action is "replaceAll">
	<cfquery name="cids" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collection_object_id from #table_name#
	</cfquery>
	<cftransaction>
		<cfquery name="upSE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from specimen_event where collection_object_id in (select collection_object_id from #table_name#)
		</cfquery>
		<cfloop query="cids">
			<cfquery name="upSE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into specimen_event (
					collection_object_id,
					collecting_event_id,
					assigned_by_agent_id,
					assigned_date,
					specimen_event_remark,
					specimen_event_type,
					COLLECTING_METHOD,
					COLLECTING_SOURCE,
					VERIFICATIONSTATUS,
					habitat
				) values (
					#collection_object_id#,
					#collecting_event_id#,
					#assigned_by_agent_id#,
					'#dateformat(assigned_date,"yyyy=mm-dd")#',
					'#escapeQuotes(specimen_event_remark)#',
					'#specimen_event_type#',
					'#escapeQuotes(COLLECTING_METHOD)#',
					'#COLLECTING_SOURCE#',
					'#VERIFICATIONSTATUS#',
					'#escapeQuotes(habitat)#'
				)
			</cfquery>
		</cfloop>
	</cftransaction>
	<cflocation url="bulkCollEvent.cfm?table_name=#table_name#" addtoken="false">
</cfif>
<!----------------------------------------------------------------------------------->
<cfif action is "addToAll">
	<cfquery name="cids" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collection_object_id from #table_name#
	</cfquery>
	<cftransaction>
		<cfloop query="cids">
			<cfquery name="upSE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into specimen_event (
					collection_object_id,
					collecting_event_id,
					assigned_by_agent_id,
					assigned_date,
					specimen_event_remark,
					specimen_event_type,
					COLLECTING_METHOD,
					COLLECTING_SOURCE,
					VERIFICATIONSTATUS,
					habitat
				) values (
					#collection_object_id#,
					#collecting_event_id#,
					#assigned_by_agent_id#,
					'#dateformat(assigned_date,"yyyy=mm-dd")#',
					'#escapeQuotes(specimen_event_remark)#',
					'#specimen_event_type#',
					'#escapeQuotes(COLLECTING_METHOD)#',
					'#COLLECTING_SOURCE#',
					'#VERIFICATIONSTATUS#',
					'#escapeQuotes(habitat)#'
				)
			</cfquery>
		</cfloop>
	</cftransaction>
	<cflocation url="bulkCollEvent.cfm?table_name=#table_name#" addtoken="false">
</cfif>
<!----------------------------------------------------------------------------------->
<cfif action is "nothing">
	<cfset title = "Change Coll Event">
	<cfset showLocality=1>
	<cfset showEvent=1>
	<cfoutput>
 		<h3>Find collecting event</h3>
		<form name="getCol" method="post" action="bulkCollEvent.cfm">
			<input type="hidden" name="Action" value="findCollEvent">
			<input type="hidden" name="table_name" value="#table_name#">
			<cfinclude template="/includes/frmFindLocation_guts.cfm">	   
		</form>
	</cfoutput>
</cfif>
<cfif action is "nothing" or action is "findCollEvent">
	<cfquery name="specimenList" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		 SELECT 
		 	flat.collection_object_id,
		 	flat.guid, 
			concatSingleOtherId(flat.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
			flat.scientific_name,
			collecting_event.collecting_event_id,
			getPreferredAgentName(specimen_event.assigned_by_agent_id) assignedBy,
			specimen_event.assigned_by_agent_id,
	    	specimen_event.specimen_event_id,
	    	specimen_event.assigned_date,
			specimen_event.specimen_event_remark,
			specimen_event.specimen_event_type,
			specimen_event.COLLECTING_METHOD,
			specimen_event.COLLECTING_SOURCE,
			specimen_event.VERIFICATIONSTATUS,
			specimen_event.habitat,
			collecting_event.VERBATIM_DATE,
			collecting_event.VERBATIM_LOCALITY,
			collecting_event.COLL_EVENT_REMARKS,
			collecting_event.BEGAN_DATE,
			collecting_event.ENDED_DATE,
			collecting_event.VERBATIM_COORDINATES,
			collecting_event.COLLECTING_EVENT_NAME,
			locality.spec_locality,
			geog_auth_rec.higher_geog,
			locality.locality_name
		FROM 
			flat,
			specimen_event,
			collecting_event,
			locality,
			geog_auth_rec
		WHERE 
			flat.collection_object_id=specimen_event.collection_object_id (+) and
			specimen_event.collecting_event_id=collecting_event.collecting_event_id (+) and
			collecting_event.locality_id=locality.locality_id (+) and
			locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id (+) and
			flat.collection_object_id IN (select collection_object_id from #table_name#)
	</cfquery>
	<cfquery name="spec" dbtype="query">
		select 
			collection_object_id,
		 	guid, 
			CustomID,
			scientific_name
		from
			specimenList
		group by
			collection_object_id,
		 	guid, 
			CustomID,
			scientific_name
	</cfquery>
	<cfquery name="events_per_spec" dbtype="query">
		select collection_object_id,count(*) c from specimenList group by collection_object_id
	</cfquery>
	<cfquery name="events_per_spec2" dbtype="query">
		select count(*) x from events_per_spec where c != 1
	</cfquery>
	
	<cfoutput>
	<cfset allowReplace=false>
	<div style="padding:1em; text-align:center; margin:1em; width:70%;border:2px solid red;">
		<cfif len(events_per_spec2.x) gt 0 and events_per_spec2.x is not 0>
			<br>There is not 1 event per specimen - only additive tools are available
		<cfelse>
			<br>There is 1 event per specimen.....
			<cfquery name="et" dbtype="query">
				select specimen_event_type from specimenList group by specimen_event_type
			</cfquery>
			<cfif et.recordcount is 1 and valuelist(et.specimen_event_type) is "accepted place of collection">
				<br>All events are accepted place of collection....
				<cfquery name="vs" dbtype="query">
					select verificationstatus from specimenList group by verificationstatus
				</cfquery>
				<cfif vs.recordcount is 1 and valuelist(vs.verificationstatus) is "unverified">
					<br>all events are unverified
					<cfset allowReplace=true>
				<cfelse>
					<br>verified events - do not allow replace
				</cfif>
			<cfelse>
				<br>NOT all accepted place of collection
			</cfif> 
		</cfif>
		<cfif allowReplace is true>
			<br><input type="button"
					onclick="document.location='bulkCollEvent.cfm?action=deleteAll&table_name=#table_name#';" 
				 	value="REMOVE all specimen events (presumably so you can add new ones)" 
					class="delBtn">
			<hr>
			OR edit common information in all specimen/events
			<hr>
			
			
			
			
				
				<!-------
				
	    	specimen_event.assigned_date,
			specimen_event.specimen_event_remark,
			specimen_event.specimen_event_type,
			specimen_event.COLLECTING_METHOD,
			specimen_event.COLLECTING_SOURCE,
			specimen_event.VERIFICATIONSTATUS,
			specimen_event.habitat,
			
			-------->
			
			<script language="javascript" type="text/javascript">
				jQuery(document).ready(function() {
					$("##assigned_date").datepicker();
				});
			</script>
			
			<div style=" text-align:left">
				<cfform name="loc" method="post" action="bulkCollEvent.cfm">
					<input type="hidden" name="action" value="saveChangeMultiEvent">
					<input type="hidden" name="specimen_event_id" value="#valuelist(specimenList.specimen_event_id)#">
					<input type="hidden" name="table_name" value="#table_name#">
					
					
					<cfquery name="ctspecimen_event_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select specimen_event_type from ctspecimen_event_type order by specimen_event_type
					</cfquery>
					<cfquery name="ctcollecting_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				        select COLLECTING_SOURCE from ctcollecting_source order by COLLECTING_SOURCE
				     </cfquery>
				     <cfquery name="ctVerificationStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select VerificationStatus from ctVerificationStatus
					</cfquery>
					
					<cfquery name="c_specimen_event_type" dbtype="query">
						select specimen_event_type from specimenList group by specimen_event_type
					</cfquery>
					<label for="specimen_event_type">Specimen/Event Type</label>
					<cfif c_specimen_event_type.recordcount is 1>
						<select name="specimen_event_type" id="specimen_event_type" size="1" class="reqdClr">
							<cfloop query="ctspecimen_event_type">
								<option <cfif ctspecimen_event_type.specimen_event_type is c_specimen_event_type.specimen_event_type> selected="selected" </cfif>
									value="#ctspecimen_event_type.specimen_event_type#">#ctspecimen_event_type.specimen_event_type#</option>
						    </cfloop>
						</select>
					<cfelse>
						<div id="specimen_event_type">
							various - no edit allowed.
						</div>
					</cfif>
					
					<cfquery name="c_assignedBy" dbtype="query">
						select assignedBy,assigned_by_agent_id from specimenList group by assignedBy,assigned_by_agent_id
					</cfquery>
					<label for="assigned_by_agent_name">Event Assigned by Agent</label>
					<cfif c_assignedBy.recordcount is 1>
						<input type="text" name="assigned_by_agent_name" id="assigned_by_agent_name" class="reqdClr" value="#c_assignedBy.assignedBy#" size="40"
							 onchange="getAgent('assigned_by_agent_id','assigned_by_agent_name','loc',this.value); return false;"
							 onKeyPress="return noenter(event);">
						<input type="hidden" name="assigned_by_agent_id" id="assigned_by_agent_id" value="#c_assignedBy.assigned_by_agent_id#">
					<cfelse>
						<div id="assigned_by_agent_name">
							various - no edit allowed.
						</div>
					</cfif>
					<cfquery name="c_assigned_date" dbtype="query">
						select assigned_date from specimenList group by assigned_date
					</cfquery>
					<label for="assigned_date" class="infoLink" onClick="getDocs('locality','assigned_date')">Specimen/Event Assigned Date</label>
					<cfif c_assigned_date.recordcount is 1>
						<input type="text" name="assigned_date" id="assigned_date" value="#dateformat(c_assigned_date.assigned_date,'yyyy-mm-dd')#" class="reqdClr">
					<cfelse>
						<div id="assigned_by_agent_name">
							various - no edit allowed.
						</div>
					</cfif>
					
					<cfquery name="c_specimen_event_remark" dbtype="query">
						select specimen_event_remark from specimenList group by specimen_event_remark
					</cfquery>
					<label for="specimen_event_remark">Specimen/Event Remark</label>
					<cfif c_specimen_event_remark.recordcount is 1>
						<input type="text" name="specimen_event_remark" id="specimen_event_remark" value="#c_specimen_event_remark.specimen_event_remark#" size="75">
					<cfelse>
						<div id="specimen_event_remark">
							various - no edit allowed.
						</div>
					</cfif>
					
					<cfquery name="c_habitat" dbtype="query">
						select habitat from specimenList group by habitat
					</cfquery>
					<label for="habitat">Habitat</label>
					<cfif c_specimen_event_remark.recordcount is 1>
						<input type="text" name="habitat" id="habitat" value="#c_habitat.habitat#" size="75">
					<cfelse>
						<div id="habitat">
							various - no edit allowed.
						</div>
					</cfif>
					
					
					<cfquery name="c_collecting_source" dbtype="query">
						select collecting_source from specimenList group by collecting_source
					</cfquery>
					<label for="" class="infoLink" onClick="getDocs('collecting_source','collecting_method')">Collecting Source</label>
					<cfif c_collecting_source.recordcount is 1>
						<select name="collecting_source" id="collecting_source" size="1" class="reqdClr">
							<option value=""></option>
							<cfloop query="ctcollecting_source">
								<option <cfif ctcollecting_source.COLLECTING_SOURCE is c_collecting_source.COLLECTING_SOURCE> selected="selected" </cfif>
									value="#ctcollecting_source.COLLECTING_SOURCE#">#ctcollecting_source.COLLECTING_SOURCE#</option>
							</cfloop>
						</select>
					<cfelse>
						<div id="collecting_source">
							various - no edit allowed.
						</div>
					</cfif>
					
					<cfquery name="c_collecting_method" dbtype="query">
						select collecting_method from specimenList group by collecting_method
					</cfquery>
					<label for="collecting_method" onClick="getDocs('collecting_event','collecting_method')" class="infoLink">Collecting Method</label>
					<cfif c_collecting_method.recordcount is 1>
						<input type="text" name="collecting_method" id="collecting_method" value="#stripQuotes(c_collecting_method.COLLECTING_METHOD)#" size="75">
					<cfelse>
						<div id="collecting_method">
							various - no edit allowed.
						</div>
					</cfif>
					
					<cfquery name="c_VerificationStatus" dbtype="query">
						select VerificationStatus from specimenList group by VerificationStatus
					</cfquery>
					<label for="VerificationStatus" class="likeLink" onClick="getDocs('lat_long','verification_status')">Verification Status</label>
					<cfif c_VerificationStatus.recordcount is 1>
						<select name="VerificationStatus" id="verificationstatus" size="1" class="reqdClr">
							<cfloop query="ctVerificationStatus">
								<option <cfif c_VerificationStatus.VerificationStatus is ctVerificationStatus.VerificationStatus> selected="selected" </cfif>
									value="#VerificationStatus#">#VerificationStatus#</option>
							</cfloop>
						</select>
					<cfelse>
						<div id="VerificationStatus">
							various - no edit allowed.
						</div>
					</cfif>
					<br><input type="submit" value="update all specimen/events listed below" class="savBtn">
				</cfform>
			</div>
		</cfif>		
	</div>
	<br><b>Specimens Being Changed:</b>
		<table width="95%" border="1">
			<tr>
				<th>Specimen</th>
				<th>#session.CustomOtherIdentifier#</th>
				<th>Accepted ID</th>
				<th>Events</th>
			</tr>
			<cfloop query="spec">
				<cfquery name="thisEvents" dbtype="query">
					select 
						collecting_event_id,
						assignedBy,
			    		assigned_date,
						specimen_event_remark,
						specimen_event_type,
						COLLECTING_METHOD,
						COLLECTING_SOURCE,
						VERIFICATIONSTATUS,
						habitat,
						VERBATIM_DATE,
						VERBATIM_LOCALITY,
						COLL_EVENT_REMARKS,
						BEGAN_DATE,
						ENDED_DATE,
						VERBATIM_COORDINATES,
						COLLECTING_EVENT_NAME,
						locality_name,
						spec_locality,
						higher_geog
					from
						specimenList
					where
						specimen_event_type is not null and
						collection_object_id=#collection_object_id#
				</cfquery>
				<tr>
					<td><a href="/guid/#guid#">#guid#</a></td>	  
					<td>#CustomID#&nbsp;</td>
					<td><i>#Scientific_Name#</i></td>
					<td>
						<cfset i=1>
						<cfloop query="thisEvents">
							<table #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))# border>
								<cfset i=1+1>
								<tr>
									<td align="right">Specimen/Event Type</td>
									<td>#specimen_event_type#</td>
								</tr>
								<tr>
									<td align="right">EventAssignedBy/Date</td>
									<td>#assignedBy# on #assigned_date#</td>
								</tr>
								<cfif len(specimen_event_remark) gt 0>
									<tr>
										<td align="right">Specimen/Event Remark</td>
										<td>#specimen_event_remark#</td>
									</tr>
								</cfif>
								<cfif len(COLLECTING_METHOD) gt 0>
									<tr>
										<td align="right">Collecting Method</td>
										<td>#COLLECTING_METHOD#</td>
									</tr>
								</cfif>
								<cfif len(COLLECTING_SOURCE) gt 0>
									<tr>
										<td align="right">Collecting Source</td>
										<td>#COLLECTING_SOURCE#</td>
									</tr>
								</cfif>
								<tr>
									<td align="right">VerificationStatus</td>
									<td>#VERIFICATIONSTATUS#</td>
								</tr>
								<cfif len(habitat) gt 0>
									<tr>
										<td align="right">Habitat</td>
										<td>#habitat#</td>
									</tr>
								</cfif>
								<tr>
									<td align="right">Date</td>
									<td>#VERBATIM_DATE# (#BEGAN_DATE#-#ENDED_DATE#)</td>
								</tr>
								<cfif len(VERBATIM_LOCALITY) gt 0>
									<tr>
										<td align="right">Verbatim Locality</td>
										<td>#VERBATIM_LOCALITY#</td>
									</tr>
								</cfif>
								<cfif len(COLL_EVENT_REMARKS) gt 0>
									<tr>
										<td align="right">EventRemark</td>
										<td>#COLL_EVENT_REMARKS#</td>
									</tr>
								</cfif>
								<cfif len(VERBATIM_COORDINATES) gt 0>
									<tr>
										<td align="right">EventCoordinates</td>
										<td>#VERBATIM_COORDINATES#</td>
									</tr>
								</cfif>
								<cfif len(COLLECTING_EVENT_NAME) gt 0>
									<tr>
										<td align="right">EventName</td>
										<td>#COLLECTING_EVENT_NAME#</td>
									</tr>
								</cfif>
								<cfif len(locality_name) gt 0>
									<tr>
										<td align="right">LocalityName</td>
										<td>#locality_name#</td>
									</tr>
								</cfif>
								<cfif len(spec_locality) gt 0>
									<tr>
										<td align="right">SpecificLocality</td>
										<td>#spec_locality#</td>
									</tr>
								</cfif>
								<tr>
									<td align="right">Geography</td>
									<td>#higher_geog#</td>
								</tr>
							</table>
						</cfloop>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>


<!----------------------------------------------------------------------------------->
<cfif action is "saveChangeMultiEvent">
	<cfoutput>
		<cftransaction>
			<cfloop list="#specimen_event_id#" index="i">
				<cfquery name="ctspecimen_event_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update 
						specimen_event 
					set
						<cfif isdefined("specimen_event_type") and len(specimen_event_type) gt 0>
							specimen_event_type='#specimen_event_type#',
						</cfif>
						<cfif isdefined("assigned_by_agent_id") and len(assigned_by_agent_id) gt 0>
							assigned_by_agent_id=#assigned_by_agent_id#,
						</cfif>
						<cfif isdefined("assigned_date") and len(assigned_date) gt 0>
							assigned_date='#assigned_date#',
						</cfif>
						<cfif isdefined("specimen_event_remark") and len(specimen_event_remark) gt 0>
							assigned_date='#escapeQuotes(specimen_event_remark)#'
						</cfif>
						<cfif isdefined("habitat") and len(habitat) gt 0>
							habitat='#escapeQuotes(habitat)#',
						</cfif>
						<cfif isdefined("collecting_source") and len(collecting_source) gt 0>
							collecting_source='#collecting_source#',
						</cfif>
						<cfif isdefined("collecting_method") and len(collecting_method) gt 0>
							collecting_method='#escapeQuotes(collecting_method)#',
						</cfif>
						<cfif isdefined("VerificationStatus") and len(VerificationStatus) gt 0>
							VerificationStatus='#VerificationStatus#',
						</cfif>
						specimen_event_id=#i#
					where
						specimen_event_id=#i#
					</cfquery>
			</cfloop>
		</cftransaction>
		<cflocation url="bulkCollEvent.cfm?table_name=#table_name#" addtoken="false">
	</cfoutput>	
</cfif>
<!----------------------------------------------------------------------------------->

<cfif action is "findCollEvent">
	<cfquery name="ctspecimen_event_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select specimen_event_type from ctspecimen_event_type order by specimen_event_type
	</cfquery>
	<cfquery name="ctcollecting_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
        select COLLECTING_SOURCE from ctcollecting_source order by COLLECTING_SOURCE
     </cfquery>
	<cfquery name="ctVerificationStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select VerificationStatus from ctVerificationStatus
	</cfquery>
	<cfoutput>
		<h3>Locality Search Results</h3>
		<cf_findLocality type="event">
		<table border>
			<tr>
				<td><b>Geog ID</b></td>
				<td><b>Locality ID</b></td>
				<td><b>&nbsp;</b></td>
				<td><b>Verb. Loc</b></td>
				<td><b>Beg. Date</b></td>
				<td><b>End Date</b></td>
				<td><b>Verb. Date</b></td>
				<td><b>Source</b></td>
				<td><b>Method</b></td>
			</tr>
			<cfset i = 1>
			<cfquery name="localityResults" dbtype="query">
				select
					geog_auth_rec_id,
					locality_id,
					collecting_event_id,
					verbatim_locality,
					spec_locality,
					began_date,
					ended_date,
					verbatim_date
				from
					localityResults
				where
					collecting_event_id is not null
				group by
					geog_auth_rec_id,
					locality_id,
					collecting_event_id,
					verbatim_locality,
					spec_locality,
					began_date,
					ended_date,
					verbatim_date
			</cfquery>
			<cfloop query="localityResults">
				<tr>
					<td> <a href="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">#geog_auth_rec_id#</a></td>
					<td><a href="editLocality.cfm?locality_id=#locality_id#">#locality_id#</a></td>
					<td>
						
						<form name="coll#i#" method="post" action="bulkCollEvent.cfm">
							<input type="hidden" name="collecting_event_id" value="#collecting_event_id#">
							<input type="hidden" name="table_name" value="#table_name#">
							<input type="hidden" name="action" value="">
							<label for="specimen_event_type">Specimen/Event Type</label>
							<select name="specimen_event_type" id="specimen_event_type" size="1" class="reqdClr">
								<cfloop query="ctspecimen_event_type">
									<option value="#ctspecimen_event_type.specimen_event_type#">#ctspecimen_event_type.specimen_event_type#</option>
							    </cfloop>
							</select>
							<span class="infoLink" onclick="getCtDoc('ctspecimen_event_type');">Define</span>

							<label for="specimen_event_type">Event Assigned by Agent</label>
							<input type="text" name="assigned_by_agent_name" id="assigned_by_agent_name" class="reqdClr" size="40" value="#session.dbuser#"
								 onchange="getAgent('assigned_by_agent_id','assigned_by_agent_name','coll#i#',this.value); return false;"
								 onKeyPress="return noenter(event);">
							<input type="hidden" name="assigned_by_agent_id" id="assigned_by_agent_id" value="#session.myAgentId#">
			
							<label for="assigned_date" class="infoLink" onClick="getDocs('locality','assigned_date')">Specimen/Event Assigned Date</label>
							<input type="text" name="assigned_date" id="assigned_date" class="reqdClr" value="#dateformat(now(),'yyyy-mm-dd')#">
							
			
							<label for="specimen_event_remark" class="infoLink">Specimen/Event Remark</label>
							<input type="text" name="specimen_event_remark" id="specimen_event_remark" size="75">
							
							<label for="habitat">Habitat</label>
							<input type="text" name="habitat" id="habitat" size="75">
							
							<label for="collecting_source" class="infoLink" onClick="getDocs('collecting_source','collecting_method')">Collecting Source</label>
							<select name="collecting_source" id="collecting_source" size="1" class="reqdClr">
								<option value=""></option>
								<cfloop query="ctcollecting_source">
									<option value="#ctcollecting_source.COLLECTING_SOURCE#">#ctcollecting_source.COLLECTING_SOURCE#</option>
								</cfloop>
							</select>
							<span class="infoLink" onclick="getCtDoc('ctcollecting_source');">Define</span>
				
							<label for="collecting_method" onClick="getDocs('collecting_event','collecting_method')" class="infoLink">Collecting Method</label>
							<input type="text" name="collecting_method" id="collecting_method" size="75">
							
							<label for="VerificationStatus" class="likeLink" onClick="getDocs('lat_long','verification_status')">Verification Status</label>
							<select name="VerificationStatus" id="verificationstatus" size="1" class="reqdClr">
								<cfloop query="ctVerificationStatus">
									<option value="#VerificationStatus#">#VerificationStatus#</option>
								</cfloop>
							</select>
							<cfif allowReplace is true>
								<br><input type="button"
									onclick="coll#i#.action.value='replaceAll';coll#i#.submit();" 
								 	value="REPLACE all specimens event with this event" 
									class="savBtn">
							<cfelse>
								<br>Only additive tools are available for this specimen set
							</cfif>
							<br><input type="button"
								onclick="coll#i#.action.value='addToAll';coll#i#.submit();" 
							 	value="Add this event to all listed specimens (may remove the ability to bulk-update)" 
								class="insBtn">
					</form>
						
						<!------

					<form name="coll#i#" method="post" action="bulkCollEvent.cfm">
						<input type="hidden" name="collection_object_id" value="#collection_object_id#">
						<input type="hidden" name="collecting_event_id" value="#collecting_event_id#">
						<input type="hidden" name="action" value="updateCollEvent">
						<input type="submit" 
							 	value="Change ALL listed specimens to this coll event" 
								class="savBtn"
		   						onmouseover="this.className='savBtn btnhov'" 
								onmouseout="this.className='savBtn'">
					</form>
					-------->
					</td>
					<td>#verbatim_locality#
						<cfif spec_locality neq verbatim_locality>
							<br><strong><em>Spec. Locality:</em></strong> #spec_locality#
						</cfif>
					</td>
					<td>#began_date#</td>
					<td>#ended_date#</td>
					<td>#verbatim_date#</td>
				</tr>
				<cfset i=i+1>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->

<cfif action is "updateCollEvent">
	deprecated<cfabort>
<cfoutput>
	<cftransaction>
		<cfloop list="#collection_object_id#" index="i">
			<cfquery name="newCollEvent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				UPDATE cataloged_item SET collecting_event_id = #collecting_event_id# WHERE
				collection_object_id=#i#
			</cfquery>
			<cfquery name="upEd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				UPDATE coll_object SET
					last_edited_person_id=#session.myagentid#,
					last_edit_date=sysdate
				WHERE
					collection_object_id = #i#
			</cfquery>
		</cfloop>
	</cftransaction>
	<cflocation url="bulkCollEvent.cfm?collection_object_id=#collection_object_id#">
</cfoutput>
</cfif>
<cfinclude template="includes/_footer.cfm">