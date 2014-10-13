<cfinclude template="/includes/_header.cfm">
<cfset title="merge collecting events">
<cfif not isdefined("locality_id") or len(locality_id) is 0>
	need a locality_id to proceed<cfabort>
</cfif>
<cfoutput>
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from collecting_event where locality_id=#locality_id#
</cfquery>
<hr>

All collecting events from this locality:
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
		</cfquery>
		<p>
			The following Collecting Events are duplicates.
		</p>
		<cfdump var=#thisun#>
		<cfquery name="master" dbtype="query">
			select min(collecting_event_id) as collecting_event_id from thisun
		</cfquery>
		<cfquery name="thisdups" dbtype="query">
			select collecting_event_id from thisun where collecting_event_id != #master.collecting_event_id#
		</cfquery>
		
		<p>
			If you proceed, these events.....
		</p>
		
		<cfdump var=#thisdups#>
		
		<p>
			Will be merged into....
		</p>
		<cfdump var=#master#>
	</cfloop>
	<p>
		<a href="mergeDuplicateEvents.cfm?locality_id=#locality_id#&action=makeMerge">Proceed with all of the above mergers</a>
	</p>
</cfif>
</cfoutput>

<cfinclude template="/includes/_footer.cfm">
