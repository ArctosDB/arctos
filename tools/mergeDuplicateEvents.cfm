<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<style>
	.theChosenOne{font-weight:bold;}
</style>
<cfset title="merge collecting events">
<cfif not isdefined("locality_id") or len(locality_id) is 0>
	need a locality_id to proceed<cfabort>
</cfif>
<cfoutput>
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		collecting_event_id, 
		VERBATIM_DATE,
		VERBATIM_LOCALITY,
		COLL_EVENT_REMARKS,
		BEGAN_DATE,
		ENDED_DATE,
		VERBATIM_COORDINATES,
		COLLECTING_EVENT_NAME,
		DATUM from collecting_event where locality_id=#locality_id#
</cfquery>

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
<cftransaction>
<cfif dups.recordcount is 0>
	No duplicates detected - try merging localities first.
	<p>
		<a href="/Locality.cfm?action=findCollEvent&locality_id=#locality_id#">return to locality/event list</a>
	</p>
<cfelse>
	<cfif action is not "makeMerge">	
		All collecting events from this locality:
		<table border id="t" class="sortable">
			<tr>
				<th>COLLECTING_EVENT_ID</th>
				<th>COLLECTING_EVENT_NAME</th>
				<th>VERBATIM_DATE</th>
				<th>BEGAN_DATE</th>
				<th>ENDED_DATE</th>
				<th>VERBATIM_LOCALITY</th>
				<th>COLL_EVENT_REMARKS</th>
				<th>VERBATIM_COORDINATES</th>
				<th>DATUM</th>
			</tr>
			<cfloop query="data">
				<tr <cfif COLLECTING_EVENT_ID is master.collecting_event_id> class="theChosenOne"</cfif>>
					<td>#COLLECTING_EVENT_ID#</td>
					<td>#COLLECTING_EVENT_NAME#</td>
					<td>#VERBATIM_DATE#</td>
					<td>#BEGAN_DATE#</td>
					<td>#ENDED_DATE#</td>
					<td>#VERBATIM_LOCALITY#</td>
					<td>#COLL_EVENT_REMARKS#</td>
					<td>#VERBATIM_COORDINATES#</td>
					<td>#DATUM#</td>
				</tr>
			</cfloop>
		</table>
		<!----
		<table border id="t" class="sortable">
			<tr>
				<cfloop list="#data.columnlist#" index="x">
					<th>#x#</th>
				</cfloop>
			</tr>
			<cfloop query=#data#>
				<tr>
					<cfloop list="#data.columnlist#" index="x">
						<td>#evaluate("data." & x)#</td>
					</cfloop>
				</tr>
			</cfloop>
		</table>
		---->
		<p>
			Uniques:
		</p>
		<table border id="tu" class="sortable">
				<tr>
					<th>COLLECTING_EVENT_NAME</th>
					<th>VERBATIM_DATE</th>
					<th>BEGAN_DATE</th>
					<th>ENDED_DATE</th>
					<th>VERBATIM_LOCALITY</th>
					<th>COLL_EVENT_REMARKS</th>
					<th>VERBATIM_COORDINATES</th>
					<th>DATUM</th>
				</tr>
				<cfloop query="dups">
					<tr>
						<td>#COLLECTING_EVENT_NAME#</td>
						<td>#VERBATIM_DATE#</td>
						<td>#BEGAN_DATE#</td>
						<td>#ENDED_DATE#</td>
						<td>#VERBATIM_LOCALITY#</td>
						<td>#COLL_EVENT_REMARKS#</td>
						<td>#VERBATIM_COORDINATES#</td>
						<td>#DATUM#</td>
					</tr>
				</cfloop>
			</table>
			<!----
			
			<table border id="tu" class="sortable">
			<tr>
				<cfloop list="#dups.columnlist#" index="x">
					<th>#x#</th>
				</cfloop>
			</tr>
			<cfloop query=#dups#>
				<tr>
					<cfloop list="#dups.columnlist#" index="x">
						<td>#evaluate("data." & x)#</td>
					</cfloop>
				</tr>
			</cfloop>
		</table>
		---->
	</cfif>
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
			order by collecting_event_id
		</cfquery>
		<cfquery name="master" dbtype="query">
			select min(collecting_event_id) as collecting_event_id from thisun
		</cfquery>
		<cfquery name="thisdups" dbtype="query">
			select collecting_event_id from thisun where collecting_event_id != #master.collecting_event_id#
		</cfquery>
		
		<cfif action is not "makeMerge">	
			<p>
				The following set of Collecting Events are duplicates. If you proceed, the row in bold will replace all other rows in all
				data, and all non-bold rows will be deleted.
			</p>
			<table border id="t#master.collecting_event_id#" class="sortable">
				<tr>
					<th>COLLECTING_EVENT_ID</th>
					<th>COLLECTING_EVENT_NAME</th>
					<th>VERBATIM_DATE</th>
					<th>BEGAN_DATE</th>
					<th>ENDED_DATE</th>
					<th>VERBATIM_LOCALITY</th>
					<th>COLL_EVENT_REMARKS</th>
					<th>VERBATIM_COORDINATES</th>
					<th>DATUM</th>
				</tr>
				<cfloop query="thisun">
					<tr <cfif COLLECTING_EVENT_ID is master.collecting_event_id> class="theChosenOne"</cfif>>
						<td>#COLLECTING_EVENT_ID#</td>
						<td>#COLLECTING_EVENT_NAME#</td>
						<td>#VERBATIM_DATE#</td>
						<td>#BEGAN_DATE#</td>
						<td>#ENDED_DATE#</td>
						<td>#VERBATIM_LOCALITY#</td>
						<td>#COLL_EVENT_REMARKS#</td>
						<td>#VERBATIM_COORDINATES#</td>
						<td>#DATUM#</td>
					</tr>
				</cfloop>
			</table>
		</cfif>
		
		<cfif action is "makeMerge">
			<cfquery name="mergeSE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update 
					specimen_event 
				set 
					collecting_event_id=#master.collecting_event_id# 
				where 
					collecting_event_id in (#valuelist(thisdups.collecting_event_id)#)
			</cfquery>
			<cfquery name="mergeMR" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update 
					media_relations 
				set 
					related_primary_key=#master.collecting_event_id# 
				where 
					MEDIA_RELATIONSHIP like '% collecting_event' and
					related_primary_key in (#valuelist(thisdups.collecting_event_id)#)
			</cfquery>
			<cfquery name="deleteEvents" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from collecting_event where 
				collecting_event_id in (#valuelist(thisdups.collecting_event_id)#)
			</cfquery>
			<p>
				Collecting event(s) #valuelist(thisdups.collecting_event_id)# have been merged into Collecting event #master.collecting_event_id# 
			</p>
		</cfif>
	</cfloop>
	<cfif action is not "makeMerge">	
		<p>
			<a href="mergeDuplicateEvents.cfm?locality_id=#locality_id#&action=makeMerge">Proceed with all of the above mergers</a>
		</p>
	<cfelse>
		<p>
			<a href="/Locality.cfm?action=findCollEvent&locality_id=#locality_id#">return to locality/event list</a>
		</p>
	</cfif>
</cfif>
</cftransaction>
</cfoutput>

<cfinclude template="/includes/_footer.cfm">
