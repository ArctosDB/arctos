<div id="msg"></div>
<div><!--- spacer ---></div>
<cfinclude template="/includes/_header.cfm">
<cfset title="Data Entry">
<link rel="stylesheet" type="text/css" href="/includes/_DEstyle.css">
<!---
<script type='text/javascript' src='/includes/jquery/suggest.js'></script>
<script type='text/javascript' src='/includes/jquery/jquery-autocomplete/jquery.autocomplete.pack.js'></script>
--->
<script type='text/javascript' src='/includes/DEAjax.js'></script>
<cf_showMenuOnly>
<cf_setDataEntryGroups>

<cfif not isdefined("ImAGod") or len(#ImAGod#) is 0>
	<cfset ImAGod = "no">
</cfif>
<cfif isdefined("CFGRIDKEY") and not isdefined("collection_object_id")>
	<cfset collection_object_id = CFGRIDKEY>
</cfif>
<cfset collid = 1>
<cfif not isdefined("pMode") or len(pMode) is 0>
	<cfset pMode = "enter">
</cfif>
<cfset thisDate = #dateformat(now(),"yyyy-mm-dd")#>
<!--------------------------------------------------------------------------------------------------------->
<cfif action is "nothing">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from cf_dataentry_settings where username='#session.username#'
		</cfquery>
		<cfif d.recordcount is not 1>
			<cfquery name="seed" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into cf_dataentry_settings (
					username
				) values (
					'#session.username#'
				)
			</cfquery>
		</cfif>
		<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from collection ORDER BY COLLECTION
		</cfquery>
		<cfloop query="c">
			<cfquery  name="isBL" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from bulkloader where collection_object_id = #collection_id#
			</cfquery>
			<cfif isBl.recordcount is 0>
				<cfquery name="prime" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					insert into bulkloader (
						collection_object_id, 
						institution_acronym,
						collection_cde,
						loaded) VALUES (
						#collection_id#,
						'#institution_acronym#',
						'#collection_cde#',
						'#ucase(institution_acronym)# #ucase(collection_cde)# TEMPLATE')
				</cfquery>
			<cfelseif isBL.loaded is not "#ucase(institution_acronym)# #ucase(collection_cde)# TEMPLATE">
				<cfquery name="move" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update bulkloader set collection_object_id = bulkloader_PKEY.nextval
					where collection_object_id = #collection_id#
				</cfquery>
				<cfquery name="prime" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					insert into bulkloader (
						collection_object_id, 
						institution_acronym,
						collection_cde,
						loaded) VALUES (
						#collection_id#,
						'#institution_acronym#',
						'#collection_cde#',
						'#ucase(institution_acronym)# #ucase(collection_cde)# TEMPLATE')
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
		<cfquery name="theirLast" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
				<cfif #theirLast.recordcount# gt 0>
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
		<!---
		
		<div>
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection_object_id from bulkloader
	</cfquery>
<cfloop query="c">
	<br><span onclick="loadRecord(#collection_object_id#)">#collection_object_id#</span>
</cfloop>

</div>
---->

		<cfif not isdefined("collection_object_id") or len(collection_object_id) is 0>
			you don't have an ID. <cfabort>
		</cfif>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from bulkloader where collection_object_id=#collection_object_id#
		</cfquery>
		<cfif collection_object_id GT 50>
			<cfquery name="chk" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select bulk_check_one(#collection_object_id#) rslt from dual
			</cfquery>
			<cfset loadedMsg=chk.rslt>
		<cfelse>
			<cfset loadedMsg = "">
		</cfif>
	</cfoutput>
	<cfoutput query="data">
		<cfquery name="ctInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
			SELECT institution_acronym || ' ' || collection_cde as instcoll, collection_id FROM collection
				<cfif len(#collection_cde#) gt 0>
					WHERE collection_cde='#collection_cde#'
				</cfif>
		</cfquery>
		<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select collection_cde,institution_acronym,collection from collection order by collection
		</cfquery>
		<cfquery name="ctnature" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select nature_of_id from ctnature_of_id order by nature_of_id
		</cfquery>
		<cfquery name="ctunits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       select ORIG_LAT_LONG_UNITS from ctLAT_LONG_UNITS order by orig_lat_long_units
	    </cfquery>
		<cfquery name="ctflags" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       select flags from ctflags order by flags
	    </cfquery>
		<cfquery name="CTCOLL_OBJ_DISP" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP order by coll_obj_DISPOSITION
	    </cfquery>	 
		<cfquery name="cterror" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
	    	select LAT_LONG_ERROR_UNITS from ctLAT_LONG_ERROR_UNITS order by lat_long_error_units
	    </cfquery>
		<cfquery name="ctdatum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select datum from ctdatum order by datum
	    </cfquery>    
		<cfquery name="ctgeorefmethod" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select georefmethod from ctgeorefmethod order by georefmethod
	    </cfquery>
		<cfquery name="ctverificationstatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select verificationstatus from ctverificationstatus order by verificationstatus
	    </cfquery>
		<cfquery name="ctcollecting_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select collecting_source from ctcollecting_source order by collecting_source
	    </cfquery>			
	    <cfquery name="ctew" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
	    	select e_or_w from ctew order by e_or_w
	    </cfquery>
	    <cfquery name="ctns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select n_or_s from ctns order by n_or_s
	    </cfquery>
		<cfquery name="ctOtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
			SELECT distinct(other_id_type) FROM ctColl_Other_id_type
			order by other_id_type
	    </cfquery>
		<cfquery name="ctSex_Cde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
			SELECT distinct(sex_cde) as sex_cde FROM ctSex_Cde
			<cfif len(collection_cde) gt 0>
				WHERE collection_cde='#collection_cde#'
			</cfif>
			order by sex_cde
		</cfquery>
		<cfquery name="ctOrigElevUnits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select orig_elev_units from ctorig_elev_units
	    </cfquery>
		<cfquery name="ctbiol_relations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
	      	select BIOL_INDIV_RELATIONSHIP from ctbiol_relations
			order by BIOL_INDIV_RELATIONSHIP
	    </cfquery>
		<cfquery name="ctLength_Units" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select length_units from ctLength_Units order by length_units
		</cfquery>
		<cfquery name="ctWeight_Units" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select Weight_Units from ctWeight_Units order by weight_units
		</cfquery>
		
		
		<cfquery name="ctAttributeType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
			SELECT attribute_type FROM ctattribute_type 
			<cfif len(#collection_cde#) gt 0>
				WHERE collection_cde='#collection_cde#'
			</cfif>
			order by attribute_type
		</cfquery>
		<cfquery name="ctgeology_attribute" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select geology_attribute from ctgeology_attribute order by geology_attribute
		</cfquery>
		<cfquery name="ctCodes" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select 
				attribute_type,
				value_code_table,
				units_code_table
		 	from ctattribute_code_tables
		</cfquery>
		<cfset sql = "select collection_object_id from bulkloader where collection_object_id > 10">
		<cfif ImAGod is "no">
			 <cfset sql = "#sql# AND enteredby = '#session.username#'">
		<cfelse>
			<cfset sql = "#sql# AND enteredby IN (#listqualify(adminForUsers,'''')#)">
		</cfif>
		<cfset sql = "#sql# order by collection_object_id">
		<cfquery name="whatIds" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<cfif not isdefined("inEntryGroups") OR len(inEntryGroups) eq 0>
			You have group issues! You must be in a Data Entry group to use this form.
			<cfabort>
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
			<input type="hidden" name="loaded" value="waiting approval"  id="loaded"/>
			<table width="100%" cellspacing="0" cellpadding="0" id="theTable" style="display:none;"> <!--- whole page table --->
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
							<td valign="top">
								#institution_acronym#:#collection_cde#
								<!---
								<span class="f11a">Coll:</span>
								<select name="colln" id="colln" class="reqdClr" onchange="changeCollection(this.value)">
									<cfloop query="ctcollection">
										<option <cfif data.collection_cde is ctcollection.collection_cde and data.institution_acronym is ctcollection.institution_acronym> selected="selected"</cfif>
											value="#institution_acronym#:#collection_cde#">#collection#</option>
									</cfloop>
								</select>
								--->
								<span id="catNumLbl" class="f11a">Cat##</span>
								<input type="text" name="cat_num" value="#cat_num#"  size="6" id="cat_num">
								<cfif isdefined("session.CustomOtherIdentifier") and len(#session.CustomOtherIdentifier#) gt 0>
									<span id="d_other_id_num_type_5">
										<span class="f11a">#session.CustomOtherIdentifier#</span>
										<input type="hidden" name="other_id_num_type_5" value="#session.CustomOtherIdentifier#" id="other_id_num_type_5" />
										<input type="text" name="other_id_num_5" value="#other_id_num_5#" size="8" id="other_id_num_5">
										<span id="rememberLastId">
											<cfif isdefined("session.rememberLastOtherId") and session.rememberLastOtherId is 1>
												<span class="infoLink" onclick="rememberLastOtherId(0)">Nevermind</span>
											<cfelse>
												<span class="infoLink" onclick="rememberLastOtherId(1)">Increment this</span>
											</cfif>
										</span>
									</span>
								</cfif>
								<span class="f11a">Accn</span>
								<input type="text" name="accn" value="#accn#" size="13" class="reqdClr" id="accn" onchange="isGoodAccn();">
								<span id="customizeForm" class="infoLink" onclick="customize()">[ customize form ]</span>

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
								<input type="text" name="made_date" value="#made_date#" id="made_date">
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
					<table cellspacing="0" cellpadding="0" class="fs"><!----- locality ---------->
					 	<tr>
							<td rowspan="99" valign="top">
								<img src="/images/info.gif" border="0" onClick="getDocs('locality')" class="likeLink" alt="[ help ]">
							</td>
							<td align="right"><span class="f11a">Higher Geog</span></td>
							<td width="100%">
								<input type="text" name="higher_geog" class="reqdClr" id="higher_geog" value="#higher_geog#" size="80"
									onchange="getGeog('nothing',this.id,'dataEntry',this.value)">
							</td>
						</tr>
						<tr>
							<td align="right"><span class="f11a">Spec&nbsp;Locality&nbsp;</span></td>
							<td nowrap="nowrap">
								<input type="text" name="spec_locality" class="reqdClr"
									id="spec_locality"	value="#stripQuotes(spec_locality)#" size="80">
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<table>
									<tr>
										<td id="d_locality_id">
											<label for="fetched_locid">Existing&nbsp;LocalityID</label>
											<input type="hidden" id="fetched_locid">
											<input type="text" name="locality_id" id="locality_id" value="#locality_id#" readonly="readonly" class="readClr" size="8">
											<span class="infoLink" id="localityPicker"
												onclick="LocalityPick('locality_id','spec_locality','dataEntry','turnSaveOn'); return false;">
												Pick&nbsp;Locality
											</span>
											<span class="infoLink" 
												id="localityUnPicker"
												style="display:none;"
												onclick="unpickLocality()">
												Depick&nbsp;Locality
											</span>
										</td>
										<td id="d_collecting_event_id">
											<label for="collecting_event_id">Existing&nbsp;EventID</label>
											<input type="text" name="collecting_event_id" id="collecting_event_id" value="#collecting_event_id#" readonly="readonly" class="readClr" size="8">
											<input type="hidden" id="fetched_eventid">
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
								<span class="infoLink" onclick="copyAllDates('began_date');">Copy2All</span>
								<span class="f11a">End</span>
								<input type="text" name="ended_date" class="reqdClr" value="#ended_date#" id="ended_date" size="10">
								<span class="infoLink" onclick="copyAllDates('ended_date');">Copy2All</span>
							</td>
						</tr>
						<tr>
							<td colspan="2" id="dateConvertStatus"></td>
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
								<input type="text" name="habitat_desc" size="50" id="habitat_desc" value="#habitat_desc#">
							</td>
						</tr>
						<tr id="d_associated_species">
							<td align="right"><span class="f11a">Associated&nbsp;Species</span></td>
							<td>
								<input type="text" name="associated_species" size="80" id="associated_species" value="#associated_species#">
							</td>
						</tr>
						<tr id="d_coll_object_habitat">
							<td align="right"><span class="f11a">Microhabitat</span></td>
							<td>
								<input type="text" name="coll_object_habitat" size="80" id="coll_object_habitat" value="#coll_object_habitat#">
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
						<tr id="d_coll_event_remarks">
							<td align="right"><span class="f11a">CollEvntRemk</span></td>
							<td>
								<input type="text" name="coll_event_remarks" size="80" value="#coll_event_remarks#" id="coll_event_remarks">
							</td>
						</tr>
						<tr id="d_locality_remarks">
							<td align="right"><span class="f11a">LocalityRemk</span></td>
							<td>
								<input type="text" name="locality_remarks" size="80" value="#locality_remarks#" id="locality_remarks">
							</td>
						</tr>
					</table><!----- /locality ---------->
				</td> <!---- end top left --->		
				<td valign="top"><!----- right column ---->	
				<table cellpadding="0" cellspacing="0" class="fs" id="d_orig_lat_long_units"><!------- coordinates ------->
					<tr>
						<td rowspan="99" valign="top">
							<img src="/images/info.gif" border="0" onClick="getDocs('lat_long')" class="likeLink" alt="[ help ]">
						</td>
						<td>
							<table>
								<tr>
									<td align="right"><span class="f11a">Original&nbsp;lat/long&nbsp;Units</span></td>
									<td colspan="99" width="100%">
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
										<td align="right"><span class="f11a">Extent</span></td>
										<td>
											<input type="text" name="extent" id="extent" value="#extent#" size="10">
										</td>
									</tr>
									<tr>
										<td align="right"><span class="f11a">GPS Accuracy</span></td>
										<td>
											<input type="text" name="gpsaccuracy" id="gpsaccuracy" value="#gpsaccuracy#" size="10">
										</td>
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
										<td align="right">
											<span class="f11a">Determiner</span>
										</td>
										<td>
											<input type="text" name="determined_by_agent" value="#determined_by_agent#" class="reqdClr" 
												id="determined_by_agent"
												onchange="getAgent('nothing',this.id,'dataEntry',this.value);"
												onkeypress="return noenter(event);">
										</td>
										<td align="right"><span class="f11a">Date</span></td>
										<td>
											<input type="text" name="determined_date" class="reqdClr" value="#determined_date#" id="determined_date">
											<span class="infoLink" onclick="copyAllDates('determined_date');">Copy2All</span>
										</td>
									</tr>
									<tr>
										<td align="right"><span class="f11a">Reference</span></td>
										<td colspan="3" nowrap="nowrap">
											<input type="text" name="lat_long_ref_source" id="lat_long_ref_source"  class="reqdClr" 
												size="60" value="#lat_long_ref_source#">
											<span class="infoLink" onclick="getHelp('lat_long_ref_source');">Pick</span>
										</td>
									</tr>
									<tr>
										<td align="right"><span class="f11a">Georef Meth</span></td>
										<td>
											<select name="georefmethod" size="1" class="reqdClr" style="width:130px" id="georefmethod">
												<cfloop query="ctgeorefmethod">
													<option <cfif data.georefmethod is ctgeorefmethod.georefmethod> selected="selected" </cfif>
														value="#ctgeorefmethod.georefmethod#">#ctgeorefmethod.georefmethod#</option>
												</cfloop>
											</select> 
										</td>
										<td align="right"><span class="f11a">Verification</span></td>
										<td>
											<cfset thisverificationstatus = #verificationstatus#>
											<select name="verificationstatus" size="1" class="reqdClr" id="verificationstatus">
												<cfloop query="ctverificationstatus">
													<option <cfif data.verificationstatus is ctverificationstatus.verificationstatus> selected="selected" </cfif>
												  		value="#ctverificationstatus.verificationstatus#">#ctverificationstatus.verificationstatus#</option>
												</cfloop>
											</select>
										</td>
									</tr>
									<tr id="d_lat_long_remarks">
										<td align="right"><span class="f11a">LatLongRemk</span></td>
										<td colspan="3">
											<input type="text" name="lat_long_remarks" size="80" value="#lat_long_remarks#" id="lat_long_remarks">
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
				<table cellpadding="0" cellspacing="0" class="fs"><!----- attributes ------->
					<tr>
						<td>
							<cfif collection_cde is not "Crus" and collection_cde is not "Herb"
								and collection_cde is not "ES" and collection_cde is not "Fish"
								and collection_cde is not "Para" and collection_cde is not "Art">
								<table cellpadding="0" cellspacing="0">
									<tr>
										<td rowspan="99" valign="top">
											<img src="/images/info.gif" border="0" onClick="getDocs('attributes')" class="likeLink" alt="[ help ]">
										</td>
										<td nowrap="nowrap">
											<span class="f11a">Sex</span>
											 <input type="hidden" name="attribute_1" value="sex">
											 <select name="attribute_value_1" size="1" onChange="changeSex(this.value)"
												id="attribute_value_1"
												class="reqdClr"
												style="width: 80px">
												<option value=""></option>
												<cfloop query="ctSex_Cde">
													<option 
														<cfif data.attribute_value_1 is Sex_Cde> selected </cfif>value="#Sex_Cde#">#Sex_Cde#</option>
												</cfloop>
											 </select>
											<span class="f11a">Date</span>
											<input type="text" name="attribute_date_1" value="#attribute_date_1#" id="attribute_date_1" size="10" class="reqdClr">
											<span class="infoLink" onclick="copyAttributeDates('attribute_date_1');">Sync Att.</span>
											<span class="f11a">Detr</span>
											<input type="text" 
												name="attribute_determiner_1" 
												value="#attribute_determiner_1#" 
												class="reqdClr" 
												onchange="getAgent('nothing',this.id,'dataEntry',this.value);"
												onkeypress="return noenter(event);"
												onblur="doAttributeDefaults();"
												id="attribute_determiner_1" />
											<span class="infoLink" onclick="copyAttributeDetr('attribute_determiner_1');">Sync Att.</span>
											<span class="f11a">Meth</span>
											<input type="text" name="attribute_det_meth_1" 
												value="#attribute_det_meth_1#" 
												id="attribute_det_meth_1">
										</td>
									</tr>
								</table>
							<cfelse>
								<input type="hidden" name="attribute_1" id="attribute_1" value="">
								<input type="hidden" name="attribute_value_1"  id="attribute_value_1" value="">
								<input type="hidden" name="attribute_date_1"  id="attribute_date_1" value="">
								<input type="hidden" name="attribute_determiner_1"  id="attribute_determiner_1" value="">
								<input type="hidden" name="attribute_det_meth_1"  id="attribute_det_meth_1" value="">
							</cfif>
							<table cellpadding="1" cellspacing="0">
								<cfif collection_cde is "Mamm">
									<tr>
										<td><span class="f11a">len</span></td>
										<td><span class="f11a">tail</span></td>
										<td><span class="f11a">Hind Foot</span></td>
										<td><span class="f11a">Ear From Notch</span></td>
										<td><span class="f11a">Units</span></td>
										<td colspan="2" align="center"><span class="f11a">Weight</span></td>
										<td><span class="f11a">Date</span></td>
										<td><span class="f11a">Determiner</span></td>
									<tr>
										<td>
											<input type="hidden" name="attribute_2" value="total length" />
											<input type="text" name="attribute_value_2" value="#attribute_value_2#" size="3" id="attribute_value_2">
										</td>
										<td>
											<input type="hidden" name="attribute_units_3" value="#attribute_units_3#" id="attribute_units_3" />
											<input type="hidden" name="attribute_date_3" value="#attribute_date_3#" id="attribute_date_3" />
											<input type="hidden" name="attribute_determiner_3" value="#attribute_determiner_3#" id="attribute_determiner_3" />
											<input type="hidden" name="attribute_3" value="tail length" />
											<input type="text" name="attribute_value_3" value="#attribute_value_3#" size="3" id="attribute_value_3">
										</td>
										<td align='center'>
											<input type="hidden" name="attribute_units_4" value="#attribute_units_4#" id="attribute_units_4" />
											<input type="hidden" name="attribute_date_4" value="#attribute_date_4#" id="attribute_date_4" />
											<input type="hidden" name="attribute_determiner_4" value="#attribute_determiner_4#" id="attribute_determiner_4" />
											<input type="hidden" name="attribute_4" value="hind foot with claw" />
											<input type="text" name="attribute_value_4" value="#attribute_value_4#" size="3" id="attribute_value_4">
										</td>
										<td align='center'>
											<input type="hidden" name="attribute_units_5" value="#attribute_units_5#" id="attribute_units_5" />
											<input type="hidden" name="attribute_date_5" value="#attribute_date_5#" id="attribute_date_5" />
											<input type="hidden" name="attribute_determiner_5" value="#attribute_determiner_5#" id="attribute_determiner_5" />
											<input type="hidden" name="attribute_5" value="ear from notch" />
											<input type="text" name="attribute_value_5" value="#attribute_value_5#" size="3" id="attribute_value_5">
										</td>
										<td>
											<select name="attribute_units_2" size="1" id="attribute_units_2">
												<option value=""></option>
												<cfloop query="ctLength_Units">
													<option <cfif #data.attribute_units_2# is #Length_Units#> selected </cfif> 
													value="#Length_Units#">#Length_Units#</option>
												</cfloop>
											</select>
										</td>
										<td>
											<input type="hidden" name="attribute_date_6" value="#attribute_date_6#" id="attribute_date_6" />
											<input type="hidden" name="attribute_determiner_6" value="#attribute_determiner_6#" id="attribute_determiner_6" />
											<input type="hidden" name="attribute_6" value="weight" />
											<input type="text" name="attribute_value_6" value="#attribute_value_6#" size="3" id="attribute_value_6">
										</td>
										<td>
											<select name="attribute_units_6" size="1" id="attribute_units_6">
												<option value=""></option>
												<cfloop query="ctWeight_Units">
													<option <cfif #data.attribute_units_6# is #Weight_Units#> selected </cfif>value="#Weight_Units#">#Weight_Units#</option>
												</cfloop>
											</select>
										</td>
										<td>
											<input type="text" name="attribute_date_2" id="attribute_date_2" value="#attribute_date_2#">		
										</td>
										<td>
											<input type="text" name="attribute_determiner_2" id="attribute_determiner_2"
												value="#attribute_determiner_2#"
												onchange="getAgent('nothing',this.id,'dataEntry',this.value);"
												onkeypress="return noenter(event);">
											
										</td>
									</tr>
								<cfelseif collection_cde is "Bird">
									<tr>
										<td><span class="f11a">Age</span></td>
										<td><span class="f11a">Fat</span></td>
										<td><span class="f11a">Molt</span></td>
										<td><span class="f11a">Ossification</span></td>
										<td colspan="2" align="center"><span class="f11a">Weight</span></td>
										<td><span class="f11a">Date</span></td>
										<td><span class="f11a">Determiner</span></td>
									<tr>
										<td>
											<input type="hidden" name="attribute_2" value="age" />
											<input type="text" name="attribute_value_2" value="#attribute_value_2#" size="3" id="attribute_value_2">
										</td>
										<td>
											<input type="hidden" name="attribute_date_3" value="#attribute_date_3#" id="attribute_date_3" />
											<input type="hidden" name="attribute_determiner_3" value="#attribute_determiner_3#" id="attribute_determiner_3" />
											<input type="hidden" name="attribute_3" value="fat deposition" />
											<input type="text" name="attribute_value_3" value="#attribute_value_3#" size="15" id="attribute_value_3">
										</td>
										<td>
											<input type="hidden" name="attribute_date_4" value="#attribute_date_4#" id="attribute_date_4" />
											<input type="hidden" name="attribute_determiner_4" value="#attribute_determiner_4#" id="attribute_determiner_4" />
											<input type="hidden" name="attribute_4" value="molt condition" />
											<input type="text" name="attribute_value_4" value="#attribute_value_4#" size="15" id="attribute_value_4">
										</td>
										<td>
											<input type="hidden" name="attribute_date_5" value="#attribute_date_5#" id="attribute_date_5" />
											<input type="hidden" name="attribute_determiner_5" value="#attribute_determiner_5#" id="attribute_determiner_5" />
											<input type="hidden" name="attribute_5" value="skull ossification" />
											<input type="text" name="attribute_value_5" value="#attribute_value_5#" size="15" id="attribute_value_5">
										</td>
										<td>
											<input type="hidden" name="attribute_date_6" value="#attribute_date_6#" id="attribute_date_6" />
											<input type="hidden" name="attribute_determiner_6" value="#attribute_determiner_6#" id="attribute_determiner_6" />
											<input type="hidden" name="attribute_6" value="weight" />
											<input type="text" name="attribute_value_6" value="#attribute_value_6#" size="2" id="attribute_value_6">
										</td>
										<td>
											<select name="attribute_units_6" size="1" id="attribute_units_6" >
												<cfloop query="ctWeight_Units">
													<option <cfif #data.attribute_units_6# is #Weight_Units#> selected </cfif>value="#Weight_Units#">#Weight_Units#</option>
												</cfloop>
											</select>
										</td>
										<td>
											<input type="text" name="attribute_date_2" id="attribute_date_2" value="#attribute_date_2#">
										</td>
										<td>
											<input type="text" 
												name="attribute_determiner_2" 
												id="attribute_determiner_2"
												value="#attribute_determiner_2#"
												onchange="getAgent('nothing',this.id,'dataEntry',this.value);"
												onkeypress="return noenter(event);">
										</td>
									</tr>
								<cfelse><!--- maintain attributes 2-6 as hiddens to not break the JS --->
									<cfloop from="2" to="6" index="i">
										<input type="hidden" name="attribute_#i#" id="attribute_#i#" value="">
										<input type="hidden" name="attribute_value_#i#"  id="attribute_value_#i#" value="">
										<input type="hidden" name="attribute_date_#i#"  id="attribute_date_#i#" value="">
										<input type="hidden" name="attribute_determiner_#i#"  id="attribute_determiner_#i#" value="">
										<input type="hidden" name="attribute_det_meth_#i#"  id="attribute_det_meth_#i#" value="">
									</cfloop>
								</cfif>
							</table>
							<table cellspacing="0" cellpadding="0">
								<tr>
									<th><span class="f11a">Attribute</span></th>
									<th><span class="f11a">Value</span></th>
									<th><span class="f11a">Units</span></th>
									<th><span class="f11a">Date</span></th>
									<th><span class="f11a">Determiner</span></th>
									<th><span class="f11a">Method</span></th>
									<th><span class="f11a">Remarks</span></th>
								</tr>
								<cfloop from="7" to="10" index="i">
									<tr id="d_attribute_#i#">
										<td>
											<select name="attribute_#i#" onChange="getAttributeStuff(this.value,this.id);"
												style="width:100px;" id="attribute_#i#">
												<option value="">&nbsp;&nbsp;&nbsp;&nbsp;</option>						
												<cfloop query="ctAttributeType">
													<option <cfif evaluate("data.attribute_" & i) is ctAttributeType.attribute_type> selected="selected" </cfif>
														value="#attribute_type#">#attribute_type#</option>
												</cfloop>
											</select>
										</td>
										<td>
											<div id="attribute_value_cell_#i#">
												<input type="text" name="attribute_value_#i#" value="#evaluate("data.attribute_value_" & i)#" 
													id="attribute_value_#i#"size="15">
											</div>
										</td>
										<td>
											<div id="attribute_units_cell_#i#">
											<input type="text" name="attribute_units_#i#"  value="#evaluate("data.attribute_units_" & i)#" 
												id="attribute_units_#i#" size="6">
											</div>
										</td>
										<td>
											<input type="text" name="attribute_date_#i#" value="#evaluate("data.attribute_date_" & i)#" 
												id="attribute_date_#i#" size="10">
										</td>
										<td>
											 <input type="text" name="attribute_determiner_#i#"
												id="attribute_determiner_#i#" size="15"
												value="#evaluate("data.attribute_determiner_" & i)#"
												onchange="getAgent('nothing',this.id,'dataEntry',this.value);"
												onkeypress="return noenter(event);">
										</td>
										<td>
											<input type="text" name="attribute_det_meth_#i#"
												id="attribute_det_meth_#i#" size="15" value="#evaluate("data.attribute_det_meth_" & i)#">
										</td>
										<td>
											<input type="text" name="attribute_remarks_#i#"
												id="attribute_remarks_#i#"
												value="#evaluate("data.attribute_remarks_" & i)#">
										</td>
									</tr>
								</cfloop>
							</table>
						</td>
					</tr>
				</table><!---- /attributes ----->
				<table cellpadding="0" cellspacing="0" class="fs"><!--- random admin stuff ---->
					<tr>
						<td align="right"><span class="f11a">Entered&nbsp;By</span></td>
						<td width="100%">
							<cfif ImAGod is not "yes">
								<input type="hidden" name="enteredby" value="#session.username#" id="enteredby" class="readClr"/>
							<cfelseif ImAGod is "yes">
								<input type="text" name="enteredby" value="#enteredby#" id="enteredby"/>
							<cfelse>
								ERROR!!!
							</cfif> 
						</td>
					</tr>
					<tr>
						<td align="right"><span class="f11a">Disposition</span></td>
						<td>
							<cfset thisDisp = COLL_OBJ_DISPOSITION>
							<select name="coll_obj_disposition" size="1" class="reqdClr" id="coll_obj_disposition">
								<option value=""></option>
								<cfloop query="CTCOLL_OBJ_DISP">
									<option
										<cfif thisDisp is COLL_OBJ_DISPOSITION> selected </cfif>
									 value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td align="right"><span class="f11a">Condition</span></td>
						<td>
							<input type="text" class="reqdClr" name="condition" value="#condition#" id="condition" size="50">
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
							<select name="related_to_num_type" size="1" id="related_to_num_type" style="width:80px">
								<option value=""></option>
								<option <cfif thisRELATED_TO_NUM_TYPE is "catalog number">selected="selected"</cfif> value="catalog number">catalog number (UAM Mamm 123 format)</option>
								<cfloop query="ctOtherIdType">
									<option
										<cfif thisRELATED_TO_NUM_TYPE is other_id_type> selected="selected" </cfif>
									 value="#other_id_type#">#other_id_type#</option>
								</cfloop>							
							</select>
							<input type="text" value="#related_to_number#" name="related_to_number" id="related_to_number" size="10" />
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
						<th><span class="f11a">Vial Label</span></th>
						<th><span class="f11a">Remark</span></th>
					</tr>
					<cfloop from="1" to="12" index="i">
						<tr id="d_part_name_#i#">
							<td>
								<cfset tpn=evaluate("data.part_name_" & i)>
								<input type="text" name="part_name_#i#" id="part_name_#i#" <cfif i is 1>class="reqdClr"</cfif>
									value="#tpn#" size="25"
									onchange="findPart(this.id,this.value,'#collection_cde#');requirePartAtts('#i#',this.value);" 
									onkeypress="return noenter(event);">
							</td>
							<td>
								<input type="text" name="part_condition_#i#" id="part_condition_#i#"
									<cfif i is 1>class="reqdClr" </cfif>value="#evaluate("data.part_condition_" & i)#">
							</td>
							<td>
								<select id="part_disposition_#i#" name="part_disposition_#i#" <cfif i is 1>class="reqdClr"</cfif>>
									<option value=""></option>
									<cfloop query="CTCOLL_OBJ_DISP">
										<option
											<cfif evaluate("data.part_disposition_" & i) is CTCOLL_OBJ_DISP.COLL_OBJ_DISPOSITION> selected="selected" </cfif>
										 	value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
									</cfloop>
								</select>
							</td>
							<td>
								<input type="text" name="part_lot_count_#i#" id="part_lot_count_#i#" value="#evaluate("data.part_lot_count_" & i)#" 
									<cfif i is 1>class="reqdClr" </cfif>size="1">
							</td>
							<td>
								<input type="text" name="part_barcode_#i#" id="part_barcode_#i#" value="#evaluate("data.part_barcode_" & i)#" 
									 size="6" onchange="part_container_label_#i#.className='reqdClr';setPartLabel(this.id);">
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
							<input type="button" value="Delete Record" class="delBtn" onclick="deleteThisRec();" />
						</span>
					</td>
					<!---
					<td width="16%">	
						<cfif institution_acronym is "MSB" and collection_cde is "Bird" and pMode is "enter">
							<span id="clearDefault">
								<input type="button" value="Clear All" class="delBtn" onclick="clearAll();" />
							</span>
							<script language="javascript" type="text/javascript">
								catNumSeq();
							</script>
						<cfelse>
							<span id="clearDefault">
								<input type="button" value="Clear Defaults" class="delBtn" onclick="setNewRecDefaults();" />
							</span>
						</cfif>
						--->
					</td>
					<td width="16%">	
						<a href="userBrowseBulkedGrid.cfm">[ JAVA table ]</a>
						<a href="userBrowseBulkedGrid.cfm?action=ajaxGrid">[ AJAX table ]</a>
					</td>
					<td align="right" width="16%" nowrap="nowrap">
						<span id="browseThingy">
							<span id="recCount">#whatIds.recordcount#</span> total records - Jump to 
							<span class="infoLink" id="pBrowse" onclick="browseTo('previous')">[ previous ]</span>
							<select name="browseRecs" size="1" id="selectbrowse" onchange="loadRecord(this.value);">
								<cfset recposn=1>
								<cfloop query="whatIds">
									<option 
										<cfif data.collection_object_id is whatIds.collection_object_id> selected="selected" </cfif>
										value="#collection_object_id#">#collection_object_id#</option>
									<cfset idList = "#idList#,">
									<cfset recposn=recposn+1>
								</cfloop>
							</select>
							<span id="nBrowse" class="infoLink" onclick="browseTo('next')">[ next ]</span>
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
	switchActive('#orig_lat_long_units#');
	highlightErrors('#trim(loadedMsg)#');
	changeMode('#pMode#');
	pickedLocality();
</script>
<cfif isdefined("session.rememberLastOtherId") and session.rememberLastOtherId is 1 and pMode is "enter">
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
</cfif>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">