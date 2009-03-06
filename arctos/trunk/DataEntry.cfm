<cfset btime=now()>
<cfinclude template="/includes/_header.cfm">
<script type='text/javascript' src='/includes/jquery/jquery.js'></script>	
<script type='text/javascript' src='/includes/jquery/suggest.js'></script>	
<cf_showMenuOnly>
<!--- 
Group Setup:
Two groups are required to complete data entry using this form:
	x Data Entry Group, and
	x Data Admin Group
x can be any string. There must be a space between x and "Data." Acceptable entries:
UAM Mammals Data.....
UAM Data .....
Some Totally Random String Data .....
--->
<cf_setDataEntryGroups>
<cfif not isdefined("ImAGod") or len(#ImAGod#) is 0>
	<cfset ImAGod = "no">
</cfif>
<cfif isdefined("CFGRIDKEY") and not isdefined("collection_object_id")>
	<cfset collection_object_id = #CFGRIDKEY#>
</cfif>
<cfset collid = 1>
<cfif not isdefined("pMode") or len(#pMode#) is 0>
	<cfset pMode = "enter">
</cfif>
	<link rel="stylesheet" type="text/css" href="/includes/_DEstyle.css">
	<script type='text/javascript' src='/includes/_DEhead.js'></script>	
	<script type='text/javascript' src='/includes/_DEajax.js'></script>	
	
	<script language="JavaScript" src="includes/CalendarPopup.js" type="text/javascript"></script>
	<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
		var cal1 = new CalendarPopup("theCalendar");
		cal1.showYearNavigation();
		cal1.showYearNavigationInput();
	</SCRIPT>
	<SCRIPT LANGUAGE="JavaScript" type="text/javascript">document.write(getCalendarStyles());</SCRIPT>
<cfset title="Data Entry">
<cfset thisDate = #dateformat(now(),"dd mmm yyyy")#>
<!------------ default page --------------------------------------------------------------------------------------------->
<cfif #action# is "nothing">
<!--- prime the bulkloader table with templates for each collection ---->
<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from collection ORDER BY COLLECTION_ID
</cfquery>
<cfoutput>
	<cfloop query="c">
		<!--- see if the template already exists --->
		<cfquery  name="isBL" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from bulkloader where collection_object_id = #collection_id#
		</cfquery>
		<cfif #isBl.recordcount# is 0>
			<!--- re-create the template --->
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
		<cfelse>
		<!--- see if it's our template --->
			<cfif #isBL.loaded# is not "#ucase(institution_acronym)# #ucase(collection_cde)# TEMPLATE">
				<!--- shiyite - move the barged-in record and create template --->
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
		</cfif>
	</cfloop>
	Welcome to Data Entry, #session.username# 
	<ul>
		<li>Green Screen: You are entering data to a new record.</li>
		<li>Blue Screen: you are editing an unloaded record that you've previously entered.</li>
		<li>Yellow Screen: A record has been saved but has errors that must be corrected. Fix and save to continue.</li>
	</ul>
    <p>
        <a href="/Bulkloader/cloneWithBarcodes.cfm">Clone records by Barcode</a>
    </p>
				<cfquery datasource="#Application.web_user#" name="theirLast">
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
									<option value="#theId#">Your Last #instAc# #collnCde#</option>
								</cfloop>								
							</cfif>
							<cfloop query="c">
								<option value="#collection_id#">Enter a new #institution_acronym# #collection_cde# Record</option>
							</cfloop>
						</select>
						<input class="lnkBtn" onmouseover="this.className='lnkBtn btnhov'"
							onmouseout="this.className='lnkBtn'"
							type="submit" value="Enter Data"/>
					</form>
</cfoutput>	
</cfif>
<!------------ editEnterData --------------------------------------------------------------------------------------------->
<cfif action is "editEnterData">
<cfoutput>
<cfif not isdefined("collection_object_id") or len(#collection_object_id#) is 0>
	you don't have an ID. <cfabort>
</cfif>
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from bulkloader where collection_object_id=#collection_object_id#
</cfquery>
<!------------------- check these data ------------------->
<cfif #collection_OBJECT_ID# GT 50>
	<cfquery name="oneRecord" dbtype="query">
		select * from data
	</cfquery>
	<cfinclude template="Bulkloader/BulkloaderCheck.cfm">
<cfelse>
	<cfset loadedMsg = "">
</cfif>
</cfoutput>
<!------------------- end check these data ------------------->
<cfoutput query="data">
	<!---- get data for dropdowns; cache it to speed up the form; refresh every hour---->
	<cfquery name="ctInst" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
		SELECT institution_acronym || ' ' || collection_cde as instcoll, collection_id FROM collection
			<cfif len(#collection_cde#) gt 0>
				WHERE collection_cde='#collection_cde#'
			</cfif>
	</cfquery>
	<cfquery name="ctnature" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
		select nature_of_id from ctnature_of_id order by nature_of_id
	</cfquery>
	<cfquery name="ctunits" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
       select ORIG_LAT_LONG_UNITS from ctLAT_LONG_UNITS order by orig_lat_long_units
    </cfquery>
	<cfquery name="ctflags" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
       select flags from ctflags order by flags
    </cfquery>
	<cfquery name="CTCOLL_OBJ_DISP" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
       select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP order by coll_obj_DISPOSITION
    </cfquery>	 
	<cfquery name="cterror" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
    	select LAT_LONG_ERROR_UNITS from ctLAT_LONG_ERROR_UNITS order by lat_long_error_units
    </cfquery>
	<cfquery name="ctdatum" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
		select datum from ctdatum order by datum
    </cfquery>    
	<cfquery name="ctgeorefmethod" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
       	select georefmethod from ctgeorefmethod order by georefmethod
    </cfquery>
	<cfquery name="ctverificationstatus" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
       	select verificationstatus from ctverificationstatus order by verificationstatus
    </cfquery>
	<cfquery name="ctcollecting_source" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
       	select collecting_source from ctcollecting_source order by collecting_source
    </cfquery>			
    <cfquery name="ctew" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
    	select e_or_w from ctew order by e_or_w
    </cfquery>
    <cfquery name="ctns" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
       	select n_or_s from ctns order by n_or_s
    </cfquery>
	<cfquery name="ctOtherIdType" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
		SELECT distinct(other_id_type) FROM ctColl_Other_id_type
		order by other_id_type
    </cfquery>
	<cfquery name="ctSex_Cde" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
		SELECT distinct(sex_cde) as sex_cde FROM ctSex_Cde
		<cfif len(#collection_cde#) gt 0>
			WHERE collection_cde='#collection_cde#'
		</cfif>
		order by sex_cde
	</cfquery>
	<cfquery name="ctOrigElevUnits" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
       	select orig_elev_units from ctorig_elev_units
    </cfquery>
	<cfquery name="ctbiol_relations" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
      	select BIOL_INDIV_RELATIONSHIP from ctbiol_relations
		order by BIOL_INDIV_RELATIONSHIP
    </cfquery>
	<cfquery name="ctPartName" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
		SELECT distinct(part_name) FROM ctSpecimen_part_name
		<cfif len(#collection_cde#) gt 0>
			WHERE collection_cde='#collection_cde#'
		</cfif>
		order by part_name
    </cfquery>
	<cfquery name="ctPartModifier" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
		SELECT distinct(part_modifier) FROM ctSpecimen_part_modifier
		order by part_modifier
    </cfquery>
	<cfquery name="ctPresMeth" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
		select preserve_method from ctspecimen_preserv_method
		<cfif len(#collection_cde#) gt 0>
			WHERE collection_cde='#collection_cde#'
		</cfif>
		order by preserve_method
	</cfquery>
	<cfquery name="ctAttributeType" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
		select distinct(attribute_type) from ctattribute_type
		<cfif len(#collection_cde#) gt 0>
			WHERE collection_cde='#collection_cde#'
		</cfif>
		order by attribute_type
	</cfquery>
	<cfquery name="ctLength_Units" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
		select length_units from ctLength_Units order by length_units
	</cfquery>
	<cfquery name="ctWeight_Units" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
		select Weight_Units from ctWeight_Units order by weight_units
	</cfquery>
	<cfquery name="ctattribute_type" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
		SELECT attribute_type FROM ctattribute_type 
		<cfif len(#collection_cde#) gt 0>
			WHERE collection_cde='#collection_cde#'
		</cfif>
		order by attribute_type
	</cfquery>
	<cfquery name="ctgeology_attribute" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
		select geology_attribute from ctgeology_attribute order by geology_attribute
	</cfquery>
	<cfquery name="ctCodes" datasource="#Application.web_user#" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			attribute_type,
			value_code_table,
			units_code_table
	 	from ctattribute_code_tables
	</cfquery>
<!----------------- end dropdowns --------------------->
<cfset thisUser = "#session.username#">
<cfset sql = "select collection_object_id from bulkloader
	where collection_object_id > 10">
	<cfif #ImAGod# is "no">
		 <cfset sql = "#sql# AND enteredby = '#thisUser#'">
	<cfelse>
		<cfset afg = "">
		<cfloop list="#adminForUsers#" index="m">
			<cfif len(#afg#) is 0>
				<cfset afg="'#m#'">
			<cfelse>
				<cfset afg="#afg#,'#m#'">
			</cfif>
		</cfloop>
		<cfset sql = "#sql# AND enteredby IN (#afg#)">
	</cfif>
	<cfset sql = "#sql# order by collection_object_id">
<cfquery name="whatIds" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(sql)#
</cfquery>
<cfset idList = "">
	<cfloop query="whatIds">
		<cfset idList = "#idList#,#collection_object_id#">
	</cfloop>
	<cfset currentPos = listFind(idList,data.collection_object_id)>
<cfif len(#loadedMsg#) gt 0>
	<!--- peel the first "; " off loadedMsg --->
	<cfset loadedMsg = right(loadedMsg,len(loadedMsg) - 2)>
	<cfset pageTitle = replace(loadedMsg,"::","","all")>
<cfelse>
	<cfset pageTitle = "This record has passed all bulkloader checks!">
</cfif>
<cfif not isdefined("inEntryGroups") OR #len(inEntryGroups)# eq 0>
	You have group issues! You must be in a Data Entry group to use this form.
	<cfabort>
</cfif>
<div align="center">
<div id="splash"align="center">
	<span style="background-color:##FF0000; font-size:large;">
		Page Loading....
	</span>
</div>
<form name="dataEntry" method="post" action="DataEntry.cfm" onsubmit="return cleanup(); return noEnter();" id="dataEntry">
<table width="100%" cellspacing="0" cellpadding="0" id="theTable" style="display:none;"> <!--- whole page table --->
	<tr>
		<td colspan="2" style="border-bottom: 1px solid black; " align="center">
			<div id="pageTitle"><strong>#pageTitle#</strong></div>	
		</td>
	</tr>
	<tr>
		<td width="50%" valign="top"><!--- left top of page --->		
<input type="hidden" name="action" value="" id="action">
	<input type="hidden" name="nothing" value="" id="nothing"/><!--- trashcan for picks - don't delete --->
	<input type="hidden" name="ImAGod" value="#ImAGod#" id="ImAGod"><!--- allow power users to browse other's records --->
	<input type="hidden" name="collection_cde" value="#collection_cde#" id="collection_cde">
	<input type="hidden" name="institution_acronym" value="#institution_acronym#" id="institution_acronym">
	<input type="hidden" name="collection_object_id" value="#collection_object_id#"  id="collection_object_id"/>  
	<input type="hidden" name="loaded" value="waiting approval"  id="loaded"/>
	<table cellpadding="0" cellspacing="0" class="fs"><!--- cat item IDs --->
		<tr>
			<td valign="top">
					<span class="f11a">Coll:</span>
					#institution_acronym# #collection_cde#
					<span class="f11a">Cat##</span>
					<input type="text" name="cat_num" value="#cat_num#"  size="6"
						id="cat_num" class="d11a">
						<cfif isdefined("session.CustomOtherIdentifier") and len(#session.CustomOtherIdentifier#) gt 0>
							<span class="f11a">#session.CustomOtherIdentifier#</span>
							<input type="hidden" name="other_id_num_type_5" value="#session.CustomOtherIdentifier#" id="other_id_num_type_5" />
							<input type="text" name="other_id_num_5" value="#other_id_num_5#" 
								size="8"
								id="other_id_num_5" class="d11a">
							<span id="rememberLastId">
							<cfif isdefined("session.rememberLastOtherId") and #session.rememberLastOtherId# is 1>
								<span class="infoLink" onclick="rememberLastOtherId(0)">Nevermind</span>
							<cfelse>
								<span class="infoLink" onclick="rememberLastOtherId(1)">Increment this</span>
							</cfif>
						</cfif>
						</span>
					<span class="f11a">Accn</span>
						<input type="text" name="accn" value="#accn#" size="13"
						class="d11a reqdClr" id="accn" onchange="isGoodAccn();">
			</td>
		</tr>
	</table>
<!---------------------------------- / cat item IDs ---------------------------------------------->
<!------------------------------------- agents ---------------------------------------------------->
	<table cellpadding="0" cellspacing="0" class="fs">
		<tr>
			<td rowspan="99" valign="top">
				<img src="/images/info.gif" border="0" onClick="getDocs('agent')" class="likeLink" alt="[ help ]">
			</td>
			<td align="right">
				<select name="collector_role_1" 
					size="1"
					class="reqdClr d11a"
					id="collector_role_1">
					<option selected value="c">Collector&nbsp;&nbsp;&nbsp;</option>
				</select> 
			</td>
			<td nowrap="nowrap">
				<span class="f11a">1</span>
				<input type="text" 
					name="collector_agent_1" 
					value="#collector_agent_1#" 
					class="reqdClr d11a" 
					onchange="if(this.value.length>0) {getAgent('nothing','collector_agent_1','dataEntry',this.value); return false;}"
					id="collector_agent_1">
					<img src="/images/copyall.gif" 
						border="0"  
						height="18" 
						width="18" 
						class="likeLink"
						alt="[ help ]"
						onclick="copyAllAgents('collector_agent_1');" />
			</td>
			<!--- 2 --->
			<td align="right">
				<cfset thisRole=#collector_role_2#>
				<select 
					name="collector_role_2" 
					size="1"
					class="d11a"
					id="collector_role_2"
					onChange="dataEntry.collector_agent_2.className='looky';
						dataEntry.collector_agent_2.focus();">
					<option value=""></option>
					<option <cfif #collector_role_2# is "c"> selected </cfif>value="c">Collector</option>
					<option <cfif #collector_role_2# is "p"> selected </cfif>value="p">Preparator</option>
				</select>
			</td>
			<td>
				<span class="f11a">2</span>
				<input type="text" 
					name="collector_agent_2" 
					class="d11a"
					value="#collector_agent_2#" 
					onchange="if(this.value.length>0) {getAgent('nothing','collector_agent_2','dataEntry',this.value); return false;}"
					onblur = "this.className='d11a';"
					id="collector_agent_2">
			</td>
		</tr>	
		<tr>
			<td align="right">
				<cfset thisRole=#collector_role_3#>
				<select name="collector_role_3" 
					size="1"
					class="d11a"
					id="collector_role_3"
					onChange="dataEntry.collector_agent_3.className='d11a';
					dataEntry.collector_agent_3.focus();">
					<option value=""></option>
					<option <cfif #collector_role_3# is "c"> selected </cfif>value="c">Collector</option>
					<option <cfif #collector_role_3# is "p"> selected </cfif>value="p">Preparator</option>
				</select>
			</td>
			<td>
				<span class="f11a">3</span>
				<input type="text" name="collector_agent_3" value="#collector_agent_3#"
					onchange="if(this.value.length>0) {getAgent('nothing','collector_agent_3','dataEntry',this.value); return false;}"
					id="collector_agent_3"
					class="d11a">
			</td>
			<td align="right">
				<cfset thisRole=#collector_role_4#>
				<select name="collector_role_4" 
					size="1"
					class="d11a"
					id="collector_role_4"
					onChange="dataEntry.collector_agent_4.className='d11a';
					dataEntry.collector_agent_4.focus();">
					<option value=""></option>
					<option <cfif #collector_role_4# is "c"> selected </cfif>value="c">Collector</option>
					<option <cfif #collector_role_4# is "p"> selected </cfif>value="p">Preparator</option>
				</select>
	
			</td>
			<td width="100%"><!--- force this as wide as possible to align stuff left --->
				<span class="f11a">4</span>
				<input type="text" name="collector_agent_4" value="#collector_agent_4#"
					onchange="getAgent('nothing','collector_agent_4','dataEntry',this.value); return false;"
					id="collector_agent_4"
					class="d11a">
			</td>
		</tr>
		<tr>
			<td align="right">
				<cfset thisRole=#collector_role_5#>
				<select name="collector_role_5" 
					size="1"
					class="d11a"
					id="collector_role_5"
					onChange="dataEntry.collector_agent_5.className='d11a';dataEntry.collector_agent_5.focus();">
					<option value=""></option>
					<option <cfif #collector_role_5# is "c"> selected </cfif>value="c">Collector</option>
					<option <cfif #collector_role_5# is "p"> selected </cfif>value="p">Preparator</option>
				</select>
			</td>
			<td>
				<span class="f11a">5</span>
				<input type="text" name="collector_agent_5" value="#collector_agent_5#"
					onchange="if(this.value.length>0) {getAgent('nothing','collector_agent_5','dataEntry',this.value); return false;}"
					id="collector_agent_5"
					class="d11a">
			</td>
		</tr>
	</table>
<!-------------------------------------- / agents------------------------------------------->	
<!---------------------------------------- other IDs --------------------------------------->
	<table cellpadding="0" cellspacing="0" class="fs">
			<tr>
				<td rowspan="99" valign="top">
					<!----
					<img src="/images/info.gif" border="0" onClick="getDocs('agent')" class="likeLink" alt="[ help ]">
					---->
				</td>
			<td>
					<cfset thisIdType=#other_id_num_type_1#>
					<span class="f11a">OtherID 1</span>
					<select name="other_id_num_type_1" size="1" style="width: 120"
						id="other_id_num_type_1"
						class="d11a"
						onChange="this.className='reqdClr d11a';
							dataEntry.other_id_num_1.className='reqdClr d11a';dataEntry.other_id_num_1.focus();">
						<option value=""></option>
						<cfloop query="ctOtherIdType">
							<option 
								<cfif #ctOtherIdType.other_id_type# is #thisIdType#> selected </cfif>
								value="#other_id_type#">#other_id_type#</option>
						</cfloop>
					</select>
					<input type="text" name="other_id_num_1" 
						class="d11a"
						value="#other_id_num_1#"
						id="other_id_num_1">
				</td>
			</tr>
			<tr>
				<td>
					<span class="f11a">OtherID 2</span>
					<cfset thisIdType=#other_id_num_type_2#>
					<select name="other_id_num_type_2" size="1" style="width: 120"
						class="d11a"
						id="other_id_num_type_2"
						onChange="dataEntry.other_id_num_2.className='reqdClr d11a';
							dataEntry.other_id_num_2.focus();">
						<option value=""></option>
						<cfloop query="ctOtherIdType">
							<option <cfif #ctOtherIdType.other_id_type# is #thisIdType#> selected </cfif>
							value="#other_id_type#">#other_id_type#</option>
						</cfloop>
					</select>
					<input type="text" 
						name="other_id_num_2" 
						value="#other_id_num_2#"
						class="d11a"
						id="other_id_num_2"
						onChange="dataEntry.other_id_num_type_3.focus();">
				</td>
			</tr>
			<tr>
				<td>
					<span class="f11a">OtherID 3</span>
					<cfset thisIdType=#other_id_num_type_3#>
					<select name="other_id_num_type_3" size="1" style="width: 120"
						class="d11a"
						id="other_id_num_type_3"
						onChange="dataEntry.other_id_num_3.className='d11a reqdClr';
							dataEntry.other_id_num_3.focus();">
						<option  value=""></option>
						<cfloop query="ctOtherIdType">
							<option <cfif #ctOtherIdType.other_id_type# is #thisIdType#> selected </cfif>
								value="#other_id_type#">#other_id_type#</option>
						</cfloop>
					</select>
					<input type="text" name="other_id_num_3" value="#other_id_num_3#"
						class="d11a"
						id="other_id_num_3">
				</td>
			</tr>
			<tr>
				<td>
					<span class="f11a">OtherID 4</span>
					<cfset thisIdType=#other_id_num_type_4#>
					<select name="other_id_num_type_4" size="1" style="width: 120"
						class="d11a"
						id="other_id_num_type_4"
						onChange="dataEntry.other_id_num_4.className='d11a reqdClr';
							dataEntry.other_id_num_4.focus();">
						<option  value=""></option>
						<cfloop query="ctOtherIdType">
							<option <cfif #ctOtherIdType.other_id_type# is #thisIdType#> selected </cfif>
								value="#other_id_type#">#other_id_type#</option>
						</cfloop>
					</select>
					<input type="text" name="other_id_num_4" value="#other_id_num_4#"
						class="d11a"
						id="other_id_num_4">
				</td>
			</tr>
		</table><!---- /other IDs ---->
<!------------------------------------------------- identification ---------------------------------->		
		<table cellpadding="0" cellspacing="0" class="fs">
		<tr>
			<td rowspan="99" valign="top">
				<img src="/images/info.gif" border="0" onClick="getDocs('identification')" class="likeLink" alt="[ help ]">
			</td>
			<td align="right">
			<span class="f11a">Scientific&nbsp;Name</span>
			</td>
			<td width="100%">
				<input 
					type="text" 
					name="taxon_name" 
					value="#taxon_name#" 
					class="reqdClr  d11a" 
					size="40"
					onchange="taxaPick('nothing','taxon_name','dataEntry',this.value); return false;"
					id="taxon_name">
			</td>
		</tr>
		<tr>
			<td align="right"><span class="f11a">ID By</span></td>
			<td>
				<input type="text" 
					name="id_made_by_agent" 
					value="#id_made_by_agent#" 
					class="reqdClr d11a"
					size="40" 
					onchange="getAgent('nothing','id_made_by_agent','dataEntry',this.value); return false;"
					id="id_made_by_agent">
					<img src="/images/copyall.gif" 
						border="0"  
						height="18" 
						width="18" 
						class="likeLink" 
						alt="[ copy ]"
						onclick="copyAllAgents('id_made_by_agent');" />
			</td>
		</tr>
		<tr>
			<td align="right"><span class="f11a">Nature</span></td>
			<td>
				<cfset thisNature=#nature_of_id#>
				<select name="nature_of_id" 
					size="1" 
					class="reqdClr d11a"
					id="nature_of_id">
						  <cfloop query="ctnature">
							<option 
							<cfif #nature_of_id# is #thisNature#> selected </cfif> 
							value="#ctnature.nature_of_id#">#ctnature.nature_of_id#</option>
						  </cfloop>
						</select>
			</td>
		</tr>
		<tr>
			<td align="right"><span class="f11a">Date</span></td>
			<td>
				<input type="text" name="made_date" value="#made_date#"
					id="made_date" 
					class="d11a">
					<img src="images/pick.gif" 
						class="likeLink" 
						border="0" 
						alt="[calendar]"
						name="anchor1"
						id="anchor1"
						onClick="cal1.select(document.dataEntry.made_date,'anchor1','dd-MMM-yyyy'); return false;"/>					
					<img src="/images/copyall.gif"
							border="0"  
							height="18" 
							width="18" 
							class="likeLink" 
							alt="[ copy ]"
							onclick="copyAllDates('made_date');" />
			</td>
		</tr>
		<tr>
			<td align="right"><span class="f11a">ID Remk</span></td>
			<td><input type="text" name="IDENTIFICATION_REMARKS" value="#IDENTIFICATION_REMARKS#"
				id="IDENTIFICATION_REMARKS"
				class="d11a" size="80">
			</td>
		</tr>
	</table>
<!----------------------------- /identification --------------------------------------------------------->
<!----------------------------- locality ---------------------------------------------------------------->
	<table cellspacing="0" cellpadding="0" class="fs">
		 	<tr>
				<td rowspan="99" valign="top">
					<img src="/images/info.gif" border="0" onClick="getDocs('locality')" class="likeLink" alt="[ help ]">
				</td>
				<td align="right"><span class="f11a">Higher Geog</span></td>
				<td width="100%">
					<input type="text" name="higher_geog" 
						class="reqdClr d11a"
						onchange="getGeog('nothing','higher_geog','dataEntry',this.value); return false;"
						id="higher_geog"
						value="#higher_geog#"
						size="80">
				</td>
			</tr>
			<tr>
				<td align="right"><span class="f11a">Spec&nbsp;Locality&nbsp;</span></td>
				<td nowrap="nowrap">
					<input type="text" name="spec_locality" class="reqdClr d11a"
						id="spec_locality"
						value="#stripQuotes(spec_locality)#" size="80">
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<table>
						<tr>
							<td align="right"><span class="f11a">Existing&nbsp;LocalityID:&nbsp;</span></td>
							<td>
								<input type="text" name="locality_id" id="locality_id" value="#locality_id#" readonly="readonly" class="readClr" size="8">
								<span class="infoLink" 
										id="localityPicker"
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
							<td align="right"><span class="f11a">Existing&nbsp;EventID:&nbsp;</span></td>
							<td>
								<input type="text" name="collecting_event_id" id="collecting_event_id" value="#collecting_event_id#" readonly="readonly" class="readClr" size="8">
								<span class="infoLink" 
										id="eventPicker"
										onclick="findCollEvent('collecting_event_id','dataEntry','verbatim_locality'); return false;">
											Pick&nbsp;Event
									</span>
									<span class="infoLink" 
										id="eventUnPicker"
										style="display:none;"
										onclick="unpickEvent()">
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
						class="reqdClr d11a"
						size="80"
						id="verbatim_locality" value="#stripQuotes(verbatim_locality)#">
					<span class="infoLink" 
						onclick="document.getElementById('verbatim_locality').value=document.getElementById('spec_locality').value;">
						Use Specloc
					</span>
				</td>
			</tr>			
			<tr>
				<td align="right"><span class="f11a">Date</span></td>
				<td>
					<input type="text" 
						name="verbatim_date" 
						class="reqdClr d11a" 
						value="#verbatim_date#"
						id="verbatim_date"
						size="20">
					<img
						src="/images/rt_arrow.gif" 
						class="likeLink"
						border="0"
						alt="[ copy ]"
						onClick="dataEntry.began_date.value=dataEntry.verbatim_date.value;
						dataEntry.ended_date.value=dataEntry.verbatim_date.value;">
					<span class="f11a">Begin</span>
					<input type="text" 
						name="began_date" 
						class="reqdClr d11a" 
						value="#began_date#"
						id="began_date"
						size="10"
						onFocus="VerbToBegan(this.value);">
					<img src="images/pick.gif" 
						class="likeLink" 
						border="0" 
						alt="[calendar]"
						name="anchor2"
						id="anchor2"
						onClick="cal1.select(document.dataEntry.began_date,'anchor2','dd-MMM-yyyy'); return false;"/>					
					<img src="/images/copyall.gif"
							border="0"  
							height="18" 
							width="18" 
							class="likeLink" 
							alt="[ copy ]"
							onclick="copyAllDates('began_date');" />
					<span class="f11a">End</span>
					<input type="text" 
						name="ended_date" 
						class="reqdClr d11a" 
						value="#ended_date#"
						id="ended_date"
						size="10"
						onFocus="VerbToEnd(this.value);">
					<img src="images/pick.gif" 
						class="likeLink" 
						border="0" 
						alt="[calendar]"
						name="anchor3"
						id="anchor3"
						onClick="cal1.select(document.dataEntry.ended_date,'anchor3','dd-MMM-yyyy'); return false;"/>					
					<img src="/images/copyall.gif"
							border="0"  
							height="18" 
							width="18" 
							class="likeLink" 
							alt="[ copy ]"
							onclick="copyAllDates('ended_date');" />
							
				</td>
			</tr>
			<tr>
				<td align="right"><span class="f11a">Coll. Meth.:</span></td>
				<td>
					<table cellspacing="0" cellpadding="0">
						<tr>
							<td>
								<input type="text" 
									name="collecting_method" 
									class="d11a" 
									value="#collecting_method#"
									id="collecting_method">
							</td>
							<td align="right"><span class="f11a">Coll. Src.:</span></td>
							<td>
								<cfif len(#collecting_source#) gt 0>
									<cfset thisCollSrc=#collecting_source#>
								<cfelse>
									<cfset thisCollSrc="wild caught">
								</cfif>
								<select name="collecting_source" 
									size="1" 
									id="collecting_source"
									class="d11a reqdClr">										
									<cfloop query="ctcollecting_source">
										<option 
											<cfif #collecting_source# is #thisCollSrc#> selected </cfif>
											value="#collecting_source#">#collecting_source#</option>
									</cfloop>
									</select>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td align="right"><span class="f11a">Habitat</span></td>
				<td>
					<input type="text"  
							name="habitat_desc" 
						class="d11a"
						size="50"
						id="habitat_desc" value="#habitat_desc#">
				</td>
			</tr>
			<tr>
				<td align="right"><span class="f11a">Associated&nbsp;Species</span></td>
				<td>
					<input type="text"  
							name="associated_species" 
						class="d11a"
						size="80"
						id="associated_species" value="#associated_species#">
				</td>
			</tr>
			<tr>
				<td align="right"><span class="f11a">Microhabitat</span></td>
				<td>
					<input type="text"  name="COLL_OBJECT_HABITAT"
						class="d11a"
						size="80"
						id="COLL_OBJECT_HABITAT" value="#COLL_OBJECT_HABITAT#">
				</td>
			</tr>
			<tr>
				<td align="right"><span class="f11a">Elevation</span></td>
				<td>
					<span class="f11a">&nbsp;between</span>
					<input type="text" 
						name="minimum_elevation" 
						size="4" 
						value="#minimum_elevation#"
						id="minimum_elevation"
						class="d11a">
					<span class="f11a"> and </span>
					<input type="text" 
							name="maximum_elevation" 
							size="4" 
							value="#maximum_elevation#"
							id="maximum_elevation"
							class="d11a">
						<cfset thisElUn=#orig_elev_units#>
						<select name="orig_elev_units" 
							size="1" 
							id="orig_elev_units"
							class="d11a">
								<option value=""></option>
								<cfloop query="ctOrigElevUnits">
									<option 
										<cfif #thisElUn# is #orig_elev_units#> selected </cfif>
										value="#orig_elev_units#">#orig_elev_units#</option>
								</cfloop>
						</select>
				</td>
			</tr>
			<tr>
				<td align="right"><span class="f11a">CollEvntRemk</span></td>
				<td>
					<input type="text" 
						name="coll_event_remarks" 
						size="80" 
						value="#coll_event_remarks#"
						id="coll_event_remarks"
						class="d11a">
				</td>
			</tr>
			<tr>
				<td align="right"><span class="f11a">LocalityRemk</span></td>
				<td>
					<input type="text" 
						name="locality_remarks" 
						size="80" 
						value="#locality_remarks#"
						id="locality_remarks"
						class="d11a">
				</td>
			</tr>
		 </table>
<!--------------------------------------- /locality -------------------------------------------------------------->
</td> <!---- end top left --->		
<td valign="top"><!----- right column ---->	
<!-------------------------------------- coordinates ------------------------------------------------------------->		
	<table cellpadding="0" cellspacing="0" class="fs">
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
							<select name="orig_lat_long_units"
								size="1"  
								id="orig_lat_long_units"
								class="d11a"
								onChange="switchActive(this.value);
									dataEntry.max_error_distance.focus();"
								>
									<option value=""></option>
										<cfloop query="ctunits">
										  <option <cfif #ORIG_LAT_LONG_UNITS# is #thisLLUnits#> selected </cfif>
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
					<input type="text" name="max_error_distance"  class="d11a"
						  id="max_error_distance"
						value="#max_error_distance#" size="10">
					<cfset thisMEUnit = #max_error_units#>
					<select name="max_error_units" 
						 size="1" 
						class="d11a"
						id="max_error_units">
								<option value=""></option>
								<cfloop query="cterror">
								  <option 
								  <cfif #cterror.LAT_LONG_ERROR_UNITS# is #thisMEUnit#> selected </cfif>
								  value="#cterror.LAT_LONG_ERROR_UNITS#">#cterror.LAT_LONG_ERROR_UNITS#</option>
								</cfloop>
							</select> 
				</td>
				<td align="right"><span class="f11a">Extent</span></td>
				<td>
					<input type="text" name="extent"  class="d11a"
						  id="extent"
						value="#extent#" size="10">
				</td>
			</tr>
			<tr>
				<td align="right"><span class="f11a">GPS Accuracy</span></td>
				<td>
					<input type="text" name="gpsaccuracy"  class="d11a"
						  id="gpsaccuracy"
						value="#gpsaccuracy#" size="10">
				</td>
				<td align="right"><span class="f11a">Datum</span></td>
				<td>
					<cfset thisDatum=#datum#>
					<select name="datum" size="1"
						class="reqdClr d11a"
						id="datum">
							<option value=""></option>
							<cfloop query="ctdatum">
							  <option <cfif #thisDatum# is #datum#> selected </cfif>
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
					<input type="text"
						name="determined_by_agent" 
						value="#determined_by_agent#" 
						class="reqdClr d11a" 
						onchange="getAgent('nothing','determined_by_agent','dataEntry',this.value); return false;"
						id="determined_by_agent">
				</td>
				<td align="right"><span class="f11a">Date</span></td>
				<td>
					<input type="text" 
						 name="determined_date" 
						class="d11a reqdClr"
						value="#determined_date#"
						id="determined_date">
					<img src="images/pick.gif" 
						class="likeLink" 
						border="0" 
						alt="[calendar]"
						name="anchor4"
						id="anchor4"
						onClick="cal1.select(document.dataEntry.determined_date,'anchor4','dd-MMM-yyyy'); return false;"/>					
					<img src="/images/copyall.gif"
							border="0"  
							height="18" 
							width="18" 
							class="likeLink" 
							alt="[ copy ]"
							onclick="copyAllDates('determined_date');" />
				</td>
			</tr>
			<tr>
				<td align="right"><span class="f11a">Reference</span></td>
				<td colspan="3" nowrap="nowrap">
					<input type="text" 
						name="lat_long_ref_source" 
						id="lat_long_ref_source" 
						class="reqdClr d11a" 
						size="60"
						value="#lat_long_ref_source#">
						<span class="infoLink" 
					  		onclick="getHelp('lat_long_ref_source');">Pick</span>
				</td>
			</tr>
			<tr>
				<td align="right"><span class="f11a">Georef Meth</span></td>
				<td>
					<cfset thisgeorefmethod = #georefmethod#>
					<select name="georefmethod" size="1" class="reqdClr d11a" 
						style="width:130 "
						id="georefmethod">
							<cfloop query="ctgeorefmethod">
							  <option <cfif #thisgeorefmethod# is #georefmethod#> selected </cfif>
							  value="#ctgeorefmethod.georefmethod#">#ctgeorefmethod.georefmethod#</option>
							</cfloop>
					</select> 
				</td>
				<td align="right"><span class="f11a">Verification</span></td>
				<td>
					<cfset thisverificationstatus = #verificationstatus#>
					<select name="verificationstatus" size="1" class="reqdClr d11a" 
						 id="verificationstatus">
							<cfloop query="ctverificationstatus">
							  <option <cfif #thisverificationstatus# is #verificationstatus#> selected </cfif>
							  value="#ctverificationstatus.verificationstatus#">#ctverificationstatus.verificationstatus#</option>
							</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td align="right"><span class="f11a">LatLongRemk</span></td>
				<td colspan="3">
					<input type="text" 
						name="LAT_LONG_REMARKS" 
						size="80" 
						value="#LAT_LONG_REMARKS#"
						id="lat_long_remarks"
						class="d11a">
				</td>
			</tr>
		</table>
	</div>
	<div id="dms" class="noShow">
		<table cellpadding="0" cellspacing="0">
			<tr>
				<td align="right"><span class="f11a">Lat Deg</span></td>
				<td>
					<input type="text"
						 name="latdeg" 
						size="4"
						id="latdeg"
						class="reqdClr d11a"
						value="#latdeg#">
				</td>
				<td align="right"><span class="f11a">Min</span></td>
				<td>
					<input type="text" 
						 name="LATMIN" 
						size="4"
						id="latmin"
						class="reqdClr d11a"						
						value="#LATMIN#">
				</td>
				<td align="right"><span class="f11a">Sec</span></td>
				<td>
					<input type="text" 
						 name="latsec" 
						size="6"
						id="latsec"
						class="reqdClr d11a"
						value="#latsec#">
					</td>
				<td align="right"><span class="f11a">Dir</span></td>
				<td>
					<select name="latdir"
						 size="1"
						id="latdir"
						class="reqdClr d11a"
						>
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
						class="reqdClr d11a"	
						value="#longdeg#">
				</td>
				<td align="right"><span class="f11a">Min</span></td>
				<td>
					<input type="text" 
						name="longmin" 
						size="4"
						id="longmin"
						class="reqdClr d11a"	
						value="#longmin#">
				</td>
				<td align="right"><span class="f11a">Sec</span></td>
				<td>
					<input type="text" 
						 name="longsec" 
						size="6"
						id="longsec"
						class="reqdClr d11a"	
						value="#longsec#">
				</td>
				<td align="right"><span class="f11a">Dir</span></td>
				<td>
					<select name="longdir"
						 size="1"
						id="longdir"
						class="reqdClr d11a"
						>
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
						class="reqdClr d11a"
						value="#latdeg#"
						onchange="dataEntry.latdeg.value=this.value;">
				</td>
				<td align="right"><span class="f11a">Dec Min</span></td>
				<td>
					<input type="text" 
						name="dec_lat_min" 
						 size="8"
						id="dec_lat_min"
						class="reqdClr d11a"
						value="#dec_lat_min#">
				</td>
				<td align="right"><span class="f11a">Dir</span></td>
				<td>
					<select name="decLAT_DIR"
						 size="1"
						id="decLAT_DIR"
						class="reqdClr d11a"						
						onchange="dataEntry.latdir.value=this.value;"
						>
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
						class="reqdClr d11a"
						value="#longdeg#"																
						onchange="dataEntry.longdeg.value=this.value;">
				</td>
				<td align="right"><span class="f11a">Dec Min</span></td>
				<td>
					<input type="text" 
						  name="DEC_LONG_MIN" 
						size="8"
						id="dec_long_min"
						class="reqdClr d11a"
						value="#DEC_LONG_MIN#">
				</td>
				<td align="right"><span class="f11a">Dir</span></td>
				<td>
					<select name="decLONGDIR"
						 size="1"
						id="decLONGDIR"
						class="reqdClr d11a"											
						onchange="dataEntry.longdir.value=this.value;"
						>
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
						class="reqdClr d11a"
						value="#dec_lat#">
		<span class="f11a">Dec Long</span>
					<input type="text" 
						 name="dec_long" 
						size="8"
						id="dec_long"
						class="reqdClr d11a"
						value="#dec_long#">
	</div>
	<div id="utm" class="noShow">
		<span class="f11a">UTM Zone</span>
					<input type="text" 
						 name="utm_zone" 
						size="8"
						id="utm_zone"
						class="reqdClr d11a"
						value="#utm_zone#">
		<span class="f11a">UTM E/W</span>
					<input type="text" 
						 name="utm_ew" 
						size="8"
						id="utm_ew"
						class="reqdClr d11a"
						value="#utm_ew#">
		<span class="f11a">UTM N/S</span>
					<input type="text" 
						 name="utm_ns" 
						size="8"
						id="utm_ns"
						class="reqdClr d11a"
						value="#utm_ns#">
	</div>
	</td>
	</tr>
	</table>
<!-------------------------------------------------- /coordinates --------------------------------------------------->
<!-------------------------------------------------- geology --------------------------------------------------->
<cfif #collection_cde# is "ES">
<div id="geolCell">
	<table cellpadding="0" cellspacing="0" class="fs">
		<tr>
			<td>
				<img src="/images/info.gif" border="0" onClick="getDocs('geology_attributes')" class="likeLink" alt="[ help ]">
				<table cellpadding="0" cellspacing="0">
					<tr>
						<th nowrap="nowrap">
							<span class="f11a">Geol Att.</span>
						</th>
						<th>
							<span class="f11a">Geol Att. Value</span>
						</th>
						<th>
							<span class="f11a">Determiner</span>
						</th>
						<th>
							<span class="f11a">Date</span>
						</th>
						<th>
							<span class="f11a">Method</span>
						</th>
						<th>
							<span class="f11a">Remark</span>
						</th>
					</tr>
					<cfloop from="1" to="6" index="i">
						<cfset thisAttribute= evaluate("data.geology_attribute_" & i)>
						<cfset thisVal= evaluate("data.geo_att_value_" & i)>
						<cfset thisDeterminer= evaluate("data.geo_att_determiner_" & i)>
						<cfset thisDate= evaluate("data.geo_att_determined_date_" & i)>
						<cfset thisMeth= evaluate("data.geo_att_determined_method_" & i)>
						<cfset thisRemark= evaluate("data.geo_att_remark_" & i)>
						<div id="#i#">
						<tr>
							<td>
								<select name="geology_attribute_#i#" id="geology_attribute_#i#" size="1" class="d11a">
									<option value=""></option>
									<cfloop query="ctgeology_attribute">
										<option 
											<cfif #thisAttribute# is #geology_attribute#> selected="selected" </cfif>
												value="#geology_attribute#">#geology_attribute#</option>
									</cfloop>
								</select>								
							</td>
							<td>
								<input type="text" 
									name="geo_att_value_#i#"
									id="geo_att_value_#i#"
									value="#thisVal#"
									class="d11a"
									size="25">	
							</td>
							<td>
								<input type="text" 
									name="geo_att_determiner_#i#"
									id="geo_att_determiner_#i#"
									value="#thisDeterminer#" 
									class="d11a" 
									onchange="getAgent('nothing','geo_att_determiner_#i#','dataEntry',this.value); return false;"/>
							</td>
							<td>
								<input type="text" 
									name="geo_att_determined_date_#i#"
									id="geo_att_determined_date_#i#"
									value="#thisDate#"
									class="d11a"
									size="10"
									onclick="cal1.select(document.dataEntry.geo_att_determined_date_#i#,'anchor1#i#','dd-MMM-yyyy');">
								<a name="anchor1#i#" id="anchor1#i#"></a>
								<!---
								<img src="images/pick.gif" 
									class="likeLink" 
									border="0" 
									alt="[calendar]"
									name="anchor1#i#"
									id="anchor1#i#"
									onClick="cal1.select(document.dataEntry.geo_att_determined_date_#i#,'anchor1#i#','dd-MMM-yyyy'); return false;"/>
									--->	
							</td>
							<td>
								<input type="text" 
									name="geo_att_determined_method_#i#"
									id="geo_att_determined_method_#i#"
									value="#thisMeth#"
									class="d11a"
									size="15">						
							</td>
							<td>
								<input type="text" 
									name="geo_att_remark_#i#"
									id="geo_att_remark_#i#"
									value="#thisRemark#"
									class="d11a"
									size="15">						
							</td>
						</tr>
						</div>
						<script>
							jQuery("##geo_att_value_#i#").suggest("/ajax/tData.cfm?action=suggestGeologyAttVal",{minchars:1,typeField:"geology_attribute_#i#"});
						</script>
					</cfloop>
				</table>
			</td>
		</tr>
	</table>
</div>
</cfif>		
<!-------------------------------------------------- /geology --------------------------------------------------->
<!-------------------------------------------------- attributes --------------------------------------------------->
<table cellpadding="0" cellspacing="0" class="fs">
	<tr>
		<td>
		<cfif #collection_cde# is not "Crus" and #collection_cde# is not "Herb"
			and #collection_cde# is not "ES" and #collection_cde# is not "Fish"
			and #collection_cde# is not "Para">
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
					class="reqdClr d11a"
					style="width: 80">
					<option value=""></option>
					<cfloop query="ctSex_Cde">
						<option 
							<cfif #data.attribute_value_1# is #Sex_Cde#> selected </cfif>value="#Sex_Cde#">#Sex_Cde#</option>
					</cfloop>
				 </select>
				<span class="f11a">Date</span>
				<input type="text" name="attribute_date_1" value="#attribute_date_1#"
					id="attribute_date_1" 
					class="d11a" size="10">
					<img src="images/pick.gif" 
						class="likeLink" 
						border="0" 
						alt="[calendar]"
						name="anchor5"
						id="anchor5"
						onClick="cal1.select(document.dataEntry.attribute_date_1,'anchor5','dd-MMM-yyyy'); return false;"/>					
					<span class="infoLink"
						onclick="copyAttributeDates('attribute_date_1');">Sync Att.</span>
							
				<span class="f11a">Detr</span>
				<input type="text" 
					name="attribute_determiner_1" 
					value="#attribute_determiner_1#" 
					class="reqdClr d11a" 
					onchange="getAgent('nothing','attribute_determiner_1','dataEntry',this.value); return false;"
					onblur="doAttributeDefaults();"
					id="attribute_determiner_1" />
					<span class="infoLink"
						onclick="copyAttributeDetr('attribute_determiner_1');">Sync Att.</span>
				<span class="f11a">Meth</span>
				<input type="text" 
					name="ATTRIBUTE_DET_METH_1" 
					value="#ATTRIBUTE_DET_METH_1#" 
					class="d11a" 
					id="ATTRIBUTE_DET_METH_1">
			</td>
		</tr>
	</table>
	<cfelse>
		<!-- easiest to just reserve this stuff as blank hidden fields -->
		<input type="hidden" name="attribute_1" id="attribute_1" value="">
		<input type="hidden" name="attribute_value_1"  id="attribute_value_1" value="">
		<input type="hidden" name="attribute_date_1"  id="attribute_date_1" value="">
		<input type="hidden" name="attribute_determiner_1"  id="attribute_determiner_1" value="">
		<input type="hidden" name="ATTRIBUTE_DET_METH_1"  id="ATTRIBUTE_DET_METH_1" value="">
	</cfif>
	<table cellpadding="1" cellspacing="0">
		<!----------------------------------- mammal-specific attributes ----------------------------->
		<cfif #collection_cde# is "Mamm">
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
				<input type="text" name="attribute_value_2" value="#attribute_value_2#" size="3"
					id="attribute_value_2" 
					class="d11a">
			</td>
			<td>
				<input type="hidden" name="attribute_units_3" value="#attribute_units_3#" id="attribute_units_3" />
				<input type="hidden" name="attribute_date_3" value="#attribute_date_3#" id="attribute_date_3" />
				<input type="hidden" name="attribute_determiner_3" value="#attribute_determiner_3#" id="attribute_determiner_3" />
				<input type="hidden" name="attribute_3" value="tail length" />
				<input type="text" name="attribute_value_3" value="#attribute_value_3#" size="3"
					id="attribute_value_3" 
					class="d11a">
			</td>
			<td align='center'>
				<input type="hidden" name="attribute_units_4" value="#attribute_units_4#" id="attribute_units_4" />
				<input type="hidden" name="attribute_date_4" value="#attribute_date_4#" id="attribute_date_4" />
				<input type="hidden" name="attribute_determiner_4" value="#attribute_determiner_4#" id="attribute_determiner_4" />
				<input type="hidden" name="attribute_4" value="hind foot with claw" />
				<input type="text" name="attribute_value_4" value="#attribute_value_4#" size="3"
					id="attribute_value_4" 
					class="d11a">
			</td>
			<td align='center'>
				<input type="hidden" name="attribute_units_5" value="#attribute_units_5#" id="attribute_units_5" />
				<input type="hidden" name="attribute_date_5" value="#attribute_date_5#" id="attribute_date_5" />
				<input type="hidden" name="attribute_determiner_5" value="#attribute_determiner_5#" id="attribute_determiner_5" />
				<input type="hidden" name="attribute_5" value="ear from notch" />
				<input type="text" name="attribute_value_5" value="#attribute_value_5#" size="3"
					id="attribute_value_5" 
					class="d11a">
			</td>
			<td>
				<select name="attribute_units_2" size="1"
					class="d11a"
					id="attribute_units_2">
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
				<input type="text" name="attribute_value_6" value="#attribute_value_6#" size="3"
					id="attribute_value_6" 
					class="d11a">
			</td>
			<td>
				<select name="attribute_units_6" size="1"
						id="attribute_units_6"
						class="d11a">
					<cfloop query="ctWeight_Units">
						<option <cfif #data.attribute_units_6# is #Weight_Units#> selected </cfif>value="#Weight_Units#">#Weight_Units#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<input type="text" name="attribute_date_2"
					id="attribute_date_2" 
					class="d11a"
					value="#attribute_date_2#">
					<A HREF="##" onClick="cal1.select(document.dataEntry.attribute_date_2,'anchor3','dd MMM yyyy'); return false;" 
					NAME="anchor3" ID="anchor3"><img src="images/pick.gif" border="0" alt="pick"/></A>				
			</td>
			<td>
				<input type="text" 
					name="attribute_determiner_2" 
					class="d11a" 
					onchange="getAgent('nothing','attribute_determiner_2','dataEntry',this.value); return false;"
					id="attribute_determiner_2"
					value="#attribute_determiner_2#">
				
			</td>
		</tr>
		<!----------------------------------- / mammal-specific attributes ------------------------------------->
		<cfelseif #collection_cde# is "Bird">
		<!--------------------------------- Bird-specific attributes --------------------------------------------->
		<tr>
			<td><span class="f11a">Age</span></td>
			<td><span class="f11a">Fat</span></td>
			<td><span class="f11a">Molt</span></td>
			<td><span class="f11a">Ossification</span></td>
			<!---<td><span class="f11a">Units</span></td>--->
			<td colspan="2" align="center"><span class="f11a">Weight</span></td>
			<td><span class="f11a">Date</span></td>
			<td><span class="f11a">Determiner</span></td>
		<tr>
			<td>
				<input type="hidden" name="attribute_2" value="age" />
				<input type="text" name="attribute_value_2" value="#attribute_value_2#" size="3"
					id="attribute_value_2" 
					class="d11a">
			</td>
			<td>
				<input type="hidden" name="attribute_date_3" value="#attribute_date_3#" id="attribute_date_3" />
				<input type="hidden" name="attribute_determiner_3" value="#attribute_determiner_3#" id="attribute_determiner_3" />
				<input type="hidden" name="attribute_3" value="fat deposition" />
				<input type="text" name="attribute_value_3" value="#attribute_value_3#" size="15"
					id="attribute_value_3" 
					class="d11a">
			</td>
			<td>
				<input type="hidden" name="attribute_date_4" value="#attribute_date_4#" id="attribute_date_4" />
				<input type="hidden" name="attribute_determiner_4" value="#attribute_determiner_4#" id="attribute_determiner_4" />
				<input type="hidden" name="attribute_4" value="molt condition" />
				<input type="text" name="attribute_value_4" value="#attribute_value_4#" size="15"
					id="attribute_value_4" 
					class="d11a">
			</td>
			<td>
				<input type="hidden" name="attribute_date_5" value="#attribute_date_5#" id="attribute_date_5" />
				<input type="hidden" name="attribute_determiner_5" value="#attribute_determiner_5#" id="attribute_determiner_5" />
				<input type="hidden" name="attribute_5" value="skull ossification" />
				<input type="text" name="attribute_value_5" value="#attribute_value_5#" size="15"
					id="attribute_value_5" 
					class="d11a">
			</td>
			<!---
			<td>
				<select name="attribute_units_2" size="1"
					class="d11a"
					id="attribute_units_2">
					<cfloop query="ctLength_Units">
						<option <cfif #data.attribute_units_2# is #Length_Units#> selected </cfif> 
						value="#Length_Units#">#Length_Units#</option>
					</cfloop>
				</select>
			</td>
			--->
			<td>
				<input type="hidden" name="attribute_date_6" value="#attribute_date_6#" id="attribute_date_6" />
				<input type="hidden" name="attribute_determiner_6" value="#attribute_determiner_6#" id="attribute_determiner_6" />
				<input type="hidden" name="attribute_6" value="weight" />
				<input type="text" name="attribute_value_6" value="#attribute_value_6#" size="2"
					id="attribute_value_6" 
					class="d11a">
			</td>
			<td>
				<select name="attribute_units_6" size="1"
						id="attribute_units_6"
						class="d11a">
					<cfloop query="ctWeight_Units">
						<option <cfif #data.attribute_units_6# is #Weight_Units#> selected </cfif>value="#Weight_Units#">#Weight_Units#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<input type="text" name="attribute_date_2"
					id="attribute_date_2" 
					class="d11a"
					value="#attribute_date_2#">
					<A HREF="##" onClick="cal1.select(document.dataEntry.attribute_date_2,'anchor3','dd MMM yyyy'); return false;" 
					NAME="anchor3" ID="anchor3"><img src="images/pick.gif" border="0" alt="pick"/></A>				
			</td>
			<td>
				<input type="text" 
					name="attribute_determiner_2" 
					class="d11a" 
					onchange="getAgent('nothing','attribute_determiner_2','dataEntry',this.value); return false;"
					id="attribute_determiner_2"
					value="#attribute_determiner_2#">
				
			</td>
		</tr>
		<!--------------------------------- /Bird-specific attributes --------------------------------------------->
		<cfelse>
			<cfloop from="2" to="6" index="i">
				<input type="hidden" name="attribute_#i#" id="attribute_#i#" value="">
				<input type="hidden" name="attribute_value_#i#"  id="attribute_value_#i#" value="">
				<input type="hidden" name="attribute_date_#i#"  id="attribute_date_#i#" value="">
				<input type="hidden" name="attribute_determiner_#i#"  id="attribute_determiner_#i#" value="">
				<input type="hidden" name="attribute_det_meth_#i#"  id="attribute_det_meth_#i#" value="">
			</cfloop>
		<!--- maintain attributes 2-6 as hiddens to not break the JS --->
		</cfif>
		
	</table>
		<table cellspacing="0" cellpadding="0">
			<tr>
				<td><span class="f11a">Attribute</span></td>
				<td><span class="f11a">Value</span></td>
				<td><span class="f11a">Units</span></td>
				<td><span class="f11a">Date</span></td>
				<td><span class="f11a">Determiner</span></td>
				<td><span class="f11a">Method</span></td>
				<td><span class="f11a">Remarks</span></td>
			</tr>
			<tr>
				<td>
					<select name="attribute_7" size="1" onChange="getAttributeStuff(this.value,this.id);"
						style="width:100;"
						id="attribute_7"
						class="d11a">
						<option value="">&nbsp;&nbsp;&nbsp;&nbsp;</option>						
						<cfloop query="ctAttributeType">
							<option 
								<cfif #data.attribute_7# is #attribute_type#> selected </cfif>
									value="#attribute_type#">#attribute_type#</option>
						</cfloop>
					  </select>
				</td>
				<td>
					<div id="attribute_value_cell_7">
					<input type="text" 
						name="attribute_value_7" 
						value="#attribute_value_7#" 
						id="attribute_value_7"
						class="d11a"
						size="15">
						</div>
				</td>
				<td>
					<div id="attribute_units_cell_7">
					<input type="text"
						name="attribute_units_7" 
						value="#attribute_units_7#" 
						id="attribute_units_7"
						size="6"
						class="d11a">
					</div>
				</td>
				<td>
					<input type="text" 
						class="d11a"
						name="attribute_date_7" 
						value="#attribute_date_7#" 
						id="attribute_date_7"
						size="10">
				</td>
				<td>
					 <input type="text" name="attribute_determiner_7"
						class="d11a"
						onchange="getAgent('nothing','attribute_determiner_7','dataEntry',this.value);"
						id="attribute_determiner_7"
						size="15"
						value="#attribute_determiner_7#">
				</td>
				<td>
					<input type="text" name="attribute_det_meth_7"
						class="d11a"
						id="attribute_det_meth_7"
						size="15"
						value="#attribute_det_meth_7#">
				</td>
				<td>
					<input type="text" name="attribute_remarks_7"
						class="d11a"
						id="attribute_remarks_7"
						value="#attribute_remarks_7#">
				</td>
			</tr>
			<tr>
				<td>
					<select name="attribute_8" size="1" onChange="getAttributeStuff(this.value,this.id);"
						style="width:100;"
						id="attribute_8"
						class="d11a">
						<option value=""></option>
						<cfloop query="ctAttributeType">
							<option 
								<cfif #data.attribute_8# is #attribute_type#> selected </cfif>
									value="#attribute_type#">#attribute_type#</option>
						</cfloop>
					  </select>
				</td>
				<td>
					<div id="attribute_value_cell_8">
					<input type="text" 
						name="attribute_value_8" 
						value="#attribute_value_8#" 
						id="attribute_value_8"
						class="d11a"						
						size="15">
					</div>
				</td>
				<td>
					<div id="attribute_units_cell_8">
					<input type="text" 
						name="attribute_units_8" 
						value="#attribute_units_8#" 
						id="attribute_units_8"
						size="6"
						class="d11a">
						</div>
				</td>
				<td>
					<input type="text" 
						class="d11a"
						name="attribute_date_8" 
						value="#attribute_date_8#" 
						id="attribute_date_8"
						size="10">
				</td>
				<td>
					 <input type="text" name="attribute_determiner_8"
						class="d11a"
						onchange="getAgent('nothing','attribute_determiner_8','dataEntry',this.value);"
						id="attribute_determiner_8"
						size="15"
						value="#attribute_determiner_8#">
				</td>
				<td>
					<input type="text" name="attribute_det_meth_8"
						class="d11a"
						id="attribute_det_meth_8"
						size="15"
						value="#attribute_det_meth_8#">
				</td>
				<td>
					<input type="text" name="attribute_remarks_8"
						class="d11a"
						id="attribute_remarks_8"
						value="#attribute_remarks_8#">
				</td>
			</tr>
			<tr>
				<td>
					<select name="attribute_9" size="1" onChange="getAttributeStuff(this.value,this.id);"
						style="width:100;"
						id="attribute_9"
						class="d11a">
						<option value=""></option>
						<cfloop query="ctAttributeType">
							<option 
								<cfif #data.attribute_9# is #attribute_type#> selected </cfif>
									value="#attribute_type#">#attribute_type#</option>
						</cfloop>
					  </select>
				</td>
				<td>
					<div id="attribute_value_cell_9">
					<input type="text" 
						name="attribute_value_9" 
						value="#attribute_value_9#" 
						id="attribute_value_9"
						class="d11a"
						size="15">
					</div>
				</td>
				<td>
					<div id="attribute_units_cell_9">
					<input type="text" 
						name="attribute_units_9" 
						value="#attribute_units_9#" 
						id="attribute_units_9"
						size="6"
						class="d11a">
					</div>
				</td>
				<td>
					<input type="text" 
						class="d11a"
						name="attribute_date_9" 
						value="#attribute_date_9#" 
						id="attribute_date_9"
						size="10">
				</td>
				<td>
					 <input type="text" name="attribute_determiner_9"
						class="d11a"
						onchange="getAgent('nothing','attribute_determiner_9','dataEntry',this.value);"
						id="attribute_determiner_9"
						size="15"
						value="#attribute_determiner_9#">
				</td>
				<td>
					<input type="text" name="attribute_det_meth_9"
						class="d11a"
						id="attribute_det_meth_9"
						size="15"
						value="#attribute_det_meth_9#">
				</td>
				<td>
					<input type="text" name="attribute_remarks_9"
						class="d11a"
						id="attribute_remarks_9"
						value="#attribute_remarks_9#">
				</td>
			</tr>
			<tr>
				<td>
					<select name="attribute_10" size="1"  onChange="getAttributeStuff(this.value,this.id);"
						style="width:100;"
						id="attribute_10"
						class="d11a">
						<option value=""></option>
						<cfloop query="ctAttributeType">
							<option 
								<cfif #data.attribute_10# is #attribute_type#> selected </cfif>
									value="#attribute_type#">#attribute_type#</option>
						</cfloop>
					  </select>
				</td>
				<td>
					<div id="attribute_value_cell_10">
					<input type="text" 
						name="attribute_value_10" 
						value="#attribute_value_10#" 
						id="attribute_value_10"
						class="d11a"
						size="15">
					</div>
				</td>
				<td>
					<div id="attribute_units_cell_10">
					<input type="text" 
						name="attribute_units_10" 
						value="#attribute_units_10#" 
						id="attribute_units_10"
						size="6"
						class="d11a">
						</div>
				</td>
				<td>
					<input type="text" 
						class="d11a"
						name="attribute_date_10" 
						value="#attribute_date_10#" 
						id="attribute_date_10"
						size="10">
				</td>
				<td>
					 <input type="text" name="attribute_determiner_10"
						class="d11a"
						onchange="getAgent('nothing','attribute_determiner_10','dataEntry',this.value);"
						id="attribute_determiner_10"
						size="15"
						value="#attribute_determiner_10#">
				</td>
				<td>
					<input type="text" name="attribute_det_meth_10"
						class="d11a"
						id="attribute_det_meth_10"
						size="15"
						value="#attribute_det_meth_10#">
				</td>
				<td>
					<input type="text" name="attribute_remarks_10"
						class="d11a"
						id="attribute_remarks_10"
						value="#attribute_remarks_10#">
				</td>
			</tr>
		</table>
	</td></tr></table>
<!---------------------------------------- /attributes ---------------------------------------------->
<!---------------------------------------- random admin stuff ---------------------------------------------->
				<table cellpadding="0" cellspacing="0" class="fs">
					<tr>
						<td align="right"><span class="f11a">Entered&nbsp;By</span></td>
						<td width="100%">
							<cfif #ImAGod# is not "yes"><input type="hidden"
								name="enteredby" 
								
								value="#session.username#"
								
								id="enteredby"
								class="d11a readClr"/>
								
							<input type="text" name="fake" value="#session.username#" disabled="disabled" /> 
								<cfelseif #ImAGod# is "yes">
								<input type="text"
								name="enteredby" 
								
								value="#enteredby#"
								
								id="enteredby"
								class="d11a "/>
								<cfelse>
								ERROR!!!
								</cfif> 
						</td>
					</tr>
					<tr>
						<td align="right"><span class="f11a">Disposition</span></td>
						<td>
							<cfset thisDisp = #COLL_OBJ_DISPOSITION#>
							<select name="coll_obj_disposition" size="1" class="d11a reqdClr" id="coll_obj_disposition">
								<cfloop query="CTCOLL_OBJ_DISP">
									<option
										<cfif #thisDisp# is #COLL_OBJ_DISPOSITION#> selected </cfif>
									 value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td align="right"><span class="f11a">Condition</span></td>
						<td>
							<input type="text" 
								class="d11a reqdClr"
								name="condition" 
								value="#condition#" 
								id="condition"
								size="50">
						</td>
					</tr>
					<tr>
						<td align="right"><span class="f11a">Relations</span></td>
						<td>
							 <cfset thisRELATIONSHIP = #RELATIONSHIP#>
							<select name="relationship" size="1" class="d11a" id="relationship">
								<option value=""></option>
								<cfloop query="ctbiol_relations">
									<option
										<cfif #thisRELATIONSHIP# is #BIOL_INDIV_RELATIONSHIP#> selected </cfif>
									 value="#BIOL_INDIV_RELATIONSHIP#">#BIOL_INDIV_RELATIONSHIP#</option>
								</cfloop>							
							</select>
							<cfset thisRELATED_TO_NUM_TYPE = #RELATED_TO_NUM_TYPE#>
							<select name="related_to_num_type" size="1" id="related_to_num_type" class="d11a" style="width: 80">
								<option value=""></option>
								<option value="catalog number">catalog number (UAM Mamm 123 format)</option>
								<cfloop query="ctOtherIdType">
									<option
										<cfif #thisRELATED_TO_NUM_TYPE# is #other_id_type#> selected </cfif>
									 value="#other_id_type#">#other_id_type#</option>
								</cfloop>							
							</select>
							<input type="text" value="#related_to_number#" name="related_to_number" id="related_to_number" size="10" class="d11a" />
						</td>
					</tr>
				</table>
<!---------------------------------------- random admin stuff ---------------------------------------------->
<!---------------------------------------- remarkey stuff ---------------------------------------------->				
		<table cellpadding="0" cellspacing="0" class="fs">
			<tr>
				<td colspan="2">
					<span class="f11a">Spec Remark</span>
						<textarea name="coll_object_remarks"
						class="d11a"
						id="coll_object_remarks"
						rows="2" cols="100">#coll_object_remarks#</textarea>
				</td>
			</tr>
			<tr>
				<td>
					<span class="f11a">Missing....</span>
					<cfset thisflags = #flags#>
					<select name="flags" size="1" style="width: 120"
						class="d11a"
						id="flags">
						<option  value=""></option>
						<cfloop query="ctflags">
							<option <cfif #flags# is #thisflags#> selected </cfif>
								value="#flags#">#flags#</option>
						</cfloop>
					</select>
				</td>
				<td>
					<span class="f11a">Status</span>
					#loaded#
				</td>
			</tr>
		</table>
<!---------------------------------------- remarkey stuff ---------------------------------------------->				

</td><!--- end right column --->
</tr><!---- end top row of page --->
<tr><!---- start bottom row of page --->
	<td colspan="2"><!--- parts block --->
		<table cellpadding="0" cellspacing="0" class="fs">
					
					<tr>
						<td rowspan="99" valign="top">
				<img src="/images/info.gif" border="0" onClick="getDocs('parts')" class="likeLink" alt="[ help ]">
			</td>
						<td><span class="f11a">Part Name</span></td>
						<td><span class="f11a">Part Modifier</span></td>
						<td><span class="f11a">Preserv Method</span></td>
						<td><span class="f11a">Condition</span></td>
						<td><span class="f11a">Disposition</span></td>
						<td><span class="f11a">##</span></td>
						<td><span class="f11a">Barcode</span></td>
						<td><span class="f11a">Vial Label</span></td>
						<td width="100%"><span class="f11a">Remark</span></td>
					</tr>
					<tr>
						<td>
							<cfset part1 = #part_name_1#>
							<select name="part_name_1" size="1"
								id="part_name_1"
								onFocus="self.status='First Part Name'"
								class="reqdClr d11a">
									<cfloop query="ctPartName">
										<option <cfif #part1# is #ctPartName.part_name#> selected </cfif>
											value="#part_name#">#part_name#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<cfset partmod1 = #part_modifier_1#>
							<select name="part_modifier_1" 
								size="1"
								id="part_modifier_1"
								class="d11a"
						onFocus="self.status='First Part Modifier'">
								<option value=""></option>
								<cfloop query="ctPartModifier">
									<option <cfif #partmod1# is #part_modifier#> selected </cfif>
									value="#part_modifier#">#part_modifier#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<cfset presmeth1 = #preserv_method_1#>
							<select name="preserv_method_1" size="1"
								id="preserv_method_1"
								class="d11a"
								onFocus="self.status='First Part Preservation Method'">
									<option value=""></option>
									<cfloop query="ctPresMeth">
										<option <cfif #presmeth1# is #preserve_method#> selected </cfif>
										value="#ctPresMeth.preserve_method#">#ctPresMeth.preserve_method#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<input type="text" name="part_condition_1"
								id="part_condition_1"
								onFocus="self.status='First Part Condition'"
								value="#part_condition_1#"
								class="reqdClr d11a">
						</td>
						<td>
							<cfset thisDisp = #part_disposition_1#>
							<select name="part_disposition_1" size="1" class="d11a reqdClr" id="part_disposition_1">
								<cfloop query="CTCOLL_OBJ_DISP">
									<option
										<cfif #thisDisp# is #COLL_OBJ_DISPOSITION#> selected </cfif>
									 value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" 
								name="part_lot_count_1" 
								id="part_lot_count_1"
								value="#part_lot_count_1#" 
								class="d11a reqdClr" size="1">
						</td>
						<td>
							<input type="text" 
								name="part_barcode_1" 
								id="part_barcode_1"
								value="#part_barcode_1#" 
								class="d11a" size="6"
								onchange="part_container_label_1.className='reqdClr d11a';setPartLabel(this.id);">
						</td>
						<td>
							<input type="text" 
								name="part_container_label_1" 
								id="part_container_label_1"
								value="#part_container_label_1#" 
								class="d11a" size="10">
						</td>
						<td>
							<input type="text" 
								name="part_remark_1" 
								id="part_remark_1"
								value="#part_remark_1#" 
								class="d11a" size="40">
						</td>
					</tr>
					<tr>
						<td>
							<cfset part2 = #part_name_2#>
							<select name="part_name_2" size="1"
								id="part_name_2"
								class="d11a"
								onchange="this.className='d11a reqdClr';
									part_condition_2.className='d11a reqdClr';
									part_lot_count_2.className='d11a reqdClr';
									part_disposition_2.className='d11a reqdClr';">
									<option value=""></option>
									<cfloop query="ctPartName">
										<option <cfif #part2# is #ctPartName.part_name#> selected </cfif>
											value="#part_name#">#part_name#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<cfset partmod2 = #part_modifier_2#>
							<select name="part_modifier_2" 
								size="1"
								id="part_modifier_2"
								class="d11a">
								<option value=""></option>
								<cfloop query="ctPartModifier">
									<option <cfif #partmod2# is #part_modifier#> selected </cfif>
									value="#part_modifier#">#part_modifier#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<cfset presmeth2 = #preserv_method_2#>
							<select name="preserv_method_2" size="1"
								id="preserv_method_2"
								class="d11a"
								onFocus="self.status='First Part Preservation Method'">
									<option value=""></option>
									<cfloop query="ctPresMeth">
										<option <cfif #presmeth2# is #preserve_method#> selected </cfif>
										value="#ctPresMeth.preserve_method#">#ctPresMeth.preserve_method#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<input type="text" name="part_condition_2"
								id="part_condition_2"
								onFocus="self.status='First Part Condition'"
								value="#part_condition_2#"
								class="d11a">
						</td>
						<td>
							<cfset thisDisp = #part_disposition_2#>
							<select name="part_disposition_2"
								id="part_disposition_2"
								size="1" 
								class="d11a">
								<cfloop query="CTCOLL_OBJ_DISP">
									<option
										<cfif #thisDisp# is #COLL_OBJ_DISPOSITION#> selected </cfif>
									 value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" 
								id="part_lot_count_2"
								name="part_lot_count_2" 
								value="#part_lot_count_2#" 
								class="d11a" size="1">
						</td>
						<td>
							<input type="text" 
								name="part_barcode_2" 
								value="#part_barcode_2#" 
								class="d11a" size="6"
								id="part_barcode_2"
								onchange="part_container_label_2.className='reqdClr d11a';setPartLabel(this.id);">
						</td>
						<td>
							<input type="text" 
								name="part_container_label_2"
								id="part_container_label_2" 
								value="#part_container_label_2#" 
								class="d11a" size="10">
						</td>
						<td>
							<input type="text" 
								name="part_remark_2" 
								id="part_remark_2"
								value="#part_remark_2#" 
								class="d11a" size="40">
						</td>
					</tr>
					<tr>
						<td>
							<cfset part3 = #part_name_3#>
							<select name="part_name_3" size="1"
								id="part_name_3"
								class="d11a"
								onchange="this.className='d11a reqdClr';
									part_condition_3.className='d11a reqdClr';
									part_lot_count_3.className='d11a reqdClr';
									part_disposition_3.className='d11a reqdClr';">
									<option value=""></option>
									<cfloop query="ctPartName">
										<option <cfif #part3# is #ctPartName.part_name#> selected </cfif>
											value="#part_name#">#part_name#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<cfset partmod3 = #part_modifier_3#>
							<select name="part_modifier_3" 
								size="1"
								id="part_modifier_3"
								class="d11a">
								<option value=""></option>
								<cfloop query="ctPartModifier">
									<option <cfif #partmod3# is #part_modifier#> selected </cfif>
									value="#part_modifier#">#part_modifier#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<cfset presmeth3 = #preserv_method_3#>
							<select name="preserv_method_3" size="1"
								id="preserv_method_3"
								class="d11a">
									<option value=""></option>
									<cfloop query="ctPresMeth">
										<option <cfif #presmeth3# is #preserve_method#> selected </cfif>
										value="#ctPresMeth.preserve_method#">#ctPresMeth.preserve_method#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<input type="text" name="part_condition_3"
								id="part_condition_3"
								value="#part_condition_3#"
								class="d11a">
						</td>
						<td>
							<cfset thisDisp = #part_disposition_3#>
							<select name="part_disposition_3"
								id="part_disposition_3"
								size="1" 
								class="d11a">
								<cfloop query="CTCOLL_OBJ_DISP">
									<option
										<cfif #thisDisp# is #COLL_OBJ_DISPOSITION#> selected </cfif>
									 value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" 
								name="part_lot_count_3" 
								id="part_lot_count_3"
								value="#part_lot_count_3#" 
								class="d11a" size="1">
						</td>
						<td>
							<input type="text" 
								name="part_barcode_3" 
								id="part_barcode_3"
								value="#part_barcode_3#" 
								class="d11a" size="6"
								onchange="part_container_label_3.className='reqdClr d11a';setPartLabel(this.id);">
						</td>
						<td>
							<input type="text" 
								name="part_container_label_3" 
								id="part_container_label_3"
								value="#part_container_label_3#" 
								class="d11a" size="10">
						</td>
						<td>
							<input type="text" 
								name="part_remark_3" 
								id="part_remark_3"
								value="#part_remark_3#" 
								class="d11a" size="40">
						</td>
					</tr>
					<tr>
						<td>
							<cfset part4 = #part_name_4#>
							<select name="part_name_4" size="1"
								id="part_name_4"
								class="d11a"
								onchange="this.className='d11a reqdClr';
									part_condition_4.className='d11a reqdClr';
									part_lot_count_4.className='d11a reqdClr';
									part_disposition_4.className='d11a reqdClr';">
									<option value=""></option>
									<cfloop query="ctPartName">
										<option <cfif #part4# is #ctPartName.part_name#> selected </cfif>
											value="#part_name#">#part_name#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<cfset partmod4 = #part_modifier_4#>
							<select name="part_modifier_4" 
								size="1"
								id="part_modifier_4"
								class="d11a">
								<option value=""></option>
								<cfloop query="ctPartModifier">
									<option <cfif #partmod4# is #part_modifier#> selected </cfif>
									value="#part_modifier#">#part_modifier#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<cfset presmeth4 = #preserv_method_4#>
							<select name="preserv_method_4" size="1"
								id="preserv_method_4"
								class="d11a"
								onFocus="self.status='First Part Preservation Method'">
									<option value=""></option>
									<cfloop query="ctPresMeth">
										<option <cfif #presmeth4# is #preserve_method#> selected </cfif>
										value="#ctPresMeth.preserve_method#">#ctPresMeth.preserve_method#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<input type="text" name="part_condition_4"
								id="part_condition_4"
								onFocus="self.status='First Part Condition'"
								value="#part_condition_4#"
								class="d11a">
						</td>
						<td>
							<cfset thisDisp = #part_disposition_4#>
							<select name="part_disposition_4"
								id="part_disposition_4"
								size="1" 
								class="d11a">
								<cfloop query="CTCOLL_OBJ_DISP">
									<option
										<cfif #thisDisp# is #COLL_OBJ_DISPOSITION#> selected </cfif>
									 value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" 
								id="part_lot_count_4"
								name="part_lot_count_4" 
								value="#part_lot_count_4#" 
								class="d11a" size="1">
						</td>
						<td>
							<input type="text" 
								id="part_barcode_4"
								name="part_barcode_4" 
								value="#part_barcode_4#" 
								class="d11a" size="6"
								onchange="part_container_label_4.className='reqdClr d11a';setPartLabel(this.id);">
						</td>
						<td>
							<input type="text" 
								id="part_container_label_4"
								name="part_container_label_4" 
								value="#part_container_label_4#" 
								class="d11a" size="10">
						</td>
						<td>
							<input type="text" 
								name="part_remark_4" 
								id="part_remark_4"
								value="#part_remark_4#" 
								class="d11a" size="40">
						</td>
					</tr>
					<tr>
						<td>
							<cfset part5 = #part_name_5#>
							<select name="part_name_5" size="1"
								id="part_name_5"
								onchange="this.className='d11a reqdClr';
									part_condition_5.className='d11a reqdClr';
									part_lot_count_5.className='d11a reqdClr';
									part_disposition_5.className='d11a reqdClr';"
								class="d11a">
									<option value=""></option>
									<cfloop query="ctPartName">
										<option <cfif #part5# is #ctPartName.part_name#> selected </cfif>
											value="#part_name#">#part_name#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<cfset partmod5 = #part_modifier_5#>
							<select name="part_modifier_5" 
								size="1"
								id="part_modifier_5"
								class="d11a"
						onFocus="self.status='First Part Modifier'">
								<option value=""></option>
								<cfloop query="ctPartModifier">
									<option <cfif #partmod5# is #part_modifier#> selected </cfif>
									value="#part_modifier#">#part_modifier#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<cfset presmeth5 = #preserv_method_5#>
							<select name="preserv_method_5" size="1"
								id="preserv_method_5"
								class="d11a"
								onFocus="self.status='First Part Preservation Method'">
									<option value=""></option>
									<cfloop query="ctPresMeth">
										<option <cfif #presmeth5# is #preserve_method#> selected </cfif>
										value="#ctPresMeth.preserve_method#">#ctPresMeth.preserve_method#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<input type="text" name="part_condition_5"
								id="part_condition_5"
								onFocus="self.status='First Part Condition'"
								value="#part_condition_5#"
								class="d11a">
						</td>
						<td>
							<cfset thisDisp = #part_disposition_5#>
							<select name="part_disposition_5"
								id="part_disposition_5"
								size="1" 
								class="d11a">
								<cfloop query="CTCOLL_OBJ_DISP">
									<option
										<cfif #thisDisp# is #COLL_OBJ_DISPOSITION#> selected </cfif>
									 value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" 
								id="part_lot_count_5"
								name="part_lot_count_5" 
								value="#part_lot_count_5#" 
								class="d11a" size="1">
						</td>
						<td>
							<input type="text" 
								id="part_barcode_5"
								name="part_barcode_5" 
								value="#part_barcode_5#" 
								class="d11a" size="6"
								onchange="part_container_label_5.className='reqdClr d11a';setPartLabel(this.id);">
						</td>
						<td>
							<input type="text" 
								id="part_container_label_5"
								name="part_container_label_5" 
								value="#part_container_label_5#" 
								class="d11a" size="10">
						</td>
						<td>
							<input type="text" 
								name="part_remark_5" 
								id="part_remark_5"
								value="#part_remark_5#" 
								class="d11a" size="40">
						</td>
					</tr>
					<tr>
						<td>
							<cfset part6 = #part_name_6#>
							<select name="part_name_6" size="1"
								id="part_name_6"
								class="d11a" 
								onchange="this.className='d11a reqdClr';
									part_condition_6.className='d11a reqdClr';
									part_lot_count_6.className='d11a reqdClr';
									part_disposition_6.className='d11a reqdClr';">
									<option value=""></option>
									<cfloop query="ctPartName">
										<option <cfif #part6# is #ctPartName.part_name#> selected </cfif>
											value="#part_name#">#part_name#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<cfset partmod6 = #part_modifier_6#>
							<select name="part_modifier_6" 
								size="1"
								id="part_modifier_6"
								class="d11a"
						onFocus="self.status='First Part Modifier'">
								<option value=""></option>
								<cfloop query="ctPartModifier">
									<option <cfif #partmod6# is #part_modifier#> selected </cfif>
									value="#part_modifier#">#part_modifier#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<cfset presmeth6 = #preserv_method_6#>
							<select name="preserv_method_6" size="1"
								id="preserv_method_6"
								class="d11a"
								onFocus="self.status='First Part Preservation Method'">
									<option value=""></option>
									<cfloop query="ctPresMeth">
										<option <cfif #presmeth6# is #preserve_method#> selected </cfif>
										value="#ctPresMeth.preserve_method#">#ctPresMeth.preserve_method#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<input type="text" name="part_condition_6"
								id="part_condition_6"
								value="#part_condition_6#"
								class="d11a">
						</td>
						<td>
							<cfset thisDisp = #part_disposition_6#>
							<select name="part_disposition_6"
								id="part_disposition_6"
								size="1" 
								class="d11a">
								<cfloop query="CTCOLL_OBJ_DISP">
									<option
										<cfif #thisDisp# is #COLL_OBJ_DISPOSITION#> selected </cfif>
									 value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" 
								name="part_lot_count_6"
								id="part_lot_count_6" 
								value="#part_lot_count_6#" 
								class="d11a" size="1">
						</td>
						<td>
							<input type="text" 
								name="part_barcode_6" 
								id="part_barcode_6"
								value="#part_barcode_6#" 
								class="d11a" size="6"
								onchange="part_container_label_6.className='reqdClr d11a';setPartLabel(this.id);">
						</td>
						<td>
							<input type="text" 
								name="part_container_label_6"
								id="part_container_label_6" 
								value="#part_container_label_6#" 
								class="d11a" size="10">
						</td>
						<td>
							<input type="text" 
								name="part_remark_6" 
								id="part_remark_6"
								value="#part_remark_6#" 
								class="d11a" size="40">
						</td>
					</tr>
					<tr>
						<td>
							<cfset part7 = #part_name_7#>
							<select name="part_name_7" size="1"
								id="part_name_7"
								class="d11a"
								onchange="this.className='d11a reqdClr';
									part_condition_7.className='d11a reqdClr';
									part_lot_count_7.className='d11a reqdClr';
									part_disposition_7.className='d11a reqdClr';">
									<option value=""></option>
									<cfloop query="ctPartName">
										<option <cfif #part7# is #ctPartName.part_name#> selected </cfif>
											value="#part_name#">#part_name#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<cfset partmod7 = #part_modifier_7#>
							<select name="part_modifier_7" 
								size="1"
								id="part_modifier_7"
								class="d11a">
								<option value=""></option>
								<cfloop query="ctPartModifier">
									<option <cfif #partmod7# is #part_modifier#> selected </cfif>
									value="#part_modifier#">#part_modifier#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<cfset presmeth7 = #preserv_method_7#>
							<select name="preserv_method_7" size="1"
								id="preserv_method_7"
								class="d11a">
									<option value=""></option>
									<cfloop query="ctPresMeth">
										<option <cfif #presmeth7# is #preserve_method#> selected </cfif>
										value="#ctPresMeth.preserve_method#">#ctPresMeth.preserve_method#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<input type="text" name="part_condition_7"
								id="part_condition_7"
								value="#part_condition_7#"
								class="d11a">
						</td>
						<td>
							<cfset thisDisp = #part_disposition_7#>
							<select name="part_disposition_7"
								id="part_disposition_7"
								size="1" 
								class="d11a">
								<cfloop query="CTCOLL_OBJ_DISP">
									<option
										<cfif #thisDisp# is #COLL_OBJ_DISPOSITION#> selected </cfif>
									 value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" 
								id="part_lot_count_7"
								name="part_lot_count_7" 
								value="#part_lot_count_7#" 
								class="d11a" size="1">
						</td>
						<td>
							<input type="text" 
								id="part_barcode_7"
								name="part_barcode_7" 
								value="#part_barcode_7#" 
								class="d11a" size="6"
								onchange="part_container_label_7.className='reqdClr d11a';setPartLabel(this.id);">
						</td>
						<td>
							<input type="text" 
								id="part_container_label_7"
								name="part_container_label_7" 
								value="#part_container_label_7#" 
								class="d11a" size="10">
						</td>
						<td>
							<input type="text" 
								name="part_remark_7" 
								id="part_remark_7"
								value="#part_remark_7#" 
								class="d11a" size="40">
						</td>
					</tr>
					<tr>
						<td>
							<cfset part8 = #part_name_8#>
							<select name="part_name_8" size="1"
								id="part_name_8"
								class="d11a"
								onchange="this.className='d11a reqdClr';
									part_condition_8.className='d11a reqdClr';
									part_lot_count_8.className='d11a reqdClr';
									part_disposition_8.className='d11a reqdClr';">
									<option value=""></option>
									<cfloop query="ctPartName">
										<option <cfif #part8# is #ctPartName.part_name#> selected </cfif>
											value="#part_name#">#part_name#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<cfset partmod8 = #part_modifier_8#>
							<select name="part_modifier_8" 
								size="1"
								id="part_modifier_8"
								class="d11a">
								<option value=""></option>
								<cfloop query="ctPartModifier">
									<option <cfif #partmod8# is #part_modifier#> selected </cfif>
									value="#part_modifier#">#part_modifier#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<cfset presmeth8 = #preserv_method_8#>
							<select name="preserv_method_8" size="1"
								id="preserv_method_8"
								class="d11a">
									<option value=""></option>
									<cfloop query="ctPresMeth">
										<option <cfif #presmeth8# is #preserve_method#> selected </cfif>
										value="#ctPresMeth.preserve_method#">#ctPresMeth.preserve_method#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<input type="text" name="part_condition_8"
								id="part_condition_8"
								onFocus="self.status='First Part Condition'"
								value="#part_condition_8#"
								class="d11a">
						</td>
						<td>
							<cfset thisDisp = #part_disposition_8#>
							<select name="part_disposition_8"
								id="part_disposition_8"
								size="1" 
								class="d11a">
								<cfloop query="CTCOLL_OBJ_DISP">
									<option
										<cfif #thisDisp# is #COLL_OBJ_DISPOSITION#> selected </cfif>
									 value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" 
								id="part_lot_count_8"
								name="part_lot_count_8" 
								value="#part_lot_count_8#" 
								class="d11a" size="1">
						</td>
						<td>
							<input type="text" 
								id="part_barcode_8"
								name="part_barcode_8" 
								value="#part_barcode_8#" 
								class="d11a" size="6"
								onchange="part_container_label_8.className='reqdClr d11a';setPartLabel(this.id);">
						</td>
						<td>
							<input type="text" 
								id="part_container_label_8"
								name="part_container_label_8" 
								value="#part_container_label_8#" 
								class="d11a" size="10">
						</td>
						<td>
							<input type="text" 
								name="part_remark_8" 
								id="part_remark_8"
								value="#part_remark_8#" 
								class="d11a" size="40">
						</td>
					</tr>
					<tr>
						<td>
							<cfset part9 = #part_name_9#>
							<select name="part_name_9" size="1"
								id="part_name_9"
								class="d11a"
								onchange="this.className='d11a reqdClr';
									part_condition_9.className='d11a reqdClr';
									part_lot_count_9.className='d11a reqdClr';
									part_disposition_9.className='d11a reqdClr';">
									<option value=""></option>
									<cfloop query="ctPartName">
										<option <cfif #part9# is #ctPartName.part_name#> selected </cfif>
											value="#part_name#">#part_name#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<cfset partmod9 = #part_modifier_9#>
							<select name="part_modifier_9" 
								size="1"
								id="part_modifier_9"
								class="d11a">
								<option value=""></option>
								<cfloop query="ctPartModifier">
									<option <cfif #partmod9# is #part_modifier#> selected </cfif>
									value="#part_modifier#">#part_modifier#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<cfset presmeth9 = #preserv_method_9#>
							<select name="preserv_method_9" size="1"
								id="preserv_method_9"
								class="d11a">
									<option value=""></option>
									<cfloop query="ctPresMeth">
										<option <cfif #presmeth9# is #preserve_method#> selected </cfif>
										value="#ctPresMeth.preserve_method#">#ctPresMeth.preserve_method#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<input type="text" name="part_condition_9"
								id="part_condition_9"
								onFocus="self.status='First Part Condition'"
								value="#part_condition_9#"
								class="d11a">
						</td>
						<td>
							<cfset thisDisp = #part_disposition_9#>
							<select name="part_disposition_9"
								id="part_disposition_9"
								size="1" 
								class="d11a">
								<cfloop query="CTCOLL_OBJ_DISP">
									<option
										<cfif #thisDisp# is #COLL_OBJ_DISPOSITION#> selected </cfif>
									 value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" 
								id="part_lot_count_9"
								name="part_lot_count_9" 
								value="#part_lot_count_9#" 
								class="d11a" size="1">
						</td>
						<td>
							<input type="text" 
								id="part_barcode_9"
								name="part_barcode_9" 
								value="#part_barcode_9#" 
								class="d11a" size="6"
								onchange="part_container_label_9.className='reqdClr d11a';setPartLabel(this.id);">
						</td>
						<td>
							<input type="text" 
								id="part_container_label_9"
								name="part_container_label_9" 
								value="#part_container_label_9#" 
								class="d11a" size="10">
						</td>
						<td>
							<input type="text" 
								name="part_remark_9" 
								id="part_remark_9"
								value="#part_remark_9#" 
								class="d11a" size="40">
						</td>
					</tr>
					<tr>
						<td>
							<cfset part10 = #part_name_10#>
							<select name="part_name_10" size="1"
								id="part_name_10"
								class="d11a"
								onchange="this.className='d11a reqdClr';
									part_condition_10.className='d11a reqdClr';
									part_lot_count_10.className='d11a reqdClr';
									part_disposition_10.className='d11a reqdClr';">
									<option value=""></option>
									<cfloop query="ctPartName">
										<option <cfif #part10# is #ctPartName.part_name#> selected </cfif>
											value="#part_name#">#part_name#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<cfset partmod10 = #part_modifier_10#>
							<select name="part_modifier_10" 
								size="1"
								id="part_modifier_10"
								class="d11a">
								<option value=""></option>
								<cfloop query="ctPartModifier">
									<option <cfif #partmod10# is #part_modifier#> selected </cfif>
									value="#part_modifier#">#part_modifier#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<cfset presmeth10 = #preserv_method_10#>
							<select name="preserv_method_10" size="1"
								id="preserv_method_10"
								class="d11a">
									<option value=""></option>
									<cfloop query="ctPresMeth">
										<option <cfif #presmeth10# is #preserve_method#> selected </cfif>
										value="#ctPresMeth.preserve_method#">#ctPresMeth.preserve_method#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<input type="text" name="part_condition_10"
								id="part_condition_10"
								value="#part_condition_10#"
								class="d11a">
						</td>
						<td>
							<cfset thisDisp = #part_disposition_10#>
							<select name="part_disposition_10"
								id="part_disposition_10"
								size="1" 
								class="d11a">
								<cfloop query="CTCOLL_OBJ_DISP">
									<option
										<cfif #thisDisp# is #COLL_OBJ_DISPOSITION#> selected </cfif>
									 value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" 
								id="part_lot_count_10"
								name="part_lot_count_10" 
								value="#part_lot_count_10#" 
								class="d11a" size="1">
						</td>
						<td>
							<input type="text" 
								name="part_barcode_10" 
								id="part_barcode_10"
								value="#part_barcode_10#" 
								class="d11a" size="6"
								onchange="part_container_label_10.className='reqdClr d11a';setPartLabel(this.id);">
						</td>
						<td>
							<input type="text" 
								id="part_container_label_10"
								name="part_container_label_10" 
								value="#part_container_label_10#" 
								class="d11a" size="10">
						</td>
						<td>
							<input type="text" 
								name="part_remark_10" 
								id="part_remark_10"
								value="#part_remark_10#" 
								class="d11a" size="40">
						</td>
					</tr>
					<tr>
						<td>
							<cfset part11 = #part_name_11#>
							<select name="part_name_11" size="1"
								id="part_name_11"
								class="d11a"
								onchange="this.className='d11a reqdClr';
									part_condition_11.className='d11a reqdClr';
									part_lot_count_11.className='d11a reqdClr';
									part_disposition_11.className='d11a reqdClr';">
									<option value=""></option>
									<cfloop query="ctPartName">
										<option <cfif #part11# is #ctPartName.part_name#> selected </cfif>
											value="#part_name#">#part_name#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<cfset partmod11 = #part_modifier_11#>
							<select name="part_modifier_11" 
								size="1"
								id="part_modifier_11"
								class="d11a">
								<option value=""></option>
								<cfloop query="ctPartModifier">
									<option <cfif #partmod11# is #part_modifier#> selected </cfif>
									value="#part_modifier#">#part_modifier#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<cfset presmeth11 = #preserv_method_11#>
							<select name="preserv_method_11" size="1"
								id="preserv_method_11"
								class="d11a">
									<option value=""></option>
									<cfloop query="ctPresMeth">
										<option <cfif #presmeth11# is #preserve_method#> selected </cfif>
										value="#ctPresMeth.preserve_method#">#ctPresMeth.preserve_method#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<input type="text" name="part_condition_11"
								id="part_condition_11"
								value="#part_condition_11#"
								class="d11a">
						</td>
						<td>
							<cfset thisDisp = #part_disposition_11#>
							<select name="part_disposition_11"
								id="part_disposition_11"
								size="1" 
								class="d11a">
								<cfloop query="CTCOLL_OBJ_DISP">
									<option
										<cfif #thisDisp# is #COLL_OBJ_DISPOSITION#> selected </cfif>
									 value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" 
								id="part_lot_count_11"
								name="part_lot_count_11" 
								value="#part_lot_count_11#" 
								class="d11a" size="1">
						</td>
						<td>
							<input type="text" 
								id="part_barcode_11"
								name="part_barcode_11" 
								value="#part_barcode_11#" 
								class="d11a" size="6"
								onchange="part_container_label_11.className='reqdClr d11a';setPartLabel(this.id);">
						</td>
						<td>
							<input type="text" 
								id="part_container_label_11"
								name="part_container_label_11" 
								value="#part_container_label_11#" 
								class="d11a" size="10">
						</td>
						<td>
							<input type="text" 
								name="part_remark_11" 
								id="part_remark_11"
								value="#part_remark_11#" 
								class="d11a" size="40">
						</td>
					</tr>
					<tr>
						<td>
							<cfset part12 = #part_name_12#>
							<select name="part_name_12" size="1"
								id="part_name_12"
								class="d11a"
								onchange="this.className='d11a reqdClr';
									part_condition_12.className='d11a reqdClr';
									part_lot_count_12.className='d11a reqdClr';
									part_disposition_12.className='d11a reqdClr';">
									<option value=""></option>
									<cfloop query="ctPartName">
										<option <cfif #part12# is #ctPartName.part_name#> selected </cfif>
											value="#part_name#">#part_name#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<cfset partmod12 = #part_modifier_12#>
							<select name="part_modifier_12" 
								size="1"
								id="part_modifier_12"
								class="d11a">
								<option value=""></option>
								<cfloop query="ctPartModifier">
									<option <cfif #partmod12# is #part_modifier#> selected </cfif>
									value="#part_modifier#">#part_modifier#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<cfset presmeth12 = #preserv_method_12#>
							<select name="preserv_method_12" size="1"
								id="preserv_method_12"
								class="d11a">
									<option value=""></option>
									<cfloop query="ctPresMeth">
										<option <cfif #presmeth12# is #preserve_method#> selected </cfif>
										value="#ctPresMeth.preserve_method#">#ctPresMeth.preserve_method#</option>
									</cfloop>
								</select>
						</td>
						<td>
							<input type="text" name="part_condition_12"
								id="part_condition_12"
								value="#part_condition_12#"
								class="d11a">
						</td>
						<td>
							<cfset thisDisp = #part_disposition_12#>
							<select name="part_disposition_12"
								id="part_disposition_12"
								size="1" 
								class="d11a">
								<cfloop query="CTCOLL_OBJ_DISP">
									<option
										<cfif #thisDisp# is #COLL_OBJ_DISPOSITION#> selected </cfif>
									 value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" 
								id="part_lot_count_12"
								name="part_lot_count_12" 
								value="#part_lot_count_12#" 
								class="d11a" size="1">
						</td>
						<td>
							<input type="text" 
								id="part_barcode_12"
								name="part_barcode_12" 
								value="#part_barcode_12#" 
								class="d11a" size="6"
								onchange="part_container_label_12.className='reqdClr d11a';setPartLabel(this.id);">
						</td>
						<td>
							<input type="text" 
								id="part_container_label_12"
								name="part_container_label_12" 
								value="#part_container_label_12#" 
								class="d11a" size="10">
						</td>
						<td>
							<input type="text" 
								name="part_remark_12" 
								id="part_remark_12"
								value="#part_remark_12#" 
								class="d11a" size="40">
						</td>
					</tr>
				</table>
	
	</td><!--- end parts block --->
</tr>
<tr>
	<td colspan="2">
		<table cellpadding="0" cellspacing="0" width="100%" style="background-color:##339999">
			<tr>
				<td width="16%">
					<span id="theNewButton" style="display:none;">
					<input type="button" value="Save This Entry As A New Record" class="insBtn"
					   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'"
					  onclick="saveNewRecord();"/>
					 </span>
				</td>
				<td width="16%">
					<span id="enterMode" style="display:none">
						<input type="button" 
							value="Enter Edit Mode" 
							class="lnkBtn"
							onmouseover="this.className='lnkBtn btnhov'" 
							onmouseout="this.className='lnkBtn'" 
							onclick="click_changeMode('edit','#collection_object_id#')">			
					</span>
					<span id="editMode" style="display:none">
						<cfif len(#loadedMsg#) is 0>
						<input type="button" 
								value="Clone This Record" 
								class="lnkBtn"
								onmouseover="this.className='lnkBtn btnhov'" 
								onmouseout="this.className='lnkBtn'" 
								onclick="click_changeMode('enter')">	
						</cfif>
					</span>
				</td>
				
				<td width="16%" nowrap="nowrap">
					 <span id="theSaveButton" style="display:none;">
						<input type="button" value="Save Edits" class="savBtn"
						   	onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'"
							onclick="saveEditedRecord();" />
						<input type="button" value="Delete Record" class="delBtn"
						   	onmouseover="this.className='delBtn btnhov'" onmouseout="this.className='delBtn'"
							onclick="deleteThisRec();" />
					</span>
				</td>
				<td width="16%">	
					<cfif #institution_acronym# is "MSB" and #collection_cde# is "Bird" and #pMode# is "enter">
						<span id="clearDefault">
						<input type="button" value="Clear All" class="delBtn"
								onmouseover="this.className='delBtn btnhov'" onmouseout="this.className='delBtn'"
								onclick="clearAll();" />
						</span>
						<script>
							// good a place as any to get the next catnum
							catNumSeq();
						</script>
					<cfelse>
						<span id="clearDefault">
						<input type="button" value="Clear Defaults" class="delBtn"
								onmouseover="this.className='delBtn btnhov'" onmouseout="this.className='delBtn'"
								onclick="setNewRecDefaults();" />
						</span>
					</cfif>
				</td>
				<td width="16%">	
					<input type="button" value="Table View" class="lnkBtn"
						   	onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
							onclick="window.open('userBrowseBulkedGrid.cfm','_browseDE');" />
				</td>
				<td align="right" width="16%" nowrap="nowrap">
					<span id="browseThingy">
					<cfif currentPos gt 1>
					<cfset prevCollObjId = listgetat(idList,currentPos - 1)>
					<cfif #imAGod# is "yes">
						<cfset theLink = "DataEntry.cfm?action=editEnterData&pMode=edit&collection_object_id=#prevCollObjId#&imagod=yes">
					<cfelse>
						<cfset theLink = "DataEntry.cfm?action=editEnterData&pMode=edit&collection_object_id=#prevCollObjId#">
					</cfif>
					<a href="#theLink#">
						<img src="/images/previous.gif" class="likeLink" border="0" alt="[ back ]"/></a>
					<cfelse>
							<img src="/images/no_previous.gif" border="0" alt="[ null ]" />
					</cfif>
					<cfset recposn = 1>
					Record 
					<cfif #imAGod# is "yes">
						<cfset theLink = "DataEntry.cfm?action=editEnterData&pMode=edit&imagod=yes&collection_object_id=">
					<cfelse>
						<cfset theLink = "DataEntry.cfm?action=editEnterData&pMode=edit&collection_object_id=">
					</cfif>
					<select name="browseRecs" size="1" id="selectbrowse"
						onchange="document.location='#theLink#' + this.value;">
					<cfloop query="whatIds">
						<option 
							<cfif #recposn# is #currentPos#> selected </cfif>
							value="#collection_object_id#">#recposn#</option>
						<cfset idList = "#idList#,">
						<cfset recposn = #recposn# + 1>
					</cfloop>
					</select>
					of #whatIds.recordcount#
					
					<cfif currentPos is listlen(idList)>
						<img src="/images/no_next.gif" border="0" alt="[ null ]" />
					<cfelse>
						<cfset nextCollObjId = listgetat(idList,currentPos + 1)>
						<cfif #imAGod# is "yes">
							<cfset theLink = "DataEntry.cfm?action=editEnterData&pMode=edit&collection_object_id=#nextCollObjId#&imagod=yes">
						<cfelse>
							<cfset theLink = "DataEntry.cfm?action=editEnterData&pMode=edit&collection_object_id=#nextCollObjId#">
						</cfif>
						<a href="#theLink#">
						<img src="/images/next.gif" class="likeLink"  border="0"/ alt="[ next ]"></a>
					</cfif>		
					</span>									
				</td>
				
			</tr>
		</table>
   </td>
</tr>
</table>
</form>
<!--- do not allow change to new entry mode if there's a problem --->
<!--- crude but effective: set up an invisible DIV here to hold loadedMsg. 
		After we've switched bgcolor based on mode, switch it again 
		based on the contents of the DIV --->
	<div style="display:none;" id="loadedMsgDiv">
		#loadedMsg#
	</div>
<cfif len(#loadedMsg#) gt 0>
	<cfset pMode = 'edit'>
</cfif>
<cfset loadedMsg = replace(loadedMsg,"'","`","all")>
<script language="javascript" type="text/javascript">
	switchActive('#orig_lat_long_units#');
	// loadedMsg, with ::field_name:: format, can be used to highlight goofy stuff
	highlightErrors('#trim(loadedMsg)#');
	// SEE WHAT mod ewe're in
	changeMode('#pMode#');
	pickedLocality();
</script>
<!---
<cfif #thisEntryGroup# is "UAM" and #pMode# is "enter">
	<script>
		catNumGap();
	</script>
</cfif>
--->
<!--- after all else is loaded, see if we're carrying an ID over --->
<cfif isdefined("session.rememberLastOtherId") and #session.rememberLastOtherId# is 1 and #pMode# is "enter">
	<cfset cVal="">
	<cfif isnumeric(#other_id_num_5#)>
		<cfset cVal = #other_id_num_5# + 1>
	<cfelseif isnumeric(right(other_id_num_5,len(other_id_num_5)-1))>
		<cfset temp = (right(other_id_num_5,len(other_id_num_5)-1)) + 1>
		<cfset cVal = left(other_id_num_5,1) & temp>
	</cfif>
	<script>
		//alert('carry');
		var cid = document.getElementById('other_id_num_5').value='#cVal#';
	</script>
</cfif>
</cfoutput>
</cfif>

<!---------------------------------------------------------------------------->
<cfif #action# is "deleteThisRec">
	<cfoutput>
	<cftransaction>
	<cfquery name="kill" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from bulkloader where collection_object_id = #collection_object_id#
	</cfquery>
	</cftransaction>
	<cfquery name="next" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select max(collection_object_id) as collection_object_id from bulkloader 
		where enteredby = '#session.username#'
	</cfquery>
	<cfif #len(next.collection_object_id)# is 0>
		<cflocation url="DataEntry.cfm">
	</cfif>
	
	<cfif #imAGod# is "yes">
		<cfset theLink = "DataEntry.cfm?action=editEnterData&pMode=edit&collection_object_id=#next.collection_object_id#&imagod=yes">
	<cfelse>
		<cfset theLink = "DataEntry.cfm?action=editEnterData&pMode=edit&collection_object_id=#next.collection_object_id#">
	</cfif>
	<cflocation url="#theLink#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------->
<cfif #action# is "saveEditRecord">

	<cfoutput>
	<cfquery name="getCols" datasource="uam_god">
		select column_name from sys.user_tab_cols
		where table_name='BULKLOADER'
		order by internal_column_id
	</cfquery>
	<!--- do this dynamically, everything is varchar --->
	<cfset sql = "UPDATE bulkloader SET ">
	<cfloop query="getCols">
		<cfif isDefined("Form.#column_name#")>
				<cfset thisData = evaluate("form." & column_name)>
				<cfset thisData = replace(thisData,"'","''","all")>
				<cfset sql = "#SQL#,#COLUMN_NAME# = '#thisData#'">
		</cfif>
	</cfloop>
	<cfset sql = "#SQL# where collection_object_id = #collection_object_id#">
	<!--- KILL THE first comma in sql --->
	<cfset sql = replace(sql,"UPDATE bulkloader SET ,","UPDATE bulkloader SET ")>
	<cfquery name="new" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfif #imAGod# is "yes">
		<cfset theLink = "DataEntry.cfm?action=editEnterData&pMode=edit&collection_object_id=#collection_object_id#&imagod=yes">
	<cfelse>
		<cfset theLink = "DataEntry.cfm?action=editEnterData&pMode=edit&collection_object_id=#collection_object_id#">
	</cfif>
	<cflocation url="#theLink#">
	</cfoutput>
	
</cfif>
<!-------------------------------------------------------------------------------------------->
<cfif #action# is "saveEntry">

	<cfoutput>
	<!--- saving a new record --->
	<cfquery name="getCols" datasource="uam_god">
		select column_name from sys.user_tab_cols
		where table_name='BULKLOADER'
		order by internal_column_id
	</cfquery>
	<!--- do this dynamically, everything is varchar --->
	<cfset sql = "INSERT INTO bulkloader (">
	<cfset flds = "">
	<cfset data = "">
	<cfloop query="getCols">
		<cfif isDefined("Form.#column_name#")>
			<cfif #column_name# is not "collection_object_id">
				<cfset flds = "#flds#,#column_name#">
				<cfset thisData = evaluate("form." & column_name)>
				<cfset thisData = replace(thisData,"'","''","all")>
				<cfset data = "#data#,'#thisData#'">
			</cfif>
		</cfif>
	</cfloop>
	<!--- flds and data will start with a comma - remove it --->
	<cfset flds = trim(flds)>
	<cfset flds=right(flds,len(flds)-1)>
	<cfset data = trim(data)>
	<cfset data=right(data,len(data)-1)>
	<!--- tack on collectin object ID handling for new records --->
	<cfset flds = "collection_object_id,#flds#">
	<cfset data = "bulkloader_PKEY.nextval,#data#">
	<cfset sql = "insert into bulkloader (#flds#) values (#data#)">	
	<cfquery name="new" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfquery name="tVal" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select bulkloader_PKEY.currval as currval from dual
	</cfquery>
	<cfif #imAGod# is "yes">
		<cfset theLink = "DataEntry.cfm?action=editEnterData&collection_object_id=#tVal.currval#&imagod=yes">
	<cfelse>
		<cfset theLink = "DataEntry.cfm?action=editEnterData&collection_object_id=#tVal.currval#">
	</cfif>
	<cflocation url="#theLink#">
	<cflocation url="">
</cfoutput>
</cfif>
<DIV ID="theCalendar" STYLE="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></DIV>
<cfinclude template="/includes/_footer.cfm">