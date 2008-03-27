	<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">

	<form name="l" method="post" action="labelTest.cfm">
		<input type="hidden" name="action" value="print">
		<label for="orientation">Orientation</label>
		<select name="orientation" id="orientation">
			<option value="portrait">portrait</option>
		</select>
		<label for="lblHeight">Label Height</label>
		<input type="text" name="lblHeight" id="lblHeight" value="2.25">inches
		<label for="lblWidth">Label Width</label>
		<input type="text" name="lblWidth" id="lblWidth" value="1.5">inches
		<label for="lblMargin">Label Margin</label>
		<input type="text" name="lblMargin" id="lblMargin" value=".05">inches
		
		<label for="lblBorder">Outer Border</label>
		<select name="lblBorder" id="lblBorder">
			<option value="1px dashed gray">1px dashed gray</option>
			<option value="none">none</option>
		</select>
		
		<label for="inrBorder">Inner Border</label>
		<select name="inrBorder" id="inrBorder">
			<option value=".5px dotted lightgray">.5px dotted lightgray</option>
			<option value="1px dotted gray">1px dotted gray</option>
			<option value="none">none</option>
		</select>
		<label for="cellBorder">Cell Border</label>
		<select name="cellBorder" id="cellBorder">
			<option value="none">none</option>
			<option value=".5px dotted lightgray">.5px dotted lightgray</option>
			<option value="1px dotted gray">1px dotted gray</option>
		</select>
		
		
		<label for="font_family">Base Font</label>
		<select name="font_family" id="font_family">
			<option value="Arial, Helvetica, sans-serif">Arial, Helvetica, sans-serif</option>
			<option value="'Times New Roman', Times, serif">'Times New Roman', Times, serif</option>			
		</select>
		<label for="lblHeight">Base Font Size</label>
		<input type="text" name="font_size" id="font_size" value="8">px
		
		
		<br>
		<input type="submit">
	</form>
	
</cfif>
<cfif #action# is "print">

<cfset collection_object_id="266883,284046,292102,190294,190295,292101,190290,190292,292100,214973,213572,190289,190293,266884,213571,213570,214293,190291,215248,219029">
<cfset sql="
	select
		scientific_name,
		decode(trim(ConcatAttributeValue(cataloged_item.collection_object_id,'sex')),
			'male','M',
			'female','F',
			'U') sex,					
				concatParts(cataloged_item.collection_object_id) parts,
		concatAcceptedIdentifyingAgent(cataloged_item.collection_object_id) identified_by,
		get_taxonomy(cataloged_item.collection_object_id,'family') family,
		get_taxonomy(cataloged_item.collection_object_id,'scientific_name') tsname,
		get_taxonomy(cataloged_item.collection_object_id,'author_text') auth,
		CONCATATTRIBUTE(cataloged_item.collection_object_id) attributes,
		trim(ConcatAttributeValue(cataloged_item.collection_object_id,'abundance')) abundance,
		identification_remarks,
		made_date,
		cat_num,
		state_prov,
		country,
		quad,
		county,
		island,
		island_group,
		sea,
		feature,
		spec_locality,
		CASE orig_lat_long_units
			WHEN 'decimal degrees' THEN dec_lat || 'd'
			WHEN 'deg. min. sec.' THEN lat_deg || 'd ' || lat_min || 'm ' || lat_sec || 's ' || lat_dir
			WHEN 'degrees dec. minutes' THEN lat_deg || 'd ' || dec_lat_min || 'm ' || lat_dir
		END as VerbatimLatitude,
		CASE orig_lat_long_units
			WHEN 'decimal degrees' THEN dec_long || 'd'
			WHEN'degrees dec. minutes' THEN long_deg || 'd ' || dec_long_min || 'm ' || long_dir
			WHEN 'deg. min. sec.' THEN long_deg || 'd ' || long_min || 'm ' || long_sec || 's ' || long_dir
		END as VerbatimLongitude,
		MAXIMUM_ELEVATION,
		MINIMUM_ELEVATION,
		ORIG_ELEV_UNITS,
		concatColl(cataloged_item.collection_object_id) as collectors,
					concatPrep(cataloged_item.collection_object_id) as preparators,
		concatotherid(cataloged_item.collection_object_id) as other_ids,
		concatsingleotherid(cataloged_item.collection_object_id,'collector number') collector_number,
		concatsingleotherid(cataloged_item.collection_object_id,'preparator number') preparator_number,
		concatsingleotherid(cataloged_item.collection_object_id,'original identifier') fieldnum,
		concatsingleotherid(cataloged_item.collection_object_id,'U. S. National Park Service accession') npsa,
		concatsingleotherid(cataloged_item.collection_object_id,'U. S. National Park Service catalog') npsc,
		concatsingleotherid(cataloged_item.collection_object_id,'ALAAC') ALAAC,
		verbatim_date,
		habitat_desc,
		habitat,
		associated_species,
		project_name
	FROM
		cataloged_item,
		identification,
		collecting_event,
		locality,
		geog_auth_rec,
		accepted_lat_long,
		coll_object_remark,
		project_trans,
		project
	WHERE
		cataloged_item.collection_object_id = identification.collection_object_id AND
		cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		collecting_event.locality_id = locality.locality_id AND
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		locality.locality_id = accepted_lat_long.locality_id (+) AND
		cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+) AND
		cataloged_item.accn_id = project_trans.transaction_id (+) AND
		project_trans.project_id = project.project_id(+) AND
		accepted_id_fg=1 AND cataloged_item.collection_object_id IN (#collection_object_id#)
	ORDER BY
		concatsingleotherid(cataloged_item.collection_object_id,'original identifier')
			">
	<cfquery name="data" datasource="#Application.web_user#">
		#preservesinglequotes(sql)#
	</cfquery>
	

<!---
	
<cfdocument 
	format="PDF"
	pagetype="letter" 
		orientation="landscape"
		margintop="0"
		marginleft="0"
		marginbottom="0"
		marginright="0.0" 
		overwrite="true"
	fontembed="yes" filename="#Application.webDirectory#/temp/alaLabel.pdf">	
---->

		<!--- --->
<cfoutput>
<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">
<cfset rc=data.recordcount>
<cfset locHeight=(font_size*6)*1.2>
<cfset ff=font_size*1.2>
<style>
	.singleLine {
		height:#ff#px;
		font-size:#font_size#px;
		font-family:#font_family#;		
		overflow:hidden;
		border:#cellBorder#;
	}
						
	.threeQuarter {
		width:75%;
		float:left;
	}
	.oneQuarter {
		width:22%;
		float:right;	
	}
	.alignCenter {
		text-align:center;						
	}
	.sciName {
		font-style:italic;
		font-family:"Times New Roman", Times, serif;
		height:#font_size#px;
		font-size:#font_size#px;
		overflow:hidden;
		border:#cellBorder#;
	}
	.locality {
		height:#locHeight#px;
		font-size:#font_size#px;
		font-family:#font_family#;		
		overflow:hidden;
		border:#cellBorder#;
	}
</style>
<cfif #orientation# is "portrait">
	<cfset pHeight=11>
	<cfset pWidth=8.5>
</cfif>
<!--- there are three nested divs:

the main label container, which sets outer border
an intermediate container, which sets the inner border
an inner container, which holds the content

--->

<cfset middleHeight=lblHeight-(lblMargin*2)>
<cfset middleWidth=lblWidth-(lblMargin*2)>

<cfset innerHeight=lblHeight-(lblMargin*4)>
<cfset innerWidth=lblWidth-(lblMargin*4)>


<cfset rowsPerPage = int(pHeight/lblHeight)>
<cfset colsPerPage = int(pWidth/lblWidth)>
<cfset counter=1>
<cfset lrPosn=0>
<cfset topPosn=0>


<cfset i=1>
<cfloop query="data">
	<cfset geog="#ucase(state_prov)#">
	<cfif #country# is "United States">
		<cfset geog="#geog#, USA">
	<cfelse>
		<cfset geog="#geog#, #ucase(country)#">
	</cfif>
	<cfset coordinates = "">
	<cfif len(#verbatimLatitude#) gt 0 AND len(#verbatimLongitude#) gt 0>
		<cfset coordinates = "#verbatimLatitude# / #verbatimLongitude#">
		<cfset coordinates = replace(coordinates,"d","&##176;","all")>
		<cfset coordinates = replace(coordinates,"m","'","all")>
		<cfset coordinates = replace(coordinates,"s","''","all")>
	</cfif>
	<cfset locality="">
	<cfif len(#quad#) gt 0>
		<cfset locality = "#quad# Quad.:">
	</cfif>
	<cfif len(#spec_locality#) gt 0>
		<cfset locality = "#locality# #spec_locality#">
	</cfif>
	<cfif len(#coordinates#) gt 0>
	 	<cfset locality = "#locality#, #coordinates#">
	 </cfif>
	  <cfif len(#ORIG_ELEV_UNITS#) gt 0>
	 	<cfset locality = "#locality#. Elev. #MINIMUM_ELEVATION#-#MAXIMUM_ELEVATION# #ORIG_ELEV_UNITS#">
	 </cfif>
	 <cfif len(#habitat#) gt 0>
	 	<cfset locality = "#locality#, #habitat#">
	 </cfif>
	 <cfif right(locality,1) is not ".">
		 <cfset locality = "#locality#.">
	</cfif>
	
	
	
	<cfif counter is 1>
		<!--- new page  
			
			---starting a new page -------------------<br>
			--->
		<div style="width:#pWidth#in;
			height:#pHeight#in;
			position:relative;
			border:1px solid green;">   
	</cfif>
	
<!----


Hi, I'm a label<br>
	top:#topPosn#; left:#lrPosn#<br>
---->

	<div style="top:#topPosn#in; 
		left:#lrPosn#in; 
		width:#lblWidth#in; 
		height:#lblHeight#in; 
		position:absolute;
		overflow:hidden;
		border:#lblBorder#;">
		<div style="height: #middleHeight#in; width:#middleWidth#in; position:relative; border:#inrBorder#; margin:#lblMargin#in">
				<div style="position:relative; height:#innerHeight#in; width:#innerWidth#in; margin:#lblMargin#in">
					<!--- content goes here --->
					<cfset thisHeight=".2in;">
					<div class="singleLine alignCenter">
						Museum of Southwestern Biology
					</div>
					<div class="singleLine alignCenter">
						Biological Surveys Collection
					</div>
					<div class="singleLine alignCenter">
						MSB #cat_num#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#sex#
					</div>
					<div class="sciName">
						#scientific_name#
					</div>
					<div class="locality">
						#locality#
					</div>
					<div class="singleLine">
						#verbatim_date#
					</div>
					<div class="singleLine threeQuarter" >
						#collectors#
					</div>
					<div class="singleLine oneQuarter">
						#collector_number#
					</div>		

					<div class="singleLine threeQuarter" >
						#preparators#
					</div>
					<div class="singleLine oneQuarter">
						#preparator_number#
					</div>
					<div class="locality">
						#parts#
					</div>	

					<!--- end of content ---->
				</div>
		</div>
	</div>
	
	
	<cfset lrPosn= lrPosn + lblWidth>
	<cfif lrPosn gte (pWidth  - lblWidth)>
		<cfset lrPosn=0>
		<cfset topPosn=topPosn+lblHeight>
	</cfif>
		


	
	<cfset counter=counter+1>
	
	<cfif counter gt (rowsPerPage * colsPerPage)>
		<!--- counter starts with one at every page --->
		<cfset counter=1>
		<cfset lrPosn=0>
		<cfset topPosn = 0>
	</cfif>
	<cfif #counter# is 1 or i is rc>
		<!--- close new page--  
		----closing the page div -----------------<br>
		  --->
		</div>
		
	</cfif>
	<cfset i=i+1>
</cfloop>



<!----
<cfif not isdefined("collection_object_id")>
	<cfabort>
</cfif>	


<cfset sql="
	select
		get_scientific_name_auths(cataloged_item.collection_object_id) sci_name_with_auth,
		concatAcceptedIdentifyingAgent(cataloged_item.collection_object_id) identified_by,
		get_taxonomy(cataloged_item.collection_object_id,'family') family,
		get_taxonomy(cataloged_item.collection_object_id,'scientific_name') tsname,
		get_taxonomy(cataloged_item.collection_object_id,'author_text') auth,
		CONCATATTRIBUTE(cataloged_item.collection_object_id) attributes,
		trim(ConcatAttributeValue(cataloged_item.collection_object_id,'abundance')) abundance,
		identification_remarks,
		made_date,
		cat_num,
		state_prov,
		country,
		quad,
		county,
		island,
		island_group,
		sea,
		feature,
		spec_locality,
		CASE orig_lat_long_units
			WHEN 'decimal degrees' THEN dec_lat || 'd'
			WHEN 'deg. min. sec.' THEN lat_deg || 'd ' || lat_min || 'm ' || lat_sec || 's ' || lat_dir
			WHEN 'degrees dec. minutes' THEN lat_deg || 'd ' || dec_lat_min || 'm ' || lat_dir
		END as VerbatimLatitude,
		CASE orig_lat_long_units
			WHEN 'decimal degrees' THEN dec_long || 'd'
			WHEN'degrees dec. minutes' THEN long_deg || 'd ' || dec_long_min || 'm ' || long_dir
			WHEN 'deg. min. sec.' THEN long_deg || 'd ' || long_min || 'm ' || long_sec || 's ' || long_dir
		END as VerbatimLongitude,
		MAXIMUM_ELEVATION,
		MINIMUM_ELEVATION,
		ORIG_ELEV_UNITS,
		concatColl(cataloged_item.collection_object_id) as collectors,
		concatotherid(cataloged_item.collection_object_id) as other_ids,
		concatsingleotherid(cataloged_item.collection_object_id,'original identifier') fieldnum,
		concatsingleotherid(cataloged_item.collection_object_id,'U. S. National Park Service accession') npsa,
		concatsingleotherid(cataloged_item.collection_object_id,'U. S. National Park Service catalog') npsc,
		concatsingleotherid(cataloged_item.collection_object_id,'ALAAC') ALAAC,
		verbatim_date,
		habitat_desc,
		habitat,
		associated_species,
		project_name
	FROM
		cataloged_item,
		identification,
		collecting_event,
		locality,
		geog_auth_rec,
		accepted_lat_long,
		coll_object_remark,
		project_trans,
		project
	WHERE
		cataloged_item.collection_object_id = identification.collection_object_id AND
		cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		collecting_event.locality_id = locality.locality_id AND
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		locality.locality_id = accepted_lat_long.locality_id (+) AND
		cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+) AND
		cataloged_item.accn_id = project_trans.transaction_id (+) AND
		project_trans.project_id = project.project_id(+) AND
		accepted_id_fg=1 AND cataloged_item.collection_object_id IN (#collection_object_id#)
	ORDER BY
		concatsingleotherid(cataloged_item.collection_object_id,'original identifier')
			">
	<cfquery name="data" datasource="#Application.web_user#">
		#preservesinglequotes(sql)#
	</cfquery>
	
	<cfif  #data.recordcount# mod 2 neq 0>
		<!--- pad on a garbage record --->
		<cfset temp = queryaddrow(data,1)>
		<cfset temp = querysetcell(data,'family','blank filler')>
	</cfif>	
	<cfoutput>
	
	
	
	
<cfset rowsPerPage = 2>
<cfset colsPerPage = 2>

<cfset pHeight=8.5>
<cfset pWidth=11>

<cfset lblHeight=3.25>
<cfset lblWidth=5.5>

<cfset lrPosn=0>
<cfset topPosn = 0>
<cfset counter=1>
<cfset currentRow=0>
<cfset currentColumn=0>
<cfset i=1>
<cfloop query="data">
	<cfset geog="#ucase(state_prov)#">
	<cfif #country# is "United States">
		<cfset geog="#geog#, USA">
	<cfelse>
		<cfset geog="#geog#, #ucase(country)#">
	</cfif>
	<cfset coordinates = "">
	<cfif len(#verbatimLatitude#) gt 0 AND len(#verbatimLongitude#) gt 0>
		<cfset coordinates = "#verbatimLatitude# / #verbatimLongitude#">
		<cfset coordinates = replace(coordinates,"d","&##176;","all")>
		<cfset coordinates = replace(coordinates,"m","'","all")>
		<cfset coordinates = replace(coordinates,"s","''","all")>
	</cfif>
	<cfset locality="">
	<cfif len(#quad#) gt 0>
		<cfset locality = "#quad# Quad.:">
	</cfif>
	<cfif len(#spec_locality#) gt 0>
		<cfset locality = "#locality# #spec_locality#">
	</cfif>
	<cfif len(#coordinates#) gt 0>
	 	<cfset locality = "#locality#, #coordinates#">
	 </cfif>
	  <cfif len(#ORIG_ELEV_UNITS#) gt 0>
	 	<cfset locality = "#locality#. Elev. #MINIMUM_ELEVATION#-#MAXIMUM_ELEVATION# #ORIG_ELEV_UNITS#">
	 </cfif>
	 <cfif len(#habitat#) gt 0>
	 	<cfset locality = "#locality#, #habitat#">
	 </cfif>
	 <cfif len(#associated_species#) gt 0>
	 	<cfset locality = "#locality#, #associated_species#">
	 </cfif>	
	<cfif len(abundance) gt 0>
		<cfset locality = "#locality#, #abundance#">
	</cfif>
	 <cfif right(locality,1) is not ".">
		 <cfset locality = "#locality#.">
	</cfif>
	<cfset collector="#collectors# #fieldnum#">
	<cfset determiner="">
	<cfif #collectors# neq #identified_by# AND #identified_by# is not "unknown">
		<cfset determiner="Det: #identified_by# #dateformat(made_date,"dd mmm yyyy")#">
	</cfif>
	<cfset project="#project_name#">	
	<cfif len(#npsa#) gt 0 or len(#npsc#) gt 0>
		<cfif len(#project#) gt 0>
			<cfset project="#project#<br/>">
		</cfif>
		<cfset project="#project#NPS: #npsa# #npsc#">
	</cfif>	
	<cfset alaacString="Herbarium, University of Alaska Museum (ALA) accession #alaac#">
	<cfset sAtt="">
	<cfloop list="#attributes#" index="att">
		<cfif att does not contain "abundance">
			<cfif att contains "diploid number">
				<cfset att=replace(att,"diploid number: ","2n=","all")>
			</cfif>
			<cfset sAtt=listappend(sAtt,att)>
		</cfif>
	</cfloop>
				
	<cfif #counter# is 1>
		<!--- new page --->
		<div style="width:11in;
	height:8.5in;
	position:relative;">
	</cfif>
	<!---
	i: #i#; counter: #counter#; lrPosn: #lrPosn#
	--->
	<!--- only works on 2-column labels --->

	<div class="oneLabel" style="
		width:#lblWidth#in;
		height:#lblHeight#in;
		top:#topPosn#in;
		left:#lrPosn#in;">
			<div class="oneCell times16b"
				style="top:.15in;
				left:.25in;
				width:2.5in;
				height:.25in;">
					#family#					
			</div>
			<div class="oneCell times16b alignR"
				 style="top:.15in;
					left:2.75in;
					width:2.5in;
					height:.25in;">
					#geog#
			</div>
			<div class="oneCell times16b"
				 style="top:.4in;
					left:.25in;
					width:5in;
					height:.25in;">
					#sci_name_with_auth#
			</div>
			<div class="oneCell times14"
				 style="top:.65in;
					left:.25in;
					width:5in;
					height:.25in;">
					#identification_remarks#
			</div>
			<div class="oneCell times14"
				 style="top:.9in;
					left:.25in;
					width:5in;
					height:.75in;">
					#locality#
			</div>
			<div class="oneCell"
				 style="top:1.65in;
					left:.25in;
					width:5in;
					height:.25in;">
					#sAtt#
			</div>			
			<div class="oneCell"
				 style="top:1.9in;
					left:.25in;
					width:3.5in;
					height:.25in;">
					#collector#
			</div>
			<div class="oneCell alignR"
				 style="top:1.9in;
					left:3.75in;
					width:1.5in;
					height:.25in;">
					<!---#dateformat(made_date,"dd mmm yyyy")#--->
					#verbatim_date#
			</div>
			<div class="oneCell"
				 style="top:2.1in;
					left:.25in;
					width:5in;
					height:.25in;">
					#determiner#
			</div>
			<div class="oneCell"
				 style="top:2.3in;
					left:.25in;
					width:5in;
					height:.45in;">
					#project#
			</div>
			<div class="oneCell times16b valignB alignC"
				 style="top:2.75in;
					left:.25in;
					width:5in;
					height:.25in;">
					#alaacString#
			</div>			
	</div>
	<cfif counter mod 2 is 0>
		<!--- even number= just made right column --->
		<cfset lrPosn=0>
		<cfset topPosn=lblHeight>
	<cfelse>
		<!--- odd number, left column --->
		<cfset lrPosn=lblWidth>
	</cfif>
	<!----
	<cfif lrPosn is 0>
		<cfset lrPosn=lblWidth>
	<cfelse>
		<cfset lrPosn=0>
	</cfif>
	
	<cfif topPosn is 0>
		<cfset topPosn=lblHeight>
	<cfelse>
		<cfset topPosn=0>
	</cfif>
	---->
	<cfset counter=counter+1>
	<cfif counter gt (rowsPerPage * colsPerPage)>
		<cfset counter=1>
		<cfset lrPosn=0>
		<cfset topPosn = 0>
	</cfif>
	<cfif #counter# is 1>
		<!--- close new page --->
		</div>
	</cfif>
	<cfset i=i+1>
</cfloop>

	<!----
	<div style="border:1px solid red;width:5.5in;height:2.5in;position:absolute;top:0in;left:5.5in;">
		labeley
	</div>
	<div style="border:1px solid red;width:5.5in;height:2.5in;position:absolute;top:2.5in;left:0in;">
		labeley
	</div>
	<div style="border:1px solid red;width:5.5in;height:2.5in;position:absolute;top:2.5in;left:5.5in;">
		labeley
	</div>
---->
---->
</cfoutput>
<!----
</cfdocument>
---->

<cfoutput>
	<a href="#Application.ServerRootUrl#/temp/alaLabel.pdf">pdf</a>
	</cfoutput>
	</cfif>