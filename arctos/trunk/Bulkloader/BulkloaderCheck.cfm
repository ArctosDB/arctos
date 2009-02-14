
<cfset mcat="#Application.uam_dbo#"> <!--- a read/write user talking to the database --->

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
<cfset loadedMsg = "">

	 		<!--- make sure everything in that record is good to load - 
				check that required fields are present, code table values are matched, etc. 
				Replace nulls with "" and such so we have stuff to feed to Arctos. 
				find existing values that we can load against. 
				Required: taxonomy, higher geography, agents.
			--->
			<!--- check for collection cde early as we use it often when validating ---->
			<cfif len(#collection_object_id#) is 0>
				<cfset loadedMsg = "collection_Object_ID is required.">
			</cfif>
			
			<cfif len(#collection_cde#) is 0>
				<cfset loadedMsg = "#loadedMsg#; ::collection_cde:: is required">
			</cfif>
			<cfquery name="coll" datasource="#mcat#">
				select * from ctcollection_cde where collection_cde = '#collection_cde#'
			</cfquery>
			<cfif coll.recordcount is 0>
				<cfset loadedMsg = "#loadedMsg#; ::collection_cde:: must match code table values.">
			</cfif>

			<cfif len(#institution_acronym#) is 0>
				<cfset loadedMsg = "#loadedMsg#; ::institution_acronym:: is required.">
			<cfelse>
				<cfquery name="getCollId" datasource="#mcat#">
					select collection_id from collection where
					institution_acronym = '#institution_acronym#' and
					collection_cde='#collection_cde#'
				</cfquery>
				<cfif getCollId.recordcount is not 1>
					<cfset loadedMsg = "#loadedMsg#; ::institution_acronym:: (#institution_acronym#) and 
						::collection_cde:: (#collection_cde#) do not resolve to a valid collection ID.">
				</cfif>
					<cfset collection_id = #getCollId.collection_id#>
			</cfif>
			
			
			<!--- 
				See if they've preassigned a cat_num. If they have, make sure it is valid. If not, 
				go find the next available cat_num and use it
			--->
			<cfif len(#cat_num#) gt 0>
				<cfif not isnumeric(#cat_num#)>
					<cfset loadedMsg = "#loadedMsg#; ::cat_num:: must be numeric.">
				</cfif>
				<cfif #cat_num# is 0>
					<cfset loadedMsg = "#loadedMsg#; ::cat_num:: may not be 0. Did you mean NULL?">
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
					<cfset loadedMsg = "#loadedMsg#; Duplicate ::cat_num:: found in database!">
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
					<cfset loadedMsg = "#loadedMsg#; ::began_date:: must be a date.">
				</cfif>
			<cfelse>
				<cfset loadedMsg = "#loadedMsg#; ::began_date:: is required.">
			</cfif>
			
			<cfif not len(#ended_date#) is 0>
				<cfif not isdate(#ended_date#)>
					<cfset loadedMsg = "#loadedMsg#; ::ended_date:: must be a date.">
				</cfif>
			<cfelse>
				<cfset loadedMsg = "#loadedMsg#; ::ended_date:: is required."></cfif>
			
			<cfif len(#verbatim_date#) is 0>
				<cfset loadedMsg = "#loadedMsg#; ::verbatim_date:: is required.">
			</cfif>
			<!--- handle relationships - at this stage, just put them in a temp table on Arctos
				where we can eventually move them over to real tables --->
			<cfif len(#relationship#) gt 0>
				<cfif len(#related_to_num_type#) is 0 or len(#related_to_number#) is 0>
					<cfset loadedMsg = "#loadedMsg#; 
						::related_to_number:: and ::related_to_num_type:: are required when relationship is given.">
				</cfif>
				<cfquery name="isGoodReln" datasource="#mcat#">
					select biol_indiv_relationship from ctbiol_relations where
					biol_indiv_relationship ='#relationship#'
				</cfquery>
				<cfif len(#isGoodReln.biol_indiv_relationship#) is 0>
					<cfset loadedMsg = "#loadedMsg#; #relationship# is not a valid ::relationship::.">
				</cfif>
				<cfquery name="isGoodRelOID" datasource="#mcat#">
					select other_id_type from ctcoll_other_id_type
					where other_id_type='#related_to_num_type#'
				</cfquery>
				<cfif len(#isGoodRelOID.other_id_type#) is 0>
					<cfset loadedMsg = "#loadedMsg#; #related_to_num_type# is not a valid ID type and cannot be in a ::relationship::.">
				</cfif>
			</cfif>
			<!--- 
				There must be one and only one preexisting higher_geog match
			--->
			<cfquery name= "getGeog" datasource="#mcat#">
				SELECT geog_auth_rec_id FROM geog_auth_rec WHERE higher_geog = '#higher_geog#'
			</cfquery>
			<cfif getGeog.recordcount gt 1>
				<cfset loadedMsg = "#loadedMsg#; There are multiple ::higher_geog:: matches for #higher_geog#.">
			  <cfelseif getGeog.recordcount is 0>
					<cfset loadedMsg = "#loadedMsg#; There are no ::higher_geog:: matches for #higher_geog#.">
			</cfif>
					<cfset geogauthrecid = getGeog.geog_auth_rec_id>
			<cfif len(#locality_id#) is 0>
				
				<!--- proceed with normal locality routine --->
				<cfif len(#maximum_elevation#) gt 0>
					<cfif not isnumeric(#maximum_elevation#)>
						<cfset loadedMsg = "#loadedMsg#; ::maximum_elevation:: must be a number.">
					</cfif>
				</cfif>
				<cfif len(#minimum_elevation#) gt 0>
					<cfif not isnumeric(#minimum_elevation#)>
						<cfset loadedMsg = "#loadedMsg#; ::minimum_elevation::  must be a number.">
					</cfif>
				</cfif>
				<cfif len(#maximum_elevation#) gt 0 AND len(#minimum_elevation#) gt 0>
					<cfif #minimum_elevation# gt #maximum_elevation#>
						<cfset loadedMsg = "#loadedMsg#; ::minimum_elevation:: cannot be greater than Maximum Elevation">
					</cfif>
				</cfif>
				<!--- elevation units are required if min or max is used, and not allowed if not. --->
				<cfif len(trim(#minimum_elevation#)) gt 0 OR len(trim(#maximum_elevation#)) gt 0>
					<cfif len(#orig_elev_units#) is 0>
						<cfset loadedMsg = "#loadedMsg#; ::orig_elev_units:: must be specified if elevation is given.">
					</cfif>
					<cfquery name="valElevUnits" datasource="#mcat#">
						SELECT * from ctorig_elev_units where orig_elev_units = '#orig_elev_units#'
					</cfquery>
					<cfif valElevUnits.recordcount eq 0>
						<cfset loadedMsg = "#loadedMsg#; ::orig_elev_units:: must match code table values.">
					</cfif>
				</cfif>
				<cfif len(#spec_locality#) is 0>
					<cfset loadedMsg = "#loadedMsg#; ::spec_locality:: is required.">
				</cfif>
				<!--- See if they put any lat/long stuff in. Some things are conditionally required. --->
			<cfif len(#orig_lat_long_units#) gt 0>
				<cfquery name="valOrigLatLong" datasource="#mcat#">
					select * from ctlat_long_units where orig_lat_long_units='#orig_lat_long_units#'
				</cfquery>
				<cfif valOrigLatLong.recordcount is 0>
					<cfset loadedMsg = "#loadedMsg#; ::orig_lat_long_units:: do not match code table values.">
				</cfif>
				
				<!--- first get format-specific lat/long stuff ---->
				<cfif #orig_lat_long_units# IS "decimal degrees">
					<cfif (len(#dec_lat#) is 0) OR (not isnumeric(#dec_lat#))>
						<cfset loadedMsg = "#loadedMsg#;  ::dec_lat:: is required and must be numeric when orig_lat_long_units is decimal degrees.">
					</cfif>
					<cfif #dec_lat# lt -90 OR #dec_lat# gt 90>
						<cfset loadedMsg = "#loadedMsg#;  ::dec_lat:: must be between -90 and 90">
					</cfif>
					<cfif (len(#dec_long#) is 0) OR (not isnumeric(#dec_long#))>
						<cfset loadedMsg = "#loadedMsg#;  ::dec_long:: is required and must be numeric when orig lat long units is decimal degrees.">
					</cfif>
					<cfif #dec_long# lt -180 OR #dec_long# gt 180>
						<cfset loadedMsg = "#loadedMsg#;  ::dec_long:: must be between -180 and 180">
					</cfif>
				<cfelseif #orig_lat_long_units# IS "deg. min. sec.">
					<cfif len(#latdeg#) is 0 or not isnumeric(#latdeg#)>
						<cfset loadedMsg = "#loadedMsg#;  ::latdeg:: is required and must be numeric when orig_lat_long_units is deg. min. sec.">
					</cfif>
					<cfif #latdeg# lt 0 OR #latdeg# gt 90>
						<cfset loadedMsg = "#loadedMsg#;  ::latdeg::: must be between 0 and 90">
					</cfif>
					<cfif len(#latmin#) is 0 or not isnumeric(#latmin#)>
						<cfset loadedMsg = "#loadedMsg#;  ::latmin:: is required and must be numeric when orig lat long units is deg. min. sec.">
					</cfif>
					<cfif #latmin# lt 0 OR #latmin# gt 90>
						<cfset loadedMsg = "#loadedMsg#;  ::latmin:: must be between 0 and 60">
					</cfif>
					<cfif len(#latsec#) is 0 or not isnumeric(#latsec#)>
						<cfset loadedMsg = "#loadedMsg#;  ::latsec:: is required and must be numeric when orig lat long units is deg. min. sec.">
					</cfif>
					<cfif #latsec# lt 0 OR #latsec# gt 60>
						<cfset loadedMsg = "#loadedMsg#;  ::latsec:: must be between 0 and 60">
					</cfif>
					<cfif len(#longdeg#) is 0 or not isnumeric(#longdeg#)>
						<cfset loadedMsg = "#loadedMsg#;  ::longdeg:: is required and must be numeric when orig lat long units is deg. min. sec.">
					</cfif>
					<cfif #longdeg# lt 0 OR #longdeg# gt 180>
						<cfset loadedMsg = "#loadedMsg#; ::longdeg:: must be between 0 and 180">
					</cfif>
					<cfif len(#longmin#) is 0 or not isnumeric(#longmin#)>
						<cfset loadedMsg = "#loadedMsg#; ::longmin:: is required and must be numeric when orig lat long units is deg. min. sec.">
					</cfif>
					<cfif #longmin# lt 0 OR #longmin# gt 60>
						<cfset loadedMsg = "#loadedMsg#; ::longmin:: must be between 0 and 60">
					</cfif>
					<cfif len(#longsec#) is 0 or not isnumeric(#longsec#)>
						<cfset loadedMsg = "#loadedMsg#; ::longsec:: is required and must be numeric when orig lat long units is deg. min. sec.">
					</cfif>
					<cfif #longsec# lt 0 OR #longsec# gt 60>
						<cfset loadedMsg = "#loadedMsg#; ::longsec:: must be between 0 and 60">
					</cfif>
					<cfif len(#latdir#) is 0>
						<cfset loadedMsg = "#loadedMsg#; ::latdir:: (#latdir#) is required.">
					</cfif>
					<cfif #latdir# is not "N" AND #latdir# is not "S">
						<cfset loadedMsg = "#loadedMsg#;  ::latdir:: (#latdir#) is required and must be N or S when orig lat long units is degrees dec. minutes">
					</cfif>
					<cfif len(#longdir#) is 0>
						<cfset loadedMsg = "#loadedMsg#;  ::longdir:: (#longdir#) is required and must be E or W when orig lat long units is deg. min. sec.">
					</cfif>
					<cfif #longdir# is not "E" AND #longdir# is not "W">
						<cfset loadedMsg = "#loadedMsg#;  ::longdir:: (#longdir#) is required and must be E or W when orig lat long units is deg. min. sec.">
					</cfif>
				
				<cfelseif #orig_lat_long_units# IS "degrees dec. minutes">
					<cfif len(#latdeg#) is 0 or not isnumeric(#latdeg#)>
						<cfset loadedMsg = "#loadedMsg#;  ::latdeg:: is required and must be numeric when orig lat long units is degrees dec. minutes">
					</cfif>
					<cfif #latdeg# lt 0 OR #latdeg# gt 90>
						<cfset loadedMsg = "#loadedMsg#;  ::latdeg:: must be between 0 and 90">
					</cfif>
					<cfif len(#dec_lat_min#) is 0 or not isnumeric(#dec_lat_min#)>
						<cfset loadedMsg = "#loadedMsg#;  ::dec_lat_min:: is required and must be numeric when orig lat long units is degrees dec. minutes">
					</cfif>
					<cfif #dec_lat_min# lt 0 OR #dec_lat_min# gt 60>
						<cfset loadedMsg = "#loadedMsg#;  ::dec_lat_min:: must be between 0 and 60">
					</cfif>
					<cfif len(#latdir#) is 0>
						<cfset loadedMsg = "#loadedMsg#;  ::latdir:: (#latdir#) is required when orig lat long units is degrees dec. minutes">
					</cfif>
					<cfif #latdir# is not "N" AND #latdir# is not "S">
						<cfset loadedMsg = "#loadedMsg#;  ::latdir:: (#latdir#) must be N or S when orig lat long units is degrees dec. minutes">
					</cfif>
					<cfif len(#longdeg#) is 0 or not isnumeric(#longdeg#)>
						<cfset loadedMsg = "#loadedMsg#;  ::longdeg:: is required and must be numeric when orig lat long units is degrees dec. minutes">
					</cfif>
					<cfif #longdeg# lt 0 OR #longdeg# gt 180>
						<cfset loadedMsg = "#loadedMsg#;  ::longdeg:: must be between 0 and 180">
					</cfif>
					<cfif len(#dec_long_min#) is 0 or not isnumeric(#dec_long_min#)>
						<cfset loadedMsg = "#loadedMsg#;  ::dec_long_min:: is required and must be numeric when orig lat long units is degrees dec. minutes">
					</cfif>
					<cfif #dec_long_min# lt 0 OR #dec_long_min# gt 60>
						<cfset loadedMsg = "#loadedMsg#;  ::dec_long_min:: must be between 0 and 60">
					</cfif>
					<cfif len(#longdir#) is 0>
						<cfset loadedMsg = "#loadedMsg#;  ::longdir:: (#longdir#) is required when orig lat long units is deg. min. sec.">
					</cfif>
					<cfif #longdir# is not "E" AND #longdir# is not "W">
						<cfset loadedMsg = "#loadedMsg#;  ::longdir:: (#longdir#) and must be E or W when orig lat long units is deg. min. sec.">
					</cfif>
				<cfelseif #orig_lat_long_units# IS "UTM">
					<!--- let em in...--->
				<cfelse>
					<cfset loadedMsg = "#loadedMsg#; I do not know how to handle ::orig_lat_long_units:: #orig_lat_long_units#">
				</cfif>
				<!--- now get the universsal lat/long stuff --->
				<cfif len(#datum#) gt 0>
					<cfquery name="valdatum" datasource="#mcat#">
						select * from ctdatum where datum ='#datum#'
					</cfquery>
					<cfif valdatum.recordcount is 0>
						<cfset loadedMsg = "#loadedMsg#; ::datum:: must match code table values.">
					</cfif>
				<cfelse>
					<cfset loadedMsg = "#loadedMsg#; ::datum:: is required.">
				</cfif>
				<cfif len(#determined_by_agent#) gt 0>
					<cfquery name="getLLAgnt" datasource="#mcat#">
						select agent_id from agent_name where agent_name = '#determined_by_agent#'
						and agent_name_type <> 'Kew abbr.'
					</cfquery>
					<cfif getLLAgnt.recordcount is 0>
						<cfset loadedMsg = "#loadedMsg#; The lat long ::determined_by_agent:: was not found.">
					  <cfelseif getLLAgnt.recordcount gt 1>
						<cfset loadedMsg = "#loadedMsg#; The lat long ::determined_by_agent:: returned more than one match. Please enter an agent anme (not necessarily the preferred name) that uniquely identifies the agent who determined the lat_long.">
					<cfelse>
						<cfset llagentid = getLLAgnt.agent_id>
					</cfif>
							
				</cfif>
				<cfif len(#determined_date#) is 0>
					<cfset loadedMsg = "#loadedMsg#; Lat Long ::determined_date:: is required.">
				<cfelse>
					<cfif not isdate(#determined_date#)>
						<cfset loadedMsg = "#loadedMsg#; Lat Long ::determined_date:: must be a date.">
					</cfif>
				</cfif>
				<cfif len(#lat_long_ref_source#) is 0>
					<cfset loadedMsg = "#loadedMsg#; ::lat_long_ref_source:: is required">
				</cfif>
				<cfif len(#max_error_distance#) gt 0>
					<cfif len(#max_error_units#) is 0>
						<cfset loadedMsg = "#loadedMsg#; ::max_error_units:: is required if max error is not null.">
					</cfif>
					<cfif not isnumeric(#max_error_distance#)>
						<cfset loadedMsg = "#loadedMsg#; ::max_error_distance:: must be numeric">
					</cfif>
					<cfquery name="valMED" datasource="#mcat#">
						select * from CTLAT_LONG_ERROR_UNITS where LAT_LONG_ERROR_UNITS ='#max_error_units#'
					</cfquery>
					<cfif valMED.recordcount is 0>
						<cfset loadedMsg = "#loadedMsg#; ::max_error_units:: must match code table values">
					</cfif>
				</cfif>
			</cfif><!---- end lat/long validation ---->
					<cfif len(#verbatim_locality#) is 0>
						<cfset loadedMsg = "#loadedMsg#;  ::verbatim_locality:: is required.">
					</cfif>
				
				
				
				
				
				
				<!---- end normal locality-checking routine ---->
			<cfelse>
				<!--- just make sure we got a valid locality_id --->
				<cfquery name="isValidLocId" datasource="#mcat#">
					select locality_id from locality where locality_id=#locality_id#
				</cfquery>
				<cfif #len(isValidLocId.locality_id)# is 0>
					<cfset loadedMsg = "#loadedMsg#; You specified a pre-existing locality ID that does not exist.">
				</cfif>
			</cfif><!--- end use existing locality check --->
			<cfif  len(#coll_obj_disposition#) is 0>
				<cfset loadedMsg = "#loadedMsg#;  ::coll_obj_disposition:: -#coll_obj_disposition#- is required.">
			</cfif>
			<cfquery name="coll_obj_disposition" datasource="#mcat#">
				select coll_obj_disposition from ctcoll_obj_disp
			</cfquery>
				<cfif #coll_obj_disposition.recordcount# is 0>
					<cfset loadedMsg = "#loadedMsg#;  ::coll_obj_disposition:: was not found in the code table.">
				</cfif>			
			<cfif not len(#condition#) gt 0>
				<cfset loadedMsg = "#loadedMsg#; ::condition:: is required">
			</cfif>
		
			
			<cfif len(#made_date#) gt 0>				
				<cfif not isdate(#made_date#)>
					<cfset loadedMsg = "#loadedMsg#; ID ::made_date:: must be a date.">
				</cfif>
			</cfif>
			
			<cfif not len(#nature_of_id#) gt 0>
				<cfset loadedMsg = "#loadedMsg#;  ::nature_of_id:: is required">
			</cfif>
			<cfquery name= "valNatureOfId" datasource="#mcat#">
					SELECT nature_of_id FROM ctnature_of_id WHERE nature_of_id = '#nature_of_id#'
			</cfquery>
			<cfif valNatureOfId.recordcount is 0>
				<cfset loadedMsg = "#loadedMsg#; ::nature_of_id:: must match code table values.">
			</cfif>
			
			<cfif not len(#taxon_name#) gt 0>
				<cfset loadedMsg = "#loadedMsg#; ::taxon_name:: is required.">
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
			<cfelseif right(taxon_name,2) is " ?">
				<!---- handle A + "?" taxa formula ---->
				<cfset taxon_name=left(taxon_name,len(taxon_name) -2)>
				<cfset taxa_formula = "A ?">
				<cfset TaxonomyTaxonName=left(taxon_name,len(taxon_name) - 2)>
			<!---
			<cfelseif Compare(taxon_name, " X ")>
			<cfset loadedMsg = "#loadedMsg#X">
				<!---- handle hybrids ---->
				<cfset xPos = find(" X ",taxon_name)>
				<cfif #xPos# gt 0>
					it is <cfflush>
					<cfset nameone = left(taxon_name,xPos-1)>
					<cfset nameTwo = mid(taxon_name,xPos + 3,(len(taxon_name) - xPos))>
					<cfset taxa_formula = "A X B">
					<cfset taxon_name=left(taxon_name,len(taxon_name) -4)>
					<cfset loadedMsg = "#loadedMsg#;#taxon_name#:hybrid:#nameone#;#nameTwo#:">
					
				<cfelse>
					<cfset loadedMsg = "#loadedMsg#; NO X??">
				</cfif>
				<!--- just so we don't kill the query below...--->
				<cfset TaxonomyTaxonName= "Mus musculus">
				--->
			<cfelse>
				<cfset  taxa_formula = "A">
				<cfset TaxonomyTaxonName="#taxon_name#">
			</cfif>
			<cfquery name= "getTaxa" datasource="#mcat#">
				SELECT taxon_name_id FROM taxonomy WHERE scientific_name = '#TaxonomyTaxonName#'
				AND valid_catalog_term_fg=1
			</cfquery>
			
			<cfif getTaxa.recordcount is 0>
				<cfset loadedMsg = "#loadedMsg#;  ::taxon_name:: (#taxon_name#) not found.">
			<cfelseif getTaxa.recordcount gt 1>
				<cfset loadedMsg = "#loadedMsg#; Multiple ::taxon_name:: (#taxon_name#) matches found">
			</cfif>
			<!---<cfset loadedMsg = "#loadedMsg#;#getTaxa.recordcount#">--->
					<cfset taxonnameid = getTaxa.taxon_name_id>
			
			<!-------------------- depth ----------------------------->
			<cfif len(#min_depth#) gt 0 OR len(#max_depth#) gt 0 OR len(#depth_units#) gt 0>
				<!---- if we got one, we need them all ---->
				<cfif len(#min_depth#) is 0 OR len(#max_depth#) is 0 OR len(#depth_units#) is 0>
					<cfset loadedMsg = "#loadedMsg#; ::min_depth::, ::max_depth::, and ::depth_units:: are all required if one is given.">
				</cfif>
				
				<cfif not isnumeric(#min_depth#) OR not isnumeric(#max_depth#)>
					<cfset loadedMsg = "#loadedMsg#; ::min_depth:: and ::max_depth:: must be numeric.">
				</cfif>
				<cfquery name="valDepthUnits" datasource="#mcat#">
					select depth_units from ctdepth_units where depth_units='#depth_units#'
				</cfquery>
				<cfif #valDepthUnits.recordcount# is not 1>
					<cfset loadedMsg = "#loadedMsg#; ::depth_units:: was not found in the code table.">
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
					<cfset loadedMsg = "#loadedMsg#; ::attribute_#i#:: (#thisAttributeValue#) does not match code table values for collection #collection_cde#.">
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
										SELECT #columnName# as valCodes from valCT
										WHERE #columnName# =  '#thisValueValue#'
										AND collection_cde='#collection_cde#'
									</cfquery>
									
								  <cfelse>
								 	<cfquery name="valCodes" dbtype="query">
										SELECT #columnName# as valCodes from valCT
										WHERE #columnName# =  '#thisValueValue#'
									</cfquery>
									
								</cfif>
								<cfset validValueFlag="">
								<cfloop query="valCodes">
									<cfif #valCodes.valCodes# is #thisValueValue#>
										<cfset validValueFlag = "#validValueFlag#true">
									</cfif>
								</cfloop>
								<cfif len(#validValueFlag#) is 0>									
									<cfset loadedMsg = "#loadedMsg#; ::attribute_value_#i#:: (#thisValueValue#) is code table controlled and does not match code table values.">
								</cfif>
				  </cfif>
						<cfelse><!---- attribute_value was null --->
							<cfset loadedMsg = "#loadedMsg#; ::attribute_value_#i#:: (#thisValueValue#) is required when Attribute #i# is given.">
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
									SELECT #columnName# as unitCodes from unitCT
									WHERE collection_cde='#indiv.collection_cde#'
								</cfquery>
							  <cfelse>
						
								<cfquery name="unitCodes" dbtype="query">
									SELECT #columnName# as unitCodes from unitCT
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
						<cfset loadedMsg = "#loadedMsg#; ::attribute_units_#i#:: (#thisAttUnit#) do not match CT values.">
					</cfif>
		  			<!---- they have a valid units code table, so go back and make sure the value they 
						gave is numeric --->
					<cfif not isnumeric(#thisValueValue#)>
						<cfset loadedMsg = "#loadedMsg#; ::attribute_value_#i#:: (#thisAttUnit#) must be numeric for #thisAttributeValue#">
					</cfif>
		  <cfelse>
							<!---- not code table controlled, leave it null for now - all units are 
							either CT controlled or NULL--->
							<!--- see if they tried to put anything in here --->
							<cfif len(#thisUnitsValue#) gt 0>
									<cfset loadedMsg = "#loadedMsg#; You cannot have attribute units for ::attribute_#i#::">
							</cfif>
					</cfif><!--- end CT check --->
				 <cfelse>
					 <!--- att val units not given, see if it should be --->
					 	<cfquery name="isUnitCt" datasource="#mcat#">
							SELECT units_code_table FROM ctattribute_code_tables WHERE
							attribute_type = '#thisAttributeValue#'
						</cfquery>
						<cfif #isUnitCt.recordcount# gt 0 and len(#isUnitCt.units_code_table#) gt 0>
							
							<cfset loadedMsg = "#loadedMsg#; A value for ::attribute_units_#i#:: is required.">
						</cfif>
					</cfif>
					
					<cfif len(#thisDateValue#) gt 0>
						<cfif not isdate(#thisDateValue#)>
						 	<cfset loadedMsg = "#loadedMsg#; ::attribute_date_#i#:: (#thisDateValue#) is not a date">
					  </cfif>
					</cfif>
					
					<cfif len(#thisDeterminerValue#) gt 0>
						<cfquery name="attDet1" datasource="#mcat#">
							SELECT agent_id FROM agent_name WHERE agent_name = '#thisDeterminerValue#'
							and agent_name_type <> 'Kew abbr.'
						</cfquery>
						<cfif #attDet1.recordcount# is 0>
							<cfset loadedMsg = "#loadedMsg#; ::attribute_determiner_#i#:: (#thisDeterminerValue#) was not found.">
						</cfif>
						<cfif #attDet1.recordcount# gt 1>
							<cfset loadedMsg = "#loadedMsg#; ::attribute_determiner_#i#:: (#thisDeterminerValue#) matched more than one existing agent name.">
						</cfif>
					<cfelse>
						<cfset loadedMsg = "#loadedMsg#; ::attribute_determiner_#i#:: may not be null.">
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
	
	
		<cfif len(#thisIDNumberValue#) gt 0>
			<!---- we got an other ID for this loop---->
			<cfif len(#thisIDTypeValue#) is 0>
				<cfset loadedMsg = "#loadedMsg#; You must supply ::#thisIDType#:: for ::#thisIDNumber#::">
			</cfif>
			<cfquery name="oidType" datasource="#mcat#">
				select * from ctcoll_other_id_type where other_id_type = '#thisIDTypeValue#'
			</cfquery>
			<cfif oidType.recordcount is 0>
				<cfset loadedMsg = "#loadedMsg#; ::#thisIDType#:: (#thisIDTypeValue#) is not in the code table.">
			</cfif>
		</cfif>
</cfloop>

			
			<cfif not len(#id_made_by_agent#) gt 0>
				<cfset loadedMsg = "#loadedMsg#; ::id_made_by_agent:: is required.">
			</cfif>
			<cfquery name= "valIdBy" datasource="#mcat#">
				SELECT agent_id FROM agent_name WHERE agent_name = '#id_made_by_agent#' 
				and agent_name_type <> 'Kew abbr.'
			</cfquery>
			<cfif valIdBy.recordcount is 0>
					<cfset loadedMsg = "#loadedMsg#; ::id_made_by_agent:: (#id_made_by_agent#) was not found.">
			<cfelseif valIdBy.recordcount gt 1>
					<cfset loadedMsg = "#loadedMsg#;  ::id_made_by_agent:: (#id_made_by_agent#) agent matched more than one agent.">
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
			<cfset loadedMsg = "#loadedMsg#;  ::collector_agent_1:: is required.">
		</cfif>
		<cfif not #thisCollectorRole# is "c">
			<cfset loadedMsg = "#loadedMsg#; ::collector_role_1:: is required and must be c">
		</cfif>
	</cfif>
	<cfif len(#thisCollector#) gt 0>
		<cfquery name= "getColl" datasource="#mcat#">
			SELECT agent_id FROM agent_name WHERE agent_name = '#thisCollector#'
			and agent_name_type <> 'Kew abbr.'
		</cfquery>
		<cfif len(#getColl.agent_id#) is 0>
			<cfset loadedMsg = "#loadedMsg#;  ::collector_agent_#i#:: (#thisCollector#) not found">
		<cfelseif getColl.recordcount gt 1>
			<cfset loadedMsg = "#loadedMsg#;  ::collector_agent_#i#:: (#thisCollector#) has multiple matches.">
		</cfif>
		<cfif #thisCollectorRole# is not "c" AND #thisCollectorRole# is not "p">
			<cfset loadedMsg = "#loadedMsg#;  ::collector_role_#i#:: must be c or p">
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
			<cfset loadedMsg = "#loadedMsg#; ::part_name_1:: is required. ">
		</cfif>
	</cfif>
	<cfif len(#thisPartName#) gt 0>
		<cfquery name= "valPartName" datasource="#mcat#">
				SELECT part_name FROM ctspecimen_part_name WHERE part_name = '#thisPartName#' 
				and collection_cde='#collection_cde#'
		</cfquery>
		<cfif valPartName.recordcount is 0>
			<cfset loadedMsg = "#loadedMsg#; ::part_name_#i#:: (#thisPartName#) must match code table values for #collection_cde#.">
		</cfif>
		
		<cfif len(#thisPresMeth#) gt 0>
			<cfquery name= "valPartPres" datasource="#mcat#">
				SELECT preserve_method FROM ctspecimen_preserv_method 
				WHERE preserve_method = '#thisPresMeth#' 
				and collection_cde='#collection_cde#'
			</cfquery>
			<cfif valPartPres.recordcount is 0>
				<cfset loadedMsg = "#loadedMsg#;  ::preserv_method_#i#:: (#thisPresMeth#) must match code table values">
			</cfif>
		</cfif>
		<cfif len(#thisPartCondition#) is 0>
			<cfset loadedMsg = "#loadedMsg#; ::part_condition_#i#:: may not be null.">
		</cfif>
		
		<cfif len(#thisPartBarCode#) GT 0>
			<cfquery name="getID" datasource="#mcat#">
				select container_id from container where barcode = '#thisPartBarCode#'
			</cfquery>
			<cfif #getID.recordcount# neq 1>
				<cfset loadedMsg = "#loadedMsg#; ::part_barcode_#i#:: (#thisPartBarCode#) was not found. Barcodes must match pre-existing containers">
			</cfif>
			<cfif len (#thisPartContainerLabel#) is 0>
				<cfset loadedMsg = "#loadedMsg#; ::container_label_#i#:: is required when loading barcodes.">
			</cfif>
		<cfelseif len (#thisPartContainerLabel#) gt 0>
			<!---- label but no barcode ---->
			<cfset loadedMsg = "#loadedMsg#; You must supply a barcode for ::container_label_#i#::">
		</cfif>
	</cfif>
</cfloop>
	
	<cfset ccSQL = "SELECT collection_id from collection 
		WHERE collection_cde = '#collection_cde#' AND institution_acronym = '#institution_acronym#'">
	<cfquery name="getCollID" datasource="#mcat#">
		#preservesinglequotes(ccSQL)#
	</cfquery>
	<cfset collectionid = #getCollID.collection_id#>
	
		
	<cfif len(#accn#) is 0>
		<cfset loadedMsg = "#loadedMsg#;  ::accn:: may not be null.">
	</cfif>
	<cfif #accn# contains "[" and #accn# contains "]">
		<cfset p = find(']',accn)>
		<cfset ia = mid(accn,2,p-2)>	
		<cfset ac = mid(accn,p+1,len(accn))>
	<cfelse>
		<cfset ac=accn>
		<cfset ia=institution_acronym>
	</cfif>		
	<cfquery name="getTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			accn.transaction_id
		FROM
			accn,
			trans,
			collection
		WHERE
			accn.transaction_id = trans.transaction_id AND
			trans.collection_id=collection.collection_id and
			accn.accn_number = '#ac#' and
			collection.institution_acronym = '#ia#'
	</cfquery>
	<cfif #len(getTrans.transaction_id)# gt 0>
		<cfset transactionid = getTrans.transaction_id>
	<cfelse>
		<cfset loadedMsg = "#loadedMsg#; You must specify a valid, pre-existing ::accn:: number.">		
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
				
			
			
			
			<cfif len(#flags#) gt 0>
				<cfquery name="ctFlags" datasource="#mcat#">
					select * from ctflags where flags = '#flags#'
				</cfquery>
				<cfif ctFlags.recordcount is 0>
					<cfset loadedMsg = "#loadedMsg#;  Flags does not match code table values.">
				</cfif>
			</cfif>	
			<cfif len(#collecting_source#) gt 0>
				<cfquery name="ctcollecting_source" datasource="#mcat#">
					select collecting_source from ctcollecting_source where collecting_source = '#collecting_source#'
				</cfquery>
				<cfif ctcollecting_source.recordcount is 0>
					<cfset loadedMsg = "#loadedMsg#;  ::collecting_source:: does not match code table values.">
				</cfif>
			</cfif>	
			<cfif len(#georefmethod#) gt 0>
				<cfquery name="ctgeorefmethod" datasource="#mcat#">
					select * from ctgeorefmethod where georefmethod = '#georefmethod#'
				</cfquery>
				<cfif ctgeorefmethod.recordcount is 0>
					<cfset loadedMsg = "#loadedMsg#;  ::georefmethod:: (#georefmethod#) does not match code table values.">
				</cfif>
			<cfelse>
				<cfset loadedMsg = "#loadedMsg#;  ::georefmethod:: is required.">
			</cfif>			
	</cfoutput>