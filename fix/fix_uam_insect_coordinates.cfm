<cfabort>
uam@ARCTOSPROD> desc uaminsfix
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 CAT_NUM							   NOT NULL VARCHAR2(40)
 ORIG_LAT_LONG_UNITS							    VARCHAR2(20)
 DEC_LAT								    NUMBER
 DEC_LONG								    NUMBER
 DATUM									    VARCHAR2(55)
 LAT_LONG_REF_SOURCE							    VARCHAR2(4000)
 MAX_ERROR_DISTANCE							    NUMBER
 MAX_ERROR_UNITS							    VARCHAR2(30)
 GEOREFMETHOD								    VARCHAR2(255)
 DETERMINED_BY_AGENT							    VARCHAR2(255)
 DETERMINED_DATE							    DATE
 LAT_LONG_REMARKS							    VARCHAR2(4000)
 VERIFICATIONSTATUS							    VARCHAR2(40)
 INSTITUTION_ACRONYM						   NOT NULL VARCHAR2(20)
 LOCALITY_ID								    NUMBER
 DECLAT 								    NUMBER

<cfoutput>
<cfquery name="d" datasource="uam_god">
 select
	DEC_LAT,
	DEC_LONG,
	DATUM,
	LAT_LONG_REF_SOURCE,
	MAX_ERROR_DISTANCE,
	MAX_ERROR_UNITS,
	GEOREFMETHOD,
	DETERMINED_BY_AGENT,
	DETERMINED_DATE,
	LAT_LONG_REMARKS,
	VERIFICATIONSTATUS,
	LOCALITY_ID
from uaminsfix
group by
	DEC_LAT,
	DEC_LONG,
	DATUM,
	LAT_LONG_REF_SOURCE,
	MAX_ERROR_DISTANCE,
	MAX_ERROR_UNITS,
	GEOREFMETHOD,
	DETERMINED_BY_AGENT,
	DETERMINED_DATE,
	LAT_LONG_REMARKS,
	VERIFICATIONSTATUS,
	LOCALITY_ID
</cfquery>
<cftransaction>
<cfloop query="d">
	<hr>LOCALITY_ID=#LOCALITY_ID#
	<br>DEC_LAT=#DEC_LAT#
	<br>DEC_LONG=#DEC_LONG#
	<br>DATUM=#DATUM#
	<br>LAT_LONG_REF_SOURCE=#LAT_LONG_REF_SOURCE#
	<br>MAX_ERROR_DISTANCE=#MAX_ERROR_DISTANCE#
	<br>MAX_ERROR_UNITS=#MAX_ERROR_UNITS#
	<br>GEOREFMETHOD=#GEOREFMETHOD#
	<br>DETERMINED_BY_AGENT=#DETERMINED_BY_AGENT#
	<br>DETERMINED_DATE=#DETERMINED_DATE#
	<br>LAT_LONG_REMARKS=#LAT_LONG_REMARKS#
	<br>VERIFICATIONSTATUS=#VERIFICATIONSTATUS#
		<cfquery name="l" datasource="uam_god">
			select * from locality where locality_id=#locality_id#
		</cfquery>
		<cfdump var=#l#>
		<cfloop query="l">
			<cfif len(dec_lat) gt 0>
				<br>locality has declat
			</cfif>
		</cfloop>

		<cfif len(l.locality_remarks) gt 0>
			<cfif len(LAT_LONG_REMARKS) gt 0>
				<cfset lrem=l.locality_remarks & '; ' & LAT_LONG_REMARKS>
			<cfelse>
				<cfset lrem=l.locality_remarks>
			</cfif>
		<cfelse>
			<cfset lrem=LAT_LONG_REMARKS>
		</cfif>

		<br>
				<cfquery name="uploc" datasource="uam_god">
			update locality set
						DEC_LAT=#DEC_LAT#,
						DEC_LONG=#DEC_LONG#,
						DATUM='#DATUM#',
						LOCALITY_REMARKS='#lrem#',
			GEOREFERENCE_SOURCE='not recorded',
			GEOREFERENCE_PROTOCOL='#GEOREFMETHOD#',
			MAX_ERROR_DISTANCE=#MAX_ERROR_DISTANCE#,
			MAX_ERROR_UNITS='#MAX_ERROR_UNITS#'
				where locality_id=#locality_id#
</cfquery>

<br>

				<cfquery name="upce" datasource="uam_god">update collecting_event set
				DEC_LAT=#DEC_LAT#,
							DEC_LONG=#DEC_LONG#,
							DATUM='#DATUM#',
							ORIG_LAT_LONG_UNITS='decimal degrees'
						 where locality_id=#locality_id#
</cfquery>








			<cfquery name="se" datasource="uam_god">
				select * from specimen_event where
				collecting_event_id in (select collecting_event_id from collecting_event where locality_id=#locality_id#)
			</cfquery>

				<cfquery name="agnt" datasource="uam_god">
					select agent_id from agent_name where agent_name='#DETERMINED_BY_AGENT#'
				</cfquery>
				<cfif len(agnt.agent_id) is 0>
					<br>-----------------------#DETERMINED_BY_AGENT# nomatch
				</cfif>
			<cfloop query="se">
				<br>
					<cfquery name="upse" datasource="uam_god">
					update specimen_event set
				ASSIGNED_BY_AGENT_ID=#agnt.agent_id#,
				 ASSIGNED_DATE='#dateformat(d.DETERMINED_DATE,"yyyy-mm-dd")#',
				VERIFICATIONSTATUS='#d.VERIFICATIONSTATUS#'
				where specimen_event_id=#specimen_event_id#
</cfquery>
			</cfloop>

			<cfdump var=#se#>
	<!---------

DEC_LAT,
	DEC_LONG,
	DATUM,
	LAT_LONG_REF_SOURCE,
	MAX_ERROR_DISTANCE,
	MAX_ERROR_UNITS,
	GEOREFMETHOD,
	DETERMINED_BY_AGENT,
	DETERMINED_DATE,
	LAT_LONG_REMARKS,
	VERIFICATIONSTATUS,
	LOCALITY_ID



	<cfquery name="l" datasource="uam_god">
		update locality set
			DEC_LAT=#DEC_LAT#,
			DEC_LONG=#DEC_LONG#,
			DATUM='#DATUM#',
			LOCALITY_REMARKS='#lrem#',
GEOREFERENCE_SOURCE='not recorded',
GEOREFERENCE_PROTOCOL='#GEOREFMETHOD#',
MAX_ERROR_DISTANCE=#MAX_ERROR_DISTANCE#,
MAX_ERROR_UNITS='#MAX_ERROR_UNITS#'

uam@ARCTOSPROD> desc locality
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
 							    NUMBER
 							    VARCHAR2(30)
 DATUM									    VARCHAR2(255)
 LOCALITY_REMARKS							    VARCHAR2(4000)
 							    VARCHAR2(4000)
 							    VARCHAR2(255)
 LOCALITY_NAME								    VARCHAR2(255)
 S$ELEVATION								    NUMBER
 S$GEOGRAPHY								    VARCHAR2(4000)
 S$DEC_LAT								    NUMBER
 S$DEC_LONG								    NUMBER




		where locality_id=#locality_id#
	</cfquery>

	<cfdump var=#l#>

		<cfquery name="ce" datasource="uam_god">

				DEC_LAT=#DEC_LAT#,
				DEC_LONG=#DEC_LONG#,
				DATUM='#DATUM#'
				ORIG_LAT_LONG_UNITS='decimal degrees'
			 where locality_id=#locality_id#
		</cfquery>
		<cfdump var=#ce#>

		------------->
</cfloop>
</cftransaction>
</cfoutput>