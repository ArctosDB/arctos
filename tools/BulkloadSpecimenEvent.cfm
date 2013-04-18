<!-----

drop table cf_temp_specevent;


create table cf_temp_specevent (
	key number not null,
	status varchar2(255),
	guid varchar2(60) not null,
	ASSIGNED_BY_AGENT varchar2(255),
	ASSIGNED_DATE varchar2(255),
	SPECIMEN_EVENT_REMARK varchar2(255),
	SPECIMEN_EVENT_TYPE varchar2(255),
	COLLECTING_METHOD varchar2(255),
	COLLECTING_SOURCE varchar2(255),
	VERIFICATIONSTATUS varchar2(255),
	HABITAT varchar2(255),
	COLLECTING_EVENT_ID NUMBER,
	VERBATIM_DATE varchar2(255),
	VERBATIM_LOCALITY varchar2(255),
	COLL_EVENT_REMARKS varchar2(255),
	BEGAN_DATE varchar2(255),
	ENDED_DATE varchar2(255),
	COLLECTING_EVENT_NAME varchar2(255),
	LAT_DEG NUMBER,
	DEC_LAT_MIN NUMBER,
	LAT_MIN NUMBER,
	LAT_SEC NUMBER,
	LAT_DIR NUMBER,
	LONG_DEG NUMBER,
	DEC_LONG_MIN NUMBER,
	LONG_MIN NUMBER,
	LONG_SEC NUMBER,
	LONG_DIR NUMBER,
	DEC_LAT NUMBER,
	DEC_LONG NUMBER,
	DATUM varchar2(255),
	UTM_ZONE varchar2(255),
	UTM_EW varchar2(255),
	UTM_NS varchar2(255),
	ORIG_LAT_LONG_UNITS varchar2(255),
	LOCALITY_ID NUMBER,
	SPEC_LOCALITY varchar2(255),
	MINIMUM_ELEVATION NUMBER,
	MAXIMUM_ELEVATION NUMBER,
	ORIG_ELEV_UNITS varchar2(255),
	MIN_DEPTH NUMBER,
	MAX_DEPTH NUMBER,
	DEPTH_UNITS varchar2(255),
	MAX_ERROR_DISTANCE NUMBER,
	MAX_ERROR_UNITS varchar2(255),
	LOCALITY_REMARKS varchar2(255),
	GEOREFERENCE_SOURCE varchar2(255),
	GEOREFERENCE_PROTOCOL varchar2(255),
	LOCALITY_NAME varchar2(255),
	GEOG_AUTH_REC_ID NUMBER,
	HIGHER_GEOG varchar2(255),
	l_collection_object_id number,
	l_collecting_event_id number,
	l_locality_id number,
	l_geog_auth_rec_id number
);

create or replace public synonym cf_temp_specevent for cf_temp_specevent;

grant all on cf_temp_specevent to coldfusion_user;

CREATE OR REPLACE TRIGGER cf_temp_specevent_key before insert ON cf_temp_specevent for each row
    begin
    	if :NEW.key is null then
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;
    end;
/

---->
<cfinclude template="/includes/_header.cfm">
<cfset thecolumns="guid,ASSIGNED_BY_AGENT,ASSIGNED_DATE,SPECIMEN_EVENT_REMARK,SPECIMEN_EVENT_TYPE,COLLECTING_METHOD,COLLECTING_SOURCE,VERIFICATIONSTATUS,HABITAT,COLLECTING_EVENT_ID,COLLECTING_EVENT_NAME,VERBATIM_DATE,VERBATIM_LOCALITY,COLL_EVENT_REMARKS,BEGAN_DATE,ENDED_DATE,LAT_DEG,DEC_LAT_MIN,LAT_MIN,LAT_SEC,LAT_DIR,LONG_DEG,DEC_LONG_MIN,LONG_MIN,LONG_SEC,LONG_DIR,DEC_LAT,DEC_LONG,DATUM,UTM_ZONE,UTM_EW,UTM_NS,ORIG_LAT_LONG_UNITS,LOCALITY_ID,SPEC_LOCALITY,MINIMUM_ELEVATION,MAXIMUM_ELEVATION,ORIG_ELEV_UNITS,MIN_DEPTH,MAX_DEPTH,DEPTH_UNITS,MAX_ERROR_DISTANCE,MAX_ERROR_UNITS,LOCALITY_REMARKS,GEOREFERENCE_SOURCE,GEOREFERENCE_PROTOCOL,LOCALITY_NAME,GEOG_AUTH_REC_ID,HIGHER_GEOG">
<cfif action is "makeTemplate">
	<cfset header=thecolumns>
	<cffile action = "write"
    file = "#Application.webDirectory#/download/BulkloadSpecimenEvent.csv"
    output = "#header#"
    addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkloadSpecimenEvent.csv" addtoken="false">
</cfif>
<cfif action is  "nothing">
	Use this form to ADD specimen-events.
	<p>
		You may NOT create localities with geology attributes from this form - create them in Arctos, name them, and use locality_name here. 
		<a href="/contact.cfm">contact us</a> if you need other functinoality.
	</p>
	<p>
		<a href="BulkloadSpecimenEvent.cfm?action=makeTemplate">download a CSV template</a>
	</p>
	<table border>
		<tr>
			<th>Column</th>
			<th>Required?</th>
			<th>more</th>
		</tr>
		<tr>
			<td>guid</td>
			<td>yes</td>
			<td>UAM:Mamm:12 format</td>
		</tr>
		<tr>
			<td>ASSIGNED_BY_AGENT</td>
			<td>yes</td>
			<td>unique agent_name</td>
		</tr>
		<tr>
			<td>ASSIGNED_DATE</td>
			<td>yes</td>
			<td>ISO8601</td>
		</tr>
		<tr>
			<td>SPECIMEN_EVENT_REMARK</td>
			<td>no</td>
			<td></td>
		</tr>
		<tr>
			<td>SPECIMEN_EVENT_TYPE</td>
			<td>yes</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTSPECIMEN_EVENT_TYPE">CTSPECIMEN_EVENT_TYPE</a></td>
		</tr>
		<tr>
			<td>COLLECTING_METHOD</td>
			<td>no</td>
			<td></td>
		</tr>
		<tr>
			<td>COLLECTING_SOURCE</td>
			<td>yes</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTCOLLECTING_SOURCE">CTCOLLECTING_SOURCE</a></td>
		</tr>
		<tr>
			<td>VERIFICATIONSTATUS</td>
			<td>yes</td>
			<td><a href="/info/ctDocumentation.cfm?table=CTVERIFICATIONSTATUS">CTVERIFICATIONSTATUS</a></td>
		</tr>
		<tr>
			<td>HABITAT</td>
			<td>no</td>
			<td></td>
		</tr>
		<tr>
			<td>COLLECTING_EVENT_ID</td>
			<td>no</td>
			<td>Specify an existing COLLECTING_EVENT.COLLECTING_EVENT_ID to use an existing event. This will IGNORE anything
			else entered under event, locality, geography here</td>
		</tr>
		<tr>
			<td>COLLECTING_EVENT_NAME</td>
			<td>no</td>
			<td>Specify an existing COLLECTING_EVENT.COLLECTING_EVENT_NAME to use an existing event. This will IGNORE anything
			else entered under event, locality, geography here</td>
		</tr>
		<tr>
			<td>VERBATIM_DATE</td>
			<td>conditionally</td>
			<td>required if COLLECTING_EVENT_ID or COLLECTING_EVENT_NAME is not given</td>
		</tr>
		<tr>
			<td>VERBATIM_LOCALITY</td>
			<td>conditionally</td>
			<td>required if COLLECTING_EVENT_ID or COLLECTING_EVENT_NAME is not given</td>
		</tr>
		<tr>
			<td>COLL_EVENT_REMARKS</td>
			<td>no</td>
			<td></td>
		</tr>
		<tr>
			<td>BEGAN_DATE</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>ENDED_DATE</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>LAT_DEG</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>DEC_LAT_MIN</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>LAT_MIN</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>LAT_SEC</td>
			<td></td>
			<td></td>
		</tr>
	<tr>
		<td>LAT_DIR</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>LONG_DEG</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>DEC_LONG_MIN</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>LONG_MIN</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>LONG_SEC</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>LONG_DIR</td>
		<td></td>
		<td></td>
	</tr>
		<tr>
			<td>DEC_LAT</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>DEC_LONG</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>DATUM</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>UTM_ZONE</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>UTM_EW</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>UTM_NS</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>ORIG_LAT_LONG_UNITS</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>LOCALITY_ID</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>SPEC_LOCALITY</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>MINIMUM_ELEVATION</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>MAXIMUM_ELEVATION</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>ORIG_ELEV_UNITS</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>MIN_DEPTH</td>
			<td></td>
			<td></td>
		</tr>
	<tr>
		<td>MAX_DEPTH</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>DEPTH_UNITS</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>MAX_ERROR_DISTANCE</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>MAX_ERROR_UNITS</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>LOCALITY_REMARKS</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>GEOREFERENCE_SOURCE</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>GEOREFERENCE_PROTOCOL</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>LOCALITY_NAME</td>
		<td></td>
		<td></td>
	</tr>
		<tr>
			<td>GEOG_AUTH_REC_ID</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>HIGHER_GEOG</td>
			<td></td>
			<td></td>
		</tr>

	</table>


	Upload a file:
	<cfform name="getFile" method="post" action="BulkloadSpecimenEvent.cfm" enctype="multipart/form-data">
		<input type="hidden" name="action" value="getFileData">
		 <input type="file"
			   name="FiletoUpload"
			   size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>
</cfif>

<cfif action is "getFileData">
	<cfoutput>
		<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from cf_temp_specevent
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
					<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into cf_temp_specevent (#colNames#) values (#preservesinglequotes(colVals)#)
					</cfquery>
				</cfif>
			</cfloop>
			<cflocation url="BulkloadSpecimenEvent.cfm?action=validateFromFile">
		</cfoutput>
	</cfif>
	<cfif action is "validateFromFile">
		<cfquery name="guid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_specevent set status='guid not found'
			where guid NOT IN (select guid from flat)
		</cfquery>
		<cfquery name="SPECIMEN_EVENT_TYPE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_specevent set status='SPECIMEN_EVENT_TYPE not found'
			where SPECIMEN_EVENT_TYPE NOT IN (select SPECIMEN_EVENT_TYPE from CTSPECIMEN_EVENT_TYPE)
		</cfquery>
		<cfquery name="COLLECTING_SOURCE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_specevent set status='COLLECTING_SOURCE not found'
			where COLLECTING_SOURCE NOT IN (select COLLECTING_SOURCE from CTCOLLECTING_SOURCE)
		</cfquery>
	
	
	
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_specevent
		</cfquery>
		<cfloop query="data">
			<cfset s=''>
			<cfset checkEvent=true>
			<cfset checkLocality=true>
			<cfset l_collection_object_id = 0>
			<cfset l_collecting_event_id = 0>
			<cfset l_locality_id = 0>
			<cfset l_geog_auth_rec_id = 0>
	
			<cfquery name="getCatItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select nvl(collection_object_id,0) collection_object_id from flat where guid='#guid#'
			</cfquery>
			<cfset l_collection_object_id=getCatItem.collection_object_id>
			<cfif getCatItem.collection_object_id is 0>
				<cfset s=listappend(s,'guid not found',';')>
			</cfif>
			<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select is_iso8601('#ASSIGNED_DATE#') isdate from dual
			</cfquery>
			<cfif dd.isdate is not "valid">
				<cfset s=listappend(s,'ASSIGNED_DATE not a valid date',';')>
			</cfif>
			<cfif len(collecting_event_id) gt 0>
				<cfset checkEvent=false>
				<cfset checkLocality=false>
				<cfquery name="collecting_event" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
					select nvl(collecting_event_id,0) collecting_event_id from collecting_event where collecting_event_id=#collecting_event_id#
				</cfquery>
				<cfset l_collecting_event_id=collecting_event.collecting_event_id>
				<cfif collecting_event.collecting_event_id is 0>
					<cfset s=listappend(s,'not a valid collecting_event_id',';')>
				</cfif>
			</cfif>
			<cfif len(collecting_event_name) gt 0>
				<cfset checkEvent=false>
				<cfset checkLocality=false>
				<cfquery name="collecting_event" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
					select nvl(collecting_event_id,0) collecting_event_id from collecting_event where collecting_event_name='#collecting_event_name#'
				</cfquery>
				<cfset l_collecting_event_id=collecting_event.collecting_event_id>
				<cfif collecting_event.collecting_event_id is 0>
					<cfset s=listappend(s,'not a valid collecting_event_name',';')>
				</cfif>
			</cfif>
			<cfif len(LOCALITY_ID) gt 0>
				<cfset checkLocality=false>
				<cfquery name="LOCALITY" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
					select nvl(LOCALITY_ID,0) LOCALITY_ID from LOCALITY where LOCALITY_ID=#LOCALITY_ID#
				</cfquery>
				<cfset l_locality_id=LOCALITY.LOCALITY_ID>
				<cfif LOCALITY.LOCALITY_ID is 0>
					<cfset s=listappend(s,'not a valid LOCALITY_ID',';')>
				</cfif>
			</cfif>
			<cfif len(LOCALITY_NAME) gt 0>
				<cfset checkLocality=false>
				<cfquery name="LOCALITY" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
					selectnvl(LOCALITY_ID,0) LOCALITY_ID from LOCALITY where LOCALITY_NAME='#LOCALITY_NAME#'
				</cfquery>
				<cfset l_locality_id=LOCALITY.LOCALITY_ID>
				<cfif LOCALITY.LOCALITY_ID is 0>
					<cfset s=listappend(s,'not a valid LOCALITY_NAME',';')>
				</cfif>
			</cfif>
			<cfif checkEvent is true>
				<cfif len(VERBATIM_DATE) is 0>
					<cfset s=listappend(s,'VERBATIM_DATE is required',';')>
				</cfif>
				<cfif len(VERBATIM_LOCALITY) is 0>
					<cfset s=listappend(s,'VERBATIM_LOCALITY is required',';')>
				</cfif>
				<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
					select is_iso8601('#BEGAN_DATE#') isdate from dual
				</cfquery>
				<cfif dd.isdate is not "valid">
					<cfset s=listappend(s,'BEGAN_DATE is not a valid date',';')>
				</cfif>
				<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
					select is_iso8601('#ENDED_DATE#') isdate from dual
				</cfquery>
				<cfif dd.isdate is not "valid">
					<cfset s=listappend(s,'ENDED_DATE is not a valid date',';')>
				</cfif>
				<cfif len(ORIG_LAT_LONG_UNITS) gt 0>
					<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
						select count(*) c from ctORIG_LAT_LONG_UNITS where ORIG_LAT_LONG_UNITS='#ORIG_LAT_LONG_UNITS#'
					</cfquery>
					<cfif dd.c is not 1>
						<cfset s=listappend(s,'ORIG_LAT_LONG_UNITS is not valid',';')>
					</cfif>
					<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
						select count(*) c from ctDATUM where DATUM='#DATUM#'
					</cfquery>
					<cfif dd.c is not 1>
						<cfset s=listappend(s,'DATUM is not valid',';')>
					</cfif>
					<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
						select count(*) c from ctGEOREFERENCE_SOURCE where GEOREFERENCE_SOURCE='#GEOREFERENCE_SOURCE#'
					</cfquery>
					<cfif dd.c is not 1>
						<cfset s=listappend(s,'GEOREFERENCE_SOURCE is not valid',';')>
					</cfif>
					<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
						select count(*) c from ctGEOREFERENCE_PROTOCOL where GEOREFERENCE_PROTOCOL='#GEOREFERENCE_PROTOCOL#'
					</cfquery>
					<cfif dd.c is not 1>
						<cfset s=listappend(s,'GEOREFERENCE_PROTOCOL is not valid',';')>
					</cfif>
					<cfif ORIG_LAT_LONG_UNITS is "decimal degrees">
						<cfif DEC_LAT gt 90 or DEC_LAT lt -90 or DEC_LONG gt 180 or DEC_LONG lt -180>
							<cfset s=listappend(s,'coordinates not valid',';')>
						</cfif>
					<cfelseif orig_lat_long_units is 'deg. min. sec.'>
						<cfif LAT_DEG gt 90 or LAT_DEG lt 0 or
							LAT_MIN lt 0 or LAT_MIN gt 60 or
							LAT_SEC  lt 0 or LAT_SEC gt 60 or
							LONG_DEG gt 90 or LONG_DEG lt 0 or
							LONG_MIN lt 0 or LONG_MIN gt 60 or
							LONG_SEC  lt 0 or LONG_SEC gt 60 or
							(LAT_DIR is not "N" and LAT_DIR is not "S") or
							(LONG_DIR is not "W" and LONG_DIR is not "E")>
							<cfset s=listappend(s,'coordinates not valid',';')>
						</cfif>
					<cfelseif orig_lat_long_units is 'degrees dec. minutes'>
						<cfif LAT_DEG gt 90 or LAT_DEG lt 0 or
							DEC_LAT_MIN lt 0 or DEC_LAT_MIN gt 60 or
							LONG_DEG gt 90 or LONG_DEG lt 0 or
							DEC_LONG_MIN lt 0 or DEC_LONG_MIN gt 60 or
							(LAT_DIR is not "N" and LAT_DIR is not "S") or
							(LONG_DIR is not "W" and LONG_DIR is not "E")>
							<cfset s=listappend(s,'coordinates not valid',';')>
						</cfif>
					<cfelseif orig_lat_long_units is 'UTM'>
						<cfif not (isnumeric(UTM_EW) and isnumeric(UTM_NS))>
							<cfset s=listappend(s,'coordinates not valid',';')>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
			<cfif checkLocality is true>
				<cfif len(SPEC_LOCALITY) is 0>
					<cfset s=listappend(s,'SPEC_LOCALITY is required',';')>
				</cfif>
				<cfif len(ORIG_ELEV_UNITS) gt 0>
					<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
						select count(*) c from ctORIG_ELEV_UNITS where ORIG_ELEV_UNITS='#ORIG_ELEV_UNITS#'
					</cfquery>
					<cfif dd.c is not 1>
						<cfset s=listappend(s,'ORIG_ELEV_UNITS is not valid',';')>
					</cfif>
					<cfif len(MINIMUM_ELEVATION) is 0 or len(MAXIMUM_ELEVATION) is 0 or (not isnumeric(MINIMUM_ELEVATION))
						 or (not isnumeric(MAXIMUM_ELEVATION)) or (MINIMUM_ELEVATION gt MAXIMUM_ELEVATION)>
						<cfset s=listappend(s,'elevation is wonky',';')>
					</cfif>
				</cfif>
				<cfif len(DEPTH_UNITS) gt 0>
					<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
						select count(*) c from ctDEPTH_UNITS where DEPTH_UNITS='#DEPTH_UNITS#'
					</cfquery>
					<cfif dd.c is not 1>
						<cfset s=listappend(s,'DEPTH_UNITS is not valid',';')>
					</cfif>
					<cfif len(MIN_DEPTH) is 0 or len(MAX_DEPTH) is 0 or (not isnumeric(MIN_DEPTH))
						 or (not isnumeric(MAX_DEPTH)) or (MIN_DEPTH gt MAX_DEPTH)>
						<cfset s=listappend(s,'depth is wonky',';')>
					</cfif>
				</cfif>
				<cfif len(MAX_ERROR_UNITS) gt 0>
					<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
						select count(*) c from ctMAX_ERROR_UNITS where MAX_ERROR_UNITS='#DEPTH_UNITS#'
					</cfquery>
					<cfif dd.c is not 1>
						<cfset s=listappend(s,'MAX_ERROR_UNITS is not valid',';')>
					</cfif>
					<cfif len(MAX_ERROR_DISTANCE) is 0>
						<cfset s=listappend(s,'MAX_ERROR_DISTANCE is required when MAX_ERROR_UNITS is given',';')>
					</cfif>
				</cfif>
				<cfif len(GEOG_AUTH_REC_ID) gt 0>
					<cfquery name="GEOG_AUTH_REC" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
						select nvl(GEOG_AUTH_REC_ID,0) GEOG_AUTH_REC_ID from GEOG_AUTH_REC where GEOG_AUTH_REC_ID=#GEOG_AUTH_REC_ID#
					</cfquery>
					<cfset l_geog_auth_rec_id=GEOG_AUTH_REC.GEOG_AUTH_REC_ID>
					<cfif GEOG_AUTH_REC.GEOG_AUTH_REC_ID is 0>
						<cfset s=listappend(s,'GEOG_AUTH_REC_ID is not valid',';')>
					</cfif>
				<cfelseif len(HIGHER_GEOG) gt 0>
					<cfquery name="GEOG_AUTH_REC" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
						select nvl(GEOG_AUTH_REC_ID,0) GEOG_AUTH_REC_ID  from GEOG_AUTH_REC where HIGHER_GEOG='#HIGHER_GEOG#'
					</cfquery>
					<cfset l_geog_auth_rec_id=GEOG_AUTH_REC.GEOG_AUTH_REC_ID>
					<cfif GEOG_AUTH_REC.GEOG_AUTH_REC_ID is 0>
						<cfset s=listappend(s,'HIGHER_GEOG is not valid',';')>
					</cfif>
				<cfelse>
					<cfset s=listappend(s,'Either HIGHER_GEOG or GEOG_AUTH_REC_ID is required.',';')>
				</cfif>
			</cfif>
			<cfquery name="dd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update cf_temp_specevent set l_collection_object_id=#getCatItem.collection_object_id#, status='#s#' where key=#key#
			</cfquery>
		</cfloop>
		<cflocation url="BulkloadSpecimenEvent.cfm?action=beenValidated" addtoken="false">
	</cfif>
<!------------------------------------------------------------------------------------------------>	
	<cfif action is "beenValidated">
		<cfoutput>
		<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_specevent
		</cfquery>
		<cfquery name="willload" dbtype="query">
			select count(*) c from data where len(status) is 0
		</cfquery>
		<cfif willload.c is 0>
			<a href="BulkloadSpecimenEvent.cfm?action=load">continue to load</a>
		<cfelse>
			fix errors and reload
		</cfif>
		<cfset clist=listprepend(thecolumns,'status')>
		<table border>
			<tr>
				<cfloop list="#clist#" index="i">
					<th>#i#</th>
				</cfloop>
			</tr>
			<cfloop query="data">
				<tr>
					<cfloop list="#clist#" index="i">
						<td>#evaluate("data." & i)#</td>
					</cfloop>
				</tr>
			</cfloop>
		</table>
		</cfoutput>
	</cfif>
	<cfif action is "load">
		<cfoutput>
			<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from cf_temp_specevent
			</cfquery>
			<cfloop query="data">
				<cfif len(l_collecting_event_id) is 0>
					<!--- we'll have to find or build an event - see about locality ---->
					<cfif len(l_locality_id) is 0>
						<!--- we'll have to find or build a locality ---->
						<!--- coordinates? --->
						<cfif orig_lat_long_units is 'deg. min. sec.'>
							<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								select  dms_to_string ('#latdeg#','#latmin#','#latsec#','#latdir#','#longdeg#','#longmin#','#longsec#','#longdir#') vc from dual
							</cfquery>
							<cfset verbatimcoordinates=data.vc>
						<cfelseif orig_lat_long_units is 'degrees dec. minutes'>
							<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								select  dm_to_string ('#latdeg#','#dec_lat_min#','#latdir#','#longdeg#','#dec_long_min#''#longdir#') vc from dual
							</cfquery>
							<cfset verbatimcoordinates=data.vc>
						<cfelseif orig_lat_long_units is 'decimal degrees'>
							<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								select  dd_to_string ('#DEC_LAT#','#DEC_LONG#') vc from dual
							</cfquery>
							<cfset verbatimcoordinates=data.vc>
						<cfelseif orig_lat_long_units is 'UTM'>
							<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								select  utm_to_string ('#UTM_NS#','#UTM_EW#','#UTM_ZONE#') vc from dual
							</cfquery>
							<cfset verbatimcoordinates=data.vc>
						<cfelse>
							<cfset verbatimcoordinates=''>
						</cfif>
						<cfquery name="eLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							select nvl(min(locality.locality_id),-1)
				            FROM 
				            	locality
				            WHERE
				                geog_auth_rec_id = #l_geog_auth_rec_id# AND
				                NVL(MAXIMUM_ELEVATION,-1) = NVL(#maximum_elevation#,-1) AND
				            	NVL(MINIMUM_ELEVATION,-1) = NVL(#minimum_elevation#,-1) AND
				            	NVL(ORIG_ELEV_UNITS,'NULL') = NVL('#orig_elev_units#','NULL') AND
				            	NVL(MIN_DEPTH,-1) = nvl(#min_depth#,-1) AND
				            	NVL(MAX_DEPTH,-1) = nvl(#max_depth#,-1) AND
				            	NVL(SPEC_LOCALITY,'NULL') = NVL('#spec_locality#','NULL') AND
				            	NVL(LOCALITY_REMARKS,'NULL') = NVL('#locality_remarks#','NULL') AND
				            	NVL(DEPTH_UNITS,'NULL') = NVL('#depth_units#','NULL') AND
				            	NVL(dec_lat,-1) = nvl(#dec_lat#,-1) AND
				            	NVL(dec_long,-1) = nvl(#dec_long#,-1) AND
				            	locality_name IS NULL AND -- because we tested that above and will use it if it exists
				                locality_id not in (select locality_id from geology_attributes)
						</cfquery>
						<cfif eLoc.locality_id gt 0>
							cant find locality
							<cfset l_locality_id=eLoc.locality_id>
						<cfelse>
							<!--- make a locality ---->
							<cfquery name="nLocId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								select sq_locality_id.nextval nv from dual
							</cfquery>
							<cfset lid=nLocId.nv>
							<cfquery name="newLocality" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								INSERT INTO locality (
									LOCALITY_ID,
									GEOG_AUTH_REC_ID,
									MAXIMUM_ELEVATION,
									MINIMUM_ELEVATION,
									ORIG_ELEV_UNITS,
									SPEC_LOCALITY,
									LOCALITY_REMARKS,
									DEPTH_UNITS,
									MIN_DEPTH,
									MAX_DEPTH,
									DEC_LAT,
									DEC_LONG,
									MAX_ERROR_DISTANCE,
									MAX_ERROR_UNITS,
									DATUM,
									georeference_source,
									georeference_protocol,
									locality_name
								)  values (
									#lid#,
									#l_geog_auth_rec_id#,
									<cfif len(MAXIMUM_ELEVATION) gt 0>
										MAXIMUM_ELEVATION
									<cfelse>
										NULL
									</cfif>,
									<cfif len(MINIMUM_ELEVATION) gt 0>
										MINIMUM_ELEVATION
									<cfelse>
										NULL
									</cfif>,
									'#ORIG_ELEV_UNITS#',
									'#SPEC_LOCALITY#',
									'#LOCALITY_REMARKS#',
									'#DEPTH_UNITS#',
									<cfif len(MIN_DEPTH) gt 0>
										MIN_DEPTH
									<cfelse>
										NULL
									</cfif>,
									<cfif len(MAX_DEPTH) gt 0>
										MAX_DEPTH
									<cfelse>
										NULL
									</cfif>,
									<cfif len(DEC_LAT) gt 0>
										DEC_LAT
									<cfelse>
										NULL
									</cfif>,
									<cfif len(DEC_LONG) gt 0>
										DEC_LONG
									<cfelse>
										NULL
									</cfif>,
									<cfif len(MAX_ERROR_DISTANCE) gt 0>
										MAX_ERROR_DISTANCE
									<cfelse>
										NULL
									</cfif>,
									'#MAX_ERROR_UNITS#',
									'#DATUM#',
									'#georeference_source#',
									'#georeference_protocol#',
									'#locality_name#'
									from
										locality
									where
										locality_id=#locality_id#
								)
							</cfquery>
							<cfset l_locality_id=lid>
						</cfif>
					</cfif>
					<!--- we should have a locality_id here, so see if we have a collecting_event.---->
					<cfquery name="findEvent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">

						select 
				    	    nvl(MIN(collecting_event_id),-1) collecting_event_id
				    	from
				    	    collecting_event 
				    	where
				    	    locality_id = l_locality_id and
				    	    nvl(verbatim_date,'NULL') = nvl('#verbatim_date#','NULL') and
				    	    nvl(VERBATIM_LOCALITY,'NULL') = nvl('#VERBATIM_LOCALITY#','NULL') and
				    	    nvl(COLL_EVENT_REMARKS,'NULL') = nvl('#COLL_EVENT_REMARKS#','NULL') and
				    	    nvl(began_date,'NULL') = nvl('#began_date#','NULL') and
				    	    nvl(ended_date,'NULL') = nvl('#ended_date#','NULL') and
				    	    COLLECTING_EVENT_NAME IS NULL AND -- or we'd have found it at that check
				    	    nvl(verbatim_coordinates,'NULL') = nvl('#verbatimcoordinates#','NULL') and
				    	    nvl(DATUM,'NULL') = nvl('#DATUM#','NULL') and
				    	    nvl(ORIG_LAT_LONG_UNITS,'NULL') = nvl('#ORIG_LAT_LONG_UNITS#','NULL')
    	    		</cfquery>
    				<cfif findEvent.collecting_event_id gt 0>
						<cfset l_collecting_event_id=findEvent.collecting_event_id>
					<cfelse>
						<!---- make a collecting event ---->
						<cfquery name="nCevId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							select sq_collecting_event_id.nextval nv from dual
						</cfquery>
						<cfset l_collecting_event_id=nCevId.nv>
						<cfquery name="makeEvent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				    		insert into collecting_event (
				    			collecting_event_id,
				    			locality_id,
				    			verbatim_date,
				    			VERBATIM_LOCALITY,
				    			began_date,
				    			ended_date,
				    			coll_event_remarks,
				    			LAT_DEG,
				    			DEC_LAT_MIN,
				    			LAT_MIN,
				    			LAT_SEC,
				    			LAT_DIR,
				    			LONG_DEG,
				    			DEC_LONG_MIN,
				    			LONG_MIN,
				    			LONG_SEC,
				    			LONG_DIR,
				    			DEC_LAT,
				    			DEC_LONG,
				    			DATUM,
				    			UTM_ZONE,
				    			UTM_EW,
				    			UTM_NS,
				    			ORIG_LAT_LONG_UNITS
				    		) values (
				    			#l_collecting_event_id#',
				    			#l_locality_id#',
				    			'#verbatim_date#',
				    			'#VERBATIM_LOCALITY#',
				    			'#began_date#',			
				    			'#ended_date#',
				    			'#coll_event_remarks#',
				    			<cfif len(LATDEG) gt 0>
									LATDEG
								<cfelse>
									NULL
								</cfif>,
				    			<cfif len(DEC_LAT_MIN) gt 0>
									DEC_LAT_MIN
								<cfelse>
									NULL
								</cfif>,
				    			<cfif len(LATMIN) gt 0>
									LATMIN
								<cfelse>
									NULL
								</cfif>,
				    			<cfif len(LATSEC) gt 0>
									LATSEC
								<cfelse>
									NULL
								</cfif>,
				    			'#LATDIR#',
				    			<cfif len(LONGDEG) gt 0>
									LONGDEG
								<cfelse>
									NULL
								</cfif>,
				    			<cfif len(DEC_LONG_MIN) gt 0>
									DEC_LONG_MIN
								<cfelse>
									NULL
								</cfif>,
				    			<cfif len(LONGMIN) gt 0>
									LONGMIN
								<cfelse>
									NULL
								</cfif>,
				    			<cfif len(LONGSEC) gt 0>
									LONGSEC
								<cfelse>
									NULL
								</cfif>,
				    			'#LONGDIR#',
				    			<cfif len(DEC_LAT) gt 0>
									DEC_LAT
								<cfelse>
									NULL
								</cfif>,
				    			<cfif len(DEC_LONG) gt 0>
									DEC_LONG
								<cfelse>
									NULL
								</cfif>,
				    			'#DATUM#',
				    			'#UTM_ZONE#',
				    			<cfif len(UTM_EW) gt 0>
									UTM_EW
								<cfelse>
									NULL
								</cfif>,
				    			<cfif len(UTM_NS) gt 0>
									UTM_NS
								<cfelse>
									NULL
								</cfif>,
				    			'#ORIG_LAT_LONG_UNITS#'
				    		)
    					</cfquery>
					</cfif>
				</cfif>
				<!--- at this point, we should have a collecting event ID, so make the specimen_event --->
				<cfquery name="makeSpecEvent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO specimen_event (
			            COLLECTION_OBJECT_ID,
			            COLLECTING_EVENT_ID,
			            ASSIGNED_BY_AGENT_ID,
			            ASSIGNED_DATE,
			            SPECIMEN_EVENT_REMARK,
			            SPECIMEN_EVENT_TYPE,
			            COLLECTING_METHOD,
			            COLLECTING_SOURCE,
			            VERIFICATIONSTATUS,
			            HABITAT
			        ) VALUES (
			            l_collection_object_id,
			            l_collecting_event_id,
			            (SELECT agent_id FROM agent_name WHERE agent_name='#ASSIGNED_BY_AGENT#'),
			            '#event_assigned_date#',
			            '#SPECIMEN_EVENT_REMARK#',
			            '#SPECIMEN_EVENT_TYPE#',
			            '#COLLECTING_METHOD#',
			            '#COLLECTING_SOURCE#',
			            '#VERIFICATIONSTATUS#',
			            '#HABITAT#'
			        )
				</cfquery>
				<br>				inserted for #l_collection_object_id#
			</cfloop>
		</cfoutput>
	</cfif>