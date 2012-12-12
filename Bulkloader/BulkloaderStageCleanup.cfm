	<cfinclude template="/includes/_header.cfm">
	<cfset title="Bulkloader Stage Cleanup" />
	<a href="BulkloaderStageCleanup.cfm">[ cleanup home ]</a>
		<script>
			function getDistinct(col){
					$('#distHere').append('<img src="/images/indicator.gif">');
					var ptl="/ajax/bulk_stage_distinct.cfm?col=" + col;
					jQuery.get(ptl, function(data){ jQuery('#distHere').html(data); })
				 }
				 function appendToSQL(l) {
				 	$("#s").append (' ' + l);
				 }
				 function showExample(i) {
				 	switch(i){
			        	case 1:
			           	 $("#s").val("enteredby='billybob'");
			            break;
			        case 2:
			            $("#s").val("enteredby='billybob',\naccn='blah'");
			            break;
			        case 3:
			            $("#s").val("enteredby='billybob',\naccn='blah'\nattribute_determiner_1=collector_agent_1");
			            break;
			         case 4:
			            $("#s").val("enteredby='billybob',\naccn='blah',\nattribute_determiner_1=collector_agent_1\nWHERE\ntaxon_name LIKE 'Sorex %'");
			            break;
		  		  }
				 }
		</script>

			<cfif action is "ajaxGrid">
				<cfoutput>
					<cfquery name="cNames" datasource="uam_god">
						select column_name from user_tab_cols where table_name='BULKLOADER_STAGE' and column_name not like '%$%'
						order by internal_column_id
					</cfquery>
					<cfset ColNameList = valuelist(cNames.column_name)>
					<cfset ColNameList = replace(ColNameList,"COLLECTION_OBJECT_ID","","all")>
					<cfset args.width="1200">
					<cfset args.height="600">
					<cfset args.stripeRows = true>
					<cfset args.selectColor = "##D9E8FB">
					<cfset args.selectmode = "edit">
					<cfset args.format="html">
					<cfset args.onchange = "cfc:component.Bulkloader.editStageRecord({cfgridaction},{cfgridrow},{cfgridchanged})">
					<cfset args.bind="cfc:component.Bulkloader.getStagePage({cfgridpage},{cfgridpagesize},{cfgridsortcolumn},{cfgridsortdirection})">
					<cfset args.name="blGrid">
					<cfset args.pageSize="20">

					<cfform method="post" action="BulkloaderStageCleanup.cfm">
						<cfinput type="hidden" name="returnAction" value="ajaxGrid">
						<cfinput type="hidden" name="action" value="saveGridUpdate">
						<cfgrid attributeCollection="#args#">
							<cfloop list="#ColNameList#" index="thisName">
								<cfgridcolumn name="#thisName#">
							</cfloop>
						</cfgrid>
					</cfform>
				</cfoutput>
			</cfif>
	<!--------------------------------------------------------------------------------->
	<cfif action is "runSQL">
		<cfoutput>
			<cfset sql="update bulkloader_stage set collection_object_id=collection_object_id,#s#" />
			<cfquery name="update" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				#preservesinglequotes(sql)#
			</cfquery>
			<cfdump var=#sql# />
			<hr>
			done -
			<a href="BulkloaderStageCleanup.cfm?action=sql">back to sql</a>
		</cfoutput>
	</cfif>
	<!--------------------------------------------------------------------------------->
	<cfif action is "sql">
		<cfoutput>
			<table width="100%">
				<tr>
					<td valign="top">
						<div id="distHere" style="border:2px solid red;">results of "show distinct" go here</div>
						Write your own SQL.
						<br>
						Whatever you enter in the box will be appended to "update bulkloader_stage set "
						<br>
						This isn't a great place to learn SQL - make sure you know what you're doing!
						<br>
						Examples: update.....
						<ul>
							<li>
								<span class="likeLink" onclick="showExample(1)">
									<strong>enteredby</strong>
									to "billybob"
								</span>
							</li>
							<li>
								<span class="likeLink" onclick="showExample(2)">
									<strong>enteredby</strong>
									to "billybob";
									<strong>accn</strong>
									to "blah"
								</span>
							</li>
							<li>
								<span class="likeLink" onclick="showExample(3)">
									<strong>enteredby</strong>
									to "billybob,"
									<strong>accn</strong>
									to "blah," and
									<strong>attribute_determined_1</strong>
									to
									<em>collector_agent_1</em>
								</span>
							</li>
							<li>
								<span class="likeLink" onclick="showExample(4)">
									<strong>enteredby</strong>
									to "billybob,"
									<strong>accn</strong>
									to "blah," and
									<strong>attribute_determined_1</strong>
									to
									<em>collector_agent_1</em>
									where
									<strong>taxon_name</strong>
									starts with "Sorex "
								</span>
							</li>
						</ul>
						<form name="x" method="post" action="BulkloaderStageCleanup.cfm">
							<input type="hidden" name="action" value="runSQL">
							<label for="s">SQL: UPDATE bulkloader_stage SET ....</label>
							<textarea name="s" id="s" rows="20" cols="90"></textarea>
							<br>
							<input type="submit" value="run SQL">
						</form>
					</td>
					<td valign="top">
						<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							select * from bulkloader_stage where 1=2
						</cfquery>
						<div style="max-height:600px;overflow:auto;">
							<cfloop list="#d.columnList#" index="l">
								<br>
								#l#
								<span class="infoLink" onclick="appendToSQL('#l#')">append to SQL box</span>
								~
								<span class="infoLink" onclick="getDistinct('#l#')">distinct</span>
							</cfloop>
						</div>
					</td>
				</tr>
			</table>
		</cfoutput>
	</cfif>
	<!--------------------------------------------------------------------------------->
	<cfif action is "distinctValues">
		<cfoutput>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from bulkloader_stage
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
	<!--------------------------------------------------------------------------------->
	<cfif action is "runUpdate">
		<cfoutput>
			<cfset sql="update bulkloader_stage set collection_object_id=collection_object_id" />
			<cfloop list="#form.fieldnames#" index="f">
				<cfif f is not "ACTION">
					<cfset thisValue=evaluate(f) />
					<cfif len(thisValue) gt 0>
						<cfset sql=sql&",#f#='#thisValue#'" />
					</cfif>
				</cfif>
			</cfloop>
			<cfset sql=replace(sql,"'{","","all")>
			<cfset sql=replace(sql,"}'","","all")>

				<cfdump var=#sql# />

			<cfquery name="update" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				#preservesinglequotes(sql)#
			</cfquery>
			<hr>
			done -
			<a href="BulkloaderStageCleanup.cfm?action=updateCommonDefaults">back to update defaults</a>
		</cfoutput>
	</cfif>
	<!--------------------------------------------------------------------------------->
	<cfif action is "updateCommonDefaults">
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
			<br>
			This form will happily replace all your good values with garbage. There is no finesse. (Load to bulkloader and use SQL browse/edit option.) Reload your text file and start over if you muck it up.
			<div id="distHere" style="border:2px solid red">results of "show distinct" go here</div>
			<form name="x" method="post" action="BulkloaderStageCleanup.cfm">
				<input type="hidden" name="action" value="runUpdate">
				<table border>
					<tr>
						<th>ColumnName</th>
						<th>UpdateTo (leave blank to ignore)</th>
					</tr>
					<tr>
						<td>
							ENTEREDBY
							<span class="likeLink" onclick="getDistinct('ENTEREDBY')">[ Show Distinct ]</span>
						</td>
						<td>
							<select name="ENTEREDBY" id="ENTEREDBY">
								<option value=""></option>
								<option value="#session.username#">#session.username#</option>
							</select>
						</td>
					</tr>
					<tr>
						<td>
							NATURE_OF_ID
							<span class="likeLink" onclick="getDistinct('NATURE_OF_ID')">[ Show Distinct ]</span>
						</td>
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
						<td>
							ID_MADE_BY_AGENT
							<span class="likeLink" onclick="getDistinct('ID_MADE_BY_AGENT')">[ Show Distinct ]</span>
						</td>
						<td>
							<select name="ID_MADE_BY_AGENT" id="ID_MADE_BY_AGENT">
								<option value=""></option>
								<option value="{collector_agent_1}">{collector_agent_1}</option>
							</select>
						</td>
					</tr>
					<tr>
						<td>MADE_DATE</td>
						<td>
							<select name="MADE_DATE" id="MADE_DATE">
								<option value=""></option>
								<option value="{began_date}">{began_date}</option>
							</select>
						</td>
					</tr>
					<tr>
						<td>BEGAN_DATE</td>
						<td>
							<select name="BEGAN_DATE" id="BEGAN_DATE">
								<option value=""></option>
								<!----
								<option value="{verbatim_date}">{verbatim_date}</option>
								---->
							</select>
						</td>
					</tr>
					<tr>
						<td>ENDED_DATE</td>
						<td>
							<select name="ENDED_DATE" id="ENDED_DATE">
								<option value=""></option><!----
									<option value="{verbatim_date}">{verbatim_date}</option>
									---->
							</select>
						</td>
					</tr>
					<tr>
						<td>VERBATIM_LOCALITY</td>
						<td>
							<select name="VERBATIM_LOCALITY" id="VERBATIM_LOCALITY">
								<option value=""></option>
								<option value="{spec_locality}">{spec_locality}</option>
							</select>
						</td>
					</tr>
					<tr>
						<td>
							ORIG_LAT_LONG_UNITS
							<span class="likeLink" onclick="getDistinct('ORIG_LAT_LONG_UNITS')">[ Show Distinct ]</span>
						</td>
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
						<td>
							DATUM
							<span class="likeLink" onclick="getDistinct('DATUM')">[ Show Distinct ]</span>
						</td>
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
						<td>
							GEOREFERENCE_SOURCE
							<span class="likeLink" onclick="getDistinct('GEOREFERENCE_SOURCE')">[ Show Distinct ]</span>
						</td>
						<td>
							<input type="text" name="GEOREFERENCE_SOURCE" id="GEOREFERENCE_SOURCE">
							(don't know anything? Use "unknown".)
						</td>
					</tr>
					<tr>
						<td>
							MAX_ERROR_UNITS
							<span class="likeLink" onclick="getDistinct('MAX_ERROR_UNITS')">[ Show Distinct ]</span>
						</td>
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
						<td>
							GEOREFERENCE_PROTOCOL
							<span class="likeLink" onclick="getDistinct('GEOREFERENCE_PROTOCOL')">[ Show Distinct ]</span>
						</td>
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
								<option value="{collector_agent_1}">{collector_agent_1}</option>
							</select>
						</td>
					</tr>
					<tr>
						<td>
							EVENT_ASSIGNED_DATE
							<span class="likeLink" onclick="getDistinct('EVENT_ASSIGNED_DATE')">[ Show Distinct ]</span>
						</td>
						<td>
							<select name="EVENT_ASSIGNED_DATE" id="EVENT_ASSIGNED_DATE">
								<option value=""></option>
								<option value="verbatim_date">{verbatim_date}</option>
							</select>
						</td>
					</tr>
					<tr>
						<td>
							VERIFICATIONSTATUS
							<span class="likeLink" onclick="getDistinct('VERIFICATIONSTATUS')">[ Show Distinct ]</span>
						</td>
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
							<td>
								COLLECTOR_ROLE_#x#
								<span class="likeLink" onclick="getDistinct('COLLECTOR_ROLE_#x#')">[ Show Distinct ]</span>
							</td>
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
						<td>
							COLLECTION_CDE
							<span class="likeLink" onclick="getDistinct('COLLECTION_CDE')">[ Show Distinct ]</span>
						</td>
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
						<td>
							INSTITUTION_ACRONYM
							<span class="likeLink" onclick="getDistinct('INSTITUTION_ACRONYM')">[ Show Distinct ]</span>
						</td>
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
							<td>
								PART_CONDITION_#x#
								<span class="likeLink" onclick="getDistinct('PART_CONDITION_#x#')">[ Show Distinct ]</span>
							</td>
							<td>
								<select name="PART_CONDITION_#x#" id="PART_CONDITION_#x#">
									<option value=""></option>
									<option value="unchecked">unchecked</option>
								</select>
							</td>
						</tr>
						<tr>
							<td>
								PART_LOT_COUNT_#x#
								<span class="likeLink" onclick="getDistinct('PART_LOT_COUNT_#x#')">[ Show Distinct ]</span>
							</td>
							<td>
								<select name="PART_LOT_COUNT_#x#" id="PART_LOT_COUNT_#x#">
									<option value=""></option>
									<option value="1">1</option>
								</select>
							</td>
						</tr>
						<tr>
							<td>
								PART_DISPOSITION_#x#
								<span class="likeLink" onclick="getDistinct('PART_DISPOSITION_#x#')">[ Show Distinct ]</span>
							</td>
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
							<td>
								ATTRIBUTE_DATE_#x#
								<span class="likeLink" onclick="getDistinct('ATTRIBUTE_DATE_#x#')">[ Show Distinct ]</span>
							</td>
							<td>
								<select name="ATTRIBUTE_DATE_#x#" id="ATTRIBUTE_DATE_#x#">
									<option value=""></option>
									<option value="{began_date}">{began_date}</option>
								</select>
							</td>
						</tr>
						<tr>
							<td>
								ATTRIBUTE_DETERMINER_#x#
								<span class="likeLink" onclick="getDistinct('ATTRIBUTE_DETERMINER_#x#')">[ Show Distinct ]</span>
							</td>
							<td>
								<select name="ATTRIBUTE_DETERMINER_#x#" id="ATTRIBUTE_DETERMINER_#x#">
									<option value=""></option>
									<option value="{collector_agent_1}">{collector_agent_1}</option>
								</select>
							</td>
						</tr>
					</cfloop>
					<tr>
						<td>
							COLLECTING_SOURCE
							<span class="likeLink" onclick="getDistinct('COLLECTING_SOURCE')">[ Show Distinct ]</span>
						</td>
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
						<td>
							SPECIMEN_EVENT_TYPE
							<span class="likeLink" onclick="getDistinct('SPECIMEN_EVENT_TYPE')">[ Show Distinct ]</span>
						</td>
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
				<input type="submit" value="update everything">
			</form>
		</cfoutput>
	</cfif>
	<cfif action is "nothing">
		<cfoutput>
			<br>
			When to use this form:
			<ul>
				<li>You have otherwise-clean data with lots of missing homogenous default values.</li>
			</ul>
			When NOT to use this form:
			<ul>
				<li>You have messy data. (See Reports/Data Services.)</li>
				<li>You expect magic. (We have none.)</li>
				<li>You have missing heterogeneous values. (This form won't work.)</li>
				<li>
					You have no idea what you're trying to do. (This form will happily mess up all your data at once.)
				</li>
				<li>
					You're going to be a while - this is part of a single-user, shared application, and someone will probably over-write your data eventually.
					You can download (perhaps partially-cleaned) and re-upload data if you need a pause.
				</li>
			</ul>
			All of these options may eat your browser on large datasets. Use with caution.
			<ul>
				<li>
					<a href="BulkloaderStageCleanup.cfm?action=distinctValues">Show distinct values</a>
				</li>
				<li>
					<a href="BulkloaderStageCleanup.cfm?action=updateCommonDefaults">Update Common Defaults</a>
				</li>
				<li>
					<a href="BulkloaderStageCleanup.cfm?action=sql">Write SQL</a>
				</li>
		<li>
			<a href="BulkloaderStageCleanup.cfm?action=ajaxGrid">Edit in AJAX grid</a>
		</li>
	<li><a href="BulkloadSpecimens.cfm?action=checkStaged">check these records</a></li>

			</ul>
		</cfoutput>
	</cfif>
	<cfinclude template="/includes/_footer.cfm">
