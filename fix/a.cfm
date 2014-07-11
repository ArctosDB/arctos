<cfinclude template="/includes/_header.cfm">

<input required>



<cfabort>


<cfset inet_address = CreateObject("java", "java.net.InetAddress")>
<cfset host_name = inet_address.getByName("66.249.66.99").getHostName()>


<cfoutput>#host_name#</cfoutput>
<cfabort>


<cfinclude template="/includes/_header.cfm">



<!----




DO NOT OVERWRITE THIS

until cornell has moved field numbers over to evnet names

moved tohttp://arctos.database.museum/fix/cumv_eventname.cfm?action=showProblems&rownum=10000 



---------------------------------------->
<cfoutput>



<cfquery name="d" datasource="uam_god">
	select * from cumv_fish_tid_le where hasdup = 1
</cfquery>
<cfquery name="ddv" dbtype="query">
	select display_value from d group by display_value
</cfquery>

<cfset i=0>


<cfloop query="ddv">
	<cfquery name='hasdup'dbtype="query">
		select collecting_event_id from d where display_value='#display_value#' group by collecting_event_id
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
				<hr>
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
						<br>geog and specloc match
						<cfif len(one.dec_lat) gt 0>
							<br>no problem can autoupdate@ update collecting_event set locality_id=#one.locality_id# where locality_id=#two.locality_id#;
						<cfelseif len(two.dec_lat) gt 0>
							<br>no problem can autoupdate@ update collecting_event set locality_id=#two.locality_id# where locality_id=#one.locality_id#;
						<cfelse>
							<br>no clear winner - pick one randomly?
						</cfif>
					<cfelse>
						<cfif one.GEOG_AUTH_REC_ID is not two.GEOG_AUTH_REC_ID>
							<br>geog mismatch
						</cfif>
						<cfif one.SPEC_LOCALITY is not two.SPEC_LOCALITY>
							<br><strong>#one.SPEC_LOCALITY#</strong> ::ISNOT:: <strong>#two.SPEC_LOCALITY#</strong>
						</cfif>
					</cfif>
					
					<br>Locality data dump:
					<p>
						<cfdump var=#l#>
					</p>
					<br>Locality1: <a target="_blank" href="/editLocality.cfm?locality_id=#mad.lid#">[edit #mad.lid#]</a>
					<br>Locality1 Specimens:<a target="_blank" href="/SpecimenResults.cfm?locality_id=#mad.lid#">[specimens]</a>
					<br>Loclaity2: <a target="_blank" href="/editLocality.cfm?locality_id=#mid.lid#">[edit #mid.lid#]</a>
					<br>Locality2 Specimens: <a target="_blank" href="/SpecimenResults.cfm?locality_id=#mid.lid#">[specimens]</a>
					
					<cfset i=i+1>
	
				<cfelse>
				<!----
					<cfdump var=#l#>
					--->
				</cfif>
				
				
			</cfif>
	</cfif>
</cfloop>

<p>total number problems: #i#</p>
</cfoutput>