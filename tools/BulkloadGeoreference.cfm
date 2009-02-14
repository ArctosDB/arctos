<cfinclude template="/includes/_header.cfm">
<!---- 

This application accepts coordinate data and 
	1) searches for an appropriate locality/lat-long combination (using the current specimen locality)
	2) Failing that, creates an appropriate entry
	3) IF accepted_lat_long_fg=1
			a) makes current coordinate determinations unaccepted
			b) enters loaded coordinate determination as accepted
		or, if accepted_lat_long_fg=1
			a) b) enters loaded coordinate determination as unaccepted
	
make the table 

drop table cf_temp_georef;

	 
create table cf_temp_georef (
	key number not null,
	institution_acronym varchar2(20) not null,
	collection_cde varchar2(255) not null,
	other_id_type varchar2(255) not null,
	other_id_number varchar2(255) not null,
	collection_object_id number,
	determined_by_agent_id number,
	 LAT_DEG     NUMBER,
	 DEC_LAT_MIN NUMBER,
	 LAT_MIN     NUMBER,
	 LAT_SEC     NUMBER,
	 LAT_DIR     CHAR(1),
	 LONG_DEG    NUMBER,
	 DEC_LONG_MIN NUMBER,
	 LONG_MIN    NUMBER,
	 LONG_SEC    NUMBER,
	 LONG_DIR    CHAR(1),
	 DEC_LAT     NUMBER,
	 DEC_LONG    NUMBER,
	 DATUM       VARCHAR2(55) not null,
	 UTM_ZONE    VARCHAR2(3),
	 UTM_EW      NUMBER,
	 UTM_NS      NUMBER,
	 ORIG_LAT_LONG_UNITS VARCHAR2(25) not null,
	 DETERMINED_BY_AGENT varchar2(255) not null,
	 DETERMINED_DATE DATE,
	 LAT_LONG_REF_SOURCE VARCHAR2(255) not null,
	 LAT_LONG_REMARKS VARCHAR2(4000),
	 MAX_ERROR_DISTANCE NUMBER,
	 MAX_ERROR_UNITS    VARCHAR2(2),
	 ACCEPTED_LAT_LONG_FG NUMBER,
	 EXTENT NUMBER,
	 GPSACCURACY NUMBER,
	 GEOREFMETHOD VARCHAR2(255) not null,
	 VERIFICATIONSTATUS VARCHAR2(40) not null,
	 SPATIALFIT NUMBER(4,3),
	 status varchar2(255)
	);
alter table cf_temp_georef rename status to t;
	create or replace public synonym cf_temp_georef for cf_temp_georef;
	grant select,insert,update,delete on cf_temp_georef to coldfusion_user;
	grant select on cf_temp_georef to public;
CREATE OR REPLACE TRIGGER cf_temp_georef_key                                         
 before insert  ON cf_temp_georef  
 for each row 
    begin     
    	if :NEW.key is null then                                                                                      
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;                                
    end;                                                                                            
/
sho err
------>
<CFINclude template="/includes/functionLib.cfm">
<!--- no security --->
<cfif #action# is "nothing">
<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select column_name from all_tab_cols where 
	table_name='CF_TEMP_GEOREF' 
	and column_name not in (
		'KEY',
		'COLLECTION_OBJECT_ID',
		'DETERMINED_BY_AGENT_ID'
	)	order by INTERNAL_COLUMN_ID
</cfquery>
<!---
<cfdump var=#t#>
--->
Step 1: Upload a comma-delimited text file (csv). Save the following code as a CSV template. 
<ul>
	<li>
		Institution_Acronym, Collection_cde, Other_Id_Type, and Other_Id_Number are required and MUST resolve to a single cataloged item.
	</li>
	<li>
		"catalog number" is an acceptable Other_Id_Type
	</li>
	<li>
		All values are case-sensitive.
	</li>
</ul>
<cfoutput>
	<div id="template">
		<textarea rows="2" cols="80" id="t">#valuelist(t.column_name)#</textarea>
	</div> 
<p></p>
</cfoutput>

<cfform name="oids" method="post" enctype="multipart/form-data">
			<input type="hidden" name="Action" value="getFile">
			  <input type="file"
		   name="FiletoUpload"
		   size="45">
			  <input type="submit" value="Upload this file" #saveClr#>
  </cfform>

</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->

<!------------------------------------------------------->
<cfif #action# is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from CF_TEMP_GEOREF
	</cfquery>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />	
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				<cfset thisBit=arrResult[o][i]>
				<cfif #o# is 1>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset colVals="#colVals#,'#thisBit#'">
				</cfif>
			</cfloop>
		<cfif #o# is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>	
		<cfif len(#colVals#) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into CF_TEMP_GEOREF (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	
	
	<cflocation url="BulkloadGeoreference.cfm?action=validate" addtoken="no">
			
	<!----
	
	<cfdump var=#ins#>
	---->
	
</cfoutput>
</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->
<cfif #action# is "validate">
<cfoutput>
	<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update CF_TEMP_GEOREF set status='invalid ACCEPTED_LAT_LONG_FG'
		where ACCEPTED_LAT_LONG_FG not in (1,0)
	</cfquery>
	
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from  CF_TEMP_GEOREF where status is null
	</cfquery>
	<cfloop query="data">
		<br>max_error_distance:#max_error_distance#<br>
		<br>trim:max_error_distance:#trim(max_error_distance)#<br>
		<cfset problem="">
		<cfif #other_id_type# is not "catalog number">
			<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					SELECT 
						coll_obj_other_id_num.collection_object_id
					FROM
						coll_obj_other_id_num,
						cataloged_item,
						collection
					WHERE
						coll_obj_other_id_num.collection_object_id = cataloged_item.collection_object_id and
						cataloged_item.collection_id = collection.collection_id and
						collection.collection_cde = '#collection_cde#' and
						collection.institution_acronym = '#institution_acronym#' and
						other_id_type = '#trim(other_id_type)#' and
						display_value = '#trim(other_id_number)#'
				</cfquery>
			<cfelse>
				<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					SELECT 
						collection_object_id
					FROM
						cataloged_item,
						collection
					WHERE
						cataloged_item.collection_id = collection.collection_id and
						collection.collection_cde = '#collection_cde#' and
						collection.institution_acronym = '#institution_acronym#' and
						cat_num=#other_id_number#
				</cfquery>
			</cfif>
			#collObj.recordcount#<br>
			<cfif #collObj.recordcount# is 0>
				<cfif len(#problem#) is 0>
					<cfset problem = "#data.institution_acronym# #data.collection_cde# #data.other_id_type# #data.other_id_number# could not be found">
				<cfelse>
					<cfset problem = "#problem#; #data.institution_acronym# #data.collection_cde# #data.other_id_type# #data.other_id_number# could not be found">
				</cfif>
			<cfelseif #collObj.recordcount# gt 1>
				<cfif len(#problem#) is 0>
					<cfset problem = "#data.institution_acronym# #data.collection_cde# #data.other_id_type# #data.other_id_number# matched #collObj.recordcount# records.">
				<cfelse>
					<cfset problem = "#data.institution_acronym# #data.collection_cde# #data.other_id_type# #data.other_id_number# matched #collObj.recordcount# records.">
				</cfif>
			<cfelse>
				<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					UPDATE CF_TEMP_GEOREF SET collection_object_id = #collObj.collection_object_id# where
					key = #key#
				</cfquery>
			</cfif>
			<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select distinct agent_id from agent_name where agent_name='#DETERMINED_BY_AGENT#'
			</cfquery>
			<cfif #q.recordcount# is 0>
				<cfif len(#problem#) is 0>
					<cfset problem = "#DETERMINED_BY_AGENT# matched #q.recordcount# records">
				<cfelse>
					<cfset problem = "#problem#; #DETERMINED_BY_AGENT# matched #q.recordcount# records">
				</cfif>
			<cfelse>
				<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					UPDATE CF_TEMP_GEOREF SET DETERMINED_BY_AGENT_ID = #q.agent_id# where
					key = #key#
				</cfquery>
			</cfif>
            <cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select count(*) c from ctdatum where datum='#datum#'
			</cfquery>            
			<cfif #q.c# neq 1>
				<cfif len(#problem#) is 0>
					<cfset problem = "#datum# matched #q.c# records">
				<cfelse>
					<cfset problem = "#problem#; #datum# matched #q.c# records">
				</cfif>
			</cfif>
			<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select count(*) c from ctlat_long_error_units where LAT_LONG_ERROR_UNITS='#MAX_ERROR_UNITS#'
			</cfquery>            
			<cfif #q.c# neq 1>
				<cfif len(#problem#) is 0>
					<cfset problem = "#MAX_ERROR_UNITS# matched #q.c# records">
				<cfelse>
					<cfset problem = "#problem#; #MAX_ERROR_UNITS# matched #q.c# records">
				</cfif>
			</cfif>
			<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select count(*) c from ctGEOREFMETHOD where GEOREFMETHOD='#GEOREFMETHOD#'
			</cfquery>            
			<cfif #q.c# neq 1>
				<cfif len(#problem#) is 0>
					<cfset problem = "#GEOREFMETHOD# matched #q.c# records">
				<cfelse>
					<cfset problem = "#problem#; #GEOREFMETHOD# matched #q.c# records">
				</cfif>
			</cfif>
			<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select count(*) c from ctVERIFICATIONSTATUS where VERIFICATIONSTATUS='#VERIFICATIONSTATUS#'
			</cfquery>     
			<cfif #q.c# neq 1>
				<cfif len(#problem#) is 0>
					<cfset problem = "#VERIFICATIONSTATUS# matched #q.c# records">
				<cfelse>
					<cfset problem = "#problem#; #VERIFICATIONSTATUS# matched #q.c# records">
				</cfif>
			</cfif>
			<cfif #ORIG_LAT_LONG_UNITS# is "decimal degrees">
				<cfif len(#DEC_LAT#) is 0 or len(#DEC_LONG#) is 0>
					<cfif len(#problem#) is 0>
						<cfset problem = "Missing values required for #ORIG_LAT_LONG_UNITS#">
					<cfelse>
						<cfset problem = "#problem#; Missing values required for #ORIG_LAT_LONG_UNITS#">
					</cfif>
				</cfif>
			<cfelseif #ORIG_LAT_LONG_UNITS# is "UTM">
				<cfif len(#UTM_ZONE#) is 0 or len(#UTM_EW#) is 0  or len(#UTM_NS#) is 0>
					<cfif len(#problem#) is 0>
						<cfset problem = "Missing values required for #ORIG_LAT_LONG_UNITS#">
					<cfelse>
						<cfset problem = "#problem#; Missing values required for #ORIG_LAT_LONG_UNITS#">
					</cfif>
				</cfif>
			<cfelseif #ORIG_LAT_LONG_UNITS# is "deg. min. sec.">
				<cfif len(#LAT_DEG#) is 0 or len(#LAT_MIN#) is 0  or len(#LAT_SEC#) is 0 or len(#LAT_DIR#) is 0 
						or len(#LONG_DEG#) is 0 or len(#LONG_MIN#) is 0 or len(#LONG_SEC#) is 0 or len(#LONG_DIR#) is 0 >
					<cfif len(#problem#) is 0>
						<cfset problem = "Missing values required for #ORIG_LAT_LONG_UNITS#">
					<cfelse>
						<cfset problem = "#problem#; Missing values required for #ORIG_LAT_LONG_UNITS#">
					</cfif>
					<cfif (#LAT_DIR# is not "N" and #LAT_DIR# is not "S") or #LONG_DIR# is not "E" and #LONG_DIR# is not "W">
							<cfif len(#problem#) is 0>
							<cfset problem = "Lat/Long Dir invalid">
						<cfelse>
							<cfset problem = "#problem#; Lat/Long Dir invalid">
						</cfif>
					</cfif>
				</cfif>
			<cfelseif #ORIG_LAT_LONG_UNITS# is "degrees dec. minutes">
				<cfif len(#LAT_DEG#) is 0 or len(#DEC_LAT_MIN#) is 0 or len(#LAT_DIR#) is 0 
						or len(#LONG_DEG#) is 0 or len(#DEC_LONG_MIN#) is 0 or len(#LONG_DIR#) is 0 >
					<cfif len(#problem#) is 0>
						<cfset problem = "Missing values required for #ORIG_LAT_LONG_UNITS#">
					<cfelse>
						<cfset problem = "#problem#; Missing values required for #ORIG_LAT_LONG_UNITS#">
					</cfif>
					<cfif (#LAT_DIR# is not "N" and #LAT_DIR# is not "S") or #LONG_DIR# is not "E" and #LONG_DIR# is not "W">
							<cfif len(#problem#) is 0>
							<cfset problem = "Lat/Long Dir invalid">
						<cfelse>
							<cfset problem = "#problem#; Lat/Long Dir invalid">
						</cfif>
					</cfif>
				</cfif>
			</cfif>
			<cfif len(#problem#) gt 0>
				<cfquery name="insColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					UPDATE CF_TEMP_GEOREF SET status = '#problem#' where
					key = #key#
				</cfquery>
			</cfif>
			
		</cfloop>
	<cfquery name="done" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from  CF_TEMP_GEOREF
	</cfquery>
	<cfdump var=#done#>
	<cfquery name ="ok" dbtype="query">
		select * from done where status is not null
	</cfquery>
	<cfif ok.recordcount is 0>
		<a href="BulkloadGeoreference.cfm?action=loadData">load em</a>
	</cfif>
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "loadData">

<cfoutput>
	
		
	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from CF_TEMP_GEOREF
	</cfquery>
	
	<cftransaction>
	<cfloop query="getTempData">
		<!--- get locality data from the current locality --->
		<cfquery name="cd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				locality.LOCALITY_ID,
				GEOG_AUTH_REC_ID,
				MAXIMUM_ELEVATION,
				MINIMUM_ELEVATION,
				ORIG_ELEV_UNITS,
				SPEC_LOCALITY,
				LOCALITY_REMARKS,
				DEPTH_UNITS,
				MIN_DEPTH,
				MAX_DEPTH,
				NOGEOREFBECAUSE
			from 
				cataloged_item,
				collecting_event,
				locality 
			where 
				cataloged_item.collecting_event_id = collecting_event.collecting_event_id and
				collecting_event.locality_id = locality.locality_id and
				cataloged_item.collection_object_id = #collection_object_id#
		</cfquery>
		<!--- see if an appropriate locality/georef combination exists --->
		<cfset localityStuffString = "#cd.MAXIMUM_ELEVATION#:#cd.MINIMUM_ELEVATION#:#cd.ORIG_ELEV_UNITS#:#cd.SPEC_LOCALITY#:#cd.LOCALITY_REMARKS#:#cd.DEPTH_UNITS#:#cd.MIN_DEPTH#:#cd.MAX_DEPTH#:#cd.NOGEOREFBECAUSE#:">
				localityStuffString:#localityStuffString#<br>
		<cfif #ORIG_LAT_LONG_UNITS# is "decimal degrees">
			<cfset coordStr = "#DEC_LAT#:#DEC_LONG#:">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "UTM">
			<cfset coordStr = "#UTM_ZONE#:#UTM_EW#:#UTM_NS#:">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "degrees dec. minutes">
			<cfset coordStr = "#LAT_DEG#:#DEC_LAT_MIN#:#LAT_DIR#:#LONG_DEG#:#DEC_LONG_MIN#:#LONG_DIR#:">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "deg. min. sec.">
			<cfset coordStr = "#LAT_DEG#:#LAT_MIN#:#LAT_SEC#:#LAT_DIR#:#LONG_DEG#:#LONG_MIN#:#LONG_SEC#:#LONG_DIR#:">
		</cfif>
		<cfset coordStatStr = "#dateformat(DETERMINED_DATE,"dd-Mmm-yyyy")#:#LAT_LONG_REMARKS#:#MAX_ERROR_DISTANCE#:#MAX_ERROR_UNITS#:#EXTENT#:#GPSACCURACY#:#SPATIALFIT#:">
		coordStr:#coordStr#<br>
		<cfset sql = "select min(locality.locality_id) locality_id FROM
				locality,
				lat_long
			WHERE
				locality.locality_id = lat_long.locality_id and
				GEOG_AUTH_REC_ID = #cd.GEOG_AUTH_REC_ID# and
				to_char(MAXIMUM_ELEVATION) ||':'||
				to_char(MINIMUM_ELEVATION) ||':'||
				ORIG_ELEV_UNITS ||':'||
				SPEC_LOCALITY ||':'||
				LOCALITY_REMARKS ||':'||
				DEPTH_UNITS ||':'||
				to_char(MIN_DEPTH) ||':'||
				to_char(MAX_DEPTH) ||':'||
				NOGEOREFBECAUSE ||':'
			=
				'#localityStuffString#'	and
				DATUM='#DATUM#' and
				ORIG_LAT_LONG_UNITS='#ORIG_LAT_LONG_UNITS#' and
				DETERMINED_BY_AGENT_ID=#DETERMINED_BY_AGENT_ID# and
				LAT_LONG_REF_SOURCE='#LAT_LONG_REF_SOURCE#' and
				ACCEPTED_LAT_LONG_FG=#ACCEPTED_LAT_LONG_FG# and
				GEOREFMETHOD='#GEOREFMETHOD#' and
				VERIFICATIONSTATUS='#VERIFICATIONSTATUS#' and	
			decode (ORIG_LAT_LONG_UNITS,
				'UTM',
					UTM_ZONE ||':'|| UTM_EW ||':'|| UTM_NS ||':',
				'decimal degrees',
					DEC_LAT ||':'|| DEC_LONG ||':',
				'degrees dec. minutes',
					LAT_DEG ||':'|| DEC_LAT_MIN ||':'|| LAT_DIR ||':'|| LONG_DEG ||':'|| DEC_LONG_MIN ||':'|| LONG_DIR ||':',
				'deg. min. sec.',
					LAT_DEG ||':'|| LAT_MIN ||':'|| LAT_SEC ||':'|| LAT_DIR ||':'|| LONG_DEG ||':'|| 
					LONG_MIN ||':'|| LONG_SEC ||':'|| LONG_DIR ||':'
			) = '#coordStr#' and
			to_char(DETERMINED_DATE,'dd-Mon-yyyy') ||':'|| LAT_LONG_REMARKS ||':'|| MAX_ERROR_DISTANCE ||':'|| 
			 MAX_ERROR_UNITS ||':'|| EXTENT ||':'|| GPSACCURACY ||':'|| SPATIALFIT ||':' = '#coordStatStr#'">
			 <br>
			 sql:#sql#<br>
		<cfquery name="itsThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(sql)#
		</cfquery>
		<cfif isdefined("itsThere.locality_id") and len(#itsThere.locality_id#) gt 0>
			yay - found a match!!
		<cfelse>
			boo - make a locality
		</cfif>
		itsThere.locality_id:#itsThere.locality_id#<br>
		cd.locality_id: #cd.locality_id#<br>
	</cfloop>
	</cftransaction>

	Spiffy, all done.
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
