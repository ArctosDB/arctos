<cfinclude template="/includes/_pickHeader.cfm">
<script type="text/javascript" src="includes/wz_dragdrop.js"></script>
<script type='text/javascript' src='/ajax/core/engine.js'></script>
	<script type='text/javascript' src='/ajax/core/util.js'></script>
	<script type='text/javascript' src='/ajax/core/settings.js'></script>
	
	<cfinclude template="/ajax/core/cfajax.cfm">
<style>
	.changed {
		background-color:#FF0000;
		font-size:14px;
	}
	.unchanged {
		border-style:none;	
		font-size:14px;
	}
	#headerArea { width: 100%; position: fixed; z-index: 1000; top: 0; background-color:#6600FF;}
#contentArea { margin-top: 163px; margin-bottom: 50px; }
* html #contentArea { margin-top: 0; }
#faderBottom { width: 100%; background: url(/assets/template.graphics/fader_bottom.png) repeat-x; position: fixed; z-index: 1000; height: 50px; bottom: 0px; }
#faderTop { width: 100%; background: url(/assets/template.graphics/fader_top.png) repeat-x; position: fixed; z-index: 1000; height: 50px; top: 123px; }
* html #faderBottom, * html #faderTop { display: none; }
</style>
<script>
function updateData (theName, theValue) {
	//alert('going with name=' + theName + ' and value ' + theValue);
	DWREngine._execute(_cfscriptLocation, null, 'bulkEditUpdate',theName, theValue, successUpdateData);
}
function successUpdateData (result) {
	// will return QUERY FAILED if the cfcatch block got anything, 
	// otherwise will return field name = ID
	if (result == 'QUERY FAILED') {
		alert('There was a problem. Your changes have not been saved!');
	} else {
		// successful save
		//alert(result);
		var theElement = document.getElementById(result);
		theElement.className = 'unchanged';
	} 
	
}
</script>

<br />This form updates the Bulkloader. Records that have been successfully loaded do not appear in this form. Saves are instant and do not require any action, other than leaving the field, on your part. Fields should briefly turn red (unsaved state) and back to default (saved state) when you update something.<br />
<br /><font color="#FF0000">Allow the form to completely load before you make changes. This will take a long time and use a lot of memory!</font>
 <cfquery name="CTATTRIBUTE_TYPE" datasource="#Application.web_user#">
	select distinct(ATTRIBUTE_TYPE) as ATTRIBUTE_TYPE from CTATTRIBUTE_TYPE
</cfquery>
  
<cfquery name="CTVERIFICATIONSTATUS" datasource="#Application.web_user#">
	select VERIFICATIONSTATUS from CTVERIFICATIONSTATUS
</cfquery>
<cfquery name="CTGEOREFMETHOD" datasource="#Application.web_user#">
	select GEOREFMETHOD from CTGEOREFMETHOD
</cfquery> 
  
<cfquery name="CTCOLLECTING_METHOD" datasource="#Application.web_user#">
	select COLLECTING_METHOD from CTCOLLECTING_METHOD
</cfquery> 
<cfquery name="CTFLAGS" datasource="#Application.web_user#">
	select FLAGS from CTFLAGS
</cfquery>    
<cfquery name="ctDEPTH_UNITS" datasource="#Application.web_user#">
	select DEPTH_UNITS from ctDEPTH_UNITS
</cfquery>   
<cfquery name="CTINSTITUTION_ACRONYM" datasource="#Application.web_user#">
	select distinct(INSTITUTION_ACRONYM) as INSTITUTION_ACRONYM from collection
</cfquery>
<cfquery name="CTSPECIMEN_PART_MODIFIER" datasource="#Application.web_user#">
	select distinct(PART_MODIFIER) as PART_MODIFIER from CTSPECIMEN_PART_MODIFIER
</cfquery>
<cfquery name="CTCOLLECTION_CDE" datasource="#Application.web_user#">
	select distinct(COLLECTION_CDE) as COLLECTION_CDE from CTCOLLECTION_CDE
</cfquery>
 
<cfquery name="CTCOLL_OBJ_DISP" datasource="#Application.web_user#">
	select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP
</cfquery>
<cfquery name="ctORIG_ELEV_UNITS" datasource="#Application.web_user#">
	select ORIG_ELEV_UNITS from ctORIG_ELEV_UNITS
</cfquery>
<cfquery name="ctNATURE_OF_ID" datasource="#Application.web_user#">
	select NATURE_OF_ID from ctNATURE_OF_ID
</cfquery>
<cfquery name="CTCOLL_OTHER_ID_TYPE" datasource="#Application.web_user#">
	select distinct(OTHER_ID_TYPE) as OTHER_ID_TYPE from CTCOLL_OTHER_ID_TYPE
</cfquery>
<cfquery name="CTSPECIMEN_PART_NAME" datasource="#Application.web_user#">
	select distinct(PART_NAME) as PART_NAME from CTSPECIMEN_PART_NAME
</cfquery>
<cfquery name="CTSPECIMEN_PRESERV_METHOD" datasource="#Application.web_user#">
	select distinct(PRESERVE_METHOD) as PRESERVE_METHOD from CTSPECIMEN_PRESERV_METHOD
</cfquery>
			
<cfquery name="getCols" datasource="uam_god">
	select column_name from sys.user_tab_cols
	where table_name='BULKLOADER'
	order by internal_column_id
</cfquery>

<cfquery name="ctLAT_LONG_UNITS" datasource="#Application.web_user#">
	select ORIG_LAT_LONG_UNITS from ctLAT_LONG_UNITS
</cfquery>
 <cfquery name="ctLAT_LONG_REF_SOURCE" datasource="#Application.web_user#">
	select LAT_LONG_REF_SOURCE from ctLAT_LONG_REF_SOURCE
</cfquery>
 <cfquery name="ctLAT_LONG_UNITS" datasource="#Application.web_user#">
	select ORIG_LAT_LONG_UNITS from ctLAT_LONG_UNITS
</cfquery>
<cfquery name="CTLAT_LONG_ERROR_UNITS" datasource="#Application.web_user#">
	select LAT_LONG_ERROR_UNITS from CTLAT_LONG_ERROR_UNITS
</cfquery>


<cfquery name="data" datasource="#Application.web_user#">
	select * from bulkloader where 
	 (
		loaded <> 'Success!' OR loaded is null)
		
</cfquery>
<cfoutput>
<cfset rowNum = 1>
<form name="blData" method="post" action="editUnBulked.cfm">
	<input type="hidden" name="action" value="save" />
	<input type="hidden" name="nothing" /><!--- trashcan for picks --->

<table border cellpadding="0" cellspacing="0">
	<cfset colList = "">
	<!---
	#i# CONTAINS "PART_BARCODE_" ORPART_LOT_COUNTrereplace(i,"[0-9]+","") IS "PART_CONTAINER_LABEL_" OR
					rereplace(i,"[0-9]+","") IS "ATTRIBUTE_DATE_" OR
					rereplace(i,"[0-9]+","") IS "ATTRIBUTE_DET_METH_"
					--->
	<cfset TextLenTenFields = "began_date,ended_date,verbatim_date,minimum_elevation,maximum_elevation,determined_date,max_error_distance,dec_lat,dec_long,DEC_LAT_MIN,DEC_LONG_MIN,LATDEG,LATMIN,LATSEC,LONGDEG,LONGMIN,LONGSEC,MADE_DATE,ACCN,MIN_DEPTH,MAX_DEPTH,VESSEL,STATION_NAME,STATION_NUMBER,COLL_OBJECT_HABITAT,ASSOCIATED_SPECIES">
	<cfloop query="getCols">
		<cfif len(#colList#) is 0>
			<cfset colList = #column_name#>
		<cfelse>
			<cfset colList = "#colList##chr(9)##column_name#">
		</cfif>
	</cfloop>
	<hr>
	<cfset colList=#trim(colList)#>
	<cfset colList = "#colList##chr(10)#"><!--- add one and only one line break back onto the end --->
	
	
	<tr>
		<cfloop list="#colList#" delimiters="#chr(9)#" index="h">
			<td><span style="font-size:10px">
				<cfif #h# is "collection_object_id">ID<cfelse>#h#</cfif>
				</span>
			</td>
		</cfloop>
	</tr>

	<!---
	<cffile action="write" file="#Application.webDirectory#/Bulkloader/bulkloader.txt" addnewline="no" output="#colList#">
	--->
	<cfloop query="data">
		<tr>
		<cfquery name="thisQueryRow" dbtype="query">
			select * from data where collection_object_id = #collection_object_id#
		</cfquery>
		<cfset thisRow = "">
		<cfloop list="#colList#" index="i" delimiters="#chr(9)#">
			<cfset thisData = #evaluate("thisQueryRow." & i)#>
			<!--- replace linebreak chars in Loaded --->
			<cfif #i# is "loaded">
				<cfset thisData = #replace(thisData,chr(10),"-linebreak-","all")#>
				<cfset thisData = #replace(thisData,chr(9),"-tab-","all")#>
			</cfif>	
			<cfif len(#thisData#) is 0>
				<cfset thisData = " ">
			</cfif>
			<cfif len(#thisRow#) is 0>
				<cfset thisRow = #thisData#>
			<cfelse>
				<cfset thisRow = "#thisRow##chr(9)##thisData#">
			</cfif>
			<td align="right">
				<!--- this is the data cell. Field name is i. Naming convention is #i#__collection_object_id
					that is {field name}{double underscore}{collection_object_id}
					or		part_name_1__123
				--->
				<!--- lots of custom code here to handle strange things - more-or-less a field-by-field procedure --->
				<cfset thisName = "#i#__#collection_object_id#">
				<cfif #i# is "collection_object_id" OR
					 #i# is "enteredby">
					<input type="text" id="#thisName#" name="#thisName#" value="#thisData#" readonly="yes" size="6" /><!--- do not allow changes --->
				<cfelseif #i# is "cat_num">
					<input type="text" id="#thisName#" name="#thisName#" value="#thisData#" size="6"  class="unchanged" onchange="this.className='changed';updateData('#thisName#',this.value);" />
					<!--- short text fields --->
				<cfelseif #i# is "began_date" OR 
					#i# is "ended_date" OR
					#i# is "verbatim_date" OR
					#i# is "minimum_elevation" OR
					#i# is "maximum_elevation" OR
					#i# is "determined_date" OR
					#i# is "max_error_distance" OR
					#i# is "dec_lat" OR
					#i# is "dec_long" OR
					#i# is "DEC_LAT_MIN" OR
					#i# is "DEC_LONG_MIN" OR
					#i# is "LATDEG" OR
					#i# is "LATMIN" OR
					#i# is "LATSEC" OR
					#i# is "LONGDEG" OR
					#i# is "LONGMIN" OR
					#i# is "LONGSEC" OR
					#i# is "MADE_DATE" OR
					#i# CONTAINS "PART_BARCODE_" OR
					#i# is "ACCN" OR
					#i# is "MIN_DEPTH" OR
					#i# is "MAX_DEPTH" OR
					#i# is "VESSEL" OR
					#i# is "STATION_NAME" OR
					#i# is "STATION_NUMBER" OR
					#i# is "COLL_OBJECT_HABITAT" OR
					#i# is "ASSOCIATED_SPECIES" OR
					#i# contains "PART_LOT_COUNT" OR
					rereplace(i,"[0-9]+","") IS "PART_CONTAINER_LABEL_" OR
					rereplace(i,"[0-9]+","") IS "ATTRIBUTE_DATE_" OR
					rereplace(i,"[0-9]+","") IS "ATTRIBUTE_DET_METH_"
					>
					<input type="text" id="#thisName#" name="#thisName#" value="#thisData#" size="10" class="unchanged" onchange="this.className='changed';updateData('#thisName#',this.value)" />
					<!--- longer text fields --->
					
				<cfelseif #i# is "COLL_EVENT_REMARKS" OR
					#i# is "SPEC_LOCALITY" OR
					#i# is "LOCALITY_REMARKS" OR
					#i# is "DATUM" OR
					#i# is "LAT_LONG_REMARKS" OR
					#i# is "VERBATIM_LOCALITY" OR
					#i# is "HABITAT_DESC" OR
					#i# is "COLL_OBJ_DISPOSITION" OR
					#i# is "CONDITION" OR
					#i# is "COLL_OBJECT_REMARKS" OR
					#i# is "DISPOSITION_REMARKS" OR
					#i# is "IDENTIFICATION_REMARKS" OR
					#i# is "LOADED" OR					  
					rereplace(i,"[0-9]+","") IS "OTHER_ID_NUM_" OR
					rereplace(i,"[0-9]+","") IS "PART_CONDITION_" OR
					rereplace(i,"[0-9]+","") IS "ATTRIBUTE_VALUE_" OR
					rereplace(i,"[0-9]+","") IS "ATTRIBUTE_UNITS_" OR
					rereplace(i,"[0-9]+","") IS "ATTRIBUTE_REMARKS_"
				 >
					<input type="text" id="#thisName#" name="#thisName#" value="#thisData#" size="30" class="unchanged" onchange="this.className='changed';updateData('#thisName#',this.value);" />
				<!--- special stuff --->
				<cfelseif #i# is "HIGHER_GEOG">
					<input type="text" name="#thisName#" value="#thisData#" size="50" class="unchanged"
						onchange="getGeog('nothing','#thisName#','blData',this.value); return false;this.className='changed';updateData('#thisName#',this.value);" />
				<cfelseif #i# is "ORIG_ELEV_UNITS">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="ctORIG_ELEV_UNITS">
							<option 
								<cfif #thisData# is #ORIG_ELEV_UNITS# > selected </cfif>
								value="#ORIG_ELEV_UNITS#">#ORIG_ELEV_UNITS#</option>
						</cfloop>
					</select>
				<cfelseif #i# is "ORIG_LAT_LONG_UNITS">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="ctLAT_LONG_UNITS">
							<option 
								<cfif #thisData# is #ORIG_LAT_LONG_UNITS# > selected </cfif>
								value="#ORIG_LAT_LONG_UNITS#">#ORIG_LAT_LONG_UNITS#</option>
						</cfloop>
					</select>
				<cfelseif #i# is "LAT_LONG_REF_SOURCE">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="ctLAT_LONG_REF_SOURCE">
							<option 
								<cfif #thisData# is #LAT_LONG_REF_SOURCE# > selected </cfif>
								value="#LAT_LONG_REF_SOURCE#">#LAT_LONG_REF_SOURCE#</option>
						</cfloop>
					</select>
				<cfelseif #i# is "LAT_LONG_UNITS">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="ctLAT_LONG_UNITS">
							<option 
								<cfif #thisData# is #ORIG_LAT_LONG_UNITS# > selected </cfif>
								value="#ORIG_LAT_LONG_UNITS#">#ORIG_LAT_LONG_UNITS#</option>
						</cfloop>
					</select>
				<cfelseif #i# is "MAX_ERROR_UNITS">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="CTLAT_LONG_ERROR_UNITS">
							<option 
								<cfif #thisData# is #LAT_LONG_ERROR_UNITS# > selected </cfif>
								value="#LAT_LONG_ERROR_UNITS#">#LAT_LONG_ERROR_UNITS#</option>
						</cfloop>
					</select>
				<cfelseif #i# is "LATDIR">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
							<option 
								<cfif #thisData# is "N" > selected </cfif>
								value="N">N</option>
							<option 
								<cfif #thisData# is "S" > selected </cfif>
								value="S">S</option>
					</select>
				<cfelseif #i# is "LONGDIR">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
							<option 
								<cfif #thisData# is "E" > selected </cfif>
								value="E">E</option>
							<option 
								<cfif #thisData# is "W" > selected </cfif>
								value="W">W</option>							
					</select>
					
					
				<cfelseif rereplace(i,"[0-9]+","") IS "COLLECTOR_ROLE_">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
							<option 
								<cfif #thisData# is "C" > selected </cfif>
								value="C">C</option>
							<option 
								<cfif #thisData# is "P" > selected </cfif>
								value="P">P</option>							
					</select>
				<cfelseif rereplace(i,"[0-9]+","") IS "PART_NAME_">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="CTSPECIMEN_PART_NAME">
							<option 
								<cfif #thisData# is #PART_NAME# > selected </cfif>
								value="#PART_NAME#">#PART_NAME#</option>
						</cfloop>
					</select>
				<cfelseif rereplace(i,"[0-9]+","") IS "PART_MODIFIER_">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="CTSPECIMEN_PART_MODIFIER">
							<option 
								<cfif #thisData# is #PART_MODIFIER# > selected </cfif>
								value="#PART_MODIFIER#">#PART_MODIFIER#</option>
						</cfloop>
					</select>
				<cfelseif rereplace(i,"[0-9]+","") IS "PRESERV_METHOD_">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="CTSPECIMEN_PRESERV_METHOD">
							<option 
								<cfif #thisData# is #PRESERVE_METHOD# > selected </cfif>
								value="#PRESERVE_METHOD#">#PRESERVE_METHOD#</option>
						</cfloop>
					</select>
					 
				<cfelseif #i# is "COLL_OBJ_DISPOSITION">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="CTCOLL_OBJ_DISP">
							<option 
								<cfif #thisData# is #COLL_OBJ_DISPOSITION# > selected </cfif>
								value="#COLL_OBJ_DISPOSITION#">#COLL_OBJ_DISPOSITION#</option>
						</cfloop>
					</select>
				<cfelseif #i# is "INSTITUTION_ACRONYM">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="CTINSTITUTION_ACRONYM">
							<option 
								<cfif #thisData# is #INSTITUTION_ACRONYM# > selected </cfif>
								value="#INSTITUTION_ACRONYM#">#INSTITUTION_ACRONYM#</option>
						</cfloop>
					</select>
				<cfelseif #i# is "NATURE_OF_ID">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="ctNATURE_OF_ID">
							<option 
								<cfif #thisData# is #NATURE_OF_ID# > selected </cfif>
								value="#NATURE_OF_ID#">#NATURE_OF_ID#</option>
						</cfloop>
					</select>
				<cfelseif #i# is "COLLECTION_CDE">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="CTCOLLECTION_CDE">
							<option 
								<cfif #thisData# is #COLLECTION_CDE# > selected </cfif>
								value="#COLLECTION_CDE#">#COLLECTION_CDE#</option>
						</cfloop>
					</select>
				<cfelseif #i# is "FLAGS">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="CTFLAGS">
							<option 
								<cfif #thisData# is #FLAGS# > selected </cfif>
								value="#FLAGS#">#FLAGS#</option>
						</cfloop>
					</select>
				<cfelseif #i# is "GEOREFMETHOD">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="CTGEOREFMETHOD">
							<option 
								<cfif #thisData# is #GEOREFMETHOD# > selected </cfif>
								value="#GEOREFMETHOD#">#GEOREFMETHOD#</option>
						</cfloop>
					</select>
				<cfelseif #i# is "COLLECTING_METHOD">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="CTCOLLECTING_METHOD">
							<option 
								<cfif #thisData# is #COLLECTING_METHOD# > selected </cfif>
								value="#COLLECTING_METHOD#">#COLLECTING_METHOD#</option>
						</cfloop>
					</select>
				<cfelseif #i# is "VERIFICATIONSTATUS">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="CTVERIFICATIONSTATUS">
							<option 
								<cfif #thisData# is #VERIFICATIONSTATUS# > selected </cfif>
								value="#VERIFICATIONSTATUS#">#VERIFICATIONSTATUS#</option>
						</cfloop>
					</select>
				<cfelseif #i# is "DEPTH_UNITS">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="ctDEPTH_UNITS">
							<option 
								<cfif #thisData# is #DEPTH_UNITS# > selected </cfif>
								value="#DEPTH_UNITS#">#DEPTH_UNITS#</option>
						</cfloop>
					</select>
				<cfelseif rereplace(i,"[0-9]+","") IS "OTHER_ID_NUM_TYPE_">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="CTCOLL_OTHER_ID_TYPE">
							<option 
								<cfif #thisData# is #OTHER_ID_TYPE# > selected </cfif>
								value="#OTHER_ID_TYPE#">#OTHER_ID_TYPE#</option>
						</cfloop>
					</select>
				<cfelseif rereplace(i,"[0-9]+","") IS "ATTRIBUTE_">
					<select name="#thisName#" 
						size="1" 
						id="#thisName#" 
						class="unchanged" 
						onchange="this.className='changed';updateData('#thisName#',this.value);">
						<option value=""></option>
						<cfloop query="CTATTRIBUTE_TYPE">
							<option 
								<cfif #thisData# is #ATTRIBUTE_TYPE# > selected </cfif>
								value="#ATTRIBUTE_TYPE#">#ATTRIBUTE_TYPE#</option>
						</cfloop>
					</select>
				<cfelseif #i# is "DETERMINED_BY_AGENT" OR
					#i# is "ID_MADE_BY_AGENT" OR
					 rereplace(i,"[0-9]+","") IS "COLLECTOR_AGENT_" OR
					 rereplace(i,"[0-9]+","") IS "ATTRIBUTE_DETERMINER_"					 
					   >
					<input type="text"
						name="#thisName#" 
						value="#thisData#" 
						class="unchanged" 
						 id="#thisName#"
						onchange="getAgent('nothing','#thisName#','blData',this.value); return false;"
						onKeyPress="return noenter(event);">
					<cfelseif #i# is "TAXON_NAME">	
						<input 
							type="text" 
							name="#thisName#" 
							value="#thisData#" 
							class="unchanged" 
							 id="#thisName#"
							onchange="taxaPick('nothing','#thisName#','blData',this.value); return false;"
							onKeyPress="return noenter(event);">
				</cfif>
			
			</td>
		</cfloop>
		<cfset thisRow=#trim(thisRow)#>
	<cfset thisRow = "#thisRow##chr(10)#">
	</tr>
	<cfset rowNum = #rowNum# + 1>
	</cfloop>
	</table>
	</form>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">