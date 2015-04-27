<cfinclude template="includes/_header.cfm">
<cfif isdefined("guid")>
	<!----
		<cfif cgi.script_name contains "/SpecimenDetail.cfm">
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="/guid/#guid#">
		<cfabort>
		</cfif>
		---->
	<cfset checkSql(guid)>
	<cfif guid contains ":">
		<cfoutput>
			<cfset sql="select collection_object_id from
				#session.flatTableName#
				WHERE
				upper(guid)='#ucase(guid)#'">
			<cfset checkSql(sql)>
			<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				#preservesinglequotes(sql)#
			</cfquery>
		</cfoutput>
	</cfif>
	<cfif isdefined("c.collection_object_id") and len(c.collection_object_id) gt 0>
		<cfset collection_object_id=c.collection_object_id>
	<cfelse>
		<cfinclude template="/errors/404.cfm">
		<cfabort>
	</cfif>
<cfelse>
	<cfinclude template="/errors/404.cfm">
	<cfabort>
</cfif>
<style>
	.acceptedIdDiv { border:1px dotted green; } .unAcceptedIdDiv{ border:1px dotted gray; background-color:#F8F8F8; color:gray; font-size:.8em; } .taxDetDiv { padding-left:1em; }
</style>
<cfset detSelect = "
	SELECT
	#session.flatTableName#.guid,
	#session.flatTableName#.collection_id,
	#session.flatTableName#.locality_id,
	web_link,
	web_link_text,
	#session.flatTableName#.cat_num,
	#session.flatTableName#.collection_object_id as collection_object_id,
	#session.flatTableName#.scientific_name,
	#session.flatTableName#.collecting_event_id,
	#session.flatTableName#.higher_geog,
	#session.flatTableName#.spec_locality,
	#session.flatTableName#.verbatim_date,
	#session.flatTableName#.BEGAN_DATE,
	#session.flatTableName#.ended_date,
	#session.flatTableName#.parts as partString,
	#session.flatTableName#.dec_lat,
	#session.flatTableName#.dec_long">
<cfset detSelect = "#detSelect#
	FROM
	#session.flatTableName#,
	collection
	where
	#session.flatTableName#.collection_id = collection.collection_id AND
	#session.flatTableName#.collection_object_id = #collection_object_id#
	ORDER BY
	cat_num">
<cfset checkSql(detSelect)>
<cfquery name="detail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	#preservesinglequotes(detSelect)#
</cfquery>
<cfif detail.recordcount lt 1>
	<div class="error">
		Oops! No specimen was found for that URL.
		<ul>
			<li>
				Did you mis-type the URL?
			</li>
			<li>
				Did you click a link?
				<a href="/info/bugs.cfm">
					Tell us about it
				</a>
				.
			</li>
			<li>
				You may need to log out or change your preferences to access all public data.
			</li>
		</ul>
	</div>
</cfif>
<cfset title="#detail.guid#: #detail.scientific_name#">
<cfset metaDesc="#detail.guid#; #detail.scientific_name#; #detail.higher_geog#; #detail.spec_locality#">
<cf_customizeHeader collection_id=#detail.collection_id#>
<cfif (detail.verbatim_date is detail.began_date) AND (detail.verbatim_date is detail.ended_date)>
	<cfset thisDate = detail.verbatim_date>
<cfelseif (
		(detail.verbatim_date is not detail.began_date) OR
		(detail.verbatim_date is not detail.ended_date)
		)
		AND
		detail.began_date is detail.ended_date>
	<cfset thisDate = "#detail.verbatim_date# (#detail.began_date#)">
<cfelse>
	<cfset thisDate = "#detail.verbatim_date# (#detail.began_date# - #detail.ended_date#)">
</cfif>
<cfset sciname = '#replace(detail.Scientific_Name," or ","</i>&nbsp;or&nbsp;<i>")#'>
<div class="sdtitle">
	#detail.guid#: #sciname#
</div>
<div class="sdterm">
	#detail.higher_geog#
</div>
<div class="sdterm">
	#detail.spec_locality#
</div>
<div class="sdterm">
	#thisDate#
</div>
<cfquery name="one" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
    SELECT
        collection_object_id,
        cat_num,
        collection_cde,
        accn_id,
        collection,
        EnteredBy,
        LASTUSER EditedBy,
        entereddate,
        LASTDATE,
        accession,
        concatEncumbranceDetails(collection_object_id) encumbranceDetail,
        typestatus,
        encumbrances,
        COLLECTORS,
        PREPARATORS,
        concatCollectorAgent(#session.flatTableName#.collection_object_id,'maker') makers,
        remarks,
        flags,
        PHYLCLASS,
        KINGDOM,
        PHYLUM,
        PHYLORDER,
        FAMILY,
        GENUS,
        SPECIES,
        SUBSPECIES,
        FORMATTED_SCIENTIFIC_NAME,
        full_taxon_name,
        associated_species
    FROM
        #session.flatTableName#
    WHERE
        #session.flatTableName#.collection_object_id = <cfqueryparam value = "#collection_object_id#" CFSQLType = "CF_SQL_INTEGER">
</cfquery>
<cfquery name="attribute" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
    select
        attribute_type,
        attribute_value,
        attribute_units,
        attribute_remark,
        determination_method,
        determined_date,
        determiner attributeDeterminer
    from
        v_attributes
    where
        <cfif not listfind(session.roles,"COLDFUSION_USER")>
            is_encumbered=0 and
        </cfif>
        collection_object_id = <cfqueryparam value = "#collection_object_id#" CFSQLType = "CF_SQL_INTEGER">
</cfquery>
<cfquery name="rawevent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
    select
        specimen_event.SPECIMEN_EVENT_ID,
        collecting_event.collecting_event_id,
        assigned_by_agent_id,
        getPreferredAgentName(assigned_by_agent_id) assigned_by_agent_name,
        assigned_date,
        specimen_event_remark,
        specimen_event_type,
        COLLECTING_METHOD,
        COLLECTING_SOURCE,
        VERIFICATIONSTATUS,
        habitat,
        locality.LOCALITY_ID,
        VERBATIM_DATE,
        VERBATIM_LOCALITY,
        COLL_EVENT_REMARKS,
        BEGAN_DATE,
        ENDED_DATE,
        CASE
            WHEN '#one.encumbrances#' LIKE '%mask coordinates%'
            THEN NULL
            ELSE verbatim_coordinates
        END verbatim_coordinates,
        collecting_event_name,
        CASE
            WHEN '#one.encumbrances#' LIKE '%mask coordinates%'
            THEN NULL
            ELSE locality.DEC_LAT
        END DEC_LAT,
        CASE
            WHEN '#one.encumbrances#' LIKE '%mask coordinates%'
            THEN NULL
            ELSE locality.DEC_LONG
        END DEC_LONG,
        collecting_event.DATUM,
        collecting_event.ORIG_LAT_LONG_UNITS,
        geog_auth_rec.GEOG_AUTH_REC_ID,
        geog_auth_rec.SOURCE_AUTHORITY,
        SPEC_LOCALITY,
        MINIMUM_ELEVATION,
        MAXIMUM_ELEVATION,
        ORIG_ELEV_UNITS,
        MIN_DEPTH,
        MAX_DEPTH,
        DEPTH_UNITS,
        MAX_ERROR_DISTANCE,
        MAX_ERROR_UNITS,
        LOCALITY_REMARKS,
        georeference_source,
        georeference_protocol,
        locality_name,
        higher_geog,
        geog_auth_rec.SOURCE_AUTHORITY,
        geog_search_term.SEARCH_TERM
    from
        specimen_event,
        collecting_event,
        locality,
        geog_auth_rec,
        geog_search_term
    where
        specimen_event.collecting_event_id=collecting_event.collecting_event_id and
        collecting_event.locality_id=locality.locality_id and
        locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
        geog_auth_rec.geog_auth_rec_id=geog_search_term.geog_auth_rec_id (+) and
        specimen_event.specimen_event_type != 'unaccepted place of collection' and
        specimen_event.collection_object_id=<cfqueryparam value = "#collection_object_id#" CFSQLType = "CF_SQL_INTEGER">
    order by
        specimen_event_type
</cfquery>
<cfquery name="event" dbtype="query">
    select
        SPECIMEN_EVENT_ID,
        collecting_event_id,
        assigned_by_agent_id,
        assigned_by_agent_name,
        assigned_date,
        specimen_event_remark,
        specimen_event_type,
        COLLECTING_METHOD,
        COLLECTING_SOURCE,
        VERIFICATIONSTATUS,
        habitat,
        LOCALITY_ID,
        VERBATIM_DATE,
        VERBATIM_LOCALITY,
        COLL_EVENT_REMARKS,
        BEGAN_DATE,
        ENDED_DATE,
        verbatim_coordinates,
        collecting_event_name,
        DEC_LAT,
        DEC_LONG,
        DATUM,
        ORIG_LAT_LONG_UNITS,
        GEOG_AUTH_REC_ID,
        SOURCE_AUTHORITY,
        SPEC_LOCALITY,
        MINIMUM_ELEVATION,
        MAXIMUM_ELEVATION,
        ORIG_ELEV_UNITS,
        MIN_DEPTH,
        MAX_DEPTH,
        DEPTH_UNITS,
        MAX_ERROR_DISTANCE,
        MAX_ERROR_UNITS,
        LOCALITY_REMARKS,
        georeference_source,
        georeference_protocol,
        locality_name,
        higher_geog,
        SOURCE_AUTHORITY
    from
        rawevent
    group by
        SPECIMEN_EVENT_ID,
        collecting_event_id,
        assigned_by_agent_id,
        assigned_by_agent_name,
        assigned_date,
        specimen_event_remark,
        specimen_event_type,
        COLLECTING_METHOD,
        COLLECTING_SOURCE,
        VERIFICATIONSTATUS,
        habitat,
        LOCALITY_ID,
        VERBATIM_DATE,
        VERBATIM_LOCALITY,
        COLL_EVENT_REMARKS,
        BEGAN_DATE,
        ENDED_DATE,
        verbatim_coordinates,
        collecting_event_name,
        DEC_LAT,
        DEC_LONG,
        DATUM,
        ORIG_LAT_LONG_UNITS,
        GEOG_AUTH_REC_ID,
        SOURCE_AUTHORITY,
        SPEC_LOCALITY,
        MINIMUM_ELEVATION,
        MAXIMUM_ELEVATION,
        ORIG_ELEV_UNITS,
        MIN_DEPTH,
        MAX_DEPTH,
        DEPTH_UNITS,
        MAX_ERROR_DISTANCE,
        MAX_ERROR_UNITS,
        LOCALITY_REMARKS,
        georeference_source,
        georeference_protocol,
        locality_name,
        higher_geog,
        SOURCE_AUTHORITY
</cfquery>
<cfoutput query="one">
	<!------------------------------------ Taxonomy ---------------------------------------------->
	<div class="detailCell">
		<div class="detailBlock">
			<span class="detailData">
				<cfquery name="raw_identification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
                    SELECT
                        identification.scientific_name,
                        concatidagent(identification.identification_id) agent_name,
                        made_date,
                        nature_of_id,
                        identification_remarks,
                        identification.identification_id,
                        accepted_id_fg,
                        taxa_formula,
                        short_citation,
                        identification.publication_id,
                        taxon_name.scientific_name taxsciname
                    FROM
                        identification,
                        publication,
                        identification_taxonomy,
                        taxon_name
                    WHERE
                        identification.publication_id=publication.publication_id (+) and
                        identification.identification_id=identification_taxonomy.identification_id (+) and
                        identification_taxonomy.taxon_name_id=taxon_name.taxon_name_id (+) and
                        identification.collection_object_id = #collection_object_id#
                </cfquery>
				<cfquery name="identification" dbtype="query">
                             select
                                 scientific_name,
                                 agent_name,
                                 made_date,
                                 nature_of_id,
                                 identification_remarks,
                                 identification_id,
                                 accepted_id_fg,
                                 taxa_formula,
                                 short_citation,
                                 publication_id
                             from
                                 raw_identification
                             group by
                                 scientific_name,
                                 agent_name,
                                 made_date,
                                 nature_of_id,
                                 identification_remarks,
                                 identification_id,
                                 accepted_id_fg,
                                 taxa_formula,
                                 short_citation,
                                 publication_id
                             ORDER BY accepted_id_fg DESC,made_date DESC
                         </cfquery>
				<cfloop query="identification">
					<cfif accepted_id_fg is 1>
						<div class="acceptedIdDiv">
						<cfelse>
							<div class="unAcceptedIdDiv">
					</cfif>
					<cfquery name="thisTaxLinks" dbtype="query">
                                    select taxsciname from raw_identification where identification_id=#identification_id#
                                </cfquery> <cfset link=""> <cfset i=1> <cfset thisSciName="#scientific_name#"> <cfloop query="thisTaxLinks"> <cfset thisLink='<a href="/name/#taxsciname#" target="_blank">#taxsciname#</a>'> <cfset thisSciName=#replace(thisSciName,taxsciname,thisLink)#> <cfset i=i+1> </cfloop> #thisSciName# <cfif not isdefined("metaDesc")> <cfset metaDesc=""> </cfif> <div class="taxDetDiv"> <cfif accepted_id_fg is 1> <div style="font-size:.8em;color:gray;"> #one.full_taxon_name# </div> </cfif> <cfif len(short_citation) gt 0> sensu <a href="/publication/#publication_id#" target="_mainFrame"> #short_citation# </a><br> </cfif> Identified by #agent_name# <cfif len(made_date) gt 0> on #made_date# </cfif> <br>Nature of ID: #nature_of_id# <cfif len(identification_remarks) gt 0> <br>Remarks: #identification_remarks# </cfif> </div> </div>
				</cfloop>
			</span>
			</div>
		</div>
		<!------------------------------------ citations ---------------------------------------------->
		<cfif len(one.typestatus) gt 0>
			<cfquery name="citations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
                    select
                        citation.PUBLICATION_ID,
                        type_status,
                        identification.scientific_name idsciname,
                        taxon_name.scientific_name taxsciname,
                        short_citation,
                        OCCURS_PAGE_NUMBER,
                        preview_uri,
                        media_type,
                        media_uri
                    FROM
                        citation,
                        identification,
                        publication,
                        identification_taxonomy,
                        taxon_name,
                        (select * from media_relations where media_relationship='shows publication') media_relations,
                        media
                    WHERE
                        citation.identification_id=identification.identification_id AND
                        citation.publication_id=publication.publication_id AND
                        identification.identification_id=identification_taxonomy.identification_id and
                        identification_taxonomy.taxon_name_id=taxon_name.taxon_name_id and
                        publication.publication_id = media_relations.related_primary_key (+) and
                        media_relations.media_id=media.media_id (+) and
                        citation.collection_object_id=#collection_object_id#
                </cfquery>
			<div class="detailCell">
				<div class="detailLabel">
					Citations
				</div>
				<cfloop query="citations">
					<div class="detailBlock">
						#type_status# of
						<a href="http://arctos.database.museum/name/#taxsciname#">
							#idsciname#
						</a>
						<cfif len(OCCURS_PAGE_NUMBER) gt 0>
							, page #OCCURS_PAGE_NUMBER#
						</cfif>
						in
						<a href="http://arctos.database.museum/publication/#PUBLICATION_ID#">
							#short_citation#
						</a>
						<cfif len(media_uri) gt 0>
							<cfset mp = obj.getMediaPreview(
								preview_uri="#preview_uri#",
								media_type="#media_type#")>
							<a href="/exit.cfm?target=#media_uri#" target="_blank">
								<img src="#mp#" class="smallMediaPreview">
							</a>
						</cfif>
					</div>
				</cfloop>
			</div>
		</cfif>
		<!------------------------------------ locality ---------------------------------------------->
		<div class="detailCell">
			<cfloop query="event">
				<div style="border:1px solid green; margin:1em;">
					<div id="seidd_#specimen_event_id#" style="display:none;font-size:xx-small;">
						OccurrenceID: #Application.serverRootURL#/guid/#guid#?seid=#specimen_event_id#
					</div>
					Determination&nbsp;Type:#specimen_event_type# assigned by #assigned_by_agent_name# on #dateformat(assigned_date,'yyyy-mm-dd')# Higher Geography:
					<cfif left(source_authority,4) is "http">
						<a href="#source_authority#" target="_blank" class="external">
							#higher_geog#
						</a>
					<cfelse>
						#higher_geog#
					</cfif>
					<cfquery name="geosrchterms" dbtype="query">
                                    select search_term from rawevent where specimen_event_id=#specimen_event_id# group by search_term order by search_term
                                </cfquery>
					<div style="margin-left:1em;max-height:3em;overflow:auto;" class="detailBlock">
						<cfloop query='geosrchterms'>
							<div class="detailCellSmall">
								#search_term#
							</div>
						</cfloop>
					</div>
					<cfif verbatim_locality is not spec_locality>
						<cfif len(verbatim_locality) gt 0>
							<div class="detailData">
								<div id="SDCellLeft" class="innerDetailLabel">
									Verbatim Locality:
								</div>
								<div class="SDCellRight">
									#verbatim_locality#
								</div>
							</div>
						</cfif>
					</cfif>
					<cfif len(locality_name) gt 0>
						<div class="detailData">
							<div id="SDCellLeft" class="innerDetailLabel">
								Locality Nickname:
							</div>
							<div class="SDCellRight">
								#locality_name#
							</div>
						</div>
					</cfif>
					<cfif len(collecting_event_name) gt 0>
						<div class="detailData">
							<div id="SDCellLeft" class="innerDetailLabel">
								Event Nickname:
							</div>
							<div class="SDCellRight">
								#collecting_event_name#
							</div>
						</div>
					</cfif>
					<cfif len(spec_locality) gt 0>
						<div class="detailData">
							<div id="SDCellLeft" class="innerDetailLabel">
								Specific Locality:
							</div>
							<div class="SDCellRight">
								#spec_locality#
							</div>
						</div>
					</cfif>
					<cfif len(specimen_event_remark) gt 0>
						<div class="detailData">
							<div id="SDCellLeft" class="innerDetailLabel">
								Specimen/Event Remarks:
							</div>
							<div class="SDCellRight">
								#specimen_event_remark#
							</div>
						</div>
					</cfif>
					<cfif len(COLL_EVENT_REMARKS) gt 0>
						<div class="detailData">
							<div id="SDCellLeft" class="innerDetailLabel">
								Event Remarks:
							</div>
							<div class="SDCellRight">
								#COLL_EVENT_REMARKS#
							</div>
						</div>
					</cfif>
					<cfif len(LOCALITY_REMARKS) gt 0>
						<div class="detailData">
							<div id="SDCellLeft" class="innerDetailLabel">
								Locality Remarks:
							</div>
							<div class="SDCellRight">
								#LOCALITY_REMARKS#
							</div>
						</div>
					</cfif>
					<cfif len(habitat) gt 0>
						<div class="detailData">
							<div id="SDCellLeft" class="innerDetailLabel">
								Habitat:
							</div>
							<div class="SDCellRight">
								#habitat#
							</div>
						</div>
					</cfif>
					<cfif len(collecting_method) gt 0>
						<div class="detailBlock">
							<div class="detailData">
								<div id="SDCellLeft" class="innerDetailLabel">
									Collecting&nbsp;Method:
								</div>
								<div class="SDCellRight">
									#collecting_method#
								</div>
							</div>
						</div>
					</cfif>
					<cfif len(collecting_source) gt 0>
						<div class="detailBlock">
							<div class="detailData">
								<div id="SDCellLeft" class="innerDetailLabel">
									Collecting&nbsp;Source:
								</div>
								<div class="SDCellRight">
									#collecting_source#
								</div>
							</div>
						</div>
					</cfif>
					<div class="detailData">
						<div id="SDCellLeft" class="innerDetailLabel">
							Event Date:
						</div>
						<div class="SDCellRight">
							#began_date#
							<cfif ended_date neq began_date>
								to #ended_date#
							</cfif>
						</div>
					</div>
					<div>
						<div>
						</div>
						<div class="SDCellRight" class="detailCellSmall">
							Verbatim Date: #verbatim_date#
						</div>
					</div>
					<cfif len(VERIFICATIONSTATUS) gt 0>
						<div class="detailBlock">
							<div class="detailData">
								<div id="SDCellLeft" class="innerDetailLabel">
									Verification&nbsp;Status:
								</div>
								<div class="SDCellRight">
									#VERIFICATIONSTATUS#
								</div>
							</div>
						</div>
					</cfif>
					<cfif len(one.associated_species) gt 0>
						<div class="detailBlock">
							<div class="detailData">
								<div id="SDCellLeft" class="innerDetailLabel">
									Associated Species:
								</div>
								<div class="SDCellRight">
									#one.associated_species#
								</div>
							</div>
						</div>
					</cfif>
					<div>
						<div>
							<div>
								<div>
									<div>
										<!---- text stuff here ---->
										<div>
											<cfif len(dec_lat) gt 0 and len(dec_long) gt 0>
												<div>
													<div class="align-top-right">
														Coordinates:
													</div>
													<div class="align-left">
														#dec_lat# / #dec_long#
														<cfif len(verbatim_coordinates) gt 0>
															<div class="detailCellSmall">
																Verbatim Coordinates: #verbatim_coordinates#
															</div>
														</cfif>
														<cfif len(DATUM) gt 0>
															<div style="font-size:.8em;">
																Datum: #DATUM#
															</div>
														</cfif>
														<cfif len(MAX_ERROR_UNITS) gt 0>
															<div style="font-size:.8em;">
																Error: #MAX_ERROR_DISTANCE# #MAX_ERROR_UNITS#
															</div>
														</cfif>
														<cfif len(georeference_source) gt 0>
															<div style="font-size:.8em;">
																Georeference&nbsp;Source: #georeference_source#
															</div>
														</cfif>
														<cfif len(georeference_protocol) gt 0>
															<div style="font-size:.8em;">
																Georeference&nbsp;Protocol: #georeference_protocol#
															</div>
														</cfif>
													</div>
												</div>
											</cfif>
											<cfif len(orig_elev_units) gt 0>
												<div>
													<div class="align-right">
														Elevation
													</div>
													<div class="align-left">
														#minimum_elevation# to #maximum_elevation# #orig_elev_units#
													</div>
												</div>
											</cfif>
											<cfif len(DEPTH_UNITS) gt 0>
												<div>
													<div class="align-right">
														Depth:
													</div>
													<div class="align-left">
														#MIN_DEPTH# to #MAX_DEPTH# #DEPTH_UNITS#
													</div>
												</div>
											</cfif>
										</div>
									</div>
									<div class="align-top-right">
										<!---- map here --->
										<cfif len(dec_lat) gt 0 and len(dec_long) gt 0>
											<div id="mapgohere-locality_id-#locality_id#">
											</div>
											<!----
												<cfinvoke component="component.functions" method="getMap" returnvariable="contents">
												<cfinvokeargument name="locality_id" value="#locality_id#">
												</cfinvoke>
												#contents#
												---->
										</cfif>
									</div>
								</div>
								<div>
									<div class="align-top-right">
										<!---- map here --->
										<div id="colEventMedia">
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
					<cfquery name="geology" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
                            select * from
                            geology_attributes,
                            preferred_agent_name
                            where
                            geology_attributes.GEO_ATT_DETERMINER_ID=preferred_agent_name.agent_id (+) and
                             locality_id=#locality_id#
                        </cfquery>
					<cfloop query="geology">
						<div>
							<div id="SDCellLeft" class="innerDetailLabel">
								#GEOLOGY_ATTRIBUTE#:
							</div>
							<div class="SDCellRight">
								#GEO_ATT_VALUE#
							</div>
						</div>
						<div>
							<div>
							</div>
							<div class="SDCellRight" class="detailCellSmall">
								Determined by
								<cfif len(agent_name) gt 0>
									#agent_name#
								<cfelse>
									unknown
								</cfif>
								<cfif len(GEO_ATT_DETERMINED_DATE) gt 0>
									on #dateformat(GEO_ATT_DETERMINED_DATE,"yyyy-mm-dd")#
								</cfif>
								<cfif len(GEO_ATT_DETERMINED_METHOD) gt 0>
									Method: #GEO_ATT_DETERMINED_METHOD#
								</cfif>
								<cfif len(GEO_ATT_REMARK) gt 0>
									Remark: #GEO_ATT_REMARK#
								</cfif>
							</div>
						</div>
					</cfloop>
					</div>
				</div>
			</cfloop>
		</div>
		<!------------------------------------ collectors ---------------------------------------------->
		<div class="detailCell">
			<div class="detailLabel">
				Collector(s)
				<cfif oneOfUs is 1>
					<span class="detailEditCell" onclick="window.parent.loadEditApp('editColls');">
						Edit
					</span>
				</cfif>
			</div>
			<div class="detailBlock">
				<span class="detailData">
					<span class="innerDetailLabel">
					</span>
					#collectors#
				</span>
			</div>
		</div>
		<!------------------------------------ preparators ---------------------------------------------->
		<cfif len(preparators) gt 0>
			<div class="detailCell">
				<div class="detailLabel">
					Preparator(s)
					<cfif oneOfUs is 1>
						<span class="detailEditCell" onclick="window.parent.loadEditApp('editColls');">
							Edit
						</span>
					</cfif>
				</div>
				<div class="detailBlock">
					<span class="detailData">
						<span class="innerDetailLabel">
						</span>
						#preparators#
					</span>
				</div>
			</div>
		</cfif>
		<!------------------------------------ makers ---------------------------------------------->
		<cfif len(makers) gt 0>
			<div class="detailCell">
				<div class="detailLabel">
					Maker(s)
					<cfif oneOfUs is 1>
						<span class="detailEditCell" onclick="window.parent.loadEditApp('editColls');">
							Edit
						</span>
					</cfif>
				</div>
				<div class="detailBlock">
					<span class="detailData">
						<span class="innerDetailLabel">
						</span>
						#makers#
					</span>
				</div>
			</div>
		</cfif>
		<cfquery name="isProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
                SELECT project_name, project.project_id project_id FROM
                project, project_trans
                WHERE
                project_trans.project_id = project.project_id AND
                project_trans.transaction_id=#one.accn_id#
                GROUP BY project_name, project.project_id
          </cfquery>
		<cfquery name="isLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
                SELECT project_name, project.project_id FROM
                    loan_item,
                    project,
                    project_trans,
                    specimen_part
                 WHERE
                    specimen_part.derived_from_cat_item = #one.collection_object_id# AND
                    loan_item.transaction_id=project_trans.transaction_id AND
                    project_trans.project_id=project.project_id AND
                    specimen_part.collection_object_id = loan_item.collection_object_id
                GROUP BY
                    project_name, project.project_id
        </cfquery>
		<cfquery name="isLoanedItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
            SELECT
                loan_item.collection_object_id
            FROM
                loan_item,
                specimen_part
            WHERE
                loan_item.collection_object_id=specimen_part.collection_object_id AND
                specimen_part.derived_from_cat_item=#one.collection_object_id#
            UNION
            SELECT
                loan_item.collection_object_id
            FROM
                loan_item
            WHERE
                loan_item.collection_object_id=#one.collection_object_id#
        </cfquery>
		</div>
		<div class="align-top-half">
			<!------------------------------------ identifiers ---------------------------------------------->
			<cfquery name="oid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
                SELECT
                    coll_obj_other_id_num.COLL_OBJ_OTHER_ID_NUM_ID,
                    case when #oneOfUs# != 1 and
                        concatencumbrances(coll_obj_other_id_num.collection_object_id) like '%mask original field number%' and
                        coll_obj_other_id_num.other_id_type = 'original identifier'
                        then 'Masked'
                    else
                        coll_obj_other_id_num.display_value
                    end display_value,
                    coll_obj_other_id_num.other_id_type,
                    coll_obj_other_id_num.id_references,
                    case when base_url is not null then
                        ctcoll_other_id_type.base_url || coll_obj_other_id_num.display_value
                    else
                        null
                    end link
                FROM
                    coll_obj_other_id_num,
                    ctcoll_other_id_type
                where
                    collection_object_id=#one.collection_object_id# and
                    coll_obj_other_id_num.other_id_type=ctcoll_other_id_type.other_id_type (+)
            </cfquery>
			<cfquery name="ids" dbtype="query">
                select * from oid where id_references='self' order by other_id_type
            </cfquery>
			<cfif len(ids.other_id_type) gt 0>
				<div class="detailCell" style="max-height:200px;overflow:auto;">
					<div class="detailLabel">
						Identifiers
						<cfif oneOfUs is 1>
							<span class="detailEditCell" onclick="window.parent.loadEditApp('editIdentifiers');">
								Edit
							</span>
						</cfif>
					</div>
					<cfloop query="ids">
						<div class="detailBlock">
							<span class="innerDetailLabel">
								#other_id_type#:
							</span>
							<cfif len(link) gt 0>
								<a class="external" href="#link#" target="_blank">
									#display_value#
								</a>
							<cfelse>
								#display_value#
							</cfif>
						</div>
					</cfloop>
				</div>
			</cfif>
			<cfquery name="rels" dbtype="query">
                select * from oid where id_references != 'self' order by id_references,other_id_type
            </cfquery>
			<cfif len(rels.other_id_type) gt 0>
				<div class="detailCell" id="relationshipsCell" style="max-height:200px;overflow:auto;">
					<div class="detailLabel">
						Relationships
						<cfif oneOfUs is 1>
							<span class="detailEditCell" onclick="window.parent.loadEditApp('editIdentifiers');">
								Edit
							</span>
						</cfif>
					</div>
					<cfloop query="rels">
						<cfquery name="relcache" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
                            select * from cf_relations_cache where COLL_OBJ_OTHER_ID_NUM_ID=#COLL_OBJ_OTHER_ID_NUM_ID# order by term
                        </cfquery>
						<cfset thisClass="">
						<cfif id_references is "same individual as">
							<script>
                                $("body").addClass("isDuplicateRecord");
                            </script>
							<cfset thisClass="isDuplicateRecord">
						</cfif>
						<div class="detailBlock #thisClass#">
							<span class="innerDetailLabel">
								(
								<i>
									#id_references#
								</i>
								)
							</span>
							<cfif len(link) gt 0>
								<a class="external" href="#link#" target="_blank">
									#other_id_type#:#display_value#
								</a>
							<cfelse>
								#other_id_type#:#display_value#
							</cfif>
							<div class="relCacheDiv">
								<cfloop query="relcache">
									<div class="indivRelCacheTerm">
										#TERM#@#dateformat(CACHEDATE,"yyyy-mm-dd")#: #VALUE#
									</div>
								</cfloop>
							</div>
						</div>
					</cfloop>
				</div>
			</cfif>
			<!------------------------------------ parts ---------------------------------------------->
			<cfquery name="rparts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
    select
        specimen_part.collection_object_id part_id,
        pc.label,
        part_name,
        sampled_from_obj_id,
        coll_object.COLL_OBJ_DISPOSITION part_disposition,
        coll_object.CONDITION part_condition,
        lot_count,
        coll_object_remarks part_remarks,
        attribute_type,
        attribute_value,
        attribute_units,
        determined_date,
        attribute_remark,
        agent_name
    from
        specimen_part,
        coll_object,
        coll_object_remark,
        coll_obj_cont_hist,
        container oc,
        container pc,
        specimen_part_attribute,
        preferred_agent_name
    where
        specimen_part.collection_object_id=specimen_part_attribute.collection_object_id (+) and
        specimen_part_attribute.determined_by_agent_id=preferred_agent_name.agent_id (+) and
        specimen_part.collection_object_id=coll_object.collection_object_id and
        coll_object.collection_object_id=coll_obj_cont_hist.collection_object_id and
        coll_object.collection_object_id=coll_object_remark.collection_object_id (+) and
        coll_obj_cont_hist.container_id=oc.container_id and
        oc.parent_container_id=pc.container_id (+) and
        specimen_part.derived_from_cat_item=#one.collection_object_id#
</cfquery>
			<cfquery name="parts" dbtype="query">
    select
        part_id,
        label,
        part_name,
        sampled_from_obj_id,
        part_disposition,
        part_condition,
        lot_count,
        part_remarks
    from
        rparts
    group by
        part_id,
        label,
        part_name,
        sampled_from_obj_id,
        part_disposition,
        part_condition,
        lot_count,
        part_remarks
    order by
        part_name
</cfquery>
			<cfquery name="mPart" dbtype="query">
    select * from parts where sampled_from_obj_id is null order by part_name
</cfquery>
			<div class="detailCell">
				<div class="detailLabel">
					&nbsp;
					<!---Parts--->
					<cfif oneOfUs is 1>
						<span class="detailEditCell" onclick="window.parent.loadEditApp('editParts');">
							Edit
						</span>
					<cfelse>
						<span class="detailEditCell" onClick="getInfo('parts','#one.collection_object_id#');">
							Details
						</span>
					</cfif>
				</div>
				<div class="detailBlock">
					<span class="detailData">
						<table border>
							<div>
								<th>
									<span class="innerDetailLabel">
										Part Name
									</span>
								</th>
								<th>
									<span class="innerDetailLabel">
										Condition
									</span>
								</th>
								<cfif oneOfUs is 1>
									<th>
										<span class="innerDetailLabel">
											Disposition
										</span>
									</th>
								</cfif>
								<th>
									<span class="innerDetailLabel">
										Qty
									</span>
								</th>
								<cfif oneOfUs is 1>
									<th>
										<span class="innerDetailLabel">
											Label
										</span>
									</th>
								</cfif>
								<th>
									<span class="innerDetailLabel">
										Remarks
									</span>
								</th>
							</div>
							<cfloop query="mPart">
								<div>
									<div>
										#part_name#
									</div>
									<div>
										#part_condition#
									</div>
									<cfif oneOfUs is 1>
										<div>
											#part_disposition#
										</div>
									</cfif>
									<div>
										#lot_count#
									</div>
									<cfif oneOfUs is 1>
										<div>
											#label#
										</div>
									</cfif>
									<div>
										#part_remarks#
									</div>
								</div>
								<cfquery name="patt" dbtype="query">
                                    select
                                        attribute_type,
                                        attribute_value,
                                        attribute_units,
                                        determined_date,
                                        attribute_remark,
                                        agent_name
                                    from
                                        rparts
                                    where
                                        attribute_type is not null and
                                        part_id=#part_id#
                                    group by
                                        attribute_type,
                                        attribute_value,
                                        attribute_units,
                                        determined_date,
                                        attribute_remark,
                                        agent_name
                                    order by
                                        attribute_type,
                                        determined_date
                                </cfquery>
								<cfif patt.recordcount gt 0>
									<div>
											<table border id="patbl#mPart.part_id#" class="detailCellSmall sortable">
												<div>
													<th>
														Attribute
													</th>
													<th>
														Value
													</th>
													<th>
														Date
													</th>
													<th>
														Dtr.
													</th>
													<th>
														Rmk.
													</th>
												</div>
												<cfloop query="patt">
													<div>
														<div>
															#attribute_type#
														</div>
														<div>
															<cfif not(oneOfUs) and attribute_type is "location" and one.encumbranceDetail contains "mask part attribute location">
																masked
															<cfelse>
																#attribute_value#
																<cfif len(attribute_units) gt 0>
																	#attribute_units#
																</cfif>
															</cfif>
														</div>
														<div>
															#dateformat(determined_date,'yyyy-mm-dd')#
														</div>
														<div>
															#agent_name#
														</div>
														<div>
															#attribute_remark#
														</div>
													</div>
												</cfloop>
											</div>
									</div>
								</cfif>
								<cfquery name="sPart" dbtype="query">
                                    select * from parts where sampled_from_obj_id=#part_id#
                                </cfquery>
								<cfloop query="sPart">
									<div>
										<div>
											&nbsp;&nbsp;&nbsp;#part_name#
										</div>
										<div>
											#part_condition#
										</div>
										<cfif oneOfUs is 1>
											<div>
												#part_disposition#
											</div>
										</cfif>
										<div>
											#lot_count#
										</div>
										<cfif oneOfUs is 1>
											<div>
												#label#
											</div>
										</cfif>
										<div>
											#part_remarks#
										</div>
									</div>
								</cfloop>
							</cfloop>
						</div>
					</span>
				</div>
			</div>
			<!------------------------------------ attributes ---------------------------------------------->
			<cfif len(attribute.attribute_type) gt 0>
				<div class="detailCell">
					<div class="detailLabel">
						<!---Attributes--->
						<cfif oneOfUs is 1>
							<span class="detailEditCell" onclick="window.parent.loadEditApp('editBiolIndiv');">
								Edit
							</span>
						</cfif>
					</div>
					<cfquery name="sex" dbtype="query">
                        select * from attribute where attribute_type = 'sex'
                    </cfquery>
					<div class="detailBlock">
						<cfloop query="sex">
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">
										sex:
									</span>
									#attribute_value#
									<cfif len(attributeDeterminer) gt 0>
										<cfset determination = "#attributeDeterminer#">
										<cfif len(determined_date) gt 0>
											<cfset determination = '#determination#, #determined_date#'>
										</cfif>
										<cfif len(determination_method) gt 0>
											<cfset determination = '#determination#, #determination_method#'>
										</cfif>
										<div class="detailBlock">
											<span class="detailCellSmall">
												#determination#
											</span>
										</div>
									</cfif>
									<cfif len(attribute_remark) gt 0>
										<div class="detailBlock">
											<span class="detailCellSmall">
												<span class="innerDetailLabel">
													Remark:
												</span>
												#attribute_remark#
											</span>
										</div>
									</cfif>
								</span>
							</div>
						</cfloop>
						<cfif one.collection_cde is "Mamm">
							<cfquery name="total_length" dbtype="query">
                            select * from attribute where attribute_type = 'total length'
                        </cfquery>
							<cfquery name="tail_length" dbtype="query">
                            select * from attribute where attribute_type = 'tail length'
                        </cfquery>
							<cfquery name="hf" dbtype="query">
                            select * from attribute where attribute_type = 'hind foot with claw'
                        </cfquery>
							<cfquery name="efn" dbtype="query">
                            select * from attribute where attribute_type = 'ear from notch'
                        </cfquery>
							<cfquery name="weight" dbtype="query">
                            select * from attribute where attribute_type = 'weight'
                        </cfquery>
							<cfquery name="theRest" dbtype="query">
                            select * from attribute where attribute_type NOT IN (
                                'weight','sex','total length','tail length','hind foot with claw','ear from notch'
                            )
                        </cfquery>
							<cfif len(total_length.attribute_units) gt 0 OR
								len(tail_length.attribute_units) gt 0 OR
								len(hf.attribute_units) gt 0  OR
								len(efn.attribute_units) gt 0  OR
								len(weight.attribute_units) gt 0>
								<!---semi-standard measurements --->
								<div class="detailBlock">
									<span class="detailData">
										<span class="innerDetailLabel">
											Std. Meas.
										</span>
										<table border width="100%">
											<div>
												<div>
													<font size="-1">
														total length
													</font>
												</div>
												<div>
													<font size="-1">
														tail length
													</font>
												</div>
												<div>
													<font size="-1">
														hind foot
													</font>
												</div>
												<div>
													<font size="-1">
														efn
													</font>
												</div>
												<div>
													<font size="-1">
														weight
													</font>
												</div>
											</div>
											<div>
												<div>
													#total_length.attribute_value# #total_length.attribute_units#&nbsp;
												</div>
												<div>
													#tail_length.attribute_value# #tail_length.attribute_units#&nbsp;
												</div>
												<div>
													#hf.attribute_value# #hf.attribute_units#&nbsp;
												</div>
												<div>
													#efn.attribute_value# #efn.attribute_units#&nbsp;
												</div>
												<div>
													#weight.attribute_value# #weight.attribute_units#&nbsp;
												</div>
											</div>
										</div>
										<cfif isdefined("attributeDeterminer") and len(#attributeDeterminer#) gt 0>
											<cfset determination = "#attributeDeterminer#">
											<cfif len(determined_date) gt 0>
												<cfset determination = '#determination#, #determined_date#'>
											</cfif>
											<cfif len(determination_method) gt 0>
												<cfset determination = '#determination#, #determination_method#'>
											</cfif>
											<div class="detailBlock">
												<span class="detailCellSmall">
													#determination#
												</span>
											</div>
										</cfif>
									</span>
								</div>
							</cfif>
						<cfelse>
							<cfquery name="theRest" dbtype="query">
                            select * from attribute where attribute_type NOT IN ('sex')
                        </cfquery>
						</cfif>
						<cfloop query="theRest">
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">
										#attribute_type#:
									</span>
									#attribute_value#
									<cfif len(attribute_units) gt 0>
										#attribute_units#
									</cfif>
									<cfif len(attributeDeterminer) gt 0>
										<cfset determination = "&nbsp;&nbsp;#attributeDeterminer#">
										<cfif len(determined_date) gt 0>
											<cfset determination = '#determination#, #determined_date#'>
										</cfif>
										<cfif len(determination_method) gt 0>
											,
											<cfset determination = '#determination#, #determination_method#'>
										</cfif>
										<div class="detailBlock">
											<span class="detailCellSmall">
												#determination#
											</span>
										</div>
									</cfif>
									<cfif len(attribute_remark) gt 0>
										<div class="detailBlock">
											<span class="detailCellSmall">
												&nbsp;&nbsp;
												<span class="innerDetailLabel">
													Remark:
												</span>
												#attribute_remark#
											</span>
										</div>
									</cfif>
							</div>
							</span>
						</cfloop>
					</div>
				</div>
			</cfif>
			<!------------------------------------ cataloged item ---------------------------------------------->
			<div class="detailCell">
				<div class="detailLabel">
					<cfif oneOfUs is 1>
						<span class="detailEditCell" onclick="window.parent.loadEditApp('editBiolIndiv');">
							Edit
						</span>
					</cfif>
				</div>
				<cfif len(one.remarks) gt 0>
					<div class="detailBlock">
						<span class="detailData">
							<span class="innerDetailLabel">
								Remarks:
							</span>
							#one.remarks#
						</span>
					</div>
				</cfif>
				<cfif oneOfUs is 1>
					<div class="detailBlock">
						<span class="detailData">
							<span class="innerDetailLabel">
								Entered By:
							</span>
							#one.EnteredBy# on #dateformat(one.entereddate,"yyyy-mm-dd")#
						</span>
					</div>
					<cfif one.EditedBy is not "unknown" OR len(one.lastdate) is not 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">
									Last Edited By:
								</span>
								#one.EditedBy# on #dateformat(one.lastdate,"yyyy-mm-dd")#
							</span>
						</div>
					</cfif>
					<cfif len(#one.flags#) is not 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">
									Missing (flags):
								</span>
								#one.flags#
							</span>
						</div>
					</cfif>
					<cfif len(one.encumbranceDetail) is not 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">
									Encumbrances:
								</span>
								#replace(one.encumbranceDetail,";","
								<br>
								","all")#
							</span>
						</div>
					</cfif>
				</cfif>
			</div>
			<!------------------------------------ accession ---------------------------------------------->
			<div class="detailCell">
				<div class="detailLabel">
					Accession
					<cfif oneOfUs is 1>
						<span class="detailEditCell" onclick="window.parent.loadEditApp('addAccn');">
							Edit
						</span>
					</cfif>
				</div>
				<div class="detailBlock">
					<span class="detailData">
						<cfif oneOfUs is 1>
							<a href="/editAccn.cfm?Action=edit&transaction_id=#one.accn_id#" target="_blank">
								#accession#
							</a>
						<cfelse>
							<a href="/viewAccn.cfm?transaction_id=#one.accn_id#" target="_blank">
								#accession#
							</a>
						</cfif>
						<div id="SpecAccnMedia">
						</div>
					</span>
				</div>
			</div>
			<!------------------------------------ usage ---------------------------------------------->
			<cfif isProj.recordcount gt 0 OR isLoan.recordcount gt 0 or (oneOfUs is 1 and isLoanedItem.collection_object_id gt 0)>
				<div class="detailCell">
					<div class="detailLabel">
						Usage
					</div>
					<cfloop query="isProj">
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">
									Contributed By Project:
								</span>
								<a href="/ProjectDetail.cfm?src=proj&project_id=#isProj.project_id#">
									#isProj.project_name#
								</a>
							</span>
						</div>
					</cfloop>
					<cfloop query="isLoan">
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">
									Used By Project:
								</span>
								<a href="/ProjectDetail.cfm?src=proj&project_id=#isLoan.project_id#" target="_mainFrame">
									#isLoan.project_name#
								</a>
							</span>
						</div>
					</cfloop>
					<cfif isLoanedItem.collection_object_id gt 0 and oneOfUs is 1>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">
									Loan History:
								</span>
								<a href="/Loan.cfm?action=listLoans&collection_object_id=#valuelist(isLoanedItem.collection_object_id)#"
									target="_mainFrame">
									Click for loan list
								</a>
							</span>
						</div>
					</cfif>
				</div>
			</cfif>
			<!------------------------------------ Media ---------------------------------------------->
			<cfquery name="mediaTag" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
    select distinct
        tag.tag_id,
        media.media_id,
        media.media_uri,
        media.mime_type,
        media.media_type,
        media.preview_uri
     from
        media,
        tag
     where
         media.media_id=tag.media_id and
        tag.collection_object_id = #collection_object_id#
</cfquery>
			<cfif mediaTag.recordcount gt 0>
				<div class="detailCell">
					<div class="detailLabel">
						Tagged in Media
					</div>
					<div class="detailBlock">
						<cfloop query="mediaTag">
							<cfset puri = obj.getMediaPreview(preview_uri="#preview_uri#",media_type="#media_type#")>
							<span class="detailData">
								<cfif media_type is "multi-page document">
									<a href="/document.cfm?media_id=#media_id#&tag_id=#tag_id#" target="_blank">
										<img src="#puri#">
									</a>
								<cfelse>
									<a href="/showTAG.cfm?media_id=#media_id#" target="_blank">
										<img src="#puri#">
									</a>
								</cfif>
							</span>
						</cfloop>
					</div>
				</div>
			</cfif>
			<div class="detailCell">
				<div class="detailLabel">
					Media
				</div>
				<div class="detailBlock">
					<span class="detailData">
					<div id="specMediaDv">
					</div>
				</div>
			</div>
			<cftry>
				<!--- this thing is dicey sometimes.... ---->
				<cfquery name="barcode"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
                select p.barcode from
                container c,
                container p,
                coll_obj_cont_hist,
                specimen_part,
                cataloged_item
                where
                cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
                specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
                coll_obj_cont_hist.container_id=c.container_id and
                c.parent_container_id=p.container_id and
                cataloged_item.collection_object_id=#collection_object_id#
            </cfquery>
				<cfloop query="barcode">
					<cfquery name="ocr" datasource="taccocr">
                    select label from output where barcode = '#barcode#'
                </cfquery>
					<cfif ocr.recordcount is 1>
						<div class="detailLabel">
							OCR for #barcode#
						</div>
						<div class="detailBlock">
							<span class="detailData">
								#replace(ocr.label,chr(10),'
								<br>
								','all')#
							</span>
						</div>
					</cfif>
				</cfloop>
				<cfcatch>
				</cfcatch>
			</cftry>
	</div>
</cfoutput>
<cfinclude template="includes/_footer.cfm">
