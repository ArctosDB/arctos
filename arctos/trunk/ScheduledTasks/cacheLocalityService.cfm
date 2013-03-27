<cfoutput>
<cfquery name="d" datasource="prod">
		select
			locality.LOCALITY_ID,
			higher_geog,
			SPEC_LOCALITY,
			DEC_LAT,
			DEC_LONG
		from
		locality,geog_auth_rec where
		locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
		 S$LASTDATE is null and rownum<2
	</cfquery>
	<cfset obj = CreateObject("component","component.functions")>

	<cfloop query="d">
						action="run"
						name="EsDollar#d.locality_id#"
						locality_id="#d.locality_id#"
						dec_lat="#d.dec_lat#"
						dec_long="#d.dec_long#"
						spec_locality="#d.spec_locality#"
						higher_geog="#d.higher_geog#">

						<cfset intStartTime = GetTickCount() />

						<!--- for some strange reason, this must be mapped like zo.... ----->
						<cfset obj = CreateObject("component","component.functions")>




							<cfset geoList="">
							<cfset slat="">
							<cfset slon="">
							<cfset elevRslt=''>
							<cfif len(DEC_LAT) gt 0 and len(DEC_LONG) gt 0>
								<!--- geography data from curatorial coordinates ---->
								<cfset signedURL = obj.googleSignURL(
									urlPath="/maps/api/geocode/json",
									urlParams="latlng=#URLEncodedFormat('#DEC_LAT#,#DEC_LONG#')#")>

								<br>going to get
								<br>
										#signedURL#
								<br>
								<cfsavecontent variable="x">
									<cfexecute name = "/usr/bin/curl" arguments = "#signedURL#" timeout="20"></cfexecute>
								</cfsavecontent>

<hr>

back from call with this:

<hr>

<cfdump var=#x#>

<hr>
									<cfset llresult=DeserializeJSON(x)>
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

								<cfset signedURL = obj.googleSignURL(
									urlPath="/maps/api/elevation/json",
									urlParams="locations=#URLEncodedFormat('#DEC_LAT#,#DEC_LONG#')#")>
									<cfsavecontent variable="X">
										<cfexecute name = "/usr/bin/curl" arguments = "#signedURL#"></cfexecute>
									</cfsavecontent>

									<cfset elevResult=DeserializeJSON(x.fileContent)>
									<cfif isdefined("elevResult.status") and elevResult.status is "OK">
										<cfset elevRslt=round(elevResult.results[1].elevation)>
									</cfif>


							</cfif>
							<cfif len(spec_locality) gt 0 and len(higher_geog) gt 0>
								<cfset signedURL = obj.googleSignURL(
									urlPath="/maps/api/geocode/json",
									urlParams="address=#URLEncodedFormat('#spec_locality#, #higher_geog#')#")>
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
									<cfelseif llresult.status is "ZERO_RESULTS">
										<!--- try without specloc, which is user-supplied and often wonky ---->
										<cfset signedURL = obj.googleSignURL(
											urlPath="/maps/api/geocode/json",
											urlParams="address=#URLEncodedFormat('#higher_geog#')#")>
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

							<!---- update cache ---->
							<cfquery name="upEsDollar" datasource="uam_god">
								update locality set
									S$ELEVATION=<cfif len(elevRslt) is 0>NULL<cfelse>#elevRslt#</cfif>,
									S$GEOGRAPHY='#replace(geoList,"'","''","all")#',
									S$DEC_LAT=<cfif len(slat) is 0>NULL<cfelse>#slat#</cfif>,
									S$DEC_LONG=<cfif len(slon) is 0>NULL<cfelse>#slon#</cfif>,
									S$LASTDATE=sysdate
								where locality_id=#locality_id#
							</cfquery>

<!----
						<cfmail subject="threadreport" to="dustymc@gmail.com" from="threadreport@#Application.fromEmail#" type="html">

</cfmail>
						----->
		<hr>

							finished a thread in  #NumberFormat(((GetTickCount() - intStartTime) / 1000),",.00")#
							<hr>
							update locality set
									S$ELEVATION=<cfif len(elevRslt) is 0>NULL<cfelse>#elevRslt#</cfif>,
									S$GEOGRAPHY='#replace(geoList,"'","''","all")#',
									S$DEC_LAT=<cfif len(slat) is 0>NULL<cfelse>#slat#</cfif>,
									S$DEC_LONG=<cfif len(slon) is 0>NULL<cfelse>#slon#</cfif>,
									S$LASTDATE=sysdate
								where locality_id=#locality_id#


	</cfloop>
</cfoutput>