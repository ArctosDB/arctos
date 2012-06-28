<!---
drop table cf_temp_place;

create table cf_temp_place (
	key NUMBER NOT NULL,
	status varchar2(4000),
	higher_geog varchar2(255),
	geog_auth_rec_id number,
	action varchar2(255),
	guid_prefix,
	other_id_type,
	other_id_num,
	collection_object_id NUMBER,
    collecting_event_id NUMBER,
    assigned_by_agent_id NUMBER,
	event_assigned_by_agent varchar2(255),
    assigned_date DATE NOT NULL,
    specimen_event_remark VARCHAR2(4000),
    specimen_event_type VARCHAR2(60),
    COLLECTING_METHOD VARCHAR2(255),
    COLLECTING_SOURCE VARCHAR2(60),
    VERIFICATIONSTATUS VARCHAR2(60),
    habitat  VARCHAR2(4000)
	LOCALITY_ID NUMBER,
    VERBATIM_DATE VARCHAR2(60),
    VERBATIM_LOCALITY VARCHAR2(4000),
    COLL_EVENT_REMARKS VARCHAR2(4000),
    BEGAN_DATE VARCHAR2(22),
    ENDED_DATE VARCHAR2(22),
    collecting_event_name VARCHAR2(255),
    LAT_DEG NUMBER,
    DEC_LAT_MIN NUMBER(8,6),
    LAT_MIN NUMBER,
    LAT_SEC NUMBER(8,6),
    LAT_DIR CHAR(1),
    LONG_DEG NUMBER,
    DEC_LONG_MIN NUMBER(10,8),
    LONG_MIN NUMBER,
    LONG_SEC NUMBER(8,6),
    LONG_DIR CHAR(1),
    DEC_LAT NUMBER(12,10),
    DEC_LONG  NUMBER(13,10),
    DATUM VARCHAR2(55),
    UTM_ZONE VARCHAR2(3),
    UTM_EW NUMBER,
    UTM_NS NUMBER,
    ORIG_LAT_LONG_UNITS VARCHAR2(20),
	SPEC_LOCALITY VARCHAR2(255),
    MINIMUM_ELEVATION NUMBER,
    MAXIMUM_ELEVATION NUMBER,
    ORIG_ELEV_UNITS VARCHAR2(30),
    MIN_DEPTH NUMBER,
    MAX_DEPTH NUMBER,
    DEPTH_UNITS VARCHAR2(30),
    MAX_ERROR_DISTANCE NUMBER,
    MAX_ERROR_UNITS VARCHAR2(30),
    LOCALITY_REMARKS VARCHAR2(4000),
    georeference_source VARCHAR2(4000),
    georeference_protocol VARCHAR2(255),
    locality_name VARCHAR2(255)
);




create or replace public synonym cf_temp_place for cf_temp_place;
grant all on cf_temp_place to manage_locality;
grant select on cf_temp_place to public;

CREATE OR REPLACE TRIGGER cf_temp_place_key                                         
 before insert  ON cf_temp_place  
 for each row 
    begin     
    	if :NEW.key is null then                                                                                      
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;                                
    end;                                                                                            
/
sho err
--->
<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">

	
<br><span class="likeLink" onclick="document.getElementById('template').style.display='block';">view template</span>
	<div id="template" style="display:none;">
		<label for="t">Copy and save as a .csv file</label>
		<textarea rows="2" cols="80" id="t">higher_geog,action,guid_prefix,other_id_type,other_id_num,event_assigned_by_agent,assigned_date,specimen_event_remark,specimen_event_type,COLLECTING_METHOD,COLLECTING_SOURCE,VERIFICATIONSTATUS,habitat,VERBATIM_DATE,VERBATIM_LOCALITY,COLL_EVENT_REMARKS,BEGAN_DATE,ENDED_DATE,collecting_event_name,LAT_DEG,DEC_LAT_MIN,LAT_MIN,LAT_SEC,LAT_DIR,LONG_DEG,DEC_LONG_MIN,LONG_MIN,LONG_SEC,LONG_DIR,DEC_LAT,DEC_LONG,DATUM,UTM_ZONE,UTM_EW,UTM_NS,ORIG_LAT_LONG_UNITS,SPEC_LOCALITY,MINIMUM_ELEVATION,MAXIMUM_ELEVATION,ORIG_ELEV_UNITS,MIN_DEPTH,MAX_DEPTH,DEPTH_UNITS, MAX_ERROR_DISTANCE,MAX_ERROR_UNITS,LOCALITY_REMARKS,georeference_source,georeference_protocol,locality_name</textarea>
	</div> 
<p>
	Action MODIFY_LOCALITY will work only if there is one "accepted place of collection" locality that is not
	used for "verified by %" verificationstatus or by collections to which you do not have access. Useful for eg, adding georeference.
</p>

<table border>
	<tr>
		<th>Column</th>
		<th>RequiredWhen</th>
		<th>docs</th>
	</tr>
	<tr>
		<td>higher_geog</td>
		<td>locality_name or collecting_event_name not given</td>
		<td></td>
	</tr>
	<tr>
		<td>action</td>
		<td>always</td>
		<td>one of (MODIFY_LOCALITY)</td>
	</tr>
	<tr>
		<td>guid_prefix</td>
		<td>always</td>
		<td></td>
	</tr>
	<tr>
		<td>other_id_type</td>
		<td>always</td>
		<td></td>
	</tr>
	<tr>
		<td>other_id_num</td>
		<td>always</td>
		<td></td>
	</tr>
	<tr>
		<td>event_assigned_by_agent</td>
		<td>action one on (ADD_LOCALITY)</td>
		<td></td>
	</tr>
	<tr>
		<td>assigned_date</td>
		<td>action one on (ADD_LOCALITY)</td>
		<td></td>
	</tr>
	<tr>
		<td>specimen_event_remark</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>specimen_event_type</td>
		<td>action one on (ADD_LOCALITY)</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>COLLECTING_METHOD</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>COLLECTING_SOURCE</td>
		<td>action one on (ADD_LOCALITY)</td>
		<td></td>
	</tr>
	<tr>
		<td>VERIFICATIONSTATUS</td>
		<td>action one on (ADD_LOCALITY)</td>
		<td></td>
	</tr>
	<tr>
		<td>habitat</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>VERBATIM_DATE</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>VERBATIM_LOCALITY</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>COLL_EVENT_REMARKS</td>
		<td></td>
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
		<td>collecting_event_name</td>
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
		<td>georeference_source</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>georeference_protocol</td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>locality_name</td>
		<td></td>
		<td></td>
	</tr>
</table>





<cfform name="atts" method="post" enctype="multipart/form-data">
			<input type="hidden" name="Action" value="getFile">
			  <input type="file"
		   name="FiletoUpload"
		   size="45" onchange="checkCSV(this);">
			 <input type="submit" value="Upload this file"
		class="savBtn"
		onmouseover="this.className='savBtn btnhov'" 
		onmouseout="this.className='savBtn'">
  </cfform>

</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->

<!------------------------------------------------------->
<cfif #action# is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_georef
	</cfquery>
	
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset numberOfColumns = ArrayLen(arrResult[1])>
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				 <cfset numColsRec = ArrayLen(arrResult[o])>
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
			<cfif numColsRec lt numberOfColumns>
				<cfset missingNumber = numberOfColumns - numColsRec>
				<cfloop from="1" to="#missingNumber#" index="c">
					<cfset colVals = "#colVals#,''">
				</cfloop>
			</cfif>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into cf_temp_georef (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>

		</cfif>
	</cfloop>
</cfoutput>
<cflocation url="BulkloadGeoref.cfm?action=validate" addtoken="false">
</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->
<cfif action is "validate">
<cfoutput>
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from cf_temp_georef
</cfquery>
<cfquery name="ctGEOREFMETHOD" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select GEOREFMETHOD from ctGEOREFMETHOD
</cfquery>
<cfquery name="CTLAT_LONG_UNITS" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select ORIG_LAT_LONG_UNITS from CTLAT_LONG_UNITS
</cfquery>
<cfquery name="CTDATUM" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select DATUM from CTDATUM
</cfquery>
<cfquery name="CTVERIFICATIONSTATUS" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select VERIFICATIONSTATUS from CTVERIFICATIONSTATUS
</cfquery>
<cfquery name="CTLAT_LONG_ERROR_UNITS" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select LAT_LONG_ERROR_UNITS from CTLAT_LONG_ERROR_UNITS
</cfquery>
<cfloop query="d">
	<cfset ts="">
	<cfset sql="select spec_locality,higher_geog,locality.locality_id from locality,geog_auth_rec where
		locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
		locality.locality_id=#Locality_ID# and
		trim(geog_auth_rec.higher_geog)='#trim(HigherGeography)#' and
		 trim(locality.spec_locality)='#trim(escapeQuotes(SpecLocality))#'">
	<cfquery name="m" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfif len(m.locality_id) is 0>
		<cfset ts=listappend(ts,'no Locality_ID:SpecLocality:HigherGeography match',";")>
		<cfquery name="fail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select 
				spec_locality,higher_geog
			from locality,geog_auth_rec where
				locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
				locality.locality_id=#Locality_ID#
		</cfquery>
		<cfif trim(SpecLocality) is not fail.spec_locality>
			<label>Locality Fail: ID=#locality_id#</label>
			<cfset yl=replace(trim(SpecLocality)," ","{space}","all")>
			<cfset al=replace(fail.spec_locality," ","{space}","all")>
			<table border>
				<tr>
					<td>yours:</td>
					<td>#yl#</td>
				</tr>
				<tr>
					<td>arctos:</td>
					<td>#al#</td>
				</tr>
			</table>
		</cfif>
		<cfif trim(HigherGeography) is not fail.higher_geog>
			<label>Geography Fail: ID=#locality_id#</label>
			<cfset yg=replace(trim(HigherGeography)," ","{space}","all")>
			<cfset ag=replace(fail.higher_geog," ","{space}","all")>
			<table border>
				<tr>
					<td>yours:</td>
					<td>#yg#</td>
				</tr>
				<tr>
					<td>arctos:</td>
					<td>#ag#</td>
				</tr>
			</table>
		</cfif>
	</cfif>
	<cfquery name="a" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select agent_id from agent_name where agent_name='#DETERMINED_BY_AGENT#'
	</cfquery>
	<cfif a.recordcount is 1>
		<cfquery name="au" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_georef set DETERMINED_BY_AGENT_ID=#a.agent_id# where key=#key#
		</cfquery>
	<cfelse>
		<cfset ts=listappend(ts,'bad agent match',";")>
	</cfif>
	<cfif not listfind(valuelist(ctGEOREFMETHOD.GEOREFMETHOD),GEOREFMETHOD)>
		<cfset ts=listappend(ts,'bad GEOREFMETHOD',";")>
	</cfif>
	<cfif not listfind(valuelist(CTLAT_LONG_UNITS.ORIG_LAT_LONG_UNITS),ORIG_LAT_LONG_UNITS)>
		<cfset ts=listappend(ts,'bad ORIG_LAT_LONG_UNITS',";")>
	</cfif>
	<cfif not listfind(valuelist(CTDATUM.DATUM),DATUM)>
		<cfset ts=listappend(ts,'bad DATUM',";")>
	</cfif>
	<cfif not listfind(valuelist(CTVERIFICATIONSTATUS.VERIFICATIONSTATUS),VERIFICATIONSTATUS)>
		<cfset ts=listappend(ts,'bad VERIFICATIONSTATUS',";")>
	</cfif>
	<cfif not listfind(valuelist(CTLAT_LONG_ERROR_UNITS.LAT_LONG_ERROR_UNITS),MAX_ERROR_UNITS)>
		<cfset ts=listappend(ts,'bad MAX_ERROR_UNITS',";")>
	</cfif>
	<cfquery name="l" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from lat_long where
		lat_long.locality_id=#Locality_ID#
	</cfquery>
	<cfif l.c neq 0>
		<cfset ts=listappend(ts,'georeference exists.',";")>
	</cfif>
	
	
	<cfif len(ts) gt 0>
		<cfquery name="au" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_georef set status='#ts#' where key=#key#
		</cfquery>
	<cfelse>
		<cfquery name="au" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_georef set status='spiffy' where key=#key#
		</cfquery>
	</cfif>
	
	
</cfloop>
<cfquery name="dp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select count(*) c from cf_temp_georef where status != 'spiffy'
</cfquery>
<cfif dp.c is 0>
	Looks like we made it. Take a look at everything below, then
	<a href="BulkloadGeoref.cfm?action=load">click to load</a>
<cfelse>
	fail. Something's busted.
</cfif>
<cfquery name="df" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from cf_temp_georef
</cfquery>
<cfset internalPath="#Application.webDirectory#/temp/">
<cfset externalPath="#Application.ServerRootUrl#/temp/">
<cfset dlFile = "BulkloadGeoref.kml">
<cfset variables.fileName="#internalPath##dlFile#">
<cfset variables.encoding="UTF-8">
<cfscript>
	variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
	kml='<?xml version="1.0" encoding="UTF-8"?>' & chr(10) & 
	 	'<kml xmlns="http://earth.google.com/kml/2.2">' & chr(10) & 
	 	chr(9) & '<Document>' & chr(10) & 
	 	chr(9) & chr(9) & '<name>Localities</name>' & chr(10) & 
	 	chr(9) & chr(9) & '<open>1</open>' & chr(10) & 
	 	chr(9) & chr(9) & '<Style id="green-star">' & chr(10) & 
	 	chr(9) & chr(9) & chr(9) & '<IconStyle>' & chr(10) & 
	 	chr(9) & chr(9) & chr(9) & chr(9) & '<Icon>' & chr(10) & 
	 	chr(9) & chr(9) & chr(9) & chr(9) & chr(9) & '<href>http://maps.google.com/mapfiles/kml/paddle/grn-stars.png</href>' & chr(10) & 
	 	chr(9) & chr(9) & chr(9) & chr(9) & '</Icon>' & chr(10) & 
	 	chr(9) & chr(9) & chr(9) & '</IconStyle>' & chr(10) & 
	 	chr(9) & chr(9) & '</Style>';
	variables.joFileWriter.writeLine(kml);
</cfscript>
<cfloop query="df">
	<cfset cdata='<![CDATA[Datum: #datum#<br/>Error: #max_error_distance# #max_error_units#<br/><p><a href="#Application.ServerRootUrl#/editLocality.cfm?locality_id=#locality_id#">Edit Locality</a></p>]]>'>
	<cfscript>
		kml='<Placemark>'  & chr(10) & 
			chr(9) & '<name>#HigherGeography#: #replace(SpecLocality,"&","&amp;","all")#</name>' & chr(10) & 
			chr(9) & '<visibility>1</visibility>' & chr(10) & 
			chr(9) & '<description>' & chr(10) & 
			chr(9) & chr(9) & '#cdata#' & chr(10) & 
			chr(9) & '</description>' & chr(10) & 
			chr(9) & '<Point>' & chr(10) & 
			chr(9) & chr(9) & '<coordinates>#dec_long#,#dec_lat#</coordinates>' & chr(10) & 
			chr(9) & '</Point>' & chr(10) & 
			chr(9) & '<styleUrl>##green-star</styleUrl>' & chr(10) & 
			'</Placemark>';
		variables.joFileWriter.writeLine(kml);
	</cfscript>
</cfloop>		
	<cfscript>
		kml='</Document></kml>';
		variables.joFileWriter.writeLine(kml);	
		variables.joFileWriter.close();
	</cfscript>
		<p>
		<a href="http://maps.google.com/maps?q=#externalPath##dlFile#?r=#randRange(1,10000)#">map it</a>
		</p>
Data:
<cfdump var=#df#>
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "load">
<cfoutput>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select 
			*
		from 
			cf_temp_georef
	</cfquery>
	<cftransaction>
		<cfloop query="d">
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into lat_long (
					LAT_LONG_ID,
					LOCALITY_ID,
					DEC_LAT,
					DEC_LONG,
					DATUM,
					ORIG_LAT_LONG_UNITS,
					DETERMINED_BY_AGENT_ID,
					DETERMINED_DATE,
					LAT_LONG_REF_SOURCE,
					LAT_LONG_REMARKS,
					MAX_ERROR_DISTANCE,
					MAX_ERROR_UNITS,
					ACCEPTED_LAT_LONG_FG,
					EXTENT,
					GPSACCURACY,
					GEOREFMETHOD,
					VERIFICATIONSTATUS,
					SPATIALFIT
				) values (
					sq_lat_long_id.nextval,
					#Locality_ID#,
					#Dec_Lat#,
					#Dec_Long#,
					'#DATUM#',
					'#ORIG_LAT_LONG_UNITS#',
					#DETERMINED_BY_AGENT_ID#,
					'#dateformat(DETERMINED_DATE,'yyyy-mm-dd')#',
					'#LAT_LONG_REF_SOURCE#',
					'#LAT_LONG_REMARKS#',
					<cfif len(MAX_ERROR_DISTANCE) gt 0>
						#MAX_ERROR_DISTANCE#,
					<cfelse>
						NULL,
					</cfif>
					'#MAX_ERROR_UNITS#',
					1,
					<cfif len(EXTENT) gt 0>
						#EXTENT#,
					<cfelse>
						NULL,
					</cfif>
					<cfif len(GPSACCURACY) gt 0>
						#GPSACCURACY#,
					<cfelse>
						NULL,
					</cfif>
					'#GEOREFMETHOD#',
					'#VERIFICATIONSTATUS#',
					<cfif len(SPATIALFIT) gt 0>
						#SPATIALFIT#
					<cfelse>
						NULL
					</cfif>
				)
			</cfquery>
		</cfloop>
	</cftransaction>
	Spiffy, all done.
</cfoutput>
</cfif>

<cfinclude template="/includes/_footer.cfm">
