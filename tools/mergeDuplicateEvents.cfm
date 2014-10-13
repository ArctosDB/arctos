<cfinclude template="/includes/_header.cfm">
<cfset title="merge collecting events">
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
				cast(VERBATIM_DATE as varchar)='#VERBATIM_DATE#' and
			<cfelse>
				VERBATIM_DATE is null and
			</cfif>
			<cfif len(VERBATIM_LOCALITY) gt 0>
				VERBATIM_LOCALITY='#VERBATIM_LOCALITY#' and
			<cfelse>
				VERBATIM_LOCALITY is null and
			</cfif>
			<cfif len(COLL_EVENT_REMARKS) gt 0>
				COLL_EVENT_REMARKS='#COLL_EVENT_REMARKS#' and
			<cfelse>
				COLL_EVENT_REMARKS is null and
			</cfif>
			<cfif len(BEGAN_DATE) gt 0>
				cast(BEGAN_DATE as varchar)='#BEGAN_DATE#' and
			<cfelse>
				BEGAN_DATE is null and
			</cfif>
			<cfif len(ENDED_DATE) gt 0>
				cast(ENDED_DATE as varchar)='#ENDED_DATE#' and
			<cfelse>
				ENDED_DATE is null and
			</cfif>
			<cfif len(VERBATIM_COORDINATES) gt 0>
				VERBATIM_COORDINATES='#VERBATIM_COORDINATES#' and
			<cfelse>
				VERBATIM_COORDINATES is null and
			</cfif>
			<cfif len(COLLECTING_EVENT_NAME) gt 0>
				COLLECTING_EVENT_NAME='#COLLECTING_EVENT_NAME#' and
			<cfelse>
				COLLECTING_EVENT_NAME is null and
			</cfif>
			<cfif len(DATUM) gt 0>
				DATUM='#DATUM#'
			<cfelse>
				DATUM is null
			</cfif>
			
			<!----
			select * from data where VERBATIM_DATE='26 MAR 1997' and 
			VERBATIM_LOCALITY='captive'   and 
			cast(BEGAN_DATE as varchar)='1997-03-26'
			---->
			<!----
			
			 and 
			ENDED_DATE='1997-03-26'
			
			
			and COLL_EVENT_REMARKS
			 and VERBATIM_COORDINATES is null and COLLECTING_EVENT_NAME is null and DATUM is null 
			----> 
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
