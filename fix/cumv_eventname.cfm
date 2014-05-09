<cfinclude template="/includes/_header.cfm">


<!----




DO NOT OVERWRITE THIS

until cornell has moved field numbers over to evnet names



---------------------------------------->
<cfoutput>
<p>
	This form is temporary and therefore slow. Click the links, wait for stuff to happen. It'll take a while.
</p>
<p>
	<a href="cumv_eventname.cfm?action=refreshData">refreshData - run this after you've fixed some stuff - showProblems is NOT dynamic but uses tables built here</a>
</p>
<p>
	adjust the "rownum" parameter in the showProblems URL to see fewer records/make this faster. The number doesn't mean anything important, it's just an index. 1000 will be pretty fast, 100000 will probably time out
</p>
<p>
	<a href="cumv_eventname.cfm?action=showProblems&rownum=10000">showProblems 10,000</a>
</p>
<p>
	<a href="cumv_eventname.cfm?action=showProblems&rownum=1000">showProblems 1,000</a>
</p>

<cfif action is "forceUpdate">
	<p>running for 
	update collecting_event set locality_id=#goodLOCID# where locality_id=#badLOCID#
	</p>
	<cfquery name="forceUpdate" datasource="uam_god">
		update collecting_event set locality_id=#goodLOCID# where locality_id=#badLOCID#
	</cfquery>
	<cfquery name="alldone" datasource="uam_god">
		delete from cumv_herp_tid_le where collecting_event_id in (#cidlist#)
	</cfquery>
	
	
	<p>cidlist: #cidlist#</p>
	<p>
		update successful - use the links above to continue
	</p>
	
</cfif>


<!------------------------------------------------------------>
<cfif action is "showProblems">


<cfif not isdefined("rownum") or len(rownum) is 0>
	<cfset rownum=1000>
</cfif>
<cfquery name="d" datasource="uam_god">
	select * from cumv_herp_tid_le where hasdup = 1 and rownum<#rownum#
</cfquery>
<cfquery name="ddv" dbtype="query">
	select display_value from d group by display_value
</cfquery>

<cfset i=0>


<cfloop query="ddv">
	<cfquery name='hasdup'dbtype="query">
		select collecting_event_id from d where display_value='#display_value#'  group by collecting_event_id
	</cfquery>
	
	
	
	<cfquery name='hasdup'dbtype="query">
		select collecting_event_id from d where display_value='#display_value#' group by collecting_event_id
	</cfquery>
	<cfif hasdup.recordcount gt 1>
	
	<!----
		<p>
			#ddv.display_value# has multiple events: #valuelist(hasdup.collecting_event_id)#
		</p>
		
		-------->
		
		
		
			<cfquery name="l"  dbtype="query">
				select  
				LOCALITY_ID,
				GEOG_AUTH_REC_ID,
				 SPEC_LOCALITY	,
				 DEC_LAT,
				 DEC_LONG,
				 MINIMUM_ELEVATION	,
				 MAXIMUM_ELEVATION	,
				 ORIG_ELEV_UNITS,
				 MIN_DEPTH,
				 MAX_DEPTH	,
				 DEPTH_UNITS		,
				MAX_ERROR_DISTANCE	,
				 MAX_ERROR_UNITS	,
				 DATUM,
				 LOCALITY_REMARKS,
				 GEOREFERENCE_SOURCE,
				 GEOREFERENCE_PROTOCOL	,
				 LOCALITY_NAME
				 from
				 d
				 where collecting_event_id in (#valuelist(hasdup.collecting_event_id)#)
				 group by
				 LOCALITY_ID,
				GEOG_AUTH_REC_ID,
				 SPEC_LOCALITY	,
				 DEC_LAT,
				 DEC_LONG,
				 MINIMUM_ELEVATION	,
				 MAXIMUM_ELEVATION	,
				 ORIG_ELEV_UNITS,
				 MIN_DEPTH,
				 MAX_DEPTH	,
				 DEPTH_UNITS		,
				MAX_ERROR_DISTANCE	,
				 MAX_ERROR_UNITS	,
				 DATUM,
				 LOCALITY_REMARKS,
				 GEOREFERENCE_SOURCE,
				 GEOREFERENCE_PROTOCOL	,
				 LOCALITY_NAME
			</cfquery>
			<cfif l.recordcount gt 1>
				<div style="border:2px solid black;margin-bottom:2em;">
				<a target="_blank" href="/SpecimenResults.cfm?&OIDNum=#ddv.display_value#&oidOper=IS">#ddv.display_value#</a> is used in multiple localities
				<cfif l.recordcount is 2>
					<cfquery name="mid" dbtype="query">
						select min(locality_id) lid from l
					</cfquery>
					<cfquery name="mad" dbtype="query">
						select max(locality_id) lid from l
					</cfquery>
		
					<cfquery name="one" dbtype="query">
						select * from l where locality_id=#mid.lid#
					</cfquery>
					<cfquery name="two" dbtype="query">
						select * from l where locality_id=#mad.lid#
					</cfquery>
					
					
					<cfif one.GEOG_AUTH_REC_ID is two.GEOG_AUTH_REC_ID and one.SPEC_LOCALITY is two.SPEC_LOCALITY>
						<cfset sql="">
						<br>geog and specloc match
						<cfif len(one.dec_lat) gt 0 and len(two.dec_lat) is 0>
							<br>no problem can autoupdate@ <br>update collecting_event set locality_id=#one.locality_id# where locality_id=#two.locality_id#;
							<cfset sql="update collecting_event set locality_id=#one.locality_id# where locality_id=#two.locality_id#">
						<cfelseif len(two.dec_lat) gt 0 and len(one.dec_lat) is 0>
							<br>no problem can autoupdate@ <br>update collecting_event set locality_id=#two.locality_id# where locality_id=#one.locality_id#;
							<cfset sql="update collecting_event set locality_id=#two.locality_id# where locality_id=#one.locality_id#">
						<cfelseif len(one.max_error_distance) gt 0 and len(two.max_error_distance) is 0>
							<br>no problem can autoupdate@ <br>update collecting_event set locality_id=#one.locality_id# where locality_id=#two.locality_id#;
							<cfset sql="update collecting_event set locality_id=#one.locality_id# where locality_id=#two.locality_id#">
						<cfelseif len(two.max_error_distance) gt 0 and len(one.max_error_distance) is 0>
							<br>no problem can autoupdate@ <br>update collecting_event set locality_id=#two.locality_id# where locality_id=#one.locality_id#;
							<cfset sql="update collecting_event set locality_id=#two.locality_id# where locality_id=#one.locality_id#">
						<cfelse>
							<br>no clear winner - pick one randomly?
							<cfset sql="">
						</cfif>
						<cfif len(sql) gt 0>
							<p>
								autoupdate this: #sql#
							</p>
							
							<cfquery name="obviousUpdate" datasource="uam_god">
								#sql#
							</cfquery>

						</cfif>
					<cfelse>
						<cfif one.GEOG_AUTH_REC_ID is not two.GEOG_AUTH_REC_ID>
							<div style="font-weight:bold;font-size:large;color:red">
								geog mismatch
							</div>
						</cfif>
						<cfif one.SPEC_LOCALITY is not two.SPEC_LOCALITY>
							<br><strong>#one.SPEC_LOCALITY#</strong> ::ISNOT:: <strong>#two.SPEC_LOCALITY#</strong>
						</cfif>
					</cfif>
					
					<br>Locality data dump:
					<table border style="max-width:95%">
						<tr>
							<td>LOCALITY_ID</td>
							<td>GEOG_AUTH_REC_ID</td>
							<td>SPEC_LOCALITY</td>
							<td>LOCALITY_REMARKS</td>
							<td><div style="font-size:x-small">DEC_LAT:DEC_LONG:MAX_ERROR_DISTANCE:MAX_ERROR_UNITS:DATUM:GEOREFERENCE_PROTOCOL:GEOREFERENCE_SOURCE</div></td>
							<td><div style="font-size:x-small">MIN_DEPTH:MAX_DEPTH:DEPTH_UNITS</div></td>
							<td><div style="font-size:x-small">MINIMUM_ELEVATION:MAXIMUM_ELEVATION:ORIG_ELEV_UNITS</div></td>	 	 	 	 	
						</tr>
						<cfloop query="#l#">
							<tr>
								<td>
									<a target="_blank" href="/editLocality.cfm?locality_id=#locality_id#">[edit&nbsp;#locality_id#]</a>
									<br><a target="_blank" href="/SpecimenResults.cfm?locality_id=#locality_id#">[specimens]</a>
								</td>
								<td>#GEOG_AUTH_REC_ID#</td>
								<td>#SPEC_LOCALITY#</td>
								<td>#LOCALITY_REMARKS#</td>
								<td>#DEC_LAT#:#DEC_LONG#:#MAX_ERROR_DISTANCE#:#MAX_ERROR_UNITS#:#DATUM#:#GEOREFERENCE_PROTOCOL#:#GEOREFERENCE_SOURCE#</td>
								<td>#MIN_DEPTH#:#MAX_DEPTH#:#DEPTH_UNITS#</td>
								<td>#MINIMUM_ELEVATION#:#MAXIMUM_ELEVATION#:#ORIG_ELEV_UNITS#</td>	 	 	 	 	
							</tr>
						</cfloop>
					</table>
					<div style="border:5px solid red; margin:1em;padding:1em;">
						<br>CAUTION: THESE LINKS PERMANENTLY CHANGE DATA!! match the locality IDs with the table above, and make very sure you 
						know what you're doing before you get all clicky....
						<p><a href="cumv_eventname.cfm?action=forceUpdate&badLOCID=#one.locality_id#&goodLOCID=#two.locality_id#&cidlist=#valuelist(hasdup.collecting_event_id)#">
						update collecting event to locality_id=#two.locality_id# where locality_id=#one.locality_id#</a>
						
						<br><a href="cumv_eventname.cfm?action=forceUpdate&badLOCID=#two.locality_id#&goodLOCID=#one.locality_id#&cidlist=#valuelist(hasdup.collecting_event_id)#">
						update collecting event to locality_id=#one.locality_id# where locality_id=#two.locality_id#</a>
						</p>
						
						
						
						
						
						
					</div>
					<!----
					<p>
						<cfdump var=#l#>
					</p>
					<br>Locality1: <a target="_blank" href="/editLocality.cfm?locality_id=#mad.lid#">[edit #mad.lid#]</a>
					<br>Loclaity2: <a target="_blank" href="/editLocality.cfm?locality_id=#mid.lid#">[edit #mid.lid#]</a>
					<br>Locality2 Specimens: <a target="_blank" href="/SpecimenResults.cfm?locality_id=#mid.lid#">[specimens]</a>
					---->
					<cfset i=i+1>
				
				<cfelse>
					<p>
						more than 2 localities involved here - handle this later....
					</p>
				<!----
					<cfdump var=#l#>
					--->
				</cfif>
				
				</div>
			</cfif>
	</cfif>
</cfloop>

<p>total number problems: #i#</p>

</cfif>

<cfif action is "refreshData">
	<cfquery name="d1" datasource="uam_god">
		drop table cumv_herp_tid
	</cfquery>
	<cfquery name="d2" datasource="uam_god">
		drop table cumv_herp_tid_le
	</cfquery>
	<cfquery name="c1" datasource="uam_god">
		create table cumv_herp_tid as select
		flat.guid,
		specimen_event.collecting_event_id,
		display_value
		from
		flat,
		specimen_event,
		coll_obj_other_id_num
		where
		flat.collection_object_id=specimen_event.collection_object_id and
		flat.collection_object_id=coll_obj_other_id_num.collection_object_id and
		(flat.guid like 'CUMV:Amph%' or flat.guid like 'CUMV:Rept%') and
		other_id_type='Trapline ID'
	</cfquery>
	<cfquery name="c2" datasource="uam_god">
		create table cumv_herp_tid_le as select
		cumv_herp_tid.guid,
		cumv_herp_tid.collecting_event_id,
		cumv_herp_tid.display_value,
		locality.LOCALITY_ID,
		locality.GEOG_AUTH_REC_ID,
		 locality.SPEC_LOCALITY	,
		 locality.DEC_LAT,
		 locality.DEC_LONG,
		 locality.MINIMUM_ELEVATION	,
		 locality.MAXIMUM_ELEVATION	,
		 locality.ORIG_ELEV_UNITS,
		 locality.MIN_DEPTH,
		 locality.MAX_DEPTH	,
		 locality.DEPTH_UNITS		,
		locality.MAX_ERROR_DISTANCE	,
		 locality.MAX_ERROR_UNITS	,
		 locality.DATUM,
		 locality.LOCALITY_REMARKS,
		 locality.GEOREFERENCE_SOURCE,
		 locality.GEOREFERENCE_PROTOCOL	,
		 locality.LOCALITY_NAME,
		collecting_event.VERBATIM_DATE,
		 collecting_event.VERBATIM_LOCALITY	,
		 collecting_event.COLL_EVENT_REMARKS,
		 collecting_event.BEGAN_DATE,
		 collecting_event.ENDED_DATE,
		 collecting_event.VERBATIM_COORDINATES,
		 collecting_event.COLLECTING_EVENT_NAME,
		 0 hasdup
		 from
		 cumv_herp_tid,
		 collecting_event,
		 locality
		 where
		 cumv_herp_tid.collecting_event_id=collecting_event.collecting_event_id and
		 collecting_event.locality_id=locality.locality_id
	</cfquery>
	<cfquery name="i1" datasource="uam_god">
		 create index ix_junk1 on cumv_herp_tid_le(collecting_event_id) tablespace uam_idx_1
	</cfquery>
	<cfquery name="i2" datasource="uam_god">
		 create index ix_junk2 on cumv_herp_tid_le(display_value) tablespace uam_idx_1
	</cfquery>
	<cfquery name="d" datasource="uam_god">
		select * from cumv_herp_tid
	</cfquery>
	<cfquery name="ddv" dbtype="query">
		select display_value from d group by display_value
	</cfquery>
	<cfoutput>
		<cfloop query="ddv">
			<cfquery name="isdup" dbtype="query">
				select count(distinct(collecting_event_id)) c from d where display_value='#display_value#'
			</cfquery>
			<cfif isdup.c gt 1>
				<cfquery name="updup" datasource="uam_god">
					update cumv_herp_tid_le set hasdup=1 where display_value='#display_value#'
				</cfquery>
			</cfif>
		</cfloop>
	</cfoutput>
	
	<p>data refreshed</p>
</cfif>
</cfoutput>