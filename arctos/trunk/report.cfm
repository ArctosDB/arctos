<!---
Title: report.cfm
Author: Peter DeVore
Email: pdevore@berkeley.edu

Description:
	Allows users to extract information from the database in the form of a
	.pdf (Adobe Acrobat) file for uses such as printing it out.
Parameters:
	action (optional):
		If unspecified or 'nothing', will go to formatting page.
		If generatePDF, additional parameters become available
		(for a list of those parameters, look at the form in
		<cfif action is 'nothing'> tag).
	collection_object_id:
		List of comma separate specimen IDs.
	accn_number (optional):
		The accession number if it is for the ledger.
Based on:
	loanShipLabel.cfm for its cfdocument usage
	narrowLabels.cfm and wideLabels.cfm for its queries.
--->

<cfif not isdefined("institution_appearance")>
	<cfset institution_appearance = "">
</cfif>
<!---
DLM: I have no idea what this is trying to do, but it won't work.
<cfoutput>
	<cf_get_header collection_id="#exclusive_collection_id#">
</cfoutput>
---->
<cfif not isdefined("collection_object_id")>
	Need specimens to make a report/ledger!
	<cfabort>
</cfif>
<cfif not isdefined('action')>
	<cfset action='nothing'>
	Action was not defined! That's the whole problem.
</cfif>

<cfif #action# is 'generatePDF'>
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
<!--- seleAttributes determines which additional attributes to select in the
following SQL query. Includes age, sex, etc. takes the concatentation, and
returns it as the attribute_type.--->
<cfset seleAttributes = "">
<cfloop query="ctAtt">
	<cfset thisName = #ctAtt.attribute_type#>
	<cfset thisName = #replace(thisName," ","_","all")#>
	<cfset thisName = #replace(thisName,"-","_","all")#>
	<cfset thisName = #left(thisName,20)#>
	<cfif #thisName# is not "sex"><!--- already got it --->
		<cfset seleAttributes = "#seleAttributes#,ConcatAttributeValue(cataloged_item.collection_object_id,'#ctAtt.attribute_type#')
				as #thisName#">
	</cfif>
</cfloop>
<!--- Determines how the data are ordered. --->
<cfif isdefined('order_by')>
	<cfif len(order_by) gt 0>
		<cfif order_by is "location">
			<cfset order_by = "country, state_prov, county, island, spec_locality">
		</cfif>
		<cfset order_by="ORDER BY #order_by#">
	</cfif>
<cfelse>
	<cfset order_by = "">
</cfif>
<!--- Ends determining how the data are ordered. --->
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
		verbatim_date,
		accn_num_prefix,
		accn_num,
		accn_num_suffix,
		concatotherid(cataloged_item.collection_object_id) as other_id_list,

		orig_elev_units,
		MAXIMUM_ELEVATION,
		MINIMUM_ELEVATION,
		datum,

		coll_object_remarks

		#seleAttributes#
	FROM
		cataloged_item
		INNER JOIN identification ON (cataloged_item.collection_object_id = identification.collection_object_id)
		INNER JOIN collecting_event ON (cataloged_item.collecting_event_id = collecting_event.collecting_event_id)
		INNER JOIN locality ON (collecting_event.locality_id = locality.locality_id)
		INNER JOIN geog_auth_rec ON (locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id)
		LEFT OUTER JOIN accepted_lat_long ON (locality.locality_id = accepted_lat_long.locality_id)
		LEFT OUTER JOIN accn ON (cataloged_item.accn_id=accn.transaction_id)
		LEFT OUTER JOIN event_location ON (event_location.collecting_event_id = cataloged_item.collecting_event_id)
		LEFT OUTER JOIN coll_object_remark ON (coll_object_remark.collection_object_id = cataloged_item.collection_object_id)
	WHERE
		accepted_id_fg=1 AND
		cataloged_item.collection_object_id IN (#collection_object_id#)
		#order_by#
">
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(sql)#
</cfquery>
<!----------------------------------------------------------------->
<cfoutput>
<cfif len(top_margin) is 0>
	<cfset top_margin = ".5">
</cfif>
<cfif len(bottom_margin) is 0>
	<cfset bottom_margin = ".5">
</cfif>
<cfif len(left_margin) is 0>
	<cfset left_margin = ".5">
</cfif>
<cfif len(right_margin) is 0>
	<cfset right_margin = ".5">
</cfif>
<cfdocument
        format="pdf"
        pagetype="letter"
		fontembed='yes'
        margintop="#top_margin#"
        marginbottom="#bottom_margin#"
        marginleft="#left_margin#"
        marginright="#right_margin#"
		unit="in"
        orientation="landscape" filename="#Application.webDirectory#/temp/report_#cfid#_#cftoken#.pdf" overwrite="true">

<!---<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">--->

<!--- major variables for format and layout --->

<cfset pageNum = 1>
<cfset curRow = 0>
<cfset curRecord = 0>
<cfset maxRecord = data.recordcount>
<!---I don't use these... but they may be useful later.
<cfset height = 140>
<cfset pageHeight=975>
<cfset bug="">--->
<!--- layout defaults --->
<!---<cfset defaultMaxRowsFirstPage = 6>
<cfset defaultMaxRowsAfterPage = 7>
NOTE1*: carla cicero said to have header on every page--->
<cfset defaultMaxRowsPerPage = 10>
<cfset defaultTwoPagesOnly = false>
<!--- layout settings --->
<!---<cfif len(first_page_rows) eq 0>
	<cfset maxRowsFirstPage = defaultMaxRowsFirstPage>
<cfelse>
	<cfset maxRowsFirstPage = first_page_rows>
</cfif>
<cfif len(after_page_rows) eq 0>
	<cfset maxRowsAfterPage = defaultMaxRowsAfterPage>
<cfelse>
	<cfset maxRowsAfterPage = after_page_rows>
</cfif>
deprecated: see NOTE1*--->
<cfif len(rows_per_page) eq 0>
	<cfset maxRowsPerPage = defaultMaxRowsPerPage>
<cfelse>
	<cfset maxRowsPerPage = rows_per_page>
</cfif>
<cfif not isdefined('two_pages_only')>
	<cfset twoPagesOnly = defaultTwoPagesOnly>
<cfelse>
	<cfset twoPagesOnly = two_pages_only>
</cfif>
<!--- end layout defaults and settings --->
<!--- text settings and defaults --->
<!--- text defaults --->
<cfif report_type is 'ledger'>
	<cfset headerText = 'MVZ $ Catalog Ledger'>
	<cfif not isdefined('catalog_type')>
		<cfset catalog_type = ''>
	</cfif>
	<cfif catalog_type is 'Mamm'>
		<cfset headerText = replace(headerText, '$', 'Mammal')>
	<cfelseif catalog_type is 'Herp'>
		<cfset headerText = replace(headerText, '$', 'Herp')>
	<cfelseif catalog_type is 'Bird'>
		<cfset headerText = replace(headerText, '$', 'Bird')>
	<cfelseif catalog_type is 'Egg'>
		<cfset headerText = replace(headerText, '$', 'Egg')>
	<cfelse>
		<cfset headerText = replace(headerText, '$ ', '')>
	</cfif>
	<cfif accn_number is not ''>
		<cfset headerText = '#headerText# #accn_number#'>
	</cfif>
<cfelse> <!--- Otherwise report_type is 'permit'--->
	<cfset headerText = "Permit Report:">
	<cfif len(issuedByAgent) gt 0>
		<cfset headerText = "#headerText# #issuedByAgent#">
	</cfif>
	<cfif len(permitNum) gt 0> 
		<cfset headerText = "#headerText# No. #permitNum#">
	</cfif>
	<cfif len(issuedToAgent) gt 0> 
		<cfset headerText = "#headerText# to #issuedToAgent#">
	</cfif>
	<cfif headerText is "Permit Report:">
		<cfset headerText = "Permit Report">
	</cfif>
</cfif>
<cfset defaultHeaderTextSize = '10'>
<cfset defaultHeaderTextSizeModifier = 'pt'>
<cfset defaultHeaderTextFont = 'Verdana'>
<cfset defaultTextSize = '8'>
<cfset defaultTextSizeModifier = 'pt'>
<cfset defaultTextFont = 'Verdana'>
<!--- text settings --->
<cfif len(header_text_size) eq 0>
	<cfset headerTextSize = defaultHeaderTextSize>
<cfelse>
	<cfset headerTextSize = header_text_size>
</cfif>
<cfif isdefined('header_text_size_modifier') >
	<cfif len(header_text_size_modifier) eq 0>
		<cfset headerTextSizeModifier = defaultHeaderTextSizeModifier>
	<cfelse>
		<cfset headerTextSizeModifier = header_text_size_modifier>
	</cfif>
<cfelse>
	<cfset headerTextSizeModifier = defaultHeaderTextSizeModifier>
</cfif>

<cfset headerTextFont = text_font>

<cfif len(text_size) eq 0>
	<cfset textSize = defaultTextSize>
<cfelse>
	<cfset textSize = text_size>
</cfif>
<cfif isdefined('text_size_modifier') >
	<cfif len(text_size_modifier) eq 0>
		<cfset textSizeModifier = defaultTextSizeModifier>
	<cfelse>
		<cfset textSizeModifier = text_size_modifier>
	</cfif>
<cfelse>
	<cfset textSizeModifier = defaultTextSizeModifier>
</cfif>
<cfif len(text_font) eq 0>
	<cfset textFont = defaultTextFont>
<cfelse>
	<cfset textFont = text_font>
</cfif>

<cfset headerTextStyle = "font-family: '#headerTextFont#',
		sans-serif; font-weight:600; font-size: #headerTextSize##headerTextSizeModifier#">
<cfset textStyle = "font-family: '#textFont#',
		sans-serif; font-size: #textSize##textSizeModifier#">
<!--- end text settings and defaults --->
<!--- end major variables for format and layout --->

 <cfloop query="data">
        <cfquery name="tCollNum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
                select other_id_number from coll_obj_other_id_num where
                other_id_type='collector number'
                and collection_object_id=#collection_object_id#
        </cfquery>
		<!--- Start data manipulation --->
        <cfset coordinates = "">
        <cfif len(#verbatimLatitude#) gt 0 AND len(#verbatimLongitude#) gt 0>
                <cfset coordinates = "#verbatimLatitude# / #verbatimLongitude#">
                <cfset coordinates = replace(coordinates,"d","&##176;","all")>
                <cfset coordinates = replace(coordinates,"m","'","all")>
                <cfset coordinates = replace(coordinates,"s","''","all")>
        </cfif>
        <cfset highergeog = "">
			<cfif len(#country#) gt 0>
				<cfif len(highergeog) gt 0>
					<cfset highergeog = "#highergeog#; ">
				</cfif>
				<cfset highergeog = "#highergeog##country#">
			</cfif>
			<cfif len(#state_prov#) gt 0>
				<cfif len(highergeog) gt 0>
					<cfset highergeog = "#highergeog#; ">
				</cfif>
				<cfset highergeog = "#highergeog##state_prov#">
			</cfif>
           	<cfif len(#county#) gt 0>
				<cfif len(highergeog) gt 0>
					<cfset highergeog = "#highergeog#; ">
				</cfif>
               	<cfset highergeog = "#highergeog##county#">
			</cfif>
           	<cfif len(#island#) gt 0>
				<cfif len(highergeog) gt 0>
					<cfset highergeog = "#highergeog#; ">
				</cfif>
               	<cfset highergeog = "#highergeog##island#">
			</cfif>
				<!--- outdated code
		<cfset geog="#spec_locality#">
                <cfif #country# is "United States">
                        <cfif len(#county#) gt 0>
                                <cfset geog = "#geog#, #county#">
                        </cfif>
                        <cfif len(#state_prov#) gt 0>
                                <cfset geog = "#geog#, #state_prov#">
                        </cfif>
                <cfelse>
                        <cfif len(#state_prov#) gt 0>
                                <cfset geog = "#geog#, #state_prov#">
                        </cfif>
                        <cfif len(#country#) gt 0>
                                <cfset geog = "#geog#, #country#">
                        </cfif>
                </cfif>
                <cfset geog=replace(geog,": , ",": ","all")>--->

                <cfif #sex# contains "female">
                        <cfset sexcde = replace(sex,"female","&##9792;")>
                <cfelseif #sex# contains "male">
                        <cfset sexcde = replace(sex,"male","&##9794;")>
                <cfelse>
                        <cfset sexcde = "?">
                </cfif>

				<cfset secondColl = "">
                <cfif #collectors# contains ";">
                        <Cfset spacePos = find(";",collectors)>
                        <cfset thisColl = left(collectors,#spacePos# - 1)>
                        <cfset secondColl = right(collectors, len(collectors) - spacesPos)>
                <cfelse>
                        <cfset thisColl = #collectors#>
                </cfif>

                <cfset stripParts = "">
                <cfset tiss = "">
		<!---
		Here is the logic of whether to add skin and skull stuff.
		If the parts contains both skin and skull we don't want either to show up.
		If it contains skin and skull and at least one other thing, we want a '+' at the beginning.
		If the parts contains skin or skull, we want that one to show up.
		--Peter DeVore, email: pdevore@berkeley.edu
		Note that the logic here is now mammal specific.  will add new logic
		for other catalog institutions.
		--Peter DeVore, email: pdevore@berkeley.edu--->
		<cfif catalog_type is 'Mamm'>
				<cfset studyskin=false>
				<cfset skull=false>
				<cfset otherPartAdded=false>
				<cfloop list='#parts#' delimiters=';' index='p'>
					<cfif #p# contains 'skin'>
						<cfset studyskin=true>
					</cfif>
					<cfif #p# contains 'skull'>
						<cfset skull=true>
					</cfif>
					<cfif not (#p# contains 'skin') and not (#p# contains 'skull')>
						<cfset otherPartAdded = true>
					</cfif>
				</cfloop>
                <cfloop list="#parts#" delimiters=";" index="p">
                    <cfif #p# contains "(frozen)">
                        <cfset tiss="tissues (frozen)">
                    <cfelse>
						<cfif (not (#p# contains 'skin') and not (#p# contains 'skull')) or
								(((#p# contains 'skin') or (#p# contains 'skull')) and
									((studyskin and not skull) or (skull and not studyskin)))>
                        	<cfif len(#stripParts#) is 0>
								<cfset stripParts = #p#>
							<cfelse>
                            	<cfset stripParts = "#stripParts#; #p#">
							</cfif>
                         </cfif>
                    </cfif>
                </cfloop>
				<cfif studyskin and skull and otherPartAdded>
					<cfset stripParts = '+#Trim(stripParts)#'>
				</cfif>
		<cfelseif catalog_type is 'Bird'>
			<!--- test it --->
				<cfset studyskin=false>
				<cfset otherPartAdded=false>
				<cfloop list='#parts#' delimiters=';' index='p'>
					<cfif #p# contains 'skin'>
						<cfset studyskin=true>
					</cfif>
					<cfif not (#p# contains 'skin')>
						<cfset otherPartAdded = true>
					</cfif>
				</cfloop>
                <cfloop list="#parts#" delimiters=";" index="p">
                    <cfif #p# contains "(frozen)">
                        <cfset tiss="tissues (frozen)">
                    <cfelse>
						<cfif not (p contains 'skin') or 
								(not otherPartAdded and p contains 'skin')>
                        	<cfif len(#stripParts#) is 0>
								<cfset stripParts = #p#>
							<cfelse>
                            	<cfset stripParts = "#stripParts#; #p#">
							</cfif>
                         </cfif>
                    </cfif>
                </cfloop>
				<cfif studyskin and otherPartAdded>
					<cfset stripParts = '+#Trim(stripParts)#'>
				</cfif>
		<cfelseif catalog_type is 'Herp'>
			<!--- test it  --->
				<cfset wholeanimal=false>
				<cfset otherPartAdded=false>
				<cfloop list='#parts#' delimiters=';' index='p'>
					<cfif #p# contains 'whole animal (frozen)'>
						<cfset wholeanimal=true>
					</cfif>
					<cfif not (#p# contains 'whole animal (frozen)')>
						<cfset otherPartAdded = true>
					</cfif>
				</cfloop>
                <cfloop list="#parts#" delimiters=";" index="p">
                    <cfif #p# contains "(frozen)">
                        <cfset tiss="tissues (frozen)">
                    <cfelse>
						<cfif not (p contains 'whole animal (frozen)') or 
								(not otherPartAdded and p contains 'whole animal (frozen)')>
                        	<cfif len(#stripParts#) is 0>
								<cfset stripParts = #p#>
							<cfelse>
                            	<cfset stripParts = "#stripParts#; #p#">
							</cfif>
                         </cfif>
                    </cfif>
                </cfloop>
				<cfif wholeanimal and otherPartAdded>
					<cfset stripParts = '+#Trim(stripParts)#'>
				</cfif>
		<cfelseif catalog_type is 'Egg'>
			<!--- modify this to work --->
				<cfset studyskin=false>
				<cfset skull=false>
				<cfset otherPartAdded=false>
				<cfloop list='#parts#' delimiters=';' index='p'>
					<cfif #p# contains 'skin'>
						<cfset studyskin=true>
					</cfif>
					<cfif #p# contains 'skull'>
						<cfset skull=true>
					</cfif>
					<cfif not (#p# contains 'skin') and not (#p# contains 'skull')>
						<cfset otherPartAdded = true>
					</cfif>
				</cfloop>
                <cfloop list="#parts#" delimiters=";" index="p">
                    <cfif #p# contains "(frozen)">
                        <cfset tiss="tissues (frozen)">
                    <cfelse>
						<cfif (not (#p# contains 'skin') and not (#p# contains 'skull')) or
								(((#p# contains 'skin') or (#p# contains 'skull')) and
									((studyskin and not skull) or (skull and not studyskin)))>
                        	<cfif len(#stripParts#) is 0>
								<cfset stripParts = #p#>
							<cfelse>
                            	<cfset stripParts = "#stripParts#; #p#">
							</cfif>
                         </cfif>
                    </cfif>
                </cfloop>
				<cfif studyskin and skull and otherPartAdded>
					<cfset stripParts = '+#Trim(stripParts)#'>
				</cfif>
		</cfif>
                <cfif len(#tiss#) gt 0>
                        <cfset stripParts = "#stripParts#; #tiss#">
                </cfif>
				<!--- replace commonly abbreviated words with their abbreviations--->
                <cfset thisDate = "">
                <cftry>
                        <cfset thisDate = #dateformat(verbatim_date,"dd mmm yyyy")#>
                        <cfcatch>
                                <cfset thisDate = #verbatim_date#>
                        </cfcatch>
                </cftry>
		<!--- End data manipulation --->
<!--- Please note that you must wrap the plain text itself with the div
in order for cfdocument to apply the style characteristics.  You CANNOT
just put it around the entire table, or an entire row.  If you do so,
cfdocument will not use it. Period
--Peter DeVore
--->
		<cfset curRow = #curRow# + 1>
		<cfset curRecord = #curRecord# + 1>
        <cfif #curRow# is 1>
            <table cellpadding="0" cellspacing="0" border='1' rules='rows'>
				<colgroup colspan='4'>
					<col width='200' />
					<col width='200' />
					<col width='200' />
					<col width='50' />
				</colgroup>
				<!--- The header!!! --->
			<tr>
				<td colspan='4'>
					<div style="#headerTextStyle#">
					#headerText#
					</div>
				</td>
			</tr>
        </cfif>
			<tr>
				<td>
					<div style="#textStyle#">
					<strong>#cat_num#</strong><br />
					<strong>Parts:</strong> #stripParts#<br />
					<strong>Sex:</strong>
					<!--- If I can figure out a way to use
					the sex symbol, then use #sexcde#---> #sex#
					<cfif len(age) gt 0>
						<strong>Age: </strong>#age#
					</cfif>
					</div>
				</td>
				<td>
					<div style="#textStyle#">
					<strong><i>#Scientific_Name#</i></strong><br />
					<cfif thisColl is 'not recorded'>
						Collector:
					</cfif>
					#thisColl#
	                <cfif len(#tCollNum.other_id_number#) gt 0>
	                     (#tCollNum.other_id_number#)
	                </cfif>
	                <cfif secondColl is not "">
	                	, #secondColl#
	                </cfif>
					<cfloop list="#other_id_list#" delimiters=";" index="index" >
						<cfset temp = find("=",index)>
						<cfif #Trim(Left(index,temp-1))# is not 'collector number'>
							<br />#Trim(Left(index,temp-1))#: #Trim(Right(index,len(index)-temp))#
						</cfif>
					</cfloop>
					</div>
				</td>
				<td>
					<div style="#textStyle#">
					#highergeog#<br />
					#spec_locality#;
					<cfif maximum_elevation is not "" and
							minimum_elevation is not "" and
							orig_elev_units is not "">
						<cfif maximum_elevation is minimum_elevation>
							#minimum_elevation#
						<cfelse>
							#minimum_elevation#-#maximum_elevation#
						</cfif>
						#orig_elev_units#.
					</cfif><br />
					#coordinates#
					<cfif len(datum) gt 0>
						(#datum#)
					</cfif>
					<cfif len(coll_object_remarks) gt 0>
						<br />Remarks: #coll_object_remarks#
					</cfif>
					</div>
				</td>
				<td>
					<div style="#textStyle#">
					<!--- the page breaks will force rows to be at least 5 lines long 
					ask carla about this--->
					<br/><br/>#verbatim_date#<br/>&nbsp;
					</div>
				</td>
      		</tr>
		<!--- this tests to see if we have done the last row for the page --->
        <!---<cfif (#curRow# is #maxRowsFirstPage# and pageNum is 1) or
				(#curRow# is #maxRowsAfterPage# and pageNum is not 1)> deprecated--->
			<cfif (#curRow# is #maxRowsPerPage#)> 
                </table>
				<cfif twoPagesOnly and pageNum is 2>
					<cfbreak>
				</cfif>
				<cfif curRecord is not maxRecord >
					<cfdocumentitem type="pagebreak"></cfdocumentitem>
				</cfif>
                <cfset curRow=0>
				<cfset pageNum=#pageNum#+1>
        </cfif>
</cfloop>
</cfdocument>
<a href="/temp/report_#cfid#_#cftoken#.pdf">Get the PDF</a><br />
</cfoutput>
</cfif> <!--- end the action generatePDF --->

<!-------------------------------------------------------------->

<!--- Some div stuff I could use if tables fail.
<div style="position:absolute;
                  top:3px;
                  left:0px;
                  width:100%;
                  height:100px;"
                  align="center"
                  class="times12b">
                     <u></u>
                  </div>

            <div  style="position:absolute; top:22px; left:2px; width:100; overflow:hidden;
                    height:10px; padding-left:2px; padding-right:2px;" align="left"  class="times10">

            </div>
            <div  style="position:absolute; top:22px; left:101px; width:14px; overflow:hidden;
                    height:10px; padding-left:2px; padding-right:2px;" align="right"  class="times10">

            </div>
            <div  style="position:absolute; top:22px; left:117px; width:80; overflow:hidden;
                    height:10px; padding-left:2px; padding-right:2px;" align="right"  class="times10">
                    <cfif len(#tCollNum.other_id_number#) gt 0>

                    </cfif>
            </div>

            <div style="position:absolute; top:39px; left:2px; width:190px;
                    height:10px; padding-left:2px; padding-right:2px;" align="center"  class="times10">
                    <i></i>
            </div>
            <div style=" position:absolute; top:60px; left:2px; width:190px;
                    height:40px; padding-left:2px; padding-right:2px;" align="center"  class="times9">

            </div>
            <div  style=" position:absolute; top:110px; left:2px; width:70; overflow:hidden;
                    height:10px; padding-left:2px; padding-right:2px;" align="left"  class="times10">

            </div>
            <div  style=" position:absolute; top:110px; left:77px; width:120; overflow:hidden;
                    height:10px; padding-left:2px; padding-right:2px;" align="right"  class="times10">

            </div>
            <div style=" position:absolute; top:122px; left:2px; width:190px;
                    height:10px; padding-left:2px; padding-right:2px;" align="center"  class="times8">
                    <i></i>
            </div>
    </div>
	--->

<!-------------------------------------------------------------->

<cfif #action# is 'nothing'>
<cfset anyTextSizeModifierTypes = "
		<option value='pt'>Point</option>
		<option value='%'>%</option>
		<option value='em'>times default font size</option>
		<option value='px'>Pixels</option>
		">
<cfset possibleOrderings = "
		<option value='cat_num'>Catalog Number</option>
		<option value='scientific_name'>Scientific Name</option>
		<option value='location'>Location</option>
		<!---<option value=''></option>--->
		">
<cfset institutionCatalogs = "
		<option value='Mamm'>Mammal</option>
		<option value='Herp'>Herp</option>
		<option value='Bird'>Bird</option>
		<option value='Egg'>Egg</option>
		">
<cfset reportTypes = "
		<option value='ledger' selected='selected'>Ledger</option>
		<option value='permit'>Permit Report</option>
		">
<cfset headerTextSizes = "
		<option value='8' selected='selected'>8</option>
		<option value='9'>9</option>
		<option value='10'>10</option>
		<option value='11'>11</option>
		<option value='12'>12</option>
		<option value='14'>14</option>
		">
<cfset textFonts = "
		<option value='Times New Roman'>Times New Roman</option>
		<option value='Arial'>Arial</option>
		">
<cfset textSizes = "
		<option value='5' selected='selected'>5</option>
		<option value='6'>6</option>
		<option value='7'>7</option>
		<option value='8'>8</option>
		<option value='9'>9</option>
		<option value='10'>10</option>
		">
<cfoutput>
<cfif not isdefined('accn_number')>
	<cfset accn_number = ''>
</cfif>
<table borders='1'>
	<tr>
		<td width='25%'>
		<h3>Specify your parameters</h3>
		</td>
	</tr>
	<form action='report.cfm'>
		<input type='hidden' name='action' value='generatePDF'>
		<input type='hidden' name='collection_object_id' value='#URLDecode(collection_object_id)#'>
		<input type='hidden' name='accn_number' value='#accn_number#'>
	<tr>
		<td align='right'>
			Catalog Institution:
		</td>
		<td>
			<select name='catalog_type'>#institutionCatalogs#</input>
		</td>
	</tr>
	<tr>
		<td align='right'>
			Report type:
		</td>
		<td>
			<select 
		onchange='javascript: document.getElementById("ledgerOptions").style.display="none";
		document.getElementById("permitOptions").style.display="none";
		var temp = document.getElementById("catalog_type").value;
		document.getElementById( temp + "Options").style.display="block";'
			id='catalog_type' name='report_type'>#reportTypes#</input>
		</td>
	</tr>
	<tr>
		<td colspan='3'>
		<div id='ledgerOptions'>
		I'm the ledger options. I'm default.
		</div>
		<!--- here is where I add in the permit selection--->
		<div id='permitOptions' style='display:none;'>
			Permit Number: <input type='text' readonly='readonly' name='permitNum' size='15' id='permit_num' value=''/>
			Issued to: <input type='text' readonly='readonly' name='issuedToAgent' size='40' id='issuedToAgent' value=''/>
			Issued by: <input type='text' readonly='readonly' name='issuedByAgent' size='40' id='issuedByAgent' value=''/>
			<input type='button' name='permitValues' id='permitValues' value='Select Permit' className='picBtn'
	onmouseover="this.className='picBtn btnhov'" onmouseout="this.className='picBtn'"
   onClick="javascript: var theWin=window.open('picks/selectPermit.cfm?id=permitValues', 'SelectPermit', 
'resizable,scrollbars=yes,width=600,height=600'); "/>
		</div>
		</td>
	</tr>
	<tr>
		<td>
		<strong>All Text</strong>
		</td>
	</tr>
	<tr>
		<td align='right'>
			Text Font:
		</td>
		<td>
			<select name='text_font'>#textFonts#</select>
		</td>
	</tr>
	<tr>
		<td>
		<strong>Header</strong>
		</td>
	</tr>
	<tr>
		<td align='right'>
			Header Text size:
		</td>
		<td>
			<select name='header_text_size'>#headerTextSizes#</input>
			<!---<select name='text_size_modifier'>
				#anyTextSizeModifierTypes#
			</select>
			(I recommend using 'Point')--->Point
		</td>
	</tr>
	<tr>
		<td>
		<strong>Subtext</strong>
		</td>
	</tr>
	<tr>
		<td align='right'>
			Text size:
		</td>
		<td>
			<select name='text_size'>#textSizes#</input>
			<!---<select name='text_size_modifier'>
				#anyTextSizeModifierTypes#
			</select>
			(I recommend using 'Point')--->Point
		</td>
	</tr>
	<tr>
		<td>
		<strong>Layout</strong>
		</td>
	</tr>
	<!---<tr>
		<td align='right'>
			Number of rows on first page:
		</td>
		<td>
			<input name='first_page_rows' type='text'></input>
		</td>
	</tr>
	<tr>
		<td align='right'>
			Number of rows on subsequent pages:
		</td>
		<td>
			<input name='after_page_rows' type='text'></input>
		</td>
	</tr>
	deprecated. see note: NOTE1*--->
	<tr>
		<td align='right'>
			Top Margin:
		</td>
		<td>
			<input name='top_margin' type='text'></input>
		</td>
	</tr>
	<tr>
		<td align='right'>
			Bottom Margin:
		</td>
		<td>
			<input name='bottom_margin' type='text'></input>
		</td>
	</tr>
	<tr>
		<td align='right'>
			Left Margin:
		</td>
		<td>
			<input name='Left_margin' type='text'></input>
		</td>
	</tr>
	<tr>
		<td align='right'>
			Right Margin:
		</td>
		<td>
			<input name='Right_margin' type='text'></input>
		</td>
	</tr>
	<tr>
		<td align='right'>
			Number of rows per page:
		</td>
		<td>
			<input name='rows_per_page' type='text'></input>
		</td>
	</tr>
	<tr>
		<td align='right'>
			Order by:
		</td>
		<td>
			<select name='order_by'>#possibleOrderings#</input>
		</td>
	</tr>
	<tr>
		<td colspan='2'>
			<input name='two_pages_only' value='true' type='checkbox'>
			Check this to generate only the first two pages<br />
			(This is useful in case you want to tweak settings without
			having to download a large pdf with every change to see the effect it makes)
			</input>
		</td>
	</tr>
	<tr>
		<td>
		<input type='submit' value='Generate the PDF'>
		</td>
	</tr>
	</form>
</table>
</cfoutput>
</cfif>
<cfif len(#institution_appearance#) gt 0>
	<cf_get_footer institution="#institution_appearance#">
<cfelse>
	<cfinclude template = "includes/_footer.cfm">
</cfif>