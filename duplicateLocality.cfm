<cfinclude template="includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<style>
	.readClr {background-color:gray;}
</style>
<cfset title="Duplicate Locality Merger Widget">
<cfoutput>
	<cfif action is "detectdups">
		<cfquery name="orig" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
            select
                LOCALITY_ID,
                GEOG_AUTH_REC_ID,
                SPEC_LOCALITY,
                DEC_LAT,
                DEC_LONG,
                MINIMUM_ELEVATION,
                MAXIMUM_ELEVATION,
                ORIG_ELEV_UNITS,
                MIN_DEPTH,
                MAX_DEPTH,
                DEPTH_UNITS,
                MAX_ERROR_DISTANCE,
                MAX_ERROR_UNITS,
                DATUM,
                LOCALITY_REMARKS,
                GEOREFERENCE_SOURCE,
                GEOREFERENCE_PROTOCOL,
                LOCALITY_NAME,
                concatGeologyAttributeDetail(locality_id) geologyConcat
            from
                locality
            where locality_id in (#locality_id#)
        </cfquery>
		<cfquery name="dist" dbtype="query">
		  select
		    GEOG_AUTH_REC_ID,
                SPEC_LOCALITY,
                DEC_LAT,
                DEC_LONG,
                MINIMUM_ELEVATION,
                MAXIMUM_ELEVATION,
                ORIG_ELEV_UNITS,
                MIN_DEPTH,
                MAX_DEPTH,
                DEPTH_UNITS,
                MAX_ERROR_DISTANCE,
                MAX_ERROR_UNITS,
                DATUM,
                LOCALITY_REMARKS,
                GEOREFERENCE_SOURCE,
                GEOREFERENCE_PROTOCOL,
                LOCALITY_NAME,
                geologyConcat,
				count(*) c from orig group by
				 GEOG_AUTH_REC_ID,
                SPEC_LOCALITY,
                DEC_LAT,
                DEC_LONG,
                MINIMUM_ELEVATION,
                MAXIMUM_ELEVATION,
                ORIG_ELEV_UNITS,
                MIN_DEPTH,
                MAX_DEPTH,
                DEPTH_UNITS,
                MAX_ERROR_DISTANCE,
                MAX_ERROR_UNITS,
                DATUM,
                LOCALITY_REMARKS,
                GEOREFERENCE_SOURCE,
                GEOREFERENCE_PROTOCOL,
                LOCALITY_NAME,
                geologyConcat order by
				c DESC,
				 GEOG_AUTH_REC_ID,
                SPEC_LOCALITY,
                DEC_LAT,
                DEC_LONG,
                MINIMUM_ELEVATION,
                MAXIMUM_ELEVATION,
                ORIG_ELEV_UNITS,
                MIN_DEPTH,
                MAX_DEPTH,
                DEPTH_UNITS,
                MAX_ERROR_DISTANCE,
                MAX_ERROR_UNITS,
                DATUM,
                LOCALITY_REMARKS,
                GEOREFERENCE_SOURCE,
                GEOREFERENCE_PROTOCOL,
                LOCALITY_NAME,
                geologyConcat
		</cfquery>
		<p>
			Found #orig.recordcount# localities, #dist.recordcount# unique
		</p>
		<table border id="t" class="sortable">
			<tr>
				<th>
					merge
				</th>
				<th>
					count
				</th>
				<th>
					GEOG_AUTH_REC_ID
				</th>
				<th>
					SPEC_LOCALITY
				</th>
				<th>
					DEC_LAT
				</th>
				<th>
					DEC_LONG
				</th>
				<th>
					MINIMUM_ELEVATION
				</th>
				<th>
					MAXIMUM_ELEVATION
				</th>
				<th>
					ORIG_ELEV_UNITS
				</th>
				<th>
					MIN_DEPTH
				</th>
				<th>
					MAX_DEPTH
				</th>
				<th>
					DEPTH_UNITS
				</th>
				<th>
					MAX_ERROR_DISTANCE
				</th>
				<th>
					MAX_ERROR_UNITS
				</th>
				<th>
					DATUM
				</th>
				<th>
					LOCALITY_REMARKS
				</th>
				<th>
					GEOREFERENCE_SOURCE
				</th>
				<th>
					GEOREFERENCE_PROTOCOL
				</th>
				<th>
					LOCALITY_NAME
				</th>
				<th>
					geologyConcat
				</th>
			</tr>
			<cfloop query="dist">
				<cfquery name="thisLocIDs" dbtype="query">
                          select locality_id from orig where
                           GEOG_AUTH_REC_ID=#GEOG_AUTH_REC_ID# and
                           <cfif len(SPEC_LOCALITY) gt 0>
                             SPEC_LOCALITY='#SPEC_LOCALITY#'
                            <cfelse>
                                SPEC_LOCALITY is null
                            </cfif>
                            and
                           <cfif len(DEC_LAT) gt 0>
                             DEC_LAT=#DEC_LAT#
                            <cfelse>
                                DEC_LAT is null
                            </cfif>
                            and
                           <cfif len(DEC_LONG) gt 0>
                             DEC_LONG=#DEC_LONG#
                            <cfelse>
                                DEC_LONG is null
                            </cfif>
                            and
                           <cfif len(MINIMUM_ELEVATION) gt 0>
                             MINIMUM_ELEVATION=#MINIMUM_ELEVATION#
                            <cfelse>
                                MINIMUM_ELEVATION is null
                            </cfif>
                            and
                           <cfif len(MAXIMUM_ELEVATION) gt 0>
                             MAXIMUM_ELEVATION=#MAXIMUM_ELEVATION#
                            <cfelse>
                                MAXIMUM_ELEVATION is null
                            </cfif>
                            and
                            <cfif len(ORIG_ELEV_UNITS) gt 0>
                             ORIG_ELEV_UNITS='#ORIG_ELEV_UNITS#'
                            <cfelse>
                                ORIG_ELEV_UNITS is null
                            </cfif>
                            and
                           <cfif len(MIN_DEPTH) gt 0>
                             MIN_DEPTH=#MIN_DEPTH#
                            <cfelse>
                                MIN_DEPTH is null
                            </cfif>
                            and
                           <cfif len(MAX_DEPTH) gt 0>
                             MAX_DEPTH=#MAX_DEPTH#
                            <cfelse>
                                MAX_DEPTH is null
                            </cfif>
                            and
                            <cfif len(DEPTH_UNITS) gt 0>
                             DEPTH_UNITS='#DEPTH_UNITS#'
                            <cfelse>
                                DEPTH_UNITS is null
                            </cfif>
                            and
                           <cfif len(MAX_ERROR_DISTANCE) gt 0>
                             MAX_ERROR_DISTANCE=#MAX_ERROR_DISTANCE#
                            <cfelse>
                                MAX_ERROR_DISTANCE is null
                            </cfif>
                            and
                            <cfif len(MAX_ERROR_UNITS) gt 0>
                             MAX_ERROR_UNITS='#MAX_ERROR_UNITS#'
                            <cfelse>
                                MAX_ERROR_UNITS is null
                            </cfif>
                            and
                            <cfif len(DATUM) gt 0>
                             DATUM='#DATUM#'
                            <cfelse>
                                DATUM is null
                            </cfif>
                            and
                            <cfif len(LOCALITY_REMARKS) gt 0>
                             LOCALITY_REMARKS='#escapeQuotes(LOCALITY_REMARKS)#'
                            <cfelse>
                                LOCALITY_REMARKS is null
                            </cfif>
                            and
                            <cfif len(GEOREFERENCE_SOURCE) gt 0>
                             GEOREFERENCE_SOURCE='#GEOREFERENCE_SOURCE#'
                            <cfelse>
                                GEOREFERENCE_SOURCE is null
                            </cfif>
                            and
                            <cfif len(GEOREFERENCE_PROTOCOL) gt 0>
                             GEOREFERENCE_PROTOCOL='#GEOREFERENCE_PROTOCOL#'
                            <cfelse>
                                GEOREFERENCE_PROTOCOL is null
                            </cfif>
                            and
                            <cfif len(LOCALITY_NAME) gt 0>
                             LOCALITY_NAME='#LOCALITY_NAME#'
                            <cfelse>
                                LOCALITY_NAME is null
                            </cfif>
                            and
                            <cfif len(geologyConcat) gt 0>
                             geologyConcat='#geologyConcat#'
                            <cfelse>
                                geologyConcat is null
                            </cfif>
                        </cfquery>
						<cfquery name="goodLocID" dbtype="query">
                          select min(locality_id) as locality_id from thisLocIDs
                        </cfquery>



				<tr>
					<td>
						<cfif c gt 1>
							<cfif goodLocID.recordcount gt 0>
								<cfquery name="badLocID" dbtype="query">
		                          select locality_id from thisLocIDs where locality_id != #goodLocID.locality_id#
		                        </cfquery>
								<a href="duplicateLocality.cfm?action=delete&returnlocalityid=#locality_id#&returnAction=detectdups&locality_id=#goodLocID.locality_id#&deleteLocalityID=#valuelist(badLocID.locality_id)#">
									[&nbsp;merge&nbsp;all&nbsp;]
								</a>
							</cfif>
						<cfelse>
							<a href="duplicateLocality.cfm?locality_id=#goodLocID.locality_id#">
								[&nbsp;fuzzy&nbsp;filter&nbsp;]
							</a>
						</cfif>
						<br>
						<a href="/Locality.cfm?action=findLocality&locality_id=#valuelist(thisLocIDs.locality_id)#">
							[&nbsp;view&nbsp;all&nbsp;]
						</a>
					</td>
					<td>
						#c#
					</td>
					<td>
						#GEOG_AUTH_REC_ID#
					</td>
					<td>
						#SPEC_LOCALITY#
					</td>
					<td>
						#DEC_LAT#
					</td>
					<td>
						#DEC_LONG#
					</td>
					<td>
						#MINIMUM_ELEVATION#
					</td>
					<td>
						#MAXIMUM_ELEVATION#
					</td>
					<td>
						#ORIG_ELEV_UNITS#
					</td>
					<td>
						#MIN_DEPTH#
					</td>
					<td>
						#MAX_DEPTH#
					</td>
					<td>
						#DEPTH_UNITS#
					</td>
					<td>
						#MAX_ERROR_DISTANCE#
					</td>
					<td>
						#MAX_ERROR_UNITS#
					</td>
					<td>
						#DATUM#
					</td>
					<td>
						#LOCALITY_REMARKS#
					</td>
					<td>
						#GEOREFERENCE_SOURCE#
					</td>
					<td>
						#GEOREFERENCE_PROTOCOL#
					</td>
					<td>
						#LOCALITY_NAME#
					</td>
					<td>
						#geologyConcat#
					</td>
				</tr>
			</cfloop>
		</table>
	</cfif>
	<cfif action is "nothing">
		<cfif not isdefined("q_spec_locality")>
			<cfset q_spec_locality='exact'>
		</cfif>
		<cfquery name="orig" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					LOCALITY_ID,
					GEOG_AUTH_REC_ID,
					SPEC_LOCALITY,
					DEC_LAT,
					DEC_LONG,
					MINIMUM_ELEVATION,
					MAXIMUM_ELEVATION,
					ORIG_ELEV_UNITS,
					MIN_DEPTH,
					MAX_DEPTH,
					DEPTH_UNITS,
					MAX_ERROR_DISTANCE,
					MAX_ERROR_UNITS,
					DATUM,
					LOCALITY_REMARKS,
					GEOREFERENCE_SOURCE,
					GEOREFERENCE_PROTOCOL,
					LOCALITY_NAME,
					concatGeologyAttributeDetail(locality_id) geologyConcat
				from
					locality
				where locality_id=#locality_id#
			</cfquery>
		<cfif not isdefined("GEOG_AUTH_REC_ID")>
			<cfset GEOG_AUTH_REC_ID=orig.GEOG_AUTH_REC_ID>
		</cfif>
		<cfif not isdefined("SPEC_LOCALITY")>
			<cfset SPEC_LOCALITY=orig.SPEC_LOCALITY>
		</cfif>
		<cfif not isdefined("DEC_LAT")>
			<cfset DEC_LAT=orig.DEC_LAT>
		</cfif>
		<cfif not isdefined("DEC_LONG")>
			<cfset DEC_LONG=orig.DEC_LONG>
		</cfif>
		<cfif not isdefined("MINIMUM_ELEVATION")>
			<cfset MINIMUM_ELEVATION=orig.MINIMUM_ELEVATION>
		</cfif>
		<cfif not isdefined("MAXIMUM_ELEVATION")>
			<cfset MAXIMUM_ELEVATION=orig.MAXIMUM_ELEVATION>
		</cfif>
		<cfif not isdefined("ORIG_ELEV_UNITS")>
			<cfset ORIG_ELEV_UNITS=orig.ORIG_ELEV_UNITS>
		</cfif>
		<cfif not isdefined("MIN_DEPTH")>
			<cfset MIN_DEPTH=orig.MIN_DEPTH>
		</cfif>
		<cfif not isdefined("MAX_DEPTH")>
			<cfset MAX_DEPTH=orig.MAX_DEPTH>
		</cfif>
		<cfif not isdefined("DEPTH_UNITS")>
			<cfset DEPTH_UNITS=orig.DEPTH_UNITS>
		</cfif>
		<cfif not isdefined("MAX_ERROR_DISTANCE")>
			<cfset MAX_ERROR_DISTANCE=orig.MAX_ERROR_DISTANCE>
		</cfif>
		<cfif not isdefined("MAX_ERROR_UNITS")>
			<cfset MAX_ERROR_UNITS=orig.MAX_ERROR_UNITS>
		</cfif>
		<cfif not isdefined("DATUM")>
			<cfset DATUM=orig.DATUM>
		</cfif>
		<cfif not isdefined("LOCALITY_REMARKS")>
			<cfset LOCALITY_REMARKS=orig.LOCALITY_REMARKS>
		</cfif>
		<cfif not isdefined("GEOREFERENCE_SOURCE")>
			<cfset GEOREFERENCE_SOURCE=orig.GEOREFERENCE_SOURCE>
		</cfif>
		<cfif not isdefined("GEOREFERENCE_PROTOCOL")>
			<cfset GEOREFERENCE_PROTOCOL=orig.GEOREFERENCE_PROTOCOL>
		</cfif>
		<cfif not isdefined("LOCALITY_NAME")>
			<cfset LOCALITY_NAME=orig.LOCALITY_NAME>
		</cfif>
		<cfif not isdefined("geologyConcat")>
			<cfset geologyConcat=orig.geologyConcat>
		</cfif>
		Filter for duplicates (or almost-duplicates). Default values in gray cells are from the referring locality. Default match is exact, except some fields are case-insensitive (see below). Manipulate text below to adjust fuzziness.
		<ul>
			<li>
				Empty cells match NULL.
			</li>
			<li>
				Enter "ignore" (without the quotes) to IGNORE the term. That is, spec_locality=ignore will match ALL other spec localities; the filter will be only on the remaining terms, and spec_locality will not be considered at all.
			</li>
			<li>
				Some criteria (marked below) are case-insensitive. Contact a DBA if that's a problem.
			</li>
			<li>
				Some criteria (marked "operators OK") will accept wildcard operators. Use with caution.
				<ul>
					<li>
						_ (underbar, match any single character)
					</li>
					<li>
						% (percent, match any substring)
					</li>
				</ul>
			</li>
		</ul>
		For example, if you came in for specific locality "Bonanza Creek" and you want to also find localities of "Bonanza Ck.", change specific locality to "Bonanza C%k%". However, be aware that this will also return "Bonanza Creek, other things out here"; be very careful with the "check all" button below.
		<br>
		To include "Some prefix, Bonanza Creek, Something" try "%Bonanza C%k%".
		<br>
		<p>
			Original values (from locality #locality_id#) are in grayed-out textboxes
		</p>
		<form method="post" action="duplicateLocality.cfm">
			<input type="hidden" name="locality_id" value='#locality_id#'>
			<label for="GEOG_AUTH_REC_ID">
				GEOG_AUTH_REC_ID
			</label>
			<input type="text" name="GEOG_AUTH_REC_ID" size="120" value="#GEOG_AUTH_REC_ID#">
			<br>
			<input readonly="readonly" class="readClr" type="text" size="120" value="#orig.GEOG_AUTH_REC_ID#">
			<label for="SPEC_LOCALITY">
				SPEC_LOCALITY (case insensitive, operators OK)
			</label>
			<input type="text" name="SPEC_LOCALITY" size="120" value="#SPEC_LOCALITY#">
			<br>
			<input readonly="readonly" class="readClr" type="text" size="120" value="#orig.SPEC_LOCALITY#">
			<label for="DEC_LAT">
				DEC_LAT
			</label>
			<input type="text" name="DEC_LAT" size="120" value="#DEC_LAT#">
			<br>
			<input readonly="readonly" class="readClr" type="text" size="120" value="#orig.DEC_LAT#">
			<label for="DEC_LONG">
				DEC_LONG
			</label>
			<input type="text" name="DEC_LONG" size="120" value="#DEC_LONG#">
			<br>
			<input readonly="readonly" class="readClr" type="text" size="120" value="#orig.DEC_LONG#">
			<label for="MINIMUM_ELEVATION">
				MINIMUM_ELEVATION
			</label>
			<input type="text" name="MINIMUM_ELEVATION" size="120" value="#MINIMUM_ELEVATION#">
			<br>
			<input readonly="readonly" class="readClr" type="text" size="120" value="#orig.MINIMUM_ELEVATION#">
			<label for="MAXIMUM_ELEVATION">
				MAXIMUM_ELEVATION
			</label>
			<input type="text" name="MAXIMUM_ELEVATION" size="120" value="#MAXIMUM_ELEVATION#">
			<br>
			<input readonly="readonly" class="readClr" type="text" size="120" value="#orig.MAXIMUM_ELEVATION#">
			<label for="ORIG_ELEV_UNITS">
				ORIG_ELEV_UNITS
			</label>
			<input type="text" name="ORIG_ELEV_UNITS" size="120" value="#ORIG_ELEV_UNITS#">
			<br>
			<input readonly="readonly" class="readClr" type="text" size="120" value="#orig.ORIG_ELEV_UNITS#">
			<label for="MIN_DEPTH">
				MIN_DEPTH
			</label>
			<input type="text" name="MIN_DEPTH" size="120" value="#MIN_DEPTH#">
			<br>
			<input readonly="readonly" class="readClr" type="text" size="120" value="#orig.MIN_DEPTH#">
			<label for="MAX_DEPTH">
				MAX_DEPTH
			</label>
			<input type="text" name="MAX_DEPTH" size="120" value="#MAX_DEPTH#">
			<br>
			<input readonly="readonly" class="readClr" type="text" size="120" value="#orig.MAX_DEPTH#">
			<label for="DEPTH_UNITS">
				DEPTH_UNITS
			</label>
			<input type="text" name="DEPTH_UNITS" size="120" value="#DEPTH_UNITS#">
			<br>
			<input readonly="readonly" class="readClr" type="text" size="120" value="#orig.DEPTH_UNITS#">
			<label for="MAX_ERROR_DISTANCE">
				MAX_ERROR_DISTANCE
			</label>
			<input type="text" name="MAX_ERROR_DISTANCE" size="120" value="#MAX_ERROR_DISTANCE#">
			<br>
			<input readonly="readonly" class="readClr" type="text" size="120" value="#orig.MAX_ERROR_DISTANCE#">
			<label for="MAX_ERROR_UNITS">
				MAX_ERROR_UNITS
			</label>
			<input type="text" name="MAX_ERROR_UNITS" size="120" value="#MAX_ERROR_UNITS#">
			<br>
			<input readonly="readonly" class="readClr" type="text" size="120" value="#orig.MAX_ERROR_UNITS#">
			<label for="DATUM">
				DATUM
			</label>
			<input type="text" name="DATUM" size="120" value="#DATUM#">
			<br>
			<input readonly="readonly" class="readClr" type="text" size="120" value="#orig.DATUM#">
			<label for="LOCALITY_REMARKS">
				LOCALITY_REMARKS (case insensitive, operators OK)
			</label>
			<input type="text" name="LOCALITY_REMARKS" size="120" value="#LOCALITY_REMARKS#">
			<br>
			<input readonly="readonly" class="readClr" type="text" size="120" value="#orig.LOCALITY_REMARKS#">
			<label for="GEOREFERENCE_SOURCE">
				GEOREFERENCE_SOURCE (case insensitive, operators OK)
			</label>
			<input type="text" name="GEOREFERENCE_SOURCE" size="120" value="#GEOREFERENCE_SOURCE#">
			<br>
			<input readonly="readonly" class="readClr" type="text" size="120" value="#orig.GEOREFERENCE_SOURCE#">
			<label for="GEOREFERENCE_PROTOCOL">
				GEOREFERENCE_PROTOCOL
			</label>
			<input type="text" name="GEOREFERENCE_PROTOCOL" size="120" value="#GEOREFERENCE_PROTOCOL#">
			<br>
			<input readonly="readonly" class="readClr" type="text" size="120" value="#orig.GEOREFERENCE_PROTOCOL#">
			<label for="LOCALITY_NAME">
				LOCALITY_NAME
			</label>
			<input type="text" name="LOCALITY_NAME" size="120" value="#LOCALITY_NAME#">
			<br>
			<input readonly="readonly" class="readClr" type="text" size="120" value="#orig.LOCALITY_NAME#">
			<label for="geologyConcat">
				geologyConcat
			</label>
			<input type="text" name="geologyConcat" size="120" value="#geologyConcat#">
			<br>
			<input readonly="readonly" class="readClr" type="text" size="120" value="#orig.geologyConcat#">
			<br>
			<input type="submit" value="filter table below">
			<a href="duplicateLocality.cfm?locality_id=#locality_id#">
				[ change nothing - reset everything ]
			</a>
		</form>
		<cfset sql="select
			LOCALITY_ID,
			GEOG_AUTH_REC_ID,
			SPEC_LOCALITY,
			DEC_LAT,
			DEC_LONG,
			MINIMUM_ELEVATION,
			MAXIMUM_ELEVATION,
			ORIG_ELEV_UNITS,
			MIN_DEPTH,
			MAX_DEPTH,
			DEPTH_UNITS,
			MAX_ERROR_DISTANCE,
			MAX_ERROR_UNITS,
			DATUM,
			LOCALITY_REMARKS,
			GEOREFERENCE_SOURCE,
			GEOREFERENCE_PROTOCOL,
			LOCALITY_NAME,
			concatGeologyAttributeDetail(locality_id) geologyConcat
			from
			locality
			where
			locality_id != #locality_id# and ">
		<cfif GEOG_AUTH_REC_ID is not "ignore">
			<cfif len(GEOG_AUTH_REC_ID) gt 0>
				<cfset sql=sql & " GEOG_AUTH_REC_ID=#GEOG_AUTH_REC_ID# and ">
			<cfelse>
				<cfset sql=sql & " GEOG_AUTH_REC_ID is null and ">
			</cfif>
		</cfif>
		<cfif spec_locality is not "ignore">
			<cfif len(SPEC_LOCALITY) gt 0>
				<cfset sql=sql & " upper(SPEC_LOCALITY) like '#ucase(escapeQuotes(SPEC_LOCALITY))#' and ">
			<cfelse>
				<cfset sql=sql & " SPEC_LOCALITY is null and ">
			</cfif>
		</cfif>
		<cfif DEC_LAT is not "ignore">
			<cfif len(DEC_LAT) gt 0>
				<cfset sql=sql & " DEC_LAT = #DEC_LAT# and ">
			<cfelse>
				<cfset sql=sql & " DEC_LAT is null and ">
			</cfif>
		</cfif>
		<cfif DEC_LONG is not "ignore">
			<cfif len(DEC_LONG) gt 0>
				<cfset sql=sql & " DEC_LONG=#DEC_LONG# and ">
			<cfelse>
				<cfset sql=sql & " DEC_LONG is null and ">
			</cfif>
		</cfif>
		<cfif MINIMUM_ELEVATION is not "ignore">
			<cfif len(MINIMUM_ELEVATION) gt 0>
				<cfset sql=sql & " MINIMUM_ELEVATION=#MINIMUM_ELEVATION# and ">
			<cfelse>
				<cfset sql=sql & " MINIMUM_ELEVATION is null and ">
			</cfif>
		</cfif>
		<cfif MAXIMUM_ELEVATION is not "ignore">
			<cfif len(MAXIMUM_ELEVATION) gt 0>
				<cfset sql=sql & " MAXIMUM_ELEVATION=#MAXIMUM_ELEVATION# and ">
			<cfelse>
				<cfset sql=sql & " MAXIMUM_ELEVATION is null and ">
			</cfif>
		</cfif>
		<cfif ORIG_ELEV_UNITS is not "ignore">
			<cfif len(ORIG_ELEV_UNITS) gt 0>
				<cfset sql=sql & " ORIG_ELEV_UNITS='#ORIG_ELEV_UNITS#' and ">
			<cfelse>
				<cfset sql=sql & " ORIG_ELEV_UNITS is null and ">
			</cfif>
		</cfif>
		<cfif MIN_DEPTH is not "ignore">
			<cfif len(MIN_DEPTH) gt 0>
				<cfset sql=sql & " MIN_DEPTH=#MIN_DEPTH# and ">
			<cfelse>
				<cfset sql=sql & " MIN_DEPTH is null and ">
			</cfif>
		</cfif>
		<cfif MAX_DEPTH is not "ignore">
			<cfif len(MAX_DEPTH) gt 0>
				<cfset sql=sql & " MAX_DEPTH=#MAX_DEPTH# and ">
			<cfelse>
				<cfset sql=sql & " MAX_DEPTH is null and ">
			</cfif>
		</cfif>
		<cfif DEPTH_UNITS is not "ignore">
			<cfif len(DEPTH_UNITS) gt 0>
				<cfset sql=sql & " DEPTH_UNITS='#DEPTH_UNITS#' and ">
			<cfelse>
				<cfset sql=sql & " DEPTH_UNITS is null and ">
			</cfif>
		</cfif>
		<cfif MAX_ERROR_DISTANCE is not "ignore">
			<cfif len(MAX_ERROR_DISTANCE) gt 0>
				<cfset sql=sql & " MAX_ERROR_DISTANCE=#MAX_ERROR_DISTANCE# and ">
			<cfelse>
				<cfset sql=sql & " MAX_ERROR_DISTANCE is null and ">
			</cfif>
		</cfif>
		<cfif MAX_ERROR_UNITS is not "ignore">
			<cfif len(MAX_ERROR_UNITS) gt 0>
				<cfset sql=sql & " MAX_ERROR_UNITS='#MAX_ERROR_UNITS#' and ">
			<cfelse>
				<cfset sql=sql & " MAX_ERROR_UNITS is null and ">
			</cfif>
		</cfif>
		<cfif DATUM is not "ignore">
			<cfif len(DATUM) gt 0>
				<cfset sql=sql & " DATUM='#DATUM#' and ">
			<cfelse>
				<cfset sql=sql & " DATUM is null and ">
			</cfif>
		</cfif>
		<cfif LOCALITY_REMARKS is not "ignore">
			<cfif len(LOCALITY_REMARKS) gt 0>
				<cfset sql=sql & " upper(LOCALITY_REMARKS) like '#ucase(escapeQuotes(LOCALITY_REMARKS))#' and ">
			<cfelse>
				<cfset sql=sql & " LOCALITY_REMARKS is null and ">
			</cfif>
		</cfif>
		<cfif GEOREFERENCE_SOURCE is not "ignore">
			<cfif len(GEOREFERENCE_SOURCE) gt 0>
				<cfset sql=sql & " upper(GEOREFERENCE_SOURCE) like '#ucase(escapeQuotes(GEOREFERENCE_SOURCE))#' and ">
			<cfelse>
				<cfset sql=sql & " GEOREFERENCE_SOURCE is null and ">
			</cfif>
		</cfif>
		<cfif GEOREFERENCE_PROTOCOL is not "ignore">
			<cfif len(GEOREFERENCE_PROTOCOL) gt 0>
				<cfset sql=sql & " GEOREFERENCE_PROTOCOL='#GEOREFERENCE_PROTOCOL#' and ">
			<cfelse>
				<cfset sql=sql & " GEOREFERENCE_PROTOCOL is null and ">
			</cfif>
		</cfif>
		<cfif LOCALITY_NAME is not "ignore">
			<cfif len(LOCALITY_NAME) gt 0>
				<cfset sql=sql & " LOCALITY_NAME='#LOCALITY_NAME#' and ">
			<cfelse>
				<cfset sql=sql & " LOCALITY_NAME is null and ">
			</cfif>
		</cfif>
		<cfif geologyConcat is not "ignore">
			<cfif len(geologyConcat) gt 0>
				<cfset sql=sql & " concatGeologyAttributeDetail(locality_id)='#geologyConcat#' ">
			<cfelse>
				<cfset sql=sql & " concatGeologyAttributeDetail(locality_id) is null ">
			</cfif>
		<cfelse>
			<!--- just to keep the SQL valid --->
			<cfset sql=sql & " 1=1 ">
		</cfif>
		<cfquery name="dups" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				#preservesinglequotes(sql)# and rownum < 1001
			</cfquery>
		<hr>
		<p>
			The SQL to build the table below is here.
			<br>
			In the event you want to merge localities but cannot because they are shared or used in verified events, use the Contact link in the footer or send a DBA email explaining what you're trying to do, and make sure you include this SQL.
		</p>
		<cfset dsql=replace(sql,chr(9),'','all')>
		<cfset dsql=replace(dsql,'  ',' ','all')>
		<cfset dsql=replace(dsql,'and','and' & chr(10),'all')>
		<textarea rows="20" cols="120">
			#dsql# and#chr(10)#rownum < 1001
		</textarea>
		<hr>
		<cfif dups.recordcount is 100>
			This form only returns 1000 records. You may have to delete a few sets.
		</cfif>
		Potential Duplicates - check anything that you want to merge with the locality you came from and click the button.
		<p>
			IMPORTANT: "Merge" here means "replace all instances of checked localies with the 'good' locality, and delete the checked localities." You are wholly responsible for ensuring that everything in the selected locality/localities is reflected in the retained locality, including geology data.
		</p>
		<script>
				function checkAll() {
					$('input:checkbox[name="deleteLocalityID"]').prop('checked', true);
				}
				function uncheckAll() {
					$('input:checkbox[name="deleteLocalityID"]').prop('checked', false);
				}
			</script>
		<p>
		</p>
		<span class="likeLink" onclick="checkAll();">
			[ Check All ]
		</span>
		<span class="likeLink" onclick="uncheckAll();">
			[ UNcheck All ]
		</span>
		<form name="d" method="post" action="duplicateLocality.cfm">
			<input type="hidden" name="locality_id" value="#locality_id#">
			<input type="hidden" name="action" value="delete">
			<input type="hidden" name="returnaction" value="nothing">
			<input type="hidden" name="returnlocalityid" value="#locality_id#">
			<input type="submit" class="delBtn" value="merge checked localities with this locality">
			<table border id="t" class="sortable">
				<tr>
					<th>
						merge
					</th>
					<th>
						LOCALITY_ID
					</th>
					<th>
						GEOG_AUTH_REC_ID
					</th>
					<th>
						SPEC_LOCALITY
					</th>
					<th>
						DEC_LAT
					</th>
					<th>
						DEC_LONG
					</th>
					<th>
						MINIMUM_ELEVATION
					</th>
					<th>
						MAXIMUM_ELEVATION
					</th>
					<th>
						ORIG_ELEV_UNITS
					</th>
					<th>
						MIN_DEPTH
					</th>
					<th>
						MAX_DEPTH
					</th>
					<th>
						DEPTH_UNITS
					</th>
					<th>
						MAX_ERROR_DISTANCE
					</th>
					<th>
						MAX_ERROR_UNITS
					</th>
					<th>
						DATUM
					</th>
					<th>
						LOCALITY_REMARKS
					</th>
					<th>
						GEOREFERENCE_SOURCE
					</th>
					<th>
						GEOREFERENCE_PROTOCOL
					</th>
					<th>
						LOCALITY_NAME
					</th>
					<th>
						geologyConcat
					</th>
				</tr>
				<cfloop query="dups">
					<tr>
						<td>
							<input type="checkbox" name="deleteLocalityID" value="#LOCALITY_ID#">
						</td>
						<td>
							#LOCALITY_ID#
						</td>
						<td>
							#GEOG_AUTH_REC_ID#
						</td>
						<td>
							#SPEC_LOCALITY#
						</td>
						<td>
							#DEC_LAT#
						</td>
						<td>
							#DEC_LONG#
						</td>
						<td>
							#MINIMUM_ELEVATION#
						</td>
						<td>
							#MAXIMUM_ELEVATION#
						</td>
						<td>
							#ORIG_ELEV_UNITS#
						</td>
						<td>
							#MIN_DEPTH#
						</td>
						<td>
							#MAX_DEPTH#
						</td>
						<td>
							#DEPTH_UNITS#
						</td>
						<td>
							#MAX_ERROR_DISTANCE#
						</td>
						<td>
							#MAX_ERROR_UNITS#
						</td>
						<td>
							#DATUM#
						</td>
						<td>
							#LOCALITY_REMARKS#
						</td>
						<td>
							#GEOREFERENCE_SOURCE#
						</td>
						<td>
							#GEOREFERENCE_PROTOCOL#
						</td>
						<td>
							#LOCALITY_NAME#
						</td>
						<td>
							#geologyConcat#
						</td>
					</tr>
				</cfloop>
			</table>
		</form>
	</cfif>
	<cfif action is "delete">
		<cftransaction>
			<cfquery name="cleardups" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update collecting_event set locality_id=#locality_id# where locality_id in (#deleteLocalityID#)
			</cfquery>
			<cfquery name="cleardupsMedia" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update media_relations set related_primary_key=#locality_id# where
				media_relationship like '% locality' and
				related_primary_key in (#deleteLocalityID#)
			</cfquery>
			<cfquery name="cleardupsBL" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update bulkloader set locality_id=#locality_id# where locality_id in (#deleteLocalityID#)
			</cfquery>
			<cfquery name="deleteg" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
                delete from geology_attributes where locality_id in (#deleteLocalityID#)
            </cfquery>
			<cfquery name="delete" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from locality where locality_id in (#deleteLocalityID#)
			</cfquery>
		</cftransaction>
		<cflocation url="duplicateLocality.cfm?action=#returnaction#&locality_id=#returnlocalityid#" addtoken="false">
	</cfif>
</cfoutput>
<cfinclude template="includes/_footer.cfm">
