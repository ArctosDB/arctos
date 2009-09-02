<!---
drop table cf_temp_georef;

create table cf_temp_georef (
	key NUMBER NOT NULL,
	status varchar2(4000),
	DETERMINED_BY_AGENT_ID number,
 	HigherGeography VARCHAR2(255) NOT NULL,
 	SpecLocality VARCHAR2(255) NOT NULL,
	Locality_ID number NOT NULL,
	Dec_Lat NUMBER(12,10),
	Dec_Long NUMBER(13,10),
	MAX_ERROR_DISTANCE number,
	MAX_ERROR_UNITS VARCHAR2(2),
	LAT_LONG_REMARKS VARCHAR2(255),
	DETERMINED_BY_AGENT VARCHAR2(255) NOT NULL,
	GEOREFMETHOD VARCHAR2(255) NOT NULL,
	ORIG_LAT_LONG_UNITS VARCHAR2(20) NOT NULL,
	DATUM VARCHAR2(55) NOT NULL,
	DETERMINED_DATE DATE NOT NULL,
	LAT_LONG_REF_SOURCE VARCHAR2(255) NOT NULL,
	EXTENT NUMBER(8,3),
	GPSACCURACY NUMBER(8,3),
	VERIFICATIONSTATUS VARCHAR2(40) NOT NULL,
	SPATIALFIT NUMBER(4,3)
);


create or replace public synonym cf_temp_georef for cf_temp_georef;
grant all on cf_temp_georef to manage_locality;
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
--->

<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
	HigherGeography, SpecLocality, and locality_id must all match Arctos data or this form will not work.
	<br>
	<a href="http://g-arctos.appspot.com/arctosdoc/lat_long.html">Help is here</a>
	
Step 1: Ensure that Media and objects media will relate to exist.
Step 2: Upload a comma-delimited text file (csv). 
Include column headings, spelled exactly as below. 
<br><span class="likeLink" onclick="document.getElementById('template').style.display='block';">view template</span>
	<div id="template" style="display:none;">
		<label for="t">Copy and save as a .csv file</label>
		<textarea rows="2" cols="80" id="t">HigherGeography,SpecLocality,Locality_ID,Dec_Lat,Dec_Long,MAX_ERROR_DISTANCE,MAX_ERROR_UNITS,LAT_LONG_REMARKS,DETERMINED_BY_AGENT,GEOREFMETHOD,ORIG_LAT_LONG_UNITS,DATUM,DETERMINED_DATE,LAT_LONG_REF_SOURCE,EXTENT,GPSACCURACY,VERIFICATIONSTATUS,SPATIALFIT</textarea>
	</div> 
<p></p>
Columns in <span style="color:red">red</span> are required; others are optional:
<ul>
	<li style="color:red">HigherGeography</li>
	<li style="color:red">SpecLocality</li>
	<li style="color:red">Locality_ID</li>
	<li style="color:red">Dec_Lat</li>
	<li style="color:red">Dec_Long</li>
	<li style="color:red">DETERMINED_BY_AGENT</li>
	<li style="color:red">GEOREFMETHOD<span class="infoLink" onclick="getCtDoc('ctGEOREFMETHOD','');">Define</span></li>
	<li style="color:red">ORIG_LAT_LONG_UNITS<span class="infoLink" onclick="getCtDoc('CTLAT_LONG_UNITS','');">Define</span></li>
	<li style="color:red">DATUM<span class="infoLink" onclick="getCtDoc('CTDATUM','');">Define</span></li>
	<li style="color:red">DETERMINED_DATE</li>
	<li style="color:red">LAT_LONG_REF_SOURCE</li>
	<li style="color:red">VERIFICATIONSTATUS<span class="infoLink" onclick="getCtDoc('CTVERIFICATIONSTATUS','');">Define</span></li>
	<li>MAX_ERROR_DISTANCE</li>
	<li>MAX_ERROR_UNITS<span class="infoLink" onclick="getCtDoc('CTLAT_LONG_ERROR_UNITS','');">Define</span></li>
	<li>LAT_LONG_REMARKS</li>
	<li>EXTENT</li>	
	<li>GPSACCURACY</li>	
	<li>SPATIALFIT</li>			 
</ul>

<cfform name="atts" method="post" enctype="multipart/form-data">
			<input type="hidden" name="Action" value="getFile">
			  <input type="file"
		   name="FiletoUpload"
		   size="45">
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
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into cf_temp_georef (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>

		</cfif>
	</cfloop>
</cfoutput>
<cflocation url="BulkloadGeoref.cfm?action=validate" addtoken="false">
</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->
<cfif #action# is "validate">
<cfoutput>
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from cf_temp_georef
</cfquery>
<cfquery name="ctGEOREFMETHOD" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select GEOREFMETHOD from ctGEOREFMETHOD
</cfquery>
<cfquery name="CTLAT_LONG_UNITS" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select ORIG_LAT_LONG_UNITS from CTLAT_LONG_UNITS
</cfquery>
<cfquery name="CTDATUM" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select DATUM from CTDATUM
</cfquery>
<cfquery name="CTVERIFICATIONSTATUS" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select VERIFICATIONSTATUS from CTVERIFICATIONSTATUS
</cfquery>
<cfquery name="CTLAT_LONG_ERROR_UNITS" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select LAT_LONG_ERROR_UNITS from CTLAT_LONG_ERROR_UNITS
</cfquery>
<cfloop query="d">
	<cfset ts="">
	<cfquery name="m" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) c from locality,geog_auth_rec where
		locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
		locality.locality_id=#Locality_ID# and
		locality.spec_locality='#SpecLocality#' and
		geog_auth_rec.higher_geog='#HigherGeography#'
	</cfquery>
	<cfif m.c neq 1>
		<cfset ts=listappend(ts,'no Locality_ID:SpecLocality:HigherGeography match',";")>
	</cfif>
	<cfquery name="a" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select agent_id from agent_name where agent_name='#DETERMINED_BY_AGENT#'
	</cfquery>
	<cfif a.recordcount is 1>
		<cfquery name="au" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cfquery name="l" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) c from lat_long where
		lat_long.locality_id=#Locality_ID#
	</cfquery>
	<cfif l.c neq 0>
		<cfset ts=listappend(ts,'georeference exists.',";")>
	</cfif>
	
	
	<cfif len(ts) gt 0>
		<cfquery name="au" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update cf_temp_georef set status='#ts#' where key=#key#
		</cfquery>
	<cfelse>
		<cfquery name="au" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update cf_temp_georef set status='spiffy' where key=#key#
		</cfquery>
	</cfif>
	
	
</cfloop>
<cfquery name="dp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select count(*) c from cf_temp_georef where status != 'spiffy'
</cfquery>
<cfif dp.c is 0>
	Looks like we made it. Take a look at everything below, then
	<a href="BulkloadGeoref.cfm?action=load">click to load</a>
<cfelse>
	fail. Something's busted.
</cfif>
<cfquery name="df" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			chr(9) & '<name>#HigherGeography#: #SpecLocality#</name>' & chr(10) & 
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
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			*
		from 
			cf_temp_georef
	</cfquery>
	<cftransaction>
		<cfloop query="d">
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
					to_date('#DETERMINED_DATE#'),
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
						#SPATIALFIT#,
					<cfelse>
						NULL,
					</cfif>
				)
			</cfquery>
		</cfloop>
	</cftransaction>
	Spiffy, all done.
</cfoutput>
</cfif>

<cfinclude template="/includes/_footer.cfm">
