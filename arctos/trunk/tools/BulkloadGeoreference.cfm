<cfinclude template="/includes/_header.cfm">
<cfoutput>


check code carefully - scary things are hard-coded

<cfabort>
<!----

create table cf_temp_insert_coordinates as select 
	tttest.cat_num,
	tttest.DATUM,
	tttest.DEC_LAT,
	tttest.DEC_LONG,
	tttest.ORIG_LAT_LONG_UNITS,
	cumv_fish_bulk.GEOREFERENCE_SOURCE,
	tttest.GeoRefAccuracyUnits max_error_units,
	tttest.LatLongAccuracy MAX_ERROR_DISTANCE
FROM
	tttest,
	cumv_fish_bulk
where
	tttest.cat_num=cumv_fish_bulk.cat_num and
	tttest.dec_lat is not null;



---->

	<cfquery name="d" datasource="uam_god">
		select *  from cf_temp_insert_coordinates where gotit is null
	</cfquery>
	<cfloop query="d">
	
	<cftransaction>
	<hr>
	<br>Cat Num: #d.cat_num#
		<cfquery name="thisCollEventLocality" datasource="uam_god">
			select
			specimen_event.specimen_event_id,
			locality.LOCALITY_ID,
			locality.GEOG_AUTH_REC_ID,
			locality.SPEC_LOCALITY,
			locality.DEC_LAT,
			locality.DEC_LONG,
			locality.MINIMUM_ELEVATION,
			locality.MAXIMUM_ELEVATION,
			locality.ORIG_ELEV_UNITS,
			locality.MIN_DEPTH,
			locality.MAX_DEPTH,
			locality.DEPTH_UNITS,
			locality.MAX_ERROR_DISTANCE,
			locality.MAX_ERROR_UNITS,
			locality.DATUM,
			locality.LOCALITY_REMARKS,
			locality.GEOREFERENCE_SOURCE,
			locality.GEOREFERENCE_PROTOCOL,
			locality.LOCALITY_NAME,
			collecting_event.COLLECTING_EVENT_ID,
			collecting_event.VERBATIM_DATE,
			collecting_event.VERBATIM_LOCALITY,
			collecting_event.COLL_EVENT_REMARKS,
			collecting_event.BEGAN_DATE,
			collecting_event.ENDED_DATE,
			collecting_event.VERBATIM_COORDINATES,
			collecting_event.COLLECTING_EVENT_NAME
		from
			locality,
			collecting_event,
			specimen_event,
			cataloged_item
		where
			locality.locality_id=collecting_event.locality_id and
			collecting_event.collecting_event_id=specimen_event.collecting_event_id and
			specimen_event.collection_object_id=cataloged_item.collection_object_id and
			cataloged_item.cat_num='#d.cat_num#' and
			cataloged_item.collection_id=83
		</cfquery>
		<cfif thisCollEventLocality.recordcount is 0>
			<p>
				current data not found abort
				<cfabort>
			</p>
		<cfelse>
			<!---- 
				is there a suitable locality? 
				This is current data EXCEPT
					 DEC_LAT
					 DEC_LONG			
					 ORIG_LAT_LONG_UNITS						
					 GEOREFERENCE_SOURCE						
					 MAX_ERROR_UNITS							 
					 MAX_ERROR_DISTANCE						

	
			---->
			<cfquery name="useLocality" datasource="uam_god">
				select min(locality_id) locality_id from locality where
					locality.GEOG_AUTH_REC_ID=#thisCollEventLocality.GEOG_AUTH_REC_ID# and
					<!--- from NEW data ---->
					<cfif len(d.DATUM) gt 0>
						DATUM='#d.DATUM#'
					<cfelse>
						DATUM is null
					</cfif>
					and
					<cfif len(d.GEOREFERENCE_SOURCE) gt 0>
						GEOREFERENCE_SOURCE='#d.GEOREFERENCE_SOURCE#'
					<cfelse>
						GEOREFERENCE_SOURCE is null
					</cfif>
					and
					<cfif len(d.GEOREFERENCE_PROTOCOL) gt 0>
						GEOREFERENCE_PROTOCOL='#d.GEOREFERENCE_PROTOCOL#'
					<cfelse>
						GEOREFERENCE_PROTOCOL is null
					</cfif>
					and
					<cfif len(d.MAX_ERROR_DISTANCE) gt 0>
						MAX_ERROR_DISTANCE=#d.MAX_ERROR_DISTANCE#
					<cfelse>
						MAX_ERROR_DISTANCE is null
					</cfif>
					and
					<cfif len(d.MAX_ERROR_UNITS) gt 0>
						MAX_ERROR_UNITS='#d.MAX_ERROR_UNITS#'
					<cfelse>
						MAX_ERROR_UNITS is null
					</cfif>
					and
					<cfif len(d.DEC_LAT) gt 0>
						DEC_LAT=#d.DEC_LAT#
					<cfelse>
						DEC_LAT is null
					</cfif>
					and
					<cfif len(d.DEC_LONG) gt 0>
						DEC_LONG=#d.DEC_LONG#
					<cfelse>
						DEC_LONG is null
					</cfif>
					and
					<!---- from CURRENT data ---->
					<cfif len(thisCollEventLocality.SPEC_LOCALITY) gt 0>
						SPEC_LOCALITY='#thisCollEventLocality.SPEC_LOCALITY#'
					<cfelse>
						SPEC_LOCALITY is null
					</cfif>
					and
					<cfif len(thisCollEventLocality.ORIG_ELEV_UNITS) gt 0>
						ORIG_ELEV_UNITS='#thisCollEventLocality.ORIG_ELEV_UNITS#'
					<cfelse>
						ORIG_ELEV_UNITS is null
					</cfif>
					and
					<cfif len(thisCollEventLocality.DEPTH_UNITS) gt 0>
						DEPTH_UNITS='#thisCollEventLocality.DEPTH_UNITS#'
					<cfelse>
						DEPTH_UNITS is null
					</cfif>
					and
					<cfif len(thisCollEventLocality.LOCALITY_NAME) gt 0>
						LOCALITY_NAME='#thisCollEventLocality.LOCALITY_NAME#'
					<cfelse>
						LOCALITY_NAME is null
					</cfif>
					and
					<cfif len(thisCollEventLocality.LOCALITY_REMARKS) gt 0>
						LOCALITY_REMARKS='#thisCollEventLocality.LOCALITY_REMARKS#'
					<cfelse>
						LOCALITY_REMARKS is null
					</cfif>
					and
					<cfif len(thisCollEventLocality.MINIMUM_ELEVATION) gt 0>
						MINIMUM_ELEVATION=#thisCollEventLocality.MINIMUM_ELEVATION#
					<cfelse>
						MINIMUM_ELEVATION is null
					</cfif>
					and
					<cfif len(thisCollEventLocality.MAXIMUM_ELEVATION) gt 0>
						MAXIMUM_ELEVATION=#thisCollEventLocality.MAXIMUM_ELEVATION#
					<cfelse>
						MAXIMUM_ELEVATION is null
					</cfif>
					and
					<cfif len(thisCollEventLocality.MIN_DEPTH) gt 0>
						MIN_DEPTH=#thisCollEventLocality.MIN_DEPTH#
					<cfelse>
						MIN_DEPTH is null
					</cfif>
					and
					<cfif len(thisCollEventLocality.MAX_DEPTH) gt 0>
						MAX_DEPTH=#thisCollEventLocality.MAX_DEPTH#
					<cfelse>
						MAX_DEPTH is null
					</cfif>
			</cfquery>
			<cfif useLocality.locality_id gt 0>
				
				<cfset newLocalityID=useLocality.locality_id>
				
				<br>got a locality: #newLocalityID#
			<cfelse>
					<cfquery name="nLocId" datasource="uam_god">
						select sq_locality_id.nextval nv from dual
					</cfquery>
					<cfset lid=nLocId.nv>
					<cfset newLocalityID=lid>
					<cfquery name="newLocality" datasource="uam_god">
						INSERT INTO locality (
							LOCALITY_ID,
							GEOG_AUTH_REC_ID,
							MAXIMUM_ELEVATION,
							MINIMUM_ELEVATION,
							ORIG_ELEV_UNITS,
							SPEC_LOCALITY,
							LOCALITY_REMARKS,
							DEPTH_UNITS,
							MIN_DEPTH,
							MAX_DEPTH,
							DEC_LAT,
							DEC_LONG,
							MAX_ERROR_DISTANCE,
							MAX_ERROR_UNITS,
							DATUM,
							georeference_source,
							georeference_protocol,
							locality_name
						) values (
							#lid#,
							#thisCollEventLocality.GEOG_AUTH_REC_ID#,
							<cfif len(thisCollEventLocality.MAXIMUM_ELEVATION) gt 0>
								#thisCollEventLocality.MAXIMUM_ELEVATION#
							<cfelse>
								NULL
							</cfif>,
							<cfif len(thisCollEventLocality.MINIMUM_ELEVATION) gt 0>
								#thisCollEventLocality.MINIMUM_ELEVATION#
							<cfelse>
								NULL
							</cfif>,
							<cfif len(thisCollEventLocality.ORIG_ELEV_UNITS) gt 0>
								'#thisCollEventLocality.ORIG_ELEV_UNITS#'
							<cfelse>
								NULL
							</cfif>,
							<cfif len(thisCollEventLocality.SPEC_LOCALITY) gt 0>
								'#escapeQuotes(thisCollEventLocality.SPEC_LOCALITY)#'
							<cfelse>
								NULL
							</cfif>,
							<cfif len(thisCollEventLocality.LOCALITY_REMARKS) gt 0>
								'#escapeQuotes(thisCollEventLocality.LOCALITY_REMARKS)#'
							<cfelse>
								NULL
							</cfif>,
							<cfif len(thisCollEventLocality.DEPTH_UNITS) gt 0>
								'#thisCollEventLocality.DEPTH_UNITS#'
							<cfelse>
								NULL
							</cfif>,
							<cfif len(thisCollEventLocality.MIN_DEPTH) gt 0>
								#thisCollEventLocality.MIN_DEPTH#
							<cfelse>
								NULL
							</cfif>,
							<cfif len(thisCollEventLocality.MAX_DEPTH) gt 0>
								#thisCollEventLocality.MAX_DEPTH#
							<cfelse>
								NULL
							</cfif>,
							<cfif len(d.DEC_LAT) gt 0>
								#d.DEC_LAT#
							<cfelse>
								NULL
							</cfif>,
							<cfif len(d.DEC_LONG) gt 0>
								#d.DEC_LONG#
							<cfelse>
								NULL
							</cfif>,
							<cfif len(d.MAX_ERROR_DISTANCE) gt 0>
								#d.MAX_ERROR_DISTANCE#
							<cfelse>
								NULL
							</cfif>,
							<cfif len(d.MAX_ERROR_UNITS) gt 0>
								'#d.MAX_ERROR_UNITS#'
							<cfelse>
								NULL
							</cfif>,
							<cfif len(d.DATUM) gt 0>
								'#d.DATUM#'
							<cfelse>
								NULL
							</cfif>,
							<cfif len(d.georeference_source) gt 0>
								'#escapeQuotes(d.georeference_source)#'
							<cfelse>
								NULL
							</cfif>,
							<cfif len(d.georeference_protocol) gt 0>
								'#escapeQuotes(d.georeference_protocol)#'
							<cfelse>
								NULL
							</cfif>,
							NULL
						)
					</cfquery>
					
				<br>made new locality #newLocalityID#
			</cfif>
			<cfquery name="findEvent" datasource="uam_god">
				select min(collecting_event_id) collecting_event_id from collecting_event where
					LOCALITY_ID=#newLocalityID# and
					nvl(verbatim_date,NULL)=nvl('#escapeQuotes(thisCollEventLocality.georeference_protocol)#','NULL') and
					nvl(VERBATIM_LOCALITY,NULL)=nvl('#escapeQuotes(thisCollEventLocality.VERBATIM_LOCALITY)#','NULL') and
					nvl(COLL_EVENT_REMARKS,NULL)=nvl('#escapeQuotes(thisCollEventLocality.COLL_EVENT_REMARKS)#','NULL') and
					nvl(BEGAN_DATE,NULL)=nvl('#escapeQuotes(thisCollEventLocality.BEGAN_DATE)#','NULL') and
					nvl(ENDED_DATE,NULL)=nvl('#escapeQuotes(thisCollEventLocality.ENDED_DATE)#','NULL') 
					<!--- may need to do something about verbatim/working data at some point - ignoring for now--->
			</cfquery>
			<cfif findEvent.collecting_event_id gt 0>
				<cfset newCollectingEventID=findEvent.collecting_event_id>
				<br>using event: #newCollectingEventID#
			<cfelse>
				<cfquery name="nextColl" datasource="uam_god">
					select sq_collecting_event_id.nextval nextColl from dual
				</cfquery>
				<cfset newCollectingEventID=nextColl.nextColl>

				<cfquery name="newCollEvent" datasource="uam_god">
					INSERT INTO collecting_event (
						COLLECTING_EVENT_ID,
						LOCALITY_ID,
						VERBATIM_DATE,
						VERBATIM_LOCALITY,
						COLL_EVENT_REMARKS,
						BEGAN_DATE,
						ENDED_DATE
					) values (
						#newCollectingEventID#,
						#newLocalityID#,
						'#escapeQuotes(thisCollEventLocality.VERBATIM_DATE)#',
						'#escapeQuotes(thisCollEventLocality.VERBATIM_LOCALITY)#',
						'#escapeQuotes(thisCollEventLocality.COLL_EVENT_REMARKS)#',
						'#escapeQuotes(thisCollEventLocality.BEGAN_DATE)#',
						'#escapeQuotes(thisCollEventLocality.ENDED_DATE)#'
					)
				</cfquery>
				<br>made new event: #newCollectingEventID#
			</cfif>
			<cfquery name="usev" datasource="uam_god">
				update specimen_event set COLLECTING_EVENT_ID=#newCollectingEventID# where specimen_event_id=#thisCollEventLocality.specimen_event_id#
			</cfquery>
			<br>update specimen_event set COLLECTING_EVENT_ID=#newCollectingEventID# where specimen_event_id=#thisCollEventLocality.specimen_event_id#
			<cfquery name="usev" datasource="uam_god">
				update cf_temp_insert_coordinates set gotit=1 where cat_num=#d.cat_num#
			</cfquery>
		</cfif>
<!------------
		<br>#locality_id#
		<cfquery name="isoneloc" datasource="uam_god">
			select count(distinct(n_DEC_LAT || ':' || n_DEC_LONG)) c from cumv_fwc_l where locality_id=#locality_id#
		</cfquery>
		<cfif isoneloc.c is 1>
			<br>just update
			<cfquery name="fud" datasource="uam_god">
				select N_DEC_LAT,N_DEC_LONG,N_DATUM,N_GEOREFERENCE_SOURCE from cumv_fwc_l where locality_id=#locality_id#
				group by N_DEC_LAT,N_DEC_LONG,N_DATUM,N_GEOREFERENCE_SOURCE
			</cfquery>

			update locality set dec_lat=r.N_DEC_LAT,dec_long=r.N_DEC_LONG,datum=r.N_DATUM,GEOREFERENCE_SOURCE=r.N_GEOREFERENCE_SOURCE where locality_id=r.locality_id;
			update cumv_fwc_l set gotit=1 where locality_id=r.locality_id;
		<cfelse>
			<br>need to split
		</cfif>
------------->



</cftransaction>
	</cfloop>










<!-------------------
declare 
	c number;
begin
for r in ( select p_max_error_distance from cumv_mamm_grerr group by p_max_error_distance) loop
	select count(distinct(locality_id)) into c from 
	cataloged_item,
	specimen_event,
	collecting_event
	where
	cataloged_item.collection_object_id=specimen_event.collection_object_id and
	cataloged_item.collection_id=86 and
	specimen_event.collecting_event_id=collecting_event.collecting_event_id and
	cataloged_item.cat_num in (select cat_num from cumv_mamm_grerr where p_max_error_distance=r.p_max_error_distance);
	dbms_output.put_line(c);
	end loop;
	end;
	/
	

	<cfsetting requestTimeOut = "1200">

	<cfquery name="d" datasource="uam_god">
		select *  from cumv_mamm_grerr where p_max_error_distance is not null
	</cfquery>
	<cftransaction>
	<cfloop query="d">
		<br>catnum: #cat_num#
		<cfquery name="lid" datasource="uam_god">
			select locality_id from 
				cataloged_item,
				specimen_event,
				collecting_event
			where
			cataloged_item.collection_object_id=specimen_event.collection_object_id and
			cataloged_item.collection_id=86 and
			specimen_event.collecting_event_id=collecting_event.collecting_event_id and
			cat_num=#cat_num#
		</cfquery>
		<cfif lid.recordcount is 0>
			stuck in bulkloader: <cfdump var=#lid#>
		<cfelse>
			<cfquery name="acn" datasource="uam_god">
				select cat_num from 
					cataloged_item,
					specimen_event,
					collecting_event
				where
				cataloged_item.collection_object_id=specimen_event.collection_object_id and
				cataloged_item.collection_id=86 and
				specimen_event.collecting_event_id=collecting_event.collecting_event_id and
				collecting_event.locality_id in (#valuelist(lid.locality_id)#)
			</cfquery>
			
			<cfquery name="diffs" dbtype="query">
				select p_max_error_distance from d where cat_num in (#listqualify(valuelist(acn.cat_num),chr(39))#) group by p_max_error_distance
			</cfquery>
			<cfif diffs.recordcount gt 1>
				<br>there are multiple catnums for this distance - this approach won't work
			</cfif>
			
			<cfquery name="cloc" datasource="uam_god">
				select 
					cat_num, max_error_distance,max_error_units ,locality.locality_id
				from 
					cataloged_item,
					specimen_event,
					collecting_event,
					locality
				where
				cataloged_item.collection_object_id=specimen_event.collection_object_id and
				cataloged_item.collection_id=86 and
				specimen_event.collecting_event_id=collecting_event.collecting_event_id and
				collecting_event.locality_id =locality.locality_id and 
				locality.locality_id in (#valuelist(lid.locality_id)#)
			</cfquery>
			<br>
update locality set max_error_distance=round(#d.p_max_error_distance#,2),
				max_error_units='#d.max_error_units#' where locality_id=#cloc.locality_id#			
			<cfquery name="uploc" datasource="uam_god">
				update locality set max_error_distance=round(#d.p_max_error_distance#,2),
				max_error_units='#d.max_error_units#' where locality_id=#cloc.locality_id#
			</cfquery>
			
		</cfif>
		
		<!-------------
		<cfloop from="1" to="8" index="x">
			<cfset "n#x#"=''>
			<cfset "r#x#"=''>
		</cfloop>
		<cfset thisorder=1>
		<cfloop from="1" to="8" index="x">
			<cfset thisC=evaluate("d.collector_" & x)>
			<cfif len(thisC) gt 0>
				<cfset "n#thisorder#"=thisC>
				<cfset "r#thisorder#"='c'>
				<cfset thisorder=thisorder+1>
			</cfif>
		</cfloop>
		<cfloop from="1" to="8" index="x">
			<cfset thisC=evaluate("d.preparator_" & x)>
			<cfif len(thisC) gt 0>
				<cfset "n#thisorder#"=thisC>
				<cfset "r#thisorder#"='p'>
				<cfset thisorder=thisorder+1>
			</cfif>
		</cfloop>
		<cfquery name="up" datasource="uam_god">
			update birdprepcoll set gotit=1 where collectors
			<cfif len(collectors) gt 0>
				='#escapeQuotes(collectors)#' 
			<cfelse>
				is null
			</cfif>
			and preparator
			<cfif len(preparator) gt 0>
				='#escapeQuotes(preparator)#'
			<cfelse>
				is null
			</cfif>
		</cfquery>
		<cfquery name="up" datasource="uam_god">
		update cumv_bird_bulk set 
		collector_agent_1='#n1#',
		collector_role_1='#r1#',
		collector_agent_2='#n2#',
		collector_role_2='#r2#',
		collector_agent_3='#n3#',
		collector_role_3='#r3#',
		collector_agent_4='#n4#',
		collector_role_4='#r4#',
		collector_agent_5='#n5#',
		collector_role_5='#r5#',
		collector_agent_6='#n6#',
		collector_role_6='#r6#',
		collector_agent_7='#n7#',
		collector_role_7='#r7#',
		collector_agent_8='#n8#',
		collector_role_8='#r8#'				
		where collectors='#escapeQuotes(collectors)#' and preparator
			<cfif len(preparator) gt 0>
				='#escapeQuotes(preparator)#'
			<cfelse>
				is null
			</cfif>
		</cfquery>
		--------------->
	</cfloop>
	</cftransaction>
	
	------------------>
</cfoutput>