<cfquery datasource="#Application.web_user#" name="data">
	SELECT DISTINCT
		collection.institution_acronym,
		cataloged_item.cat_num,
		cataloged_item.collection_object_id as collection_object_id,
		cataloged_item.collection_cde,
		identification.scientific_name,
		continent_ocean,
		country,
		state_prov,
		quad,
		county,
		island,
		island_group,
		minimum_elevation,
		maximum_elevation,
		orig_elev_units,
		spec_locality,
		coll_object_remarks,
		verbatim_date,
		BEGAN_DATE,
		ended_date,
		sea,
		feature,
		CONCATPREP(cataloged_item.collection_object_id) preparator,
		ConcatColl(cataloged_item.collection_object_id) collector,
		ConcatSingleOtherId(cataloged_item.collection_object_id,'original field number') field_num,
		ConcatSingleOtherId(cataloged_item.collection_object_id,'NK Number') nk_number,
	 	ConcatAttributeValue(cataloged_item.collection_object_id,'sex') sex,
	 	ConcatAttributeValue(cataloged_item.collection_object_id,'verbatim preservation date') prepdate,
 	 	concatpartsdetail(cataloged_item.collection_object_id) parts,
		biol_indiv_relationship as relationship, 
		related_cat_item.cat_num as related_cat_num,
		related_cat_item.collection_cde as related_collection_cde,
		attribute_type,
		attribute_value,
		attribute_units,
		attribute_remark,
		decode(orig_lat_long_units,
				'decimal degrees',to_char(dec_lat) || '&deg; ',
				'deg. min. sec.', to_char(lat_deg) || '&deg; ' || to_char(lat_min) || '&acute; ' || to_char(lat_sec) || '&acute;&acute; ' || lat_dir,
				'degrees dec. minutes', to_char(lat_deg) || '&deg; ' || to_char(dec_lat_min) || '&acute; ' || lat_dir
			)  VerbatimLatitude,
			decode(orig_lat_long_units,
				'decimal degrees',to_char(dec_long) || '&deg;',
				'deg. min. sec.', to_char(long_deg) || '&deg; ' || to_char(long_min) || '&acute; ' || to_char(long_sec) || '&acute;&acute; ' || long_dir,
				'degrees dec. minutes', to_char(long_deg) || '&deg; ' || to_char(dec_long_min) || '&acute; ' || long_dir
			)  VerbatimLongitude,
		max_error_distance,
		max_error_units,
		trans.INSTITUTION_ACRONYM || ' ' || 
			accn_number
			AS accession,
		lat_long_ref_source,
		datum,
		lat_long_remarks
	FROM 
		cataloged_item,
		collection,		
		identification,
		collecting_event,
		locality,
		geog_auth_rec,
		accepted_lat_long,
		coll_object_remark,
		biol_indiv_relations,
		cataloged_item related_cat_item,
		attributes,
		accn,
		trans
	WHERE 
		cataloged_item.collection_id = collection.collection_id AND
		cataloged_item.collection_object_id = identification.collection_object_id AND
		identification.accepted_id_fg = 1 AND
		Cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		collecting_event.locality_id = locality.locality_id  AND		
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		locality.locality_id = accepted_lat_long.locality_id (+) AND
		cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+) AND
		cataloged_item.collection_object_id = biol_indiv_relations.collection_object_id (+) AND
		biol_indiv_relations.related_coll_object_id = related_cat_item.collection_object_id (+) AND
		cataloged_item.collection_object_id=attributes.collection_object_id (+) AND
		cataloged_item.accn_id =  accn.transaction_id  AND
		accn.transaction_id = trans.transaction_id AND
		cataloged_item.collection_object_id  IN (#collection_object_id#)		
</cfquery>
<cfoutput >

<cfdocument 
	format="pdf"
	pagetype="custom"
	pagewidth="6" 
	pageheight="10" 
	unit="in"
	orientation="portrait"
	fontembed="yes" marginleft=".1" marginright=".5" marginbottom=".25" margintop=".5" >	

	
<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">
<cfloop query="data">
<cfquery name="attributes" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from attributes where collection_object_id=#collection_object_id#
</cfquery>
<cfset meas = "total-tail-hindfoot-ear&equiv;weight">
<cfloop query="attributes">
	<cfif #attribute_units# is 'mm' OR #attribute_units# is 'g'>
		<cfset u=''>
	<cfelse>
		<cfset u=' #attribute_units#'>
	</cfif>
	<cfif #attribute_type# is "tail length">
		<cfset meas = replace(meas,"tail",#attribute_value#,"all")>
	<cfelseif  #attribute_type# is "total length">
		<cfset meas = replace(meas,"total",#attribute_value#,"all")>
	<cfelseif  #attribute_type# is "hind foot with claw">
		<cfset meas = replace(meas,"hindfoot",#attribute_value#,"all")>
	<cfelseif  #attribute_type# is "ear from notch">
		<cfset meas = replace(meas,"ear",#attribute_value#,"all")>
	<cfelseif  #attribute_type# is "weight">
		<cfset meas = replace(meas,"weight",#attribute_value#,"all")>
	</cfif>
</cfloop>
<cfset meas = replace(meas,"tail","X","all")>
<cfset meas = replace(meas,"total","X","all")>
<cfset meas = replace(meas,"hindfoot","X","all")>
<cfset meas = replace(meas,"ear","X","all")>
<cfset meas = replace(meas,"weight","X","all")>

<table width="95%" height="95%">
	<tr>
		<td>
			<div style="font-size:.9em;color:darkgray;">
				<span style="float:left;">
					MSB #cat_num#
				</span>
				<span style="float:right;">
					NK #nk_number#
				</span>
			</div>
		</td>
	</tr>
	<tr>
		<td>
			<div align="center" style="font-size:1.3em;font-weight:bold;">
				Museum of Southwestern Biology<br>      
			    Biological Materials Datasheet<br>
				University of New Mexico<br>
			</div>
		</td>
	</tr>
	<tr>
		<td>
			<table class="iTable">
				<tr>
					<td class="lbl">
						Collector:
					</td>
					<td>
						<div class="dataDiv">
							#collector#
						</div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table class="iTable">
				<tr>
					<td width="60%">
						<table class="iTable">
							<tr>
								<td class="lbl">
									Preparator:
								</td>
								<td>
									<div class="dataDiv">
										#preparator#&nbsp;
									</div>
								</td>
							</tr>
						</table>
					</td>
					<td width="40%">
						<table class="iTable">
							<tr>
								<td class="lbl">
									Field&nbsp;##:
								</td>
								<td>
									<div class="dataDiv">
										#field_num#&nbsp;
									</div>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table class="iTable">
				<tr>
					<td width="80%">
						<table class="iTable">
							<tr>
								<td class="lbl">
									Species:
								</td>
								<td>
									<div class="dataDiv">
										#scientific_name#
									</div>
								</td>
							</tr>
						</table>
					</td>
					<td width="20%">
						<table class="iTable">
							<tr>
								<td class="lbl">
									Sex:
								</td>
								<td>
									<div class="dataDiv">
										<cfif #sex# is "male">
											M
										<cfelseif #sex# is "female">
											F
										<cfelse>
											?
										</cfif>
									</div>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	
	
	<tr>
		<td>
			<table class="iTable">
				<tr>
					<td width="60%">
						<table class="iTable">
							<tr>
								<td class="lbl">
									Country/State:
								</td>
								<td>
									<div class="dataDiv">
										#country#,&nbsp;#state_prov#
									</div>
								</td>
							</tr>
						</table>
					</td>
					<td width="40%">
						<table class="iTable">
							<tr>
								<td class="lbl">
									County:
								</td>
								<td>
									<div class="dataDiv">
										#county#
									</div>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table class="iTable">
				<tr>
					<td class="lbl">
						District<span style="font-size:.8em;">&nbsp;(e.g.&nbsp;island,&nbsp;Nat'l&nbsp;Park)</span>:
					</td>
					<td>
						<div class="dataDiv">
							#feature#&nbsp;
						</div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table class="iTable">
				<tr>
					<td class="lbl">
						Specific&nbsp;Locality:
					</td>
					<td>
						<div class="dataDiv">
							#spec_locality#&nbsp;
						</div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	
	
	<tr>
		<td>
			<table class="iTable">
				<tr>
					<td width="40%">
						<table class="iTable">
							<tr>
								<td class="lbl">
									Latitude:
								</td>
								<td>
									<div class="dataDiv">
										#verbatimlatitude#
									</div>
								</td>
							</tr>
						</table>
					</td>
					<td width="40%">
						<table class="iTable">
							<tr>
								<td class="lbl">
									Longitude:
								</td>
								<td>
									<div class="dataDiv">
										#verbatimlongitude#
									</div>
								</td>
							</tr>
						</table>
					</td>
					<td width="20%">
						<table class="iTable">
							<tr>
								<td class="lbl">
									Elevation:
								</td>
								<td>
									<div class="dataDiv">
										<cfif len(#orig_elev_units#) gt 0>
											#minimum_elevation#-#maximum_elevation#&nbsp;#orig_elev_units#
										</cfif>&nbsp;
									</div>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	
	<tr>
		<td>
			<table class="iTable">
				<tr>
					<td width="40%">
						<table class="iTable">
							<tr>
								<td class="lbl">
									Authority:
								</td>
								<td>
									<div class="dataDiv">
										#lat_long_ref_source#&nbsp;
									</div>
								</td>
							</tr>
						</table>
					</td>
					<td width="40%">
						<table class="iTable">
							<tr>
								<td class="lbl">
									Datum:
								</td>
								<td>
									<div class="dataDiv">
										#datum#&nbsp;
									</div>
								</td>
							</tr>
						</table>
					</td>
					<td width="20%">
						<table class="iTable">
							<tr>
								<td class="lbl">
									Max&nbsp;Error<span style="font-size:.8em;">&nbsp;(with&nbsp;units)</span>:
								</td>
								<td>
									<div class="dataDiv">
										#max_error_distance#&nbsp;#max_error_units#&nbsp;
									</div>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table class="iTable">
				<tr>
					<td width="50%">
						<table class="iTable">
							<tr>
								<td class="lbl">
									Date&nbsp;of&nbsp;death/collection:
								</td>
								<td>
									<div class="dataDiv">
										#verbatim_date#&nbsp;
									</div>
								</td>
							</tr>
						</table>
					</td>
					<td width="50%">
						<table class="iTable">
							<tr>
								<td class="lbl">
									Preparation:
								</td>
								<td>
									<div class="dataDiv">
										#prepdate#&nbsp;
									</div>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	
	<tr>
		<td>
			<table class="iTable">
				<tr>
					<td class="lbl">
						Nature&nbsp;of&nbsp;voucher:
					</td>
					<td>
						<div class="dataDiv">
							#parts#
						</div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table class="iTable">
				<tr>
					<td width="60%">
						<table class="iTable">
							<tr>
								<td class="lbl">
									Relationship:
								</td>
								<td>
									<div class="dataDiv">
										#relationship#&nbsp;
									</div>
								</td>
							</tr>
						</table>
					</td>
					<td width="40%">
						<table class="iTable">
							<tr>
								<td class="lbl">
									of:
								</td>
								<td>
									<div class="dataDiv">
										#related_collection_cde#&nbsp;#related_cat_num#
									</div>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table class="iTable">
				<tr>
					<td class="lbl">
						Measurements<span style="font-size:.8em;">&nbsp;(total-tail-hindfoot-ear&equiv;weight)</span>:
					</td>
					<td>
						<div class="dataDiv">
							#meas#
						</div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table class="iTable">
				<tr>
					<td class="lbl">
						Remarks:
					</td>
					<td>
						<div class="dataDiv">
							#coll_object_remarks#
						</div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table class="iTable">
				<tr>
					<td width="50%">
						<table class="iTable">
							<tr>
								<td class="lbl">
									Special&nbsp;##:
								</td>
								<td>
									<div class="dataDiv">
										&nbsp;
									</div>
								</td>
							</tr>
						</table>
					</td>
					<td width="50%">
						<table class="iTable">
							<tr>
								<td class="lbl">
									Accn##:
								</td>
								<td>
									<div class="dataDiv">
										#accession#
									</div>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td colspan="2" style="font-size:.75em;">
			PERMANENT ARCHIVAL RECORD: Please use permanent black ink and return to: Division of Genomic 
			Resources, Department of Biological Sciences, MSC03 2020, University of New Mexico,
			 Albuquerque NM, 87131. www.msb.unm.edu
		</td>
	</tr>
</table>


<cfdocumentitem type="pagebreak"></cfdocumentitem>

</cfloop>

</cfdocument>

</cfoutput>


