<cfinclude template="/includes/functionLib.cfm">
<cfoutput>
<cfquery name="d" datasource="uam_god">
	select
		*
		 from bulkloader_undeletes where status is null
	and rownum <= 1000
</cfquery>
<cfloop query="d">

	
	<cftransaction>
			<cfstoredproc datasource="uam_god" procedure="is_flat_stale">
	</cfstoredproc>	
			<cfquery name="ifs" datasource="uam_god">
				select count(*) c from flat where stale_flag=1
			</cfquery>
		<cfif ifs.c gt 0>
			flat is stale<cfabort>
		</cfif>

		<hr>
		
		
		
		<cfquery name="elocid" datasource="uam_god">
			select 
				*
			from flat where
			cat_num='#cat_num#' and
			INSTITUTION_ACRONYM='#INSTITUTION_ACRONYM#' and
			COLLECTION_CDE='#COLLECTION_CDE#'
		</cfquery>
		
		<br>INSTITUTION_ACRONYM: #INSTITUTION_ACRONYM#
		<br>flatCollObjId: #collection_object_id#
		<br>cat_num: #cat_num#
		<br>#higher_geog#
		<br>#spec_locality#
		<br>#dec_lat#
		<br>#dec_long#
		<br>#verbatim_locality#
		<br>CurrentLocalityId: #elocid.locality_id#
		<br>elll: #elocid.dec_lat#
		
		
		<br>#verbatim_locality#
		<cfif elocid.recordcount is not 1>
			<br>not one record
			<cfquery name="q" datasource="uam_god">
				update bulkloader_undeletes set status='not_one_record' where collection_object_id=#collection_object_id#
			</cfquery>
		<cfelse>	
			<cfif len(elocid.dec_lat) gt 0>
				<!--- already have coordinates - move on --->
				<cfquery name="q" datasource="uam_god">
					update bulkloader_undeletes set status='already_got_one' where collection_object_id=#collection_object_id#
				</cfquery>
				<br>already got one - abort
			<cfelse>
				<!--- just make new everything - combine/cleanup later --->
				<cfquery name="nlid" datasource="uam_god">
					select sq_locality_id.nextval nlid from dual
				</cfquery>
				<br>making locality #nlid.nlid#
				<cfquery name="nLoc" datasource="uam_god">
					insert into locality (
						LOCALITY_ID,
						GEOG_AUTH_REC_ID,
						MAXIMUM_ELEVATION,
						MINIMUM_ELEVATION,
						ORIG_ELEV_UNITS,
						SPEC_LOCALITY,
						LOCALITY_REMARKS
					) values (
						#nlid.nlid#,
						#elocid.GEOG_AUTH_REC_ID#,
						<cfif len(MAXIMUM_ELEVATION) gt 0>
							#MAXIMUM_ELEVATION#,
						<cfelse>
							NULL,
						</cfif>
						<cfif len(MINIMUM_ELEVATION) gt 0>
							#MINIMUM_ELEVATION#,
						<cfelse>
							NULL,
						</cfif>
						'#ORIG_ELEV_UNITS#',
						'#escapeQuotes(SPEC_LOCALITY)#',
						'#escapeQuotes(LOCALITY_REMARKS)#'
					)
				</cfquery>
				<cfquery name="newCoor" datasource="uam_god">
					INSERT INTO lat_long (
						LAT_LONG_ID,
						LOCALITY_ID,
						DEC_LAT,
						DEC_LONG,
						DATUM,
						orig_lat_long_units,
						determined_by_agent_id,
						DETERMINED_DATE,
						LAT_LONG_REF_SOURCE,
						LAT_LONG_REMARKS,
						MAX_ERROR_DISTANCE,
						MAX_ERROR_UNITS,
						ACCEPTED_LAT_LONG_FG,
						EXTENT,
						GPSACCURACY,
						GEOREFMETHOD,
						VERIFICATIONSTATUS
					) values (
						sq_lat_long_id.nextval,
						#nlid.nlid#,
						#DEC_LAT#,
						#DEC_LONG#,
						'#DATUM#',
						'decimal degrees',
						#determined_by_agent_id#,
						'#DETERMINED_DATE#',
						'#escapeQuotes(LAT_LONG_REF_SOURCE)#',
						'#escapeQuotes(LAT_LONG_REMARKS)#',
						<cfif len(MAX_ERROR_DISTANCE) gt 0>
							#MAX_ERROR_DISTANCE#,
						<cfelse>
							NULL,
						</cfif>
						'#MAX_ERROR_UNITS#',
						1,
						<cfif len(EXTENT) gt 0>
							#EXTENT#,
						<cfelse>
							NULL,
						</cfif>
						<cfif len(GPSACCURACY) gt 0>
							#GPSACCURACY#,
						<cfelse>
							NULL,
						</cfif>
						'#escapeQuotes(GEOREFMETHOD)#',
						'#escapeQuotes(VERIFICATIONSTATUS)#'
					)
				</cfquery>
				<cfquery name="isShared" datasource="uam_god">
					select count(*) c from cataloged_item where collecting_event_id=#elocid.collecting_event_id#
				</cfquery>
				<cfif isShared.c is 1>
					<br>moving collecting event
					<cfquery name="uce" datasource="uam_god">
						update collecting_event set LOCALITY_ID=#nlid.nlid# where collecting_event_id=#elocid.collecting_event_id#
					</cfquery>
					<cfquery name="q" datasource="uam_god">
						update bulkloader_undeletes set status='moved_single_event' where collection_object_id=#collection_object_id#
					</cfquery>
				<cfelse>
					<cfquery name="isShared2" datasource="uam_god">
						select count(*) c from collecting_event where 
						began_date='#began_date#' and 
						ended_date='#ended_date#' and 
						verbatim_date='#verbatim_date#' and 
						verbatim_locality='#verbatim_locality#'
						group by
						began_date,
						ended_date,
						verbatim_date,
						verbatim_locality
					</cfquery>
					<cfif isShared2.c is 1>
						<br>using existing shared event
						<cfquery name="uce" datasource="uam_god">
							update collecting_event set LOCALITY_ID=#nlid.nlid# where collecting_event_id=#elocid.collecting_event_id#
						</cfquery>
						<cfquery name="q" datasource="uam_god">
							update bulkloader_undeletes set status='moved_shared_event' where collection_object_id=#collection_object_id#
						</cfquery>
					<cfelse>
						<cfquery name="ncid" datasource="uam_god">
							select sq_COLLECTING_EVENT_ID.nextval ncid from dual
						</cfquery>
						<br>need new event: #ncid.ncid#
							<cfquery name="newEvent" datasource="uam_god">
								INSERT INTO collecting_event (
									COLLECTING_EVENT_ID,
									LOCALITY_ID,
									BEGAN_DATE,
									ENDED_DATE,
									VERBATIM_DATE,
									VERBATIM_LOCALITY,
									COLL_EVENT_REMARKS,
									COLLECTING_SOURCE,
									COLLECTING_METHOD,
									HABITAT_DESC
								) values (
									#ncid.ncid#,
									#nlid.nlid#,
									'#began_date#',
									'#ended_date#',
									'#escapeQuotes(verbatim_date)#',
									'#escapeQuotes(verbatim_locality)#',
									'#escapeQuotes(coll_event_remarks)#',
									'#escapeQuotes(collecting_source)#',
									'#escapeQuotes(collecting_method)#',
									'#escapeQuotes(habitat_desc)#'
								)
							</cfquery>
							<cfquery name="udci" datasource="uam_god">
								update cataloged_item set collecting_event_id=#ncid.ncid# where collection_object_id=#elocid.collection_object_id#
							</cfquery>
							
							<cfquery name="q" datasource="uam_god">
								update bulkloader_undeletes set status='created_event' where collection_object_id=#collection_object_id#
							</cfquery>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
		
				<!----

		<br>INSTITUTION_ACRONYM: #INSTITUTION_ACRONYM#
		<br>flatCollObjId: #collection_object_id#
		<br>cat_num: #cat_num#
		<br>#higher_geog#
		<br>#spec_locality#
		<br>#dec_lat#
		<br>#dec_long#
		<br>#verbatim_locality#
		<br>CurrentLocalityId: #elocid.locality_id#
		<br>elll: #elocid.dec_lat#
		
		
		<br>#verbatim_locality#
		<cfquery name="existDifferentFormSamePlace" datasource="uam_god">
			select
				locality.locality_id
			from
				locality,
				lat_long,
				geog_auth_rec
			where
				locality.locality_id=lat_long.locality_id (+) and
				locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
				locality.spec_locality='#spec_locality#' and
				geog_auth_rec.higher_geog='#higher_geog#' and
				lat_long.dec_lat=#dec_lat# and
				lat_long.dec_long=#dec_long#
		</cfquery>
		
		<cfdump var=#existDifferentFormSamePlace#>
		<cfquery name="exist" datasource="uam_god">
			select
				locality.locality_id
			from
				locality,
				lat_long,
				geog_auth_rec
			where
				locality.locality_id=lat_long.locality_id (+) and
				locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
				locality.spec_locality='#spec_locality#' and
				geog_auth_rec.higher_geog='#higher_geog#' and
				lat_long.orig_lat_long_units = 'decimal degrees' and
				lat_long.dec_lat=#dec_lat# and
				lat_long.dec_long=#dec_long#
		</cfquery>
		<cfif exist.recordcount is 0>
			<cfquery name="locexist" datasource="uam_god">
				select
					locality.locality_id
				from
					locality,
					lat_long,
					geog_auth_rec
				where
					locality.locality_id=lat_long.locality_id (+) and
					locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
					locality.spec_locality='#spec_locality#' and
					geog_auth_rec.higher_geog='#higher_geog#' and
					lat_long.locality_id is null
			</cfquery>
			<br>==========notfound
			<cfif locexist.recordcount is 0>
				<br>stillnotfound
			<cfelse>
				<cfdump var=#locexist#>
			</cfif>
		<cfelse>
			<br>---------------------------found #exist.recordcount#
		</cfif>
		---->
	</cftransaction>
</cfloop>
</cfoutput>

