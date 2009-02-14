<cfinclude template="/includes/_header.cfm">
<cfif not isdefined("collection_object_id")>
	<cfabort>
</cfif>
<cfif #action# is "nothing">
<cfoutput>
	<br /><a href="UamMammalVialLabels_pdffile.cfm?collection_object_id=#collection_object_id#&print_by_print_flag=2&action=print">Print returned items by Vial Label Flag</a>
	(If you've flagged 9 parts of UAM 1 for vial labels, and UAM 1 was in your results on the last screen, you'll get 9 UAM 1 labels)
	<br /><a href="UamMammalVialLabels_pdffile.cfm?collection_object_id=#collection_object_id#&print_by_print_flag=1&action=print">Print returned items by Box Label Flag</a>
	<br /><a href="UamMammalVialLabels_pdffile.cfm?collection_object_id=#collection_object_id#&action=print">Print returned items (one label each)</a>		
	</cfoutput>
</cfif>
<cfif #action# is "print">

	<cfquery name="ctAtt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct(attribute_type) from ctAttribute_type order by attribute_type
</cfquery>
<cfset attList = "">
<cfloop query="ctAtt">
	<cfif len(#attList#) is 0>
		<cfset attList = "#ctAtt.attribute_type#">
	<cfelse>
		<cfset attList = "#attList#,#ctAtt.attribute_type#">
	</cfif>
</cfloop>
<cfset seleAttributes = "">
<cfloop query="ctAtt">
			<cfset thisName = #ctAtt.attribute_type#>
			<cfset thisName = #replace(thisName," ","_","all")#>
			<cfset thisName = #replace(thisName,"-","_","all")#>
			<cfset thisName = #left(thisName,20)#>
			<cfif #thisName# is not "sex"><!--- already got it --->
				<cfset seleAttributes = "#seleAttributes# ,ConcatAttributeValue(cataloged_item.collection_object_id,'#ctAtt.attribute_type#') 
				as #thisName#">
			</cfif>
		</cfloop>
		
<cfset sql="
select
			cataloged_item.collection_object_id,
			cat_num,
			scientific_name,
			state_prov,
			country,
			quad,
			county,
			island,
			sea,
			feature,
			spec_locality,
			CASE orig_lat_long_units
				WHEN 'decimal degrees' THEN round(dec_lat,4) || 'd'
				WHEN 'deg. min. sec.' THEN lat_deg || 'd ' || lat_min || 'm ' || round(lat_sec,2) || 's ' || lat_dir
				WHEN 'degrees dec. minutes' THEN lat_deg || 'd ' || dec_lat_min || 'm ' || lat_dir
			END as VerbatimLatitude,
			CASE orig_lat_long_units
				WHEN 'decimal degrees' THEN round(dec_long,4) || 'd'
				WHEN'degrees dec. minutes' THEN long_deg || 'd ' || dec_long_min || 'm ' || long_dir
				WHEN 'deg. min. sec.' THEN long_deg || 'd ' || long_min || 'm ' || round(long_sec,2) || 's ' || long_dir
			END as VerbatimLongitude,
			concatColl(cataloged_item.collection_object_id) as collectors,
			ConcatAttributeValue(cataloged_item.collection_object_id,'sex') as sex,
			concatotherid(cataloged_item.collection_object_id) as other_ids,
			concatparts(cataloged_item.collection_object_id) as parts,
			verbatim_date,
			accn_number
			#seleAttributes#
		FROM
			cataloged_item
			INNER JOIN identification ON (cataloged_item.collection_object_id = identification.collection_object_id)
			INNER JOIN collecting_event ON (cataloged_item.collecting_event_id = collecting_event.collecting_event_id)
			INNER JOIN locality ON (collecting_event.locality_id = locality.locality_id)
			INNER JOIN geog_auth_rec ON (locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id)
			LEFT OUTER JOIN accepted_lat_long ON (locality.locality_id = accepted_lat_long.locality_id)
			LEFT OUTER JOIN accn ON (cataloged_item.accn_id=accn.transaction_id)
			">
			<cfif isdefined("print_by_print_flag") and len(#print_by_print_flag#) gt 0>
				<cfset sql="#sql#
					inner join specimen_part on (cataloged_item.collection_object_id = specimen_part.derived_from_cat_item)
					inner join coll_obj_cont_hist on (specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id)
					inner join container on (coll_obj_cont_hist.container_id = container.container_id)
					inner join container pcont on (container.parent_container_id = pcont.container_id)">
			
			</cfif>
		<cfset sql="#sql# WHERE
			accepted_id_fg=1 AND cataloged_item.collection_object_id IN (#collection_object_id#)">
		<cfif isdefined("print_by_print_flag") and len(#print_by_print_flag#) gt 0>
			<cfset sql="#sql# and pcont.PRINT_FG = #print_by_print_flag#">
		</cfif>		
			<cfset sql="#sql# order by scientific_name,cat_num">
			<!---
			<cfoutput>
			<hr />#sql#<hr />
			
			</cfoutput>
			<cfabort>
			#preservesinglequotes(sql)#
<cfdump var="#data#">
			#preservesinglequotes(sql)#
<cfdump var="#data#">


			---->
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
	
<cfoutput>



<cfset c1 = "##0000CC">
<cfset c2 = "##33FF66">
<cfset c3 = "##FF6666">
<cfset c4 = "##99FFCC">

<cfset c1 = "##FFFFFF">
<cfset c2 = "##FFFFFF">
<cfset c3 = "##FFFFFF">
<cfset c4 = "##FFFFFF">



<cfdocument 
	format="pdf"
	pagetype="letter"
	margintop="0"
	marginbottom="0"
	marginleft="0"
	marginright="0"
	orientation="portrait"
	filename="#Application.webDirectory#/temp/UamMammalVialLabels.pdf"
	overwrite="yes"
	fontembed="yes" >
	
<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">
<cfset i=0>
<cfset t=0>

<cfset r=1>

<cfset rc = data.recordcount>

<cfset numRows = 8>
<cfset numCols = 5>
<cfset lPos = 0><!--- position from left --->
<cfset tPos = 0><!--- position from top --->
<cfset pageNum = 1><!--- position from top --->
<cfset width = 114>
<cfset height=79>
<cfset pageHeight=975>
<cfset bug="">
<cfset thisRow = 1>
<cfset cellPadVal = 3>
<cfset fullCellWidth = #width#>
 <cfloop query="data">
 	
	<cfset coordinates = "">
	<cfif len(#verbatimLatitude#) gt 0 AND len(#verbatimLongitude#) gt 0>
		<cfset coordinates = "#verbatimLatitude# / #verbatimLongitude#">
		<cfset coordinates = replace(coordinates,"d","&##176;","all")>
		<cfset coordinates = replace(coordinates,"m","'","all")>
		<cfset coordinates = replace(coordinates,"s","''","all")>
		<cfset coordinates = replace(coordinates," ","","all")>
	</cfif>
	<cfset geog = "">
		<cfif #state_prov# is "Alaska">
			<cfset geog = "USA: Alaska">
			<cfif len(#island#) gt 0>
				<cfset geog = "#geog#, #island#">
			</cfif>
			<cfif len(#sea#) gt 0>
				<cfif len(#quad#) is 0>
					<cfset geog = "#geog#, #sea#">
				</cfif>
			</cfif>
			<cfif len(#quad#) gt 0>
					<cfif not #geog# contains " Quad">
						<cfset geog = "#geog#, #quad# Quad">
					</cfif>
			</cfif>
			
			<cfif len(#feature#) gt 0>
				<cfset geog = "#geog#, #feature#">
			</cfif>
			<cfif len(#spec_locality#) gt 0>
				<cfset geog = "#geog#; #spec_locality#">
			</cfif>
		<cfelse>
		  	<cfif len(#country#) gt 0>
				<cfif #country# is "United States">
					<cfset geog = "USA: ">
				</cfif>
				<cfset geog = "#country#: ">
			</cfif>
			<cfif len(#sea#) gt 0>
				<cfset geog = "#geog#, #sea#">
			</cfif>
			<cfif len(#state_prov#) gt 0>
				<cfset geog = "#geog#, #state_prov#">
			</cfif>
			<cfif len(#island#) gt 0>
				<cfset geog = "#geog#, #island#">
			</cfif>
			<cfif len(#quad#) gt 0>
				<cfset geog = "#geog#, #quad# Quad">
			</cfif>
			<cfif len(#feature#) gt 0>
				<cfset geog = "#geog#, #feature#">
			</cfif>
			<cfif len(#spec_locality#) gt 0>
				<cfset geog = "#geog#; #spec_locality#">
			</cfif>
		</cfif>
		<cfset geog=replace(geog,": , ",": ","all")>
		<cfset sexcode = "">
		<cfif len(#trim(sex)#) gt 0>
			<cfif #trim(sex)# is "male">
				<cfset sexcode = "M">
			<cfelseif #trim(sex)# is "female">
				<cfset sexcode = "F">
			<cfelse>
				<cfset sexcode = "?">
			</cfif>
		</cfif>
		<cfset FieldNum = "">
		<cfloop list="#other_ids#" index="val" delimiters=";">
			<cfif #val# contains "Field Num=">
				<cfset FieldNum = "Field##: #replace(val,"Field Num=","")#">
			</cfif>
			<cfif #val# contains "AF=">
				<cfset af = "#replace(val,"="," ")#">
			</cfif>
		</cfloop>
		
		<cfif #collectors# contains ",">
			<Cfset spacePos = find(",",collectors)>
			<cfset thisColl = left(collectors,#SpacePos# - 1)>
			<cfset thisColl = "#thisColl# et al.">
		<cfelse>
			<cfset thisColl = #collectors#>
		</cfif>
		<cfset totlen = "">
		<cfset taillen = "">
		<cfset hf = "">
		<cfset efn = "">
		<cfset weight = "">
		<cfset totlen_val = "">
		<cfset taillen_val = "">
		<cfset hf_val = "">
		<cfset efn_val = "">
		<cfset weight_val = "">
		<cfset totlen_units = "">
		<cfset taillen_units = "">
		<cfset hf_units = "">
		<cfset efn_units = "">
		<cfset weight_units = "">
				
		<cfloop list="#attList#" index="val">
			<cfset thisName = #val#>
			<cfset thisName = #replace(thisName," ","_","all")#>
			<cfset thisName = #replace(thisName,"-","_","all")#>
			<cfset thisName = #left(thisName,20)#>
			
			<cfif #val# is "total length">
				<cfset totlen = "#evaluate("data." &  thisName)#">
			</cfif>
			<cfif #val# is "tail length">
				<cfset taillen = "#evaluate("data." &  thisName)#">
			</cfif>
			<cfif #val# is "hind foot with claw">
				<cfset hf = "#evaluate("data." &  thisName)#">
			</cfif>
			<cfif #val# is "ear from notch">

				<cfset efn = "#evaluate("data." &  thisName)#">
			</cfif>
			<cfif #val# is "weight">
				<cfset weight = "#evaluate("data." &  thisName)#">
			</cfif>
		</cfloop>
		<cfif len(#totlen#) gt 0>
			<cfif #trim(totlen)# contains " ">
				<cfset spacePos = find(" ",totlen)>
				<cfset totlen_val = trim(left(totlen,#spacePos#))>
				<cfset totlen_Units = trim(right(totlen,len(totlen) - #spacePos#))>
			</cfif>		
		</cfif>
		<cfif len(#taillen#) gt 0>
			<cfif #trim(taillen)# contains " ">
				<cfset spacePos = find(" ",taillen)>
				<cfset taillen_val = trim(left(taillen,#spacePos#))>
				<cfset taillen_Units = trim(right(taillen,len(taillen) - #spacePos#))>
			</cfif>		
		</cfif>
		<cfif len(#hf#) gt 0>
			<cfif #trim(hf)# contains " ">
				<cfset spacePos = find(" ",hf)>
				<cfset hf_val = trim(left(hf,#spacePos#))>
				<cfset hf_Units = trim(right(hf,len(hf) - #spacePos#))>
			</cfif>		
		</cfif>
		<cfif len(#efn#) gt 0>
			<cfif trim(#efn#) contains " ">
				<cfset spacePos = find(" ",efn)>
				<cfset efn_val = trim(left(efn,#spacePos#))>
				<cfset efn_Units = trim(right(efn,len(efn) - #spacePos#))>
			</cfif>		
		</cfif>
		<cfif len(#weight#) gt 0>
			<cfif trim(#weight#) contains " ">
				<cfset spacePos = find(" ",weight)>
				<cfset weight_val = trim(left(weight,#spacePos#))>
				<cfset weight_Units = trim(right(weight,len(weight) - #spacePos#))>
			</cfif>		
		</cfif>
		
			<cfif len(#totlen#) gt 0>
				<cfif #totlen_Units# is "mm">
					<cfset meas = "#totlen_val#-">
				<cfelse>
					<cfset meas = "#totlen_val# #totlen_units#-">
				</cfif>
			<cfelse>
				<cfset meas="X-">
			</cfif>
			
			<cfif len(#taillen#) gt 0>
				<cfif #taillen_Units# is "mm">
					<cfset meas = "#meas##taillen_val#-">
				<cfelse>
					<cfset meas = "#meas##taillen_val# #taillen_Units#-">
				</cfif>
			<cfelse>
				<cfset meas="#meas#X-">
			</cfif>
			
			<cfif len(#hf#) gt 0>
				<cfif #hf_Units# is "mm">
					<cfset meas = "#meas##hf_val#-">
				<cfelse>
					<cfset meas = "#meas##hf_val# #hf_Units#-">
				</cfif>
			<cfelse>
				<cfset meas="#meas#X-">
			</cfif>
	
			<cfif len(#efn#) gt 0>
				<cfif #efn_Units# is "mm">
					<cfset meas = "#meas##efn_val#=">
				<cfelse>
					<cfset meas = "#meas##efn_val# #efn_Units#=">
				</cfif>
			<cfelse>
				<cfset meas="#meas#X=">
			</cfif>
			
			<cfif len(#weight#) gt 0>
				<cfset meas = "#meas##weight_val# #weight_Units#">
			<cfelse>
				<cfset meas="#meas#X">
			</cfif>
		<cfset stripParts = "">
		<cfset tiss = "">
		<cfloop list="#parts#" delimiters=";" index="p">
			<cfif #p# contains "(frozen)">
				<cfset tiss="tissues (frozen)">
			<cfelseif #p# does not contain "ethanol">
				<cfif len(#stripParts#) is 0>
					<cfset stripParts = #p#>
				<cfelse>
					<cfset stripParts = "#stripParts#; #p#">
				</cfif>
			</cfif>
		</cfloop>
		<cfset accn = replace(accn_number,".Mamm","","all")>
		<cfif len(#tiss#) gt 0>
			<cfset stripParts = "#stripParts#; #tiss#">
		</cfif>
		<cfif left(stripParts,2) is "; ">
			<cfset stripParts = right(stripParts,len(stripParts) - 2)>
		</cfif>
		<cfset thisDate = "">
		<cftry>
			<cfset thisDate = #dateformat(verbatim_date,"dd mmm yyyy")#>
			<cfcatch>
				<cfset thisDate = #verbatim_date#>
			</cfcatch>
		</cftry>
	<cfset t=#t#+1>	
	<cfset i=#i#+1>	
	<cfif #i# is 1>
		<table cellpadding="0" cellspacing="0">	
	</cfif>
	
	<cfif #t# is 1>
				<tr>
			</cfif>
			<cfset borderstyle = "border-bottom: 1 px solid ##CCCCCC; border-left: 1 px solid ##CCCCCC;">
					<cfif #i# lte #numCols#><!--- first row of the table --->
						<cfset borderstyle = "#borderstyle#; border-top: 1 px solid ##CCCCCC;">
					</cfif>
					<cfif #r# is #rc#><!--- LAST RECORD row of the table --->
						<cfset borderstyle = "#borderstyle#; border-right: 1 px solid ##CCCCCC;">
					</cfif>
					<cfif #t# is #numCols#><!--- RIGHT COLUMN --->
						<cfset borderstyle = "#borderstyle#; border-right: 1 px solid ##CCCCCC;">
					</cfif>
					
					<td style="padding:#cellPadVal#px; #borderstyle#">
					
		<div style="position:relative;  width:#width#px; height:#height#px; padding:0px;" align="center">
			
			<div style="position:absolute; background-color:#c1#;
				top:0px; 
				left:0px; 
				height:8px; 
				width:#fullCellWidth#px;
				overflow:hidden; 
				padding:1px;
				font-stretch:ultra-condensed;" 
				align="left"  
				class="arial8b">UAM #cat_num#</div>
			<div style="position:absolute; background-color:#c2#;
				top:8px; 
				left:0px; 
				height:6;			
				width:#fullCellWidth#px;
				overflow:hidden;
				padding:1px;
				font-stretch:ultra-condensed;" 	
				align="right"  
				class="arial6bi">#trim(Scientific_Name)#</div>
			<div style="position:absolute; background-color:#c3#;
				top:14px; 
				left:0px; 
				height:20px;			
				width:#fullCellWidth#px;
				overflow:hidden;
				padding:1px;
				font-stretch:ultra-condensed;" 	
				align="left"  
				class="arial6">#geog#</div>
			<cfset thisPart = .5>
			<cfset thisCellWidth = fullCellWidth * thisPart>
			<div style="position:absolute; background-color:#c4#;
				top:35px; 
				left:0px; 
				height:6px;			
				width:#thisCellWidth#px;
				overflow:hidden;
				padding:1px;
				font-stretch:ultra-condensed;" 	
				align="left"  
				class="arial4">#coordinates#</div>
			<cfset thisCellLeft = thisCellWidth>
			<cfset thisCellWidth = fullCellWidth  * (1-thisPart)>
			<div style="position:absolute; background-color:#c1#;
				top:35px; 
				left:#thisCellLeft#px; 
				height:6px;			
				width:#thisCellWidth#px;
				overflow:hidden;
				padding:1px;
				font-stretch:ultra-condensed;" 	
				align="right"  
				class="arial6"><cfif len(#quad#) gt 0>[#quad#]</cfif></div>
			<div style="position:absolute; background-color:#c2#;
				top:41px; 
				left:0px; 
				height:6px;			
				width:#fullCellWidth#px;
				overflow:hidden;
				padding:1px;
				font-stretch:ultra-condensed;" 	
				align="left"  
				class="arial6">Coll:&nbsp;&nbsp;#thisColl#</div>
			<cfset thisPart = .5>
			<cfset thisCellWidth = fullCellWidth * thisPart>
			<div style="position:absolute; background-color:#c3#;
				top:47px; 
				left:0px; 
				height:6px;			
				width:#thisCellWidth#px;
				overflow:hidden;
				padding:1px;
				font-stretch:ultra-condensed;" 	
				align="left"  
				class="arial6">#thisDate#</div>
			<cfset thisCellLeft = thisCellWidth>
			<cfset thisCellWidth = fullCellWidth  * (1-thisPart)>
			<div style="position:absolute; background-color:#c4#;
				top:47px; 
				left:#thisCellLeft#px; 
				height:6px;			
				width:#thisCellWidth#px;
				overflow:hidden;
				padding:1px;
				font-stretch:ultra-condensed;" 	
				align="right"  
				class="arial6">Sex: #sexcode#</div>
			<cfset thisPart = .75>
			<cfset thisCellWidth = fullCellWidth * thisPart>
			<div style="position:absolute; background-color:#c1#;
				top:53px; 
				left:0px; 
				height:6px;			
				width:#thisCellWidth#px;
				overflow:hidden;
				padding:1px;
				font-stretch:ultra-condensed;" 	
				align="left"  
				class="arial6">#meas#</div>
			<cfset thisCellLeft = thisCellWidth>
			<cfset thisCellWidth = fullCellWidth  * (1-thisPart)>
			<div style="position:absolute; background-color:#c2#;
				top:53px; 
				left:#thisCellLeft#px; 
				height:6px;			
				width:#thisCellWidth#px;
				overflow:hidden;
				padding:1px;
				font-stretch:ultra-condensed;" 	
				align="right"  
				class="arial6">#af#</div>
			<div style="position:absolute; background-color:#c3#;
				top:59px; 
				left:0px; 
				height:11px;			
				width:#fullCellWidth#px;
				overflow:hidden;
				padding:1px;
				font-stretch:ultra-condensed;" 	
				align="left"  
				class="arial4">#stripParts#</div>
			<cfset thisPart = .5>
			<cfset thisCellWidth = fullCellWidth * thisPart>
			<div style="position:absolute; background-color:#c1#;
				top:70px; 
				left:0px; 
				height:6px;			
				width:#thisCellWidth#px;
				overflow:hidden;
				padding:1px;
				font-stretch:ultra-condensed;" 	
				align="left"  
				class="arial6">#FieldNum#</div>
			<cfset thisCellLeft = thisCellWidth>
			<cfset thisCellWidth = fullCellWidth  * (1-thisPart)>
			<div style="position:absolute; background-color:#c2#;
				top:70px; 
				left:#thisCellLeft#px; 
				height:6px;			
				width:#thisCellWidth#px;
				overflow:hidden;
				padding:1px;
				font-stretch:ultra-condensed;" 	
				align="right"  
				class="arial6">Accn:&nbsp;#accn#</div>
				
				
			</div>
				<!----
			<div style="position:absolute; background-color:#c3#;
				top:16px; 
				left:2px; 
				width:#fullCellWidth#; 
				overflow:hidden;
				height:21px; 
				padding-left:2px; 
				padding-right:2px;" align="left"  class="arial6">
					#geog#
			</div>
			<div style="position:absolute;  background-color:#c4#;
				top:37px; 
				left:2px; 
				width:75px; 
				overflow:hidden; 
				height:8px; 
				padding:1px;" 
				align="left"  
				class="arial6">
					#coordinates#
			</div>
			<div style="position:absolute;   background-color:#c1#;
				top:37px; 
				left:78px; 
				width:68px; 
				overflow:hidden; 
				height:8px; 
				padding:1px;" 
				align="right"
				class="arial6"><cfif len(#quad#) gt 0>[#quad#]</cfif>
			</div>
			<div style="position:absolute;   background-color:#c2#;
				top:45px; 
				left:2px; 
				width:144px; 
				overflow:hidden; 
				height:8px; 
				padding:1px;" align="left"  class="arial6">
				Coll:&nbsp;&nbsp;#thisColl#
			</div>
			<div style="position:absolute; background-color:#c3#;
				top:53px; left:2px; width:75px; overflow:hidden; 
				height:8px; padding:1px;" align="left"  class="arial6">
				#thisDate#
			</div>
			<div style="position:absolute; background-color:#c4#;
				top:53px; left:78px; width:68px; overflow:hidden; 
				height:8px; padding:1px;" align="right"  class="arial6">
				Sex: #sexcode#
			</div>
			<div style="position:absolute; background-color:#c1#;
				top:60px; left:2px; width:95px; overflow:hidden; 
				height:8px; padding:1px;" align="left"  class="arial6">
				#meas#
			</div>
			<div style="position:absolute; background-color:#c2#;
				top:60px; left:100px; width:46px; overflow:hidden; 
				height:8px; padding:1px;" align="right"  
				class="arial6">#af#</div>
			<div style="position:absolute; background-color:#c3#;
				top:68px; left:2px; width:144px; overflow:hidden; 
				height:11px; padding:1px;" align="left"  class="arial4">
				#stripParts#
			</div>
			<div style="position:absolute; background-color:#c4#;
				top:79px; left:2px; width:77px; overflow:hidden; 
				height:8px; padding:1px;" align="left"  class="arial6">
				#FieldNum#
			</div>
			<div style="position:absolute; background-color:#c1#;
				top:79px; left:80px; width:66px; overflow:hidden; 
				height:8px; padding:1px;" align="right"  class="arial6">
				Accn #accn#&nbsp;
			</div>
			--->
		</div>
	
	</td>
			<cfif #t# is #numCols#>
				<cfset t=0>
				</tr>
				</cfif>
	<cfif #i# is (#numRows# * #numCols#)>
		<cfset i=0>
		</table>
		<cfdocumentitem type="pagebreak"></cfdocumentitem>
		<!---
		--->
	</cfif>	
			
	<cfset lPos = #lPos# + #width#>
	<cfset r=#r#+1>
	</cfloop>
	<!-----
	
	----->
	</cfdocument>
	<a href="/temp/UamMammalVialLabels.pdf">Get the PDF</a>
	</cfoutput>
	</cfif><!--- end action not nothing --->
