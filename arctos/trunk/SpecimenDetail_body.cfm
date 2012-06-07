<cfif not isdefined("toProperCase")>
	<cfinclude template="/includes/_frameHeader.cfm">
</cfif>
<cfoutput>
	<cfif not isdefined("collection_object_id") or not isnumeric(collection_object_id)>
		<div class="error">
			Improper call. Aborting.....
		</div>
		<cfabort>
	</cfif>
	<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>
		<cfset oneOfUs = 1>
		<cfset isClicky = "likeLink">
	<cfelse>
		<cfset oneOfUs = 0>
		<cfset isClicky = "">
	</cfif>
	<cfif oneOfUs is 0 and cgi.CF_TEMPLATE_PATH contains "/SpecimenDetail_body.cfm">
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">
	</cfif>
</cfoutput>
<cfquery name="one" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	SELECT
		collection_object_id,
		cat_num,
		collection_cde,
		accn_id,
		collection,
		'missingfromflat' EnteredBy,
		LASTUSER EditedBy,
		accession,
		concatEncumbranceDetails(collection_object_id) encumbranceDetail,
		typestatus,
		encumbrances,
		COLLECTORS,
		PREPARATORS
	FROM 
		#session.flatTableName#
	WHERE 
		#session.flatTableName#.collection_object_id = <cfqueryparam value = "#collection_object_id#" CFSQLType = "CF_SQL_INTEGER">
</cfquery>
<cfdump var=#one#>
<cfquery name="attribute" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select	
		attributes.attribute_type,
		attributes.attribute_value,
		attributes.attribute_units,
		attributes.attribute_remark,
		attributes.determination_method,
		attributes.determined_date,
		attribute_determiner.agent_name attributeDeterminer
	from
		attributes,
		preferred_agent_name attribute_determiner
	where
		attributes.determined_by_agent_id = attribute_determiner.agent_id and
		attributes.collection_object_id = <cfqueryparam value = "#collection_object_id#" CFSQLType = "CF_SQL_INTEGER">
</cfquery>
<cfquery name="relns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	SELECT 
		biol_indiv_relations.biol_indiv_relationship, 
		biol_indiv_relations.related_coll_object_id,
		related_cat_item.cat_num related_cat_num,
		related_coll.collection as related_collection
	from		
		biol_indiv_relations,
		cataloged_item related_cat_item,
		collection related_coll
	where		
		biol_indiv_relations.related_coll_object_id = related_cat_item.collection_object_id AND
		related_cat_item.collection_id = related_coll.collection_id and
		biol_indiv_relations.collection_object_id = <cfqueryparam value = "#collection_object_id#" CFSQLType = "CF_SQL_INTEGER">
</cfquery>
<cfquery name="event" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
		collecting_event.COLLECTING_EVENT_ID,
    	locality.LOCALITY_ID,
		VERBATIM_DATE,
		VERBATIM_LOCALITY,
		COLL_EVENT_REMARKS,
		BEGAN_DATE,
		ENDED_DATE,
		verbatim_coordinates,
		collecting_event_name,
		locality.DEC_LAT,
		locality.DEC_LONG,
		collecting_event.DATUM,
		collecting_event.ORIG_LAT_LONG_UNITS,
		geog_auth_rec.GEOG_AUTH_REC_ID,
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
		higher_geog
	from
		specimen_event,
		collecting_event,
		locality,
		geog_auth_rec
	where
		specimen_event.collecting_event_id=collecting_event.collecting_event_id and
		collecting_event.locality_id=locality.locality_id and
		locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
		specimen_event.collection_object_id=<cfqueryparam value = "#collection_object_id#" CFSQLType = "CF_SQL_INTEGER">
</cfquery>

 <cfdump var=#event#>
		 
<style>
	.acceptedIdDiv {
		border:1px dotted green;
	}
	.unAcceptedIdDiv{
		border:1px dotted gray;
		background-color:#F8F8F8;
		color:gray;
		font-size:.8em;
	}
	.taxDetDiv {
		padding-left:1em;	
	}
</style>		
<cfoutput query="one">
	<cfif oneOfUs is 1>
		<form name="editStuffLinks" method="post" action="SpecimenDetail.cfm">
			<input type="hidden" name="collection_object_id" value="#one.collection_object_id#">
			<input type="hidden" name="suppressHeader" value="true">
			<input type="hidden" name="action" value="nothing">
			<input type="hidden" name="Srch" value="Part">
	</cfif>
	<table width="95%" cellpadding="0" cellspacing="0"><!---- full page table ---->
		<tr>
			<td valign="top" width="50%">
<!------------------------------------ Taxonomy ---------------------------------------------->
				<div class="detailCell">				
					<div class="detailLabel">&nbsp;
						<cfif oneOfUs is 1>
							<span class="detailEditCell" onclick="window.parent.loadEditApp('editIdentification');">Edit</span>
						</cfif>
					</div>
					<div class="detailBlock">
						<span class="detailData">
							<cfquery name="identification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
									identification.publication_id
								FROM
									identification,
									publication
								WHERE
									identification.publication_id=publication.publication_id (+) and
									identification.collection_object_id = #collection_object_id# 
								ORDER BY accepted_id_fg DESC,made_date DESC
							</cfquery>
							<cfloop query="identification">
								<cfquery name="getTaxa_r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
									select 
										taxonomy.taxon_name_id,
										display_name,
										scientific_name,
										author_text,
										common_name,
										full_taxon_name
									FROM
										identification_taxonomy,
										taxonomy,
										common_name
									WHERE
										identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id and
										taxonomy.taxon_name_id=common_name.taxon_name_id (+) and
										identification_id=#identification_id#
								</cfquery>
								<cfquery name="getTaxa" dbtype="query">
									select 
										taxon_name_id,
										display_name,
										scientific_name,
										author_text,
										full_taxon_name
									from
										getTaxa_r
									group by
										taxon_name_id,
										display_name,
										scientific_name,
										author_text,
										full_taxon_name
								</cfquery>
								<cfif accepted_id_fg is 1>
						        	<div class="acceptedIdDiv">
							    <cfelse>
						        	<div class="unAcceptedIdDiv">
						        </cfif>
						        <cfif getTaxa.recordcount is 1 and taxa_formula is 'a'>
									<a href="/name/#getTaxa.scientific_name#" target="_blank">#getTaxa.display_name#</a> 
								<cfelse>
									<cfset link="">
									<cfset i=1>
									<cfset thisSciName="#scientific_name#">
									<cfloop query="getTaxa">
										<cfset thisLink='<a href="/name/#scientific_name#" target="_blank">#display_name#</a>'>
										<cfset thisSciName=#replace(thisSciName,scientific_name,thisLink)#>
										<cfset i=#i#+1>
									</cfloop>
									#thisSciName#
								</cfif>
								<cfif not isdefined("metaDesc")>
									<cfset metaDesc="">
								</cfif>
								<div class="taxDetDiv">
									<cfloop query="getTaxa">
										<div style="font-size:.8em;color:gray;">
											#full_taxon_name#
										</div>
										<cfset metaDesc=metaDesc & '; ' & full_taxon_name>
										<cfquery name="cName" dbtype="query">
											select common_name from getTaxa_r where taxon_name_id=#taxon_name_id#
											and common_name is not null
											group by common_name order by common_name
										</cfquery>
										<div style="font-size:.8em;color:gray;padding-left:1em;">
											#valuelist(cName.common_name,"; ")#
										</div>
										<cfset metaDesc=metaDesc & '; ' & valuelist(cName.common_name,"; ")>
									</cfloop>
									<cfif len(short_citation) gt 0>
										sensu <a href="/publication/#publication_id#" target="_mainFrame">
												#short_citation#
											</a><br>
									</cfif>
									Identified by #agent_name# 
									<cfif len(made_date) gt 0>
										on #made_date#
									</cfif>									
									<br>Nature of ID: #nature_of_id#
									<cfif len(identification_remarks) gt 0>
										<br>Remarks: #identification_remarks#
									</cfif>
								</div>
							</div>
						</cfloop>
					</span>				
				</div>
			</div>
<!------------------------------------ citations ---------------------------------------------->
			<cfif len(one.typestatus) gt 0>  
				<div class="detailCell">
					<div class="detailLabel">Citations</div>
					<cfloop list="#one.typestatus#" index="x" delimiters=";">
						<div class="detailBlock">
							#x#
						</div>
					</cfloop>
				</div>
			</cfif>
<!------------------------------------ locality ---------------------------------------------->
			<div class="detailCell">
				<div class="detailLabel">
					<cfif oneOfUs is 1>
						<span class="detailEditCell" onclick="window.parent.loadEditApp('specLocality');">Edit</span>
					</cfif>
				</div>
				<cfloop query="event">
					<cfquery name="localityMedia"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select 
							media_id 
						from 
							media_relations 
						where 
							RELATED_PRIMARY_KEY=#locality_id# and
							MEDIA_RELATIONSHIP like '% locality'
					</cfquery>
					<cfquery name="collEventMedia"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select 
							media_id 
						from 
							media_relations 
						where 
							RELATED_PRIMARY_KEY=#collecting_event_id# and
							MEDIA_RELATIONSHIP like '% collecting_event'
					</cfquery>
					
		<!---------
		,
		collecting_event.COLLECTING_EVENT_ID,
    	locality.LOCALITY_ID,
		VERBATIM_DATE,
		COLL_EVENT_REMARKS,
		BEGAN_DATE,
		ENDED_DATE,
		verbatim_coordinates,
		collecting_event_name,
		locality.DEC_LAT,
		locality.DEC_LONG,
		collecting_event.DATUM,
		collecting_event.ORIG_LAT_LONG_UNITS,
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
		
		------------>
		
		
					<table id="SD_#specimen_event_id#">
						<tr class="detailData">
							<td id="SDCellLeft" class="innerDetailLabel">Determination Type</td>
							<td id="SDCellRight">
								#specimen_event_type#
								<br>assigned by #assigned_by_agent_name# on #dateformat(assigned_date,'yyyy-mm-dd')#
							</td>
						</tr>
						<tr class="detailData">
							<td id="SDCellLeft" class="innerDetailLabel">Higher Geography:</td>
							<td id="SDCellRight">#higher_geog#</td>
						</tr>
						<cfif verbatim_locality is not spec_locality>
							<cfif len(verbatim_locality) gt 0>
								<tr class="detailData">
									<td id="SDCellLeft" class="innerDetailLabel">Verbatim Locality:</td>
									<td id="SDCellRight">#verbatim_locality#
										<cfif collEventMedia.recordcount gt 0>
											<a class="infoLink" target="_blank"	href="/MediaSearch.cfm?action=search&media_id=#valuelist(collEventMedia.media_id)#">Media</a>
										</cfif>
									</td>
								</tr>
							</cfif>
						</cfif>
						<cfif len(locality_name) gt 0>
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">Locality Name:</td>
								<td id="SDCellRight">#locality_name#</td>
							</tr>
						</cfif>
						<cfif len(spec_locality) gt 0>
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">Specific Locality:</td>
								<td id="SDCellRight">
									#spec_locality#
									<cfif localityMedia.recordcount gt 0>
										<a class="infoLink" target="_blank" href="/MediaSearch.cfm?action=search&media_id=#valuelist(localityMedia.media_id)#">Media</a>
									</cfif>
								</td>
							</tr>
						</cfif>
						<cfif len(specimen_event_remark) gt 0>
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">Specimen/Event Remarks:</td>
								<td id="SDCellRight">#specimen_event_remark#</td>
							</tr>
						</cfif>
						<cfif len(habitat) gt 0>
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">Habitat:</td>
								<td id="SDCellRight">#habitat#</td>
							</tr>
						</cfif>
						
						<cfif len(collecting_method) gt 0>
							<div class="detailBlock">
								<tr class="detailData">
									<td id="SDCellLeft" class="innerDetailLabel">Collecting&nbsp;Method:</td>
									<td id="SDCellRight">#collecting_method#</td>
								</tr>
							</div>
						</cfif>
						<cfif len(collecting_source) gt 0>
							<div class="detailBlock">
								<tr class="detailData">
									<td id="SDCellLeft" class="innerDetailLabel">Collecting&nbsp;Source:</td>
									<td id="SDCellRight">#collecting_source#</td>
								</tr>
							</div>
						</cfif>
						<cfif (verbatim_date is began_date) AND (verbatim_date is ended_date)>
							<cfset thisDate = verbatim_date>
						<cfelseif (
							(verbatim_date is not began_date) OR
				 			(verbatim_date is not ended_date)
							) AND began_date is ended_date>
							<cfset thisDate = "#verbatim_date# (#began_date#)">
						<cfelse>
							<cfset thisDate = "#verbatim_date# (#began_date# - #ended_date#)">
						</cfif>
						<tr class="detailData">
							<td id="SDCellLeft" class="innerDetailLabel">Event Date:</td>
							<td id="SDCellRight">#thisDate#</td>
						</tr>
						<cfif len(VERIFICATIONSTATUS) gt 0>
							<div class="detailBlock">
								<tr class="detailData">
									<td id="SDCellLeft" class="innerDetailLabel">VERIFICATIONSTATUS:</td>
									<td id="SDCellRight">#VERIFICATIONSTATUS#</td>
								</tr>
							</div>
						</cfif>
						
						
						
						<div class="detailBlock">
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">Spatial:</td>
								<td id="SDCellRight">
									<table>
										<tr>
											<td valign="top" align="right"><!---- text stuff here ---->
												<table>
													<cfif len(verbatim_coordinates) gt 0>
														<tr>
															<td align="right">Coordinates</td>
															<td align="left">#verbatim_coordinates#</td>
														</tr>
													</cfif>
													
												</table>
											</td>
											<td valign="top" align="right"><!---- map here ---> i am map</td>
										</tr>
									</table>
								</td>
							</tr>
						</div>
						
						<!----
						
						<cfif len(one.coll_event_remarks) gt 0>
							<div class="detailBlock">
								<tr class="detailData">
									<td id="SDCellLeft" class="innerDetailLabel">Collecting&nbsp;Event&nbsp;Remark:</td>
									<td id="SDCellRight">#one.coll_event_remarks#</td>
								</tr>
							</div>
						</cfif>
					
					<cfif len(one.minimum_elevation) gt 0>
						<tr class="detailData">
							<td id="SDCellLeft" class="innerDetailLabel">Elevation:</td>
							<td id="SDCellRight">#one.minimum_elevation# to #one.maximum_elevation# #one.orig_elev_units#</td>
						</tr>
					</cfif>
					<cfif len(one.depth_units) gt 0>
						<tr class="detailData">
							<td id="SDCellLeft" class="innerDetailLabel">Depth:</td>
							<td id="SDCellRight">#one.min_depth#
								<cfif one.min_depth neq one.max_depth>to #one.max_depth# </cfif> #one.depth_units#</td>
						</tr>
					</cfif>
					<cfif (len() gt 0)>
						<tr class="detailData">
							<td id="SDCellLeft" class="innerDetailLabel">Coordinates:</td>
							<td id="SDCellRight">#verbatim_coordinates#
								<cfif len(one.datum) gt 0>
									(#one.datum#)
								</cfif>
								<cfif len(one.max_error_distance) gt 0>
									, Error: #one.max_error_distance# #one.max_error_units#
								</cfif>
							</td>
						</tr>
						<cfif len(one.assigned_by_agent_name) gt 0>
							<cfset determination = one.assigned_by_agent_name>
							<cfif len(one.latLongDeterminedDate) gt 0>
								<cfset determination = '#assigned_by_agent_name#; #dateformat(one.latLongDeterminedDate, "yyyy-mm-dd")#'>
							</cfif>
							<cfif len(one.lat_long_ref_source) gt 0>
								<cfset determination = '#determination#; #one.lat_long_ref_source#'>
							</cfif>
							<tr>
								<td></td>
								<td id="SDCellRight" class="detailCellSmall">
									#determination#
								</td>
							</tr>
						</cfif>
						<cfif len(one.lat_long_remarks) gt 0>
							<tr class="detailCellSmall">
								<td></td>
								<td class="innerDetailLabel">Coordinate Remarks:
									#one.lat_long_remarks#
								</td>
							</tr>
						</cfif>
					</cfif>
						
						
						
						
						
						
						---->
					</table>
				</cfloop>
				
				
								
					
					<!--- move this somewhere 
									
					
					
					<cfif len(one.associated_species) gt 0>
						<div class="detailBlock">
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">Associated Species:</td>
								<td id="SDCellRight">#one.associated_species#</td>
							</tr>
						</div>
					</cfif>
					
					---->
					
					<cfquery name="geology" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select * from 
						geology_attributes,
						preferred_agent_name
						where
						geology_attributes.GEO_ATT_DETERMINER_ID=preferred_agent_name.agent_id (+) and
						 locality_id=#one.locality_id#
					</cfquery>
					<cfloop query="geology">
						 <td id="SDCellLeft" class="innerDetailLabel">#GEOLOGY_ATTRIBUTE#:</td>
						 <td id="SDCellRight">
							 #GEO_ATT_VALUE#								 
						</td>
						<tr>
							<td></td>
							<td id="SDCellRight" class="detailCellSmall">
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
							</td>
						</tr>
					</cfloop>
					
				</table>
			</div>
			
<!------------------------------------ collectors ---------------------------------------------->
			<div class="detailCell">
				<div class="detailLabel">Collectors
					<cfif oneOfUs is 1>
						<span class="detailEditCell" onclick="window.parent.loadEditApp('editColls');">Edit</span>
					</cfif>
				</div>
				<cfloop query="colls">
					<div class="detailBlock">
						<span class="detailData">
							<span class="innerDetailLabel"></span>
							#collectors#
						</span>
					</div>
				</cfloop>
			</div>
<!------------------------------------ preparators ---------------------------------------------->
			<cfif len(preps.preparators) gt 0>
				<div class="detailCell">
					<div class="detailLabel">Preparators
						<cfif oneOfUs is 1>
							<span class="detailEditCell" onclick="window.parent.loadEditApp('editColls');">Edit</span>
						</cfif>
					</div>
					<cfloop query="preps">
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel"></span>
								#preparators#
							</span>
						</div>
					</cfloop>
				</div>
			</cfif>
<!------------------------------------ relationships ---------------------------------------------->
			<cfquery name="invRel" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					collection.collection,
					cat_num,
					biol_indiv_relations.collection_object_id,
					BIOL_INDIV_RELATIONSHIP
				from 
					biol_indiv_relations,cataloged_item,collection
				where 
					biol_indiv_relations.collection_object_id = cataloged_item.collection_object_id and
					cataloged_item.collection_id = collection.collection_id AND
					RELATED_COLL_OBJECT_ID = #collection_object_id#
			</cfquery>
			<cfif len(relns.biol_indiv_relationship) gt 0 OR len(invRel.biol_indiv_relationship) gt 0>
				<div class="detailCell">
					<div class="detailLabel">Relationships
						<cfif oneOfUs is 1>
							<span class="detailEditCell" onclick="window.parent.loadEditApp('editRelationship');">Edit</span>
						</cfif>
					</div>
					<cfloop query="relns">
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">#biol_indiv_relationship#</span>
								<a href="/SpecimenDetail.cfm?collection_object_id=#related_coll_object_id#" target="_top">
									#related_collection# #related_cat_num#
								</a>
							</span>
						</div>
					</cfloop>
					<cfif len(relns.biol_indiv_relationship) gt 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel"></span>
									&nbsp;&nbsp;&nbsp;<a href="/SpecimenResults.cfm?collection_object_id=#valuelist(relns.related_coll_object_id)#" target="_top">"Related To" Specimens List</a>										
							</span>
						</div>
					</cfif>
					<cfloop query="invRel">
						<cfset invReln=BIOL_INDIV_RELATIONSHIP>
						<cfif right(invReln,3) is " of">
							<cfset invReln=left(invReln,len(invReln)-3) & ' IS'>
						<cfelseif right(invReln,4) is " ate">
							<cfset invReln=left(invReln,len(invReln)-4) & ' eaten by'>
						</cfif>						
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">#invReln#</span>
								<a href="/SpecimenDetail.cfm?collection_object_id=#invRel.collection_object_id#" 
									target="_top">#invRel.collection# #invRel.cat_num#</a>
							</span>
						</div>
					</cfloop>
					<cfif len(invRel.biol_indiv_relationship) gt 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel"></span>
								&nbsp;&nbsp;&nbsp;<a href="/SpecimenResults.cfm?collection_object_id=#valuelist(invRel.collection_object_id)#" target="_top">"Related IS" Specimens List</a>
							</span>
						</div>
					</cfif>
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
			SELECT loan_item.collection_object_id FROM
			loan_item,specimen_part
			WHERE loan_item.collection_object_id=specimen_part.collection_object_id AND
			specimen_part.derived_from_cat_item=#one.collection_object_id#
		</cfquery>
		</td>
		<td valign="top" width="50%">
	<!------------------------------------ identifiers ---------------------------------------------->
			<cfquery name="oid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				SELECT 
					case when #oneOfUs# != 1 and 
						concatencumbrances(coll_obj_other_id_num.collection_object_id) like '%mask original field number%' and
						coll_obj_other_id_num.other_id_type = 'original identifier'				
						then 'Masked'
					else
						coll_obj_other_id_num.display_value  
					end display_value,
					coll_obj_other_id_num.other_id_type,
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
				ORDER BY
					other_id_type,
					display_value
			</cfquery>
			<cfif len(oid.other_id_type) gt 0>
				<div class="detailCell">
					<div class="detailLabel">Identifiers
						<cfif oneOfUs is 1>
							<span class="detailEditCell" onclick="window.parent.loadEditApp('editIdentifiers');">Edit</span>
						</cfif>						
					</div>
					<cfloop query="oid">
						<div class="detailBlock">
							<span class="innerDetailLabel">#other_id_type#:</span>
								<cfif len(link) gt 0>
									<a class="external" href="#link#" target="_blank">#display_value#</a>
								<cfelse>
									#display_value#
								</cfif>
							</span>
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
<!-------
<cfquery name="pAtt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select
						 part_attribute_id,
						 ,
						 ,
						 ,
						 ,
						 ,
						 ,
						 
					from
						,
						
					where
						specimen_part_attribute.determined_by_agent_id=preferred_agent_name.agent_id (+) and
						collection_object_id=#partID#
				</cfquery>
				<tr bgcolor="#bgc#">
					<td colspan="8" align="center">
						<cfif pAtt.recordcount gt 0>
						<table border>
							<tr>
								<th>Attribute</th>
								<th>Value</th>
								<th>Units</th>
								<th>Date</th>
								<th>DeterminedBy</th>
								<th>Remark</th>
							</tr>
							<cfloop query="pAtt">
								<tr>
									<td>#attribute_type#</td>
									<td>
										#attribute_value#&nbsp;
									</td>
									<td>
										#attribute_units#&nbsp;
									</td>
									<td>
										#dateformat(determined_date,"yyyy-mm-dd")#&nbsp;
									</td>
									<td>
										#agent_name#&nbsp;
									</td>
									<td>
										#attribute_remark#&nbsp;
									</td>
								</tr>
							</cfloop>
						</td>
					</table>
					<cfelse>
						--no attributes--
					</cfif>
					
					
					
					
					
					
					
					
					
					
				---------->	
					
					
					
<cfquery name="mPart" dbtype="query">
	select * from parts where sampled_from_obj_id is null order by part_name
</cfquery>
			<div class="detailCell">
				<div class="detailLabel">&nbsp;<!---Parts--->
					<cfif oneOfUs is 1>
						<span class="detailEditCell" onclick="window.parent.loadEditApp('editParts');">Edit</span>
					<cfelse>
						<span class="detailEditCell" onClick="getInfo('parts','#one.collection_object_id#');">Details</span>
					</cfif>
				</div>
				<div class="detailBlock">
					<span class="detailData">
						<table border>
							<tr>
								<th><span class="innerDetailLabel">Part Name</span></th>
								<th><span class="innerDetailLabel">Condition</span></th>
								<th><span class="innerDetailLabel">Disposition</span></th>
								<th><span class="innerDetailLabel">##</span></th>
								<th><span class="innerDetailLabel">Label</span></th>
								<th><span class="innerDetailLabel">Remarks</span></th>
							</tr>
							<cfloop query="mPart">
								<tr>
									<td>
										#part_name#
									</td>
									<td>#part_condition#</td>
									<td>#part_disposition#</td>
									<td>#lot_count#</td>
									<td>#label#</td>
									<td>#part_remarks#</td>
								</tr>
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
								</cfquery>
								<cfif patt.recordcount gt 0>
									<tr>
										<td colspan="6">
											<cfloop query="patt">
												<div style="margin-left:1em;" class="detailCellSmall">
													<strong>#attribute_type#</strong>=<strong>#attribute_value#</strong>
													<cfif len(attribute_units) gt 0>
													 	<strong>#attribute_units#</strong>
													</cfif>
													<cfif len(determined_date) gt 0>
													 	determined date=<strong>#determined_date#</strong>
													</cfif>
													<cfif len(agent_name) gt 0>
													 	determined by=<strong>#agent_name#</strong>
													</cfif>
													<cfif len(attribute_remark) gt 0>
													 	remark=<strong>#attribute_remark#</strong>
													</cfif>
											
												</div>
											</cfloop>
										</td>
									</tr>
								</cfif>
	
	
	
								
								<cfquery name="sPart" dbtype="query">
									select * from parts where sampled_from_obj_id=#part_id#
								</cfquery>
								<cfloop query="sPart">
									<tr>
										<td>
											&nbsp;&nbsp;&nbsp;#part_name#
										</td>
										<td>#part_condition#</td>
										<td>#part_disposition#</td>
										<td>#lot_count#</td>
										<td>#label#</td>
										<td>#part_remarks#</td>
									</tr>
								</cfloop>
							</cfloop>
						</table>
					</span>
				</div>
			</div>

<!------------------------------------ attributes ---------------------------------------------->
			<cfif len(attribute.attribute_type) gt 0>
				<div class="detailCell">
					<div class="detailLabel"><!---Attributes--->
						<cfif oneOfUs is 1>
							<span class="detailEditCell" onclick="window.parent.loadEditApp('editBiolIndiv');">Edit</span>
						</cfif>
					</div>
					<cfquery name="sex" dbtype="query">
						select * from attribute where attribute_type = 'sex'
					</cfquery>
					<div class="detailBlock">
						<cfloop query="sex">
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">sex:</span>
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
												<span class="innerDetailLabel">Remark:</span>
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
								len(weight.attribute_units) gt 0><!---semi-standard measurements --->
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">Std. Meas.</span>
									<table border width="100%">
										<tr>
											<td><font size="-1">total length</font></td>
											<td><font size="-1">tail length</font></td>
											<td><font size="-1">hind foot</font></td>
											<td><font size="-1">efn</font></td>
											<td><font size="-1">weight</font></td>
										</tr>
										<tr>
											<td>#total_length.attribute_value# #total_length.attribute_units#&nbsp;</td>
											<td>#tail_length.attribute_value# #tail_length.attribute_units#&nbsp;</td>
											<td>#hf.attribute_value# #hf.attribute_units#&nbsp;</td>
											<td>#efn.attribute_value# #efn.attribute_units#&nbsp;</td>
											<td>#weight.attribute_value# #weight.attribute_units#&nbsp;</td>
										</tr>
									</table>
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
								<span class="innerDetailLabel">#attribute_type#:</span>
								#attribute_value# 
								<cfif len(attribute_units) gt 0>
									#attribute_units#
								</cfif>
								<cfif len(attributeDeterminer) gt 0>
									<cfset determination = "&nbsp;&nbsp;#attributeDeterminer#">
									<cfif len(determined_date) gt 0>
										<cfset determination = '#determination#, #determined_date#'>
									</cfif>
									<cfif len(determination_method) gt 0>,
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
											&nbsp;&nbsp;<span class="innerDetailLabel">Remark:</span>
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
						<span class="detailEditCell" onclick="window.parent.loadEditApp('editBiolIndiv');">Edit</span>
					</cfif>
					</div>	
					<cfif len(one.coll_object_remarks) gt 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Remarks:</span>
								#one.coll_object_remarks#
							</span>
						</div>
					</cfif>
					
					<cfif len(one.habitat) gt 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Microhabitat:</span>
								#one.habitat#
							</span>
						</div>
					</cfif>
					<cfif oneOfUs is 1>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Entered By:</span>
								#one.EnteredBy# on #dateformat(one.coll_object_entered_date,"yyyy-mm-dd")#
							</span>
						</div>
						<cfif #one.EditedBy# is not "unknown" OR len(one.last_edit_date) is not 0>
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">Last Edited By:</span>
									#one.EditedBy# on #dateformat(one.last_edit_date,"yyyy-mm-dd")#
								</span>
							</div>
						</cfif>
						<cfif len(#one.flags#) is not 0>
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">Missing (flags):</span>
									#one.flags#
								</span>
							</div>
						</cfif>
						<cfif len(#one.encumbranceDetail#) is not 0>
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">Encumbrances:</span>
									#replace(one.encumbranceDetail,";","<br>","all")#
								</span>
							</div>
						</cfif>
					</cfif>
				</div>
<!------------------------------------ accession ---------------------------------------------->
			<cfquery name="accnMedia" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			    select 
			        media.media_id,
			        media.media_uri,
			        media.mime_type,
			        media.media_type,
			        media.preview_uri,
			        label_value descr
			     from
			        media,
					media_relations,
					(select media_id,label_value from media_labels where media_label='description') media_labels
			     where
			        media.media_id=media_relations.media_id and
			        media.media_id=media_labels.media_id (+) and
					media_relations.media_relationship like '% accn' and
					media_relations.related_primary_key=#one.accn_id#
			</cfquery>
			<div class="detailCell">
				<div class="detailLabel">Accession
					<cfif oneOfUs is 1>
						<span class="detailEditCell" onclick="window.parent.loadEditApp('addAccn');">Edit</span>
					</cfif>
				</div>
				<div class="detailBlock">
					<span class="detailData">
						<cfif oneOfUs is 1>
							<a href="/editAccn.cfm?Action=edit&transaction_id=#one.accn_id#" target="_blank">#accession#</a>
						<cfelse>
							<a href="/viewAccn.cfm?transaction_id=#one.accn_id#" target="_blank">#accession#</a>
						</cfif>
						<cfif accnMedia.recordcount gt 0>
							<div class="thumbs">
								<div class="thumb_spcr">&nbsp;</div>
								<cfloop query="accnMedia">
									<div class="one_thumb">
						            	<a href="#media_uri#" target="_blank">
							               <img src="#getMediaPreview(preview_uri,media_type)#" alt="#descr#" class="theThumb">
										</a>
					                   	<p>
											#media_type# (#mime_type#)
						                   	<br><a href="/media/#media_id#" target="_blank">Media Details</a>
											<br>#descr#
										</p>
									</div>
								</cfloop>
								<div class="thumb_spcr">&nbsp;</div>
							</div>
						</cfif>
					</span>
				</div>
			</div>		
<!------------------------------------ usage ---------------------------------------------->
		<cfif isProj.recordcount gt 0 OR isLoan.recordcount gt 0 or (oneOfUs is 1 and isLoanedItem.collection_object_id gt 0)>
			<div class="detailCell">
				<div class="detailLabel">Usage</div>
					<cfloop query="isProj">
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Contributed By Project:</span>
									<a href="/ProjectDetail.cfm?src=proj&project_id=#isProj.project_id#">#isProj.project_name#</a>
							</span>
						</div>
					</cfloop>
					<cfloop query="isLoan">
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Used By Project:</span>
		 						<a href="/ProjectDetail.cfm?src=proj&project_id=#isLoan.project_id#" target="_mainFrame">#isLoan.project_name#</a>
							</span>
						</div>
					</cfloop>
					<cfif isLoanedItem.collection_object_id gt 0 and oneOfUs is 1>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Loan History:</span>
									<a href="/Loan.cfm?action=listLoans&collection_object_id=#valuelist(isLoanedItem.collection_object_id)#" 
										target="_mainFrame">Click for loan list</a>
							</span>
						</div>
					</cfif>
				</div>
		</cfif>
<!------------------------------------ Media ---------------------------------------------->
<cfquery name="mediaTag" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
    select distinct 
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
		<div class="detailLabel">Tagged in Media
		</div>
		<div class="detailBlock">
			<cfloop query="mediaTag">
				<cfset puri=getMediaPreview(preview_uri,media_type)>
				 <span class="detailData">			
					<a href="/showTAG.cfm?media_id=#media_id#" target="_blank"><img src="#puri#"></a>
		        </span>	
			</cfloop>
		</div>
	</div>	
</cfif>
<cfquery name="media" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
    select distinct 
        media.media_id,
        media.media_uri,
        media.mime_type,
        media.media_type,
        media.preview_uri
     from
         media,
         media_relations,
         media_labels
     where
         media.media_id=media_relations.media_id and
         media.media_id=media_labels.media_id (+) and
         media_relations.media_relationship like '%cataloged_item' and
         media_relations.related_primary_key = #collection_object_id#
</cfquery>
<cfif media.recordcount gt 0>
    <div class="detailCell">
		<div class="detailLabel">Media
			<cfif oneOfUs is 1>
				 <cfquery name="hasConfirmedImageAttr"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					SELECT count(*) c
					FROM
						ctattribute_type 
					where attribute_type='image confirmed' and
					collection_cde='#one.collection_cde#'
				</cfquery>
				<span class="detailEditCell" onclick="window.parent.loadEditApp('MediaSearch');">Edit</span>
				<cfquery name="isConf"  dbtype="query">
					SELECT count(*) c
					FROM
						attribute 
					where attribute_type='image confirmed'
				</cfquery>
				<CFIF isConf.c is "" and hasConfirmedImageAttr.c gt 0>
					<span class="infoLink" 
						id="ala_image_confirm" onclick='windowOpener("/ALA_Imaging/confirmImage.cfm?collection_object_id=#collection_object_id#","alaWin","width=700,height=400, resizable,scrollbars,location,toolbar");'>
						Confirm Image IDs
					</span> 
				</CFIF>
			</cfif>
		</div>
		<div class="detailBlock">
            <span class="detailData">			
				<div class="thumbs">
					<div class="thumb_spcr">&nbsp;</div>
					<cfloop query="media">
						<cfset puri=getMediaPreview(preview_uri,media_type)>
		            	<cfquery name="labels"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							select
								media_label,
								label_value
							from
								media_labels
							where
								media_id=#media_id#
						</cfquery>
						<cfquery name="desc" dbtype="query">
							select label_value from labels where media_label='description'
						</cfquery>
						<cfset alt="Media Preview Image">
						<cfif desc.recordcount is 1>
							<cfset alt=desc.label_value>
						</cfif>
		               <div class="one_thumb">
			               <a href="#media_uri#" target="_blank"><img src="#getMediaPreview(preview_uri,media_type)#" alt="#alt#" class="theThumb"></a>
		                   	<p>
								#media_type# (#mime_type#)
			                   	<br><a href="/media/#media_id#" target="_blank">Media Details</a>
								<br>#alt#
							</p>
						</div>
					</cfloop>
					<div class="thumb_spcr">&nbsp;</div>
				</div>
	        </span>		
		</div>
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
						#replace(ocr.label,chr(10),'<br>','all')#
			        </span>
				</div>
			</cfif>
		</cfloop>
	</div>		
</cfif>
	</td><!--- end right half of table --->
</table>
<cfif oneOfUs is 1>
</form>
</cfif>
</cfoutput> 	
<cf_customizeIFrame>