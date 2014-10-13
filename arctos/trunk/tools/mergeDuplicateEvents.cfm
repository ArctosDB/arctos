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
			VERBATIM_DATE='#VERBATIM_DATE#' and
			VERBATIM_LOCALITY='#VERBATIM_LOCALITY#' and
			COLL_EVENT_REMARKS='#COLL_EVENT_REMARKS#' and
			BEGAN_DATE='#BEGAN_DATE#' and
			ENDED_DATE='#ENDED_DATE#' and
			VERBATIM_COORDINATES='#VERBATIM_COORDINATES#' and
			COLLECTING_EVENT_NAME='#COLLECTING_EVENT_NAME#' and
			DATUM='#DATUM#'
		</cfquery>
		<cfdump var=#thisun#>
		
	</cfloop>

</cfif>
</cfoutput>

<cfinclude template="/includes/_footer.cfm">
