<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
<cfoutput>
	<form name="l" method="get" action="msbLabels.cfm">
		<input type="hidden" name="action" value="print">
				<input type="hidden" name="collection_object_id" value="#collection_object_id#">
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
			<option value="1px dotted gray">1px dotted gray</option>
			<option value="none">none</option>
		</select>
		<label for="cellBorder">Cell Border</label>
		<select name="cellBorder" id="cellBorder">
			<option value="none">none</option>
			<option value="1px dotted gray">1px dotted gray</option>
		</select>
		
		
		<label for="font_family">Base Font</label>
		<select name="font_family" id="font_family">
			<option value="'Courier New', Courier, mono">'Courier New', Courier, mono</option>
			<option value="Arial, Helvetica, sans-serif">Arial, Helvetica, sans-serif</option>
			<option value="'Times New Roman', Times, serif">'Times New Roman', Times, serif</option>
			
					
		</select>
		<label for="lblHeight">Base Font Size</label>
		<input type="text" name="font_size" id="font_size" value="8">px
		
		
		<br>
		<input type="submit">
	</form>
	</cfoutput>
</cfif>
<cfif #action# is "print">


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
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
	
<cfoutput>	
<!---
<cfdocument 
	format="PDF"
	pagetype="letter" 
		orientation="#orientation#"
		margintop="0"
		marginleft="0"
		marginbottom="0"
		marginright="0.0" 
		overwrite="true"
	fontembed="yes" filename="#Application.webDirectory#/temp/msbLabel.pdf">	
		
		
---->


		




<cfset rc=data.recordcount>
<cfset locHeight=(font_size*6)*1.2>
<cfset ff=font_size*1.2>
<!---
<cfsavecontent variable="tCSS">
	.singleLine {
		height:#ff#px;
		font-size:#font_size#px;
		font-family:#font_family#;		
		overflow:hidden;
		border:#cellBorder#;
	}
	.alignCenter {
		text-align:center;						
	}
	.locality {
		height:#locHeight#px;
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
		text-align:right;	
	}
	
	.sciName {
		font-style:italic;
		font-family:"Times New Roman", Times, serif;
		height:#font_size#px;
		font-size:#font_size#px;
		overflow:hidden;
		border:#cellBorder#;
	}
</cfsavecontent>

<cffile action="write" file="#application.webDirectory#/temp/lblCSS.css" output="#tCSS#">
<link rel="stylesheet" type="text/css" href="/temp/lblCSS.css">
---->
<style type="text/css">
.singleLine {
		height:#ff#px;
		font-size:#font_size#px;
		font-family:#font_family#;		
		overflow:hidden;
		border:#cellBorder#;
	}
	.alignCenter {
		text-align:center;						
	}
	.locality {
		height:#locHeight#px;
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
		text-align:right;	
	}
	
	.sciName {
		font-style:italic;
		font-family:"Times New Roman", Times, serif;
		height:#ff#px;
		font-size:#font_size#px;
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
					<div class="singleLine">
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
</cfdocument>
---->


</cfoutput>
<cfoutput>
	<a href="#Application.ServerRootUrl#/temp/msbLabel.pdf">get the pdf</a>
	</cfoutput>
	</cfif>