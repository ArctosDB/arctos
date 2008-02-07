<cfinclude template="BulkloaderCheck.cfm" />

<!--- see if there are things that we can use already loaded --->
<!--- locality --->
<!--- geog_auth_rec entry must exist and has already been checked, so see if there is a viable 
	 lat/long and locality conbination --->
	  
	  <cftry>
	  <cfquery name="dateformat" datasource="#mcat#">
	  	alter session set nls_date_format = 'DD-Mon-YYYY'
	  </cfquery>
	  <cfcatch>
	  	<!--- probably postgres - just ignore this --->
	  </cfcatch>
	  </cftry>
<!--- Oracle doesn't get "...=null..." in select statements, so clean and don't send null values --->

			
<cfoutput query="oneRecord">

<!--- fix single quotes in strings as needed using custom tag s2d --->

	

<!--- load the record --->
<!--- start the actual insert --->
<cfif len(#loadedMsg#) is 0>
<!--- load the record - no problems --->
<!--- Get pkey values that we don't already have --->
	<!--- 
		See if the locality exists. If it does, use it. If it does not, create a new one. If more than one matching locality 
		exists, abort and force a data fix.
	--->	
<cfif len(#locality_id#) is 0><!--- proceed with normal locality validation ---->
<cfset isLL = "SELECT 
				locality.locality_id">
				<cfif len(#orig_lat_long_units#) gt 0>
					<cfset isLL = "#isLL#,accepted_lat_long.lat_long_id">
				</cfif>
				<cfset isLL = "#isLL# FROM locality">
				<cfif len(#orig_lat_long_units#) gt 0>
					<cfset isLL = "#isLL#,accepted_lat_long">
				</cfif>
				
				<cfset isLL = "#isLL#
	 	WHERE 	
	 		locality.geog_auth_rec_id =  #geogauthrecid# ">
			<cfif len(#orig_lat_long_units#) gt 0>
				<!--- got a lat/long to match, otherwise no lat/long --->
				<cfset isLL = "#isLL# AND
					locality.locality_id = accepted_lat_long.locality_id">
			</cfif>
			
			<cfif not (#maximum_elevation#) is "">
				<cfset isLL = "#isLL# AND locality.maximum_elevation = #maximum_elevation#">
			<cfelse>
				<cfset isLL = "#isLL# AND locality.maximum_elevation is null">
			</cfif>
			<cfif not (#minimum_elevation#) is "">
				<cfset isLL = "#isLL# AND locality.minimum_elevation = #minimum_elevation#">
			<cfelse>
				<cfset isLL = "#isLL# AND locality.minimum_elevation is null">
			</cfif>
			<cfif not (#orig_elev_units#) is "">
				<cfset isLL = "#isLL# AND locality.orig_elev_units = '#orig_elev_units#'">
			<cfelse>
				<cfset isLL = "#isLL# AND locality.orig_elev_units is null">
			</cfif>
			<cfif not (#spec_locality#) is "">
				<cfset isLL = "#isLL# AND locality.spec_locality = '#replace(spec_locality,"'","''","all")#'">
			<cfelse>
				<cfset isLL = "#isLL# AND locality.spec_locality is null">
			</cfif>
			<cfif not (#locality_remarks#) is "">
				<cfset isLL = "#isLL# AND locality.locality_remarks = '#replace(locality_remarks,"'","''","all")#'">
			<cfelse>
				<cfset isLL = "#isLL# AND locality.locality_remarks is null">
			</cfif>
			<cfif len(#orig_lat_long_units#) gt 0>
				<cfif not (#datum#) is "">
					<cfset isLL = "#isLL# AND accepted_lat_long.datum = '#datum#'">
				<cfelse>
					<cfset isLL = "#isLL# AND accepted_lat_long.datum is null">
				</cfif>
								
				<cfset isLL = "#isLL# AND accepted_lat_long.orig_lat_long_units = '#orig_lat_long_units#'
				 AND accepted_lat_long.determined_by_agent_id = #llagentid#
				 AND accepted_lat_long.determined_date = '#dateformat(determined_date,"dd-mmm-yyyy")#'
				 AND accepted_lat_long.lat_long_ref_source = '#replace(lat_long_ref_source,"'","''","all")#'
				 AND accepted_lat_long.max_error_distance = #max_error_distance#
				 AND accepted_lat_long.max_error_units = '#max_error_units#'
				 AND verificationstatus='#verificationstatus#' 
				 AND georefmethod='#georefmethod#'">
	
				<cfif len(#lat_long_remarks#) gt 0>
					<cfset llremks = replace(lat_long_remarks,"'","''","all")>
					<cfset isLL = "#isLL# AND accepted_lat_long.lat_long_remarks = '#llremks#'">
				<cfelse>
					<cfset isLL = "#isLL# AND accepted_lat_long.lat_long_remarks is null">
				</cfif>
				<cfif #orig_lat_long_units# is "decimal degrees">
					<cfset isLL = "#isLL# AND accepted_lat_long.dec_lat = #dec_lat#
							AND accepted_lat_long.dec_long = #dec_long#">
				</cfif>
				<cfif #orig_lat_long_units# is "deg. min. sec.">
							<cfset isLL = "#isLL# AND accepted_lat_long.lat_deg = #latdeg#
								AND accepted_lat_long.lat_dir = '#latdir#'
								AND accepted_lat_long.long_deg = #longdeg#
								AND accepted_lat_long.long_dir = '#longdir#'
								AND accepted_lat_long.lat_min = #latmin#
								AND accepted_lat_long.lat_sec = #latsec#
								AND accepted_lat_long.long_min = #longmin#
								AND accepted_lat_long.long_sec = #longsec#">
				</cfif>
				<cfif #orig_lat_long_units# is "degrees dec. minutes">
							<cfset isLL = "#isLL# AND accepted_lat_long.lat_deg = #latdeg#
								AND accepted_lat_long.lat_dir = '#latdir#'
								AND accepted_lat_long.long_deg = #longdeg#
								AND accepted_lat_long.long_dir = '#longdir#'
								AND accepted_lat_long.dec_lat_min = #dec_lat_min#
								AND accepted_lat_long.dec_long_min = #dec_long_min#">
				</cfif>
			<cfelse>
				<!--- no lat/long give, find only localities without a lat/long ---->
				<cfset isLL = "#isLL# AND locality.locality_id NOT IN (select locality_id from accepted_lat_long)">
			</cfif>
			
			<cfif len(#depth_Units#) gt 0>
				<cfset isLL = "#isLL# AND depth_units = '#depth_units#' AND min_depth=#min_depth# AND max_depth=#max_depth#">
			<cfelse>
				<cfset isLL = "#isLL# AND depth_units is null AND min_depth is null AND max_depth is null">
			</cfif>

<cfif #loadedMsg# does not contain "The lat long determining agent was not found." 
	and #loadedMsg# does not contain "higher geography"><!--- see if we got a valid determiner ---->
	 <cfquery name="isLLLoc" datasource="#mcat#">
	 	#preservesinglequotes(isLL)#
	 </cfquery>
	 <!----
	 <hr>
	 #preservesinglequotes(isLL)#
	 <p> isLLLoc.recordcount: #isLLLoc.recordcount#</p>
	 <cfabort>
	 ---->
	<cfif isLLLoc.recordcount is 1><!--- exactly one match  - yeaa!!! --->
		<cfset localityid = isLLLoc.locality_id>
	<cfelseif isLLLoc.recordcount gt 1>
		<cfset loadedMsg = "#loadedMsg#; #isLLLoc.recordcount# existing localities (#isllloc.locality_id#) match your locality criteria. Fix the redundant locality and try again.">
	 <cfelseif isLLLoc.recordcount is 0>
		<cfquery name="getLoID" datasource="#mcat#">
			SELECT max(locality_id) as maxid FROM locality
		</cfquery>
		<cfset localityid = getLoID.maxid + 1>
		<cfquery name="getLLID" datasource="#mcat#">
			SELECT max(lat_long_id) as maxid FROM lat_long
		</cfquery>
		<cfset latlongid = getLLID.maxid + 1>
	</cfif>
<cfelse><!--- they specified an existing locality --->
	<cfset localityid = #locality_id#>
</cfif>
		<cfset isCol = "SELECT collecting_event_id FROM collecting_event WHERE
			locality_id = #localityid# AND
			verbatim_date = '#replace(verbatim_date,"'","''","all")#'
			AND began_date = '#dateformat(began_date,"dd-mmm-yyyy")#'
			AND ended_date = '#dateformat(ended_date,"dd-mmm-yyyy")#'
			AND  DATE_DETERMINED_BY_AGENT_ID = 0">
			<cfif not (#coll_event_remarks#) is "">
				<cfset isCol = "#isCol# AND coll_event_remarks = '#replace(coll_event_remarks,"'","''","all")#'">
			<cfelse>
				<cfset isCol = "#isCol# AND coll_event_remarks is null">
			</cfif>
			<cfif len(#collecting_source#) gt 0>
				<cfset isCol = "#isCol# AND collecting_source = '#collecting_source#'">
			<cfelse>
				<!--- allow default --->
				<cfset isCol = "#isCol# AND collecting_source = 'wild caught'">
			</cfif>
			<cfif len(#collecting_method#) gt 0>
				<cfset isCol = "#isCol# AND collecting_method = '#collecting_method#'">
			<cfelse>
				<cfset isCol = "#isCol# AND collecting_method is NULL">
			</cfif>
			<cfif len(#localityid#) gt 0>
				<cfquery name="isColID" datasource="#mcat#">
					#preservesinglequotes(isCol)#
				 </cfquery>
				 <!-----
				 <hr>
				 #preservesinglequotes(isCol)#
				 <hr>
				 isColID.recordcount: #isColID.recordcount#
				 <cfabort>
				 ----->
				 <cfif isColID.recordcount is 1>
					<cfset collectingeventid = isColID.collecting_event_id>
				<cfelseif isColID.recordcount gt 1>
					<cfset loadedMsg = "#loadedMsg#; More than one existing collecting event matches your criteria. 
						Fix the redundant collecting event and try again.">
				<cfelseif isColID.recordcount is 0>
					<cfquery name="getCollID" datasource="#mcat#">
						SELECT max(collecting_event_id) as maxid FROM collecting_event
					</cfquery>
					<cfset collectingeventid = getCollID.maxid + 1>
				</cfif>
			</cfif>
</cfif><!--- end see if we got a determiner ----->

	<cfquery name="getIDid" datasource="#mcat#">
		SELECT max(identification_id) as maxid FROM identification
	</cfquery>
		<cfset identificationid = getIDid.maxid + 1>
	<cfquery name="getCatcollid" datasource="#mcat#">
		SELECT max(collection_object_id) as maxid FROM coll_object
	</cfquery>
		<cfset catcollid = getCatcollid.maxid + 1>
	<cfquery name="getAttId" datasource="#mcat#">
		SELECT max(attribute_id) as maxid FROM attributes
	</cfquery>
		<cfset attributeid = getAttId.maxid + 1>

	<cftransaction><!--- don't commit unless we get all insert statements to run --->
	<cfif len(#relationship#) gt 0>
		<cfquery name="insReln" datasource="#mcat#">
			insert into cf_temp_relations (
				collection_object_id,
				relationship,
				related_to_number,
				related_to_num_type)
			VALUES (
				#catcollid#,
				'#relationship#',
				'#related_to_number#',
				'#related_to_num_type#')
		</cfquery>
	</cfif>
	<cfif len(#vessel#) gt 0>
		<!---- see if we have an existing vessel entry ---->
		<cfset sql="select * from vessel where
			vessel='#vessel#' AND collecting_event_id=#collectingeventid#">
			<cfif station_name is not "">
				<cfset sql="#sql# AND station_name = '#replace(station_name,"'","''","all")#'">
			<cfelse>
				<cfset sql="#sql# AND station_name is null">
			</cfif>
			<cfif station_number is not "">
				<cfset sql="#sql# AND station_number = '#replace(station_number,"'","''","all")#'">
			<cfelse>
				<cfset sql="#sql# AND station_number is null">
			</cfif>
		<cfquery name="isVessel" datasource="#mcat#">
			#preservesinglequotes(sql)#			
		</cfquery>
		<cfif #isVessel.recordcount# is 0>
			<cfset sql="INSERT INTO vessel (
				vessel,
				collecting_event_id">
			<cfif station_name is not "">
				<cfset sql="#sql# ,station_name">
			</cfif>
			<cfif station_number is not "">
				<cfset sql="#sql# ,station_number">
			</cfif>
			<cfset sql="#sql# ) VALUES (
				'#vessel#',
				#collectingeventid#">
			<cfif stationName is not "">
				<cfset sql="#sql# ,'#stationName#'">
			</cfif>
			<cfif stationNumber is not "">
				<cfset sql="#sql# ,'#stationNumber#'">
			</cfif>
			<cfset sql="#sql# )">
			
			<cfquery name="isVessel" datasource="#mcat#">
				#preservesinglequotes(sql)#			
			</cfquery>
			<!--- do nothing if we already have a vessel - it's a vessel-->coll event relationship ---->
		</cfif>
	</cfif>
	<cfif len(#locality_id#) is 0>
	<cfif isLLLoc.recordcount is 0><!--- build a new lat/long and locality --->
		<cfset thisSQL = "
			INSERT INTO locality (
			LOCALITY_ID,
			GEOG_AUTH_REC_ID">
			<cfif len(#orig_elev_units#) gt 0>
				<cfset thisSql = "#thisSql#
				,MAXIMUM_ELEVATION
				,MINIMUM_ELEVATION
				,ORIG_ELEV_UNITS
				">
			</cfif>
			<cfif len(#SPEC_LOCALITY#) gt 0>
				<cfset thisSql = "#thisSql#	,SPEC_LOCALITY">
			</cfif>
			<cfif len(#LOCALITY_REMARKS#) gt 0>
				<cfset thisSql = "#thisSql# ,LOCALITY_REMARKS">
			</cfif>
			<cfif #DEPTH_UNITS# is not "">
				<cfset thisSQL = "#thisSQL#
						,DEPTH_UNITS
						,min_DEPTH
						,max_depth">
	</cfif>
		<cfset thisSQL = "#thisSQL# )
					VALUES (
						#localityid#,
						#geogauthrecid#">
						<cfif len(#orig_elev_units#) gt 0>
							<cfset thisSQL = "#thisSQL#
								,#maximum_elevation#
								,#minimum_elevation#
								,'#orig_elev_units#'">
						</cfif>
						<cfif len(#spec_locality#) gt 0>
							<cfset thisSQL = "#thisSQL#
								,'#replace(spec_locality,"'","''","all")#'">
						</cfif>
						<cfif len(#locality_remarks#) gt 0>
							<cfset thisSql = "#thisSql#
							,'#replace(locality_remarks,"'","''","all")#'">
						</cfif>
						<cfif #depth_Units# is not "">
							<cfset thisSQL = "#thisSQL#
										,'#depth_Units#',
										#min_Depth#,
										#max_Depth#">
						</cfif>
						<cfset thisSQL = "#thisSQL# )">
						<cfquery name="makeLocality" datasource="#mcat#">
							#preservesinglequotes(thisSQL)#
						</cfquery>
		
						<cfif len(#orig_lat_long_units#) gt 0>
							<cfset thisSQL = "INSERT INTO lat_long (
								LAT_LONG_ID,
								LOCALITY_ID
								,datum
								,ORIG_LAT_LONG_UNITS
								,DETERMINED_BY_AGENT_ID
								,DETERMINED_DATE
								,LAT_LONG_REF_SOURCE
								,MAX_ERROR_DISTANCE
								,MAX_ERROR_UNITS
								,ACCEPTED_LAT_LONG_FG
				,verificationstatus,georefmethod">
								<cfif len(#LAT_LONG_REMARKS#) gt 0>
									<cfset thisSQL = "#thisSql#,LAT_LONG_REMARKS">
								</cfif>
								<cfif #orig_lat_long_units# is "decimal degrees">
									<cfset thisSQL = "#thisSQL#,dec_lat,dec_long">
								</cfif>
								<cfif #orig_lat_long_units# is "deg. min. sec.">
									<cfset thisSQL = "#thisSQL#
										,lat_deg
										,lat_min
										,lat_sec
										,lat_dir
										,long_deg
										,long_min
										,long_sec
										,long_dir">
								</cfif>
								<cfif #orig_lat_long_units# is "degrees dec. minutes">
									<cfset thisSQL = "#thisSQL#
										,lat_deg
										,dec_lat_min
										,lat_dir
										,long_deg
										,dec_long_min
										,long_dir">
								</cfif>
								<cfset thisSQL = "#thisSql#) VALUES (
									#latlongid#
									,#localityid#
									,'#datum#'
									,'#ORIG_LAT_LONG_UNITS#'
									,#llagentid#
									,'#dateformat(DETERMINED_DATE,"dd-mmm-yyyy")#'
									,'#replace(LAT_LONG_REF_SOURCE,"'","''","all")#'
									,#MAX_ERROR_DISTANCE#
									,'#MAX_ERROR_UNITS#'
									,1
				,'#verificationstatus#' 
				,'#georefmethod#'">
								<cfif len(#LAT_LONG_REMARKS#) gt 0>
									<cfset thisSQL = "#thisSql#,'#replace(LAT_LONG_REMARKS,"'","''","all")#'">
								</cfif>
								<cfif #orig_lat_long_units# is "decimal degrees">
									<cfset thisSQL = "#thisSQL#,#dec_lat#,#dec_long#">
								</cfif>
								<cfif #orig_lat_long_units# is "deg. min. sec.">
									<cfset thisSQL = "#thisSQL#
										,#latdeg#
										,#latmin#
										,#latsec#
										,'#latdir#'
										,#longdeg#
										,#longmin#
										,#longsec#
										,'#longdir#'">
								</cfif>
								<cfif #orig_lat_long_units# is "degrees dec. minutes">
									<cfset thisSQL = "#thisSQL#
										,#latdeg#
										,#dec_lat_min#
										,'#latdir#'
										,#longdeg#
										,#dec_long_min#
										,'#longdir#'">
										
								</cfif>
								<cfset thisSQL = "#thisSQL#)">
								
					<cfquery name="makeLatLong" datasource="#mcat#">
						#preservesinglequotes(thisSQL)#
					</cfquery>
			</cfif>
	  </cfif><!--- end build new lat/long and locality --->
	  
  </cfif><!--- end existing locality bypass ---->
	<cfif isColID.recordcount is 0><!--- build a new collecting_event --->
			<cfset VERBATIM_LOCALITY = replace(VERBATIM_LOCALITY,"'","''","all")>
			<cfset VERBATIM_DATE = replace(VERBATIM_DATE,"'","''","all")>
			<cfset COLL_EVENT_REMARKS = replace(COLL_EVENT_REMARKS,"'","''","all")>
			<cfset habitat_desc = replace(habitat_desc,"'","''","all")>
			
			<cfset thisSQL = "INSERT INTO collecting_event (
								COLLECTING_EVENT_ID,
								LOCALITY_ID,
								VALID_DISTRIBUTION_FG,
								COLLECTING_SOURCE,
								BEGAN_DATE,
								ENDED_DATE,
								VERBATIM_DATE,
								VERBATIM_LOCALITY,
								DATE_DETERMINED_BY_AGENT_ID">
							<cfif len(#COLL_EVENT_REMARKS#) gt 0>
								<cfset thisSQL = "#thisSQL#,COLL_EVENT_REMARKS">
							</cfif>
							<cfif len(#habitat_desc#) gt 0>
								<cfset thisSQL = "#thisSQL#,habitat_desc">
							</cfif>
							<cfif len(#collecting_method#) gt 0>
								<cfset thisSQL = "#thisSQL#,collecting_method">
							</cfif>
								<cfset thisSQL = "#thisSQL# ) VALUES (
									#collectingeventid#,
									#localityid#,
									1,">
									<cfif len(#collecting_source#) gt 0>
										<cfset thisSQL = "#thisSQL# '#collecting_source#',">
									<cfelse>
										<cfset thisSQL = "#thisSQL# 'wild caught',">
									</cfif>
									<cfset thisSQL = "#thisSQL#
									'#dateformat(BEGAN_DATE,"dd-mmm-yyyy")#',
									'#dateformat(ENDED_DATE,"dd-mmm-yyyy")#',
									'#replace(VERBATIM_DATE,"'","''","all")#',
									'#replace(VERBATIM_LOCALITY,"'","''","all")#',
									0">
									<cfif len(#COLL_EVENT_REMARKS#) gt 0>
										<cfset thisSQL = "#thisSQL#,'#replace(coll_event_remarks,"'","''","all")#'">
									</cfif>
									<cfif len(#habitat_desc#) gt 0>
										<cfset thisSQL = "#thisSQL#,'#habitat_desc#'">
									</cfif>
									<cfif len(#collecting_method#) gt 0>
										<cfset thisSQL = "#thisSQL#,'#collecting_method#'">
									</cfif>
									<cfset thisSQL = "#thisSQL# )">
								

		<cfquery name="makeCollEvent" datasource="#mcat#">
			#preservesinglequotes(thisSQL)#
		</cfquery>
		
		
	</cfif><!--- end build new collecting event --->
				
			<cfset thisSQL = "INSERT INTO coll_object (
					COLLECTION_OBJECT_ID,
					COLL_OBJECT_TYPE,
					ENTERED_PERSON_ID,
					COLL_OBJECT_ENTERED_DATE,
					COLL_OBJ_DISPOSITION,
					LOT_COUNT,
					CONDITION">
				<cfif len(#FLAGS#) gt 0>
					<cfset thisSQL = "#thisSQL#,FLAGS">
				</cfif>	
					<cfset thisSQL = "#thisSQL#	) VALUES (
					#catcollid#,
					'CI',
					#enteredbyid#,
					'#entereddate#',
					'#coll_obj_disposition#',
					1,
					'#condition#'">
				<cfif len(#FLAGS#) gt 0>
					<cfset thisSQL = "#thisSQL#,'#FLAGS#'">
				</cfif>	
					<cfset thisSQL = "#thisSQL#	)">
			<!--- make the cataloged item collection_object for every record --->
			<cfquery name="makeCatCollObject" datasource="#mcat#">
				#preservesinglequotes(thisSQL)#
			</cfquery>

<cfset thisSQL = "INSERT INTO cataloged_item (
					COLLECTION_OBJECT_ID,
					CAT_NUM,
					ACCN_ID,
					COLLECTING_EVENT_ID,
					COLLECTION_CDE,
					CATALOGED_ITEM_TYPE,
					COLLECTION_ID
					)
				VALUES (
					#catcollid#,
					#catnum#,
					#transactionid#,
					#collectingeventid#,
					'#collection_cde#',
					'BI',
					#collectionid#
					)">
			<!--- make a cataloged_item for every record. --->		
			<cfquery name="makeCatItem" datasource="#mcat#">
				#preservesinglequotes(thisSQL)#
			</cfquery>
			
			<!--- make a coll_object_remark if its needed --->
			<cfif not (#disposition_remarks# is "") OR not (#coll_object_remarks# is "")>
				<cfset thisSQL = "INSERT INTO coll_object_remark (
					COLLECTION_OBJECT_ID">
				<cfif len(#disposition_remarks#) gt 0>
					<cfset thisSQL = "#thisSQL#,DISPOSITION_REMARKS">
				</cfif>	
				<cfif len(#COLL_OBJECT_REMARKS#) gt 0>
					<cfset thisSQL = "#thisSQL#,COLL_OBJECT_REMARKS">
				</cfif>	
				<cfif len(#associated_species#) gt 0>
					<cfset thisSQL = "#thisSQL#,associated_species">
				</cfif>	
				<cfif len(#coll_object_habitat#) gt 0>
					<cfset thisSQL = "#thisSQL#,habitat">
				</cfif>	
				<cfset thisSQL = "#thisSQL# ) VALUES ( #catcollid#">
				<cfif len(#DISPOSITION_REMARKS#) gt 0>
					<cfset DISPOSITION_REMARKS=replace(DISPOSITION_REMARKS,"'","''","all")>
					<cfset thisSQL = "#thisSQL#,'#DISPOSITION_REMARKS#'">
				</cfif>	
				<cfif len(#COLL_OBJECT_REMARKS#) gt 0>
					<cfset thisSQL = "#thisSQL#,'#replace(COLL_OBJECT_REMARKS,"'","''","all")#'">
				</cfif>	
				<cfif len(#associated_species#) gt 0>
					<cfset thisSQL = "#thisSQL#,'#associated_species#'">
				</cfif>	
				<cfif len(#coll_object_habitat#) gt 0>
					<cfset thisSQL = "#thisSQL#,'#replace(coll_object_habitat,"'","''","all")#'">
				</cfif>	
				<cfset thisSQL = "#thisSQL# )">
		
			<cfquery name="makeCollObjRem" datasource="#mcat#">
				#preservesinglequotes(thisSQL)#
			</cfquery>
		</cfif><!--- end make coll_object_remark --->
		<!------ attribute 1 ---->
		<!------------------------------------ attributes --------------------------------------------->
		<cfloop from="1" to="#numberOfAttributes#" index="i">
			<cfset thisAttribute="attribute_" & #i#>
			<cfset thisValue="attribute_value_" & #i#>
			<cfset thisUnits="attribute_units_" & #i#>
			<cfset thisRemark="attribute_remarks_" & #i#>
			<cfset thisDate="attribute_date_" & #i#>
			<cfset thisMethod="attribute_det_meth_" & #i#>
			<cfset thisDeterminer="attribute_determiner_" & #i#>
			
			<cfset thisAttributeValue = evaluate(#thisAttribute#)>
			<cfset thisValueValue = evaluate(#thisValue#)>
			<cfset thisUnitsValue = evaluate(#thisUnits#)>
			<cfset thisRemarkValue = evaluate(#thisRemark#)>
			<cfset thisDateValue = evaluate(#thisDate#)>
			<cfset thisMethodValue = evaluate(#thisMethod#)>
			<cfset thisDeterminerValue = evaluate(#thisDeterminer#)>
		
			<cfset thisAttributeValue = trim(thisAttributeValue)>
			<cfset thisValueValue = trim(thisValueValue)>
			<cfset thisUnitsValue = trim(thisUnitsValue)>
			<cfset thisRemarkValue = trim(thisRemarkValue)>
			<cfset thisDateValue = trim(thisDateValue)>
			<cfset thisMethodValue = trim(thisMethodValue)>
			<cfset thisDeterminerValue = trim(thisDeterminerValue)>
	
			<cfif len(#thisAttributeValue#) gt 0 and len(#thisValueValue#) gt 0>
				<!---- GET DETERMINER ID ---->
				<cfquery name="attDetId" datasource="#mcat#">
					SELECT agent_id ThisDeterminerID from agent_name WHERE
					agent_name='#thisDeterminerValue#'
					and agent_name_type <> 'Kew abbr.'
				</cfquery>
				<cfset ThisDeterminerID=#attDetId.ThisDeterminerID#>
				<cfset thisSql = "INSERT INTO attributes (
					attribute_id,
					collection_object_id,
					determined_by_agent_id,
					attribute_type,
					attribute_value">
					<cfif len(#thisDateValue#) gt 0>
						<cfset thisSql = "#thisSql#, determined_date">
					</cfif>
					<cfif len(#thisUnitsValue#) gt 0>
						<cfset thisSql = "#thisSql#, attribute_units">
					</cfif>
					<cfif len(#thisMethodValue#) gt 0>
						<cfset thisSql = "#thisSql#, determination_method">
					</cfif>
					<cfif len(#thisRemarkValue#) gt 0>
						<cfset thisSql = "#thisSql#, attribute_remark">
					</cfif>
					<cfset thisSql = "#thisSql# ) VALUES (
						#attributeid#,
						#catcollid#,
						#ThisDeterminerID#,
						'#thisAttributeValue#',
						'#replace(thisValueValue,"'","''","all")#'">
						<cfif #thisDateValue# is not "">
							<cfset thisSql = "#thisSql#, '#dateformat(thisDateValue,"dd-mmm-yyyy")#'">
						</cfif>
						<cfif #thisUnitsValue# is not "">
							<cfset thisSql = "#thisSql#, '#thisUnitsValue#'">
						</cfif>
						<cfif #thisMethodValue# is not "">
							<cfset thisSql = "#thisSql#, '#thisMethodValue#'">
						</cfif>
						<cfif #thisRemarkValue# is not "">
							<cfset thisSql = "#thisSql#, '#thisRemarkValue#'">
						</cfif>
						<cfset thisSql = "#thisSql#)">			
				<cfquery name="att" datasource="#mcat#">
					#preservesinglequotes(thisSql)#
				</cfquery>
				<cfset attributeid = #attributeid# +1>
			</cfif>
		</cfloop>
	
		
		<!--- everything gets an identification --->
		<cfset thisSQL = "	INSERT INTO identification (
					 IDENTIFICATION_ID,
					 COLLECTION_OBJECT_ID,
					 ID_MADE_BY_AGENT_ID,
					 NATURE_OF_ID,
					 ACCEPTED_ID_FG,
					  taxa_formula,
					 scientific_name ">
					<CFIF LEN(#MADE_DATE#) GT 0>
					 	<cfset thisSQL = "#thisSQL#,MADE_DATE">
		 			</CFIF> 
					<CFIF LEN(#identification_remarks#) GT 0>
					 	<cfset thisSQL = "#thisSQL#,IDENTIFICATION_REMARKS">
		 			</CFIF> 
					<cfset thisSQL = "#thisSQL# )
				VALUES (
					#identificationid#,
					 #catcollid#,
					 #idmadebyagentid#,
					 '#nature_of_id#',
					 1,
					 '#taxa_formula#',
					 '#taxon_name#'">
					 <CFIF LEN(#made_date#) GT 0>
					 	<cfset thisSQL = "#thisSQL#,'#dateformat(made_date,"dd-mmm-yyyy")#'">
					 </CFIF>  
					 <CFIF LEN(#identification_remarks#) GT 0>
					 	<cfset thisSQL = "#thisSQL#,'#replace(identification_remarks,"'","''","all")#'">
					 </CFIF>  
					 <cfset thisSQL = "#thisSQL#)">
		<cfquery name="makeIdentification" datasource="#mcat#">
			#preservesinglequotes(thisSQL)#
		</cfquery>
		<cfset thisSql = "INSERT INTO identification_taxonomy (
			identification_id,
			taxon_name_id,
			variable)
		VALUES (
			#identificationid#,
			#taxonnameid#,
			'A')">
	<cfquery name="makeIdentificationTaxa" datasource="#mcat#">
			#preservesinglequotes(thisSQL)#
		</cfquery>
	
	
	<!--- make other ids as needed --->
<cfloop from="1" to="#numberOfOtherIds#" index="i">
	<cfset thisIDType="other_id_num_type_" & #i#>
	<cfset thisIDNumber="other_id_num_" & #i#>
	
	<cfset thisIDTypeValue = evaluate(#thisIDType#)>
	<cfset thisIDNumberValue = evaluate(#thisIDNumber#)>
	
		<cfif len(#thisIDNumberValue#) gt 0>
			<!---- we got an other ID for this loop---->
			<cfset thisSQL = "INSERT INTO coll_obj_other_id_num (
						COLLECTION_OBJECT_ID,
						OTHER_ID_NUM,
						OTHER_ID_TYPE)
					VALUES (
						#catcollid#,
						'#replace(thisIDNumberValue,"'","''","all")#',
						'#thisIDTypeValue#')">
			<cfquery name="makeOtherId1" datasource="#mcat#">
				#preservesinglequotes(thisSQL)#
			</cfquery> 
		</cfif> 
</cfloop>
<cfloop from="1" to="#numberOfCollectors#" index="i">
	<cfset thisColl="collector_agent_" & #i#>
	<cfset thisCollR="collector_role_" & #i#>
	
	<cfset thisCollector = evaluate(#thisColl#)>
	<cfset thisCollectorRole = evaluate(#thisCollR#)>
	<cfif len(#thisCollector#) gt 0>
		<!---- get agent_id ---->
		<cfquery name="agntid" datasource="#mcat#">
			select agent_id FROM agent_name WHERE
			agent_name='#thisCollector#'
			and agent_name_type <> 'Kew abbr.'
		</cfquery>
		<cfset thisSQL = "INSERT INTO collector (
			COLLECTION_OBJECT_ID,
			AGENT_ID,
			COLLECTOR_ROLE,
			COLL_NUM_PREFIX ,
			COLL_NUM,
			COLL_NUM_SUFFIX,
			COLL_ORDER)
				VALUES (
			#catcollid#,
			#agntid.agent_id#,
			'#thisCollectorRole#',
			null ,
			null,
			null,
			#i#
			)">
		<cfquery name="makeCollector" datasource="#mcat#">			
			#preservesinglequotes(thisSQL)#
		</cfquery>
	</cfif>
</cfloop>
<!---------------------------------------------------    parts   ---------------------------------------------->
	<cfquery name="maxContainer" datasource="#mcat#">
		select max(container_id) + 1 as nextID from container
	</cfquery>
	<cfset container_id=#maxContainer.nextID#>
	
	<cfset partid = #catcollid# + 1>
	
<cfloop from="1" to="#numberOfParts#" index="i">
	
	<cfset thisPN="part_name_" & #i#>
	<cfset thisPM="preserv_method_" & #i#>
	<cfset thisPC="part_condition_" & #i#>
	<cfset thisPMod="part_modifier_" & #i#>
	<cfset thisPBC="part_barcode_" & #i#>
	<cfset thisPCL="part_container_label_" & #i#>
	<cfset thisPLC="part_lot_count_" & #i#>
	<cfset thisPDisp="part_disposition_" & #i#>
	<cfset thisPRemk="part_remark_" & #i#>
	<cfset thisIsTiss="is_tissue" & #i#>
	
	<cfset thisPartName = evaluate(#thisPN#)>
	<cfset thisPresMeth = evaluate(#thisPM#)>
	<cfset thisPresMeth = replace(thisPresMeth,"'","''","all")>
	<cfset thisPartCondition = evaluate(#thisPC#)>
	<cfset thisPartModifier = evaluate(#thisPMod#)>
	<cfset thisPartBarCode = evaluate(#thisPBC#)>
	<cfset thisPartContainerLabel = evaluate(#thisPCL#)>
	<cfset thisPartLotCount = evaluate(#thisPLC#)>
	<cfset thisPartDisposition = evaluate(#thisPDisp#)>
	<!---
	<cfset thisIsTissue = evaluate(#thisIsTiss#)>
	--->
	<!--- allow default --->
	<cfif len(#thisPartDisposition#) is 0>
		<cfset thisPartDisposition = "unchecked">
	</cfif>
	<cfset thisPartRemark = evaluate(#thisPRemk#)>
	<cfif not isdefined("thisPartLotCount") or len(#thisPartLotCount#) is 0>
		<cfset thisPartLotCount = 1>
	</cfif>
	
	<cfif #i# is 1>
		<cfif len(#thisPartName#) is 0>
			<cfset loadedMsg = "#loadedMsg#; Part 1 is required">
		</cfif>
	</cfif>
	<cfif len(#thisPartName#) gt 0>
	
	
	
	<cfset thisSQL = "INSERT INTO coll_object (
					COLLECTION_OBJECT_ID,
					COLL_OBJECT_TYPE,
					ENTERED_PERSON_ID,
					COLL_OBJECT_ENTERED_DATE,
					LAST_EDITED_PERSON_ID,
					LAST_EDIT_DATE,
					COLL_OBJ_DISPOSITION,
					LOT_COUNT,
					CONDITION,
					FLAGS       
					)
				VALUES 
				(
					#partid#,
					'SP',
					#enteredbyid#,
					'#entereddate#',
					#enteredbyid#,
					'#entereddate#',
					'#thisPartDisposition#',
					#thisPartLotCount#,
					'#thisPartCondition#',
					null     
					)">
					
			<cfquery name="makePartCollObj" datasource="#mcat#">
				#preservesinglequotes(thisSQL)#
			</cfquery>
			
			<cfset thisSQL = "INSERT INTO specimen_part (	
				COLLECTION_OBJECT_ID,
				PART_NAME,
				PART_MODIFIER,
				PRESERVE_METHOD,
				DERIVED_FROM_CAT_ITEM">
			<!---
			<cfif len(#thisIsTissue#) gt 0>
				<cfset thisSQL = "#thisSQL#, is_tissue">
			</cfif>
			--->
			<cfset thisSQL = "#thisSQL#)">
			<cfset thisSQL = "#thisSQL#
			VALUES (
				#partid#,
				'#thisPartName#',
				'#thisPartModifier#',
				'#thisPresMeth#',
				#catcollid#">
			<!---
			<cfif len(#thisIsTissue#) gt 0>
				<cfset thisSQL = "#thisSQL#, #is_tissue#">
			</cfif>
			--->
			<cfset thisSQL = "#thisSQL#)">
			<cfquery name="makePart" datasource="#mcat#">
					#preservesinglequotes(thisSQL)#
			</cfquery>
			<cfif len(#thisPartRemark#) gt 0>
				<cfset thisSql = "
					INSERT INTO coll_object_remark (
						collection_object_id, 
						coll_object_remarks
					) VALUES (
					#partid#, '#thisPartRemark#')">
				<cfquery name="makePartRemk" datasource="#mcat#">
					#preservesinglequotes(thisSQL)#
				</cfquery>
			</cfif>
			<cfset pn = #replace(thisPartName,"'","","all")#>
			<cfset thisSQL = "INSERT INTO container (
					CONTAINER_ID,
					PARENT_CONTAINER_ID,
					CONTAINER_TYPE,
					LABEL,
					PARENT_INSTALL_DATE,
					locked_position,
					institution_acronym)
				VALUES (
					#container_id#,
					0,
					'collection object',
					'#collection_cde# #catnum# #pn#',
					'#entereddate#',
					0,
					'#institution_acronym#')">
			<cfquery name="cont" datasource="#mcat#">
				#preservesinglequotes(thisSQL)#
			</cfquery>
			
			<cfset sql = "INSERT INTO coll_obj_cont_hist (
							  COLLECTION_OBJECT_ID,
							  CONTAINER_ID,
							  INSTALLED_DATE,
							  CURRENT_CONTAINER_FG)
						VALUES (
							#partid#,
							#container_id#,
							'#entereddate#',
							1
							)">
			<cfquery name="CollObjCont" datasource="#mcat#">
				#preservesinglequotes(sql)#
			</cfquery>
			
			<cfif len(#thisPartBarCode#) gt 0>
				<!--- put the container we just made into the container they scanned --->
					<cfset sql = "SELECT container_id FROM container WHERE barcode = '#thisPartBarCode#' ">
					<cfquery name="ContainerID" datasource="#mcat#">
						#preservesinglequotes(sql)#
					</cfquery>
					<cfif ContainerID.recordcount neq 1>
						something bad happened with containers! 
						<cfabort>
					</cfif>
					<cfset sql = "UPDATE container SET 
							parent_container_id = #ContainerID.container_id#,
							parent_install_date = '#entereddate#'
						WHERE 
							container_id = #container_id#">
					<cfquery name="Container" datasource="#mcat#">
						#preservesinglequotes(sql)#
					</cfquery>
					
					<!--- update the label of the container we just put the object into --->
					<cfset sql = "UPDATE container SET label = '#thisPartContainerLabel#'
						where container_id = #ContainerId.container_id#">
					<cfquery name="upCont" datasource="#mcat#">
						#preservesinglequotes(sql)#
					</cfquery>
			</cfif>
	<cfset container_id=#container_id#+1>
	<cfset partid=#partid#+1>
	</cfif>
</cfloop>
		
</cftransaction>

<!----
<cfcatch>
	<!--- if anything didn't go as planned catch it, don't commit, and 
	enter it into the loadedMsg --->
		<cfset loadedMsg = "#loadedMsg#; #cfcatch.Detail#">	
		caught something!!
		<hr>#cfcatch.Detail#
		<hr>#cfcatch.Message#
		<hr>#cfcatch.Type#
		<hr>
</cfcatch>

</cftry>
---->
</cfif><!---- end if loaded len is 0 --->
		<!---update the bulk table so we can tell that this record has been loaded--->
<cfif #len(loadedMsg)# is 0>
	<!--- still 0, we made it through validation AND the transaction. Yea - record loaded!! --->
	<cfset loadedMsg = 'Success!'>
		
<cfelse><!--- something isn't cool --->
	<cfif #len(loadedMsg)# gt 250>
		<cfset loadedMsg = #left(loadedMsg,225)#>
		<cfset loadedMsg = "#loadedMsg# ...{snip}...">
	</cfif>
		
</cfif>
		
</cfoutput>
