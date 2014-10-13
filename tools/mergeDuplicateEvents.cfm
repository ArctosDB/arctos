<cfinclude template="/includes/_header.cfm">
<cfif not isdefined("locality_id") or len(locality_id) is 0>
	need a locality_id to proceed<cfabort>
</cfif>
<cfoutput>
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from collecting_event where locality_id=#locality_id#
</cfquery>

<cfdump var=#data#>
<cfquery name="dups" dbtype="query">
	select
		VERBATIM_DATE,
		VERBATIM_LOCALITY,
		COLL_EVENT_REMARKS,
		BEGAN_DATE,
		ENDED_DATE,
		VERBATIM_COORDINATES,
		COLLECTING_EVENT_NAME,
		DATUM
	from
		data
	group by
		VERBATIM_DATE,
		VERBATIM_LOCALITY,
		COLL_EVENT_REMARKS,
		BEGAN_DATE,
		ENDED_DATE,
		VERBATIM_COORDINATES,
		COLLECTING_EVENT_NAME,
		DATUM
	having
		count(*) > 1
</cfquery>
<cfdump var=#dups#>

<cfif dups.recordcount is 0>
	No dups detected - try merging localities first
<cfelse>
	<cfloop query="dups">
		<cfquery name="thisun" dbtype="query">
			select * from data where
			<cfif len(VERBATIM_DATE) gt 0>
				VERBATIM_DATE='#VERBATIM_DATE#' and
			<cfelse>
				len(VERBATIM_DATE) is 0 and
			</cfif>
			<cfif len(VERBATIM_LOCALITY) gt 0>
				VERBATIM_LOCALITY='#VERBATIM_LOCALITY#' and
			<cfelse>
				len(VERBATIM_LOCALITY) is 0 and
			</cfif>
			<cfif len(COLL_EVENT_REMARKS) gt 0>
				COLL_EVENT_REMARKS='#COLL_EVENT_REMARKS#' and
			<cfelse>
				COLL_EVENT_REMARKS is null and
			</cfif>
			<cfif len(BEGAN_DATE) gt 0>
				BEGAN_DATE='#BEGAN_DATE#' and
			<cfelse>
				len(BEGAN_DATE) is 0 and
			</cfif>
			<cfif len(ENDED_DATE) gt 0>
				ENDED_DATE='#ENDED_DATE#' and
			<cfelse>
				len(ENDED_DATE) is 0 and
			</cfif>
			<cfif len(VERBATIM_COORDINATES) gt 0>
				VERBATIM_COORDINATES='#VERBATIM_COORDINATES#' and
			<cfelse>
				len(VERBATIM_COORDINATES) is 0 and
			</cfif>
			<cfif len(COLLECTING_EVENT_NAME) gt 0>
				COLLECTING_EVENT_NAME='#COLLECTING_EVENT_NAME#' and
			<cfelse>
				len(COLLECTING_EVENT_NAME) is 0 and
			</cfif>
			<cfif len(DATUM) gt 0>
				DATUM='#DATUM#'
			<cfelse>
				len(DATUM) is 0 
			</cfif>
		</cfquery>
		<cfdump var=#thisun#>
		
	</cfloop>


 COLLECTING_EVENT_ID						   NOT NULL NUMBER
 LOCALITY_ID							   NOT NULL NUMBER
 VERBATIM_DATE								    VARCHAR2(60)
 VERBATIM_LOCALITY							    VARCHAR2(4000)
 COLL_EVENT_REMARKS							    VARCHAR2(4000)
 BEGAN_DATE								    VARCHAR2(22)
 ENDED_DATE								    VARCHAR2(22)
 VERBATIM_COORDINATES							    VARCHAR2(255)
 COLLECTING_EVENT_NAME							    VARCHAR2(255)
 LAT_DEG								    NUMBER
 DEC_LAT_MIN								    NUMBER(8,6)
 LAT_MIN								    NUMBER
 LAT_SEC								    NUMBER(8,6)
 LAT_DIR								    CHAR(1)
 LONG_DEG								    NUMBER
 DEC_LONG_MIN								    NUMBER(10,8)
 LONG_MIN								    NUMBER
 LONG_SEC								    NUMBER(8,6)
 LONG_DIR								    CHAR(1)
 DEC_LAT								    NUMBER(12,10)
 DEC_LONG								    NUMBER(13,10)
 DATUM									    VARCHAR2(55)
 UTM_ZONE								    VARCHAR2(3)
 UTM_EW 								    NUMBER
 UTM_NS 								    NUMBER
 ORIG_LAT_LONG_UNITS							    VARCHAR2(20)
 CACLULATED_DLAT							    NUMBER(12,10)
 CALCULATED_DLONG							    NUMBER(13,10)




</cfif>
</cfoutput>

<cfinclude template="/includes/_footer.cfm">
