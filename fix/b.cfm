
create table temp_g_m as select distinct WKT_MEDIA_ID from geog_auth_rec where WKT_MEDIA_ID is not null;
alter table temp_g_m add stuff varchar2(255);

	<cfquery name="one" datasource="uam_god" >
		select * from temp_g_m where stuff is null and rownum<1
	</cfquery>
	<cfdump var=#one#>
	<cfloop query="one">
			<cfquery name="m" datasource="uam_god" >
				select media_uri from media where media_id=#WKT_MEDIA_ID#
			</cfquery>
	<cfdump var=#m#>
			<cfhttp method="get" url="#m.media_uri#"></cfhttp>
			<cfdump var=#cfhttp#>

	</cfloop>

<cfabort>

 select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';
create table temp_l1 as select * from dlm.my_temp_cf;
select * from temp_l1;
create table temp_l2 as select * from dlm.my_temp_cf;
alter table temp_l2 add locality_id number;



UAM@ARCTOS> desc locality
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 LOCALITY_ID							   NOT NULL NUMBER
 GEOG_AUTH_REC_ID						   NOT NULL NUMBER
 SPEC_LOCALITY								    VARCHAR2(255)
 DEC_LAT								    NUMBER(12,10)
 DEC_LONG								    NUMBER(13,10)
 MINIMUM_ELEVATION							    NUMBER
 MAXIMUM_ELEVATION							    NUMBER
 ORIG_ELEV_UNITS							    VARCHAR2(30)
 MIN_DEPTH								    NUMBER
 MAX_DEPTH								    NUMBER
 DEPTH_UNITS								    VARCHAR2(30)
 MAX_ERROR_DISTANCE							    NUMBER
 MAX_ERROR_UNITS							    VARCHAR2(30)
 DATUM									    VARCHAR2(255)
 LOCALITY_REMARKS							    VARCHAR2(4000)
 GEOREFERENCE_SOURCE							    VARCHAR2(4000)
 GEOREFERENCE_PROTOCOL							    VARCHAR2(255)
 LOCALITY_NAME								    VARCHAR2(255)
 S$ELEVATION								    NUMBER
 S$GEOGRAPHY								    VARCHAR2(4000)
 S$DEC_LAT								    NUMBER
 S$DEC_LONG								    NUMBER
 S$LASTDATE								    DATE
 WKT_POLYGON								    CLOB
 LAST_DUP_CHECK_DATE							    DATE
 WKT_MEDIA_ID								    NUMBER






update temp_l2 set locality_id=(select locality_id from temp_l1 where temp_l1.NORTHING=temp_l2.NORTHING and   temp_l1.EASTING=temp_l2.EASTING and   temp_l1.ZONE=temp_l2.ZONE);
-- shit, duplicates

alter table temp_l1 add dec_lat number;
alter table temp_l1 add dec_long number;

begin
	for r in (select distinct NORTHING,EASTING,ZONE,LATITUDE,LONGITUDE from temp_l2) loop
		update temp_l1 set dec_lat=r.LATITUDE,dec_long=r.LONGITUDE where NORTHING=r.NORTHING and EASTING=r.EASTING and ZONE=r.ZONE;
	end loop;
end;
/


exec pause_maintenance('off');


begin
	for r in (select * from temp_l1) loop
		update locality set
			DEC_LAT=r.DEC_LAT,
			DEC_LONG=r.DEC_LONG,
			MAX_ERROR_DISTANCE=10,
			MAX_ERROR_UNITS='m',
			datum='World Geodetic System 1984',
			GEOREFERENCE_SOURCE='UTM converted with https://www.engineeringtoolbox.com/utm-latitude-longitude-d_1370.html',
			GEOREFERENCE_PROTOCOL='not recorded'
		where
			locality_id=r.locality_id;
	end loop;
end;
/



	<cfquery name="one" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from locality where locality_remarks like '%{"UTM":"%'
	</cfquery>



<cfoutput>
	<!-- first run -->
	<cfset csv="locality_id,northing, easting, zone">
	<!-- second run -->

		<cfset csv="northing, easting, zone">

<cfloop query="one">
	<hr>#locality_remarks#
	<cftry>
	<cfset lremk=mid(locality_remarks,find('{',locality_remarks,1),find('}',locality_remarks,1))>
	<br>lremk:#lremk#
	<cfset j=DeserializeJSON(lremk)>
	<cfset u=j.UTM>
	<cfset n=replace(listgetat(u,1," "),'N','')>
	<br>n:#n#
	<cfset e=replace(listgetat(u,2," "),'E','')>
	<br>e:#e#
	<cfset z=listgetat(u,4," ")>
	<br>z:#z#
	<!---- first run
	<cfset csv=csv & chr(10) & "#locality_id#,#n#,#e#,#z#">
	--->
	<cfset csv=csv & chr(10) & "#n#,#e#,#z#">
	<cfcatch><p>----------------------------------------------------------------------FAIL-----------------------------------------------------------</p></cfcatch>
</cftry>

</cfloop>
<textarea>#csv#</textarea>

<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>
<p>.</p>

</cfoutput>
