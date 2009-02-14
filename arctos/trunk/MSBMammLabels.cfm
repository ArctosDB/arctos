<cfif not isdefined("collection_object_id")>
		<cfabort>
	</cfif>
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
			identification.scientific_name,
			state_prov,
			country,
			quad,
			county,
			island,
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
			concatColl(cataloged_item.collection_object_id) as collectors,
			ConcatAttributeValue(cataloged_item.collection_object_id,'sex') as sex,
			concatotherid(cataloged_item.collection_object_id) as other_ids,
			concatparts(cataloged_item.collection_object_id) as parts,
			concatsingleotherid(cataloged_item.collection_object_id,'NK') as NK,
			verbatim_date,
			accn_num_prefix,
			accn_num,
			family,
			accn_num_suffix
			#seleAttributes#
		FROM
			cataloged_item
			INNER JOIN identification ON (cataloged_item.collection_object_id = identification.collection_object_id)
			INNER JOIN identification_taxonomy ON (identification.identification_id = identification_taxonomy.identification_id)
			INNER JOIN taxonomy ON (identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id)
			INNER JOIN collecting_event ON (cataloged_item.collecting_event_id = collecting_event.collecting_event_id)
			INNER JOIN locality ON (collecting_event.locality_id = locality.locality_id)
			INNER JOIN geog_auth_rec ON (locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id)
			LEFT OUTER JOIN accepted_lat_long ON (locality.locality_id = accepted_lat_long.locality_id)
			LEFT OUTER JOIN accn ON (cataloged_item.accn_id=accn.transaction_id)			
		WHERE
			accepted_id_fg=1 AND cataloged_item.collection_object_id IN (#collection_object_id#)		
			">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>

<!------------------------------->
<cfoutput>
<!--- pre-build the barcodes we'll need here --->
<cfloop query="data">
	<cf_makeBarcode barcode="#cat_num#">
</cfloop>
<!---

--->
<cfdocument 
	format="flashpaper"
	pagetype="letter"
	margintop="0"
	marginbottom="0"
	marginleft="0"
	marginright="0"
	orientation="portrait" >
	
<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">
<cfset i=0>
<cfset t=0>
<cfset numRows = 3>
<cfset numCols = 6>
<cfset lPos = 0><!--- position from left --->
<cfset tPos = 0><!--- position from top --->
<cfset pageNum = 1><!--- position from top --->
<cfset width = 100>
<cfset height=240>
<cfset pageHeight=975>
<cfset bug="">
<cfset thisRow = 1>
<cfset r=1>
<cfset rc = data.recordcount>

 <cfloop query="data">
 	<cfquery name="tCollNum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select display_value from coll_obj_other_id_num where
		other_id_type='NK'
		and collection_object_id=#collection_object_id#
	</cfquery>
	<cfset coordinates = "">
	<cfif len(#verbatimLatitude#) gt 0 AND len(#verbatimLongitude#) gt 0>
		<cfset coordinates = "#verbatimLatitude# / #verbatimLongitude#">
		<cfset coordinates = replace(coordinates,"d","&##176;","all")>
		<cfset coordinates = replace(coordinates,"m","'","all")>
		<cfset coordinates = replace(coordinates,"s","''","all")>
	</cfif>
	
	<cfset geog = "#country#">
	<cfif len(#state_prov#) gt 0>
		<cfset geog = "#geog#, #state_prov#">
	</cfif>
	<cfif len(#county#) gt 0>
		<cfset geog = "#geog#, #county#">	
	</cfif>
	<cfif len(#quad#) gt 0>
		<cfset geog = "#geog#, #quad#">	
	</cfif>
	<cfset geog = "#geog#, #spec_locality#">
		
	<cfset geog=replace(geog,": , ",": ","all")>
		
		<cfif #sex# contains "female">
			<cfset sexcde = replace(sex,"female","&##9792;")>
		<cfelseif #sex# contains "male">
			<cfset sexcde = replace(sex,"male","&##9794;")>
		<cfelse>
			<cfset sexcde = "?">
		</cfif>
		
		
		
		<!---
		<cfset sexcode = replace(sex,"female","F">
		<cfset sexcode = replace(sex,"female","F">
		<cfset sexcode = replace(sex,"male","M">
		
		<cfif len(#sex#) gt 0>
			<cfif #sex# is "male">
				<cfset sexcode = "M">
			<cfelseif #sex# is "female">
				<cfset sexcode = "F">
			<cfelse>
				<cfset sexcode = "?">
			</cfif>
		</cfif>
		--->
		<cfif #collectors# contains ",">
			<Cfset spacePos = find(",",collectors)>
			<cfset thisColl = left(collectors,#SpacePos# - 1)>
			<cfset thisColl = "#thisColl# et al.">
		<cfelse>
			<cfset thisColl = #collectors#>
		</cfif>
		
		<cfset stripParts = "">
		<cfset tiss = "">
		<cfloop list="#parts#" delimiters=";" index="p">
			<cfif #p# contains "(frozen)">
				<cfset tiss="tissues (frozen)">
			<cfelse>
				<cfif len(#stripParts#) is 0>
					<cfset stripParts = #p#>
				<cfelse>
					<cfset stripParts = "#stripParts#; #p#">
				</cfif>
			</cfif>
		</cfloop>
		<cfif len(#tiss#) gt 0>
			<cfset stripParts = "#stripParts#; #tiss#">
		</cfif>
		<cfset thisDate = "">
		<cftry>
			<cfset thisDate = #dateformat(verbatim_date,"dd mmm yyyy")#>
			<cfcatch>
				<cfset thisDate = #verbatim_date#>
			</cfcatch>
		</cftry>
	<!---
	
	<cfif #lPos# gte (#numCols# * #width#)>
		<cfset thisRow=#thisRow#+1>
		<cfset lPos = 0>
		<cfset tPos = #tPos# + (#height# - 1)>
		<cfif #thisRow# gte (#numRows# + 1)>
			<cfset pageNum = #pageNum# + 1>
			<cfset tPos = (#pageHeight# * (#pageNum# - 1))>
			<cfset thisRow = 1>
		</cfif>
	</cfif>
	--->
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
					<td style="padding:0px; #borderstyle#">
						<div style="  position:relative;  width:#width#px; height:#height#px;" align="center">
							<div style="position:absolute;
								top:3px; 
								left:0px; 
								width:98px;
								height:20px;"
								align="center"  
								class="arial6b">
									MUSEUM OF SOUTHWESTERN<br />BIOLOGY
							</div>
							<!---
							<cfscript>
								thisBC = "#cat_num#";
								thisBC = toString(thisBC);
								myBarcodeobj = CreateObject("Java", "net.sourceforge.barbecue.Barcode");
								barcode_3of9 = createobject("java", "net.sourceforge.barbecue.linear.code39.Code39Barcode");
								myBarcodeImageHandler = CreateObject("Java", "net.sourceforge.barbecue.BarcodeImageHandler");
								mybarcode_output = barcode_3of9.init(thisBC, false, true);
								Image = myBarcodeImageHandler.getImage(mybarcode_output);
								ImageIO = CreateObject("Java", "javax.imageio.ImageIO");
								OutputStream = CreateObject("Java", "java.io.FileOutputStream");
								OutputStream.init("/var/www/html/temp/msb#cat_num#.jpg");
								ImageIO.write(Image, "jpg", OutputStream);
								Image.flush();
								OutputStream.close();
							</cfscript>
							--->
							<div style="position:absolute;
								top:22px; 
								left:0px; 
								width:98px;
								height:20px;"
								align="center"  
								class="arial6b">
									<img src="/temp/#cat_num#.jpg" border="0" height="15"/>
							</div>
							<div style="position:absolute;
								top:42px; 
								left:0px; 
								width:98px;
								height:8px;"
								align="center"  
								class="arial8b">
									MSB: #cat_num#
							</div>
							<div style="position:absolute;
								overflow:hidden;
								top:58px; 
								left:0px; 
								width:98px;
								height:10px;"
								align="center"  
								class="arial7">
									<i>#replace(scientific_name," ","&nbsp;","all")#</i>
							</div>
							<div style="position:absolute;
								top:70px; 
								left:0px; 
								width:98px;
								height:8px;
								padding-left:2px;"
								align="left"  
								class="arial7b">
									#family#
							</div>
							<div style="position:absolute;
								top:80px; 
								left:0px; 
								width:98px;
								height:8px;
								padding-left:2px;"
								align="left"  
								class="arial6">
									<cfif len(#nk#) gt 0>
										NK ##: #nk#
									</cfif>									
							</div>
							<div style="position:absolute;
								top:90px; 
								left:0px; 
								width:98px;
								height:16px;
								padding-left:2px;"
								align="left"  
								class="arial5">
									Coll: #thisColl#
							</div>
							<div style="position:absolute;
								top:110px; 
								left:0px; 
								width:98px;
								height:16px;
								padding-left:2px;"
								align="left"  
								class="arial5">
									<!---Prep: coming soon...---->
							</div>
							<div style="position:absolute; overflow:hidden;
								top:130px; 
								left:0px; 
								width:98px;
								height:40px;
								padding-left:2px;"
								align="left"  
								class="arial7">
									#geog#
							</div>
							<div style="position:absolute;
								top:170px; 
								left:0px; 
								width:98px;
								height:10px;
								padding-left:2px;"
								align="left"  
								class="arial6">
									Sex: #sex#
							</div>
							<div style="position:absolute;
								top:190px; 
								left:0px; 
								width:98px;
								height:8px;
								padding-left:2px;"
								align="left"  
								class="arial6">
									Date: #verbatim_date#
							</div>
							<div style="position:absolute;
								top:210px; 
								left:0px; 
								width:98px;
								height:10px;
								padding-left:2px;"
								align="left"  
								class="arial6">
									Parts: #stripParts#
							</div>
						</div>
							
			
					</td><cfif #t# is #numCols#>
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
	
	-----></cfdocument>
	
	</cfoutput>
