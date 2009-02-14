<cfinclude template = "includes/_header.cfm">

<cfoutput>

<!--- find print_fg'd containers --->
<cfquery name="print_fg" datasource="#Application.uam_dbo#">
	select container_id from container where print_fg > 0
</cfquery>
<cfset flagged_cont_id = "">
<cfloop query="print_fg">
	<cfif len(#flagged_cont_id#) gt 0>
		<cfset flagged_cont_id = "#flagged_cont_id#,#print_fg.container_id#">
	  <cfelse>
	  	<cfset flagged_cont_id = "#print_fg.container_id#">
	</cfif>
</cfloop>
<!--- get the container (coll_obj) that is in these flagged containers --->
<cfquery name="flagItems" datasource="#Application.uam_dbo#">
	SELECT
		container.container_id,
		collection_object_id
	FROM
		container,
		coll_obj_cont_hist
	WHERE
		container.container_id = coll_obj_cont_hist.container_id AND
		parent_container_id IN (#flagged_cont_id#)
</cfquery>
<cfset partID = "">
<cfloop query="flagItems">
	<cfif len(#partID#) gt 0>
		<cfset partID = "#partID#,#flagItems.collection_object_id#">
	  <cfelse>
	  	<cfset partID = "#flagItems.collection_object_id#">
	</cfif>
</cfloop>
<cfquery name="getCollObjIds" datasource="#Application.uam_dbo#">
	select 
		cataloged_item.collection_object_id 
	FROM
		cataloged_item,
		specimen_part
	WHERE
		cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
		specimen_part.collection_object_id IN (#partID#)
</cfquery>

<CFSET collobjid = "0">
<cfloop query="getCollObjIds">
	<CFSET collobjid = "#collobjid#,#collection_object_id#">
</cfloop>
#collobjid#
</cfoutput>



<cfset getDM = "SELECT 
	cataloged_item.collection_object_id,
	institution_acronym,
	collection.collection_cde,
	cat_num,
	scientific_name,
	dec_lat,
	dec_long,
	datum,
	max_error_distance,
	max_error_units,
	lat_long_ref_source,
	country,
	sea,
	island,
	state_prov,	
	quad,
	county,
	feature,
	spec_locality,
	maximum_elevation,
	minimum_elevation,
	orig_elev_units,
	verbatim_date,
	sex_cde,
	sex_cde_mod,
	age_class,
	preferred_agent_name.agent_name,
	coll_order,
	part_name,
	part_modifier,
	preserve_method,
	specimen_part.collection_object_id as partid,
	other_id_type,
	other_id_num,
			coll_object_remarks,
			repro_data,
			accn_num_prefix,
					accn_num,
					accn_num_suffix,
					weight,
					weight_units,
					total_length,
					tail_length,
					hind_foot_length,
					ear_length,
					length_units
FROM 
	identification,
	collecting_event,
	locality,
	accepted_lat_long,
	geog_auth_rec,
	cataloged_item,
	taxonomy,
	collection, 
	collector, 
	preferred_agent_name,
	accn,
	coll_obj_other_id_num,	
	specimen_part,
	biol_indiv,
			coll_object_encumbrance,
			encumbrance,
			preferred_agent_name encumbering_agent
			,coll_object_remark
			,biol_indiv_remark
			,coll_object,
			mammal
WHERE locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id 
	AND collecting_event.locality_id = locality.locality_id 
	AND cataloged_item.collecting_event_id = collecting_event.collecting_event_id 
	AND identification.taxon_name_id = taxonomy.taxon_name_id 
	AND cataloged_item.collection_object_id = identification.collection_object_id 
	AND identification.accepted_id_fg = 1 
	AND cataloged_item.collection_id = collection.collection_id 
	AND cataloged_item.collection_object_id = collector.collection_object_id
	AND collector.agent_id = preferred_agent_name.agent_id
	AND collector.collector_role='c'
	AND accn.transaction_id = cataloged_item.accn_id
	AND cataloged_item.collection_object_id = specimen_part.derived_from_cat_item (+)
	AND cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id (+)
	AND locality.locality_id = accepted_lat_long.locality_id (+)
	AND cataloged_item.collection_object_id = biol_indiv.collection_object_id (+) AND
			cataloged_item.collection_object_id=coll_object_encumbrance.collection_object_id (+) AND
			coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id (+)	AND 
			encumbrance.encumbering_agent_id = encumbering_agent.agent_id (+) 
			AND cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+) 
			AND cataloged_item.collection_object_id = biol_indiv_remark.collection_object_id (+) 
			AND cataloged_item.collection_object_id = coll_object.collection_object_id
			AND cataloged_item.collection_object_id = mammal.collection_object_id (+)
			AND cataloged_item.collection_object_id IN (#collobjid#)
">
<!------>
<!--- get everthing from the server --->

<cfquery name="getDM" datasource = "#Application.web_user#">
#preserveSingleQuotes(getDM)#
</cfquery>


<!--- get unique collection_object_ids --->
<cfquery name="uniqueCollObjId" dbtype="query">
	select distinct(collection_object_id) from getDM
</cfquery>
<!--- make a list of unique collection_object_ids --->
<cfset collobjids = valuelist(uniqueCollObjId.collection_object_id)>
<!--- build a query object to hold all data --->
<cfset AllData = querynew("
	collection_object_id,
	institution_acronym,
	collection_cde,
	cat_num,
	scientific_name,
	af_num,
	dec_lat,
	dec_long,
	datum,
	max_error_distance,
	max_error_units,
	lat_long_ref_source,
	country,
	sea,
	island,
	state_prov,	
	quad,
	county,
	feature,
	spec_locality,
	elevation,
	verbatim_date,
	sex_cde,
	sex_cde_mod,
	collectors,
	parts,
	OIDs,
	OIDLs,
					coll_object_remarks,
					repro_data,
					age_class,
					accn_number,
					measurements,
					ContainerLabel,
					VialLabel")>

<cfquery name="getColl" dbtype="query">
	select distinct(collection_cde) from getDM
</cfquery>
<cfset coll = valuelist(getColl.collection_cde)>

<!--- do all this - ie, add a row to AllData - for every unique collection_object_id in our list ---->
<cfloop index="i" from="1" to = "#uniqueCollObjId.recordcount#">

<!--- get the first/next collection_object_id to work with --->		
<cfset thisRecord = listgetat(collobjids, #i#)>
<!--- get collector information for that collection_object_id --->
<cfquery name="getColl" dbtype="query">
	SELECT 
		collection_object_id, agent_name, coll_order
		FROM getDM WHERE collection_object_id = #thisRecord# 
		GROUP BY collection_object_id, agent_name, coll_order
		order by coll_order
</cfquery>

		<!---concatenate agents --->
			<cfset AgentString = "">
			<cfset numAgnt = #getColl.recordcount#>
			<cfset AgntLoop = 1>
			<cfloop query="getColl">
				<cfoutput>
					<cfif AgntLoop lt #numAgnt#>
						<cfset AgentString = "#AgentString# #agent_name#;">
					<cfelse>
						<cfset AgentString = "#AgentString# #agent_name#">
					</cfif>
					<cfset AgentString = #trim(AgentString)#>
	
			<cfset AgntLoop = #AgntLoop# + 1>
		</cfoutput>
	</cfloop>

	
	<!---
	<cfoutput query="getColl">
		<cfset AgentString = "#AgentString# #agent_name#<br>">
	</cfoutput>
	<!--- strip the trailing comma --->
		<cfset agentString = replace(reverse(#AgentString#),">rb<","","first")>
		<cfset agentString = reverse(#AgentString#)>--->
<!--- do the same for parts --->
<cfquery name="getPart" dbtype="query">
	SELECT 
		collection_object_id, 
		part_name, 
		partid,
		part_modifier,
		preserve_method
	FROM getDM 
	WHERE collection_object_id = #thisRecord#
	GROUP BY 
		collection_object_id, 
		part_name, 
		partid,
		part_modifier,
		preserve_method
	ORDER BY part_name
</cfquery>
	<cfset PartString = "">
	<cfset numPart = #getPart.recordcount#>
	<cfset partLoop = 1>
	<cfloop query="getPart">
		<cfoutput>
			<cfset part = "#part_name#">
			<cfif len(#part_modifier#) gt 0>
				<cfset part = "#part_modifier# #part#">
			</cfif>
			<cfif len(#preserve_method#) gt 0>
				<cfset part = "#part# (#preserve_method#)">
			</cfif>
			<cfif partLoop lt #numPart#>
				<cfset PartString = "#trim(PartString)# #trim(part)#;">
			<cfelse>
				<cfset PartString = "#trim(PartString)# #trim(part)#">
			</cfif>
			<cfset PartString = #trim(PartString)#>
			<cfset partLoop = #partLoop# + 1>
		</cfoutput>
	</cfloop>
	
<!--- do the same for tissues --->
<!---- get a unique collection_object_id / tissue_type combination to display --->

<!--- get unique collection_object_id / tissue_type / tissid so we can count it tissid (the number of samples) for each combinations --->

	
<!--- do the same for other_ids --->
<cfquery name="getOID" dbtype="query">
	SELECT 
		collection_object_id, other_id_num, other_id_type 
		FROM getDM WHERE collection_object_id = #thisRecord#
		GROUP BY collection_object_id, other_id_num, other_id_type 
</cfquery>
<!--- build a query object to hold concatenated part list --->
	<cfset OIDString = "">
	<cfset OIDLString = "">
	<cfset numOID = #getOID.recordcount#>
	<cfset OIDLoop = 1>
	<cfloop query="getOID">
		<cfoutput>
			<cfif OIDLoop lt #numOID#>
				<cfif #other_id_type# is "GenBank sequence accession">
					<cfset OIDString = "#OIDString# <a href=""http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Search&db=Nucleotide&term=#other_id_num#&doptcmdl=GenBank"" Target=""#session.target#"">#other_id_num# (#other_id_type#)</a>;">
				<cfelse>
					<cfset OIDString = "#OIDString# #other_id_num# (#other_id_type#);">
				</cfif>
				<cfset OIDLString = "#OIDLString# #other_id_num# (#other_id_type#);">
			<cfelse>
				<cfif #other_id_type# is "GenBank sequence accession">
					<cfset OIDString = "#OIDString# <a href=""http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Search&db=Nucleotide&term=#other_id_num#&doptcmdl=GenBank"" Target=""#session.target#"">#other_id_num# (#other_id_type#)</a>">
				<cfelse>
					<cfset OIDString = "#OIDString# #other_id_num# (#other_id_type#)">
				</cfif>
					<cfset OIDLString = "#OIDLString# #other_id_num# (#other_id_type#)">
			</cfif>
			
		<cfif #OIDString# contains "()"><!--- we got nothing --->
			<cfset OIDString = "">
			<cfset OIDLString = "">
		</cfif>
		<cfset OIDLoop = #OIDLoop# + 1>
		</cfoutput>
	</cfloop>
	
	<cfquery name="getAF" dbtype="query">
		select other_id_num from getDM where other_id_type = 'AF Number'
		and collection_object_id = #thisRecord#
	</cfquery>
	
	
<!--- insert everything into the alldata query --->		
		<!--- get single-row values from getDM. Use grouping to return one row ---->
		<cfquery name="getSingle" dbtype="query">
			SELECT 
				institution_acronym,
				collection_cde,
				cat_num,
				scientific_name,
				dec_lat,
				dec_long,
				datum,
				max_error_distance,
				max_error_units,
				lat_long_ref_source,
				country,
				sea,
				island,
				state_prov,	
				quad,
				county,
				feature,
				spec_locality,
				maximum_elevation,
				minimum_elevation,
				orig_elev_units,
				verbatim_date,
				sex_cde,
				sex_cde_mod,
					coll_object_remarks,
					repro_data,
					age_class,
					accn_num_prefix,
					accn_num,
					accn_num_suffix,
					weight,
					weight_units,
					total_length,
					tail_length,
					hind_foot_length,
					ear_length,
					length_units
			FROM getDM WHERE collection_object_id = #thisRecord# 
			GROUP BY institution_acronym,
				collection_cde,
				cat_num,
				scientific_name,
				dec_lat,
				dec_long,
				datum,
				max_error_distance,
				max_error_units,
				lat_long_ref_source,
				country,
				sea,
				island,
				state_prov,	
				quad,
				county,
				feature,
				spec_locality,
								maximum_elevation,
				minimum_elevation,
				orig_elev_units,
				verbatim_date,
				sex_cde,
				sex_cde_mod,
					coll_object_remarks,
					repro_data,
					age_class,
				accn_num_prefix,
					accn_num,
					accn_num_suffix,
					weight,
					weight_units,
					total_length,
					tail_length,
					hind_foot_length,
					ear_length,
					length_units
		</cfquery>
		<!----------------- container labels ------------------------------->
		<cfquery name="getLabel" datasource="#Application.uam_dbo#">
		SELECT
			part_name,
			parentContainer.label,
			parentContainer.print_fg
		FROM
			coll_obj_cont_hist,
			container,
			container parentContainer,
			specimen_part
		WHERE
			specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id
			AND coll_obj_cont_hist.container_id = container.container_id
			AND container.parent_container_id = parentContainer.container_id
			AND specimen_part.derived_from_cat_item = #thisRecord#
			AND parentContainer.print_fg =1
	</cfquery>
	
	<cfoutput>
	<cfset  thisBatch = "">
	<cfset a=1>
	<cfset ulabel = "">
		<cfquery name="dLabel" dbtype="query">
			select label from getLabel group by label
		</cfquery>
		
		
		<cfloop query="dLabel">
				<cfquery name="lPart" dbtype="query">
					SELECT part_name, label FROM getLabel
					WHERE label = '#dLabel.label#'
				</cfquery>
				
				<cfset thisCont = "#lPart.label#">
					<cfloop query="lPart">
						<cfif #thisCont# is "#lPart.label#"><!--- first time through --->
							<cfset thisCont = "#thisCont#; #lpart.part_name#">
						  <cfelse>
							<cfset thisCont = "#thisCont#, #lpart.part_name#">	
						</cfif>
						<cfset a=#a#+1>
						<!--- concatentate this --->
						<cfif len(#thisBatch#) is 0><!--- first time through --->
							<cfset  thisBatch = "#thisCont#">
						  <cfelse>
						  	<cfif left(#thisCont#,1) is ",">
									<cfset thisBatch = "#thisBatch##thisCont#">
								<cfelse>
									<cfset thisBatch = "#thisBatch#<br>#thisCont#">
							</cfif>
							
						</cfif>
						<cfset thisCont = ""><!--- reset for new part--->
					</cfloop>
	</cfloop>
		<cfset thisContainer = #thisBatch#>
	</cfoutput>
			<!----------------- end container labels ------------------------------->
			<!----------------- vial labels ------------------------------->
<cfquery name="getLabel" datasource="#Application.uam_dbo#">
		SELECT
			part_name,
			parentContainer.label,
			parentContainer.print_fg
		FROM
			coll_obj_cont_hist,
			container,
			container parentContainer,
			specimen_part
		WHERE
			specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id
			AND coll_obj_cont_hist.container_id = container.container_id
			AND container.parent_container_id = parentContainer.container_id
			AND specimen_part.derived_from_cat_item = #thisRecord#
			AND parentContainer.print_fg =2
	</cfquery>
	
	<cfoutput>
	<cfset  thisBatch = "">
	<cfset a=1>
	<cfset ulabel = "">
		<cfquery name="dLabel" dbtype="query">
			select label from getLabel group by label
		</cfquery>
		
		
		<cfloop query="dLabel">
				<cfquery name="lPart" dbtype="query">
					SELECT part_name, label FROM getLabel
					WHERE label = '#dLabel.label#'
				</cfquery>
				
				<cfset thisCont = "#lPart.label#">
					<cfloop query="lPart">
						<cfif #thisCont# is "#lPart.label#"><!--- first time through --->
							<cfset thisCont = "#thisCont#; #lpart.part_name#">
						  <cfelse>
							<cfset thisCont = "#thisCont#, #lpart.part_name#">	
						</cfif>
						<cfset a=#a#+1>
						<!--- concatentate this --->
						<cfif len(#thisBatch#) is 0><!--- first time through --->
							<cfset  thisBatch = "#thisCont#">
						  <cfelse>
						  	<cfif left(#thisCont#,1) is ",">
									<cfset thisBatch = "#thisBatch##thisCont#">
								<cfelse>
									<cfset thisBatch = "#thisBatch#<br>#thisCont#">
							</cfif>
							
						</cfif>
						<cfset thisCont = ""><!--- reset for new part--->
					</cfloop>
	</cfloop>
		<cfset thisVial = #thisBatch#>
	</cfoutput>
			<!----------------- end vial labels ------------------------------->
	
		<cfset newrows = queryaddrow(AllData, 1)>
			<cfset temp = QuerySetCell(AllData, "collection_object_id", "#thisRecord#", #i#)>
			<cfset temp = QuerySetCell(AllData, "institution_acronym", "#getSingle.institution_acronym#", #i#)>
			<cfset temp = QuerySetCell(AllData, "collection_cde", "#getSingle.collection_cde#", #i#)>
			<cfset temp = QuerySetCell(AllData, "cat_num", "#getSingle.cat_num#", #i#)>
			<cfset temp = QuerySetCell(AllData, "scientific_name", "#getSingle.scientific_name#", #i#)>
			<cfset temp = QuerySetCell(AllData, "af_num", "#getAF.other_id_num#", #i#)>
			<cfset temp = QuerySetCell(AllData, "dec_lat", "#getSingle.dec_lat#", #i#)>
			<cfset temp = QuerySetCell(AllData, "dec_long", "#getSingle.dec_long#", #i#)>
			<cfset temp = QuerySetCell(AllData, "datum", "#getSingle.datum#", #i#)>
			<cfset temp = QuerySetCell(AllData, "max_error_distance", "#getSingle.max_error_distance#", #i#)>
			<cfset temp = QuerySetCell(AllData, "max_error_units", "#getSingle.max_error_units#", #i#)>
			<cfset temp = QuerySetCell(AllData, "lat_long_ref_source", "#getSingle.lat_long_ref_source#", #i#)>
			<cfset temp = QuerySetCell(AllData, "country", "#getSingle.country#", #i#)>
			<cfset temp = QuerySetCell(AllData, "sea", "#getSingle.sea#", #i#)>
			<cfset temp = QuerySetCell(AllData, "island", "#getSingle.island#", #i#)>
			<cfset temp = QuerySetCell(AllData, "state_prov", "#getSingle.state_prov#", #i#)>
			<cfset temp = QuerySetCell(AllData, "quad", "#getSingle.quad#", #i#)>
			<cfset temp = QuerySetCell(AllData, "county", "#getSingle.county#", #i#)>
			<cfset temp = QuerySetCell(AllData, "feature", "#getSingle.feature#", #i#)>
			<cfset temp = QuerySetCell(AllData, "spec_locality", "#getSingle.spec_locality#", #i#)>
				<cfif len(#getSingle.orig_elev_units#) gt 0>
					<cfset elev = "#getSingle.minimum_elevation# - #getSingle.maximum_elevation# #getSingle.orig_elev_units#">
				  <cfelse>
				  	<cfset elev = "">
				</cfif>
			<cfset temp = QuerySetCell(AllData, "elevation", "#elev#", #i#)>
			<cfset temp = QuerySetCell(AllData, "verbatim_date", "#getSingle.verbatim_date#", #i#)>
			<cfset temp = QuerySetCell(AllData, "sex_cde", "#getSingle.sex_cde#", #i#)>
			<cfset temp = QuerySetCell(AllData, "sex_cde_mod", "#getSingle.sex_cde_mod#", #i#)>
			<cfset temp = QuerySetCell(AllData, "repro_data", "#getSingle.repro_data#", #i#)>
			<cfset temp = QuerySetCell(AllData, "age_class", "#getSingle.age_class#", #i#)>
			<cfset temp = QuerySetCell(AllData, "collectors", "#AgentString#", #i#)>
			<cfset temp = QuerySetCell(AllData, "OIDs", "#OIDString#", #i#)>
			<cfset temp = QuerySetCell(AllData, "OIDLs", "#OIDLString#", #i#)>
			<cfset temp = QuerySetCell(AllData, "parts", "#PartString#", #i#)>
			<cfset temp = QuerySetCell(AllData, "coll_object_remarks", "#getSingle.coll_object_remarks#", #i#)>
			<cfif len(#getSingle.accn_num#) is 1>
				<cfset aNum = "00#getSingle.accn_num#">
			</cfif>
			<cfif len(#getSingle.accn_num#) is 2>
				<cfset aNum = "0#getSingle.accn_num#">
			</cfif>
			<cfif len(#getSingle.accn_num#) is 3>
				<cfset aNum = "#getSingle.accn_num#">
			</cfif>
			<cfset accnNum = "#getSingle.accn_num_prefix#.#aNum#">
			<cfif len(#getSingle.accn_num_suffix#) gt 0>
				<cfset accnNum = "#accnNum#.#getSingle.accn_num_suffix#">
			</cfif>
			<cfset temp = QuerySetCell(AllData, "accn_number", "#accnNum#", #i#)>
			<cfset meas = "">
			<cfif #getSingle.collection_cde# is "Mamm">
				<cfif len(#getSingle.length_units#) gt 0>
					<cfif len(#getSingle.total_length#) gt 0>
						<cfset meas = "#getSingle.total_length#">
					  <cfelse>
						<cfset meas = "X">	
					</cfif>
					<cfif len(#getSingle.tail_length#) gt 0>
						<cfset meas = "#meas#-#getSingle.tail_length#">
					  <cfelse>
						<cfset meas = "#meas#-X">	
					</cfif>
					<cfif len(#getSingle.hind_foot_length#) gt 0>
						<cfset meas = "#meas#-#getSingle.hind_foot_length#">
					  <cfelse>
						<cfset meas = "#meas#-X">	
					</cfif>
					<cfif len(#getSingle.ear_length#) gt 0>
						<cfset meas = "#meas#-#getSingle.ear_length#">
					  <cfelse>
						<cfset meas = "#meas#-X">	
					</cfif>
					<cfset meas = "#meas# #getSingle.length_units#">
					<cfif len(#getSingle.weight_units#) gt 0>
						<cfset meas = "#meas# <u>=</u> #getSingle.weight# #getSingle.weight_units#">
					</cfif>
				</cfif>
			<cfelse>
				<cfset meas = "">
			</cfif>
			<cfset temp = QuerySetCell(AllData, "measurements", "#meas#", #i#)>
			
			<!----
			
			
			<!--- break thisBatch back up into indiv containers --->
			<cfoutput>
			<cfset z=1>
			<!----
			
			---->
			<cfset thisVial = "">
			<cfset thisContainer = "">
			
			<hr>
			#thisRecord#<cfflush>
			<hr>
			<br>origBatch: #thisBatch#
			<cfset numCont = #find("<br>",thisBatch)#>
			<cfif #numCont# is 0><!--- just one container ---->
			<br>just one container
				<cfif left(#thisBatch#,1) is "V">
					<cfif len(#thisVial#) gt 0>
						<cfset thisVial = "#thisVial# #thisBatch#">
					  <cfelse>
					  	<cfset thisVial = "#thisBatch#">
					 </cfif>
					 <br>thisVial: #thisVial#
				  <cfelseif left(#thisBatch#,1) is "C">
				  	<cfif len(#thisContainer#) gt 0>
						<cfset thisContainer = "#thisContainer# #thisBatch#">
					  <cfelse>
					  	<cfset thisContainer = "#thisBatch#">
					 </cfif>
					 <br>thisContainer: #thisContainer#
				</cfif>
				
			</cfif>
			<cfloop condition="z lt 100">
			<cfif #numCont# gt 0><!--- more than one container ---->
			<br> more than one container
				<cfset thisCont = left(#thisBatch#,#numCont#-1)>
				<cfif left(#thisCont#,1) is "V">
					<cfif len(#thisVial#) gt 0>
						<cfset thisVial = "#thisVial# #thisBatch#">
					  <cfelse>
					  	<cfset thisVial = "#thisBatch#">
					 </cfif>
					  <br>thisVial: #thisVial#
				  <cfelseif left(#thisCont#,1) is "C">
				  		<cfif len(#thisContainer#) gt 0>
							<cfset thisContainer = "#thisContainer# #thisBatch#">
						  <cfelse>
							<cfset thisContainer = "#thisContainer#">
						 </cfif>
						  <br>thisContainer: #thisContainer#
				</cfif>
				<cfset theRest = right(#thisBatch#,#len(thisBatch)#-#numCont#-3)>
				<cfset thislen = len(#theRest#) >
				<br>#thisLen#-----------------------------
				<cfif len(#theRest#) is 0><!--- nothing left--->
					<cfset z=10000><!--- break out of the loop --->
					---break out<cfflush>
				  <cfelse>
				  	<cfset thisBatch = "#theRest#">
					<br>thisBatch #thisBatch#
					---looping---<cfflush>
				</cfif>
			</cfif>
			
			</cfloop>
			<!----
			
			---->
			</cfoutput>
			
			---->
			<cfset temp = QuerySetCell(AllData, "VialLabel", "#thisVial#", #i#)>
			<cfset temp = QuerySetCell(AllData, "ContainerLabel", "#thisContainer#", #i#)>
			
	
	
		
	
			

	</cfloop>
	
	
	
<hr>


<table border="1" cellpadding="0" cellspacing = "0">
  <tr>
    <td><strong>Cat Num</strong></td>
    <td><strong>Scientific&nbsp;Name</strong></td>
    <td><strong>AF&nbsp;Number</strong></td>
    <td><strong>Latitude</strong></td>
    <td><strong>Longitude</strong></td>
	<td><strong>Datum</strong></td>
    <td><strong>Max Error</strong></td>
	<td><strong>LatLong Ref Source</strong></td>
    <td><strong>Country</strong></td>
    <td><strong>Sea</strong></td>
    <td><strong>Island</strong></td>
    <td><strong>State</strong></td>
    <td><strong>Quad</strong></td>
    <td><strong>County</strong></td>
    <td><strong>Feature</strong></td>
    <td><strong>Specific&nbsp;Locality</strong></td>
	<td><strong>Elevation</strong></td>
    <td><strong>Date</strong></td>
    <td><strong>Sex</strong></td>
	<td><strong>Age Class</strong></td>
	<td><strong>Repro Data</strong></td>
    <td><strong>Collector</strong></td>
    <td><strong>Other&nbsp;ID</strong></td>
    <td><strong>Parts</strong></td>
		<td><strong>Remarks</strong></td>
		<td><strong>Accn</strong></td>
	<td><strong>Measurements</strong></td>
	<td><strong>Container Label</strong></td>
	<td><strong>Vial Label</strong></td>
	
	
</tr>

<cfoutput query="AllData">
			
				
	  <tr>
  	    <td nowrap valign="top">
			<a href="SpecimenDetail.cfm?collection_object_id=#collection_object_id#"><strong>#collection_cde# #cat_num#</strong></a>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
				(<a href="SpecimenDetail.cfm?collection_object_id=#collection_object_id#">edit</a>)
			</cfif>
		</td>
	    <td nowrap valign="top">
			<i>#scientific_name#</i>&nbsp;
		</td>
    	<td nowrap valign="top">
			#af_num#&nbsp;	<!--- use a space (&nbsp;) after fields that may not show up to keep the table pretty --->
		</td>
    	<td nowrap valign="top">
			#dec_lat#&nbsp;
		</td>
    	<td nowrap valign="top">
			#dec_long#&nbsp;
		</td>
		<td nowrap valign="top">
			#datum#&nbsp;
		</td>
    	<td nowrap valign="top">
			#max_error_distance# #max_error_units#&nbsp;
		</td>
			<td nowrap valign="top">
			#lat_long_ref_source#&nbsp;
		</td>
   		<td nowrap valign="top">
			#country#&nbsp;
		</td>
    	<td nowrap valign="top">
			#sea#&nbsp;
		</td>
    	<td nowrap valign="top">
			#island#&nbsp;
		</td>
    	<td nowrap valign="top">
			#state_prov#&nbsp;
		</td>
    	<td nowrap valign="top">
			#quad#&nbsp;
		</td>
    	<td nowrap valign="top">
			#county#&nbsp;
		</td>  
		<td nowrap valign="top">
			#feature#&nbsp;
		</td>	
    	<td nowrap valign="top">
			#spec_locality#&nbsp;
		</td>
		<td nowrap valign="top">
			#elevation#&nbsp;
		</td>
    	<td nowrap valign="top">
			#verbatim_date#&nbsp;
		</td>
	    <td nowrap valign="top">
			#sex_cde# #sex_cde_mod#&nbsp;
		</td>
		 <td nowrap valign="top">
			#age_class#&nbsp;
		</td>
		 <td nowrap valign="top">
			#repro_data#&nbsp;
		</td>
		<td nowrap valign="top">
			<cfset brCollectors = replace("#collectors#","; ","<br>","all")>
				#brCollectors#&nbsp;
	
		
		
		</td>
	    <td nowrap valign="top">
			<cfset broid = replace("#oids#","; ","<br>","all")>
		#broid#&nbsp;
		</td>
    	<td nowrap valign="top">
		<cfset brpart = replace("#parts#","; ","<br>","all")>
		#brpart#&nbsp;
		</td>
		
		
			<td nowrap valign="top">
		#coll_object_remarks#&nbsp;
		</td>
		
		<td nowrap valign="top">
		#accn_number#&nbsp;
		</td>
		<td nowrap valign="top">
		#measurements#&nbsp;
		</td>
		<td nowrap valign="top">
		#ContainerLabel#&nbsp;
		</td>
		<td nowrap valign="top">
		#VialLabel#&nbsp;
		</td>
		
		
   </tr>

</cfoutput>
</table>
<p>
<!---form name="form2">

 <!--- update the values for the next and previous rows to be returned --->
<CFSET Next = StartRow + DisplayRows>
<CFSET Previous = StartRow - DisplayRows>
 
<!--- Create a previous records link if the records being displayed aren't the
      first set --->
<CFOUTPUT>
<CFIF Previous GTE 1>
   <A HREF="DetailedMatrix.cfm?StartRow=#Previous#&NewQuery=0"><B>Previous Page</B></A>
<CFELSE>
Previous Records  
</CFIF>
 
<B>|</B>
 
<!--- Create a next records link if there are more records in the record set 
      that haven't yet been displayed. --->
<CFIF Next LTE getCount.RecordCount>
    <A HREF="DetailedMatrix.cfm?StartRow=#Next#&NewQuery=0"><B>Next 
    <CFIF (getCount.RecordCount - Next) LT DisplayRows>
      #Evaluate((getCount.RecordCount - Next)+1)#
    <CFELSE>
      
    </CFIF>  Page</B></A>
<CFELSE>
Next Records   
</CFIF>
</CFOUTPUT>
 
 </form---->

 

 <cfinclude template = "includes/_footer.cfm">

