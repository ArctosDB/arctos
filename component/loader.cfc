<cfcomponent>
	<cffunction name="validateSpecimenAttribute" access="public">
		<cfargument name="q" required="yes" type="query">
		<cfoutput>
			<cfif len(q.
		<cfquery name="presetstatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_attributes
			set
				status=decode(status,
					null,'click "get GUID Prefix" before validating',
					status || '; click "get GUID Prefix" before validating')
			where
				upper(username)='#ucase(session.username)#' and
				guid_prefix is null
		</cfquery>
		<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_attributes set COLLECTION_OBJECT_ID = (
				select
					cataloged_item.collection_object_id
				from
					cataloged_item,
					collection
				WHERE
					cataloged_item.collection_id = collection.collection_id and
					collection.guid_prefix = cf_temp_attributes.guid_prefix and
					cat_num=cf_temp_attributes.other_id_number
			) where
				status is null and
				other_id_type = 'catalog number'
				and upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfquery name="collObj_nci" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_attributes set COLLECTION_OBJECT_ID = (
				select
					cataloged_item.collection_object_id
				from
					cataloged_item,
					collection,
					coll_obj_other_id_num
				WHERE
					cataloged_item.collection_id = collection.collection_id and
					cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id and
					collection.guid_prefix = cf_temp_attributes.guid_prefix and
					other_id_type = cf_temp_attributes.other_id_type and
					display_value = cf_temp_attributes.other_id_number
			) where
				status is null and
				other_id_type != 'catalog number' and
				upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfquery name="collObj_fail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_attributes
			set
				status=decode(status,
					null,'cataloged item not found',
					status || '; cataloged item not found')
			where
				collection_object_id is null and
				upper(username)='#ucase(session.username)#'
		</cfquery>

		<cfquery name="iva" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_attributes
			set
				status=decode(status,
					null,'attribute failed validation',
					status || '; attribute failed validation')
				where
					isValidAttribute(
						ATTRIBUTE,
						ATTRIBUTE_VALUE,
						ATTRIBUTE_UNITS,
						(select collection_cde from collection where collection.guid_prefix=cf_temp_attributes.guid_prefix)
					)=0 and
					upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfquery name="chkDate" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_attributes
			set
				status=decode(status,
					null,'invalid date',
					status || '; invalid date')
			where
				ATTRIBUTE_DATE is not null and
				upper(username)='#ucase(session.username)#' and
				is_iso8601(ATTRIBUTE_DATE)!='valid'
		</cfquery>
		<cfquery name="attDet1" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_temp_attributes set DETERMINED_BY_AGENT_ID=getAgentID(determiner) where upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfquery name="attDetFail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_attributes
			set
				status=decode(status,
					null,'invalid determiner',
					status || '; invalid determiner')
			where
				DETERMINED_BY_AGENT_ID is null and
				determiner is not null and
				upper(username)='#ucase(session.username)#'
		</cfquery>
		<cfquery name="postsetstatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_attributes
			set
				status='valid'
			where
				status is null and
				upper(username)='#ucase(session.username)#'
		</cfquery>
		<cflocation url="BulkloadAttributes.cfm?action=manageMyStuff" addtoken="false">
	</cfoutput>
	
	
	
	
	
	
	
	
	</cffunction>
<!-------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="createSpecimenEvent" access="public">
		<cfargument name="q" required="yes" type="query">
		<cftry>
			<cftransaction>
				<!--- first find or build a locality --->
				<!--- if we have locality_name then we just need the ID --->
				<cfif len(q.locality_name) gt 0>
					<cfquery name="x" datasource="uam_god">
						select locality_id from locality where locality_name='#q.locality_name#'
					</cfquery>
					<cfset locid=x.locality_id>
				<cfelse>
					<!--- just build one, the merger scripts will deal with it ---->
					<cfquery name="nLocId" datasource="uam_god">
						select sq_locality_id.nextval nv from dual
					</cfquery>
					<cfset locid=nLocId.nv>
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
							wkt_polygon
						)  values (
							#locid#,
							(select geog_auth_rec_id from geog_auth_rec where higher_geog='#q.higher_geog#'),
							<cfif len(q.MAXIMUM_ELEVATION) gt 0>
								#q.MAXIMUM_ELEVATION#
							<cfelse>
								NULL
							</cfif>,
							<cfif len(q.MINIMUM_ELEVATION) gt 0>
								#q.MINIMUM_ELEVATION#
							<cfelse>
								NULL
							</cfif>,
							'#q.ORIG_ELEV_UNITS#',
							'#q.SPEC_LOCALITY#',
							'#q.LOCALITY_REMARKS#',
							'#q.DEPTH_UNITS#',
							<cfif len(q.MIN_DEPTH) gt 0>
								#q.MIN_DEPTH#
							<cfelse>
								NULL
							</cfif>,
							<cfif len(q.MAX_DEPTH) gt 0>
								#q.MAX_DEPTH#
							<cfelse>
								NULL
							</cfif>,
							<cfif len(q.c$LAT) gt 0>
								#q.c$LAT#
							<cfelse>
								NULL
							</cfif>,
							<cfif len(q.c$LONG) gt 0>
								#q.c$LONG#
							<cfelse>
								NULL
							</cfif>,
							<cfif len(q.MAX_ERROR_DISTANCE) gt 0>
								#q.MAX_ERROR_DISTANCE#
							<cfelse>
								NULL
							</cfif>,
							'#q.MAX_ERROR_UNITS#',
							'#q.DATUM#',
							'#q.georeference_source#',
							'#q.georeference_protocol#',
							 <cfqueryparam value="#q.wkt_polygon#" cfsqltype="cf_sql_clob">
						)
					</cfquery>
				</cfif>


				<!--- if we have collecting_event_name then we just need the ID --->
				<cfif len(q.collecting_event_name) gt 0>
					<cfquery name="x" datasource="uam_god">
						select collecting_event_id from collecting_event where collecting_event_name='#q.collecting_event_name#'
					</cfquery>
					<cfset ceid=x.collecting_event_id>
				<cfelse>
					<!---- just build one, let the cleanup scripts worry about the mess ---->
					<cfquery name="nCevId" datasource="uam_god">
						select sq_collecting_event_id.nextval nv from dual
					</cfquery>
					<cfset ceid=nCevId.nv>
					<cfquery name="makeEvent" datasource="uam_god">
			    		insert into collecting_event (
			    			collecting_event_id,
			    			locality_id,
			    			verbatim_date,
			    			VERBATIM_LOCALITY,
			    			began_date,
			    			ended_date,
			    			coll_event_remarks,
			    			LAT_DEG,
			    			DEC_LAT_MIN,
			    			LAT_MIN,
			    			LAT_SEC,
			    			LAT_DIR,
			    			LONG_DEG,
			    			DEC_LONG_MIN,
			    			LONG_MIN,
			    			LONG_SEC,
			    			LONG_DIR,
			    			DEC_LAT,
			    			DEC_LONG,
			    			DATUM,
			    			UTM_ZONE,
			    			UTM_EW,
			    			UTM_NS,
			    			ORIG_LAT_LONG_UNITS
			    		) values (
			    			#ceid#,
			    			#locid#,
			    			'#q.verbatim_date#',
			    			'#q.VERBATIM_LOCALITY#',
			    			'#q.began_date#',
			    			'#q.ended_date#',
			    			'#q.coll_event_remarks#',
			    			<cfif len(q.LAT_DEG) gt 0>
								#q.LAT_DEG#
							<cfelse>
								NULL
							</cfif>,
			    			<cfif len(q.DEC_LAT_MIN) gt 0>
								#q.DEC_LAT_MIN#
							<cfelse>
								NULL
							</cfif>,
			    			<cfif len(q.LAT_MIN) gt 0>
								#q.LAT_MIN#
							<cfelse>
								NULL
							</cfif>,
			    			<cfif len(q.LAT_SEC) gt 0>
								#q.LAT_SEC#
							<cfelse>
								NULL
							</cfif>,
			    			'#q.LAT_DIR#',
			    			<cfif len(q.LONG_DEG) gt 0>
								#q.LONG_DEG#
							<cfelse>
								NULL
							</cfif>,
			    			<cfif len(q.DEC_LONG_MIN) gt 0>
								#q.DEC_LONG_MIN#
							<cfelse>
								NULL
							</cfif>,
			    			<cfif len(q.LONG_MIN) gt 0>
								#q.LONG_MIN#
							<cfelse>
								NULL
							</cfif>,
			    			<cfif len(q.LONG_SEC) gt 0>
								#q.LONG_SEC#
							<cfelse>
								NULL
							</cfif>,
			    			'#q.LONG_DIR#',
			    			<cfif len(q.DEC_LAT) gt 0>
								#q.DEC_LAT#
							<cfelse>
								NULL
							</cfif>,
			    			<cfif len(q.DEC_LONG) gt 0>
								#q.DEC_LONG#
							<cfelse>
								NULL
							</cfif>,
			    			'#q.DATUM#',
			    			'#q.UTM_ZONE#',
			    			<cfif len(q.UTM_EW) gt 0>
								#q.UTM_EW#
							<cfelse>
								NULL
							</cfif>,
			    			<cfif len(q.UTM_NS) gt 0>
								#q.UTM_NS#
							<cfelse>
								NULL
							</cfif>,
			    			'#q.ORIG_LAT_LONG_UNITS#'
			    		)
	  				</cfquery>
				</cfif>
				<cfquery name="makeSpecEvent"  datasource="uam_god">
					INSERT INTO specimen_event (
			            COLLECTION_OBJECT_ID,
			            COLLECTING_EVENT_ID,
			            ASSIGNED_BY_AGENT_ID,
			            ASSIGNED_DATE,
			            SPECIMEN_EVENT_REMARK,
			            SPECIMEN_EVENT_TYPE,
			            COLLECTING_METHOD,
			            COLLECTING_SOURCE,
			            VERIFICATIONSTATUS,
			            HABITAT
			        ) VALUES (
			            #q.l_collection_object_id#,
			            #ceid#,
			            #q.l_event_assigned_id#,
			            '#q.ASSIGNED_DATE#',
			            '#q.SPECIMEN_EVENT_REMARK#',
			            '#q.SPECIMEN_EVENT_TYPE#',
			            '#q.COLLECTING_METHOD#',
			            '#q.COLLECTING_SOURCE#',
			            '#q.VERIFICATIONSTATUS#',
			            '#q.HABITAT#'
			        )
				</cfquery>
				<cfset r.guid=q.guid>
				<cfset r.collection_object_id=q.l_collection_object_id>
				<cfset r.key=q.key>
				<cfset r.status="success">

			</cftransaction>
		<cfcatch>
			<cfset r.key=q.key>
			<cfset r.status="FAIL: #cfcatch.message# #cfcatch.detail#">
		</cfcatch>
		</cftry>
		<cfreturn r>
	</cffunction>
<!-------------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="validateSpecimenEvent" access="public">
		<cfargument name="q" required="yes" type="query">
		<cfset problems="">
		<cfset checkEvent=true>
		<cfset checkLocality=true>
		<cfset r.key=q.key>
		<cfquery name="x" datasource="uam_god">
			select count(*) c from CTSPECIMEN_EVENT_TYPE where SPECIMEN_EVENT_TYPE='#q.SPECIMEN_EVENT_TYPE#'
		</cfquery>
		<cfif x.c is not 1>
			<cfset problems=listappend(problems,'invalid SPECIMEN_EVENT_TYPE')>
		</cfif>
		<cfif len(q.COLLECTING_SOURCE) gt 0>
			<cfquery name="x" datasource="uam_god">
				select count(*) c from CTCOLLECTING_SOURCE where COLLECTING_SOURCE='#q.COLLECTING_SOURCE#'
			</cfquery>
			<cfif x.c is not 1>
				<cfset problems=listappend(problems,'invalid COLLECTING_SOURCE')>
			</cfif>
		</cfif>

		<cfquery name="x" datasource="uam_god">
			select collection_object_id from flat where guid='#q.guid#'
		</cfquery>
		<cfif len(x.collection_object_id) is 0>
			<cfset problems=listappend(problems,'guid not found')>
		<cfelse>
			<cfset r.collection_object_id=x.collection_object_id>
		</cfif>

		<cfquery name="x" datasource="uam_god">
			select agent_id from agent_name where agent_name='#q.ASSIGNED_BY_AGENT#' group by agent_id
		</cfquery>
		<cfif x.recordcount is 1 and len(x.agent_id) gt 0>
			<cfset r.agent_id=x.agent_id>
		<cfelse>
			<cfset problems=listappend(problems,'ASSIGNED_BY_AGENT not found')>
		</cfif>

		<cfquery name="x" datasource="uam_god">
			select is_iso8601('#q.ASSIGNED_DATE#') isdate from dual
		</cfquery>

		<cfif x.isdate is not "valid">
			<cfset problems=listappend(problems,'ASSIGNED_DATE not a valid date')>
		</cfif>

		<cfif len(q.collecting_event_name) gt 0>
			<cfset checkEvent=false>
			<cfset checkLocality=false>
			<cfquery name="x" datasource="uam_god">
				select min(collecting_event_id) collecting_event_id from collecting_event where collecting_event_name='#q.collecting_event_name#'
			</cfquery>
			<cfif x.recordcount is not 1 or len(x.collecting_event_id) is 0>
				<cfset problems=listappend(problems,'not a valid collecting_event_name')>
			</cfif>
		</cfif>

		<cfif len(q.LOCALITY_NAME) gt 0>
			<cfset checkLocality=false>
			<cfquery name="x" datasource="uam_god">
				select min(LOCALITY_ID) LOCALITY_ID from LOCALITY where LOCALITY_NAME='#q.LOCALITY_NAME#'
			</cfquery>
			<cfif x.recordcount is not 1 or len(x.LOCALITY_ID) is 0>
				<cfset problems=listappend(problems,'not a valid LOCALITY_NAME')>
			</cfif>
		</cfif>


		<cfif checkEvent is true>
			<cfif len(q.VERBATIM_DATE) is 0>
				<cfset problems=listappend(problems,'VERBATIM_DATE is required',',')>
			</cfif>
			<cfif len(q.VERBATIM_LOCALITY) is 0>
				<cfset problems=listappend(problems,'VERBATIM_LOCALITY is required',',')>
			</cfif>
			<cfquery name="x" datasource="uam_god">
				select is_iso8601('#q.BEGAN_DATE#') isdate from dual
			</cfquery>
			<cfif x.isdate is not "valid">
				<cfset problems=listappend(problems,'BEGAN_DATE is not a valid date')>
			</cfif>
			<cfquery name="x" datasource="uam_god">
				select is_iso8601('#q.ENDED_DATE#') isdate from dual
			</cfquery>
			<cfif x.isdate is not "valid">
				<cfset problems=listappend(problems,'ENDED_DATE is not a valid date')>
			</cfif>
			<cfif len(q.ORIG_LAT_LONG_UNITS) gt 0>
				<cfquery name="x" datasource="uam_god">
					select count(*) c from CTLAT_LONG_UNITS where ORIG_LAT_LONG_UNITS='#q.ORIG_LAT_LONG_UNITS#'
				</cfquery>
				<cfif x.c is not 1>
					<cfset problems=listappend(problems,'ORIG_LAT_LONG_UNITS is not valid')>
				</cfif>
				<cfquery name="x" datasource="uam_god">
					select count(*) c from ctDATUM where DATUM='#q.DATUM#'
				</cfquery>
				<cfif x.c is not 1>
					<cfset problems=listappend(problems,'DATUM is not valid')>
				</cfif>
				<cfquery name="x" datasource="uam_god">
					select count(*) c from ctGEOREFERENCE_PROTOCOL where GEOREFERENCE_PROTOCOL='#q.GEOREFERENCE_PROTOCOL#'
				</cfquery>
				<cfif x.c is not 1>
					<cfset problems=listappend(problems,'GEOREFERENCE_PROTOCOL is not valid')>
				</cfif>
				<cfif q.ORIG_LAT_LONG_UNITS is "decimal degrees">
					<cfif q.DEC_LAT gt 90 or q.DEC_LAT lt -90 or q.DEC_LONG gt 180 or q.DEC_LONG lt -180>
						<cfset problems=listappend(problems,'coordinates not valid')>
					</cfif>
				<cfelseif q.orig_lat_long_units is 'deg. min. sec.'>
					<cfif q.LAT_DEG gt 90 or q.LAT_DEG lt 0 or
						q.LAT_MIN lt 0 or q.LAT_MIN gt 60 or
						q.LAT_SEC  lt 0 or q.LAT_SEC gt 60 or
						q.LONG_DEG gt 180 or q.LONG_DEG lt 0 or
						q.LONG_MIN lt 0 or q.LONG_MIN gt 60 or
						q.LONG_SEC  lt 0 or q.LONG_SEC gt 60 or
						(q.LAT_DIR is not "N" and q.LAT_DIR is not "S") or
						(q.LONG_DIR is not "W" and q.LONG_DIR is not "E")>
						<cfset problems=listappend(problems,'coordinates not valid')>
					</cfif>
				<cfelseif q.orig_lat_long_units is 'degrees dec. minutes'>
					<cfif q.LAT_DEG gt 90 or q.LAT_DEG lt 0 or
						q.DEC_LAT_MIN lt 0 or q.DEC_LAT_MIN gt 60 or
						q.LONG_DEG gt 180 or q.LONG_DEG lt 0 or
						q.DEC_LONG_MIN lt 0 or q.DEC_LONG_MIN gt 60 or
						(q.LAT_DIR is not "N" and q.LAT_DIR is not "S") or
						(q.LONG_DIR is not "W" and q.LONG_DIR is not "E")>
						<cfset problems=listappend(problems,'coordinates not valid')>
					</cfif>
				<cfelseif q.orig_lat_long_units is 'UTM'>
					<cfif not (isnumeric(q.UTM_EW) and isnumeric(q.UTM_NS))>
						<cfset problems=listappend(problems,'coordinates not valid')>
					</cfif>
				</cfif>
			</cfif><!---- END len(ORIG_LAT_LONG_UNITS) gt 0 --->
		</cfif><!--- END  checkEvent is true --->

		<cfif checkLocality is true>
			<cfif  len(q.orig_lat_long_units) gt 0 AND
			   (
			       len(q.datum) is 0 or
			       len(q.GEOREFERENCE_SOURCE) is 0 or
			       len(q.GEOREFERENCE_PROTOCOL) is 0
			   )>
				<cfset problems=listappend(problems,'invalid datum,GEOREFERENCE_SOURCE,GEOREFERENCE_PROTOCOL')>
			</cfif>

			<cfif len(q.SPEC_LOCALITY) is 0>
				<cfset problems=listappend(problems,'SPEC_LOCALITY is required')>
			</cfif>
			<cfif len(q.ORIG_ELEV_UNITS) gt 0>
				<cfquery name="x" datasource="uam_god">
					select count(*) c from ctORIG_ELEV_UNITS where ORIG_ELEV_UNITS='#q.ORIG_ELEV_UNITS#'
				</cfquery>
				<cfif x.c is not 1>
					<cfset problems=listappend(problems,'ORIG_ELEV_UNITS is not valid')>
				</cfif>
				<cfif len(q.MINIMUM_ELEVATION) is 0 or len(q.MAXIMUM_ELEVATION) is 0 or (not isnumeric(q.MINIMUM_ELEVATION))
					 or (not isnumeric(q.MAXIMUM_ELEVATION)) or (q.MINIMUM_ELEVATION gt q.MAXIMUM_ELEVATION)>
					<cfset problems=listappend(problems,'elevation is wonky')>
				</cfif>
			</cfif>
			<cfif len(q.DEPTH_UNITS) gt 0>
				<cfquery name="x" datasource="uam_god">
					select count(*) c from ctDEPTH_UNITS where DEPTH_UNITS='#q.DEPTH_UNITS#'
				</cfquery>
				<cfif x.c is not 1>
					<cfset problems=listappend(problems,'DEPTH_UNITS is not valid')>
				</cfif>
				<cfif len(q.MIN_DEPTH) is 0 or len(q.MAX_DEPTH) is 0 or (not isnumeric(q.MIN_DEPTH))
					 or (not isnumeric(q.MAX_DEPTH)) or (q.MIN_DEPTH gt q.MAX_DEPTH)>
					<cfset problems=listappend(problems,'depth is wonky')>
				</cfif>
			</cfif>
			<cfif len(q.MAX_ERROR_UNITS) gt 0>
				<cfquery name="x" datasource="uam_god">
					select count(*) c from CTLAT_LONG_ERROR_UNITS  where LAT_LONG_ERROR_UNITS='#q.MAX_ERROR_UNITS#'
				</cfquery>
				<cfif x.c is not 1>
					<cfset problems=listappend(problems,'MAX_ERROR_UNITS is not valid')>
				</cfif>
				<cfif len(q.MAX_ERROR_DISTANCE) is 0>
					<cfset problems=listappend(problems,'MAX_ERROR_DISTANCE is required when MAX_ERROR_UNITS is given')>
				</cfif>
			</cfif>
			<!--- if we made it here we need higher_geog ---->
			<cfquery name="x" datasource="uam_god">
				select count(*) c from GEOG_AUTH_REC where HIGHER_GEOG='#q.HIGHER_GEOG#'
			</cfquery>
			<cfif x.c is not 1>
				<cfset problems=listappend(problems,'invalid HIGHER_GEOG')>
			</cfif>

		</cfif><!---- END checkLocality is true --->
		<cfif len(problems) is 0>
			<cfset problems="precheck_pass">
		</cfif>
		<cfset r.problems=problems>
		<cfreturn r>
	</cffunction>
</cfcomponent>