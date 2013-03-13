<cfcomponent>
<cffunction name="reverseGeocode" access="remote" returnformat="json">
	<cfreturn "ok">

	<!--------
	<cfquery name="hasRG" datasource="uam_god" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			S$DEC_LAT,
			S$DEC_LONG,
			s$S$ELEVATION,
			S$GEOGRAPHY
		from
			locality
		where
			locality_id=#detail.locality_id#
	</cfquery>
	<cfdump var=#hasRG#>
--------->
</cffunction>

<cffunction name="ac_georeference_source" access="remote" returnformat="json">
   	<cfargument name="term" required="true" type="string">
	<cfquery name="pn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select georeference_source label from locality where upper(georeference_source) like '%#ucase(term)#%'
		and rownum < 50
		group by georeference_source
		order by georeference_source
	</cfquery>
	<cfreturn "[" & ListQualify(valuelist(pn.label),'"') & "]">
</cffunction>
<!------------------------------------------------------------------->
<cffunction name="saveDeSettings" access="remote">
	   	<cfargument name="id" required="true" type="string">
	   	<cfargument name="val" required="true" type="string">
	   	<cfif val is true>
	   		<cfset val=1>
	   	<cfelse>
	   		<cfset val=0>
	   	</cfif>
		<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	    	update cf_dataentry_settings set #id#=#val# where username='#session.username#'
	    </cfquery>
	    <cfreturn>
</cffunction>
<!------------------------------------------------------------------->
<cffunction name="getMediaPreview" access="remote">
	   <cfargument name="preview_uri" required="true" type="string">
	   <cfargument name="media_type" required="false" type="string">
	     <!----

		 it would be just fabulous to check the previews, but cfhttp doesn't seem to time out properly
	   <cfset r=0>
	   <cfif len(preview_uri) gt 0>
			<cfhttp method="head" url="#preview_uri#" timeout="1">
			<cfif isdefined("cfhttp.responseheader.status_code") and cfhttp.responseheader.status_code is 200>
				<cfset r=1>
			</cfif>
		</cfif>
		---->
		<cfif len(preview_uri) is 0>
			<cfif media_type is "image">
				<cfreturn "/images/noThumb.jpg">
			<cfelseif media_type is "audio">
				<cfreturn "/images/audioNoThumb.png">
			<cfelseif media_type is "text">
				<cfreturn "/images/documentNoThumb.png">
			<cfelseif media_type is "multi-page document">
				<cfreturn "/images/document_thumbnail.png">
			<cfelse>
				<cfreturn "/images/noThumb.jpg">
			</cfif>
		<cfelse>
			<cfreturn preview_uri>
		</cfif>
</cffunction>
<!------------------------------------------------------------------->
<cffunction name="agentCollectionContacts" access="remote">
	<!--------- get email addresses of people who have some involvement with agent(s) ---->
	<cfargument name="agent_id" type="string" required="yes">
	<cfquery name="colns" datasource="uam_god">
		select
			agent_name,
			ADDRESS
		from
			collection_contacts,
			electronic_address,
			preferred_agent_name
		where
			collection_contacts.CONTACT_AGENT_ID=preferred_agent_name.agent_id and
			collection_contacts.CONTACT_AGENT_ID=electronic_address.agent_id and
			electronic_address.address_type='e-mail' and
			CONTACT_ROLE='data quality' and
			collection_contacts.collection_id in  (
		select
			collection_id
		from
			cataloged_item,
			citation,
			publication_agent
		where
			cataloged_item.collection_object_id=citation.collection_object_id and
			citation.publication_id=publication_agent.publication_id and
			publication_agent.agent_id in (#agent_id#)
		union
		select
			cataloged_item.collection_id
		from
			collector,
			cataloged_item
		where
			collector.collection_object_id = cataloged_item.collection_object_id AND
			agent_id in (#agent_id#)
		union
		select
			collection_id
		from
			coll_object,
			cataloged_item
		where
			coll_object.collection_object_id = cataloged_item.collection_object_id and
			ENTERED_PERSON_ID in (#agent_id#)
		union
		select
			collection_id
		from
			coll_object,
			cataloged_item
		where
			coll_object.collection_object_id = cataloged_item.collection_object_id and
			LAST_EDITED_PERSON_ID in (#agent_id#)
		union
			select
				collection_id
			from
				attributes,
				cataloged_item
			where
				cataloged_item.collection_object_id=attributes.collection_object_id and
				determined_by_agent_id in (#agent_id#)
		union
			select
					collection_id
				 from
				 	encumbrance,
				 	coll_object_encumbrance,
				 	cataloged_item
				 where
				 	encumbrance.encumbrance_id = coll_object_encumbrance.encumbrance_id and
				 	coll_object_encumbrance.collection_object_id=cataloged_item.collection_object_id and
				 	encumbering_agent_id in (#agent_id#)
		union
			select
				collection_id
			from
	        	identification,
	        	identification_agent,
				cataloged_item
	        where
				cataloged_item.collection_object_id=identification.collection_object_id and
				identification.identification_id=identification_agent.identification_id and
	        	identification_agent.agent_id in (#agent_id#)
		union
			select
				collection_id
			from
				cataloged_item,
				specimen_event
			where
				cataloged_item.collection_object_id=specimen_event.collection_object_id and
				specimen_event.ASSIGNED_BY_AGENT_ID in (#agent_id#)
		union
			select
					collection_id
				from
					shipment,
					loan,
					trans
				where
					shipment.transaction_id=loan.transaction_id and
					loan.transaction_id =trans.transaction_id and
					PACKED_BY_AGENT_ID in (#agent_id#)
		union
			select
								collection_id
				from
					shipment,
					addr,
					loan,
					trans
				where
					shipment.transaction_id=loan.transaction_id and
					loan.transaction_id =trans.transaction_id and
					shipment.SHIPPED_TO_ADDR_ID=addr.addr_id and
					addr.agent_id in (#agent_id#)
		union
				select 							collection_id
				from
					shipment,
					addr,
					loan,
					trans
				where
					shipment.transaction_id=loan.transaction_id and
					loan.transaction_id =trans.transaction_id and
					shipment.SHIPPED_FROM_ADDR_ID=addr.addr_id and
					addr.agent_id in (#agent_id#)
		union
				select
					collection_id
				from
					trans_agent,
					loan,
					trans
				where
					trans_agent.transaction_id=loan.transaction_id and
					loan.transaction_id=trans.transaction_id and
					AGENT_ID in (#agent_id#)
		union
				select
					collection_id
				from
					trans_agent,
					accn,
					trans
				where
					trans_agent.transaction_id=accn.transaction_id and
					accn.transaction_id=trans.transaction_id and
					AGENT_ID in (#agent_id#)
		union
				select
					collection_id
				from
					trans,
					loan,
					loan_item
				where
					trans.transaction_id=loan.transaction_id and
					loan.transaction_id=loan_item.transaction_id and
					RECONCILED_BY_PERSON_ID in (#agent_id#)
					)
		group by
			agent_name,
			ADDRESS
	</cfquery>
	<cfreturn colns>
</cffunction>
<!------------------------------------------------------------------->
<cffunction name="getMap" access="remote">
	<cfargument name="size" type="string" required="no" default="200x200">
	<cfargument name="maptype" type="string" required="no" default="roadmap">
	<cfargument name="collection_object_id" type="any" required="no" default="">
	<cfargument name="locality_id" type="any" required="no" default="">
	<cfargument name="collecting_event_id" type="any" required="no" default="">
	<cfargument name="specimen_event_id" type="any" required="no" default="">
	<cfargument name="media_id" type="any" required="no" default="">
	<cfargument name="showCaption" type="boolean" required="no" default="true">
	<cfargument name="forceOverrideCache" type="boolean" required="no" default="false">



	<!----
	<cftry>

	---->
		<cfif len(locality_id) gt 0>
			<cfif forceOverrideCache>
				<cfquery name="d" datasource="uam_god">
					select
						locality.locality_id,
						locality.DEC_LAT,
						locality.DEC_LONG,
						locality.S$ELEVATION,
						locality.spec_locality,
						locality.S$DEC_LAT,
						locality.S$DEC_LONG,
						locality.s$geography,
						geog_auth_rec.higher_geog,
						locality.s$lastdate,
						to_meters(locality.minimum_elevation,
			    			locality.orig_elev_units) min_elev_in_m,
						to_meters(locality.maximum_elevation,
			    			locality.orig_elev_units) max_elev_in_m
					from
						locality,
						geog_auth_rec
					where
						locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
						locality_id=<cfqueryparam value = "#locality_id#" CFSQLType = "CF_SQL_INTEGER">
				</cfquery>
			<cfelse>
				<cfquery name="d" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
					select
						locality.locality_id,
						locality.DEC_LAT,
						locality.DEC_LONG,
						locality.S$ELEVATION,
						locality.spec_locality,
						locality.S$DEC_LAT,
						locality.S$DEC_LONG,
						locality.s$geography,
						geog_auth_rec.higher_geog,
						locality.s$lastdate,
						to_meters(locality.minimum_elevation,
			    			locality.orig_elev_units) min_elev_in_m,
						to_meters(locality.maximum_elevation,
			    			locality.orig_elev_units) max_elev_in_m
					from
						locality,
						geog_auth_rec
					where
						locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
						locality_id=<cfqueryparam value = "#locality_id#" CFSQLType = "CF_SQL_INTEGER">
				</cfquery>
			</cfif>

		<cfelseif len(collecting_event_id) gt 0>
			<cfquery name="d" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
				select
					locality.locality_id,
					locality.DEC_LAT,
					locality.DEC_LONG,
					locality.S$ELEVATION,
					locality.spec_locality,
					S$DEC_LAT,
					S$DEC_LONG,
					s$geography,
					geog_auth_rec.higher_geog,
					locality.s$lastdate,
					to_meters(locality.minimum_elevation,
		    			locality.orig_elev_units) min_elev_in_m,
					to_meters(locality.maximum_elevation,
		    			locality.orig_elev_units) max_elev_in_m
				from
					locality,
					collecting_event,
					geog_auth_rec
				where
					locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
					locality.locality_id=collecting_event.locality_id and
					collecting_event.collecting_event_id=<cfqueryparam value = "#collecting_event_id#" CFSQLType = "CF_SQL_INTEGER">
			</cfquery>
		<cfelseif len(specimen_event_id) gt 0>
			<cfquery name="d" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
				select
					locality.locality_id,
					locality.DEC_LAT,
					locality.DEC_LONG,
					locality.S$ELEVATION,
					locality.spec_locality,
					S$DEC_LAT,
					S$DEC_LONG,
					s$geography,
					geog_auth_rec.higher_geog,
					locality.s$lastdate,
					to_meters(locality.minimum_elevation,
		    			locality.orig_elev_units) min_elev_in_m,
					to_meters(locality.maximum_elevation,
		    			locality.orig_elev_units) max_elev_in_m
				from
					locality,
					collecting_event,
					specimen_event,
					geog_auth_rec
				where
					locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
					locality.locality_id=collecting_event.locality_id and
					collecting_event.collecting_event_id=specimen_event.collecting_event_id and
					specimen_event.specimen_event_id=<cfqueryparam value = "#specimen_event_id#" CFSQLType = "CF_SQL_INTEGER">
			</cfquery>
		<cfelseif len(collection_object_id) gt 0>
			<cfquery name="d" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
				select
					locality.locality_id,
					locality.DEC_LAT,
					locality.DEC_LONG,
					locality.S$ELEVATION,
					locality.spec_locality,
					S$DEC_LAT,
					S$DEC_LONG,
					s$geography,
					geog_auth_rec.higher_geog,
					locality.s$lastdate,
					to_meters(locality.minimum_elevation,
		    			locality.orig_elev_units) min_elev_in_m,
					to_meters(locality.maximum_elevation,
		    			locality.orig_elev_units) max_elev_in_m
				from
					locality,
					collecting_event,
					specimen_event,
					geog_auth_rec
				where
					locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
					locality.locality_id=collecting_event.locality_id and
					collecting_event.collecting_event_id=specimen_event.collecting_event_id and
					specimen_event.collection_object_id=<cfqueryparam value = "#collection_object_id#" CFSQLType = "CF_SQL_INTEGER">
			</cfquery>
		<cfelseif len(media_id) gt 0>
			<cfquery name="d" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
				select
					COORDINATES
				from
					media_flat
				where
					COORDINATES is not null and
					media_id=<cfqueryparam value = "#media_id#" CFSQLType = "CF_SQL_INTEGER">
			</cfquery>
			<cfif len(d.coordinates) eq 0>
				<cfreturn '[ nothing to map ]'>
			</cfif>
			<cfquery name="d" dbtype="query">
				select
					'' as locality_id,
					#listgetat(d.coordinates,1)# as DEC_LAT,
					#listgetat(d.coordinates,2)# as DEC_LONG,
					'' as spec_locality,
					'' as S$ELEVATION,
					'' as S$DEC_LAT,
					'' as S$DEC_LONG,
					'' as s$geography,
					'' as higher_geog,
					'' as min_elev_in_m,
					'' as max_elev_in_m,
					'#dateformat(now(),"yyyy-mm-dd")# as s$lastdate
				from
					d
			</cfquery>
		<cfelse>
			<cfreturn 'not_enough_info'>
		</cfif>
		<cfif len(d.min_elev_in_m) is 0 and len(d.max_elev_in_m) is 0>
			<cfset elevation='not recorded'>
		<cfelseif d.min_elev_in_m is d.max_elev_in_m>
			<cfset elevation=d.min_elev_in_m & ' m'>
		<cfelse>
			<cfset elevation=d.min_elev_in_m & '-' & d.max_elev_in_m & ' m'>
		</cfif>

		<!----
			fire service lookups off in a thread for performance reasons
			the results will not be available to the current user,
			but will be cached for subsequent calls

		<cfthread action="run" name="EsDollar#d.locality_id#" forceOverrideCache="#forceOverrideCache#">



		---->
			<cftry>
				<!--- for some strange reason, this must be mapped like zo.... ----->
				<cfset obj = CreateObject("component","functions")>
				<cfif forceOverrideCache is "true" or len(d.s$lastdate) is 0>
					<cfset daysSinceLast=9000>
				<cfelse>
					<cfset daysSinceLast=DateDiff("d", "#d.s$lastdate#","#dateformat(now(),'yyyy-mm-dd')#")>
				</cfif>
				<!--- if we got some sort of response AND it's been a while....--->
				<cfif d.recordcount is 1 and len(d.locality_id) gt 0 and daysSinceLast gt 180>

				going


					<cfset geoList="">
					<cfset slat="">
					<cfset slon="">
					<cfset elevRslt=''>
					<cfif len(d.DEC_LAT) gt 0 and len(d.DEC_LONG) gt 0>
						<!--- geography data from curatorial coordinates ---->
						<cfset signedURL = obj.googleSignURL(
							urlPath="/maps/api/geocode/json",
							urlParams="latlng=#URLEncodedFormat('#d.DEC_LAT#,#d.DEC_LONG#')#")>
						<cfhttp method="get" url="#signedURL#" timeout="1"></cfhttp>
						<cfif cfhttp.responseHeader.Status_Code is 200>
							<cfset llresult=DeserializeJSON(cfhttp.fileContent)>
							<cfloop from="1" to ="#arraylen(llresult.results)#" index="llr">
								<cfloop from="1" to="#arraylen(llresult.results[llr].address_components)#" index="ac">
									<cfif not listcontainsnocase(geolist,llresult.results[llr].address_components[ac].long_name)>
										<cfset geolist=listappend(geolist,llresult.results[llr].address_components[ac].long_name)>
									</cfif>
									<cfif not listcontainsnocase(geolist,llresult.results[llr].address_components[ac].short_name)>
										<cfset geolist=listappend(geolist,llresult.results[llr].address_components[ac].short_name)>
									</cfif>
								</cfloop>
							</cfloop>
						</cfif>
					</cfif>
					<cfoutput>
					<cfif len(d.spec_locality) gt 0 and len(d.higher_geog) gt 0>
						<cfset signedURL = obj.googleSignURL(
							urlPath="/maps/api/geocode/json",
							urlParams="address=#URLEncodedFormat('#d.spec_locality#, #d.higher_geog#')#")>
						<cfhttp method="get" url="#signedURL#" timeout="1"></cfhttp>
						<cfif cfhttp.responseHeader.Status_Code is 200>
							<cfset llresult=DeserializeJSON(cfhttp.fileContent)>
							<cfdump var=#llresult#>
							<cfif llresult.status is "OK">
								<cfloop from="1" to ="#arraylen(llresult.results)#" index="llr">
									<cfloop from="1" to="#arraylen(llresult.results[llr].address_components)#" index="ac">
										<cfif not listcontainsnocase(geolist,llresult.results[llr].address_components[ac].long_name)>
											<cfset geolist=listappend(geolist,llresult.results[llr].address_components[ac].long_name)>
										</cfif>
										<cfif not listcontainsnocase(geolist,llresult.results[llr].address_components[ac].short_name)>
											<cfset geolist=listappend(geolist,llresult.results[llr].address_components[ac].short_name)>
										</cfif>
									</cfloop>
								</cfloop>
								<cfset slat=llresult.results[1].geometry.location.lat>
								<cfset slon=llresult.results[1].geometry.location.lng>
							<cfelseif llresult.status is "ZERO_RESULTS">
								<!--- try without specloc, which is user-supplied and often wonky ---->
								<cfset signedURL = obj.googleSignURL(
									urlPath="/maps/api/geocode/json",
									urlParams="address=#URLEncodedFormat('#d.higher_geog#')#")>
								<cfhttp method="get" url="#signedURL#" timeout="1"></cfhttp>
								<cfif cfhttp.responseHeader.Status_Code is 200>
									<cfset llresult=DeserializeJSON(cfhttp.fileContent)>
									<cfif llresult.status is "OK">
										<cfloop from="1" to ="#arraylen(llresult.results)#" index="llr">
											<cfloop from="1" to="#arraylen(llresult.results[llr].address_components)#" index="ac">
												<cfif not listcontainsnocase(geolist,llresult.results[llr].address_components[ac].long_name)>
													<cfset geolist=listappend(geolist,llresult.results[llr].address_components[ac].long_name)>
												</cfif>
												<cfif not listcontainsnocase(geolist,llresult.results[llr].address_components[ac].short_name)>
													<cfset geolist=listappend(geolist,llresult.results[llr].address_components[ac].short_name)>
												</cfif>
											</cfloop>
										</cfloop>
										<cfset slat=llresult.results[1].geometry.location.lat>
										<cfset slon=llresult.results[1].geometry.location.lng>
									</cfif>
								</cfif>
							</cfif>
						</cfif>
					</cfif>
					<cfif len(d.S$ELEVATION) is 0 and len(d.DEC_LAT) gt 0 and len(d.DEC_LONG) gt 0>
						<cfset signedURL = obj.googleSignURL(
							urlPath="/maps/api/elevation/json",
							urlParams="locations=#URLEncodedFormat('#d.DEC_LAT#,#d.DEC_LONG#')#")>
						<cfhttp method="get" url="#signedURL#" timeout="1"></cfhttp>
						<cfif cfhttp.responseHeader.Status_Code is 200>
							<cfset elevResult=DeserializeJSON(cfhttp.fileContent)>
							<cfif isdefined("elevResult.status") and elevResult.status is "OK">
								<cfset elevRslt=round(elevResult.results[1].elevation)>
							</cfif>
						</cfif>
					</cfif>
					<!---- update cache ---->
					<cfquery name="upEsDollar" datasource="uam_god">
						update locality set
							S$ELEVATION=<cfif len(elevRslt) is 0>NULL<cfelse>#elevRslt#</cfif>,
							S$GEOGRAPHY='#replace(geoList,"'","''","all")#',
							S$DEC_LAT=<cfif len(slat) is 0>NULL<cfelse>#slat#</cfif>,
							S$DEC_LONG=<cfif len(slon) is 0>NULL<cfelse>#slon#</cfif>,
							S$LASTDATE=sysdate
						where locality_id=#d.locality_id#
					</cfquery>

<!----------------- clean up for prod ----------------------->
					<cfmail to="arctos.database@gmail.com" subject="thread: get webservice locality LIVES" from="threadDeath@arctos-test.tacc.utexas.edu" type="html">

						<cfoutput>
							update locality set
								S$ELEVATION=<cfif len(elevRslt) is 0>NULL<cfelse>#elevRslt#</cfif>,
								S$GEOGRAPHY='#replace(geoList,"'","''","all")#',
								S$DEC_LAT=<cfif len(slat) is 0>NULL<cfelse>#slat#</cfif>,
								S$DEC_LONG=<cfif len(slon) is 0>NULL<cfelse>#slon#</cfif>,
								S$LASTDATE=sysdate
							where locality_id=#d.locality_id#
						</cfoutput>
					</cfmail>
				</cfif><!--- end service call --->

<!----------------- clean up for prod ----------------------->

				<cfmail to="arctos.database@gmail.com" subject="thread: get webservice locality DIDNOTHING" from="threadDeath@arctos-test.tacc.utexas.edu" type="html">

						outside the call for locality
					</cfmail>



			<cfcatch>
<!----------------- clean up for prod ----------------------->

				<cfmail to="arctos.database@gmail.com" subject="thread: get webservice locality died" from="threadDeath@arctos-test.tacc.utexas.edu" type="html">

					thread died

					<cfdump var=#cfcatch#>
				</cfmail>
			</cfcatch>
			</cftry>

			<!----
		</cfthread>
---->




		<!--- build and return a HTML block for a map ---->
		<cfoutput>
  			<cfset params='markers=color:red|size:tiny|label:X|#URLEncodedFormat("#d.DEC_LAT#,#d.DEC_LONG#")#'>
	<!--- code to send second marker
			<cfset params=params & '&markers=color:green|label:A|size:tiny|#URLEncodedFormat("12,12")#'>

			---->
			<cfset params=params & '&center=#URLEncodedFormat("#d.DEC_LAT#,#d.DEC_LONG#")#'>





			<cfset params=params & '&maptype=#maptype#&zoom=2&size=#size#'>
  			<cfinvoke component="component.functions" method="googleSignURL" returnvariable="signedURL">
				<cfinvokeargument name="urlPath" value="/maps/api/staticmap">
				<cfinvokeargument name="urlParams" value="#params#">
			</cfinvoke>
			<cfscript>
				mapImage='<img src="#signedURL#" alt="[ Google Map of #d.DEC_LAT#,#d.DEC_LONG# ]">';
	  			rVal='<figure>';
	  			if (len(d.locality_id) gt 0) {
	  				rVal &= '<a href="/bnhmMaps/bnhmMapData.cfm?locality_id=#valuelist(d.locality_id)#" target="_blank">' & mapImage & '</a>';
	  			} else {
	  				rVal &= mapImage;
	  			}
	  			if (showCaption) {
					rVal&='<figcaption>#numberformat(d.DEC_LAT,"__.___")#,#numberformat(d.DEC_LONG,"___.___")#';
					rVal&='; Elev. #elevation#';
					rVal&='</figcaption>';
				}
				 rVal &= "</figure>";
				 return rVal;
			</cfscript>
		</cfoutput>
		<!----
	<cfcatch>
		<cfdump var=#cfcatch#>
		<cfreturn "try_fail">
	</cfcatch>
	</cftry>
	---->
</cffunction>
<!------------------------------------------------------------------->
<cffunction name="googleSignURL" access="remote">
	<cfargument name="urlPath" type="string" required="yes">
	<cfargument name="urlParams" type="string" required="yes">
	<cfquery name="cf_global_settings" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			google_client_id,
			google_private_key
		from cf_global_settings
	</cfquery>
	<cfscript>
		baseURL = "http://maps.googleapis.com";
		urlParams &= '&sensor=false&client=' & cf_global_settings.google_client_id;
		fullURL = baseURL & urlPath & "?" & urlParams;
		urlToSign=urlPath & "?" & urlParams;
		privatekey = cf_global_settings.google_private_key;
		privatekeyBase64 = Replace(Replace(privatekey,"-","+","all"),"_","/","all");
		decodedKeyBinary = BinaryDecode(privatekeyBase64,"base64");
		secretKeySpec = CreateObject("java","javax.crypto.spec.SecretKeySpec").init(decodedKeyBinary,"HmacSHA1");
  		Hmac=CreateObject("java","javax.crypto.Mac").getInstance("HmacSHA1");
		Hmac.init(secretKeySpec);
		encryptedBytes = Hmac.doFinal(toBinary(toBase64(urlToSign)));
	  	signature = BinaryEncode(encryptedBytes, "base64");
	  	signatureModified = Replace(Replace(signature,"+","-","all"),"/","_","all");
	  	theFinalURL=fullURL & "&signature=" & signatureModified;
		return theFinalURL;
	</cfscript>
</cffunction>
<!------------------------------------------------------------------->
<cffunction name="getLocalityContents" access="public">
	<cfargument name="locality_id" type="numeric" required="yes">
	<cfquery name="whatSpecs" datasource="uam_god">
	  	SELECT
	  		count(cat_num) as numOfSpecs,
	  		collection,
	  		collection.collection_id
		from
			cataloged_item,
			collection,
			specimen_event,
			collecting_event
		WHERE
			cataloged_item.collection_id=collection.collection_id and
			cataloged_item.collection_object_id=specimen_event.collection_object_id and
			specimen_event.collecting_event_id=collecting_event.collecting_event_id and
			collecting_event.locality_id=<cfqueryparam value = "#locality_id#" CFSQLType = "CF_SQL_INTEGER">
		GROUP BY
			collection,
	  		collection.collection_id
	</cfquery>
	<cfquery name="whatMedia" datasource="uam_god">
  		SELECT
			count(*) num,
			media_id
		from
			media_relations
		WHERE
			 media_relationship like '% locality' and
			 related_primary_key=<cfqueryparam value = "#locality_id#" CFSQLType = "CF_SQL_INTEGER">
		GROUP BY
			media_id
	</cfquery>

	<cfquery name="verifiedSpecs" datasource="uam_god">
		select
			count(distinct(collection_object_id)) c
		from
			specimen_event,
			collecting_event
		where
			specimen_event.collecting_event_id=collecting_event.collecting_event_id and
			specimen_event.verificationstatus like 'verified by %' and
			collecting_event.locality_id=<cfqueryparam value = "#locality_id#" CFSQLType = "CF_SQL_INTEGER">
	</cfquery>

	<cfoutput>
		<cfsavecontent variable="return">
			<span style="margin:1em;display:inline-block;padding:1em;border:10px solid red;">
				This Locality (#locality_id#)
				<span class="infoLink" onClick="getDocs('collecting_event')">[ help ]</span> contains
				<cfif whatSpecs.recordcount is 0 and whatMedia.recordcount is 0>
					nothing. Please delete it if you don't have plans for it.
				<cfelse>
					<ul>
						<cfloop query="whatSpecs">
							<li>
								<a target="_top" href="SpecimenResults.cfm?locality_id=#locality_id#&collection_id=#collection_id#">
									#whatSpecs.numOfSpecs# #whatSpecs.collection# specimens
								</a>
							</li>
						</cfloop>
						<cfif whatMedia.recordcount gt 0>
							<li>
								<a target="_top" href="MediaSearch.cfm?action=search&media_id=#valuelist(whatMedia.media_id)#">#whatMedia.num# Media records</a>
							</li>
						</cfif>
					</ul>
				</cfif>
				<cfif verifiedSpecs.c gt 0>
					<br>
					#verifiedSpecs.c#
					<a href="/SpecimenResults.cfm?locality_id=#locality_id#&verificationstatus=verified by">
						Specimens
					</a> are verified to this locality; updates are disallowed.
				</cfif>
			</span>
		</cfsavecontent>
	</cfoutput>
	<cfreturn return>
</cffunction>
<!------------------------------------------------------------------->
<cffunction name="getEventContents" access="public">
	<cfargument name="collecting_event_id" type="numeric" required="yes">
	<cfquery name="whatSpecs" datasource="uam_god">
	  	SELECT
	  		count(cat_num) as numOfSpecs,
	  		collection,
	  		collection.collection_id
		from
			cataloged_item,
			collection,
			specimen_event
		WHERE
			cataloged_item.collection_id=collection.collection_id and
			cataloged_item.collection_object_id=specimen_event.collection_object_id and
			specimen_event.collecting_event_id=<cfqueryparam value = "#collecting_event_id#" CFSQLType = "CF_SQL_INTEGER">
		GROUP BY
			collection,
	  		collection.collection_id
	</cfquery>
	<cfquery name="whatMedia" datasource="uam_god">
  		SELECT
			count(*) num,
			media_id
		from
			media_relations
		WHERE
			 media_relationship like '% collecting_event' and
			 related_primary_key=<cfqueryparam value = "#collecting_event_id#" CFSQLType = "CF_SQL_INTEGER">
		GROUP BY
			media_id
	</cfquery>
	<cfquery name="verifiedSpecs" datasource="uam_god">
		select
			count(distinct(collection_object_id)) c
		from
			specimen_event
		where
			verificationstatus like 'verified by %' and
			specimen_event.collecting_event_id=<cfqueryparam value = "#collecting_event_id#" CFSQLType = "CF_SQL_INTEGER">
	</cfquery>

	<cfoutput>
		<cfsavecontent variable="return">
			<span style="margin:1em;display:inline-block;padding:1em;border:10px solid red;">
				This Collecting Event (#collecting_event_id#)
				<span class="infoLink" onClick="getDocs('collecting_event')">[ help ]</span> contains
				<cfif whatSpecs.recordcount is 0 and whatMedia.recordcount is 0>
					nothing. Please delete it if you don't have plans for it.
				<cfelse>
					<ul>
						<cfloop query="whatSpecs">
							<li>
								<a target="_top" href="SpecimenResults.cfm?collecting_event_id=#collecting_event_id#&collection_id=#collection_id#">
									#whatSpecs.numOfSpecs# #whatSpecs.collection# specimens
								</a>
							</li>
						</cfloop>
						<cfif whatMedia.recordcount gt 0>
							<li>
								<a target="_top" href="MediaSearch.cfm?action=search&media_id=#valuelist(whatMedia.media_id)#">#whatMedia.num# Media records</a>
							</li>
						</cfif>
					</ul>
				</cfif>
				<cfif verifiedSpecs.c gt 0>
					<br>
					#verifiedSpecs.c#
					<a href="/SpecimenResults.cfm?collecting_event_id=#collecting_event_id#&verificationstatus=verified by">
						Specimens
					</a> are verified to this event; updates are disallowed.
				</cfif>
			</span>
		</cfsavecontent>
	</cfoutput>
	<cfreturn return>
</cffunction>
<!------------------------------------------------------------------->
<cffunction name="getPublication" access="remote">
	<cfargument name="idtype" type="string" required="yes">
	<cfargument name="identifier" type="string" required="yes">
	<cfparam name="debug" default="false">
	<cfset rauths="">
	<cfset lPage=''>
	<cfset pubYear=''>
	<cfset jVol=''>
	<cfset jIssue=''>
	<cfset fPage=''>
	<cfset fail="">
	<cfset firstAuthLastName=''>
	<cfset secondAuthLastName=''>
	<cfoutput>
		<cftry>
		<cfif idtype is 'DOI'>
			<cfhttp url="http://www.crossref.org/openurl/?id=#identifier#&noredirect=true&pid=dlmcdonald@alaska.edu&format=unixref"></cfhttp>
			<cfset r=xmlParse(cfhttp.fileContent)>
			<cfif debug>
				<cfdump var=#r#>
			</cfif>
			<cfif left(cfhttp.statuscode,3) is not "200" or not structKeyExists(r.doi_records[1].doi_record[1].crossref[1],"journal")>
				<cfset fail="not found or not journal">
			</cfif>
			<cfif len(fail) is 0>
				<cfset numberOfAuthors=arraylen(r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article[1].contributors.xmlchildren)>
				<cfloop from="1" to="#numberOfAuthors#" index="i">
					<cfset fName=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article[1].contributors[1].person_name[i].given_name.xmltext>
					<cfset lName=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article[1].contributors[1].person_name[i].surname.xmltext>
					<cfset thisName=fName & ' ' & lName>
					<cfset rauths=listappend(rauths,thisName,"|")>
				</cfloop>
				<cfset firstAuthLastName=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article[1].contributors[1].person_name[1].surname.xmltext>
				<cfif numberOfAuthors gt 1>
					<cfset secondAuthLastName=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article[1].contributors[1].person_name[2].surname.xmltext>
				</cfif>
				<cfif structKeyExists(r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article.publication_date,"year")>
					<cfset pubYear=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article.publication_date.year.xmltext>
				<cfelseif structKeyExists(r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_issue.publication_date,"year")>>
					<cfset pubYear=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_issue.publication_date.year.xmltext>
				</cfif>
				<cfset pubTitle=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article.titles.title.xmltext>
				<cfset jName=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_metadata.full_title.xmltext>
				<cfif structKeyExists(r.doi_records[1].doi_record[1].crossref[1].journal[1],"journal_issue")>
					<cfif structKeyExists(r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_issue.journal_volume,"volume")>
						<cfset jVol=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_issue.journal_volume.volume.xmltext>
					</cfif>
					<cfif structKeyExists(r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_issue,"issue")>
						<cfset jIssue=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_issue.issue.xmltext>
					</cfif>
				</cfif>
				<cfif structKeyExists(r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article,"pages")>
					<cfif structKeyExists(r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article.pages,"first_page")>
						<cfset fPage=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article.pages.first_page.xmltext>
					</cfif>
					<cfif structKeyExists(r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article.pages,"last_page")>
						<cfset lPage=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article.pages.last_page.xmltext>
					</cfif>
				</cfif>
			</cfif><!--- end DOI --->
		<cfelseif idtype is "PMID">
			<cfhttp url="http://www.ncbi.nlm.nih.gov/pubmed/#identifier#?report=XML"></cfhttp>
			<cfset theData=replace(cfhttp.fileContent,'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">','')>
			<cfset theData=replace(theData,"&gt;",">","all")>
			<cfset theData=replace(theData,"&lt;","<","all")>
			<cfset r=xmlParse(theData)>
			<cfif left(cfhttp.statuscode,3) is not "200" or not structKeyExists(r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1],"Journal")>
				<cfset fail="not found or not journal">
			</cfif>
			<cfif len(fail) is 0>
				<cfif debug>
					<cfdump var=#r#>
				</cfif>
				<cfset numberOfAuthors=arraylen(r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].AuthorList[1].xmlchildren)>
				<cfloop from="1" to="#numberOfAuthors#" index="i">
					<cfset fName=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].AuthorList[1].Author[i].ForeName.xmltext>
					<cfset lName=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].AuthorList[1].Author[i].LastName.xmltext>
					<cfset thisName=fName & ' ' & lName>
					<cfset rauths=listappend(rauths,thisName,"|")>
				</cfloop>
				<cfset firstAuthLastName=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].AuthorList[1].Author[1].LastName.xmltext>
				<cfif numberOfAuthors gt 1>
					<cfset secondAuthLastName=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].AuthorList[1].Author[2].LastName.xmltext>
				</cfif>
				<cfif structKeyExists(r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].Journal[1].JournalIssue[1].PubDate,"Year")>
					<cfset pubYear=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].Journal[1].JournalIssue[1].PubDate.Year.xmltext>
				</cfif>
				<cfset pubTitle=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].ArticleTitle.xmltext>
				<cfif right(pubTitle,1) is ".">
					<cfset pubTitle=left(pubTitle,len(pubTitle)-1)>
				</cfif>
				<cfset jName=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].Journal.Title.xmltext>
				<cfif structKeyExists(r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].Journal.JournalIssue,"Issue")>
					<cfset jIssue=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].Journal.JournalIssue.Issue.xmltext>
				</cfif>
				<cfif structKeyExists(r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].Journal.JournalIssue,"Volume")>
					<cfset jVol=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].Journal.JournalIssue.Volume.xmltext>
				</cfif>
				<cfset pages=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].Pagination.MedlinePgn.xmltext>
				<cfif listlen(pages,"-") is 2>
					<cfset fPage=listgetat(pages,1,"-")>
					<cfset lPage=listgetat(pages,2,"-")>
				</cfif>
			</cfif><!--- PMID nofail --->
		</cfif><!---- end PMID --->
		<cfcatch>
			<cfset fail='error_getting_data: #cfcatch.message# #cfcatch.detail#'>
		</cfcatch>
		</cftry>

		<cfif len(fail) is 0>
			<cftry>
			<cfif listlen(rauths,"|") is 2>
				<cfset auths=replace(rauths,"|"," and ")>
			<cfelse>
				<cfset auths=listchangedelims(rauths,", ","|")>
			</cfif>
			<cfset longCit="#auths#.">
			<cfif len(pubYear) gt 0>
				<cfset longCit=longCit & " #pubYear#.">
			</cfif>
			<cfset longCit=longCit & " #pubTitle#. #jName#">
			<cfif len(jVol) gt 0>
				<cfset longCit=longCit & " #jVol#">
			</cfif>
			<cfif len(jIssue) gt 0>
				<cfset longCit=longCit & "(#jIssue#)">
			</cfif>
			<cfif len(fPage) gt 0>
				<cfset longCit=longCit & ":#fPage#">
			</cfif>
			<cfif len(lPage) gt 0>
				<cfset longCit=longCit & "-#lPage#">
			</cfif>
			<cfset longCit=longCit & ".">
			<cfif numberOfAuthors is 1>
				<cfset shortCit="#firstAuthLastName# #pubYear#">
			<cfelseif numberOfAuthors is 2>
				<cfset shortCit="#firstAuthLastName# and #secondAuthLastName# #pubYear#">
			<cfelse>
				<cfset shortCit="#firstAuthLastName# et al. #pubYear#">
			</cfif>
			<cfset d = querynew("STATUS,PUBLICATIONTYPE,LONGCITE,SHORTCITE,YEAR,AUTHOR1,AUTHOR2,AUTHOR3,AUTHOR4,AUTHOR5")>
			<cfset temp = queryaddrow(d,1)>
			<cfset temp = QuerySetCell(d, "STATUS", 'success', 1)>
			<cfset temp = QuerySetCell(d, "PUBLICATIONTYPE", 'journal article', 1)>
			<cfset temp = QuerySetCell(d, "LONGCITE", longCit, 1)>
			<cfset temp = QuerySetCell(d, "SHORTCITE", shortCit, 1)>
			<cfset temp = QuerySetCell(d, "YEAR", pubYear, 1)>
			<cfset l=1>
			<cfloop list="#rauths#" index="a" delimiters="|">
				<cfif l lte 5>
					<cfquery name="a" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select * from (
							select
								preferred_agent_name.agent_name,
								preferred_agent_name.agent_id
							from
								preferred_agent_name,
								agent_name
							where
								preferred_agent_name.agent_id=agent_name.agent_id and
								upper(agent_name.agent_name) like '%#ucase(a)#%'
						) where rownum<=5
					</cfquery>
					<cfif a.recordcount gt 0>
						<cfset thisAuthSugg="">
						<cfloop query="a">
							<cfset thisAuthSuggElem="#agent_name#@#agent_id#">
							<cfset thisAuthSugg=listappend(thisAuthSugg,thisAuthSuggElem,"|")>
						</cfloop>
					<cfelse>
						<cfif idtype is "DOI">
							<cfset thisLastName=r.doi_records[1].doi_record[1].crossref[1].journal[1].journal_article[1].contributors[1].person_name[l].surname.xmltext>
						<cfelseif idtype is "PMID">
							<cfset thisLastName=r.pre[1].PubmedArticle[1].MedlineCitation[1].Article[1].AuthorList[1].Author[l].LastName.xmltext>
						</cfif>

						<cfquery name="a" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							select * from (
								select
									preferred_agent_name.agent_name,
									preferred_agent_name.agent_id
								from
									preferred_agent_name,
									agent_name
								where
									preferred_agent_name.agent_id=agent_name.agent_id and
									upper(agent_name.agent_name) like '%#ucase(thisLastName)#%'
							) where rownum<=5
						</cfquery>
						<cfif a.recordcount gt 0>
							<cfset thisAuthSugg="">
							<cfloop query="a">
								<cfset thisAuthSuggElem="#agent_name#@#agent_id#">
								<cfset thisAuthSugg=listappend(thisAuthSugg,thisAuthSuggElem,"|")>
							</cfloop>
						<cfelse>
							<cfset thisAuthSugg="">
						</cfif>
					</cfif>
					<cfset temp = QuerySetCell(d, "AUTHOR#l#", thisAuthSugg, 1)>
				</cfif>
				<cfset l=l+1>
			</cfloop>
		<cfcatch>
			<cfset fail='error_getting_author: #cfcatch.message# #cfcatch.detail#'>
		</cfcatch>
		</cftry>
	</cfif>
	<cfif len(fail) gt 0>
		<cfset d = querynew("STATUS,PUBLICATIONTYPE,LONGCITE,SHORTCITE,YEAR,AUTHORS")>
		<cfset temp = queryaddrow(d,1)>
		<cfset temp = QuerySetCell(d, "STATUS", 'fail:#cfhttp.statuscode#:#fail#', 1)>
	</cfif>
	<cfreturn d>
</cfoutput>
</cffunction>
<!------------------------------------------------------------------->
<cffunction name="get_docs" access="remote">
	<!---
		deal with whatever structure we have on the doc site here
	--->
	<cfargument name="uri" type="string" required="yes">
	<cfargument name="anchor" type="string" required="no">
	<cfif uri is "lat_long">
		<cfset uri="documentation/places/coordinates">
	<cfelseif uri is "collecting_event">
		<cfset uri="places/collecting-event">
	<cfelseif uri contains "Bulkloader">
		<cfset uri="how-to/create/bulkloader">
	<cfelseif uri is "documentation/cataloged_item">
		<cfset uri="catalog">
	<cfelseif uri is "index">
		<cfset uri="documentation">
	<cfelseif uri is "pageHelp/spatial_query">
		<cfset uri="documentation/places/coordinates">
		<cfset anchor="spatialquery">
	<cfelseif uri is "accession">
		<cfset uri="documentation/transaction/accession">
	<cfelseif uri is "loans">
		<cfset uri="documentation/transaction/loans">
	<cfelse>
		<cfset uri="documentation/#uri#">
	</cfif>
	<cfif not isdefined("anchor") or anchor is "undefined" or len(anchor) is 0>
		<cfset anchor="top">
	</cfif>
	<cfset fullURI="http://arctosdb.wordpress.com/#uri#/###anchor#">
	<cfreturn fullURI>
	<!---
		wordpress randomly gets slow or something, so this is useless

	<cfhttp url="#fullURI#" method="head"></cfhttp>
	<cfif left(cfhttp.statuscode,3) is "200">
		<cfreturn fullURI>
	<cfelse>
		<cfmail subject="doc_not_found" to="#Application.PageProblemEmail#" from="doc_not_found@#Application.fromEmail#" type="html">
			#fullURI# is missing
			<br>----uri-#uri#
			<br>anchor=#anchor#
			<cfdump var=#cgi#>
		</cfmail>
		<cfreturn 404>
	</cfif>

	--->
</cffunction>
<!------------------------------------------------------------------->
<cffunction name="getExternalStatus" access="remote">
	<cfargument name="uri" type="string" required="yes">
	<cfhttp url="#uri#" method="head"></cfhttp>
	<cfreturn left(cfhttp.statuscode,3)>
</cffunction>
<!------------------------------------------------------------------->
<cffunction name="getPartByContainer" access="remote">
	<cfargument name="barcode" type="string" required="yes">
	<cfargument name="i" type="string" required="yes">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			1 C,
			#i# I,
			cat_num,
			cataloged_item.collection_object_id,
			collection,
			part_name,
			condition,
			sampled_from_obj_id,
			coll_obj_disposition,
			scientific_name,
			concatEncumbrances(cataloged_item.collection_object_id) encumbrances,
			specimen_part.collection_object_id as partID,
			concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
			p1.barcode
		 from
			specimen_part,
			coll_object,
			cataloged_item,
			identification,
			collection,
			coll_obj_cont_hist,
			container p,
			container p1
		WHERE
			specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
			specimen_part.collection_object_id = coll_object.collection_object_id AND
			cataloged_item.collection_object_id = identification.collection_object_id AND
			identification.accepted_id_fg = 1 AND
			cataloged_item.collection_id=collection.collection_id AND
			specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id (+) AND
			coll_obj_cont_hist.container_id=p.container_id and
			p.parent_container_id=p1.container_id and
		  	p1.barcode='#barcode#'
	</cfquery>
	<cfif d.recordcount is not 1>
		<cfset rc=d.recordcount>
		<cfset d = querynew("C,I")>
		<cfset temp = queryaddrow(d,1)>
		<cfset temp = QuerySetCell(d, "C", rc, 1)>
		<cfset temp = QuerySetCell(d, "I", i, 1)>
	</cfif>
	<cfreturn d>
</cffunction>
<!------------------------------------------------------------------->
<cffunction name="strToIso8601" access="remote">
	<cfargument name="str" type="string" required="yes">
	<cfset began=''>
	<cfset end="">
	<cfif isdate(str)>
		<cfset began=dateformat(str,"yyyy-mm-dd")>
		<cfset end=dateformat(str,"yyyy-mm-dd")>
	</cfif>
	<cfset result = querynew("I,B,E")>
	<cfset temp = queryaddrow(result,1)>
	<cfset temp = QuerySetCell(result, "I", str, 1)>
	<cfset temp = QuerySetCell(result, "B", began, 1)>
	<cfset temp = QuerySetCell(result, "E", end, 1)>

	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------->
<cffunction name="flagDupAgent" access="remote">
	<cfargument name="bad" type="numeric" required="yes">
	<cfargument name="good" type="numeric" required="yes">
	<cftry>
		<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into agent_relations (agent_id,related_agent_id,agent_relationship) values (#bad#,#good#,'bad duplicate of')
		</cfquery>
		<cfset result = querynew("STATUS,GOOD,BAD,MSG")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "status", "success", 1)>
		<cfset temp = QuerySetCell(result, "GOOD", "#good#", 1)>
		<cfset temp = QuerySetCell(result, "BAD", "#bad#", 1)>
		<cfcatch>
			<cfset result = querynew("STATUS,GOOD,BAD,MSG")>
			<cfset temp = queryaddrow(result,1)>
			<cfset temp = QuerySetCell(result, "status", "fail", 1)>
			<cfset temp = QuerySetCell(result, "GOOD", "#good#", 1)>
			<cfset temp = QuerySetCell(result, "BAD", "#bad#", 1)>
			<cfset temp = QuerySetCell(result, "MSG", "#cfcatch.message#: #cfcatch.detail#", 1)>
		</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------->
<cffunction name="getAttCodeTbl"  access="remote">
	<cfargument name="attribute" type="string" required="yes">
	<cfargument name="collection_cde" type="string" required="yes">
	<cfargument name="element" type="string" required="yes">
	<cfquery name="isCtControlled" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select VALUE_CODE_TABLE,UNITS_CODE_TABLE from ctattribute_code_tables where attribute_type='#attribute#'
	</cfquery>
	<cfif isCtControlled.recordcount is 1>
		<cfif len(isCtControlled.VALUE_CODE_TABLE) gt 0>
			<cfquery name="getCols" datasource="uam_god">
				select column_name from sys.user_tab_columns where table_name='#ucase(isCtControlled.value_code_table)#'
				and column_name <> 'DESCRIPTION'
			</cfquery>
			<cfquery name="valCT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from #isCtControlled.value_code_table#
			</cfquery>
			<cfset collCode = "">
			<cfset columnName = "">
			<cfloop query="getCols">
				<cfif getCols.column_name is "COLLECTION_CDE">
					<cfset collCode = "yes">
				  <cfelse>
					<cfset columnName = "#getCols.column_name#">
				</cfif>
			</cfloop>
			<cfif len(#collCode#) gt 0>
				<cfquery name="valCodes" dbtype="query">
					SELECT #columnName# as valCodes from valCT
					WHERE collection_cde='#collection_cde#'
				</cfquery>
			  <cfelse>
				<cfquery name="valCodes" dbtype="query">
					SELECT #columnName# as valCodes from valCT
				</cfquery>
			</cfif>
			<cfset result = QueryNew("V")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "value",1)>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "#element#",2)>
			<cfset i=3>
			<cfloop query="valCodes">
				<cfset newRow = QueryAddRow(result, 1)>
				<cfset temp = QuerySetCell(result, "v", "#valCodes#",#i#)>
				<cfset i=#i#+1>
			</cfloop>

		<cfelseif #isCtControlled.UNITS_CODE_TABLE# gt 0>
			<cfquery name="getCols" datasource="uam_god">
				select column_name from sys.user_tab_columns where table_name='#ucase(isCtControlled.UNITS_CODE_TABLE)#'
				and column_name <> 'DESCRIPTION'
			</cfquery>
			<cfquery name="valCT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from #isCtControlled.UNITS_CODE_TABLE#
			</cfquery>
			<cfset collCode = "">
			<cfset columnName = "">
			<cfloop query="getCols">
				<cfif getCols.column_name is "COLLECTION_CDE">
					<cfset collCode = "yes">
				  <cfelse>
					<cfset columnName = "#getCols.column_name#">
				</cfif>
			</cfloop>
			<cfif len(#collCode#) gt 0>
				<cfquery name="valCodes" dbtype="query">
					SELECT #columnName# as valCodes from valCT
					WHERE collection_cde='#collection_cde#'
				</cfquery>
			  <cfelse>
				<cfquery name="valCodes" dbtype="query">
					SELECT #columnName# as valCodes from valCT
				</cfquery>
			</cfif>
			<cfset result = "unit - #isCtControlled.UNITS_CODE_TABLE#">
			<cfset result = QueryNew("V")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "units")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "#element#",2)>
			<cfset i=3>
			<cfloop query="valCodes">
				<cfset newRow = QueryAddRow(result, 1)>
				<cfset temp = QuerySetCell(result, "v", "#valCodes#",#i#)>
				<cfset i=#i#+1>
			</cfloop>
		<cfelse>
			<cfset result = QueryNew("V")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "ERROR")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "#element#",2)>
		</cfif>
	<cfelse>
		<cfset result = QueryNew("V")>
		<cfset newRow = QueryAddRow(result, 1)>
		<cfset temp = QuerySetCell(result, "v", "NONE")>
		<cfset newRow = QueryAddRow(result, 1)>
		<cfset temp = QuerySetCell(result, "v", "#element#",2)>
	</cfif>
	<cfreturn result>
</cffunction>
<!---------------------------------------------------------------->
<cffunction name="removeAccnContainer" access="remote">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cfargument name="barcode" type="string" required="yes">
	<cftry>
		<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select container_id from container where barcode='#barcode#'
		</cfquery>
		<cfif c.recordcount is 1>
			<cfquery name="k" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from trans_container where
					transaction_id=#transaction_id# and
					container_id='#c.container_id#'
			</cfquery>
			<cfset r=structNew()>
			<cfset r.status="success">
			<cfset r.transaction_id=transaction_id>
			<cfset r.barcode=barcode>
		<cfelse>
			<cfset r=structNew()>
			<cfset r.status="fail">
			<cfset r.transaction_id=transaction_id>
			<cfset r.barcode=barcode>
			<cfset r.error="barcode not found">
		</cfif>
		<cfcatch>
			<cfset r.status="fail">
			<cfset r.transaction_id=transaction_id>
			<cfset r.barcode=barcode>
			<cfset r.error=cfcatch.message & '; ' & cfcatch.detail>
		</cfcatch>
	</cftry>
	<cfreturn r>
</cffunction>
<!----------------------------------------------->
<cffunction name="addAccnContainer" access="remote">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cfargument name="barcode" type="string" required="yes">
	<cftry>
		<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select container_id from container where barcode='#barcode#'
		</cfquery>
		<cfif c.recordcount is 1>
			<cfquery name="k" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into trans_container (
					transaction_id,
					container_id
				) values (
					#transaction_id#,
					'#c.container_id#'
				)
			</cfquery>
			<cfset r=structNew()>
			<cfset r.status="success">
			<cfset r.transaction_id=transaction_id>
			<cfset r.barcode=barcode>
		<cfelse>
			<cfset r=structNew()>
			<cfset r.status="fail">
			<cfset r.transaction_id=transaction_id>
			<cfset r.barcode=barcode>
			<cfset r.error="barcode not found">
		</cfif>
		<cfcatch>
			<cfset r.status="fail">
			<cfset r.transaction_id=transaction_id>
			<cfset r.barcode=barcode>
			<cfset r.error=cfcatch.message & '; ' & cfcatch.detail>
		</cfcatch>
	</cftry>
	<cfreturn r>
</cffunction>
<!----------------------------------------------->
<cffunction name="saveNewPartAtt" access="remote">
	<cfargument name="attribute_type" type="string" required="yes">
	<cfargument name="partID" type="numeric" required="yes">
	<cfargument name="attribute_value" type="string" required="yes">
	<cfargument name="attribute_units" type="string" required="no">
	<cfargument name="determined_date" type="string" required="no">
	<cfargument name="determined_by_agent_id" type="string" required="no">
	<cfargument name="attribute_remark" type="string" required="no">
	<cfargument name="determined_agent" type="string" required="no">

	<cftry>
		<cfquery name="k" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into specimen_part_attribute (
				collection_object_id,
				attribute_type,
				attribute_value,
				attribute_units,
				determined_date,
				determined_by_agent_id,
				attribute_remark
			) values (
				#partID#,
				'#attribute_type#',
				'#attribute_value#',
				'#attribute_units#',
				'#determined_date#',
				'#determined_by_agent_id#',
				'#attribute_remark#'
			)
		</cfquery>
		<cfset r=structNew()>
		<cfset r.status="spiffy">
		<cfset r.attribute_type=attribute_type>
		<cfset r.attribute_value=attribute_value>
		<cfset r.attribute_units=attribute_units>
		<cfset r.determined_date=determined_date>
		<cfset r.determined_by_agent_id=determined_by_agent_id>
		<cfset r.attribute_remark=attribute_remark>
		<cfset r.determined_agent=determined_agent>
		<cfreturn r>
		<cfcatch>
			<cfset r=structNew()>
			<cfset r.status="fail">
			<cfset r.error=cfcatch.message & '; ' & cfcatch.detail>
		</cfcatch>
	</cftry>
	<cfreturn r>
</cffunction>



<cffunction name="getPartAttOptions" access="remote">
	<cfargument name="patype" type="string" required="yes">
	<cfquery name="k" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ctspec_part_att_att where attribute_type='#patype#'
	</cfquery>
	<cfif len(k.VALUE_code_table) gt 0>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from #k.VALUE_code_table#
		</cfquery>
		<cfloop list="#d.columnlist#" index="i">
			<cfif i is not "description" and i is not "collection_cde">
				<cfquery name="r" dbtype="query">
					select #i# d from d order by #i#
				</cfquery>
			</cfif>
		</cfloop>
		<cfset rA=structNew()>
		<cfset rA.type='value'>
		<cfset rA.values=valuelist(r.d,"|")>
		<cfreturn rA>
	<cfelseif len(k.unit_code_table) gt 0>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from #k.unit_code_table#
		</cfquery>
		<cfloop list="#d.columnlist#" index="i">
			<cfif i is not "description" and i is not "collection_cde">
				<cfquery name="r" dbtype="query">
					select #i# d from d order by #i#
				</cfquery>
			</cfif>
		</cfloop>
		<cfset rA=structNew()>
		<cfset rA.type='unit'>
		<cfset rA.values=valuelist(r.d,"|")>
		<cfreturn rA>
	<cfelse>
		<cfset rA=structNew()>
		<cfset rA.type='none'>
		<cfreturn rA>
	</cfif>
</cffunction>

<cffunction name="deleteCtPartName" access="remote">
	<cfargument name="ctspnid" type="numeric" required="yes">
	<cftry>
		<cfquery name="k" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from ctspecimen_part_name where ctspnid=#ctspnid#
		</cfquery>
		<cfreturn ctspnid>
	<cfcatch>
		<cfreturn cfcatch.message & ': ' & cfcatch.detail>
	</cfcatch>
	</cftry>
</cffunction>
<!------------------------------------------------------->
<cffunction name="getTrans_agent_role" access="remote">
	<cfquery name="k" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select trans_agent_role from cttrans_agent_role where trans_agent_role != 'entered by' order by trans_agent_role
	</cfquery>
	<cfreturn k>
</cffunction>
<!------------------------------------------------------->
<cffunction name="insertAgentName" access="remote">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="id" type="numeric" required="yes">
	<cftry>
		<cfquery name="k" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO agent_name (
				agent_name_id, agent_id, agent_name_type, agent_name)
			VALUES (
				sq_agent_name_id.nextval, #id#, 'aka','#name#')
		</cfquery>
		<cfreturn "success">
	<cfcatch>
		<cfreturn cfcatch.message & ': ' & cfcatch.detail>
	</cfcatch>
	</cftry>
</cffunction>
<!------------------------------------------------------->
<cffunction name="encumberThis" access="remote">
	<cfargument name="cid" type="numeric" required="yes">
	<cfargument name="eid" type="numeric" required="yes">
	<cftry>
		<cfquery name="k" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into  coll_object_encumbrance (ENCUMBRANCE_ID,COLLECTION_OBJECT_ID)
			values (#eid#,#cid#)
		</cfquery>
		<cfreturn cid>
	<cfcatch>
		<cfreturn cfcatch.message & ': ' & cfcatch.detail>
	</cfcatch>
	</cftry>
</cffunction>
<!----------------------------------------------------------------------------------------------->
<cffunction name="getCloneOfCatalogedItemInBulkloaderFormat" access="public" output="true" returnType="query">
	<cfargument name="collection_object_id" type="any" required="yes">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			flat.COLLECTION_OBJECT_ID,
			'cloned from ' || flat.guid loaded,
			sys_context('USERENV', 'SESSION_USER') enteredby,
			flat.ACCESSION ACCN,
			identification.scientific_name taxon_name,
			identification.nature_of_id,
			identification.made_date,
			identification.IDENTIFICATION_REMARKS,
			flat.collection_cde,
			flat.institution_acronym,
			flat.remarks COLL_OBJECT_REMARKS,
			flat.COLLECTING_EVENT_ID,
			idagnt.agent_name id_by_agent,
			identification_agent.IDENTIFIER_ORDER,
			coll_obj_other_id_num.other_id_type,
			coll_obj_other_id_num.display_value,
			colagnt.agent_name collname,
			collector.COLLECTOR_ROLE,
			collector.coll_order,
			specimen_part.part_name,
			coll_object.condition,
			p.barcode,
			p.label,
			to_char(coll_object.lot_count) lot_count,
			coll_object.COLL_OBJ_DISPOSITION,
			coll_object_remark.coll_object_remarks partremark,
			attributes.ATTRIBUTE_TYPE,
			attributes.ATTRIBUTE_VALUE,
			attributes.ATTRIBUTE_UNITS,
			attributes.ATTRIBUTE_REMARK,
			atagnt.agent_name atder,
			attributes.DETERMINED_DATE,
			attributes.DETERMINATION_METHOD
		from
			flat,
			identification,
			identification_agent,
			preferred_agent_name idagnt,
			coll_obj_other_id_num,
			collector,
			preferred_agent_name colagnt,
			specimen_part,
			coll_object,
			coll_object_remark,
			coll_obj_cont_hist,
			container c,
			container p,
			attributes,
			preferred_agent_name atagnt
		where
			flat.collection_object_id=identification.collection_object_id and
			identification.accepted_id_fg=1 and
			identification.identification_id=identification_agent.identification_id and
			identification_agent.agent_id=idagnt.agent_id and
			flat.collection_object_id=coll_obj_other_id_num.collection_object_id (+) and
			flat.collection_object_id=collector.collection_object_id (+) and
			collector.agent_id=colagnt.agent_id (+) and
			flat.collection_object_id=specimen_part.derived_from_cat_item (+) and
			specimen_part.collection_object_id=coll_object.collection_object_id  (+) and
			specimen_part.collection_object_id=coll_object_remark.collection_object_id (+) and
			specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
			coll_obj_cont_hist.container_id=c.container_id (+) and
			c.parent_container_id=p.container_id (+) and
			flat.collection_object_id=attributes.collection_object_id (+) and
			attributes.DETERMINED_BY_AGENT_ID=atagnt.agent_id (+) and
			flat.collection_object_id in (#collection_object_id#)
	</cfquery>
	<cfquery name="one" dbtype="query">
		select
			COLLECTION_OBJECT_ID,
			loaded,
			enteredby,
			ACCN,
			taxon_name,
			nature_of_id,
			made_date,
			IDENTIFICATION_REMARKS,
			collection_cde,
			institution_acronym,
			COLL_OBJECT_REMARKS,
			COLLECTING_EVENT_ID
		from d group by
			COLLECTION_OBJECT_ID,
			loaded,
			enteredby,
			ACCN,
			taxon_name,
			nature_of_id,
			made_date,
			IDENTIFICATION_REMARKS,
			collection_cde,
			institution_acronym,
			COLL_OBJECT_REMARKS,
			COLLECTING_EVENT_ID
	</cfquery>
	<cfset result = querynew("
		COLLECTION_OBJECT_ID,
		LOADED,
		ENTEREDBY,
		ACCN,
		TAXON_NAME,
		NATURE_OF_ID,
		MADE_DATE,
		IDENTIFICATION_REMARKS,
		collection_cde,
		institution_acronym,
		COLL_OBJECT_REMARKS,
		COLLECTING_EVENT_ID,
		ID_MADE_BY_AGENT,
		OTHER_ID_NUM_1,
		OTHER_ID_NUM_2,
		OTHER_ID_NUM_3,
		OTHER_ID_NUM_4,
		OTHER_ID_NUM_5,
		OTHER_ID_NUM_TYPE_1,
		OTHER_ID_NUM_TYPE_2,
		OTHER_ID_NUM_TYPE_3,
		OTHER_ID_NUM_TYPE_4,
		OTHER_ID_NUM_TYPE_5,
		COLLECTOR_AGENT_1,
		COLLECTOR_ROLE_1,
		COLLECTOR_AGENT_2,
		COLLECTOR_ROLE_2,
		COLLECTOR_AGENT_3,
		COLLECTOR_ROLE_3,
		COLLECTOR_AGENT_4,
		COLLECTOR_ROLE_4,
		COLLECTOR_AGENT_5,
		COLLECTOR_ROLE_5,
		COLLECTOR_AGENT_6,
		COLLECTOR_ROLE_6,
		COLLECTOR_AGENT_7,
		COLLECTOR_ROLE_7,
		COLLECTOR_AGENT_8,
		COLLECTOR_ROLE_8,
		PART_NAME_1,
		PART_CONDITION_1,
		PART_BARCODE_1,
		PART_CONTAINER_LABEL_1,
		PART_LOT_COUNT_1,
		PART_DISPOSITION_1,
		PART_REMARK_1,
		PART_NAME_2,
		PART_CONDITION_2,
		PART_BARCODE_2,
		PART_CONTAINER_LABEL_2,
		PART_LOT_COUNT_2,
		PART_DISPOSITION_2,
		PART_REMARK_2,
		PART_NAME_3,
		PART_CONDITION_3,
		PART_BARCODE_3,
		PART_CONTAINER_LABEL_3,
		PART_LOT_COUNT_3,
		PART_DISPOSITION_3,
		PART_REMARK_3,
		PART_NAME_4,
		PART_CONDITION_4,
		PART_BARCODE_4,
		PART_CONTAINER_LABEL_4,
		PART_LOT_COUNT_4,
		PART_DISPOSITION_4,
		PART_REMARK_4,
		PART_NAME_5,
		PART_CONDITION_5,
		PART_BARCODE_5,
		PART_CONTAINER_LABEL_5,
		PART_LOT_COUNT_5,
		PART_DISPOSITION_5,
		PART_REMARK_5,
		PART_NAME_6,
		PART_CONDITION_6,
		PART_BARCODE_6,
		PART_CONTAINER_LABEL_6,
		PART_LOT_COUNT_6,
		PART_DISPOSITION_6,
		PART_REMARK_6,
		PART_NAME_7,
		PART_CONDITION_7,
		PART_BARCODE_7,
		PART_CONTAINER_LABEL_7,
		PART_LOT_COUNT_7,
		PART_DISPOSITION_7,
		PART_REMARK_7,
		PART_NAME_8,
		PART_CONDITION_8,
		PART_BARCODE_8,
		PART_CONTAINER_LABEL_8,
		PART_LOT_COUNT_8,
		PART_DISPOSITION_8,
		PART_REMARK_8,
		PART_NAME_9,
		PART_CONDITION_9,
		PART_BARCODE_9,
		PART_CONTAINER_LABEL_9,
		PART_LOT_COUNT_9,
		PART_DISPOSITION_9,
		PART_REMARK_9,
		PART_NAME_10,
		PART_CONDITION_10,
		PART_BARCODE_10,
		PART_CONTAINER_LABEL_10,
		PART_LOT_COUNT_10,
		PART_DISPOSITION_10,
		PART_REMARK_10 ,
		PART_NAME_11,
		PART_CONDITION_11,
		PART_BARCODE_11,
		PART_CONTAINER_LABEL_11,
		PART_LOT_COUNT_11,
		PART_DISPOSITION_11,
		PART_REMARK_11 ,
		PART_NAME_12,
		PART_CONDITION_12,
		PART_BARCODE_12,
		PART_CONTAINER_LABEL_12,
		PART_LOT_COUNT_12,
		PART_DISPOSITION_12,
		PART_REMARK_12,
		ATTRIBUTE_1,
		ATTRIBUTE_VALUE_1,
		ATTRIBUTE_UNITS_1,
		ATTRIBUTE_REMARKS_1,
		ATTRIBUTE_DATE_1,
		ATTRIBUTE_DET_METH_1,
		ATTRIBUTE_DETERMINER_1,
		ATTRIBUTE_2,
		ATTRIBUTE_VALUE_2,
		ATTRIBUTE_UNITS_2,
		ATTRIBUTE_REMARKS_2,
		ATTRIBUTE_DATE_2,
		ATTRIBUTE_DET_METH_2,
		ATTRIBUTE_DETERMINER_2,
		ATTRIBUTE_3,
		ATTRIBUTE_VALUE_3,
		ATTRIBUTE_UNITS_3,
		ATTRIBUTE_REMARKS_3,
		ATTRIBUTE_DATE_3,
		ATTRIBUTE_DET_METH_3,
		ATTRIBUTE_DETERMINER_3,
		ATTRIBUTE_4,
		ATTRIBUTE_VALUE_4,
		ATTRIBUTE_UNITS_4,
		ATTRIBUTE_REMARKS_4,
		ATTRIBUTE_DATE_4,
		ATTRIBUTE_DET_METH_4,
		ATTRIBUTE_DETERMINER_4,
		ATTRIBUTE_5,
		ATTRIBUTE_VALUE_5,
		ATTRIBUTE_UNITS_5,
		ATTRIBUTE_REMARKS_5,
		ATTRIBUTE_DATE_5,
		ATTRIBUTE_DET_METH_5,
		ATTRIBUTE_DETERMINER_5,
		ATTRIBUTE_6,
		ATTRIBUTE_VALUE_6,
		ATTRIBUTE_UNITS_6,
		ATTRIBUTE_REMARKS_6,
		ATTRIBUTE_DATE_6,
		ATTRIBUTE_DET_METH_6,
		ATTRIBUTE_DETERMINER_6,
		ATTRIBUTE_7,
		ATTRIBUTE_VALUE_7,
		ATTRIBUTE_UNITS_7,
		ATTRIBUTE_REMARKS_7,
		ATTRIBUTE_DATE_7,
		ATTRIBUTE_DET_METH_7,
		ATTRIBUTE_DETERMINER_7,
		ATTRIBUTE_8,
		ATTRIBUTE_VALUE_8,
		ATTRIBUTE_UNITS_8,
		ATTRIBUTE_REMARKS_8,
		ATTRIBUTE_DATE_8,
		ATTRIBUTE_DET_METH_8,
		ATTRIBUTE_DETERMINER_8,
		ATTRIBUTE_9,
		ATTRIBUTE_VALUE_9,
		ATTRIBUTE_UNITS_9,
		ATTRIBUTE_REMARKS_9,
		ATTRIBUTE_DATE_9,
		ATTRIBUTE_DET_METH_9,
		ATTRIBUTE_DETERMINER_9,
		ATTRIBUTE_10,
		ATTRIBUTE_VALUE_10,
		ATTRIBUTE_UNITS_10,
		ATTRIBUTE_REMARKS_10,
		ATTRIBUTE_DATE_10,
		ATTRIBUTE_DET_METH_10,
		ATTRIBUTE_DETERMINER_10
	")>


	<cfset i=1>
	<cfloop query="one">
		<cfset status="">
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "COLLECTION_OBJECT_ID", "#one.COLLECTION_OBJECT_ID#", i)>
		<cfset temp = QuerySetCell(result, "enteredby", "#enteredby#", i)>
		<cfset temp = QuerySetCell(result, "ACCN", "#ACCN#", i)>
		<cfset temp = QuerySetCell(result, "taxon_name", "#taxon_name#", i)>
		<cfset temp = QuerySetCell(result, "nature_of_id", "#nature_of_id#", i)>
		<cfset temp = QuerySetCell(result, "made_date", "#made_date#", i)>
		<cfset temp = QuerySetCell(result, "IDENTIFICATION_REMARKS", "#IDENTIFICATION_REMARKS#", i)>
		<cfset temp = QuerySetCell(result, "collection_cde", "#collection_cde#", i)>
		<cfset temp = QuerySetCell(result, "institution_acronym", "#institution_acronym#", i)>
		<cfset temp = QuerySetCell(result, "COLL_OBJECT_REMARKS", "#COLL_OBJECT_REMARKS#", i)>
		<cfset temp = QuerySetCell(result, "COLLECTING_EVENT_ID", "#COLLECTING_EVENT_ID#", i)>
		<cfquery name="idby" dbtype="query">
			select
				id_by_agent
			from
				d
			where
				collection_object_id=#one.collection_object_id#
			group by
				id_by_agent
		</cfquery>
		<cfif idby.recordcount is 1>
			<cfset QuerySetCell(result, "ID_MADE_BY_AGENT", "#idby.id_by_agent#", i)>
		<cfelse>
			<cfset status=listappend(status,'too_many_identifiers',";")>
		</cfif>
		<cfquery name="oid" dbtype="query">
			select
				other_id_type,
				display_value
			from
				d
			where
				collection_object_id=#one.collection_object_id#
			group by
				other_id_type,
				display_value
		</cfquery>
		<cfset n=1>
		<cfloop query="oid">
			<cfif n lte 5>
				<cfset QuerySetCell(result, "OTHER_ID_NUM_#n#", "#oid.display_value#", i)>
				<cfset QuerySetCell(result, "OTHER_ID_NUM_TYPE_#n#", "#oid.other_id_type#", i)>
				<cfset n=n+1>
			</cfif>
		</cfloop>
		<cfif oid.recordcount gt 5>
			<cfset status=listappend(status,'too_many_otherids',";")>
		</cfif>
		<cfquery name="col" dbtype="query">
			select
				collname,
				COLLECTOR_ROLE
			from
				d
			where
				collection_object_id=#one.collection_object_id#
			group by
				collname,
				COLLECTOR_ROLE
			order by
				coll_order
		</cfquery>
		<cfset n=1>
		<cfloop query="col">
			<cfif n lte 8>
				<cfset QuerySetCell(result, "COLLECTOR_AGENT_#n#", "#col.collname#", i)>
				<cfset QuerySetCell(result, "COLLECTOR_ROLE_#n#", "#col.COLLECTOR_ROLE#", i)>
				<cfset n=n+1>
			</cfif>
		</cfloop>
		<cfif col.recordcount gt 8>
			<cfset status=listappend(status,'too_many_collectors',";")>
		</cfif>
		<cfquery name="prt" dbtype="query">
			select
				part_name,
				condition,
				barcode,
				label,
				lot_count,
				COLL_OBJ_DISPOSITION,
				partremark
			from
				d
			where
				collection_object_id=#one.collection_object_id#
			group by
				part_name,
				condition,
				barcode,
				label,
				lot_count,
				COLL_OBJ_DISPOSITION,
				partremark
		</cfquery>
		<cfset n=1>
		<cfloop query="prt">
			<cfif n lte 12>
				<cfset QuerySetCell(result, "PART_NAME_#n#", "#prt.part_name#", i)>
				<cfset QuerySetCell(result, "PART_CONDITION_#n#", "#prt.condition#", i)>
				<cfset QuerySetCell(result, "PART_BARCODE_#n#", "#prt.barcode#", i)>
				<cfset QuerySetCell(result, "PART_CONTAINER_LABEL_#n#", "#prt.label#", i)>
				<cfset QuerySetCell(result, "PART_LOT_COUNT_#n#", "#prt.lot_count#", i)>
				<cfset QuerySetCell(result, "PART_DISPOSITION_#n#", "#prt.COLL_OBJ_DISPOSITION#", i)>
				<cfset QuerySetCell(result, "PART_REMARK_#n#", "#prt.partremark#", i)>
				<cfset n=n+1>
			</cfif>
		</cfloop>
		<cfif prt.recordcount gt 12>
			<cfset status=listappend(status,'too_many_parts',";")>
		</cfif>
		<cfquery name="att" dbtype="query">
			select
				ATTRIBUTE_TYPE,
				ATTRIBUTE_VALUE,
				ATTRIBUTE_UNITS,
				ATTRIBUTE_REMARK,
				atder,
				DETERMINED_DATE,
				DETERMINATION_METHOD
			from
				d
			where
				collection_object_id=#one.collection_object_id#
			group by
				ATTRIBUTE_TYPE,
				ATTRIBUTE_VALUE,
				ATTRIBUTE_UNITS,
				ATTRIBUTE_REMARK,
				atder,
				DETERMINED_DATE,
				DETERMINATION_METHOD
		</cfquery>
		<cfset n=1>
		<cfloop query="att">
			<cfif n lte 10>
				<cfset QuerySetCell(result, "ATTRIBUTE_#n#", "#att.ATTRIBUTE_TYPE#", i)>
				<cfset QuerySetCell(result, "ATTRIBUTE_VALUE_#n#", "#att.ATTRIBUTE_VALUE#", i)>
				<cfset QuerySetCell(result, "ATTRIBUTE_UNITS_#n#", "#att.ATTRIBUTE_UNITS#", i)>
				<cfset QuerySetCell(result, "ATTRIBUTE_REMARKS_#n#", "#att.ATTRIBUTE_REMARK#", i)>
				<cfset QuerySetCell(result, "ATTRIBUTE_DATE_#n#", "#att.DETERMINED_DATE#", i)>
				<cfset QuerySetCell(result, "ATTRIBUTE_DET_METH_#n#", "#att.DETERMINATION_METHOD#", i)>
				<cfset QuerySetCell(result, "ATTRIBUTE_DETERMINER_#n#", "#att.atder#", i)>
				<cfset n=n+1>
			</cfif>
		</cfloop>
		<cfif prt.recordcount gt 10>
			<cfset status=listappend(status,'too_many_attributes',";")>
		</cfif>
		<cfset status=listprepend(status,one.loaded,";")>
		<cfset temp = QuerySetCell(result, "loaded", "#status#", i)>
		<cfset i=i+1>
	</cfloop>
	<cfreturn RESULT>
</cffunction>
<!--------------------------------------------------------------------------------------------------------->
<cffunction name="cloneCatalogedItem" access="remote" output="true">
	<cfargument name="collection_object_id" type="numeric" required="yes">
	<cfargument name="numRecs" type="numeric" required="yes">
	<cfargument name="refType" type="string" required="yes">
	<cfargument name="taxon_name" type="string" required="yes">
	<cfargument name="collection_id" type="numeric" required="yes">
	<cfset status="spiffy">
	<cftransaction>
	<cfloop from="1" to="#numRecs#" index="lpNum">
		<cftry>
			<cfset problem="">
			<cfquery name="k" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select somerandomsequence.nextval c from dual
			</cfquery>
			<cfset key=k.c>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into bulkloader (
					COLLECTION_OBJECT_ID,
					LOADED,
					ENTEREDBY,
					ACCN,
					TAXON_NAME,
					NATURE_OF_ID,
					MADE_DATE,
					COLLECTION_CDE,
					INSTITUTION_ACRONYM,
					COLL_OBJECT_REMARKS,
					COLLECTING_EVENT_ID,
					SPECIMEN_EVENT_TYPE,
					EVENT_ASSIGNED_BY_AGENT,
					EVENT_ASSIGNED_DATE,
					COLLECTING_SOURCE
					<cfif len(refType) gt 0>
						,OTHER_ID_NUM_TYPE_1,
						OTHER_ID_NUM_1,
						OTHER_ID_REFERENCES_1
					</cfif>
				) (	select
						#key#,
						'cloned from ' || guid,
						'#session.username#',
						ACCESSION,
						<cfif len(taxon_name) gt 0>
							'#taxon_name#' as scientific_name,
						<cfelse>
							scientific_name,
						</cfif>
						nature_of_id,
						made_date,
						(select COLLECTION_CDE from collection where collection_id=#collection_id#),
						(select INSTITUTION_ACRONYM from collection where collection_id=#collection_id#),
						REMARKS,
						COLLECTING_EVENT_ID,
						SPECIMEN_EVENT_TYPE,
						EVENT_ASSIGNED_BY_AGENT,
						EVENT_ASSIGNED_DATE,
						COLLECTING_SOURCE
						<cfif len(refType) gt 0>
							,SUBSTR(guid, 1 ,INSTR(guid, ':', 1, 2)-1),
							cat_num,
							'#refType#'
						</cfif>
					from
						flat
					where
						collection_object_id = #collection_object_id#
				)
			</cfquery>
			<cfquery name="idby" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					agent_name
				from
					identification,
					identification_agent,
					preferred_agent_name
				where
					identification.identification_id=identification_agent.identification_id and
					identification_agent.agent_id=preferred_agent_name.agent_id and
					identification.collection_object_id = #collection_object_id#
				order by IDENTIFIER_ORDER
			</cfquery>
			<cfif idby.recordcount is 1>
				<cfquery name="iidby" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update bulkloader set ID_MADE_BY_AGENT='#idby.agent_name#'
					where collection_object_id=#key#
				</cfquery>
			<cfelse>
				<cfset problem="too many identifiers: #valuelist(idby.agent_name)#">
			</cfif>
			<cfquery name="oid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					other_id_type,
					display_value
				from coll_obj_other_id_num
				where collection_object_id=#collection_object_id#
			</cfquery>
			<cfif oid.recordcount gt 0>
				<!---
					reserve ID1 for a pointer to the record we're cloning
					ID5 is custom
					can use 2, 3, and 4 here
					---->
				<cfset i=2>
				<cfset sql="update bulkloader set ">
				<cfloop query="oid">
					<cfif i lt 4>
						<cfset sql=sql & "OTHER_ID_NUM_TYPE_#i# = '#other_id_type#',OTHER_ID_NUM_#i#='#display_value#',">
						<cfset i=i+1>
					</cfif>
				</cfloop>
				<cfset sql=sql & ' where collection_object_id=#key#'>
				<cfset sql=replace(sql,", where"," where","all")>
				<cfquery name="ioid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					#preservesinglequotes(sql)#
				</cfquery>
			</cfif>
			<cfif oid.recordcount gte 3>
				<cfset ids="">
				<cfloop query="oid">
					<cfset ids=listappend(ids,"#other_id_type#=#display_value#",";")>
				</cfloop>
				<cfset problem="too many IDs: #ids#">
			</cfif>

			<cfquery name="col" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					agent_name,
					COLLECTOR_ROLE
				from
					collector,
					preferred_agent_name
				where
					collector.agent_id=preferred_agent_name.agent_id and
					collector.collection_object_id=#collection_object_id#
				order by
					COLLECTOR_ROLE,
					COLL_ORDER
			</cfquery>

			<cfif col.recordcount gt 0>
				<cfset i=1>
				<cfset sql="update bulkloader set ">
				<cfloop query="col">
					<cfif i lt 9>
						<cfset sql=sql & "COLLECTOR_AGENT_#i# = '#agent_name#',
							COLLECTOR_ROLE_#i#='#COLLECTOR_ROLE#',">
						<cfset i=i+1>
					</cfif>
				</cfloop>
				<cfset sql=sql & ' where collection_object_id=#key#'>
				<cfset sql=replace(sql,", where"," where","all")>
				<cfquery name="icoll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					#preservesinglequotes(sql)#
				</cfquery>
			</cfif>
			<cfif col.recordcount gt 8>
				<cfset ids="">
				<cfloop query="oid">
					<cfset ids=listappend(ids,"#other_id_type#=#display_value#",";")>
				</cfloop>
				<cfset problem="too many collectors: #valuelist(col.agent_name)#">
			</cfif>


			<cfquery name="part" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					part_name,
					condition,
					p.barcode,
					p.label,
					to_char(lot_count) lot_count,
					COLL_OBJ_DISPOSITION,
					coll_object_remarks
				from
					specimen_part,
					coll_object,
					coll_object_remark,
					coll_obj_cont_hist,
					container c,
					container p
				where
					specimen_part.collection_object_id=coll_object.collection_object_id and
					specimen_part.collection_object_id=coll_object_remark.collection_object_id (+) and
					specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
					coll_obj_cont_hist.container_id=c.container_id (+) and
					c.parent_container_id=p.container_id (+) and
					specimen_part.derived_from_cat_item=#collection_object_id#
			</cfquery>

			<cfif part.recordcount gt 0>
				<cfset i=1>
				<cfset sql="update bulkloader set ">
				<cfloop query="part">
					<cfif i lt 13>
						<cfset sql=sql & "PART_NAME_#i# = '#part_name#',
							PART_CONDITION_#i#='#condition#',
							PART_BARCODE_#i#='#barcode#',
							PART_CONTAINER_LABEL_#i#='#label#',
							PART_LOT_COUNT_#i#='#lot_count#',
							PART_DISPOSITION_#i#='#COLL_OBJ_DISPOSITION#',
							PART_REMARK_#i#='#coll_object_remarks#',">
						<cfset i=i+1>
					</cfif>
				</cfloop>
				<cfset sql=sql & ' where collection_object_id=#key#'>
				<cfset sql=replace(sql,", where"," where","all")>
				<cfquery name="ipart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					#preservesinglequotes(sql)#
				</cfquery>
			</cfif>
			<cfif part.recordcount gt 12>
				<cfset problem="too many part: #valuelist(part.part_name)#">
			</cfif>



			<cfquery name="att" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					ATTRIBUTE_TYPE,
					ATTRIBUTE_VALUE,
					ATTRIBUTE_UNITS,
					ATTRIBUTE_REMARK,
					agent_name,
					DETERMINED_DATE,
					DETERMINATION_METHOD
				from
					attributes,
					preferred_agent_name
				where
					attributes.DETERMINED_BY_AGENT_ID=preferred_agent_name.agent_id and
					attributes.collection_object_id=#collection_object_id#
			</cfquery>
			<!--- attributes 1 through 6 are customizable and we can't use them here --->
			<cfif att.recordcount gt 0>
				<cfset i=7>
				<cfset sql="update bulkloader set ">
				<cfloop query="att">
					<cfif i lte 10>
						<cfset sql=sql & "ATTRIBUTE_#i# = '#ATTRIBUTE_TYPE#',
							ATTRIBUTE_VALUE_#i#='#ATTRIBUTE_VALUE#',
							ATTRIBUTE_UNITS_#i#='#ATTRIBUTE_UNITS#',
							ATTRIBUTE_REMARKS_#i#='#ATTRIBUTE_REMARK#',
							ATTRIBUTE_DATE_#i#='#DETERMINED_DATE#',
							ATTRIBUTE_DET_METH_#i#='#DETERMINATION_METHOD#',
							ATTRIBUTE_DETERMINER_#i#='#agent_name#',">
						<cfset i=i+1>
					</cfif>
				</cfloop>
				<cfset sql=sql & ' where collection_object_id=#key#'>
				<cfset sql=replace(sql,", where"," where","all")>
				<cfquery name="iatt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					#preservesinglequotes(sql)#
				</cfquery>
			</cfif>
			<cfif att.recordcount gt 4>
				<cfset problem="too many attribute: #valuelist(att.ATTRIBUTE_TYPE)#">
			</cfif>
			<cfif len(problem) gt 0>
				<cfquery name="irel" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update bulkloader set
						COLL_OBJECT_REMARKS='#problem#'
					where collection_object_id=#key#
				</cfquery>
			</cfif>
		<cfcatch>
			<cfset status="fail">
			<CFDUMP VAR=#CFCATCH#>
		</cfcatch>
	</cftry>
	</cfloop>
	<cfif status is "fail">
		<cftransaction action="rollback">
	</cfif>
	</cftransaction>

	<cfreturn status>
</cffunction>
<!------------------------------------------------------->
<cffunction name="getGeologyValues" access="remote">
	<cfargument name="attribute" type="string" required="no">
	<cfif isdefined("attribute") and len(attribute) gt 0>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				attribute_value
			FROM
				geology_attribute_hierarchy
			WHERE
				USABLE_VALUE_FG=1 and
				attribute='#attribute#'
			group by attribute_value
			order by attribute_value
		</cfquery>
		<cfreturn d>
	<cfelse>
		<cfreturn ''>
	</cfif>
</cffunction>

<!------------------------------------------------------->
<cffunction name="saveAgentRank" access="remote">
	<cfargument name="agent_id" type="numeric" required="yes">
	<cfargument name="agent_rank" type="string" required="yes">
	<cfargument name="remark" type="string" required="yes">
	<cfargument name="transaction_type" type="string" required="yes">
	<cfinclude template="/includes/functionLib.cfm">
	<cftry>
		<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into agent_rank (
				agent_id,
				agent_rank,
				ranked_by_agent_id,
				remark,
				transaction_type
			) values (
				#agent_id#,
				'#agent_rank#',
				#session.myAgentId#,
				'#escapeQuotes(remark)#',
				'#transaction_type#'
			)
		</cfquery>
		<cfreturn agent_id>
	<cfcatch>
		<cfreturn "fail: #cfcatch.Message# #cfcatch.Detail# #cfcatch.sql#">
	</cfcatch>
	</cftry>
</cffunction>
<!------------------------------------------------------->
<cffunction name="getPubAttributes" access="remote">
	<cfargument name="attribute" type="string" required="yes">
	<cftry>
		<cfquery name="res" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select control from ctpublication_attribute where publication_attribute ='#attribute#'
		</cfquery>
		<cfif len(res.control) gt 0>
			<cfquery name="ctval" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from #res.control#
			</cfquery>
			<cfset cl=ctval.columnlist>
			<cfif listcontainsnocase(cl,"description")>
				<cfset cl=listdeleteat(cl,listfindnocase(cl,"description"))>
			</cfif>
			<cfif listcontainsnocase(cl,"collection_cde")>
				<cfset cl=listdeleteat(cl,listfindnocase(cl,"collection_cde"))>
			</cfif>
			<cfif listlen(cl) is 1>
				<cfquery name="return" dbtype="query">
					select #cl# as v from ctval order by #cl#
				</cfquery>
				<cfreturn return>
			<cfelse>
				<cfreturn "fail: cl is #cl#">
			</cfif>
		</cfif>
	<cfcatch>
		<cfreturn "fail: #cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn "nocontrol">
</cffunction>
<!------------------------------------------------------->
<cffunction name="kill_canned_search" access="remote">
	<cfargument name="canned_id" type="numeric" required="yes">
	<cftry>
		<cfquery name="res" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from cf_canned_search where canned_id=#canned_id#
		</cfquery>
		<cfset result="#canned_id#">
	<cfcatch>
		<cfset result = "failure: #cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
		<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="genMD5" access="remote">
	<cfargument name="uri" type="string" required="yes">
	<cfif len(uri) is 0>
		<cfreturn ''>
	<cfelseif uri contains application.serverRootUrl>
		<cftry>
		<cfset f=replace(uri,application.serverRootUrl,application.webDirectory)>
		<cffile action="readbinary" file="#f#" variable="myBinaryFile">
		<cfset md5 = createObject("component","includes.cfc.hashBinary").hashBinary(myBinaryFile)>
		<cfreturn md5>
		<cfcatch>
			<cfreturn "">
		</cfcatch>
		</cftry>
	<cfelse>
		<cftry>
			<cfhttp url="#uri#" getAsbinary="yes" />
			<cfset md5 = createObject("component","includes.cfc.hashBinary").hashBinary(cfhttp.filecontent)>
			<cfreturn md5>
		<cfcatch>
			<cfreturn "">
		</cfcatch>
		</cftry>
	</cfif>
</cffunction>
<!-------------------------------------------->
<cffunction name="saveLocSrchPref" access="remote">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="onOff" type="numeric" required="yes">
	<cfif isdefined("session.username") and len(#session.username#) gt 0>
		<cftry>
			<cfquery name="ins" datasource="cf_dbuser">
				select LOCSRCHPREFS from cf_users
				where username='#session.username#'
			</cfquery>
			<cfset cv=valuelist(ins.LOCSRCHPREFS)>
			<cfif onOff is 1>
				<cfif not listfind(cv,id)>
					<cfset nv=listappend(cv,id)>
				</cfif>
			<cfelse>
				<cfif listfind(cv,id)>
					<cfset nv=listdeleteat(cv,listfind(cv,id))>
				</cfif>
			</cfif>
			<cfquery name="ins" datasource="cf_dbuser">
				update cf_users set LOCSRCHPREFS='#nv#'
				where username='#session.username#'
			</cfquery>
			<cfset session.locSrchPrefs=nv>
			<cfcatch><!-- nada --></cfcatch>
		</cftry>
	</cfif>
	<cfreturn 1>
</cffunction>
<!------------------------------------------->
<cffunction name="updatePartDisposition" access="remote">
	<cfargument name="part_id" type="numeric" required="yes">
	<cfargument name="disposition" type="string" required="yes">
	<cftry>
		<cfquery name="upPartDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update coll_object set COLL_OBJ_DISPOSITION
			='#disposition#' where
			collection_object_id=#part_id#
		</cfquery>
		<cfset result = querynew("STATUS,PART_ID,DISPOSITION")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "status", "success", 1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "disposition", "#disposition#", 1)>
	<cfcatch>
		<cfset result = querynew("STATUS,PART_ID,DISPOSITION")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "status", "failure", 1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "disposition", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
	</cfcatch>
	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------------->
<cffunction name="remPartFromLoan" access="remote">
	<cfargument name="part_id" type="numeric" required="yes">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cftry>
		<cfquery name="killPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from loan_item where
			collection_object_id = #part_id# and
			transaction_id=#transaction_id#
		</cfquery>
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "success", 1)>
	<cfcatch>
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
	</cfcatch>

	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------------->
<cffunction name="del_remPartFromLoan" access="remote">
	<cfargument name="part_id" type="numeric" required="yes">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cftry>
		<cftransaction>
			<cfquery name="killPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from loan_item where
				collection_object_id = #part_id# and
				transaction_id=#transaction_id#
			</cfquery>
			<cfquery name="killPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from specimen_part where collection_object_id = #part_id#
			</cfquery>
		</cftransaction>
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "success", 1)>
	<cfcatch>
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
	</cfcatch>
	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------------->
<cffunction name="updateInstructions" access="remote">
	<cfargument name="part_id" type="numeric" required="yes">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cfargument name="item_instructions" type="string" required="yes">
	<cftry>
		<cftransaction>
			<cfquery name="upIns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update loan_item set
				ITEM_INSTRUCTIONS = '#item_instructions#'
				where
				TRANSACTION_ID=#transaction_id# and
				COLLECTION_OBJECT_ID = #part_id#
			</cfquery>
		</cftransaction>
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "success", 1)>
	<cfcatch>
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
	</cfcatch>

	</cftry>
		<cfreturn result>
</cffunction>
<!----------------------------------------->
<cffunction name="updateLoanItemRemarks" access="remote">
	<cfargument name="part_id" type="numeric" required="yes">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cfargument name="loan_item_remarks" type="string" required="yes">
	<cftry>
		<cftransaction>
			<cfquery name="upIns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update loan_item set
				loan_item_remarks = '#loan_item_remarks#'
				where
				TRANSACTION_ID=#transaction_id# and
				COLLECTION_OBJECT_ID = #part_id#
			</cfquery>
		</cftransaction>
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "success", 1)>
	<cfcatch>
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
	</cfcatch>

	</cftry>
		<cfreturn result>
</cffunction>
<!------------------------------------------->
<cffunction name="updateCondition" access="remote">
	<cfargument name="part_id" type="numeric" required="yes">
	<cfargument name="condition" type="string" required="yes">
	<cftry>
		<cftransaction>
			<cfquery name="upIns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update coll_object set
				condition = '#condition#'
				where
				COLLECTION_OBJECT_ID = #part_id#
			</cfquery>
		</cftransaction>
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "success", 1)>
	<cfcatch>
		<cfset result = querynew("PART_ID,MESSAGE")>
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "part_id", "#part_id#", 1)>
		<cfset temp = QuerySetCell(result, "message", "A query error occured: #cfcatch.Message# #cfcatch.Detail#", 1)>
	</cfcatch>

	</cftry>
		<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="moveContainer" access="remote">
	<cfargument name="box_position" type="numeric" required="yes">
	<cfargument name="position_id" type="numeric" required="yes">
	<cfargument name="barcode" type="string" required="yes">
	<cfset thisContainerId = "">
	<CFTRY>
		<cfquery name="thisID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select container_id,label from container where barcode='#barcode#'
			AND container_type = 'cryovial'
		</cfquery>
		<cfif #thisID.recordcount# is 0>
			<cfquery name="thisID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select container_id,label from container where barcode='#barcode#'
				AND container_type = 'cryovial label'
			</cfquery>
			<cfif #thisID.recordcount# is 1>
				<cfquery name="update" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update container set container_type='cryovial'
					where container_id=#thisID.container_id#
				</cfquery>
				<cfset thisContainerId = #thisID.container_id#>
			</cfif>
		<cfelse>
			<cfset thisContainerId = #thisID.container_id#>
		</cfif>

		<cfif len(#thisContainerId#) gt 0>
			<cfquery name="putItIn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update container set
				parent_container_id = #position_id#,
				PARENT_INSTALL_DATE = sysdate
				where container_id = #thisContainerId#
			</cfquery>
			<cfset result = "#box_position#|#thisID.label#">
		<cfelse>
			<cfset result = "-#box_position#|Container not found.">
		</cfif>
	<cfcatch>
		<cfset result = "-#box_position#|#cfcatch.Message#">
	</cfcatch>
	</CFTRY>
	<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->



<cffunction name="getAgentId" access="remote">
	<cfargument name="agent_name" required="yes">
	<cfif len(agent_name) is 0>
		<cfset result = querynew("agent_name,agent_id,status")>
		<cfset queryaddrow(result,1)>
		<cfset QuerySetCell(result, "agent_name", agent_name, 1)>
		<cfreturn result>
	</cfif>
	<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select agent_name, agent_id, '' status from agent_name where upper(agent_name)=trim('#ucase(agent_name)#') group by agent_name,agent_id, ''
	</cfquery>
	<cfif t.recordcount is 1>
		<cfreturn t>
	<cfelse>
		<cfset result = querynew("agent_name,agent_id,status")>
		<cfset queryaddrow(result,1)>
		<cfset QuerySetCell(result, "agent_name", agent_name, 1)>
		<cfset QuerySetCell(result, "status", 'found #t.recordcount# matches', 1)>
		<cfreturn result>
	</cfif>
</cffunction>

<!----------------------------------------------------------------------------------------------------------------->



<cffunction name="parseTaxonName" access="remote">
	<cfargument name="taxon_name" required="yes">
	<cfset taxa_one=''>
	<cfset taxa_two=''>
	<cfset taxa_formula=''>
	<cfset err=''>
	<cfset result = querynew("taxon_name,taxa_formula,taxa_one,taxon_name_id_1,taxa_two,taxon_name_id_2,status")>
	<cfset queryaddrow(result,1)>

	<cfif taxon_name contains " {" and taxon_name contains "}">
		<cfset taxa_formula = "A {string}">
		<cfset taxa_one = rereplace(taxon_name,' {.*}$','')>
	<cfelseif taxon_name contains " or ">
		<cfset temp=replace(taxon_name," or ",chr(999),"all")>
		<cfset taxa_formula = "A or B">
		<cfset taxa_one = listgetat(temp,1,chr(999))>
		<cfset taxa_two = listgetat(temp,2,chr(999))>
	<cfelseif taxon_name contains " and ">
		<cfset temp=replace(taxon_name," and ",chr(999),"all")>
		<cfset taxa_formula = "A and B">
		<cfset taxa_one = listgetat(temp,1,chr(999))>
		<cfset taxa_two = listgetat(temp,2,chr(999))>
	<cfelseif taxon_name contains " x ">
		<cfset temp=replace(taxon_name," x ",chr(999),"all")>
		<cfset taxa_formula = "A x B">
		<cfset taxa_one = listgetat(temp,1,chr(999))>
		<cfset taxa_two = listgetat(temp,2,chr(999))>
	<cfelseif taxon_name contains " / " and taxon_name contains " intergrade">
		<cfset temp=replace(taxon_name," intergrade","","all")>
		<cfset temp=replace(temp," / ",chr(999),"all")>
		<cfset taxa_formula = "A / B intergrade">
		<cfset taxa_one = listgetat(temp,1,chr(999))>
		<cfset taxa_two = listgetat(temp,2,chr(999))>
	<cfelseif right(taxon_name,4) is " sp.">
		<cfset taxa_formula = "A sp.">
		<cfset taxa_one = left(taxon_name,len(taxon_name)-4)>
	<cfelseif right(taxon_name,5) is " ssp.">
		<cfset taxa_formula = "A ssp.">
		<cfset taxa_one = left(taxon_name,len(taxon_name)-5)>
	<cfelseif right(taxon_name,5) is " aff.">
		<cfset taxa_formula = "A aff.">
		<cfset taxa_one = left(taxon_name,len(taxon_name)-5)>
	<cfelseif right(taxon_name,4) is " cf.">
		<cfset taxa_formula = "A cf.">
		<cfset taxa_one = left(taxon_name,len(taxon_name)-4)>
	<cfelseif right(taxon_name,2) is " ?">
		<cfset taxa_formula = "A ?">
		<cfset taxa_one = left(taxon_name,len(taxon_name)-2)>
	<cfelse>
		<cfset taxa_formula = "A">
		<cfset taxa_one = taxon_name>
	</cfif>

	<cfif len(taxa_two) gt 0 and
		(taxa_one contains " sp." or taxa_two contains " sp." or
		taxa_one contains " ?" or taxa_two contains " ?" )>
		<cfset err=listappend(err,'"sp." and "?" are not allowed in multi-taxon IDs',";")>
	</cfif>
	<cfset QuerySetCell(result, "taxon_name", taxon_name, 1)>
	<cfset QuerySetCell(result, "taxa_formula", taxa_formula, 1)>
	<cfset QuerySetCell(result, "taxa_one", taxa_one, 1)>
	<cfset QuerySetCell(result, "taxa_two", taxa_two, 1)>

	<cfif len(taxa_one) gt 0>
		<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	        select taxon_name_id from taxonomy where scientific_name = trim('#taxa_one#') and VALID_CATALOG_TERM_FG = 1
		</cfquery>
		<cfset QuerySetCell(result, "taxon_name_id_1", t.taxon_name_id, 1)>
		<cfif t.recordcount is not 1>
			<cfset err=listappend(err,"taxon 1 not found",";")>
		</cfif>
	</cfif>
	<cfif len(taxa_two) gt 0>
		<cfquery name="t" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	        select taxon_name_id from taxonomy where scientific_name = trim('#taxa_two#') and VALID_CATALOG_TERM_FG = 1
		</cfquery>
		<cfif t.recordcount is not 1>
			<cfset err=listappend(err,"taxon 2 not found",";")>
		</cfif>
		<cfset QuerySetCell(result, "taxon_name_id_2", t.taxon_name_id, 1)>
	</cfif>

	<cfset QuerySetCell(result, "status", err, 1)>

	<cfreturn result>
</cffunction>

<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getCatalogedItemCitation" access="remote">
	<cfargument name="collection_id" type="numeric" required="yes">
	<cfargument name="theNum" type="string" required="yes">
	<cfargument name="type" type="string" required="yes">
	<cfoutput>
	<cftry>
			<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					cataloged_item.COLLECTION_OBJECT_ID,
					collection.guid_prefix || ':' || cataloged_item.cat_num guid,
					identification.scientific_name,
					identification_taxonomy.taxon_name_id,
					identification.NATURE_OF_ID,
					identification.TAXA_FORMULA
				from
					cataloged_item,
					collection,
					coll_obj_other_id_num,
					identification,
					identification_taxonomy
				where
					cataloged_item.collection_id=collection.collection_id and
					cataloged_item.collection_object_id=identification.collection_object_id and
					identification.accepted_id_fg=1 and
					identification.identification_id=identification_taxonomy.identification_id and
					identification_taxonomy.variable='A' and
					cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id (+) AND
					cataloged_item.collection_id=#collection_id# and
					<cfif type is "cat_num">
						cat_num='#theNum#'
					<cfelse>
						display_value='#theNum#' and
						other_id_type='#type#'
					</cfif>
				group by
					cataloged_item.COLLECTION_OBJECT_ID,
					collection.guid_prefix || ':' || cataloged_item.cat_num,
					identification.scientific_name,
					identification_taxonomy.taxon_name_id,
					identification.NATURE_OF_ID,
					identification.TAXA_FORMULA
			</cfquery>
		<cfcatch>
			<cfset result = querynew("collection_object_id,guid,scientific_name")>
			<cfset temp = queryaddrow(result,1)>
			<cfset temp = QuerySetCell(result, "collection_object_id", "-1", 1)>
			<cfset temp = QuerySetCell(result, "scientific_name", "#cfcatch.Message# #cfcatch.Detail#", 1)>
		</cfcatch>
	</cftry>
	<cfreturn result>
	</cfoutput>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="setUserFormAccess" access="remote">
	<cfargument name="role" type="string" required="yes">
	<cfargument name="form" type="string" required="yes">
	<cfargument name="onoff" type="string" required="yes">

	<cfset form=replace(form,Application.webDirectory,"")>
	<cfif left(form,1) is not "/">
		<cfset form="/" & form>
	</cfif>
	<cfif onoff is "true">
		<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into cf_form_permissions (form_path,role_name) values ('#form#','#role#')
		</cfquery>
	<cfelseif onoff is "false">
		<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from cf_form_permissions where
				form_path = '#form#' and
				role_name = '#role#'
		</cfquery>
	<cfelse>
		<cfreturn "Error:invalid state">
	</cfif>
	<cfreturn "Success:#form#:#role#:#onoff#">
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getParts" access="remote">
	<cfargument name="collection_id" type="string" required="yes">
	<cfargument name="other_id_type" type="string" required="yes">
	<cfargument name="oidnum" type="string" required="yes">
	<cfargument name="noBarcode" type="string" required="yes">
	<cfargument name="noSubsample" type="string" required="yes">
	<cftry>
		<cfset t="select
				cataloged_item.collection_object_id,
				specimen_part.collection_object_id partID,
				decode(p.barcode,'0',null,p.barcode) barcode,
				decode(sampled_from_obj_id,
					null,part_name,
					part_name || ' SAMPLE') part_name,
				cat_num,
				collection,
				concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
				'#session.CustomOtherIdentifier#' as CustomIdType
			from
				specimen_part,
				cataloged_item,
				collection,
				coll_obj_cont_hist,
				container c,
				container p">
		<cfset w = "where
				specimen_part.derived_from_cat_item = cataloged_item.collection_object_id and
				cataloged_item.collection_id=collection.collection_id and
				specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
				coll_obj_cont_hist.container_id=c.container_id and
				c.parent_container_id=p.container_id (+) and
				cataloged_item.collection_id=#collection_id#">
		<cfif other_id_type is not "catalog_number">
			<cfset t=t&" ,coll_obj_other_id_num">
			<cfset w=w & " and cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id and
					coll_obj_other_id_num.other_id_type='#other_id_type#' and
					coll_obj_other_id_num.display_value='#oidnum#'">
		<cfelse>
			<cfset w=w & " and cataloged_item.cat_num=#oidnum#">
		</cfif>
		<cfif noBarcode is true>
			<cfset w=w & " and (c.parent_container_id = 0 or c.parent_container_id is null or c.parent_container_id=476089)">
				<!--- 476089 is barcode 0 - our universal trashcan --->
		</cfif>
		<cfif noSubsample is true>
			<cfset w=w & " and specimen_part.SAMPLED_FROM_OBJ_ID is null">
		</cfif>
		<cfset q = t & " " & w & " order by part_name">
		<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#preservesinglequotes(q)#
		</cfquery>
		<cfquery name="u" dbtype="query">
			select count(distinct(collection_object_id)) c from q
		</cfquery>
		<cfif q.recordcount is 0>
			<cfset q=queryNew("PART_NAME")>
			<cfset t = queryaddrow(q,1)>
			<cfset t = QuerySetCell(q, "PART_NAME", "Error: no_parts_found", 1)>
		</cfif>
		<cfif u.c is not 1>
			<cfset q=queryNew("PART_NAME")>
			<cfset t = queryaddrow(q,1)>
			<cfset t = QuerySetCell(q, "PART_NAME", "Error: #u.c# specimens match", 1)>
		</cfif>
	<cfcatch>
		<!---
		<cfset t = queryaddrow(theResult,1)>
		<cfset t = QuerySetCell(theResult, "collection_object_id", "-1", 1)>
		<cfset t = QuerySetCell(theResult, "typeList", "#cfcatch.detail#", 1)>
		<cfreturn theResult>
		--->
		<cfset q=queryNew("PART_NAME")>
		<cfset t = queryaddrow(q,1)>
		<cfset t = QuerySetCell(q, "PART_NAME", "Error: #cfcatch.Message# #cfcatch.detail#", 1)>
	</cfcatch>
	</cftry>
	<cfreturn q>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getSpecimen" access="remote">
	<cfargument name="collection_id" type="string" required="yes">
	<cfargument name="other_id_type" type="string" required="yes">
	<cfargument name="oidnum" type="string" required="yes">
	<cftry>
		<cfset t="select
				cataloged_item.collection_object_id
			from
				cataloged_item">
		<cfset w = "where cataloged_item.collection_id=#collection_id#">
		<cfif other_id_type is not "catalog_number">
			<cfset t=t&" ,coll_obj_other_id_num">
			<cfset w=w & " and cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id and
					coll_obj_other_id_num.other_id_type='#other_id_type#' and
					coll_obj_other_id_num.display_value='#oidnum#'">
		<cfelse>
			<cfset w=w & " and cataloged_item.cat_num=#oidnum#">
		</cfif>
		<cfset q = t & " " & w>
		<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#preservesinglequotes(q)#
		</cfquery>
		<cfif q.recordcount is 0>
			<cfset q=queryNew("collection_object_id")>
			<cfset t = queryaddrow(q,1)>
			<cfset t = QuerySetCell(q, "collection_object_id", "Error: item_not_found", 1)>
		<cfelseif q.recordcount gt 1>
			<cfset q=queryNew("collection_object_id")>
			<cfset t = queryaddrow(q,1)>
			<cfset t = QuerySetCell(q, "collection_object_id", "Error: multiple_matches", 1)>
		</cfif>
	<cfcatch>
		<cfset q=queryNew("collection_object_id")>
		<cfset t = queryaddrow(q,1)>
		<cfset t = QuerySetCell(q, "collection_object_id", "Error: #cfcatch.Message# #cfcatch.detail#", 1)>
	</cfcatch>
	</cftry>
	<cfreturn q>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="addPartToContainer" access="remote">
	<cfargument name="collection_object_id" type="numeric" required="yes">
	<cfargument name="part_id" type="numeric" required="yes">
	<cfargument name="part_id2" type="string" required="no">
	<cfargument name="parent_barcode" type="string" required="yes">
	<cfargument name="new_container_type" type="string" required="yes">
	<cfoutput>
	<cftry>
		<cftransaction>
			<cfquery name="isGoodParent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select container_id from container where container_type <> 'collection object'
				and barcode='#parent_barcode#'
			</cfquery>
			<cfif #isGoodParent.recordcount# is not 1>
				<cfreturn "0|Parent container (barcode #parent_barcode#) not found.">
			</cfif>
			<cfquery name="cont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select container_id FROM coll_obj_cont_hist where collection_object_id=#part_id#
			</cfquery>
			<cfif #cont.recordcount# is not 1>
				<cfreturn "0|Yikes! A part is not a container.">
			</cfif>
			<cfquery name="newparent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				UPDATE container SET container_type = '#new_container_type#' WHERE
					container_id=#isGoodParent.container_id#
			</cfquery>
			<cftransaction action="commit" />
			<cfquery name="moveIt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				UPDATE container SET parent_container_id = #isGoodParent.container_id# WHERE
				container_id=#cont.container_id#
			</cfquery>
			<cfif len(#part_id2#) gt 0>
				<cfquery name="cont2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select container_id FROM coll_obj_cont_hist where collection_object_id=#part_id2#
				</cfquery>
				<cfquery name="moveIt2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					UPDATE container SET parent_container_id = #isGoodParent.container_id# WHERE
					container_id=#cont2.container_id#
				</cfquery>
			</cfif>
		</cftransaction>
		<cfquery name="coll_obj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				cat_num,
				institution_acronym,
				collection.collection_cde,
				collection.collection,
				scientific_name,
				part_name
				<cfif len(part_id2) gt 0>
					|| (select ' and ' || part_name from specimen_part where collection_object_id=#part_id2#)
				</cfif>
				part_name
			from
				cataloged_item,
				collection,
				identification,
				specimen_part
			where
				cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
				cataloged_item.collection_object_id=identification.collection_object_id and
				accepted_id_fg=1 and
				cataloged_item.collection_id=collection.collection_id and
				specimen_part.collection_object_id=#part_id#
		</cfquery>
		<cfset r='Moved <a href="/guid/#coll_obj.institution_acronym#:#coll_obj.collection_cde#:#coll_obj.cat_num#">'>
		<cfset r="#r##coll_obj.collection# #coll_obj.cat_num#">
		<cfset r="#r#</a> (<i>#coll_obj.scientific_name#</i>) #coll_obj.part_name#">
		<cfset r="#r# to container barcode #parent_barcode# (#new_container_type#)">
		<cfreturn '1|#r#'>>
		<cfcatch>
			<cfreturn "0|#cfcatch.message# #cfcatch.detail#">
		</cfcatch>
	</cftry>
	</cfoutput>
</cffunction>
<!------------------------------------------------------------------>
<cffunction name="changefancyCOID" access="remote">
	<cfargument name="tgt" type="string" required="yes">
	<cftry>
			<cfquery name="up" datasource="cf_dbuser">
				UPDATE cf_users SET
					fancyCOID =
					<cfif #tgt# is 1>
						#tgt#
					<cfelse>
						NULL
					</cfif>
				WHERE username = '#session.username#'
			</cfquery>
			<cfif #tgt# gt 0>
				<cfset session.fancyCOID = "#tgt#">
			<cfelse>
				<cfset session.fancyCOID = "">
			</cfif>
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------>
<cffunction name="changeexclusive_collection_id" access="remote">
	<cfargument name="tgt" type="string" required="yes">
	<cfinclude template="/includes/functionLib.cfm">
	<cftry>
		<cfquery name="up" datasource="cf_dbuser">
			UPDATE cf_users SET
				exclusive_collection_id =
				<cfif #tgt# gt 0>
					#tgt#
				<cfelse>
					NULL
				</cfif>
			WHERE username = '#session.username#'
			</cfquery>
		<cfset setDbUser(tgt)>
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="changecustomOtherIdentifier" access="remote">
	<cfargument name="tgt" type="string" required="yes">
	<cftry>
			<cfquery name="up" datasource="cf_dbuser">
				UPDATE cf_users SET
					customOtherIdentifier =
					<cfif len(#tgt#) gt 0>
						'#tgt#'
					<cfelse>
						NULL
					</cfif>
				WHERE username = '#session.username#'
			</cfquery>
			<cfset session.customOtherIdentifier = "#tgt#">
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!-------------------------------------------->
<cffunction name="getSpecSrchPref" access="remote">
	<cfif isdefined("session.username") and len(#session.username#) gt 0>
		<cftry>
			<cfquery name="ins" datasource="cf_dbuser">
				select specsrchprefs from cf_users
				where username='#session.username#'
			</cfquery>
				<cfreturn ins.specsrchprefs>
			<cfcatch><!-- nada --></cfcatch>
		</cftry>
	</cfif>
	<cfreturn "cookie">
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="findAccession"  access="remote">
	<cfargument name="collection_id" type="numeric" required="yes">
	<cfargument name="accn_number" type="string" required="yes">
	<cftry>
		<cfquery name="accn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT accn.TRANSACTION_ID FROM accn,trans WHERE
			accn.TRANSACTION_ID=trans.TRANSACTION_ID AND
			accn_number = '#accn_number#'
			and collection_id = #collection_id#
		</cfquery>
		<cfif accn.recordcount is 1 and len(accn.transaction_id) gt 0>
			<cfreturn accn.transaction_id>
		<cfelse>
			<cfreturn -1>
		</cfif>
		<cfcatch>
			<cfreturn -1>
		</cfcatch>
	</cftry>
</cffunction>

<cffunction name="jsontest" access="remote">
		<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select '123' a from dual union
			select '0' a from dual union
			select '0000' a from dual
		</cfquery>

		<cfset t=SerializeJSON (123)>
		<cfdump var=#t#>
		<cfset result=serializejson(result)>
		<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getSpecResultsData" access="remote">
	<cfargument name="startrow" type="numeric" required="yes">
	<cfargument name="numRecs" type="numeric" required="yes">
	<cfargument name="orderBy" type="string" required="yes">
	<cfset stopRow = startrow + numRecs -1>
	<!--- strip Safari idiocy --->
	<cfset orderBy=replace(orderBy,"%20"," ","all")>
	<cfset orderBy=replace(orderBy,"%2C",",","all")>
	<cfset orderBy=replace(orderBy,"_day_of_ymd","YEARCOLL,MONCOLL,DAYCOLL","all")>



	<cftry>
		<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			Select * from (
				Select a.*, rownum rnum From (
					select * from #session.SpecSrchTab# order by #orderBy#
				) a where rownum <= #stoprow#
			) where rnum >= #startrow#
		</cfquery>
		<cfset collObjIdList = valuelist(result.collection_object_id)>
		<cfset session.collObjIdList=collObjIdList>
		<cfquery name="cols" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			 select column_name from user_tab_cols where
			 upper(table_name)=upper('#session.SpecSrchTab#') order by internal_column_id
		</cfquery>
		<cfset clist = result.COLUMNLIST>
		<cfset t = arrayNew(1)>
		<cfset temp = queryaddcolumn(result,"COLUMNLIST",t)>
		<cfset temp = QuerySetCell(result, "COLUMNLIST", "#valuelist(cols.column_name)#", 1)>

		<!----
		<cfoutput>
		<cfset jsonResult='{"ROWCOUNT":#result.recordcount#,"COLUMNS":[#listqualify(valuelist(cols.column_name),'"')#'>
		<cfset jsonResult=jsonResult & '],"DATA":{'>
		<cfloop list="#valuelist(cols.column_name)#" index="c">
			<cfset jsonResult=jsonResult & '
		</cfloop>
		<hr>#jsonResult#
		</cfoutput>
		<cfabort>





		{"ROWCOUNT":1,"COLUMNS":["COLLECTION_OBJECT_ID","CUSTOMID","MYCUSTOMIDTYPE","CUSTOMIDINT","COLLECTION","CAT_NUM","SCIENTIFIC_NAME","ACCESSION","SPEC_LOCALITY",
		"VERBATIM_DATE","DEC_LAT","DEC_LONG","COLLECTION_ID","INSTITUTION_ACRONYM","COLLECTION_CDE","RNUM","COLUMNLIST"],"DATA":{"COLLECTION_OBJECT_ID":[21531530],"CUSTOMID":[null],"MYCUSTOMIDTYPE":["collector number"],"CUSTOMIDINT":[null],"COLLECTION":["DMNS Birds"],"CAT_NUM":[12],"SCIENTIFIC_NAME":["Meleagris gallopavo"],"ACCESSION":[0000],"SPEC_LOCALITY":["no specific locality recorded"],"VERBATIM_DATE":["before 1-Mar-2010"],"DEC_LAT":[null],"DEC_LONG":[null],"COLLECTION_ID":[43],"INSTITUTION_ACRONYM":["DMNS"],"COLLECTION_CDE":["Bird"],"RNUM":[1],"COLUMNLIST":["COLLECTION_OBJECT_ID,CUSTOMID,MYCUSTOMIDTYPE,CUSTOMIDINT,COLLECTION,CAT_NUM,SCIENTIFIC_NAME,ACCESSION,SPEC_LOCALITY,VERBATIM_DATE,DEC_LAT,DEC_LONG,COLLECTION_ID,INSTITUTION_ACRONYM,COLLECTION_CDE"]}}


		---->
	<cfcatch>
			<cfset result = querynew("collection_object_id,message")>
			<cfset temp = queryaddrow(result,1)>
			<cfset temp = QuerySetCell(result, "collection_object_id", "-1", 1)>
			<cfset temp = QuerySetCell(result, "message", "#cfcatch.Message# #cfcatch.Detail#", 1)>
		</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="clientResultColumnList" access="remote">
	<cfargument name="ColumnList" type="string" required="yes">
	<cfargument name="in_or_out" type="string" required="yes">
	<cfif not isdefined("session.ResultColumnList")>
		<cfset session.ResultColumnList=''>
	</cfif>
	<cfset result="OK">
	<cfif in_or_out is "in">
		<cfloop list="#ColumnList#" index="i">
		<cfif not ListFindNoCase(session.resultColumnList,i,",")>
			<cfset session.resultColumnList = ListAppend(session.resultColumnList, i,",")>
		</cfif>
		</cfloop>
	<cfelse>
		<cfloop list="#ColumnList#" index="i">
		<cfif ListFindNoCase(session.resultColumnList,i,",")>
			<cfset session.resultColumnList = ListDeleteAt(session.resultColumnList, ListFindNoCase(session.resultColumnList,i,","),",")>
		</cfif>
		</cfloop>
	</cfif>
	<cfquery name ="upDb" datasource="cf_dbuser">
		update cf_users set resultcolumnlist='#session.resultColumnList#' where
		username='#session.username#'
	</cfquery>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="makePart" access="remote">
	<cfargument name="collection_object_id" type="string" required="yes">
	<cfargument name="part_name" type="string" required="yes">
	<cfargument name="lot_count" type="string" required="yes">
	<cfargument name="coll_obj_disposition" type="string" required="yes">
	<cfargument name="condition" type="string" required="yes">
	<cfargument name="coll_object_remarks" type="string" required="yes">
	<cfargument name="barcode" type="string" required="yes">
	<cfargument name="new_container_type" type="string" required="yes">
	<cftry>
		<cftransaction>
			<cfquery name="ccid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select sq_collection_object_id.nextval nv from dual
			</cfquery>
			<cfquery name="updateColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO coll_object (
					COLLECTION_OBJECT_ID,
					COLL_OBJECT_TYPE,
					ENTERED_PERSON_ID,
					COLL_OBJECT_ENTERED_DATE,
					LAST_EDITED_PERSON_ID,
					COLL_OBJ_DISPOSITION,
					LOT_COUNT,
					CONDITION,
					FLAGS )
				VALUES (
					#ccid.nv#,
					'SP',
					#session.myAgentId#,
					sysdate,
					#session.myAgentId#,
					'#COLL_OBJ_DISPOSITION#',
					#lot_count#,
					'#condition#',
					0 )
			</cfquery>
			<cfquery name="newTiss" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO specimen_part (
					  COLLECTION_OBJECT_ID,
					  PART_NAME
						,DERIVED_FROM_cat_item)
					VALUES (
						#ccid.nv#,
					  '#PART_NAME#'
						,#collection_object_id#)
			</cfquery>
			<cfif len(#coll_object_remarks#) gt 0>
				<cfquery name="newCollRem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO coll_object_remark (collection_object_id, coll_object_remarks)
					VALUES (#ccid.nv#, '#coll_object_remarks#')
				</cfquery>
			</cfif>
			<cfif len(barcode) gt 0>
				<cfquery name="np" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select container_id from coll_obj_cont_hist where collection_object_id=#ccid.nv#
				</cfquery>
				<cfquery name="pc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select container_id from container where barcode='#barcode#'
				</cfquery>
				<cfquery name="m2p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update container set parent_container_id=#pc.container_id# where container_id=#np.container_id#
				</cfquery>
				<cfif len(new_container_type) gt 0>
					<cfquery name="uct" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						update container set container_type='#new_container_type#' where
						container_id=#pc.container_id#
					</cfquery>
				</cfif>
			</cfif>
			<cfset q=queryNew("STATUS,PART_NAME,LOT_COUNT,COLL_OBJ_DISPOSITION,CONDITION,COLL_OBJECT_REMARKS,BARCODE,NEW_CONTAINER_TYPE")>
			<cfset t = queryaddrow(q,1)>
			<cfset t = QuerySetCell(q, "STATUS", "success", 1)>
			<cfset t = QuerySetCell(q, "part_name", "#part_name#", 1)>
			<cfset t = QuerySetCell(q, "lot_count", "#lot_count#", 1)>
			<cfset t = QuerySetCell(q, "coll_obj_disposition", "#coll_obj_disposition#", 1)>
			<cfset t = QuerySetCell(q, "condition", "#condition#", 1)>
			<cfset t = QuerySetCell(q, "coll_object_remarks", "#coll_object_remarks#", 1)>
			<cfset t = QuerySetCell(q, "barcode", "#barcode#", 1)>
			<cfset t = QuerySetCell(q, "new_container_type", "#new_container_type#", 1)>
		</cftransaction>
		<cfcatch>
			<cfset q=queryNew("status,msg")>
			<cfset t = queryaddrow(q,1)>
			<cfset t = QuerySetCell(q, "status", "error", 1)>
			<cfset t = QuerySetCell(q, "msg", "#cfcatch.message# #cfcatch.detail#:: #ccid.nv#", 1)>
		</cfcatch>
	</cftry>
	<cfreturn q>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getLoanPartResults" access="remote">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cfoutput>
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			cataloged_item.COLLECTION_OBJECT_ID,
			specimen_part.collection_object_id partID,
			coll_object.COLL_OBJ_DISPOSITION,
			coll_object.LOT_COUNT,
			coll_object.CONDITION,
			specimen_part.PART_NAME,
			specimen_part.SAMPLED_FROM_OBJ_ID,
			concatEncumbrances(cataloged_item.collection_object_id) as encumbrance_action,
			loan_item.transaction_id,
			nvl(p1.barcode,'NOBARCODE') barcode
		from
			#session.SpecSrchTab#,
			cataloged_item,
			coll_object,
			specimen_part,
			(select * from loan_item where transaction_id = #transaction_id#) loan_item,
			coll_obj_cont_hist,
			container p0,
			container p1
		where
			#session.SpecSrchTab#.collection_object_id = cataloged_item.collection_object_id AND
			cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
			specimen_part.collection_object_id = coll_object.collection_object_id and
			specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id (+) and
			coll_obj_cont_hist.container_id=p0.container_id (+) and
			p0.parent_container_id=p1.container_id (+) and
			specimen_part.SAMPLED_FROM_OBJ_ID is null and
			specimen_part.collection_object_id = loan_item.collection_object_id (+)
		order by
			cataloged_item.collection_object_id, specimen_part.part_name
	</cfquery>
	<cfreturn result>
	</cfoutput>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="ssvar" access="remote">
	<cfargument name="startrow" type="numeric" required="yes">
	<cfargument name="maxrows" type="numeric" required="yes">
	<cfset session.maxrows=#maxrows#>
	<cfset session.startrow=#startrow#>
	<cfset result="ok">
	<cfreturn result>
</cffunction>
<!-------------------------------------------------------------------------------------------->
<cffunction name="addPartToLoan" access="remote">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cfargument name="partID" type="numeric" required="yes">
	<cfargument name="remark" type="string" required="yes">
	<cfargument name="instructions" type="string" required="yes">
	<cfargument name="subsample" type="numeric" required="yes">
	<cfoutput>
	<cftransaction>
		<cftry>
			<cfquery name="n" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select sq_collection_object_id.nextval n from dual
			</cfquery>
			<cfquery name="meta" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select cataloged_item.collection_object_id,
				cat_num,collection,part_name
				from
				cataloged_item,
				collection,
				specimen_part
				where
				cataloged_item.collection_id=collection.collection_id and
				cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
				specimen_part.collection_object_id=#partID#
			</cfquery>
			<cfif #subsample# is 1>
			<cfquery name="parentData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				SELECT
					coll_obj_disposition,
					condition,
					part_name,
					derived_from_cat_item
				FROM
					coll_object, specimen_part
				WHERE
					coll_object.collection_object_id = specimen_part.collection_object_id AND
					coll_object.collection_object_id = #partID#
			</cfquery>
			<cfquery name="newCollObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO coll_object (
					COLLECTION_OBJECT_ID,
					COLL_OBJECT_TYPE,
					ENTERED_PERSON_ID,
					COLL_OBJECT_ENTERED_DATE,
					LAST_EDITED_PERSON_ID,
					LAST_EDIT_DATE,
					COLL_OBJ_DISPOSITION,
					LOT_COUNT,
					CONDITION)
				VALUES
					(#n.n#,
					'SS',
					#session.myAgentId#,
					sysdate,
					#session.myAgentId#,
					sysdate,
					'#parentData.coll_obj_disposition#',
					1,
					'#parentData.condition#')
			</cfquery>
			<cfquery name="newPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO specimen_part (
					COLLECTION_OBJECT_ID
					,PART_NAME
					,SAMPLED_FROM_OBJ_ID
					,DERIVED_FROM_CAT_ITEM)
				VALUES (
					#n.n#
					,'#parentData.part_name#'
					,#partID#
					,#parentData.derived_from_cat_item#)
			</cfquery>
		</cfif>
		<cfquery name="addLoanItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO loan_item (
				TRANSACTION_ID,
				COLLECTION_OBJECT_ID,
				RECONCILED_BY_PERSON_ID,
				RECONCILED_DATE
				,ITEM_DESCR
				<cfif len(#instructions#) gt 0>
					,ITEM_INSTRUCTIONS
				</cfif>
				<cfif len(#remark#) gt 0>
					,LOAN_ITEM_REMARKS
				</cfif>
				       )
			VALUES (
				#TRANSACTION_ID#,
				<cfif #subsample# is 1>
					#n.n#,
				<cfelse>
					#partID#,
				</cfif>
				#session.myagentid#,
				sysdate
				,'#meta.collection# #meta.cat_num# #meta.part_name#'
				<cfif len(#instructions#) gt 0>
					,'#instructions#'
				</cfif>
				<cfif len(#remark#) gt 0>
					,'#remark#'
				</cfif>
				)
		</cfquery>
		<cfquery name="setDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			UPDATE coll_object SET coll_obj_disposition = 'on loan'
			where collection_object_id =
		<cfif #subsample# is 1>
				#n.n#
			<cfelse>
				#partID#
			</cfif>
		</cfquery>
	<cfcatch>
		<cfset result = "0|#cfcatch.message# #cfcatch.detail#">
		<cfreturn result>
	</cfcatch>
	</cftry>
	<cfreturn "1|#partID#">
	</cftransaction>
	</cfoutput>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getMedia" access="remote">
	<cfargument name="idList" type="string" required="yes">
	<cfset theResult=queryNew("media_id,collection_object_id,media_relationship")>
	<cfset r=1>
	<cfset tableList="cataloged_item,collecting_event">
	<cftry>
	<cfloop list="#idList#" index="cid">
		<cfloop list="#tableList#" index="tabl">
			<cfquery name="mid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select getMediaBySpecimen('#tabl#',#cid#) midList from dual
			</cfquery>
			<cfif len(mid.midList) gt 0>
				<cfset t = queryaddrow(theResult,1)>
				<cfset t = QuerySetCell(theResult, "collection_object_id", "#cid#", r)>
				<cfset t = QuerySetCell(theResult, "media_id", "#mid.midList#", r)>
				<cfset t = QuerySetCell(theResult, "media_relationship", "#tabl#", r)>
				<cfset r=r+1>
			</cfif>
		</cfloop>
	</cfloop>
	<cfcatch>
				<cfset craps=queryNew("media_id,collection_object_id,media_relationship")>
				<cfset temp = queryaddrow(craps,1)>
				<cfset t = QuerySetCell(craps, "collection_object_id", "12", 1)>
				<cfset t = QuerySetCell(craps, "media_id", "45", 1)>
				<cfset t = QuerySetCell(craps, "media_relationship", "#cfcatch.message# #cfcatch.detail#", 1)>
				<cfreturn craps>
		</cfcatch>
	</cftry>
	<cfreturn theResult>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getTypes" access="remote">
	<cfargument name="idList" type="string" required="yes">
	<cfset theResult=queryNew("collection_object_id,typeList")>
	<cfset r=1>
	<cftry>
	<cfloop list="#idList#" index="cid">
		<cfquery name="ts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select  type_status || decode(count(*),1,'','(' || count(*) || ')') type_status from citation where collection_object_id=#cid# group by type_status
		</cfquery>
		<cfif ts.recordcount gt 0>
			<cfset tl="">
			<cfloop query="ts">
				<cfset tl=listappend(tl,ts.type_status,";")>
			</cfloop>
			<cfset t = queryaddrow(theResult,1)>
			<cfset t = QuerySetCell(theResult, "collection_object_id", "#cid#", r)>
			<cfset t = QuerySetCell(theResult, "typeList", "#tl#", r)>
			<cfset r=r+1>
		</cfif>
	</cfloop>
	<cfcatch>
		<cfset t = queryaddrow(theResult,1)>
		<cfset t = QuerySetCell(theResult, "collection_object_id", "-1", 1)>
		<cfset t = QuerySetCell(theResult, "typeList", "#cfcatch.detail#", 1)>
	</cfcatch>
	</cftry>
	<cfreturn theResult>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="saveSearch" access="remote">
	<cfargument name="returnURL" type="string" required="yes">
	<cfargument name="srchName" type="string" required="yes">
	<cfset srchName=urldecode(srchName)>
	<cftry>
		<cfquery name="me" datasource="cf_dbuser">
			select user_id
			from cf_users
			where username='#session.username#'
		</cfquery>
		<cfset urlRoot=left(returnURL,find(".cfm", returnURL))>
		<cfquery name="alreadyGotOne" datasource="cf_dbuser">
			select search_name
			from cf_canned_search
			where search_name='#srchName#'
				and user_id='#me.user_id#'
				and url like '#urlRoot#%'
		</cfquery>
		<cfif len(alreadyGotOne.search_name) gt 0>
			<cfset msg="The name of your saved search is already in use.">
		<cfelse>
			<cfquery name="i" datasource="cf_dbuser">
				insert into cf_canned_search (
				user_id,
				search_name,
				url
				) values (
				 #me.user_id#,
				 '#srchName#',
				 '#returnURL#')
			</cfquery>
			<cfset msg="success">
		</cfif>
	<cfcatch>
		<cfset msg="An error occured while saving your search: #cfcatch.message# #cfcatch.detail#">
	</cfcatch>
	</cftry>
	<cfreturn msg>
</cffunction>
<!------------------------------------->
<cffunction name="changeresultSort" access="remote">
	<cfargument name="tgt" type="string" required="yes">
	<cftry>
			<cfquery name="up" datasource="cf_dbuser">
				UPDATE cf_users SET
					result_sort = '#tgt#'
				WHERE username = '#session.username#'
			</cfquery>
			<cfset session.result_sort = "#tgt#">
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="changekillRows" access="remote">
	<cfargument name="tgt" type="string" required="yes">
	<cftry>
			<cfif tgt is not 1>
				<cfset tgt=0>
			</cfif>
			<cfquery name="up" datasource="cf_dbuser">
				UPDATE cf_users SET
					KILLROW = #tgt#
				WHERE username = '#session.username#'
			</cfquery>
			<cfset session.KILLROW = "#tgt#">
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------->
<cffunction name="changeBlockSuggest" access="remote">
	<cfargument name="onoff" type="string" required="yes">
	<cftry>
			<cfquery name="up" datasource="cf_dbuser">
				UPDATE cf_users SET
					block_suggest = #onoff#
				WHERE username = '#session.username#'
			</cfquery>
			<cfset session.block_suggest = onoff>
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------->
<cffunction name="changedisplayRows" access="remote">
	<cfargument name="tgt" type="string" required="yes">
	<cftry>
			<cfquery name="up" datasource="cf_dbuser">
				UPDATE cf_users SET
					displayrows = #tgt#
				WHERE username = '#session.username#'
			</cfquery>
			<cfset session.displayrows = "#tgt#">
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------->
<cffunction name="setSrchVal" access="remote">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="tgt" type="numeric" required="yes">
	<cftry>
			<cfquery name="up" datasource="cf_dbuser">
				UPDATE cf_users SET
					#name# =
					#tgt#
				WHERE username = '#session.username#'
			</cfquery>
			<cfif #tgt# is 1>
				<cfset session.searchBy="#session.searchBy#,#name#">
			<cfelse>
				<cfset i = listfindnocase(session.searchBy,name,",")>
				<cfif i gt 0>
					<cfset session.searchBy=listdeleteat(session.searchBy,i)>
				</cfif>
			</cfif>
		<cfset result="success">
	<cfcatch>
		<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------->
<cffunction name="changeAttDetr" access="remote">
	<cfargument name="attribute_id" type="numeric" required="yes">
	<cfargument name="i" type="numeric" required="yes">
	<cfargument name="attribute_determiner" type="string" required="yes">
	  	<cfquery name="names" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select agent_name,agent_id
			from preferred_agent_name
			where upper(agent_name) like '%#ucase(attribute_determiner)#%'
		</cfquery>
		<cfif #names.recordcount# is 0>
			<cfset result = "Nothing matched.">
		<cfelseif #names.recordcount# is 1>
			<cftry>
				<cfquery name="upatt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update attributes set DETERMINED_BY_AGENT_ID = #names.agent_id#
					where attribute_id = #attribute_id#
				</cfquery>
				<cfset result = '#i#::#names.agent_name#'>
			<cfcatch>
				<cfset result = 'A database error occured!'>
			</cfcatch>
			</cftry>
		<cfelse>
			<cfset result = "#i#::">
			<cfloop query="names">
				<cfset result = "#result#|#agent_name#">
			</cfloop>
		</cfif>
	  <cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
		<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------->
<!----------------------------------------------------------------------------------------->
<cffunction name="changeAttDetrId" access="remote">
	<cfargument name="attribute_id" type="numeric" required="yes">
	<cfargument name="i" type="numeric" required="yes">
	<cfargument name="agent_id" type="numeric" required="yes">
	<cfquery name="names" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select agent_name,agent_id
		from preferred_agent_name
		where agent_id = #agent_id#
	</cfquery>
	<cfif #names.recordcount# is 0>
		<cfset result = "Nothing matched.">
	<cfelseif #names.recordcount# is 1>
		<cftry>
			<cfquery name="upatt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update attributes set DETERMINED_BY_AGENT_ID = #names.agent_id#
				where attribute_id = #attribute_id#
			</cfquery>
			<cfset result = '#i#::#names.agent_name#'>
		<cfcatch>
			<cfset result = 'A database error occured!'>
		</cfcatch>
		</cftry>
	<cfelse>
		<cfset result = "#i#::">
		<cfloop query="names">
			<cfset result = "#result#|#agent_name#">
		</cfloop>
	</cfif>
	<cfset result = ReReplace(result,"[#CHR(10)##CHR(13)#]","","ALL")>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------->
<cffunction name="addAnnotation" access="remote">
	<cfargument name="idType" type="string" required="yes">
	<cfargument name="idvalue" type="numeric" required="yes">
	<cfargument name="annotation" type="string" required="yes">
	<cfinclude template="/includes/functionLib.cfm">
	<cftry>
		<cfquery name="insAnn" datasource="uam_god">
			insert into annotations (
				cf_username,
				#idType#,
				annotation
			) values (
				'#session.username#',
				#idvalue#,
				'#stripQuotes(urldecode(annotation))#'
			)
		</cfquery>
		<cfquery name="whoTo" datasource="uam_god">
			select
				address
			FROM
				cataloged_item,
				collection,
				collection_contacts,
				electronic_address
			WHERE
				cataloged_item.collection_id = collection.collection_id AND
				collection.collection_id = collection_contacts.collection_id AND
				collection_contacts.contact_agent_id = electronic_address.agent_id AND
				collection_contacts.CONTACT_ROLE = 'data quality' and
				electronic_address.ADDRESS_TYPE='e-mail' and
				<cfif idType is "collection_object_id">
					cataloged_item.collection_object_id=#idvalue#
				<cfelse>
					1=0
				</cfif>
		</cfquery>
		<cfquery name="summary" datasource="uam_god">
			<cfif idType is "COLLECTION_OBJECT_ID">
				select '<a href="#Application.serverRootUrl#/guid/' || guid || '">' || guid || '</a>' s from flat where collection_object_id=#idvalue#
			<cfelseif idType is "TAXON_NAME_ID">
				select '<a href="#Application.serverRootUrl#/name/' || scientific_name || '">' || display_name || '</a>' s from taxonomy where taxon_name_id=#idvalue#
			<cfelseif idType is "PROJECT_ID">
				select '<a href="#Application.serverRootUrl#/project/' || niceURL(project_name) || '">' || project_name || '</a>' s from project where project_id=#idvalue#
			<cfelseif idType is "PUBLICATION_ID">
				select '<a href="#Application.serverRootUrl#/publication/' || publication_id || '">' || short_citation || '</a>' s from publication where publication_id=#idvalue#
			</cfif>
		</cfquery>
		<cfset mailTo = valuelist(whoTo.address)>
		<cfset mailTo=listappend(mailTo,Application.bugReportEmail,",")>
		<cfmail to="#mailTo#" from="annotation@#Application.fromEmail#" subject="Annotation Submitted" type="html">
			Arctos User #session.username# has submitted an annotation concerning #summary.s#.

			<blockquote>
				#annotation#
			</blockquote>

			View details at
			<a href="#Application.ServerRootUrl#/info/reviewAnnotation.cfm?action=show&type=#idType#&id=#idvalue#">
				#Application.ServerRootUrl#/info/annotate.cfm?action=show&type=#idType#&id=#idvalue#
			</a>
		</cfmail>
	<cfcatch>
		<cfset result = "A database error occured: #cfcatch.message# #cfcatch.detail#">
		<cfreturn result>
	</cfcatch>
	</cftry>
	<cfset result = "success">
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="changeshowObservations" access="remote">
	<cfargument name="tgt" type="string" required="yes">
	<cfif tgt is "true">
		<cfset t = 1>
	<cfelse>
		<cfset t = 0>
	</cfif>
	<cftry>
		<cfquery name="up" datasource="cf_dbuser">
			UPDATE cf_users SET
				showObservations = #t#
			WHERE username = '#session.username#'
		</cfquery>
		<cfset session.showObservations = "#t#">
		<cfset result="success">
		<cfcatch>
			<cfset result = "#cfcatch.Message# #cfcatch.Detail#">
		</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="saveSpecSrchPref" access="remote">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="onOff" type="numeric" required="yes">
	<cfif isdefined("session.username") and len(#session.username#) gt 0>
		<cftry>
			<cfquery name="ins" datasource="cf_dbuser">
				select specsrchprefs from cf_users
				where username='#session.username#'
			</cfquery>
			<cfset cv=valuelist(ins.specsrchprefs)>
			<cfif onOff is 1>
				<cfif not listfind(cv,id)>
					<cfset nv=listappend(cv,id)>
				</cfif>
			<cfelse>
				<cfif listfind(cv,id)>
					<cfset nv=listdeleteat(cv,listfind(cv,id))>
				</cfif>
			</cfif>
			<cfquery name="ins" datasource="cf_dbuser">
				update cf_users set specsrchprefs='#nv#'
				where username='#session.username#'
			</cfquery>
			<cfcatch><!-- nada --></cfcatch>
		</cftry>
		<cfreturn "saved">
	</cfif>
	<cfreturn "cookie,#id#,#onOff#">
</cffunction>
<!-------------------------------------------->
</cfcomponent>