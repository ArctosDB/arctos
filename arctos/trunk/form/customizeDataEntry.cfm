<!----

create table cf_dataentry_settings (
	username varchar2(60) not null,
	numberAgents number
);

create or replace public synonym cf_dataentry_settings for cf_dataentry_settings;
grant all on cf_dataentry_settings to data_entry;

---->
<cfinclude template="/includes/alwaysInclude.cfm">


<script>
	function toggleTo(e,v){
		$("#" + e + " :input").val(v);	
	}
	function toggleAll(v){
		$("select").val(v);
	}
</script>
<style>
	.fs{
		border:1px solid green;
		margin:1em;
		padding:1em;
	}
</style>
<cfoutput>
	<cfif action is "nothing">
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
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from cf_dataentry_settings where username='#session.username#'
			</cfquery>
		</cfif>
		<cfset noHide="OTHER_ID_NUM_TYPE_1,OTHER_ID_NUM_TYPE_2,OTHER_ID_NUM_TYPE_3,OTHER_ID_NUM_TYPE_4,OTHER_ID_NUM_TYPE_5,PART_CONDITION_1,PART_BARCODE_1,PART_CONTAINER_LABEL_1,PART_LOT_COUNT_1,PART_DISPOSITION_1,PART_REMARK_1,PART_CONDITION_2,PART_BARCODE_2,PART_CONTAINER_LABEL_2,PART_LOT_COUNT_2,PART_DISPOSITION_2,PART_REMARK_2,PART_CONDITION_3,PART_BARCODE_3,PART_CONTAINER_LABEL_3,PART_LOT_COUNT_3,PART_DISPOSITION_3,PART_REMARK_3,PART_CONDITION_4,PART_BARCODE_4,PART_CONTAINER_LABEL_4,PART_LOT_COUNT_4,PART_DISPOSITION_4,PART_REMARK_4,PART_CONDITION_5,PART_BARCODE_5,PART_CONTAINER_LABEL_5,PART_LOT_COUNT_5,PART_DISPOSITION_5,PART_REMARK_5,PART_CONDITION_6,PART_BARCODE_6,PART_CONTAINER_LABEL_6,PART_LOT_COUNT_6,PART_DISPOSITION_6,PART_REMARK_6,PART_CONDITION_7,PART_BARCODE_7,PART_CONTAINER_LABEL_7,PART_LOT_COUNT_7,PART_DISPOSITION_7,PART_REMARK_7,PART_CONDITION_8,PART_BARCODE_8,PART_CONTAINER_LABEL_8,PART_LOT_COUNT_8,PART_DISPOSITION_8,PART_REMARK_8,PART_CONDITION_9,PART_BARCODE_9,PART_CONTAINER_LABEL_9,PART_LOT_COUNT_9,PART_DISPOSITION_9,PART_REMARK_9,PART_CONDITION_10,PART_BARCODE_10,PART_CONTAINER_LABEL_10,PART_LOT_COUNT_10,PART_DISPOSITION_10,PART_REMARK_10,PART_CONDITION_11,PART_BARCODE_11,PART_CONTAINER_LABEL_11,PART_LOT_COUNT_11,PART_DISPOSITION_11,PART_REMARK_11,PART_CONDITION_12,PART_BARCODE_12,PART_CONTAINER_LABEL_12,PART_LOT_COUNT_12,PART_DISPOSITION_12,PART_REMARK_12,RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE,ATTRIBUTE_VALUE_1,ATTRIBUTE_UNITS_1,ATTRIBUTE_REMARKS_1,ATTRIBUTE_DATE_1,ATTRIBUTE_DET_METH_1,ATTRIBUTE_DETERMINER_1,ATTRIBUTE_VALUE_2,ATTRIBUTE_UNITS_2,ATTRIBUTE_REMARKS_2,ATTRIBUTE_DATE_2,ATTRIBUTE_DET_METH_2,ATTRIBUTE_DETERMINER_2,ATTRIBUTE_VALUE_3,ATTRIBUTE_UNITS_3,ATTRIBUTE_REMARKS_3,ATTRIBUTE_DATE_3,ATTRIBUTE_DET_METH_3,ATTRIBUTE_DETERMINER_3,ATTRIBUTE_VALUE_4,ATTRIBUTE_UNITS_4,ATTRIBUTE_REMARKS_4,ATTRIBUTE_DATE_4,ATTRIBUTE_DET_METH_4,ATTRIBUTE_DETERMINER_4,ATTRIBUTE_VALUE_5,ATTRIBUTE_UNITS_5,ATTRIBUTE_REMARKS_5,ATTRIBUTE_DATE_5,ATTRIBUTE_DET_METH_5,ATTRIBUTE_DETERMINER_5,ATTRIBUTE_VALUE_6,ATTRIBUTE_UNITS_6,ATTRIBUTE_REMARKS_6,ATTRIBUTE_DATE_6,ATTRIBUTE_DET_METH_6,ATTRIBUTE_DETERMINER_6,ATTRIBUTE_VALUE_7,ATTRIBUTE_UNITS_7,ATTRIBUTE_REMARKS_7,ATTRIBUTE_DATE_7,ATTRIBUTE_DET_METH_7,ATTRIBUTE_DETERMINER_7,ATTRIBUTE_VALUE_8,ATTRIBUTE_UNITS_8,ATTRIBUTE_REMARKS_8,ATTRIBUTE_DATE_8,ATTRIBUTE_DET_METH_8,ATTRIBUTE_DETERMINER_8,ATTRIBUTE_VALUE_9,ATTRIBUTE_UNITS_9,ATTRIBUTE_REMARKS_9,ATTRIBUTE_DATE_9,ATTRIBUTE_DET_METH_9,ATTRIBUTE_DETERMINER_9,ATTRIBUTE_VALUE_10,ATTRIBUTE_UNITS_10,ATTRIBUTE_REMARKS_10,ATTRIBUTE_DATE_10,ATTRIBUTE_DET_METH_10,ATTRIBUTE_DETERMINER_10,GEO_ATT_VALUE_1,GEO_ATT_DETERMINER_1,GEO_ATT_DETERMINED_DATE_1,GEO_ATT_DETERMINED_METHOD_1,GEO_ATT_REMARK_1,GEO_ATT_VALUE_2,GEO_ATT_DETERMINER_2,GEO_ATT_DETERMINED_DATE_2,GEO_ATT_DETERMINED_METHOD_2,GEO_ATT_REMARK_2,GEO_ATT_VALUE_3,GEO_ATT_DETERMINER_3,GEO_ATT_DETERMINED_DATE_3,GEO_ATT_DETERMINED_METHOD_3,GEO_ATT_REMARK_3,GEO_ATT_VALUE_4,GEO_ATT_DETERMINER_4,GEO_ATT_DETERMINED_DATE_4,GEO_ATT_DETERMINED_METHOD_4,GEO_ATT_REMARK_4,GEO_ATT_VALUE_5,GEO_ATT_DETERMINER_5,GEO_ATT_DETERMINED_DATE_5,GEO_ATT_DETERMINED_METHOD_5,GEO_ATT_REMARK_5,GEO_ATT_VALUE_6,GEO_ATT_DETERMINER_6,GEO_ATT_DETERMINED_DATE_6,GEO_ATT_DETERMINED_METHOD_6,GEO_ATT_REMARK_6,DEC_LAT,DEC_LONG,LATDEG,DEC_LAT_MIN,LATMIN,LATSEC,LATDIR,LONGDEG,DEC_LONG_MIN,LONGMIN,LONGSEC,LONGDIR,DATUM,LAT_LONG_REF_SOURCE,MAX_ERROR_DISTANCE,MAX_ERROR_UNITS,GEOREFMETHOD,DETERMINED_BY_AGENT,DETERMINED_DATE,VERIFICATIONSTATUS,UTM_ZONE,UTM_EW,UTM_NS,EXTENT,GPSACCURACY,maximum_elevation,minimum_elevation,collector_agent_1,collector_role_1,ACCN,TAXON_NAME,NATURE_OF_ID,ID_MADE_BY_AGENT,VERBATIM_DATE,BEGAN_DATE,ENDED_DATE,HIGHER_GEOG,SPEC_LOCALITY,VERBATIM_LOCALITY,COLL_OBJ_DISPOSITION,CONDITION,COLLECTING_METHOD,COLLECTING_SOURCE">
			
		<cfset cat="CAT_NUM,OTHER_ID_NUM_5,OTHER_ID_NUM_TYPE_5,ACCN">
		<cfset colls="COLLECTOR_AGENT_1,COLLECTOR_ROLE_1,COLLECTOR_AGENT_2,COLLECTOR_ROLE_2,COLLECTOR_AGENT_3,COLLECTOR_ROLE_3,COLLECTOR_AGENT_4,COLLECTOR_ROLE_4,COLLECTOR_AGENT_5,COLLECTOR_ROLE_5">
		<cfset ids="OTHER_ID_NUM_1,OTHER_ID_NUM_TYPE_1,OTHER_ID_NUM_2,OTHER_ID_NUM_TYPE_2,OTHER_ID_NUM_3,OTHER_ID_NUM_TYPE_3,OTHER_ID_NUM_4,OTHER_ID_NUM_TYPE_4">
		<cfset taxa="TAXON_NAME,NATURE_OF_ID,ID_MADE_BY_AGENT,MADE_DATE,IDENTIFICATION_REMARKS">
		<cfset locality="VERBATIM_DATE,BEGAN_DATE,ENDED_DATE,HIGHER_GEOG,SPEC_LOCALITY,VERBATIM_LOCALITY,ORIG_ELEV_UNITS,MAXIMUM_ELEVATION,MINIMUM_ELEVATION,LOCALITY_REMARKS,HABITAT_DESC,COLL_EVENT_REMARKS,MIN_DEPTH,MAX_DEPTH,DEPTH_UNITS,COLLECTING_METHOD,COLLECTING_SOURCE,COLL_OBJECT_HABITAT,ASSOCIATED_SPECIES,LOCALITY_ID,COLLECTING_EVENT_ID">
		<cfset coordinates="ORIG_LAT_LONG_UNITS,DEC_LAT,DEC_LONG,LATDEG,DEC_LAT_MIN,LATMIN,LATSEC,LATDIR,LONGDEG,DEC_LONG_MIN,LONGMIN,LONGSEC,LONGDIR,DATUM,LAT_LONG_REF_SOURCE,MAX_ERROR_DISTANCE,MAX_ERROR_UNITS,GEOREFMETHOD,DETERMINED_BY_AGENT,DETERMINED_DATE,LAT_LONG_REMARKS,VERIFICATIONSTATUS,UTM_ZONE,UTM_EW,UTM_NS,EXTENT,GPSACCURACY">
		<cfset attributes="ATTRIBUTE_1,ATTRIBUTE_VALUE_1,ATTRIBUTE_UNITS_1,ATTRIBUTE_REMARKS_1,ATTRIBUTE_DATE_1,ATTRIBUTE_DET_METH_1,ATTRIBUTE_DETERMINER_1,ATTRIBUTE_2,ATTRIBUTE_VALUE_2,ATTRIBUTE_UNITS_2,ATTRIBUTE_REMARKS_2,ATTRIBUTE_DATE_2,ATTRIBUTE_DET_METH_2,ATTRIBUTE_DETERMINER_2,ATTRIBUTE_3,ATTRIBUTE_VALUE_3,ATTRIBUTE_UNITS_3,ATTRIBUTE_REMARKS_3,ATTRIBUTE_DATE_3,ATTRIBUTE_DET_METH_3,ATTRIBUTE_DETERMINER_3,ATTRIBUTE_4,ATTRIBUTE_VALUE_4,ATTRIBUTE_UNITS_4,ATTRIBUTE_REMARKS_4,ATTRIBUTE_DATE_4,ATTRIBUTE_DET_METH_4,ATTRIBUTE_DETERMINER_4,ATTRIBUTE_5,ATTRIBUTE_VALUE_5,ATTRIBUTE_UNITS_5,ATTRIBUTE_REMARKS_5,ATTRIBUTE_DATE_5,ATTRIBUTE_DET_METH_5,ATTRIBUTE_DETERMINER_5,ATTRIBUTE_6,ATTRIBUTE_VALUE_6,ATTRIBUTE_UNITS_6,ATTRIBUTE_REMARKS_6,ATTRIBUTE_DATE_6,ATTRIBUTE_DET_METH_6,ATTRIBUTE_DETERMINER_6,ATTRIBUTE_7,ATTRIBUTE_VALUE_7,ATTRIBUTE_UNITS_7,ATTRIBUTE_REMARKS_7,ATTRIBUTE_DATE_7,ATTRIBUTE_DET_METH_7,ATTRIBUTE_DETERMINER_7,ATTRIBUTE_8,ATTRIBUTE_VALUE_8,ATTRIBUTE_UNITS_8,ATTRIBUTE_REMARKS_8,ATTRIBUTE_DATE_8,ATTRIBUTE_DET_METH_8,ATTRIBUTE_DETERMINER_8,ATTRIBUTE_9,ATTRIBUTE_VALUE_9,ATTRIBUTE_UNITS_9,ATTRIBUTE_REMARKS_9,ATTRIBUTE_DATE_9,ATTRIBUTE_DET_METH_9,ATTRIBUTE_DETERMINER_9,ATTRIBUTE_10,ATTRIBUTE_VALUE_10,ATTRIBUTE_UNITS_10,ATTRIBUTE_REMARKS_10,ATTRIBUTE_DATE_10,ATTRIBUTE_DET_METH_10,ATTRIBUTE_DETERMINER_10">
		<cfset specimen="FLAGS,COLL_OBJ_DISPOSITION,CONDITION,COLL_OBJECT_REMARKS,DISPOSITION_REMARKS,RELATIONSHIP,RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE">
		<cfset parts="PART_NAME_1,PART_CONDITION_1,PART_BARCODE_1,PART_CONTAINER_LABEL_1,PART_LOT_COUNT_1,PART_DISPOSITION_1,PART_REMARK_1,PART_NAME_2,PART_CONDITION_2,PART_BARCODE_2,PART_CONTAINER_LABEL_2,PART_LOT_COUNT_2,PART_DISPOSITION_2,PART_REMARK_2,PART_NAME_3,PART_CONDITION_3,PART_BARCODE_3,PART_CONTAINER_LABEL_3,PART_LOT_COUNT_3,PART_DISPOSITION_3,PART_REMARK_3,PART_NAME_4,PART_CONDITION_4,PART_BARCODE_4,PART_CONTAINER_LABEL_4,PART_LOT_COUNT_4,PART_DISPOSITION_4,PART_REMARK_4,PART_NAME_5,PART_CONDITION_5,PART_BARCODE_5,PART_CONTAINER_LABEL_5,PART_LOT_COUNT_5,PART_DISPOSITION_5,PART_REMARK_5,PART_NAME_6,PART_CONDITION_6,PART_BARCODE_6,PART_CONTAINER_LABEL_6,PART_LOT_COUNT_6,PART_DISPOSITION_6,PART_REMARK_6,PART_NAME_7,PART_CONDITION_7,PART_BARCODE_7,PART_CONTAINER_LABEL_7,PART_LOT_COUNT_7,PART_DISPOSITION_7,PART_REMARK_7,PART_NAME_8,PART_CONDITION_8,PART_BARCODE_8,PART_CONTAINER_LABEL_8,PART_LOT_COUNT_8,PART_DISPOSITION_8,PART_REMARK_8,PART_NAME_9,PART_CONDITION_9,PART_BARCODE_9,PART_CONTAINER_LABEL_9,PART_LOT_COUNT_9,PART_DISPOSITION_9,PART_REMARK_9,PART_NAME_10,PART_CONDITION_10,PART_BARCODE_10,PART_CONTAINER_LABEL_10,PART_LOT_COUNT_10,PART_DISPOSITION_10,PART_REMARK_10,PART_NAME_11,PART_CONDITION_11,PART_BARCODE_11,PART_CONTAINER_LABEL_11,PART_LOT_COUNT_11,PART_DISPOSITION_11,PART_REMARK_11,PART_NAME_12,PART_CONDITION_12,PART_BARCODE_12,PART_CONTAINER_LABEL_12,PART_LOT_COUNT_12,PART_DISPOSITION_12,PART_REMARK_12">
		<cfset geol="GEOLOGY_ATTRIBUTE_1,GEO_ATT_VALUE_1,GEO_ATT_DETERMINER_1,GEO_ATT_DETERMINED_DATE_1,GEO_ATT_DETERMINED_METHOD_1,GEO_ATT_REMARK_1,GEOLOGY_ATTRIBUTE_2,GEO_ATT_VALUE_2,GEO_ATT_DETERMINER_2,GEO_ATT_DETERMINED_DATE_2,GEO_ATT_DETERMINED_METHOD_2,GEO_ATT_REMARK_2,GEOLOGY_ATTRIBUTE_3,GEO_ATT_VALUE_3,GEO_ATT_DETERMINER_3,GEO_ATT_DETERMINED_DATE_3,GEO_ATT_DETERMINED_METHOD_3,GEO_ATT_REMARK_3,GEOLOGY_ATTRIBUTE_4,GEO_ATT_VALUE_4,GEO_ATT_DETERMINER_4,GEO_ATT_DETERMINED_DATE_4,GEO_ATT_DETERMINED_METHOD_4,GEO_ATT_REMARK_4,GEOLOGY_ATTRIBUTE_5,GEO_ATT_VALUE_5,GEO_ATT_DETERMINER_5,GEO_ATT_DETERMINED_DATE_5,GEO_ATT_DETERMINED_METHOD_5,GEO_ATT_REMARK_5,GEOLOGY_ATTRIBUTE_6,GEO_ATT_VALUE_6,GEO_ATT_DETERMINER_6,GEO_ATT_DETERMINED_DATE_6,GEO_ATT_DETERMINED_METHOD_6,GEO_ATT_REMARK_6">
		
		Use this form to customize what you see on data entry and how data carries over when you save a new record. There are (generally)
		three choices in the drowdown for each field:
		<ul>
			<li>hide - remove the field from the data entry screen. 
				It may be possible to have data in hidden fields - use this option with great caution.</li>
			<li>show - show the field, reset to blank each time a record is saved</li>
			<li>carry - show the field, carry last value over after save</li>
		</ul>
		Note that it may be possible to turn off values such that you cannot save a new record, and it may be possible to 
		save a record with (potentially problematic) values in hidden fields.
		
		<p>
			"Linked" fields require only turning off the "controlling" element to hide. Turn off elevation units to get
			rid of all elevation fields, or orig_lat_long_units to get rid of all coordinate data, for example.
		</p>
		<p>
			Attributes 1-6 do different things depending on collection type, and turning them off may do nothing for your account.
			Customize with caution.
		</p>
		
		<span class="likeLink" onclick="toggleAll('hide')">[ hide everything ]</span>
		<span class="likeLink" onclick="toggleAll('show')">[ show everything ]</span>
		<span class="likeLink" onclick="toggleAll('carry')">[ carry everything ]</span>
		
		<form name="customize" method="post" action="customizeDataEntry.cfm">
			<br><input type="submit" value="save preferences">
			<input type="hidden" name="action" value="saveChanges">
			<input type="hidden" name="oldaction" value="#action#">
			<!-- along with required stuff, use this to deal with linked stuff,like elevation --->
			<div class="fs" id="cat">
				<!--- cat --->
				Cataloged Item Identifiers
				<span class="likeLink" onclick="toggleTo('cat','hide')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('cat','show')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('cat','carry')">[ carry all ]</span>				
				<table border id="cat">
					<cfloop list="#cat#" index="i">
						<tr>
							<td>#i#</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<div class="fs" id="coordinates">
				<!--- coordinates --->
				Coordinates
				<span class="likeLink" onclick="toggleTo('coordinates','hide')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('coordinates','show')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('coordinates','carry')">[ carry all ]</span>
				<table border>
					<cfloop list="#coordinates#" index="i">
						<tr>
							<td>#i#</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<div class="fs" id="colls">
				<!--- colls ---->
				Collectors
				<span class="likeLink" onclick="toggleTo('colls','hide')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('colls','show')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('colls','carry')">[ carry all ]</span>
				<table border>
					<cfloop list="#colls#" index="i">
						<tr>
							<td>#i#</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<div class="fs" id="geol">
				<!--- geol ---->
				Geology
				<span class="likeLink" onclick="toggleTo('geol','hide')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('geol','show')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('geol','carry')">[ carry all ]</span>
				<table border>
					<cfloop list="#geol#" index="i">
						<tr>
							<td>#i#</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<div class="fs" id="ids">
				<!--- ids ---->
				Other IDs
				<span class="likeLink" onclick="toggleTo('ids','hide')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('ids','show')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('ids','carry')">[ carry all ]</span>
				<table border>
					<cfloop list="#ids#" index="i">
						<tr>
							<td>#i#</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<div class="fs" id="attributes">
				<!--- attributes ---->
				Attributes
				<span class="likeLink" onclick="toggleTo('attributes','hide')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('attributes','show')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('attributes','carry')">[ carry all ]</span>
				<table border>
					<cfloop list="#attributes#" index="i">
						<tr>
							<td>#i#</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<div class="fs" id="locality">
				<!--- locality ---->
				Locality
				
				<span class="likeLink" onclick="toggleTo('locality','hide')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('locality','show')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('locality','carry')">[ carry all ]</span>
				<table border>
					<cfloop list="#locality#" index="i">
						<tr>
							<td>#i#</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<div class="fs" id="specimen">
				<!--- specimen ---->
				Cataloged Item
				<br>
				<span class="likeLink" onclick="toggleTo('specimen','hide')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('specimen','show')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('specimen','carry')">[ carry all ]</span>
				<table border>
					<cfloop list="#specimen#" index="i">
						<tr>
							<td>#i#</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<div class="fs" id="parts">
				<!--- parts ---->
				Parts
				<br>
				<span class="likeLink" onclick="toggleTo('parts','hide')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('parts','show')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('parts','carry')">[ carry all ]</span>
				<table border>
					<cfloop list="#parts#" index="i">
						<tr>
							<td>#i#</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			
			<br><input type="submit" value="save preferences">
		</form>
	</cfif>
	<cfif action is "saveChanges">
		<cfquery name="getCols" datasource="uam_god">
			select column_name from sys.user_tab_cols
			where lower(table_name)='cf_dataentry_settings'
			and column_name != 'USERNAME'
			order by internal_column_id
		</cfquery>
		
		<cfset sql = "UPDATE cf_dataentry_settings SET ">
		<cfloop query="getCols">
			<cfif isDefined("form.#column_name#")>
				<cfset thisData = evaluate("form." & column_name)>
				<cfset thisData = replace(thisData,"'","''","all")>
				<cfset sql = "#SQL#,#COLUMN_NAME# = '#thisData#'">
			</cfif>
		</cfloop>
		<cfset sql = "#SQL# where username = '#session.username#'">
		<cfset sql = replace(sql,"UPDATE cf_dataentry_settings SET ,","UPDATE cf_dataentry_settings SET ")>			
		<cfquery name="new" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(sql)#
		</cfquery>
		<script>
			parent.closeCust();
		</script>
		<!---<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update cf_dataentry_settings set
				numberAgents=#numberAgents#
			where username='#session.username#'
		</cfquery>
		cflocation url="customizeDataEntry.cfm" addtoken="false">
		--->
	</cfif>
</cfoutput>