
<cfset mcat="#Application.uam_dbo#"> <!--- a read/write user talking to the database --->


<cfinclude template="BulkloaderCheck.cfm">
<!---
<!---- declare local variables - only deal with the things that we have to format for this app ---->
	<cfset catnum="">
	<cfset loadedMsg="">
	<cfset geogauthrecid="">
	<cfset taxonnameid="">
	<cfset idmadebyagentid="">
	<cfset transactionid="">
	<cfset enteredbyid="">
	<cfset collectionid="">
	<cfset identificationid="">
	<cfset catcollid="">
	<cfset attributeid="">
	<cfset entereddate=#dateformat(now(),"dd-mmm-yyyy")#>
	
	<!---- set up variable to change the number of dynamic things we handle ---->
	<cfset numberOfParts=12>
	<cfset numberOfAttributes=10>
	<cfset numberOfOtherIds=5>
	<cfset numberOfCollectors=8>
	
	<cfparam name="useExistingLocality" default="false">
	
		
<cfoutput query="oneRecord"><!--- leave this query open for the whole load process --->

	 		<!--- make sure everything in that record is good to load - 
				check that required fields are present, code table values are matched, etc. 
				Replace nulls with "" and such so we have stuff to feed to Arctos. 
				find existing values that we can load against. 
				Required: taxonomy, higher geography, agents.
			--->
			<!--- check for collection cde early as we use it often when validating ---->
			<cfif len(#collection_object_id#) is 0>
				<cfset loadedMsg = "Collection Object ID is required.">
			</cfif>
			
			<cfif len(#collection_cde#) is 0>
				<cfset loadedMsg = "#loadedMsg#; Collection code is required">
			</cfif>
			<cfquery name="coll" datasource="#mcat#">
				select * from ctcollection_cde where collection_cde = '#collection_cde#'
			</cfquery>
			<cfif coll.recordcount is 0>
				<cfset loadedMsg = "#loadedMsg#; Collection cde must match code table values.">
			</cfif>

			<!---- 2/25/2004 addition - use institution acronym to handle STAMP data --->
			<cfif len(#institution_acronym#) is 0>
				<cfset loadedMsg = "#loadedMsg#; Institution Acronym is required.">
			<cfelse>
				<cfquery name="getCollId" datasource="#mcat#">
					select collection_id from collection where
					institution_acronym = '#institution_acronym#' and
					collection_cde='#collection_cde#'
				</cfquery>
				<cfif getCollId.recordcount is not 1>
					<cfset loadedMsg = "#loadedMsg#; Institution Acronym (#institution_acronym#) and 
						collection code (#collection_cde#) do not resolve to a valid collection ID.">
				</cfif>
					<cfset collection_id = #getCollId.collection_id#>
			</cfif>
			
			
			<!--- 
				See if they've preassigned a cat_num. If they have, make sure it is valid. If not, 
				go find the next available cat_num and use it
			--->
			<cfif len(#cat_num#) gt 0>
				<cfif not isnumeric(#cat_num#)>
					<cfset loadedMsg = "#loadedMsg#; Cat number must be numeric.">
				</cfif>
				<cfif #cat_num# is 0>
					<cfset loadedMsg = "#loadedMsg#; Cat number may not be 0. Did you mean NULL?">
				</cfif>
				<!--- they've preassigned a cat num, see if it's already used--->
				<cfquery name="isValidCatNum" datasource="#mcat#">
					select collection_object_id from cataloged_item
					where cat_num=#cat_num#
					AND collection_id = 
					#collection_id#
				</cfquery>
				<cfif #isValidCatNum.recordcount# is 0>
					<cfset catnum = #cat_num#>
				<cfelse>
					<cfset loadedMsg = "#loadedMsg#; Duplicate cat number found in database!">
				</cfif>
				
			<cfelse>
				<!--- get a new cat_num --->
				<cfquery name="newCatNum" datasource="#mcat#">
					SELECT max(cat_num) + 1 AS nextcatnum 
					FROM cataloged_item WHERE collection_id = 
					#collection_id#
				</cfquery>
				<cfif len(#newCatNum.nextcatnum#) gt 0><!--- got a cat num --->
					<cfset catnum = #newCatNum.nextcatnum#>
				</cfif>
				<cfif len(#newCatNum.nextcatnum#) is 0><!--- new collection, start at 1 --->
					<cfset catnum = 1>
				</cfif>
			</cfif>
				
			
			<cfif not len(#began_date#) is 0>
				<cfif not isdate(#began_date#)>
					<cfset loadedMsg = "#loadedMsg#; Began date must be a date.">
				</cfif>
			<cfelse>
				<cfset loadedMsg = "#loadedMsg#; Began date is required.">
			</cfif>
			
			<cfif not len(#ended_date#) is 0>
				<cfif not isdate(#ended_date#)>
					<cfset loadedMsg = "#loadedMsg#; Ended date must be a date.">
				</cfif>
			<cfelse>
				<cfset loadedMsg = "#loadedMsg#; Ended date is required."></cfif>
			
			<cfif len(#verbatim_date#) is 0>
				<cfset loadedMsg = "#loadedMsg#; Verbatim date is required.">
			</cfif>
			<!--- handle relationships - at this stage, just put them in a temp table on Arctos
				where we can eventually move them over to real tables --->
			<cfif len(#relationship#) gt 0>
				<cfif len(#related_to_num_type#) is 0 or len(#related_to_number#) is 0>
					<cfset loadedMsg = "#loadedMsg#; 
						related_to_number and related_to_num_type are required when relationship is given.">
				</cfif>
				<cfquery name="isGoodReln" datasource="#mcat#">
					select biol_indiv_relationship from ctbiol_relations where
					biol_indiv_relationship ='#relationship#'
				</cfquery>
				<cfif len(#isGoodReln.biol_indiv_relationship#) is 0>
					<cfset loadedMsg = "#loadedMsg#; #relationship# is not a valid relationship.">
				</cfif>
				<cfquery name="isGoodRelOID" datasource="#mcat#">
					select other_id_type from ctcoll_other_id_type
					where collection_cde='#collection_cde#' and
					other_id_type='#related_to_num_type#'
				</cfquery>
				<cfif len(#isGoodRelOID.other_id_type#) is 0>
					<cfset loadedMsg = "#loadedMsg#; #related_to_num_type# is not a valid ID type and cannot be in a relationship.">
				</cfif>
			</cfif>
			<!--- 
				There must be one and only one preexisting higher_geog match
			--->
			<cfquery name= "getGeog" datasource="#mcat#">
				SELECT geog_auth_rec_id FROM geog_auth_rec WHERE higher_geog = '#higher_geog#'
			</cfquery>
			<cfif getGeog.recordcount gt 1>
				<cfset loadedMsg = "#loadedMsg#; There are multiple higher geography matches for #higher_geog#.">
			  <cfelseif getGeog.recordcount is 0>
					<cfset loadedMsg = "#loadedMsg#; There are no higher geography matches for #higher_geog#.">
			</cfif>
					<cfset geogauthrecid = getGeog.geog_auth_rec_id>
			<cfif len(#locality_id#) is 0>
				
				<!--- proceed with normal locality routine --->
				<cfif len(#maximum_elevation#) gt 0>
					<cfif not isnumeric(#maximum_elevation#)>
						<cfset loadedMsg = "#loadedMsg#; Maximum_elevation must be a number.">
					</cfif>
				</cfif>
				<cfif len(#minimum_elevation#) gt 0>
					<cfif not isnumeric(#minimum_elevation#)>
						<cfset loadedMsg = "#loadedMsg#; Minimum_elevation  must be a number.">
					</cfif>
				</cfif>
				<cfif len(#maximum_elevation#) gt 0 AND len(#minimum_elevation#) gt 0>
					<cfif #minimum_elevation# gt #maximum_elevation#>
						<cfset loadedMsg = "#loadedMsg#; Minimum Elevation cannot be greater than Maximum Elevation">
					</cfif>
				</cfif>
				<!--- elevation units are required if min or max is used, and not allowed if not. --->
				<cfif len(#minimum_elevation#) is not 0 OR len(#maximum_elevation#) is not 0>
					<cfif len(#orig_elev_units#) is 0>
						<cfset loadedMsg = "#loadedMsg#; Elevation units must be specified if elevation is given.">
					</cfif>
					<cfquery name="valElevUnits" datasource="#mcat#">
						SELECT * from ctorig_elev_units where orig_elev_units = '#orig_elev_units#'
					</cfquery>
					<cfif valElevUnits.recordcount eq 0>
						<cfset loadedMsg = "#loadedMsg#; Elevation units must match code table values.">
					</cfif>
				</cfif>
				<cfif len(#spec_locality#) is 0>
					<cfset loadedMsg = "#loadedMsg#; Specific locality is required.">
				</cfif>
				<!--- See if they put any lat/long stuff in. Some things are conditionally required. --->
			<cfif len(#orig_lat_long_units#) gt 0>
				<cfquery name="valOrigLatLong" datasource="#mcat#">
					select * from ctlat_long_units where orig_lat_long_units='#orig_lat_long_units#'
				</cfquery>
				<cfif valOrigLatLong.recordcount is 0>
					<cfset loadedMsg = "#loadedMsg#; Lat long units do not match code table values.">
				</cfif>
				
				<!--- first get format-specific lat/long stuff ---->
				<cfif #orig_lat_long_units# IS "decimal degrees">
					<cfif (len(#dec_lat#) is 0) OR (not isnumeric(#dec_lat#))>
						<cfset loadedMsg = "#loadedMsg#;  Dec Lat is required and must be numeric 
							when orig lat long units is decimal degrees.">
					</cfif>
					<cfif #dec_lat# lt -90 OR #dec_lat# gt 90>
						<cfset loadedMsg = "#loadedMsg#;  Dec Lat must be between -90 and 90">
					</cfif>
					<cfif (len(#dec_long#) is 0) OR (not isnumeric(#dec_long#))>
						<cfset loadedMsg = "#loadedMsg#;  Dec Long is required and must be numeric 
							when orig lat long units is decimal degrees.">
					</cfif>
					<cfif #dec_long# lt -180 OR #dec_long# gt 180>
						<cfset loadedMsg = "#loadedMsg#;  Dec Long must be between -180 and 180">
					</cfif>
				<cfelseif #orig_lat_long_units# IS "deg. min. sec.">
					<cfif len(#latdeg#) is 0 or not isnumeric(#latdeg#)>
						<cfset loadedMsg = "#loadedMsg#;  latdeg is required and must be numeric 
							when orig lat long units is deg. min. sec.">
					</cfif>
					<cfif #latdeg# lt 0 OR #latdeg# gt 90>
						<cfset loadedMsg = "#loadedMsg#;  Lat Deg must be between 0 and 90">
					</cfif>
					<cfif len(#latmin#) is 0 or not isnumeric(#latmin#)>
						<cfset loadedMsg = "#loadedMsg#;  latmin is required and must be numeric 
							when orig lat long units is deg. min. sec.">
					</cfif>
					<cfif #latmin# lt 0 OR #latmin# gt 90>
						<cfset loadedMsg = "#loadedMsg#;  Lat Min must be between 0 and 60">
					</cfif>
					<cfif len(#latsec#) is 0 or not isnumeric(#latsec#)>
						<cfset loadedMsg = "#loadedMsg#;  latsec is required and must be numeric 
							when orig lat long units is deg. min. sec.">
					</cfif>
					<cfif #latsec# lt 0 OR #latsec# gt 60>
						<cfset loadedMsg = "#loadedMsg#;  Lat Sec must be between 0 and 60">
					</cfif>
					<cfif len(#longdeg#) is 0 or not isnumeric(#longdeg#)>
						<cfset loadedMsg = "#loadedMsg#;  longdeg is required and must be numeric 
							when orig lat long units is deg. min. sec.">
					</cfif>
					<cfif #longdeg# lt 0 OR #longdeg# gt 180>
						<cfset loadedMsg = "#loadedMsg#;  Long Deg must be between 0 and 180">
					</cfif>
					<cfif len(#longmin#) is 0 or not isnumeric(#longmin#)>
						<cfset loadedMsg = "#loadedMsg#;  longmin is required and must be numeric 
							when orig lat long units is deg. min. sec.">
					</cfif>
					<cfif #longmin# lt 0 OR #longmin# gt 60>
						<cfset loadedMsg = "#loadedMsg#;  Long Min must be between 0 and 60">
					</cfif>
					<cfif len(#longsec#) is 0 or not isnumeric(#longsec#)>
						<cfset loadedMsg = "#loadedMsg#;  longsec is required and must be numeric 
							when orig lat long units is deg. min. sec.">
					</cfif>
					<cfif #longsec# lt 0 OR #longsec# gt 60>
						<cfset loadedMsg = "#loadedMsg#;  Long Sec must be between 0 and 60">
					</cfif>
					<cfif len(#latdir#) is 0>
						<cfset loadedMsg = "#loadedMsg#;  latdir (#latdir#) is required.">
					</cfif>
					<cfif #latdir# is not "N" AND #latdir# is not "S">
						<cfset loadedMsg = "#loadedMsg#;  latdir (#latdir#) is required and must be N or S
							when orig lat long units is degrees dec. minutes">
					</cfif>
					<cfif len(#longdir#) is 0>
						<cfset loadedMsg = "#loadedMsg#;  longdir (#longdir#) is required and must be E or W
								when orig lat long units is deg. min. sec.">
					</cfif>
					<cfif #longdir# is not "E" AND #longdir# is not "W">
						<cfset loadedMsg = "#loadedMsg#;  longdir (#longdir#) is required and must be E or W
								when orig lat long units is deg. min. sec.">
					</cfif>
				
				<cfelseif #orig_lat_long_units# IS "degrees dec. minutes">
					<cfif len(#latdeg#) is 0 or not isnumeric(#latdeg#)>
						<cfset loadedMsg = "#loadedMsg#;  latdeg is required and must be numeric 
							when orig lat long units is degrees dec. minutes">
					</cfif>
					<cfif #latdeg# lt 0 OR #latdeg# gt 90>
						<cfset loadedMsg = "#loadedMsg#;  Lat Deg must be between 0 and 90">
					</cfif>
					<cfif len(#dec_lat_min#) is 0 or not isnumeric(#dec_lat_min#)>
						<cfset loadedMsg = "#loadedMsg#;  dec_lat_min is required and must be numeric 
							when orig lat long units is degrees dec. minutes">
					</cfif>
					<cfif #dec_lat_min# lt 0 OR #dec_lat_min# gt 60>
						<cfset loadedMsg = "#loadedMsg#;  dec_lat_min must be between 0 and 60">
					</cfif>
					<cfif len(#latdir#) is 0>
						<cfset loadedMsg = "#loadedMsg#;  latdir (#latdir#) is required 
							when orig lat long units is degrees dec. minutes">
					</cfif>
					<cfif #latdir# is not "N" AND #latdir# is not "S">
						<cfset loadedMsg = "#loadedMsg#;  latdir (#latdir#) must be N or S
							when orig lat long units is degrees dec. minutes">
					</cfif>
					<cfif len(#longdeg#) is 0 or not isnumeric(#longdeg#)>
						<cfset loadedMsg = "#loadedMsg#;  longdeg is required and must be numeric 
							when orig lat long units is degrees dec. minutes">
					</cfif>
					<cfif #longdeg# lt 0 OR #longdeg# gt 180>
						<cfset loadedMsg = "#loadedMsg#;  Long Deg must be between 0 and 180">
					</cfif>
					<cfif len(#dec_long_min#) is 0 or not isnumeric(#dec_long_min#)>
						<cfset loadedMsg = "#loadedMsg#;  dec_long_min is required and must be numeric 
							when orig lat long units is degrees dec. minutes">
					</cfif>
					<cfif #dec_long_min# lt 0 OR #dec_long_min# gt 60>
						<cfset loadedMsg = "#loadedMsg#;  dec_long_min must be between 0 and 60">
					</cfif>
					<cfif len(#longdir#) is 0>
						<cfset loadedMsg = "#loadedMsg#;  longdir (#longdir#) is required 
								when orig lat long units is deg. min. sec.">
					</cfif>
					<cfif #longdir# is not "E" AND #longdir# is not "W">
						<cfset loadedMsg = "#loadedMsg#;  longdir (#longdir#) and must be E or W
								when orig lat long units is deg. min. sec.">
					</cfif>
					
				<cfelse>
					<cfset loadedMsg = "#loadedMsg#; I don't know how to handle lat/long units #orig_lat_long_units#">
				</cfif>
				<!--- now get the universsal lat/long stuff --->
				<cfif len(#datum#) gt 0>
					<cfquery name="valdatum" datasource="#mcat#">
						select * from ctdatum where datum ='#datum#'
					</cfquery>
					<cfif valdatum.recordcount is 0>
						<cfset loadedMsg = "#loadedMsg#; datum must match code table values.">
					</cfif>
				<cfelse>
					<cfset loadedMsg = "#loadedMsg#; Datum is required.">
				</cfif>
				<cfif len(#determined_by_agent#) gt 0>
					<cfquery name="getLLAgnt" datasource="#mcat#">
						select agent_id from agent_name where agent_name = '#determined_by_agent#'
						and agent_name_type <> 'Kew abbr.'
					</cfquery>
					<cfif getLLAgnt.recordcount is 0>
						<cfset loadedMsg = "#loadedMsg#; The lat long determining agent was not found.">
					  <cfelseif getLLAgnt.recordcount gt 1>
						<cfset loadedMsg = "#loadedMsg#; The lat long determining agent returned more than one match. Please enter an agent anme (not necessarily the preferred name) that uniquely identifies the agent who determined the lat_long.">
					<cfelse>
						<cfset llagentid = getLLAgnt.agent_id>
					</cfif>
							
				</cfif>
				<cfif len(#determined_date#) is 0>
					<cfset loadedMsg = "#loadedMsg#; Lat Long Determined date is required.">
				<cfelse>
					<cfif not isdate(#determined_date#)>
						<cfset loadedMsg = "#loadedMsg#; Lat Long Determined date must be a date.">
					</cfif>
				</cfif>
				<cfif len(#lat_long_ref_source#) gt 0>
					<cfquery name="valLLRef" datasource="#mcat#">
						select * from ctlat_long_ref_source where lat_long_ref_source ='#lat_long_ref_source#'
					</cfquery>
					<cfif valLLRef.recordcount is 0>
						<cfset loadedMsg = "#loadedMsg#; Lat long reference source must match code table values.">
					</cfif>
				<cfelse>
					<cfset loadedMsg = "#loadedMsg#; Lat long reference source is required">
				</cfif>
				<cfif len(#max_error_distance#) gt 0>
					<cfif len(#max_error_units#) is 0>
						<cfset loadedMsg = "#loadedMsg#; Max error units is required if max error is not null.">
					</cfif>
					<cfif not isnumeric(#max_error_distance#)>
						<cfset loadedMsg = "#loadedMsg#; Max error distance must be numeric">
					</cfif>
					<cfquery name="valMED" datasource="#mcat#">
						select * from CTLAT_LONG_ERROR_UNITS where LAT_LONG_ERROR_UNITS ='#max_error_units#'
					</cfquery>
					<cfif valMED.recordcount is 0>
						<cfset loadedMsg = "#loadedMsg#; Max error units must match code table values">
					</cfif>
				</cfif>
			<cfelse><!---- orig lat_long_units not given --->
				<cfif len(#dec_lat#) gt 0 OR
					len(#dec_long#) gt 0 OR
					len(#latdeg#) gt 0 OR
					len(#latmin#) gt 0 OR
					len(#latsec#) gt 0 OR
					len(#longdeg#) gt 0 OR
					len(#longmin#) gt 0 OR
					len(#longsec#) gt 0 OR
					len(#latdir#) gt 0 OR
					len(#longdir#) gt 0 OR
					len(#dec_lat_min#) gt 0 OR
					len(#dec_long_min#) gt 0>
						<cfset loadedMsg = "#loadedMsg#; You've provided coordinate data but not original lat long units">
					</cfif>
			</cfif><!---- end lat/long validation ---->
					<cfif len(#verbatim_locality#) is 0>
						<cfset loadedMsg = "#loadedMsg#;  Verbatim locality is required.">
					</cfif>
				
				
				
				
				
				
				<!---- end normal locality-checking routine ---->
			<cfelse>
				---------here's a locality ID: '#locality_id#'----------------------------<cfabort>
				<!--- just make sure we got a valid locality_id --->
				<cfquery name="isValidLocId" datasource="#mcat#">
					select locality_id from locality where locality_id=#locality_id#
				</cfquery>
				<cfif #len(isValidLocId.locality_id)# is 0>
					<cfset loadedMsg = "#loadedMsg#; You specified a pre-existing locality ID that does not exist.">
				</cfif>
			</cfif><!--- end use existing locality check --->
			<cfif  len(#coll_obj_disposition#) is 0>
				<cfset loadedMsg = "#loadedMsg#;  coll_obj_disposition -#coll_obj_disposition#- is required.">
			</cfif>
			<cfquery name="coll_obj_disposition" datasource="#mcat#">
				select coll_obj_disposition from ctcoll_obj_disp
			</cfquery>
				<cfif #coll_obj_disposition.recordcount# is 0>
					<cfset loadedMsg = "#loadedMsg#;  Disposition was not found in the code table.">
				</cfif>			
			<cfif not len(#condition#) gt 0>
				<cfset loadedMsg = "#loadedMsg#; condition is required">
			</cfif>
		
			<cfif len(#af_num#) gt 0>
				<cfif not isnumeric(#af_num#)>
					<cfset loadedMsg = "#loadedMsg#; AF Num must be numeric.">
				</cfif>
				<cfquery name="isAfNew" datasource="#mcat#">
					select * from af_num where af_num='#af_num#'
				</cfquery>
				<cfif #isAfNew.recordcount# gt 0>
					<cfset loadedMsg = "#loadedMsg#; That AF number has been used">
				</cfif>
			</cfif>
			
			<cfif len(#made_date#) gt 0>				
				<cfif not isdate(#made_date#)>
					<cfset loadedMsg = "#loadedMsg#; ID Made Date must be a date.">
				</cfif>
			</cfif>
			
			<cfif not len(#nature_of_id#) gt 0>
				<cfset loadedMsg = "#loadedMsg#;  nature of id is required">
			</cfif>
			<cfquery name= "valNatureOfId" datasource="#mcat#">
					SELECT nature_of_id FROM ctnature_of_id WHERE nature_of_id = '#nature_of_id#'
			</cfquery>
			<cfif valNatureOfId.recordcount is 0>
				<cfset loadedMsg = "#loadedMsg#; nature_of_id must match code table values.">
			</cfif>
			
			<cfif not len(#taxon_name#) gt 0>
				<cfset loadedMsg = "#loadedMsg#; taxon_name is required.">
			</cfif>
			<cfif right(taxon_name,4) is " sp.">
				<!---- handle A + "sp." taxa formula ---->
				<cfset taxon_name=left(taxon_name,len(taxon_name) -4)>
				<cfset taxa_formula = "A sp.">
				<cfset TaxonomyTaxonName=left(taxon_name,len(taxon_name) - 4)>
			<cfelseif right(taxon_name,4) is " cf.">
				<!---- handle A + "cf." taxa formula ---->
				<cfset taxon_name=left(taxon_name,len(taxon_name) -4)>
				<cfset taxa_formula = "A cf.">
				<cfset TaxonomyTaxonName=left(taxon_name,len(taxon_name) - 4)>
			<cfelse>
				<cfset  taxa_formula = "A">
				<cfset TaxonomyTaxonName="#taxon_name#">
			</cfif>
			<cfquery name= "getTaxa" datasource="#mcat#">
				SELECT taxon_name_id FROM taxonomy WHERE scientific_name = '#TaxonomyTaxonName#'
				AND valid_catalog_term_fg=1
			</cfquery>
			
			<cfif getTaxa.recordcount is 0>
				<cfset loadedMsg = "#loadedMsg#;  Taxonomy not found.">
			<cfelseif getTaxa.recordcount gt 1>
				<cfset loadedMsg = "#loadedMsg#; Multiple scientific name (#taxon_name#) matches found">
			</cfif>
					<cfset taxonnameid = getTaxa.taxon_name_id>
			
			<!-------------------- depth ----------------------------->
			<cfif len(#min_depth#) gt 0 OR len(#max_depth#) gt 0 OR len(#depth_units#) gt 0>
				<!---- if we got one, we need them all ---->
				<cfif len(#min_depth#) is 0 OR len(#max_depth#) is 0 OR len(#depth_units#) is 0>
					<cfset loadedMsg = "#loadedMsg#; Min_Depth, Max_Depth, and Depth_Units are all required if one is given.">
				</cfif>
				
				<cfif not isnumeric(#min_depth#) OR not isnumeric(#max_depth#)>
					<cfset loadedMsg = "#loadedMsg#; Min_Depth and Max_Depth must be numeric.">
				</cfif>
				<cfquery name="valDepthUnits" datasource="#mcat#">
					select depth_units from ctdepth_units where depth_units='#depth_units#'
				</cfquery>
				<cfif #valDepthUnits.recordcount# is not 1>
					<cfset loadedMsg = "#loadedMsg#; Depth Units was not found in the code table.">
				</cfif>
			</cfif>
			<!----------------------------- end depth ------------------------>
			
<!---------------------- attribute 1 ------------------------------------------------->			
<!----- 4 Oct 2004 change - loop over attributes, from 1-8 ---->

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
	
	
	<cfif len(#thisAttributeValue#) gt 0 AND len(#thisValueValue#) gt 0><!--- ignore unless we get type AND value --->
				<cfquery name="isAtt" datasource="#mcat#">
					select attribute_type from ctattribute_type where attribute_type='#thisAttributeValue#'
					AND collection_cde='#collection_cde#'
				</cfquery>
				<cfif isAtt.recordcount is not 1>					
					<cfset loadedMsg = "#loadedMsg#; Attribute_#i# (#thisAttributeValue#) does not match code table values for collection #collection_cde#.">
				</cfif>
				<!--- we have a valid attribute type ---->
				<cfif len(#thisValueValue#) gt 0>
					<!---- see if it  should be code-table controlled ---->
					<cfquery name="isValCt" datasource="#mcat#">
						SELECT value_code_table FROM ctattribute_code_tables WHERE
						attribute_type = '#thisAttributeValue#'
					</cfquery>
					<cfif isdefined("isValCt.value_code_table") and len(#isValCt.value_code_table#) gt 0>
									<!--- there's a code table --->
							<cfquery name="valCT" datasource="#mcat#">
								select * from #isValCt.value_code_table#
							</cfquery>							
							<!---- get column names --->
							<cfquery name="getCols" datasource="uam_god">
								select column_name from sys.user_tab_columns where table_name='#ucase(isValCt.value_code_table)#'
								and column_name <> 'DESCRIPTION'
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
								<!--- if we got a collection code, rerun the query to filter ---->
								<cfif len(#collCode#) gt 0>
									<cfquery name="valCodes" dbtype="query">
										SELECT #getCols.column_name# as valCodes from valCT
										WHERE #getCols.column_name# =  '#thisValueValue#'
										AND collection_cde='#collection_cde#'
									</cfquery>
									
								  <cfelse>
								 	<cfquery name="valCodes" dbtype="query">
										SELECT #getCols.column_name# as valCodes from valCT
										WHERE #getCols.column_name# =  '#thisValueValue#'
									</cfquery>
									
								</cfif>
								<cfset validValueFlag="">
								<cfloop query="valCodes">
									<cfif #valCodes.valCodes# is #thisValueValue#>
										<cfset validValueFlag = "#validValueFlag#true">
									</cfif>
								</cfloop>
								<cfif len(#validValueFlag#) is 0>									
									<cfset loadedMsg = "#loadedMsg#; Attribute Value #i# (#thisValueValue#) is code table controlled and does not match code table values.">
								</cfif>
				  </cfif>
						<cfelse><!---- attribute_value was null --->
							<cfset loadedMsg = "#loadedMsg#; Attribute Value #i# (#thisValueValue#) is required when Attribute #i# is given.">
		  </cfif>
					<cfif len(#thisUnitsValue#) gt 0>
						<!--- see if it's CT controlled --->
						<cfquery name="isUnitCt" datasource="#mcat#">
							SELECT units_code_table FROM ctattribute_code_tables WHERE
							attribute_type = '#thisAttributeValue#'
						</cfquery>
						<cfif #isUnitCt.recordcount# gt 0 AND len(#isUnitCt.units_code_table#) gt 0>
						<!--- code table controlled, see if it matches --->
							<cfquery name="unitCT" datasource="#mcat#">
								select * from #isUnitCt.units_code_table#
							</cfquery>
							<!---- get column names --->
							<cfquery name="getCols" datasource="uam_god">
								select column_name from sys.user_tab_columns where table_name='#ucase(isUnitCt.units_code_table)#'
								AND COLUMN_NAME <> 'DESCRIPTION'
							</cfquery>
							<cfset collCode = "">
							<cfset columnName = "">
							<cfloop query="getCols">
								<cfif getCols.column_name is "COLLECTION_CDE">
									<cfset collCde = "yes">
								  <cfelse>
									<cfset columnName = "#getCols.column_name#">
								</cfif>
							</cfloop>
							<!--- if we got a collection code, rerun the query to filter ---->
							<cfif len(#collCode#) gt 0>
						
								<cfquery name="unitCodes" dbtype="query">
									SELECT #getCols.column_name# as unitCodes from unitCT
									WHERE collection_cde='#indiv.collection_cde#'
								</cfquery>
							  <cfelse>
						
								<cfquery name="unitCodes" dbtype="query">
									SELECT #getCols.column_name# as unitCodes from unitCT
								</cfquery>
							</cfif>
					<cfset thisAttUnit = #thisUnitsValue#>
					<cfset validUnitsCodeTable="">
					<cfloop query="unitCodes">
						<cfif #unitCodes.unitCodes# is "#thisAttUnit#"> 
							<cfset validUnitsCodeTable = "true">
						</cfif>
					</cfloop>
					<cfif len(#validUnitsCodeTable#) is 0>
						<cfset loadedMsg = "#loadedMsg#; Attribute units #i# (#thisAttUnit#)did not match CT values.">
					</cfif>
		  			<!---- they have a valid units code table, so go back and make sure the value they 
						gave is numeric --->
					<cfif not isnumeric(#thisValueValue#)>
						<cfset loadedMsg = "#loadedMsg#; Attribute Value (#thisAttUnit#) must be numeric for #thisAttributeValue#">
					</cfif>
		  <cfelse>
							<!---- not code table controlled, leave it null for now - all units are 
							either CT controlled or NULL--->
							<!--- see if they tried to put anything in here --->
							<cfif len(#thisUnitsValue#) gt 0>
									<cfset loadedMsg = "#loadedMsg#; You can't have attribute units for attribute #i#.">
							</cfif>
					</cfif><!--- end CT check --->
				 <cfelse>
					 <!--- att val units not given, see if it should be --->
					 	<cfquery name="isUnitCt" datasource="#mcat#">
							SELECT units_code_table FROM ctattribute_code_tables WHERE
							attribute_type = '#thisAttributeValue#'
						</cfquery>
						<cfif #isUnitCt.recordcount# gt 0 and len(#isUnitCt.units_code_table#) gt 0>
							
							<cfset loadedMsg = "#loadedMsg#; A value for Atribute Units #i# is required.">
						</cfif>
					</cfif>
					
					<cfif len(#thisDateValue#) gt 0>
						<cfif not isdate(#thisDateValue#)>
						 	<cfset loadedMsg = "#loadedMsg#; Attribute Date #i# (#thisDateValue#) is not a date">
					  </cfif>
					  <cfelse>
					  	<cfset loadedMsg = "#loadedMsg#; Attribute Date #i# is required.">
					</cfif>
					
					<cfif len(#thisDeterminerValue#) gt 0>
						<cfquery name="attDet1" datasource="#mcat#">
							SELECT agent_id FROM agent_name WHERE agent_name = '#thisDeterminerValue#'
							and agent_name_type <> 'Kew abbr.'
						</cfquery>
						<cfif #attDet1.recordcount# is 0>
							<cfset loadedMsg = "#loadedMsg#; Attribute Determiner #i# (#thisDeterminerValue#) was not found.">
						</cfif>
						<cfif #attDet1.recordcount# gt 1>
							<cfset loadedMsg = "#loadedMsg#; Attribute Determiner #i# (#thisDeterminerValue#) matched more than one existing agent name.">
						</cfif>
					<cfelse>
						<cfset loadedMsg = "#loadedMsg#; Attribute Determiner #i# may not be null.">
					</cfif>
						
				<!----
				thisAttributeValue - #thisAttributeValue# <br>
				thisAttributeValue - #thisAttributeValue# <br>
				thisValueValue - #thisValueValue# <br>
				thisUnitsValue - #thisUnitsValue# <br>
				thisRemarkValue - #thisRemarkValue# <br>
				thisDateValue - #thisDateValue# <br>
				thisMethodValue - #thisMethodValue# <br>
				thisDeterminerValue - #thisDeterminerValue# <br>
				--#loadedMsg#--
				<hr>
				---->
				
	</cfif>
</cfloop>

<!---- dynamic other IDs ---->

<cfloop from="1" to="#numberOfOtherIds#" index="i">
	<cfset thisIDType="other_id_num_type_" & #i#>
	<cfset thisIDNumber="other_id_num_" & #i#>
	
	<cfset thisIDTypeValue = evaluate(#thisIDType#)>
	<cfset thisIDNumberValue = evaluate(#thisIDNumber#)>
	
	
		<cfif len(#thisIDTypeValue#) gt 0>
			<!---- we got an other ID for this loop---->
			<cfif len(#thisIDNumberValue#) is 0>
				<cfset loadedMsg = "#loadedMsg#; You must supply a number for other ID #i#">
			</cfif>
			<cfquery name="oidType" datasource="#mcat#">
				select * from ctcoll_other_id_type where other_id_type = '#thisIDTypeValue#'
				AND collection_cde = '#collection_cde#'
			</cfquery>
			<cfif oidType.recordcount is 0>
				<cfset loadedMsg = "#loadedMsg#; OtherID Type #i# (#thisIDTypeValue#) is not in the code table.">
			</cfif>
		<Cfelse>
			<!---- no type, see if we got a number --->
			<cfif len(#thisIDNumberValue#) gt 0>
				<!---- got a number but no type ---->
				<cfset loadedMsg = "#loadedMsg#; You must provide an ID type for other ID #i#">
			</cfif>
		</cfif>
</cfloop>

			
			<cfif not len(#id_made_by_agent#) gt 0>
				<cfset loadedMsg = "#loadedMsg#; id_made_by_agent is required.">
			</cfif>
			<cfquery name= "valIdBy" datasource="#mcat#">
				SELECT agent_id FROM agent_name WHERE agent_name = '#id_made_by_agent#' 
				and agent_name_type <> 'Kew abbr.'
			</cfquery>
			<cfif valIdBy.recordcount is 0>
					<cfset loadedMsg = "#loadedMsg#; IdBy agent (#id_made_by_agent#) was not found.">
			<cfelseif valIdBy.recordcount gt 1>
					<cfset loadedMsg = "#loadedMsg#;  IdBy (#id_made_by_agent#) agent matched more than one agent.">
			</cfif>
					<cfset idmadebyagentid = valIdBy.agent_id>
<!---- dynamic collectors ---->
<cfloop from="1" to="#numberOfCollectors#" index="i">
	<cfset thisColl="collector_agent_" & #i#>
	<cfset thisCollR="collector_role_" & #i#>
	
	<cfset thisCollector = evaluate(#thisColl#)>
	<cfset thisCollectorRole = evaluate(#thisCollR#)>
	<!---- special handling for first collector ---->
	<cfif #i# is 1>
		<cfif not len(#thisCollector#) gt 0>
			<cfset loadedMsg = "#loadedMsg#;  collector_agent_1 is required.">
		</cfif>
		<cfif not #thisCollectorRole# is "c">
			<cfset loadedMsg = "#loadedMsg#; collector_role_1 is required and must be 'c'">
		</cfif>
	</cfif>
	<cfif len(#thisCollector#) gt 0>
		<cfquery name= "getColl" datasource="#mcat#">
			SELECT agent_id FROM agent_name WHERE agent_name = '#thisCollector#'
			and agent_name_type <> 'Kew abbr.'
		</cfquery>
		<cfif len(#getColl.agent_id#) is 0>
			<cfset loadedMsg = "#loadedMsg#;  collector_agent_#i# (#thisCollector#) not found">
		<cfelseif getColl.recordcount gt 1>
			<cfset loadedMsg = "#loadedMsg#;  collector_agent_#i# (#thisCollector#) has multiple matches.">
		</cfif>
		<cfif #thisCollectorRole# is not "c" AND #thisCollectorRole# is not "p">
			<cfset loadedMsg = "#loadedMsg#;  collector_role_#i# must be c or p">
		</cfif>
	</cfif>
</cfloop>

<!---- dynamic parts ---->
<cfloop from="1" to="#numberOfParts#" index="i">
	<cfset thisPN="part_name_" & #i#>
	<cfset thisPM="preserv_method_" & #i#>
	<cfset thisPC="part_condition_" & #i#>
	<cfset thisPMod="part_modifier_" & #i#>
	<cfset thisPBC="part_barcode_" & #i#>
	<cfset thisPCL="part_container_label_" & #i#>
	<cfset thisPLC="part_lot_count_" & #i#>
	
	<cfset thisPartName = evaluate(#thisPN#)>
	<cfset thisPresMeth = evaluate(#thisPM#)>
	<cfset thisPartCondition = evaluate(#thisPC#)>
	<cfset thisPartModifier = evaluate(#thisPMod#)>
	<cfset thisPartBarCode = evaluate(#thisPBC#)>
	<cfset thisPartContainerLabel = evaluate(#thisPCL#)>
	<cfset thisPartLotCount = evaluate(#thisPLC#)>
	<!---- special case for first part ---->
	<cfif #i# is 1>
		<cfif not len(#thisPartName#) gt 0>
			<cfset loadedMsg = "#loadedMsg#; part_name_1 is required. ">
		</cfif>
	</cfif>
	<cfif len(#thisPartName#) gt 0>
		<cfquery name= "valPartName" datasource="#mcat#">
				SELECT part_name FROM ctspecimen_part_name WHERE part_name = '#thisPartName#' 
				and collection_cde='#collection_cde#'
		</cfquery>
		<cfif valPartName.recordcount is 0>
			<cfset loadedMsg = "#loadedMsg#; part_name_#i# (#thisPartName#) must match code table values for #collection_cde#.">
		</cfif>
		
		<cfif len(#thisPresMeth#) gt 0>
			<cfquery name= "valPartPres" datasource="#mcat#">
				SELECT preserve_method FROM ctspecimen_preserv_method 
				WHERE preserve_method = '#thisPresMeth#' 
				and collection_cde='#collection_cde#'
			</cfquery>
			<cfif valPartPres.recordcount is 0>
				<cfset loadedMsg = "#loadedMsg#;  preserv_method_#i# must match code table values">
			</cfif>
		</cfif>
		<cfif len(#thisPartCondition#) is 0>
			<cfset loadedMsg = "#loadedMsg#; part_condition_#i# may not be null.">
		</cfif>
		
		<cfif len(#thisPartBarCode#) GT 0>
			<cfquery name="getID" datasource="#mcat#">
				select container_id from container where barcode = '#thisPartBarCode#'
			</cfquery>
			<cfif #getID.recordcount# neq 1>
				<cfset loadedMsg = "#loadedMsg#; Part barcode #i# (#thisPartBarCode#) was not found. Barcodes must match pre-existing containers">
			</cfif>
			<cfif len (#thisPartContainerLabel#) is 0>
				<cfset loadedMsg = "#loadedMsg#; Container Label #i# is required when loading barcodes.">
			</cfif>
		<cfelseif len (#thisPartContainerLabel#) gt 0>
			<!---- label but no barcode ---->
			<cfset loadedMsg = "#loadedMsg#; You must supply a barcode for container label #i#">
		</cfif>
	</cfif>
</cfloop>
		<cfif len(#accn#) is 0>
			<cfset loadedMsg = "#loadedMsg#;  Accn may not be null.">
		</cfif>
		<!--- sort the accn number out into a transaction id, which must already exist--->
		<cfset goodAccn="yes">
		<cfif len(#accn#) is 8>
			<cfset pre = left(#accn#,4)>
			<cfset num = int(right(#accn#,3))>
				<cfset getTransSql = "SELECT transaction_id FROM accn WHERE
					accn_num_prefix = '#pre#' AND
					accn_num = #num#">
		<cfelseif len(#accn#) is 13>
			<cfset pre = left(#accn#,4)>
			<cfset num = int(mid(#accn#,6,3))>
			<cfset suf= right(accn,4)>
				<cfset getTransSql = "SELECT transaction_id FROM accn WHERE
					accn_num_prefix = '#pre#' AND
					accn_num = #num# AND accn_num_suffix='#suf#'">
		<cfelse>
			<cfset loadedMsg = "#loadedMsg#;  Accn format not recognized.">
			<cfset goodAccn="no">
		</cfif>
		<cfif #goodAccn# is "yes">
			<cfquery name="getTrans" datasource="#mcat#">
				#preservesinglequotes(getTransSql)#
			</cfquery>
			<cfset transactionid = getTrans.transaction_id>
			<cfif len(#transactionid#) lt 1>
				<cfset loadedMsg = "#loadedMsg#; You must specify a valid, pre-existing accn number. The number you entered parsed out as #pre#.#num#">
			</cfif>
		</cfif>
		
			
			<cfif len(#enteredby#) is 0>
				<cfset loadedMsg = "#loadedMsg#;  enteredby may not be null.">
			</cfif>
				<cfquery name= "getEntBy" datasource="#mcat#">
					SELECT agent_id FROM agent_name WHERE agent_name = '#enteredby#'
					and agent_name_type <> 'Kew abbr.'
				</cfquery>
				<cfif getEntBy.recordcount is 0>
					<cfset loadedMsg = "#loadedMsg#; enteredby not found.">
				<cfelseif getEntBy.recordcount gt 1>
					<cfset loadedMsg = "#loadedMsg#; enteredby has multiple matches">
				</cfif>
						<cfset enteredbyid = getEntBy.agent_id>
				
			
			<cfset ccSQL = "SELECT collection_id from collection 
			WHERE collection_cde = '#collection_cde#' AND institution_acronym = '#institution_acronym#'">
			<cfquery name="getCollID" datasource="#mcat#">
				#preservesinglequotes(ccSQL)#
			</cfquery>
			<cfset collectionid = #getCollID.collection_id#>
			
			
			<cfif len(#flags#) gt 0>
				<cfquery name="ctFlags" datasource="#mcat#">
					select * from ctflags where flags = '#flags#'
				</cfquery>
				<cfif ctFlags.recordcount is 0>
					<cfset loadedMsg = "#loadedMsg#;  Flags does not match code table values.">
				</cfif>
			</cfif>	
			<cfif len(#georefmethod#) gt 0>
				<cfquery name="ctgeorefmethod" datasource="#mcat#">
					select * from ctgeorefmethod where georefmethod = '#georefmethod#'
				</cfquery>
				<cfif ctgeorefmethod.recordcount is 0>
					<cfset loadedMsg = "#loadedMsg#;  georefmethod does not match code table values.">
				</cfif>
			</cfif>			
	</cfoutput>

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
		
		
		---->
		
		
		
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
			AND ended_date = '#dateformat(ended_date,"dd-mmm-yyyy")#'">
			<cfif not (#coll_event_remarks#) is "">
				<cfset isCol = "#isCol# AND coll_event_remarks = '#replace(coll_event_remarks,"'","''","all")#'">
			<cfelse>
				<cfset isCol = "#isCol# AND coll_event_remarks is null">
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
								VERBATIM_LOCALITY">
							<cfif len(#COLL_EVENT_REMARKS#) gt 0>
								<cfset thisSQL = "#thisSQL#,COLL_EVENT_REMARKS">
							</cfif>
							<cfif len(#habitat_desc#) gt 0>
								<cfset thisSQL = "#thisSQL#,habitat_desc">
							</cfif>
								<cfset thisSQL = "#thisSQL# ) VALUES (
									#collectingeventid#,
									#localityid#,
									1,
									'wild caught',
									'#dateformat(BEGAN_DATE,"dd-mmm-yyyy")#',
									'#dateformat(ENDED_DATE,"dd-mmm-yyyy")#',
									'#replace(VERBATIM_DATE,"'","''","all")#',
									'#replace(VERBATIM_LOCALITY,"'","''","all")#'">
									<cfif len(#COLL_EVENT_REMARKS#) gt 0>
										<cfset thisSQL = "#thisSQL#,'#replace(coll_event_remarks,"'","''","all")#'">
									</cfif>
									<cfif len(#habitat_desc#) gt 0>
										<cfset thisSQL = "#thisSQL#,'#habitat_desc#'">
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
					SELECT agent_id AS ThisDeterminerID from agent_name WHERE
					agent_name='#thisDeterminerValue#'
					and agent_name_type <> 'Kew abbr.'
				</cfquery>
				<cfset ThisDeterminerID=#attDetId.ThisDeterminerID#>
				<cfset thisSql = "INSERT INTO attributes (
					attribute_id,
					collection_object_id,
					determined_by_agent_id,
					attribute_type,
					attribute_value,
					determined_date">
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
						'#replace(thisValueValue,"'","''","all")#',
						'#dateformat(thisDateValue,"dd-mmm-yyyy")#'">
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
					 MADE_DATE,
					 NATURE_OF_ID,
					 ACCEPTED_ID_FG,
					  taxa_formula,
					 scientific_name ">
					<CFIF LEN(#identification_remarks#) GT 0>
					 	<cfset thisSQL = "#thisSQL#,IDENTIFICATION_REMARKS">
		  </CFIF> 
					<cfset thisSQL = "#thisSQL# )
				VALUES (
					#identificationid#,
					 #catcollid#,
					 #idmadebyagentid#,
					 '#dateformat(made_date,"dd-mmm-yyyy")#',
					 '#nature_of_id#',
					 1,
					 '#taxa_formula#',
					 '#taxon_name#'">
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
	
	<cfif not #af_num# is "">
		<cfset thisSQL = "INSERT INTO coll_obj_other_id_num (
						COLLECTION_OBJECT_ID,
						OTHER_ID_NUM,
						OTHER_ID_TYPE)
					VALUES (
						#catcollid#,
						'#af_num#',
						'AF')">
		<cfquery name="makeOtherId1" datasource="#mcat#">
			#preservesinglequotes(thisSQL)#
		</cfquery>     
	</cfif>
	<!--- make other ids as needed --->
<cfloop from="1" to="#numberOfOtherIds#" index="i">
	<cfset thisIDType="other_id_num_type_" & #i#>
	<cfset thisIDNumber="other_id_num_" & #i#>
	
	<cfset thisIDTypeValue = evaluate(#thisIDType#)>
	<cfset thisIDNumberValue = evaluate(#thisIDNumber#)>
	
		<cfif len(#thisIDTypeValue#) gt 0>
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
	
<cfloop from="1" to="8" index="i">
	
	<cfset thisPN="part_name_" & #i#>
	<cfset thisPM="preserv_method_" & #i#>
	<cfset thisPC="part_condition_" & #i#>
	<cfset thisPMod="part_modifier_" & #i#>
	<cfset thisPBC="part_barcode_" & #i#>
	<cfset thisPCL="part_container_label_" & #i#>
	<cfset thisPLC="part_lot_count_" & #i#>
	
	<cfset thisPartName = evaluate(#thisPN#)>
	<cfset thisPresMeth = evaluate(#thisPM#)>
	<cfset thisPresMeth = replace(thisPresMeth,"'","''","all")>
	<cfset thisPartCondition = evaluate(#thisPC#)>
	<cfset thisPartModifier = evaluate(#thisPMod#)>
	<cfset thisPartBarCode = evaluate(#thisPBC#)>
	<cfset thisPartContainerLabel = evaluate(#thisPCL#)>
	<cfset thisPartLotCount = evaluate(#thisPLC#)>
	<cfif not isdefined("thisPartLotCount") or len(#thisPartLotCount#) is 0>
		<cfset thisPartLotCount = 1>
	</cfif>
	
	<cfset thisPartName = trim(#thisPartName#)>
	<cfset thisPresMeth = trim(#thisPresMeth#)>
	<cfset thisPartCondition = trim(#thisPartCondition#)>
	<cfset thisPartModifier = trim(#thisPartModifier#)>
	<cfset thisPartBarCode = trim(#thisPartBarCode#)>
	<cfset thisPartContainerLabel = trim(#thisPartContainerLabel#)>

	
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
					'unchecked',
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
				DERIVED_FROM_CAT_ITEM">
				<cfif len(#thisPartModifier#) gt 0>
					<cfset thisSQL = "#thisSQL#,PART_MODIFIER">
				</cfif>
				<cfif len(#thisPresMeth#) gt 0>
					<cfset thisSQL = "#thisSQL#,PRESERVE_METHOD">
				</cfif>
				<cfset thisSQL = "#thisSQL# )
			VALUES (
				#partid#,
				'#thisPartName#',
				#catcollid#">
				<cfif len(#thisPartModifier#) gt 0>
					<cfset thisSQL = "#thisSQL#,'#thisPartModifier#'">
				</cfif>
				<cfif len(#thisPresMeth#) gt 0>
					<cfset thisSQL = "#thisSQL#,'#thisPresMeth#'">
				</cfif>
				<cfset thisSQL = "#thisSQL#	)">
			<cfquery name="makePart" datasource="#mcat#">
					#preservesinglequotes(thisSQL)#
			</cfquery>
			
			<cfset pn = #replace(thisPartName,"'","","all")#>
			<cfset thisSQL = "INSERT INTO container (
					CONTAINER_ID,
					PARENT_CONTAINER_ID,
					CONTAINER_TYPE,
					LABEL,
					PARENT_INSTALL_DATE,
					locked_position)
				VALUES (
					#container_id#,
					0,
					'collection object',
					'#collection_cde# #catnum# #pn#',
					'#entereddate#',
					0)">
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
	<!--- also pass collection_object_id if and only if we came from DataEntry.cfm --->
	<cfif #cgi.SCRIPT_NAME# contains "DataEntry.cfm">
		<cfset loadedMsg="#loadedMsg#">
	</cfif>
	
<cfelse><!--- something isn't cool --->
	<cfif #len(loadedMsg)# gt 250>
		<cfset loadedMsg = #left(loadedMsg,225)#>
		<cfset loadedMsg = "#loadedMsg# ...{snip}...">
	</cfif>
		
</cfif>
		
</cfoutput>
