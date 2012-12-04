<div id="msg"></div>
<div><!--- spacer ---></div>
<cfinclude template="/includes/_header.cfm">
<cfset title="Data Entry">
<link rel="stylesheet" type="text/css" href="/includes/_DEstyle.css">
<!---
<script type='text/javascript' src='/includes/jquery/suggest.js'></script>
--->

<script type='text/javascript' src='/includes/jquery/jquery-autocomplete/jquery.autocomplete.pack.js'></script>

<script type='text/javascript' src='/includes/DEAjax.js'></script>
<cf_showMenuOnly>
<!--- don't think this is necessary anymore
<cf_setDataEntryGroups>
---->
<cfif not isdefined("ImAGod") or len(ImAGod) is 0>
	<cfset ImAGod = "no">
</cfif>
<cfif isdefined("CFGRIDKEY") and not isdefined("collection_object_id")>
	<cfset collection_object_id = CFGRIDKEY>
</cfif>
<cfset collid = 1>
<cfif not isdefined("pMode") or len(pMode) is 0>
	<cfset pMode = "enter">
</cfif>
<cfset thisDate = dateformat(now(),"yyyy-mm-dd")>
<!--------------------------------------------------------------------------------------------------------->
<cfif action is "nothing">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_dataentry_settings where username='#session.username#'
		</cfquery>
		<cfif d.recordcount is not 1>
			<cfquery name="seed" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into cf_dataentry_settings (
					username
				) values (
					'#session.username#'
				)
			</cfquery>
		</cfif>
		<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from collection ORDER BY COLLECTION
		</cfquery>
		<cfloop query="c">
			<cfquery  name="isBL" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from bulkloader where collection_object_id = #collection_id#
			</cfquery>
			<cfif isBl.recordcount is 0>
				<cfquery name="prime" datasource="uam_god">
					insert into bulkloader (
						collection_object_id,
						institution_acronym,
						collection_cde,
						loaded,
						collection_id,
						entered_agent_id
					) VALUES (
						#collection_id#,
						'#institution_acronym#',
						'#collection_cde#',
						'#ucase(institution_acronym)# #ucase(collection_cde)# TEMPLATE',
						#collection_id#,
						0
					)
				</cfquery>
			<cfelseif isBL.loaded is not "#ucase(institution_acronym)# #ucase(collection_cde)# TEMPLATE">
				<cfquery name="move" datasource="uam_god">
					update bulkloader set collection_object_id = bulkloader_PKEY.nextval
					where collection_object_id = #collection_id#
				</cfquery>
				<cfquery name="prime" datasource="uam_god">
					insert into bulkloader (
						collection_object_id,
						institution_acronym,
						collection_cde,
						loaded,
						collection_id,
						entered_agent_id
					) VALUES (
						#collection_id#,
						'#institution_acronym#',
						'#collection_cde#',
						'#ucase(institution_acronym)# #ucase(collection_cde)# TEMPLATE',
						#collection_id#,
						0
					)
				</cfquery>
			</cfif>
		</cfloop>
		Welcome to Data Entry, #session.username#
		<ul>
			<li>Green Screen: You are entering data to a new record.</li>
			<li>Blue Screen: you are editing an unloaded record that you've previously entered.</li>
			<li>Yellow Screen: A record has been saved but has errors that must be corrected. Fix and save to continue.</li>
		</ul>
    	<p><a href="/Bulkloader/cloneWithBarcodes.cfm">Clone records by Barcode</a></p>
		<cfquery name="theirLast" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				max(collection_object_id) theId,
				collection_cde collnCde,
				institution_acronym instAc
			from bulkloader where enteredby = '#session.username#'
			GROUP BY
				collection_cde,
				institution_acronym
		</cfquery>
		Begin at....<br>
		<form name="begin" method="post" action="DataEntry.cfm">
			<input type="hidden" name="action" value="editEnterData" />
			<select name="collection_object_id" size="1">
				<cfif theirLast.recordcount gt 0>
					<cfloop query="theirLast">
						<cfquery name="temp" dbtype="query">
							select collection from c where institution_acronym='#instAc#' and collection_cde='#collnCde#'
						</cfquery>
						<option value="#theId#">Your Last #temp.collection#</option>
					</cfloop>
				</cfif>
				<cfloop query="c">
					<option value="#collection_id#">Enter a new #collection# Record</option>
				</cfloop>
			</select>
			<input class="lnkBtn" type="submit" value="Enter Data"/>
		</form>
	</cfoutput>
</cfif>
<cfif action is "saveCust">
	<cfdump var=#form#>
</cfif>
<!------------ editEnterData --------------------------------------------------------------------------------------------->
<cfif action is "editEnterData">
	<cfoutput>
		<cfif not isdefined("collection_object_id") or len(collection_object_id) is 0>
			you don't have an ID. <cfabort>
		</cfif>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from bulkloader where collection_object_id=#collection_object_id#
		</cfquery>
		<cfif collection_object_id GT 100>
			<cfquery name="chk" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select bulk_check_one(#collection_object_id#) rslt from dual
			</cfquery>
			<cfset loadedMsg=chk.rslt>
		<cfelse>
			<cfset loadedMsg = "">
		</cfif>
	</cfoutput>
	<cfoutput query="data">
		<cfquery name="ctInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			SELECT institution_acronym || ' ' || collection_cde as instcoll, collection_id FROM collection
				<cfif len(collection_cde) gt 0>
					WHERE collection_cde='#collection_cde#'
				</cfif>
		</cfquery>
		<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select collection_cde,institution_acronym,collection from collection order by collection
		</cfquery>
		<cfquery name="ctnature" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select nature_of_id from ctnature_of_id order by nature_of_id
		</cfquery>
		<cfquery name="ctunits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       select ORIG_LAT_LONG_UNITS from ctLAT_LONG_UNITS order by orig_lat_long_units
	    </cfquery>
		<cfquery name="ctflags" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       select flags from ctflags order by flags
	    </cfquery>
		<cfquery name="CTCOLL_OBJ_DISP" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP order by coll_obj_DISPOSITION
	    </cfquery>
		<cfquery name="cterror" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	    	select LAT_LONG_ERROR_UNITS from ctLAT_LONG_ERROR_UNITS order by lat_long_error_units
	    </cfquery>
		<cfquery name="ctdatum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select datum from ctdatum order by datum
	    </cfquery>
		<cfquery name="ctgeorefmethod" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select georefmethod from ctgeorefmethod order by georefmethod
	    </cfquery>
		<cfquery name="ctverificationstatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select verificationstatus from ctverificationstatus order by verificationstatus
	    </cfquery>
		<cfquery name="ctcollecting_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select collecting_source from ctcollecting_source order by collecting_source
	    </cfquery>
	    <cfquery name="ctew" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	    	select e_or_w from ctew order by e_or_w
	    </cfquery>
	    <cfquery name="ctns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select n_or_s from ctns order by n_or_s
	    </cfquery>
		<cfquery name="ctOtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			SELECT distinct(other_id_type) FROM ctColl_Other_id_type
			order by other_id_type
	    </cfquery>
		<cfquery name="ctOrigElevUnits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select orig_elev_units from ctorig_elev_units
	    </cfquery>
		<cfquery name="ctbiol_relations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	      	select BIOL_INDIV_RELATIONSHIP from ctbiol_relations
			order by BIOL_INDIV_RELATIONSHIP
	    </cfquery>
		<cfquery name="ctgeoreference_protocol" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select georeference_protocol from ctgeoreference_protocol order by georeference_protocol
		</cfquery>
		<cfquery name="ctspecimen_event_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select specimen_event_type from ctspecimen_event_type order by specimen_event_type
		</cfquery>
		<cfquery name="ctgeology_attribute" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select geology_attribute from ctgeology_attribute order by geology_attribute
		</cfquery>
		<cfquery name="ctCodes" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				attribute_type,
				value_code_table,
				units_code_table
		 	from ctattribute_code_tables
		</cfquery>
		<cfset sql = "select collection_object_id from bulkloader where collection_object_id > 100 and rownum<1001">
		<cfif ImAGod is "no">
			 <cfset sql = "#sql# AND enteredby = '#session.username#'">
		</cfif>
		<cfset sql = "#sql# order by collection_object_id">
		<cfquery name="whatIds" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#preservesinglequotes(sql)#
		</cfquery>
		<cfset idList=valuelist(whatIds.collection_object_id)>
		<cfset currentPos = listFind(idList,data.collection_object_id)>
		<cfif len(loadedMsg) gt 0>
			<cfset loadedMsg = right(loadedMsg,len(loadedMsg) - 2)>
			<cfset pageTitle = replace(loadedMsg,"::","","all")>
		<cfelse>
			<cfset pageTitle = "This record has passed all bulkloader checks!">
		</cfif>
		<div id="splash"align="center">
			<span style="background-color:##FF0000; font-size:large;">
				Page Loading....
			</span>
		</div>
		<form name="dataEntry" method="post" action="DataEntry.cfm" onsubmit="return cleanup(); return noEnter();" id="dataEntry">
			<input type="hidden" name="action" value="" id="action">
			<input type="hidden" name="nothing" value="" id="nothing"/><!--- trashcan for picks - don't delete --->
			<input type="hidden" name="ImAGod" value="#ImAGod#" id="ImAGod"><!--- allow power users to browse other's records --->
			<input type="hidden" name="collection_cde" value="#collection_cde#" id="collection_cde">
			<input type="hidden" name="institution_acronym" value="#institution_acronym#" id="institution_acronym">
			<input type="hidden" name="collection_object_id" value="#collection_object_id#"  id="collection_object_id"/>
			<input type="hidden" name="pMode" value="#pMode#"  id="pMode"/>
			<input type="hidden" name="loaded" value="waiting approval"  id="loaded"/>
			<table width="100%" cellspacing="0" cellpadding="0" id="theTable" style=""> <!--- display:none-------whole page table --->
				<tr>
					<td colspan="2" style="border-bottom: 1px solid black; " align="center">
						<div id="loadedMsgDiv">
							#loadedMsg#
						</div>
					</td>
				</tr>
				<tr><td width="50%" valign="top"><!--- left top of page --->
					<table cellpadding="0" cellspacing="0" class="fs"><!--- cat item IDs --->
						<tr>
							<td valign="middle">
								#institution_acronym#:#collection_cde#
							</td>
							<td class="valigntop">
								<label for="cat_num">Cat##</label>
								<input type="text" name="" value="#cat_num#"  size="6" id="cat_num">
								<span id="catNumLbl" class="f11a"></span>
							</td>
							<td class="valigntop">
								<cfif (isdefined("session.CustomOtherIdentifier") and len(session.CustomOtherIdentifier) gt 0) or
										isdefined("data.other_id_num_type_5") and len(data.other_id_num_type_5) gt 0>
									<cfif isdefined("data.other_id_num_type_5") and len(data.other_id_num_type_5) gt 0>
										<cfset thisID=data.other_id_num_type_5>
									<cfelse>
										<cfset thisID=session.CustomOtherIdentifier>
									</cfif>
									<label for="other_id_num_type_5">CustomID Type</label>
									<select name="other_id_num_type_5" style="width:180px"
										id="other_id_num_type_5"
										onChange="this.className='reqdClr';dataEntry.other_id_num_5.className='reqdClr';dataEntry.other_id_num_5.focus();">
										<option value=""></option>
										<cfloop query="ctOtherIdType">
											<option <cfif thisID is ctOtherIdType.other_id_type> selected="selected" </cfif>
												value="#other_id_type#">#other_id_type#</option>
										</cfloop>
									</select>
							</td>
							<td class="valigntop">
									<label for="other_id_num_5">CustomID</label>
									<input type="text" name="other_id_num_5" size="8" id="other_id_num_5">
								<cfelse>
									<input type="hidden" name="other_id_num_type_5" id="other_id_num_type_5" value=''.
									<input type="hidden" name="other_id_num_5" id="other_id_num_5" value=''>
								</cfif>
							</td>
							<td class="nowrap valigntop">
								<label for="accn">Accn</label><br>
								<input type="text" name="accn" value="#accn#" size="25" class="reqdClr" id="accn" onchange="getAccn(this.value,this.id,'#institution_acronym#:#collection_cde#');">
								<span class="infoLink" onclick="var an=$('##accn').val();getAccn(an,'accn','#institution_acronym#:#collection_cde#');">[ pick ]</span>
							</td>
							<td class="nowrap valignmiddle">
								<span id="customizeForm" class="infoLink" onclick="customize()">[ customize form ]</span>
								<br><span id="calControl" class="infoLink" onclick="removeCalendars();">[ disable calendars ]</span>
							</td>
						</tr>
					</table><!---------------------------------- / cat item IDs ---------------------------------------------->
					<table cellpadding="0" cellspacing="0" class="fs"><!--- agents --->
						<tr>
							<td rowspan="99" valign="top">
								<img src="/images/info.gif" border="0" onClick="getDocs('agent')" class="likeLink" alt="[ help ]">
							</td>
							<cfloop from="1" to="5" index="i">
								<cfif i is 1 or i is 3 or i is 5><tr></cfif>
								<td id="d_collector_role_#i#" align="right">
									<select name="collector_role_#i#" size="1" <cfif i is 1>class="reqdClr"</cfif> id="collector_role_#i#">
										<option <cfif evaluate("data.collector_role_" & i) is "c">selected="selected"</cfif> value="c">Collector</option>
										<cfif i gt 1>
											<option <cfif evaluate("data.collector_role_" & i) is "p">selected="selected"</cfif> value="p">Preparator</option>
										</cfif>
									</select>
								</td>
								<td  id="d_collector_agent_#i#" nowrap="nowrap">
									<span class="f11a">#i#</span>
									<input type="text" name="collector_agent_#i#" value="#evaluate("data.collector_agent_" & i)#"
										<cfif i is 1>class="reqdClr"</cfif> id="collector_agent_#i#"
										onchange="getAgent('nothing',this.id,'dataEntry',this.value);"
										onkeypress="return noenter(event);">
									<span class="infoLink" onclick="copyAllAgents('collector_agent_#i#');">Copy2All</span>
								</td>
								<cfif i is 2 or i is 4 or i is 5></tr></cfif>
							</cfloop>
					</table><!---- / agents------------->
					<table cellpadding="0" cellspacing="0" class="fs"><!------ other IDs ------------------->
						<tr>
							<td rowspan="99" valign="top">
								<img src="/images/info.gif" border="0" onClick="getDocs('cataloged_item','other_id')" class="likeLink" alt="[ help ]">
							</td>
						</tr>
						<cfloop from="1" to="4" index="i">
							<tr>
								<td id="d_other_id_num_#i#">
									<span class="f11a">OtherID #i#</span>
									<select name="other_id_num_type_#i#" style="width:250px"
										id="other_id_num_type_#i#"
										onChange="this.className='reqdClr';dataEntry.other_id_num_#i#.className='reqdClr';dataEntry.other_id_num_#i#.focus();">
										<option value=""></option>
										<cfloop query="ctOtherIdType">
											<option <cfif evaluate("data.other_id_num_type_" & i) is ctOtherIdType.other_id_type> selected="selected" </cfif>
												value="#other_id_type#">#other_id_type#</option>
										</cfloop>
									</select>
									<input type="text" name="other_id_num_#i#" value="#evaluate("data.other_id_num_" & i)#" id="other_id_num_#i#">
									<span class="infoLink" onclick="getRelatedData(#i#)">[ pull ]</span>
								</td>
							</tr>
						</cfloop>
					</table><!---- /other IDs ---->
					<table cellpadding="0" cellspacing="0" class="fs"><!----- identification ----->
						<tr>
							<td rowspan="99" valign="top">
								<img src="/images/info.gif" border="0" onClick="getDocs('identification')" class="likeLink" alt="[ help ]">
							</td>
							<td align="right">
								<span class="f11a">Scientific&nbsp;Name</span>
							</td>
							<td width="100%">
								<input type="text" name="taxon_name" value="#taxon_name#" class="reqdClr" size="40"
									id="taxon_name"
									onchange="taxaPick('nothing',this.id,'dataEntry',this.value)">
							</td>
						</tr>
						<tr>
							<td align="right"><span class="f11a">ID By</span></td>
							<td>
								<input type="text" name="id_made_by_agent" value="#id_made_by_agent#" class="reqdClr" size="40"
									id="id_made_by_agent"
									onchange="getAgent('nothing',this.id,'dataEntry',this.value);"
									onkeypress="return noenter(event);">
								<span class="infoLink" onclick="copyAllAgents('id_made_by_agent');">Copy2All</span>
							</td>
						</tr>
						<tr>
							<td align="right"><span class="f11a">Nature</span></td>
							<td>
								<select name="nature_of_id" class="reqdClr" id="nature_of_id">
									<cfloop query="ctnature">
										<option <cfif data.nature_of_id is ctnature.nature_of_id> selected="selected" </cfif>
											value="#ctnature.nature_of_id#">#ctnature.nature_of_id#</option>
									</cfloop>
								</select>
							</td>
						</tr>
						<tr>
							<td align="right"><span class="f11a">Date</span></td>
							<td>
								<input type="text " name="made_date" value="#made_date#" id="made_date">
								<span class="infoLink" onclick="copyAllDates('made_date');">Copy2All</span>
							</td>
						</tr>
						<tr id="d_identification_remarks">
							<td align="right"><span class="f11a">ID Remk</span></td>
							<td><input type="text" name="identification_remarks" value="#identification_remarks#"
								id="identification_remarks" size="80">
							</td>
						</tr>
					</table><!------ /identification -------->
					<table cellpadding="0" cellspacing="0" class="fs"><!----- attributes ------->
						<tr>
							<td id="attributeTableCell">
								<cfinclude template="/form/DataEntryAttributeTable.cfm">
							</td>
						</tr>
					</table><!---- /attributes ----->
					<table cellpadding="0" cellspacing="0" class="fs"><!--- random admin stuff ---->
					<tr>
						<td align="right"><span class="f11a">Entered&nbsp;By</span></td>
						<td width="100%">
							<cfif ImAGod is not "yes">
								<cfset eby=session.username>
							<cfelseif ImAGod is "yes">
								<cfset eby=enteredby>
							<cfelse>
								ERROR!!!
							</cfif>
							<input type="hidden" name="enteredby" value="#eby#" id="enteredby">
							#eby#
						</td>
					</tr>
					<tr id="d_relationship">
						<td align="right"><span class="f11a">Relations</span></td>
						<td>
							<cfset thisRELATIONSHIP = RELATIONSHIP>
							<select name="relationship" size="1" id="relationship">
								<option value=""></option>
								<cfloop query="ctbiol_relations">
									<option
										<cfif thisRELATIONSHIP is BIOL_INDIV_RELATIONSHIP> selected="selected" </cfif>
									 value="#BIOL_INDIV_RELATIONSHIP#">#BIOL_INDIV_RELATIONSHIP#</option>
								</cfloop>
							</select>
							<cfset thisRELATED_TO_NUM_TYPE = RELATED_TO_NUM_TYPE>
							<select name="related_to_num_type" size="1" id="related_to_num_type" style="width:150px">
								<option value=""></option>
								<option <cfif thisRELATED_TO_NUM_TYPE is "catalog number">selected="selected"</cfif> value="catalog number">catalog number (UAM:Mamm:123 format)</option>
								<cfloop query="ctOtherIdType">
									<option
										<cfif thisRELATED_TO_NUM_TYPE is other_id_type> selected="selected" </cfif>
									 value="#other_id_type#">#other_id_type#</option>
								</cfloop>
							</select>
							<input type="text" value="#related_to_number#" name="related_to_number" id="related_to_number" size="20" />
							<span class="likeLink" onclick="getRelatedSpecimenData()">[ pick/use ]</span>
						</td>
					</tr>
				</table><!------ random admin stuff ---------->
				<table cellpadding="0" cellspacing="0" class="fs"><!------- remarkey stuff --->
					<tr id="d_coll_object_remarks">
						<td colspan="2">
							<span class="f11a">Spec Remark</span>
								<textarea name="coll_object_remarks" id="coll_object_remarks" rows="2" cols="80">#coll_object_remarks#</textarea>
						</td>
					</tr>
					<tr id="d_associated_species">
						<td align="right"><span class="f11a">Associated&nbsp;Species</span></td>
						<td>
							<input type="text" name="associated_species" size="80" id="associated_species" value="#associated_species#">
						</td>
					</tr>
					<tr>
						<td id="d_flags">
							<span class="f11a">Missing....</span>
							<cfset thisflags = flags>
							<select name="flags" size="1" style="width:120px" id="flags">
								<option  value=""></option>
								<cfloop query="ctflags">
									<option <cfif flags is thisflags> selected </cfif>
										value="#flags#">#flags#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<span class="f11a">Status</span>
							#loaded#
						</td>
					</tr>
				</table><!------- /remarkey stuff --->

				</td> <!---- end top left --->
				<td valign="top"><!----- right column ---->
				<label onClick="getDocs('specimen_event')" class="likeLink" for="loctbl">Specimen/Event</label>
					<table cellspacing="0" cellpadding="0" class="fs"><!----- Specimen/Event ---------->
						<tr>
							<td colspan="2">
								<table>
									<tr>
										<td align="right">
											<span class="f11a">Event Assigned By
										</td>
										<td>
											<input type="text" name="event_assigned_by_agent" value="#event_assigned_by_agent#" class="reqdClr"
												id="event_assigned_by_agent"
												onchange="getAgent('nothing',this.id,'dataEntry',this.value);"
												onkeypress="return noenter(event);">
										</td>
										<td align="right"><span class="f11a">On Date</span></td>
										<td>
											<input type="text" name="event_assigned_date" class="reqdClr" value="#event_assigned_date#" id="event_assigned_date">
											<span class="infoLink" onclick="copyAllDates('event_assigned_date');">Copy2All</span>
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td align="right"><span class="f11a">Specimen/Event Type</span></td>
							<td>
								<select name="specimen_event_type" size="1" id="specimen_event_type" class="reqdClr">
									<cfloop query="ctspecimen_event_type">
										<option <cfif ctspecimen_event_type.specimen_event_type is data.specimen_event_type> selected="selected" </cfif>
											value="#ctspecimen_event_type.specimen_event_type#">#ctspecimen_event_type.specimen_event_type#</option>
									</cfloop>
								</select>
							</td>
						</tr>
						<tr>
							<td align="right"><span class="f11a">Coll. Meth.:</span></td>
							<td>
								<table cellspacing="0" cellpadding="0">
									<tr>
										<td>
											<input type="text" name="collecting_method" value="#collecting_method#" id="collecting_method">
										</td>
										<td align="right"><span class="f11a">Coll. Src.:</span></td>
										<td>
											<cfif len(collecting_source) gt 0>
												<cfset thisCollSrc=collecting_source>
											<cfelse>
												<cfset thisCollSrc="wild caught">
											</cfif>
											<select name="collecting_source"
												size="1"
												id="collecting_source"
												class="reqdClr">
												<option value=""></option>
												<cfloop query="ctcollecting_source">
													<option
														<cfif collecting_source is thisCollSrc> selected </cfif>
														value="#collecting_source#">#collecting_source#</option>
												</cfloop>
											</select>
										</td>
									</tr>
								</table>
							</td>
						</tr>

						<tr id="d_habitat_desc">
							<td align="right"><span class="f11a">Habitat</span></td>
							<td>
								<input type="text" name="habitat" size="50" id="habitat" value="#habitat#">
							</td>
						</tr>
						<tr>
							<td align="right"><span class="f11a">VerificationStatus</span></td>
							<td>
								<select name="verificationstatus" size="1" class="reqdClr" id="verificationstatus">
									<cfloop query="ctverificationstatus">
										<option <cfif data.verificationstatus is ctverificationstatus.verificationstatus> selected="selected" </cfif>
									  		value="#ctverificationstatus.verificationstatus#">#ctverificationstatus.verificationstatus#</option>
									</cfloop>
								</select>
							</td>
						</tr>
						<tr>
							<td align="right"><span class="f11a">Specimen/Event Remark</span></td>
							<td>
								<input type="text"  name="specimen_event_remark" class="" size="80"
									id="specimen_event_remark" value="#stripQuotes(specimen_event_remark)#">
							</td>
						</tr>
					</table>
					<label onClick="getDocs('collecting_event')" class="likeLink" for="loctbl">Collecting Event</label>
					<table cellspacing="0" cellpadding="0" class="fs">
						<tr>
							<td colspan="2">
								<table>
									<tr>
										<td align="right"><span class="f11a">Event Name</span></td>
										<td>
											<input type="text" name="collecting_event_name" class="" id="collecting_event_name" value="#collecting_event_name#" size="60"
												onchange="findCollEvent('collecting_event_id','dataEntry','verbatim_locality',this.value);">
										</td>
										<td id="d_collecting_event_id">
											<label for="collecting_event_id">Existing&nbsp;EventID</label>
										</td><td>
											<input type="text" name="collecting_event_id" id="collecting_event_id" value="#collecting_event_id#" class="readClr" size="8">
											<input type="hidden" id="fetched_eventid">
										</td>
										<td>
											<span class="infoLink" id="eventPicker" onclick="findCollEvent('collecting_event_id','dataEntry','verbatim_locality'); return false;">
												Pick&nbsp;Event
											</span>
											<span class="infoLink" id="eventUnPicker" style="display:none;" onclick="unpickEvent()">
												Depick&nbsp;Event
											</span>
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td align="right"><span class="f11a">Verbatim Locality</span></td>
							<td>
								<input type="text"  name="verbatim_locality"
									class="reqdClr" size="80"
									id="verbatim_locality" value="#stripQuotes(verbatim_locality)#">
								<span class="infoLink" onclick="document.getElementById('verbatim_locality').value=document.getElementById('spec_locality').value;">
									&nbsp;Use&nbsp;Specloc
								</span>
							</td>
						</tr>
						<tr>
							<td align="right"><span class="f11a">VerbatimDate</span></td>
							<td>
								<input type="text" name="verbatim_date" class="reqdClr" value="#verbatim_date#" id="verbatim_date" size="20">
								<span class="infoLink"
									onClick="copyVerbatim($('##verbatim_date').val());">--></span>
								<span class="f11a">Begin</span>
								<input type="text" name="began_date" class="reqdClr" value="#began_date#" id="began_date" size="10">
								<span class="infoLink" onclick="copyBeganEnded();">>></span>
								<span class="f11a">End</span>
								<input type="text" name="ended_date" class="reqdClr" value="#ended_date#" id="ended_date" size="10">
								<span class="infoLink" onclick="copyAllDates('ended_date');">Copy2All</span>
							</td>
						</tr>
						<tr id="d_coll_event_remarks">
							<td align="right"><span class="f11a">CollEvntRemk</span></td>
							<td>
								<input type="text" name="coll_event_remarks" size="80" value="#coll_event_remarks#" id="coll_event_remarks">
							</td>
						</tr>
						<tr>
							<td colspan="2" id="dateConvertStatus"></td>
						</tr>
					</table>
					<label onClick="getDocs('locality')" class="likeLink" for="loctbl">Locality</label>
					<table cellspacing="0" cellpadding="0" class="fs">
						<tr>
							<td align="right"><span class="f11a">Higher Geog</span></td>
							<td>
								<input type="text" name="higher_geog" class="reqdClr" id="higher_geog" value="#higher_geog#" size="80"
									onchange="getGeog('nothing',this.id,'dataEntry',this.value)">
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<table>
									<tr>
										<td align="right"><span class="f11a">Locality Name</span></td>
										<td>
											<input type="text" name="locality_name" class="" id="locality_name" value="#locality_name#" size="60"
												onchange="LocalityPick('locality_id','spec_locality','dataEntry',this.value);">
										</td>
										<td id="d_locality_id">
											<label for="fetched_locid">Existing&nbsp;LocalityID</label>
										</td><td>
											<input type="hidden" id="fetched_locid">
											<input type="text" name="locality_id" id="locality_id" value="#locality_id#" class="readClr" size="8">
										</td>
										<td>
											<span class="infoLink" id="localityPicker"
												onclick="LocalityPick('locality_id','spec_locality','dataEntry',''); return false;">
												Pick&nbsp;Locality
											</span>
											<span class="infoLink"
												id="localityUnPicker"
												style="display:none;"
												onclick="unpickLocality()">
												Depick&nbsp;Locality
											</span>
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td align="right"><span class="f11a">Spec Locality</span></td>
							<td>
								<input type="text" name="spec_locality" class="reqdClr" id="spec_locality" value="#spec_locality#" size="80">
								<span class="infoLink" onclick="document.getElementById('spec_locality').value=document.getElementById('verbatim_locality').value;">
									&nbsp;Use&nbsp;VerbLoc
								</span>
							</td>
						</tr>
						<tr>
							<td colspan="2" id="d_orig_elev_units">
								<label for="minimum_elevation">Elevation (min-max)</label>
								<span class="f11a">&nbsp;between</span>
								<input type="text" name="minimum_elevation" size="4" value="#minimum_elevation#" id="minimum_elevation">
								<span class="infoLink"
									onclick="document.getElementById('maximum_elevation').value=document.getElementById('minimum_elevation').value";>&nbsp;>>&nbsp;</span>
								<input type="text" name="maximum_elevation" size="4" value="#maximum_elevation#" id="maximum_elevation">
								<select name="orig_elev_units" size="1" id="orig_elev_units">
									<option value=""></option>
									<cfloop query="ctOrigElevUnits">
										<option
											<cfif data.orig_elev_units is ctOrigElevUnits.orig_elev_units> selected="selected" </cfif>
											value="#orig_elev_units#">#orig_elev_units#</option>
									</cfloop>
								</select>
							</td>
						</tr>

						<tr id="d_locality_remarks">
							<td align="right"><span class="f11a">LocalityRemk</span></td>
							<td>
								<input type="text" name="locality_remarks" size="80" value="#locality_remarks#" id="locality_remarks">
							</td>
						</tr>
					</table><!----- /locality ---------->

					<label onClick="getDocs('coordinates')" class="likeLink" for="loctbl">Coordinates (event and locality)</label>
				<table cellpadding="0" cellspacing="0" class="fs" id="d_orig_lat_long_units"><!------- coordinates ------->
					<tr>
						<td rowspan="99" valign="top">
							<img src="/images/info.gif" border="0" onClick="getDocs('lat_long')" class="likeLink" alt="[ help ]">
						</td>
						<td>
							<table>
								<tr>
									<td align="right"  valign="top"><span class="f11a">Original&nbsp;lat/long&nbsp;Units</span></td>
									<td colspan="99" width="100%">
										<table>
											<tr>
												<td valign="top">
													<cfset thisLLUnits=#ORIG_LAT_LONG_UNITS#>
													<select name="orig_lat_long_units" id="orig_lat_long_units"
														onChange="switchActive(this.value);dataEntry.max_error_distance.focus();">
														<option value=""></option>
														<cfloop query="ctunits">
														  <option <cfif data.orig_lat_long_units is ctunits.orig_lat_long_units> selected="selected" </cfif>
														  	value="#ctunits.ORIG_LAT_LONG_UNITS#">#ctunits.ORIG_LAT_LONG_UNITS#</option>
														</cfloop>
													</select>
												</td>
												<td valign="top">
													<span style="font-size:small" class="likeLink" onclick="geolocate()">[ geolocate ]</span>
												</td>
												<td valign="top">
													<div id="geoLocateResults" style="font-size:small">geolocate messages go here</div>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<tr>
						<td>
							<div id="lat_long_meta" class="noShow">
								<table cellpadding="0" cellspacing="0">
									<tr>
										<td align="right"><span class="f11a">Max Error</span></td>
										<td>
											<input type="text" name="max_error_distance" id="max_error_distance" value="#max_error_distance#" size="10">
											<select name="max_error_units" size="1" id="max_error_units">
												<option value=""></option>
												<cfloop query="cterror">
												  <option
												  <cfif cterror.LAT_LONG_ERROR_UNITS is data.max_error_units> selected="selected" </cfif>
												  	value="#cterror.LAT_LONG_ERROR_UNITS#">#cterror.LAT_LONG_ERROR_UNITS#</option>
												</cfloop>
											</select>
										</td>
									</tr>
									<tr>
										<td align="right"><span class="f11a">Datum</span></td>
										<td>
											<select name="datum" size="1" class="reqdClr" id="datum">
												<option value=""></option>
												<cfloop query="ctdatum">
													<option <cfif data.datum is ctdatum.datum> selected="selected" </cfif>
												 		value="#datum#">#datum#</option>
												</cfloop>
											</select>
										</td>
									</tr>


									<tr>
										<td align="right"><span class="f11a">Georeference Source</span></td>
										<td colspan="3" nowrap="nowrap">
											<input type="text" name="georeference_source" id="georeference_source"  class="reqdClr" size="60" value="#georeference_source#">
										</td>
									</tr>
									<tr>
										<td align="right"><span class="f11a">Georeference Protocol</span></td>
										<td>
											<select name="georeference_protocol" size="1" class="reqdClr" style="width:130px" id="georeference_protocol">
												<cfloop query="ctgeoreference_protocol">
													<option <cfif data.georeference_protocol is ctgeoreference_protocol.georeference_protocol> selected="selected" </cfif>
														value="#ctgeoreference_protocol.georeference_protocol#">#ctgeoreference_protocol.georeference_protocol#</option>
												</cfloop>
											</select>
										</td>
									</tr>
								</table>
							</div>
							<div id="dms" class="noShow">
								<table cellpadding="0" cellspacing="0">
									<tr>
										<td align="right"><span class="f11a">Lat Deg</span></td>
										<td>
											<input type="text" name="latdeg" size="4" id="latdeg" class="reqdClr" value="#latdeg#">
										</td>
										<td align="right"><span class="f11a">Min</span></td>
										<td>
											<input type="text"
												 name="LATMIN"
												size="4"
												id="latmin"
												class="reqdClr"
												value="#LATMIN#">
										</td>
										<td align="right"><span class="f11a">Sec</span></td>
										<td>
											<input type="text"
												 name="latsec"
												size="6"
												id="latsec"
												class="reqdClr"
												value="#latsec#">
											</td>
										<td align="right"><span class="f11a">Dir</span></td>
										<td>
											<select name="latdir" size="1" id="latdir" class="reqdClr">
												<option value=""></option>
												<option <cfif #LATDIR# is "N"> selected </cfif>value="N">N</option>
												<option <cfif #LATDIR# is "S"> selected </cfif>value="S">S</option>
											  </select>
										</td>
									</tr>
									<tr>
										<td align="right"><span class="f11a">Long Deg</span></td>
										<td>
											<input type="text"
												name="longdeg"
												size="4"
												id="longdeg"
												class="reqdClr"
												value="#longdeg#">
										</td>
										<td align="right"><span class="f11a">Min</span></td>
										<td>
											<input type="text"
												name="longmin"
												size="4"
												id="longmin"
												class="reqdClr"
												value="#longmin#">
										</td>
										<td align="right"><span class="f11a">Sec</span></td>
										<td>
											<input type="text"
												 name="longsec"
												size="6"
												id="longsec"
												class="reqdClr"
												value="#longsec#">
										</td>
										<td align="right"><span class="f11a">Dir</span></td>
										<td>
											<select name="longdir" size="1" id="longdir" class="reqdClr">
												<option value=""></option>
												<option <cfif #LONGDIR# is "E"> selected </cfif>value="E">E</option>
												<option <cfif #LONGDIR# is "W"> selected </cfif>value="W">W</option>
											  </select>
										</td>
									</tr>
								</table>
							</div>
							<div id="ddm" class="noShow">
								<table cellpadding="0" cellspacing="0">
									<tr>
										<td align="right"><span class="f11a">Lat Deg</span></td>
										<td>
											<input type="text"
												 name="decLAT_DEG"
												size="4"
												id="decLAT_DEG"
												class="reqdClr"
												value="#latdeg#"
												onchange="dataEntry.latdeg.value=this.value;">
										</td>
										<td align="right"><span class="f11a">Dec Min</span></td>
										<td>
											<input type="text"
												name="dec_lat_min"
												 size="8"
												id="dec_lat_min"
												class="reqdClr"
												value="#dec_lat_min#">
										</td>
										<td align="right"><span class="f11a">Dir</span></td>
										<td>
											<select name="decLAT_DIR"
												size="1"
												id="decLAT_DIR"
												class="reqdClr"
												onchange="dataEntry.latdir.value=this.value;">
												<option value=""></option>
												<option <cfif #LATDIR# is "N"> selected </cfif>value="N">N</option>
												<option <cfif #LATDIR# is "S"> selected </cfif>value="S">S</option>
											</select>
										</td>
									</tr>
									<tr>
										<td align="right"><span class="f11a">Long Deg</span></td>
										<td>
											<input type="text"
												name="decLONGDEG"
												size="4"
												id="decLONGDEG"
												class="reqdClr"
												value="#longdeg#"
												onchange="dataEntry.longdeg.value=this.value;">
										</td>
										<td align="right"><span class="f11a">Dec Min</span></td>
										<td>
											<input type="text"
												name="DEC_LONG_MIN"
												size="8"
												id="dec_long_min"
												class="reqdClr"
												value="#DEC_LONG_MIN#">
										</td>
										<td align="right"><span class="f11a">Dir</span></td>
										<td>
											<select name="decLONGDIR"
												 size="1"
												id="decLONGDIR"
												class="reqdClr"
												onchange="dataEntry.longdir.value=this.value;">
												<option value=""></option>
												<option <cfif #LONGDIR# is "E"> selected </cfif>value="E">E</option>
												<option <cfif #LONGDIR# is "W"> selected </cfif>value="W">W</option>
											</select>
										</td>
									</tr>
								</table>
							</div>
							<div id="dd" class="noShow">
								<span class="f11a">Dec Lat</span>
								<input type="text"
									 name="dec_lat"
									size="8"
									id="dec_lat"
									class="reqdClr"
									value="#dec_lat#">
								<span class="f11a">Dec Long</span>
									<input type="text"
										 name="dec_long"
										size="8"
										id="dec_long"
										class="reqdClr"
										value="#dec_long#">
							</div>
							<div id="utm" class="noShow">
								<span class="f11a">UTM Zone</span>
								<input type="text"
									 name="utm_zone"
									size="8"
									id="utm_zone"
									class="reqdClr"
									value="#utm_zone#">
								<span class="f11a">UTM E/W</span>
								<input type="text"
									 name="utm_ew"
									size="8"
									id="utm_ew"
									class="reqdClr"
									value="#utm_ew#">
								<span class="f11a">UTM N/S</span>
								<input type="text"
									 name="utm_ns"
									size="8"
									id="utm_ns"
									class="reqdClr"
									value="#utm_ns#">
							</div>
						</td>
					</tr>
				</table><!---- /coordinates ---->
				<cfif collection_cde is "ES"><!--- geology ---->
					<div id="geolCell">
						<table cellpadding="0" cellspacing="0" class="fs">
							<tr>
								<td>
									<img src="/images/info.gif" border="0" onClick="getDocs('geology_attributes')" class="likeLink" alt="[ help ]">
									<table cellpadding="0" cellspacing="0">
										<tr>
											<th nowrap="nowrap"><span class="f11a">Geol Att.</span></th>
											<th><span class="f11a">Geol Att. Value</span></th>
											<th><span class="f11a">Determiner</span></th>
											<th><span class="f11a">Date</span></th>
											<th><span class="f11a">Method</span></th>
											<th><span class="f11a">Remark</span></th>
										</tr>
										<cfloop from="1" to="6" index="i">
											<cfset thisAttribute= evaluate("data.geology_attribute_" & i)>
											<cfset thisVal= evaluate("data.geo_att_value_" & i)>
											<cfset thisDeterminer= evaluate("data.geo_att_determiner_" & i)>
											<cfset thisDate= evaluate("data.geo_att_determined_date_" & i)>
											<cfset thisMeth= evaluate("data.geo_att_determined_method_" & i)>
											<cfset thisRemark= evaluate("data.geo_att_remark_" & i)>
											<div id="#i#">
											<tr id="d_geology_attribute_#i#">
												<td>
													<select name="geology_attribute_#i#" id="geology_attribute_#i#" size="1" onchange="populateGeology(this.id);">
														<option value=""></option>
														<cfloop query="ctgeology_attribute">
															<option
																<cfif thisAttribute is geology_attribute> selected="selected" </cfif>
																	value="#geology_attribute#">#geology_attribute#</option>
														</cfloop>
													</select>
												</td>
												<td>
													<select name="geo_att_value_#i#" id="geo_att_value_#i#">
														<option value="#thisVal#">#thisVal#</option>
													</select>
												</td>
												<td>
													<input type="text"
														name="geo_att_determiner_#i#"
														id="geo_att_determiner_#i#"
														value="#thisDeterminer#"
														onchange="getAgent('nothing',this.id,'dataEntry',this.value);"
														onkeypress="return noenter(event);">
												</td>
												<td>
													<input type="text"
														name="geo_att_determined_date_#i#"
														id="geo_att_determined_date_#i#"
														value="#thisDate#"
														size="10">
												</td>
												<td>
													<input type="text"
														name="geo_att_determined_method_#i#"
														id="geo_att_determined_method_#i#"
														value="#thisMeth#"
														size="15">
												</td>
												<td>
													<input type="text"
														name="geo_att_remark_#i#"
														id="geo_att_remark_#i#"
														value="#thisRemark#"
														size="15">
												</td>
											</tr>
											</div>
										</cfloop>
									</table>
								</td>
							</tr>
						</table>
					</div>
				</cfif><!---- /geology ------->


			</td><!--- end right column --->
		</tr><!---- end top row of page --->
		<tr><!---- start bottom row of page --->
			<td colspan="2"><!--- parts block --->
				<table cellpadding="0" cellspacing="0" class="fs">
					<tr>
						<td rowspan="99" valign="top">
							<img src="/images/info.gif" border="0" onClick="getDocs('parts')" class="likeLink" alt="[ help ]">
						</td>
						<th><span class="f11a">Part Name</span></th>
						<th><span class="f11a">Condition</span></th>
						<th><span class="f11a">Disposition</span></th>
						<th><span class="f11a">##</span></th>
						<th><span class="f11a">Barcode</span></th>
						<th><span class="f11a">Label</span></th>
						<th><span class="f11a">Remark</span></th>
					</tr>
					<cfloop from="1" to="12" index="i">
						<tr id="d_part_name_#i#">
							<td>
								<cfset tpn=evaluate("data.part_name_" & i)>
								<input type="text" name="part_name_#i#" id="part_name_#i#"
									value="#tpn#" size="25"
									onchange="findPart(this.id,this.value,'#collection_cde#');requirePartAtts('#i#',this.value);"
									onkeypress="return noenter(event);">
							</td>
							<td>
								<input type="text" name="part_condition_#i#" id="part_condition_#i#" value="#evaluate("data.part_condition_" & i)#">
							</td>
							<td>
								<select id="part_disposition_#i#" name="part_disposition_#i#">
									<option value=""></option>
									<cfloop query="CTCOLL_OBJ_DISP">
										<option
											<cfif evaluate("data.part_disposition_" & i) is CTCOLL_OBJ_DISP.COLL_OBJ_DISPOSITION> selected="selected" </cfif>
										 	value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
									</cfloop>
								</select>
							</td>
							<td>
								<input type="text" name="part_lot_count_#i#" id="part_lot_count_#i#" value="#evaluate("data.part_lot_count_" & i)#" size="1">
							</td>
							<td>
								<input type="text" name="part_barcode_#i#" id="part_barcode_#i#" value="#evaluate("data.part_barcode_" & i)#"
									 size="15" onchange="setPartLabel(this.id);">
							</td>
							<td>
								<input type="text" name="part_container_label_#i#" id="part_container_label_#i#"
									value="#evaluate("data.part_container_label_" & i)#" size="10">
							</td>
							<td>
								<input type="text" name="part_remark_#i#" id="part_remark_#i#"
									value="#evaluate("data.part_remark_" & i)#" size="40">
							</td>
						</tr>
					</cfloop>
				</table>
			</td><!--- end parts block --->
		</tr>
		<tr>
		<td colspan="2">
			<table cellpadding="0" cellspacing="0" width="100%" style="background-color:##339999">
				<tr>
					<td width="16%">
						<span id="theNewButton" style="display:none;">
							<input type="button" value="Save This As A New Record" class="insBtn"
								onclick="saveNewRecord();"/>
						 </span>
					</td>
					<td width="16%">
						<span id="enterMode" style="display:none">
							<input type="button"
								value="Edit Last Record"
								class="lnkBtn"
								onclick="editThis()">
						</span>
						<span id="editMode" style="display:none">
								<input type="button"
									value="Clone This Record"
									class="lnkBtn"
									onclick="createClone()">
						</span>
					</td>
					<td width="16%" nowrap="nowrap">
						 <span id="theSaveButton" style="display:none;">
							<input type="button" value="Save Edits" class="savBtn" onclick="saveEditedRecord();" />
							<cfif ImAGod is not "yes">
								<input type="button" value="Delete Record" class="delBtn" onclick="deleteThisRec();" />
							</cfif>
						</span>
					</td>
					<td width="16%">
						<a href="/Bulkloader/browseBulk.cfm?enteredby=#session.username#&action=ajaxGrid">[ AJAX ]</a>
						<a href="/Bulkloader/browseBulk.cfm?enteredby=#session.username#&action=sqlTab">[ SQL ]</a>
						<a href="/Bulkloader/browseBulk.cfm?enteredby=#session.username#&action=viewTable">[ Java ]</a>
						<a href="/Bulkloader/browseBulk.cfm?enteredby=#session.username#&action=download">[ download ]</a>

					</td>
					<td align="right" width="16%" nowrap="nowrap">
						<span id="recCount">#whatIds.recordcount#</span> records <cfif whatIds.recordcount is 1000>(limit)</cfif>
							<span id="browseThingy">
								 - Jump to
								<span class="infoLink" id="pBrowse" onclick="browseTo('previous')">[ previous ]</span>
								<select name="browseRecs" size="1" id="selectbrowse" onchange="loadRecord(this.value);">
									<cfloop query="whatIds">
										<option <cfif data.collection_object_id is whatIds.collection_object_id> selected="selected" </cfif>
											value="#collection_object_id#">#collection_object_id#</option>
									</cfloop>
								</select>
								<span id="nBrowse" class="infoLink" onclick="browseTo('next')">[ next ]</span>
							</span>
						</span>
					</td>
				</tr>
			</table>
   		</td>
	</tr>
</table>
</form>
<cfif len(loadedMsg) gt 0>
	<cfset pMode = 'edit'>
</cfif>
<cfset loadedMsg = replace(loadedMsg,"'","`","all")>
<script language="javascript" type="text/javascript">
	//switchActive('#orig_lat_long_units#');
	//highlightErrors('#trim(loadedMsg)#');
	changeMode('#pMode#');
	jQuery("##georeference_source").autocomplete("/ajax/autocomplete.cfm?term=georeference_source", {
		width: 320,
		max: 50,
		autofill: false,
		multiple: false,
		scroll: true,
		scrollHeight: 300,
		matchContains: true,
		minChars: 1,
		selectFirst:false
	});

	jQuery(document).ready(function() {
		loadRecord('#collection_object_id#');
	});
</script>
<cfif isdefined("session.rememberLastOtherId") and session.rememberLastOtherId is 1 and pMode is "enter">
	<cftry>
		<cfset cVal="">
		<cfif isnumeric(other_id_num_5)>
			<cfset cVal = other_id_num_5 + 1>
		<cfelseif isnumeric(right(other_id_num_5,len(other_id_num_5)-1))>
			<cfset temp = (right(other_id_num_5,len(other_id_num_5)-1)) + 1>
			<cfset cVal = left(other_id_num_5,1) & temp>
		</cfif>
		<script language="javascript" type="text/javascript">
			var cid = document.getElementById('other_id_num_5').value='#cVal#';
		</script>
	<cfcatch>
		<cfmail to="arctos.database@gmail.com" subject="data entry catch" from="wtf@#Application.fromEmail#" type="html">
			other_id_num_5: #other_id_num_5#
			<cfdump var=#cfcatch#>
		</cfmail>
	</cfcatch>
	</cftry>
</cfif>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">