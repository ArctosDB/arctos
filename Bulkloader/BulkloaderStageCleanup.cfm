<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkloader Stage Cleanup" />
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
	<cfif action is "runUpdate">
		<cfoutput>
			<cfdump var=#form#>
		</cfoutput>
	</cfif>
<cfif action is "updateCommonDefaults">
	<cfoutput>

		<cfquery name="ctnature_of_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select nature_of_id from ctnature_of_id order by nature_of_id
		</cfquery>
<cfdump var=#ctnature_of_id#>
		<hr>
		select something to update ALL rows in bulkloader stage to the selected value.

		<br>Mess it up? Reload your text file.

		<form name="x" method="post" action="BulkloaderStageCleanup.cfm">
			<input type="hidden" name="action" value="runUpdate">
			UPDATE bulkloader_stage SET
			<div>
				ENTEREDBY=
				<select name="ENTEREDBY" id="ENTEREDBY">
					<option value=""></option>
					<option value="#session.username#">#session.username#</option>
				</select>
			</div>
			<div>
				NATURE_OF_ID=
				<select name="NATURE_OF_ID" id="NATURE_OF_ID">
					<option value=""></option>
					<cfloop query="nature_of_id">
						<option value="#nature_of_id#">#nature_of_id#</option>
					</cfloop>
				</select>
			</div>
		</form>
			<div>
				NATURE_OF_ID=
				<select name="NATURE_OF_ID" id="NATURE_OF_ID">
					<option value=""></option>
					<cfloop query="ctnature_of_id">
						<option value="#nature_of_id#">#nature_of_id#</option>
					</cfloop>
				</select>
			</div>
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
OTHER_ID_NUM_5,OTHER_ID_NUM_TYPE_5,OTHER_ID_NUM_1,OTHER_ID_NUM_TYPE_1,ACCN,TAXON_NAME,,ID_MADE_BY_AGENT,MADE_DATE,IDENTIFICATION_REMARKS,VERBATIM_DATE,BEGAN_DATE,ENDED_DATE,HIGHER_GEOG,SPEC_LOCALITY,VERBATIM_LOCALITY,ORIG_LAT_LONG_UNITS,DEC_LAT,DEC_LONG,LATDEG,DEC_LAT_MIN,LATMIN,LATSEC,LATDIR,LONGDEG,DEC_LONG_MIN,LONGMIN,LONGSEC,LONGDIR,DATUM,GEOREFERENCE_SOURCE,MAX_ERROR_DISTANCE,MAX_ERROR_UNITS,GEOREFERENCE_PROTOCOL,EVENT_ASSIGNED_BY_AGENT,EVENT_ASSIGNED_DATE,VERIFICATIONSTATUS,MAXIMUM_ELEVATION,MINIMUM_ELEVATION,ORIG_ELEV_UNITS,LOCALITY_REMARKS,HABITAT,COLL_EVENT_REMARKS,COLLECTOR_AGENT_1,COLLECTOR_ROLE_1,COLLECTOR_AGENT_2,COLLECTOR_ROLE_2,COLLECTOR_AGENT_3,COLLECTOR_ROLE_3,COLLECTOR_AGENT_4,COLLECTOR_ROLE_4,COLLECTOR_AGENT_5,COLLECTOR_ROLE_5,COLLECTOR_AGENT_6,COLLECTOR_ROLE_6,COLLECTOR_AGENT_7,COLLECTOR_ROLE_7,COLLECTOR_AGENT_8,COLLECTOR_ROLE_8,COLLECTION_CDE,INSTITUTION_ACRONYM,FLAGS,COLL_OBJECT_REMARKS,OTHER_ID_NUM_2,OTHER_ID_NUM_TYPE_2,OTHER_ID_NUM_3,OTHER_ID_NUM_TYPE_3,OTHER_ID_NUM_4,OTHER_ID_NUM_TYPE_4,PART_NAME_1,PART_CONDITION_1,PART_BARCODE_1,PART_CONTAINER_LABEL_1,PART_LOT_COUNT_1,PART_DISPOSITION_1,PART_REMARK_1,PART_NAME_2,PART_CONDITION_2,PART_BARCODE_2,PART_CONTAINER_LABEL_2,PART_LOT_COUNT_2,PART_DISPOSITION_2,PART_REMARK_2,PART_NAME_3,PART_CONDITION_3,PART_BARCODE_3,PART_CONTAINER_LABEL_3,PART_LOT_COUNT_3,PART_DISPOSITION_3,PART_REMARK_3,PART_NAME_4,PART_CONDITION_4,PART_BARCODE_4,PART_CONTAINER_LABEL_4,PART_LOT_COUNT_4,PART_DISPOSITION_4,PART_REMARK_4,PART_NAME_5,PART_CONDITION_5,PART_BARCODE_5,PART_CONTAINER_LABEL_5,PART_LOT_COUNT_5,PART_DISPOSITION_5,PART_REMARK_5,PART_NAME_6,PART_CONDITION_6,PART_BARCODE_6,PART_CONTAINER_LABEL_6,PART_LOT_COUNT_6,PART_DISPOSITION_6,PART_REMARK_6,PART_NAME_7,PART_CONDITION_7,PART_BARCODE_7,PART_CONTAINER_LABEL_7,PART_LOT_COUNT_7,PART_DISPOSITION_7,PART_REMARK_7,PART_NAME_8,PART_CONDITION_8,PART_BARCODE_8,PART_CONTAINER_LABEL_8,PART_LOT_COUNT_8,PART_DISPOSITION_8,PART_REMARK_8,PART_NAME_9,PART_CONDITION_9,PART_BARCODE_9,PART_CONTAINER_LABEL_9,PART_LOT_COUNT_9,PART_DISPOSITION_9,PART_REMARK_9,PART_NAME_10,PART_CONDITION_10,PART_BARCODE_10,PART_CONTAINER_LABEL_10,PART_LOT_COUNT_10,PART_DISPOSITION_10,PART_REMARK_10,PART_NAME_11,PART_CONDITION_11,PART_BARCODE_11,PART_CONTAINER_LABEL_11,PART_LOT_COUNT_11,PART_DISPOSITION_11,PART_REMARK_11,PART_NAME_12,PART_CONDITION_12,PART_BARCODE_12,PART_CONTAINER_LABEL_12,PART_LOT_COUNT_12,PART_DISPOSITION_12,PART_REMARK_12,ATTRIBUTE_1,ATTRIBUTE_VALUE_1,ATTRIBUTE_UNITS_1,ATTRIBUTE_REMARKS_1,ATTRIBUTE_DATE_1,ATTRIBUTE_DET_METH_1,ATTRIBUTE_DETERMINER_1,ATTRIBUTE_2,ATTRIBUTE_VALUE_2,ATTRIBUTE_UNITS_2,ATTRIBUTE_REMARKS_2,ATTRIBUTE_DATE_2,ATTRIBUTE_DET_METH_2,ATTRIBUTE_DETERMINER_2,ATTRIBUTE_3,ATTRIBUTE_VALUE_3,ATTRIBUTE_UNITS_3,ATTRIBUTE_REMARKS_3,ATTRIBUTE_DATE_3,ATTRIBUTE_DET_METH_3,ATTRIBUTE_DETERMINER_3,ATTRIBUTE_4,ATTRIBUTE_VALUE_4,ATTRIBUTE_UNITS_4,ATTRIBUTE_REMARKS_4,ATTRIBUTE_DATE_4,ATTRIBUTE_DET_METH_4,ATTRIBUTE_DETERMINER_4,ATTRIBUTE_5,ATTRIBUTE_VALUE_5,ATTRIBUTE_UNITS_5,ATTRIBUTE_REMARKS_5,ATTRIBUTE_DATE_5,ATTRIBUTE_DET_METH_5,ATTRIBUTE_DETERMINER_5,ATTRIBUTE_6,ATTRIBUTE_VALUE_6,ATTRIBUTE_UNITS_6,ATTRIBUTE_REMARKS_6,ATTRIBUTE_DATE_6,ATTRIBUTE_DET_METH_6,ATTRIBUTE_DETERMINER_6,ATTRIBUTE_7,ATTRIBUTE_VALUE_7,ATTRIBUTE_UNITS_7,ATTRIBUTE_REMARKS_7,ATTRIBUTE_DATE_7,ATTRIBUTE_DET_METH_7,ATTRIBUTE_DETERMINER_7,ATTRIBUTE_8,ATTRIBUTE_VALUE_8,ATTRIBUTE_UNITS_8,ATTRIBUTE_REMARKS_8,ATTRIBUTE_DATE_8,ATTRIBUTE_DET_METH_8,ATTRIBUTE_DETERMINER_8,ATTRIBUTE_9,ATTRIBUTE_VALUE_9,ATTRIBUTE_UNITS_9,ATTRIBUTE_REMARKS_9,ATTRIBUTE_DATE_9,ATTRIBUTE_DET_METH_9,ATTRIBUTE_DETERMINER_9,ATTRIBUTE_10,ATTRIBUTE_VALUE_10,ATTRIBUTE_UNITS_10,ATTRIBUTE_REMARKS_10,ATTRIBUTE_DATE_10,ATTRIBUTE_DET_METH_10,ATTRIBUTE_DETERMINER_10,RELATIONSHIP,RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE,MIN_DEPTH,MAX_DEPTH,DEPTH_UNITS,COLLECTING_METHOD,COLLECTING_SOURCE,ASSOCIATED_SPECIES,LOCALITY_ID,UTM_ZONE,UTM_EW,UTM_NS,GEOLOGY_ATTRIBUTE_1,GEO_ATT_VALUE_1,GEO_ATT_DETERMINER_1,GEO_ATT_DETERMINED_DATE_1,GEO_ATT_DETERMINED_METHOD_1,GEO_ATT_REMARK_1,GEOLOGY_ATTRIBUTE_2,GEO_ATT_VALUE_2,GEO_ATT_DETERMINER_2,GEO_ATT_DETERMINED_DATE_2,GEO_ATT_DETERMINED_METHOD_2,GEO_ATT_REMARK_2,GEOLOGY_ATTRIBUTE_3,GEO_ATT_VALUE_3,GEO_ATT_DETERMINER_3,GEO_ATT_DETERMINED_DATE_3,GEO_ATT_DETERMINED_METHOD_3,GEO_ATT_REMARK_3,GEOLOGY_ATTRIBUTE_4,GEO_ATT_VALUE_4,GEO_ATT_DETERMINER_4,GEO_ATT_DETERMINED_DATE_4,GEO_ATT_DETERMINED_METHOD_4,GEO_ATT_REMARK_4,GEOLOGY_ATTRIBUTE_5,GEO_ATT_VALUE_5,GEO_ATT_DETERMINER_5,GEO_ATT_DETERMINED_DATE_5,GEO_ATT_DETERMINED_METHOD_5,GEO_ATT_REMARK_5,GEOLOGY_ATTRIBUTE_6,GEO_ATT_VALUE_6,GEO_ATT_DETERMINER_6,GEO_ATT_DETERMINED_DATE_6,GEO_ATT_DETERMINED_METHOD_6,GEO_ATT_REMARK_6,COLLECTING_EVENT_ID,SPECIMEN_EVENT_REMARK,SPECIMEN_EVENT_TYPE,COLLECTING_EVENT_NAME,LOCALITY_NAME
