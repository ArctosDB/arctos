<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkloader Stage Cleanup" />
<cfif action is "distinctValues">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from bulkloader_stage where 1=2
		</cfquery>
		<table border>
			<tr>
				<th>Column Name</th>
				<th>Distinct Values</th>
			</tr>
			<cfloop list="#d.columnList#" index="colname">
				<tr>
					<td>#colname#</td>
					<cfquery name="thisDistinct" dbtype="query">
						select #colname# cval from d group by #colname# order by #colname#
					</cfquery>
					<td>
						<cfloop query="thisDistinct"><br>
							#cval#</cfloop>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
	<cfif action is "showDistinct">
		<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select #col# from bulkloader_stage group by #col# order by #col#
		</cfquery>
		<cfdump var=#d#>
		</cfoutput>
	</cfif>
<cfif action is "runUpdate">
	<cfoutput><cfdump var=#form# /></cfoutput>
</cfif>
<cfif action is "updateCommonDefaults">
	<script>
		function getDistinct(col){
		$('#distHere').append('<img src="/images/indicator.gif">');

			var ptl="/Bulkloader/BulkloaderStageCleanup.cfm?action=showDistinct&col=" + col;

			jQuery.get(ptl, function(data){
				 jQuery('#distHere').html(data);
			})
		}
	</script>

	<cfoutput>
		<cfquery name="ctnature_of_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select nature_of_id from ctnature_of_id order by nature_of_id
		</cfquery>
		<cfquery name="ctLAT_LONG_UNITS" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select ORIG_LAT_LONG_UNITS from ctLAT_LONG_UNITS order by orig_lat_long_units
		</cfquery>
		<cfquery name="ctdatum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select datum from ctdatum order by datum
		</cfquery>
		<cfquery name="cterror" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select LAT_LONG_ERROR_UNITS from ctLAT_LONG_ERROR_UNITS order by lat_long_error_units
		</cfquery>
		<cfquery name="ctgeoreference_protocol" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select georeference_protocol from ctgeoreference_protocol order by georeference_protocol
		</cfquery>
		<cfquery name="ctverificationstatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select verificationstatus from ctverificationstatus order by verificationstatus
		</cfquery>
		<cfquery name="ctCOLLECTION_CDE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select COLLECTION_CDE from COLLECTION group by COLLECTION_CDE order by COLLECTION_CDE
		</cfquery>
		<cfquery name="ctinstitution_acronym" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select institution_acronym from COLLECTION group by institution_acronym order by institution_acronym
		</cfquery>
		<cfquery name="CTCOLL_OBJ_DISP" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP order by coll_obj_DISPOSITION
		</cfquery>
		<cfquery name="ctcollecting_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select collecting_source from ctcollecting_source order by collecting_source
		</cfquery>
		<cfquery name="ctspecimen_event_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select specimen_event_type from ctspecimen_event_type order by specimen_event_type
		</cfquery>
		<hr>
		select something to update ALL rows in bulkloader stage to the selected value.
		<br>
		Mess it up? Reload your text file.
		<div id="distHere"></div>
		<form name="x" method="post" action="BulkloaderStageCleanup.cfm">
			<input type="hidden" name="action" value="runUpdate">
			<table border>
				<tr>
					<th>ColumnName</th>
					<th>UpdateTo (leave blank to ignore)</th>
				</tr>
				<tr>
					<td>ENTEREDBY <span class="likeLink" onclick="getDistinct('ENTEREDBY')">[ Show Distinct ]</span></td>
					<td>
						<select name="ENTEREDBY" id="ENTEREDBY">
							<option value=""></option>
							<option value="#session.username#">#session.username#</option>
						</select>
					</td>
				</tr>
				<tr>
					<td>NATURE_OF_ID</td>
					<td>
						<select name="NATURE_OF_ID" id="NATURE_OF_ID">
							<option value=""></option>
							<cfloop query="ctnature_of_id">
								<option value="#nature_of_id#">#nature_of_id#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td>ID_MADE_BY_AGENT</td>
					<td>
						<select name="ID_MADE_BY_AGENT" id="ID_MADE_BY_AGENT">
							<option value=""></option>
							<option value="collector_agent_1">{collector_agent_1}</option>
						</select>
					</td>
				</tr>
				<tr>
					<td>MADE_DATE</td>
					<td>
						<select name="MADE_DATE" id="MADE_DATE">
							<option value=""></option>
							<option value="began_date">{began_date}</option>
						</select>
					</td>
				</tr>
				<tr>
					<td>BEGAN_DATE</td>
					<td>
						<select name="BEGAN_DATE" id="BEGAN_DATE">
							<option value=""></option>
							<option value="verbatim_date">{verbatim_date}</option>
						</select>
					</td>
				</tr>
				<tr>
					<td>ENDED_DATE</td>
					<td>
						<select name="ENDED_DATE" id="ENDED_DATE">
							<option value=""></option>
							<option value="verbatim_date">{verbatim_date}</option>
						</select>
					</td>
				</tr>
				<tr>
					<td>VERBATIM_LOCALITY</td>
					<td>
						<select name="VERBATIM_LOCALITY" id="VERBATIM_LOCALITY">
							<option value=""></option>
							<option value="spec_locality">{spec_locality}</option>
						</select>
					</td>
				</tr>
				<tr>
					<td>ORIG_LAT_LONG_UNITS</td>
					<td>
						<select name="VERBATIM_LOCALITY" id="VERBATIM_LOCALITY">
							<option value=""></option>
							<cfloop query="ctLAT_LONG_UNITS">
								<option value="#ORIG_LAT_LONG_UNITS#">#ORIG_LAT_LONG_UNITS#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td>DATUM</td>
					<td>
						<select name="VERBATIM_LOCALITY" id="VERBATIM_LOCALITY">
							<option value=""></option>
							<cfloop query="ctdatum"><option value="#datum#">
									#datum#
								</option></cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td>GEOREFERENCE_SOURCE</td>
					<td>
						<input type="text" name="GEOREFERENCE_SOURCE" id="GEOREFERENCE_SOURCE">
						(don't know anything? Use "unknown".)
					</td>
				</tr>
				<tr>
					<td>MAX_ERROR_UNITS</td>
					<td>
						<select name="MAX_ERROR_UNITS" id="MAX_ERROR_UNITS">
							<option value=""></option>
							<cfloop query="cterror">
								<option value="#LAT_LONG_ERROR_UNITS#">#LAT_LONG_ERROR_UNITS#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td>GEOREFERENCE_PROTOCOL</td>
					<td>
						<select name="GEOREFERENCE_PROTOCOL" id="GEOREFERENCE_PROTOCOL">
							<option value=""></option>
							<cfloop query="ctgeoreference_protocol">
								<option value="#georeference_protocol#">#georeference_protocol#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td>EVENT_ASSIGNED_BY_AGENT</td>
					<td>
						<select name="EVENT_ASSIGNED_BY_AGENT" id="EVENT_ASSIGNED_BY_AGENT">
							<option value=""></option>
							<option value="collector_agent_1">{collector_agent_1}</option>
						</select>
					</td>
				</tr>
				<tr>
					<td>EVENT_ASSIGNED_DATE</td>
					<td>
						<select name="EVENT_ASSIGNED_DATE" id="EVENT_ASSIGNED_DATE">
							<option value=""></option>
							<option value="verbatim_date">{verbatim_date}</option>
						</select>
					</td>
				</tr>
				<tr>
					<td>VERIFICATIONSTATUS</td>
					<td>
						<select name="VERIFICATIONSTATUS" id="VERIFICATIONSTATUS">
							<option value=""></option>
							<cfloop query="ctverificationstatus">
								<option value="#verificationstatus#">#verificationstatus#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<cfloop from="1" to="8" index="x">
					<tr>
						<td>COLLECTOR_ROLE_#x#</td>
						<td>
							<select name="COLLECTOR_ROLE_#x#" id="COLLECTOR_ROLE_#x#">
								<option value=""></option>
								<option value="c">c</option>
								<option value="p">p</option>
							</select>
						</td>
					</tr>
				</cfloop>
				<tr>
					<td>COLLECTION_CDE</td>
					<td>
						<select name="COLLECTION_CDE" id="COLLECTION_CDE">
							<option value=""></option>
							<cfloop query="ctCOLLECTION_CDE">
								<option value="#COLLECTION_CDE#">#COLLECTION_CDE#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td>INSTITUTION_ACRONYM</td>
					<td>
						<select name="INSTITUTION_ACRONYM" id="INSTITUTION_ACRONYM">
							<option value=""></option>
							<cfloop query="ctinstitution_acronym">
								<option value="#institution_acronym#">#institution_acronym#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<cfloop from="1" to="12" index="x">
					<tr>
						<td>PART_CONDITION_#x#</td>
						<td>
							<select name="PART_CONDITION_#x#" id="PART_CONDITION_#x#">
								<option value=""></option>
								<option value="unchecked">unchecked</option>
							</select>
						</td>
					</tr>
					<tr>
						<td>PART_LOT_COUNT_#x#</td>
						<td>
							<select name="PART_LOT_COUNT_#x#" id="PART_LOT_COUNT_#x#">
								<option value=""></option>
								<option value="1">1</option>
							</select>
						</td>
					</tr>
					<tr>
						<td>PART_DISPOSITION_#x#</td>
						<td>
							<select name="PART_DISPOSITION_#x#" id="PART_DISPOSITION_#x#">
								<option value=""></option>
								<cfloop query="CTCOLL_OBJ_DISP">
									<option value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
								</cfloop>
							</select>
						</td>
					</tr>
				</cfloop>
				<cfloop from="1" to="10" index="x">
					<tr>
						<td>ATTRIBUTE_DATE_#x#</td>
						<td>
							<select name="ATTRIBUTE_DATE_#x#" id="ATTRIBUTE_DATE_#x#">
								<option value=""></option>
								<option value="began_date">{began_date}</option>
							</select>
						</td>
					</tr>
					<tr>
						<td>ATTRIBUTE_DETERMINER_#x#</td>
						<td>
							<select name="ATTRIBUTE_DETERMINER_#x#" id="ATTRIBUTE_DETERMINER_#x#">
								<option value=""></option>
								<option value="collector_agent_1">{collector_agent_1}</option>
							</select>
						</td>
					</tr>
				</cfloop>
				<tr>
					<td>COLLECTING_SOURCE</td>
					<td>
						<select name="COLLECTING_SOURCE" id="COLLECTING_SOURCE">
							<option value=""></option>
							<cfloop query="ctcollecting_source">
								<option value="#collecting_source#">#collecting_source#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td>SPECIMEN_EVENT_TYPE</td>
					<td>
						<select name="SPECIMEN_EVENT_TYPE" id="SPECIMEN_EVENT_TYPE">
							<option value=""></option>
							<cfloop query="ctspecimen_event_type">
								<option value="#specimen_event_type#">#specimen_event_type#</option>
							</cfloop>
						</select>
					</td>
				</tr>
			</table>
		</form>
	</cfoutput>
</cfif>
<cfif action is "nothing">
	<cfoutput>
		When to use this form:
		<ul>
			<li>You have clean data with lots of missing homogenous default values.</li>
		</ul>
		When NOT to use this form:
		<ul>
			<li>You have messy data. (See Reports/Data Services.)</li>
			<li>You expect magic. (We have none.)</li>
			<li>You have missing heterogeneous values. (This form won't work.)</li>
			<li>
				You have no idea what you're trying to do. (This form will mess up all your data at once.)
			</li>
		</ul>
		<ul>
			<li>
				<a href="BulkloaderStageCleanup.cfm?action=distinctValues">Show distinct values</a>
			</li>
			<li>
				<a href="BulkloaderStageCleanup.cfm?action=updateCommonDefaults">Update Common Defaults</a>
			</li>
		</ul>
	</cfoutput>
</cfif>
<cfif action is "runsql">
	<cfquery name="up" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update bulkloader_stage set collection_object_id=collection_object_id
		<cfif len(ENTEREDBY) gt 0>
			,ENTEREDBY='#ENTEREDBY#'
		</cfif>
		where 1=1
		<cfif ENTEREDBY_CRIT is "NULL">
			and ENTEREDBY is null
		</cfif>
	</cfquery>
</cfif>
