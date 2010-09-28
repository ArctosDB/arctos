<!----

create table cf_dataentry_settings (
	username varchar2(60) not null,
	numberAgents number
);

create or replace public synonym cf_dataentry_settings for cf_dataentry_settings;
grant all on cf_dataentry_settings to data_entry;

---->
<cfinclude template="/includes/alwaysInclude.cfm">
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
		<cfquery name="getCols" datasource="uam_god">
			select column_name from sys.user_tab_cols
			where lower(table_name)='cf_dataentry_settings'
			and column_name != 'USERNAME'
			order by internal_column_id
		</cfquery>
		Use this form to customize what you see on data entry and how it carries over when you save a new record.
		Note that it may be possible to turn off values such that you cannot save a new record, and it may be possible to 
		save a record with (potentially problematic) values in hidden fields. We'll try to not turn off required fields, so
		some settings (such as hiding taxon name) may do nothing. Linked fields may be somewhat cryptic. Turn off elevation units to get
		rid of all elevation fields, or orig_lat_long_units to get rid of all coordinate data, for example.
		Attributes 1-6 do different things depending on collection type, and turning them off may do nothing for your account.
		Use with caution.
		<form name="customize" method="post" action="customizeDataEntry.cfm">
			<br><input type="submit" value="save preferences">
			<input type="hidden" name="action" value="saveChanges">
			<input type="hidden" name="oldaction" value="#action#">
			<!-- along with required stuff, use this to deal with linked stuff,like elevation --->
			<cfset noHide="OTHER_ID_NUM_TYPE_1,OTHER_ID_NUM_TYPE_2,OTHER_ID_NUM_TYPE_3,OTHER_ID_NUM_TYPE_4,OTHER_ID_NUM_TYPE_5,PART_CONDITION_1,PART_BARCODE_1,PART_CONTAINER_LABEL_1,PART_LOT_COUNT_1,PART_DISPOSITION_1,PART_REMARK_1,PART_CONDITION_2,PART_BARCODE_2,PART_CONTAINER_LABEL_2,PART_LOT_COUNT_2,PART_DISPOSITION_2,PART_REMARK_2,PART_CONDITION_3,PART_BARCODE_3,PART_CONTAINER_LABEL_3,PART_LOT_COUNT_3,PART_DISPOSITION_3,PART_REMARK_3,PART_CONDITION_4,PART_BARCODE_4,PART_CONTAINER_LABEL_4,PART_LOT_COUNT_4,PART_DISPOSITION_4,PART_REMARK_4,PART_CONDITION_5,PART_BARCODE_5,PART_CONTAINER_LABEL_5,PART_LOT_COUNT_5,PART_DISPOSITION_5,PART_REMARK_5,PART_CONDITION_6,PART_BARCODE_6,PART_CONTAINER_LABEL_6,PART_LOT_COUNT_6,PART_DISPOSITION_6,PART_REMARK_6,PART_CONDITION_7,PART_BARCODE_7,PART_CONTAINER_LABEL_7,PART_LOT_COUNT_7,PART_DISPOSITION_7,PART_REMARK_7,PART_CONDITION_8,PART_BARCODE_8,PART_CONTAINER_LABEL_8,PART_LOT_COUNT_8,PART_DISPOSITION_8,PART_REMARK_8,PART_CONDITION_9,PART_BARCODE_9,PART_CONTAINER_LABEL_9,PART_LOT_COUNT_9,PART_DISPOSITION_9,PART_REMARK_9,PART_CONDITION_10,PART_BARCODE_10,PART_CONTAINER_LABEL_10,PART_LOT_COUNT_10,PART_DISPOSITION_10,PART_REMARK_10,PART_CONDITION_11,PART_BARCODE_11,PART_CONTAINER_LABEL_11,PART_LOT_COUNT_11,PART_DISPOSITION_11,PART_REMARK_11,PART_CONDITION_12,PART_BARCODE_12,PART_CONTAINER_LABEL_12,PART_LOT_COUNT_12,PART_DISPOSITION_12,PART_REMARK_12,RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE,ATTRIBUTE_VALUE_1,ATTRIBUTE_UNITS_1,ATTRIBUTE_REMARKS_1,ATTRIBUTE_DATE_1,ATTRIBUTE_DET_METH_1,ATTRIBUTE_DETERMINER_1,ATTRIBUTE_VALUE_2,ATTRIBUTE_UNITS_2,ATTRIBUTE_REMARKS_2,ATTRIBUTE_DATE_2,ATTRIBUTE_DET_METH_2,ATTRIBUTE_DETERMINER_2,ATTRIBUTE_VALUE_3,ATTRIBUTE_UNITS_3,ATTRIBUTE_REMARKS_3,ATTRIBUTE_DATE_3,ATTRIBUTE_DET_METH_3,ATTRIBUTE_DETERMINER_3,ATTRIBUTE_VALUE_4,ATTRIBUTE_UNITS_4,ATTRIBUTE_REMARKS_4,ATTRIBUTE_DATE_4,ATTRIBUTE_DET_METH_4,ATTRIBUTE_DETERMINER_4,ATTRIBUTE_VALUE_5,ATTRIBUTE_UNITS_5,ATTRIBUTE_REMARKS_5,ATTRIBUTE_DATE_5,ATTRIBUTE_DET_METH_5,ATTRIBUTE_DETERMINER_5,ATTRIBUTE_VALUE_6,ATTRIBUTE_UNITS_6,ATTRIBUTE_REMARKS_6,ATTRIBUTE_DATE_6,ATTRIBUTE_DET_METH_6,ATTRIBUTE_DETERMINER_6,ATTRIBUTE_VALUE_7,ATTRIBUTE_UNITS_7,ATTRIBUTE_REMARKS_7,ATTRIBUTE_DATE_7,ATTRIBUTE_DET_METH_7,ATTRIBUTE_DETERMINER_7,ATTRIBUTE_VALUE_8,ATTRIBUTE_UNITS_8,ATTRIBUTE_REMARKS_8,ATTRIBUTE_DATE_8,ATTRIBUTE_DET_METH_8,ATTRIBUTE_DETERMINER_8,ATTRIBUTE_VALUE_9,ATTRIBUTE_UNITS_9,ATTRIBUTE_REMARKS_9,ATTRIBUTE_DATE_9,ATTRIBUTE_DET_METH_9,ATTRIBUTE_DETERMINER_9,ATTRIBUTE_VALUE_10,ATTRIBUTE_UNITS_10,ATTRIBUTE_REMARKS_10,ATTRIBUTE_DATE_10,ATTRIBUTE_DET_METH_10,ATTRIBUTE_DETERMINER_10,GEO_ATT_DETERMINER_1,GEO_ATT_DETERMINED_DATE_1,GEO_ATT_DETERMINED_METHOD_1,GEO_ATT_REMARK_1,GEOLOGY_ATTRIBUTE_2,GEO_ATT_DETERMINER_2,GEO_ATT_DETERMINED_DATE_2,GEO_ATT_DETERMINED_METHOD_2,GEO_ATT_REMARK_2,GEOLOGY_ATTRIBUTE_3,GEO_ATT_DETERMINER_3,GEO_ATT_DETERMINED_DATE_3,GEO_ATT_DETERMINED_METHOD_3,GEO_ATT_REMARK_3,GEOLOGY_ATTRIBUTE_4,GEO_ATT_DETERMINER_4,GEO_ATT_DETERMINED_DATE_4,GEO_ATT_DETERMINED_METHOD_4,GEO_ATT_REMARK_4,GEOLOGY_ATTRIBUTE_5,GEO_ATT_DETERMINER_5,GEO_ATT_DETERMINED_DATE_5,GEO_ATT_DETERMINED_METHOD_5,GEO_ATT_REMARK_5,GEOLOGY_ATTRIBUTE_6,GEO_ATT_DETERMINER_6,GEO_ATT_DETERMINED_DATE_6,GEO_ATT_DETERMINED_METHOD_6,GEO_ATT_REMARK_6,DEC_LAT,DEC_LONG,LATDEG,DEC_LAT_MIN,LATMIN,LATSEC,LATDIR,LONGDEG,DEC_LONG_MIN,LONGMIN,LONGSEC,LONGDIR,DATUM,LAT_LONG_REF_SOURCE,MAX_ERROR_DISTANCE,MAX_ERROR_UNITS,GEOREFMETHOD,DETERMINED_BY_AGENT,DETERMINED_DATE,VERIFICATIONSTATUS,UTM_ZONE,UTM_EW,UTM_NS,EXTENT,GPSACCURACY,maximum_elevation,minimum_elevation,collector_agent_1,collector_role_1,ACCN,TAXON_NAME,NATURE_OF_ID,ID_MADE_BY_AGENT,VERBATIM_DATE,BEGAN_DATE,ENDED_DATE,HIGHER_GEOG,SPEC_LOCALITY,VERBATIM_LOCALITY,COLL_OBJ_DISPOSITION,CONDITION,COLLECTING_METHOD,COLLECTING_SOURCE">
			
			
			


			<table border>
				<cfloop query="getCols">
					<tr>
						<td>#column_name#</td>
						<td>
							<cfset uservalue=evaluate("d." & column_name)>
							<select name="#column_name#" id="#column_name#">
								<cfif not listfindnocase(noHide,column_name)>
									<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
								</cfif>
								<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
								<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
							</select>
						</td>
					</tr>
				</cfloop>
			</table>
			<br><br><input type="submit" value="save preferences">
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
		#preservesinglequotes(sql)#
		
		<cflocation url="customizeDataEntry.cfm" addtoken="false">
		<!---<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update cf_dataentry_settings set
				numberAgents=#numberAgents#
			where username='#session.username#'
		</cfquery>
		
		--->
	</cfif>
</cfoutput>