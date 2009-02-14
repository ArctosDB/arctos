<!---
Title: Reports/permit.cfm
Author: Peter DeVore
Email: pdevore@berkeley.edu

Description:
	Allows users to extract information from the database by permit
	for use in a permit report.
Parameters:
	One of either:
		permit_num
		OR
		permit_id
Based on:
	narrowLabels.cfm and wideLabels.cfm for its queries.
--->

<cfoutput>
<cfinclude template="/includes/_header.cfm">
<!---debug form--->
<!---<cfif isdefined('form')>
	<cfdump var='#form#'>
</cfif>--->
</cfoutput>

<cfif #action# is 'Generate the PDF'>
<!---<cfif not isdefined('permit_num')>
	Select a permit before generating a report!
	<cfabort>
</cfif>--->
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
<cfif isdefined('data_order_by')>
	<cfif len(data_order_by) gt 0>
		<cfif data_order_by is "location">
			<cfset data_order_by = "country, state_prov, county, island, spec_locality">
		</cfif>
		<cfset data_order_by="ORDER BY #data_order_by#">
	</cfif>
<cfelse>
	<cfset data_order_by = "">
</cfif>

<!--- 
put in unneeded select statements here
		quad,
		sea,
		feature,
		accn_num_prefix,
		accn_num,
		accn_num_suffix,

put in unneeded from statements here
		LEFT OUTER JOIN accn ON (cataloged_item.accn_id=accn.transaction_id)
		LEFT OUTER JOIN event_location ON (event_location.collecting_event_id = cataloged_item.collecting_event_id)
		

put in unneeded where statements here

--->
<!--- Ends determining how the data are ordered. --->
<cfset sql="
	select
		distinct cataloged_item.collection_object_id,
		collection_cde,
		cat_num,
		scientific_name,
		state_prov,
		country,
		county,
		island,
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
		concatotherid(cataloged_item.collection_object_id) as other_id_list,
		verbatim_date,
			
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
		LEFT OUTER JOIN coll_object_remark ON (coll_object_remark.collection_object_id = cataloged_item.collection_object_id)
	WHERE
		accepted_id_fg=1 AND
		cataloged_item.collection_object_id IN (#collection_object_id#)
	#data_order_by#
">
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(sql)#
</cfquery>

<!----------------------------------------------------------------->
<!--- Create annotation Array --->
<cfset i=1>
<cfset annotations = ArrayNew(1)>
<cfloop condition='isdefined("annotationText#i#")'>
	<cfset annotations[i] = StructNew()>
	<cfset annotations[i].text = Form["annotationText" & i]>
	<cfset annotations[i].scope = Form["annotationScope" & i]>
	<cfset i=i+1>
</cfloop>
<cffunction name='withinScope' returntype="boolean">
	<cfargument name='catalogNum'>
	<cfargument name="scope">
	<!--- if the scope is blank or 'all' its in the scope--->
	<cfif len(scope) is 0 or scope is 'all'>
		<cfreturn true>
	</cfif>
	<!--- now we separate by commas and loop over each element --->
	<cfloop list="#scope#" index="scopeItem">
		<cfif scopeItem contains "-">
			<cfset hyphenPos = find("-","#scopeItem#")>
			<cfset lowerVal = Left(scopeItem,hyphenPos-1)>
			<cfset higherVal = Right(scopeItem,len(scopeItem)-hyphenPos)>
			<cfif catalogNum gte lowerVal and catalogNum lte higherVal>
				<cfreturn true>
			</cfif>
		<cfelse>
			<cfif scopeItem is catalogNum>
				<cfreturn true>
			</cfif>
		</cfif>
	</cfloop>
	<!--- the scope is not all, and the list of items does not contain the
	catalogNum, either in a range of numbers or as the number itself--->
	<cfreturn false>
</cffunction>
<!----------------------------------------------------------------->
<cfoutput>
<!--- filling in values for modularity 
these are so that we can have default values below if we ever add back in
the option to choose these parameters.  in that case, remove these lines--->
<cfset top_margin="">
<cfset bottom_margin="">
<cfset left_margin="">
<cfset right_margin="">
<cfset rows_per_page="">
<cfset header_text_size="">
<cfset text_font="">
<cfset text_size="">
<!--- end filling in values for modularity --->
<cfdocument
        format="pdf"
        pagetype="letter"
		fontembed='yes'
        margintop=".35"
        marginbottom="0"
        marginleft=".25"
        marginright=".25"
		unit="in"
        orientation="landscape" filename="#Application.webDirectory#/temp/permit_#cfid#_#cftoken#.pdf" overwrite="true">

<!---<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">--->

<!--- major variables for format and layout --->

<cfset pageNum = 1>
<cfset curRow = 0>
<cfset curRecord = 0>
<cfset maxRecord = data.recordcount>
<cfloop query="data">
	<cfif not isdefined('$#collection_object_id#$')>
		<cfset maxRecord = maxRecord - 1>
	</cfif>
</cfloop>
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
<cfset maxPage = (maxRecord-1) \ maxRowsPerPage + 1>
<!--- end layout defaults and settings --->
<!--- text settings and defaults --->
<!--- text defaults --->
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

<cfset headerTextSize = '8'>
<cfset headerTextSizeModifier = 'pt'>
<cfset headerTextFont = 'Times New Roman'>
<cfset textSize = '5'>
<cfset textSizeModifier = 'pt'>
<cfset textFont = 'Times New Roman'>
<!---
<cfset defaultHeaderTextSize = '8'>
<cfset defaultHeaderTextSizeModifier = 'pt'>
<cfset defaultHeaderTextFont = 'Times New Roman'>
<cfset defaultTextSize = '5'>
<cfset defaultTextSizeModifier = 'pt'>
<cfset defaultTextFont = 'Times New Roman'>--->
<!--- text settings --->
<!---<cfif len(header_text_size) eq 0>
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
</cfif>--->


<cfset headerTextStyle = "font-family: '#headerTextFont#',
		sans-serif; font-weight:600; font-size: #headerTextSize##headerTextSizeModifier#">
<cfset textStyle = "font-family: '#textFont#',
		sans-serif; font-size: #textSize##textSizeModifier#">
<!--- end text settings and defaults --->
<!--- end major variables for format and layout --->

 <cfloop query="data">
	<!--- here will we skip the entry completely if we don't find $#collection_object_id#$ defined --->
	<cftry><cfif not isdefined('$#collection_object_id#$')>
		<cfthrow type='continue'>
	</cfif>
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
                        <cfset spacePos = find(";",collectors)>
                        <cfset thisColl = left(collectors,#spacePos# - 1)>
                        <cfset secondColl = right(collectors, len(collectors) - spacesPos)>
                <cfelse>
                        <cfset thisColl = #collectors#>
                </cfif>
                <cfset thisDate = "">
                <cftry>
                        <cfset thisDate = #dateformat(verbatim_date,"dd mmm yyyy")#>
                        <cfcatch>
                                <cfset thisDate = #verbatim_date#>
                        </cfcatch>
                </cftry>
				<!---<cfset theDate = replace(verbatim_date," ","<br/>","all")>--->
				<cfset theDate = verbatim_date>
				
		<!--- Here is the annotation portion --->
		<cfset annotationDefault = "Note:">
		<cfset annotation = annotationDefault>
		<!--- Go through all find/replace items, adding to annotation as necessary. --->
		<cfloop index="index" from='1' to='#ArrayLen(annotations)#'>
			<cfif withinScope(cat_num, annotations[index].scope) and len(annotations[index].text) gt 0>
				<cfset annotation="#annotation# #annotations[index].text#">
			</cfif>
		</cfloop>		
		<!--- End data manipulation --->
<!--- Please note that you must wrap the plain text itself with the div
in order for cfdocument to apply the style characteristics.  You CANNOT
just put it around the entire table, or an entire row.  If you do so,
cfdocument will not use it, since it does not consider it valid HTML. Period.
--Peter DeVore
--->
		<cfset curRow = #curRow# + 1>
		<cfset curRecord = #curRecord# + 1>
        <cfif #curRow# is 1>
            <table cellpadding="0" cellspacing="0" border='0' rules='rows'>
				<colgroup colspan='4'>
					<col width='250' />
					<col width='250' />
					<col width='370' />
					<col width='130' />
				</colgroup>
			<tr><td colspan='4'><hr></td></tr>
				<!--- The header!!! --->
			<tr>
				<td colspan='3'>
					<div style="#headerTextStyle#">
					#headerText#
					</div>
				</td>
				<td colspan='1'>
					<div style="#headerTextStyle#">
					Page #pageNum# of #maxPage#
					</div>
				</td>
			</tr>
			<tr><td colspan='4'><hr></td></tr>
        </cfif>
			<tr>
				<td>
					<div style="#textStyle#">
					<strong>#cat_num#</strong><br />
					<strong>Parts:</strong> #parts#<br />
					<strong>Sex:</strong>
					<!--- If I can figure out a way to use
					the sex symbol, then use #sexcde#---> #sex#
					<cfif collection_cde is "Bird" and isdefined("age") and len(age) gt 0>
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
					<br/><br/>#theDate#<br/>&nbsp;
					</div>
				</td>
      		</tr>
			<tr><td colspan='4'><div style="#textStyle#">
			<cfif annotation is not annotationDefault>
				#annotation#
			<cfelse>
				&nbsp;
			</cfif>
			</div></td></tr>
			<tr><td colspan='4'><hr></td></tr>
		<!--- this tests to see if we have done the last row for the page --->
			<cfif (#curRow# is #maxRowsPerPage#)> 
                </table>
				<cfif twoPagesOnly and pageNum is 2>
					<cfbreak>
				</cfif>
				<cfif curRecord is not maxRecord>
					<cfdocumentitem type="pagebreak"></cfdocumentitem>
				</cfif>
                <cfset curRow=0>
				<cfset pageNum=#pageNum#+1>
        </cfif>
<cfcatch type="continue"><!--- ignore ---></cfcatch>
</cftry>
</cfloop>
</cfdocument>
<a href="/temp/permit_#cfid#_#cftoken#.pdf">Get the PDF</a><br />
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
<cfif not isdefined("checkedDarkColor")>
	<cfset darkCheckedElementBGColor = "##CCCCEE">
<cfelse>
	<cfset darkCheckedElementBGColor = "#checkedDarkColor#">
</cfif>
<cfif not isdefined("checkedLightColor")>
	<cfset lightCheckedElementBGColor = "##DDDDFF">
<cfelse>
	<cfset lightCheckedElementBGColor = "#checkedLightColor#">
</cfif>
<cfif not isdefined("uncheckedDarkColor")>
	<cfset darkUncheckedElementBGColor = "##CCCCCC">
<cfelse>
	<cfset darkUncheckedElementBGColor = "#uncheckedDarkColor#">
</cfif>
<cfif not isdefined("uncheckedLightColor")>
	<cfset lightUncheckedElementBGColor = "##E0E0E0">
<cfelse>
	<cfset lightUncheckedElementBGColor = "#uncheckedLightColor#">
</cfif>
<cfset specimensTableStyle = 'border: 1px solid black; padding: 0.3em;'>
<cfset darkCheckedElementStyle = '#specimensTableStyle# background-color: #darkCheckedElementBGColor#;'>
<cfset lightCheckedElementStyle = '#specimensTableStyle# background-color: #lightCheckedElementBGColor#;'>
<cfset darkUncheckedElementStyle = '#specimensTableStyle# background-color: #darkUncheckedElementBGColor#;'>
<cfset lightUncheckedElementStyle = '#specimensTableStyle# background-color: #lightUncheckedElementBGColor#;'>
<cfset tableStyle = 'padding: 3px;'>
<!---lets do js functions! woo --->
<script type='text/javascript'>
<!--- cool javascript functions to help with parts --->
function selectAll(name, value) {
	var testLocations = document.getElementsByName(name+'_value');
	for (var i = 0; i < testLocations.length; i++) {
		var mySpan = testLocations[i];
		var text = mySpan.childNodes[0];
		if (testLocations[i].childNodes[0].nodeValue == value) {
			var tr = testLocations[i].parentNode.parentNode;
			var td = tr.cells[0];
			for (var e = td.childNodes[0]; e != null; e = e.nextSibling) {
				if (e.type && e.type == 'checkbox') {
					e.checked = true;
					setSelectedColor(tr);
				}
			}
		}
	}
}
function deselectAll(name, value) {
	var testLocations = document.getElementsByName(name+'_value');
	for (var i = 0; i < testLocations.length; i++) {
		var mySpan = testLocations[i];
		var text = mySpan.childNodes[0];
		if (testLocations[i].childNodes[0].nodeValue == value) {
			var tr = testLocations[i].parentNode.parentNode;
			var td = tr.cells[0];
			for (var e = td.childNodes[0]; e != null; e = e.nextSibling) {
				if (e.type && e.type == 'checkbox') {
					e.checked = false;
					setDeselectedColor(tr);
				}
			}
		}
	}
}
function setSelectedColor(row) {
	if (row.rowIndex % 2 == 0) {
		row.style.backgroundColor = <cfoutput>"#darkCheckedElementBGColor#"</cfoutput>;
	} else {
		row.style.backgroundColor = <cfoutput>"#lightCheckedElementBGColor#"</cfoutput>;
	}
}
function setDeselectedColor(row) {
	if (row.rowIndex % 2 == 0) {
		row.style.backgroundColor = <cfoutput>"#darkUncheckedElementBGColor#"</cfoutput>;
	} else {
		row.style.backgroundColor = <cfoutput>"#lightUncheckedElementBGColor#"</cfoutput>;
	}
}
function toggleColor(checkbox) {
	if (checkbox.checked) {
		setSelectedColor(checkbox.parentNode.parentNode);
	} else {
		setDeselectedColor(checkbox.parentNode.parentNode);
	}
}

<!--- end cool javascript functions to help with specimen selection and color change --->
<!--- js functions for annotations --->
function removeAnnotation() {
	var that = this.parentNode.parentNode;
	var num = that.id.substr(7);
	var theNextRow = that.nextSibling;
	that.parentNode.removeChild(that);
	reIndexAnnotation(theNextRow, num);
}
function reIndexAnnotation(theRow, num) {
	while (theRow.id != 'endOfAnnotation') {
		//Go through all of the children, changing the numbers
		for (var td = theRow.firstChild; td != null; td = td.nextSibling) {
			for (var e = td.firstChild; e != null; e = e.nextSibling) {
				if (e.name.indexOf("AnnotationText") == 0) {
					//Then this is the find element.
					e.name = "AnnotationText" + num;
				}
				if (e.name.indexOf("AnnotationScope") == 0) {
					//Then this is the scope element.
					e.name = "AnnotationScope" + num;
				}
			}
		}
		theRow.id = 'Annotation' + num;
		num++;
		theRow = theRow.nextSibling;
	}
}
function addNewAnnotation() {
	var endRow = document.getElementById("endOfAnnotation");
	var prevRow = endRow.previousSibling;
	var curNum = 1;
	if (prevRow.id && prevRow.id.indexOf("Annotation") == 0) {
		//The the previous row is a Annotation entry, so we add a new one,
		//incrementing the number.
		var previousNum = prevRow.id.substr("Annotation".length);
		var curNum = 1 + Number(previousNum);
	}
	var newAnnotationRow = document.createElement("tr");
	newAnnotationRow.id = "Annotation" + curNum;
	
	var annotationTextTD = document.createElement("TD");
	var annotationTextInput = document.createElement("INPUT");
	annotationTextInput.type = 'text';
	annotationTextInput.name = 'AnnotationText' + curNum;
	annotationTextInput.size = 50;
	annotationTextTD.appendChild(annotationTextInput);

	var scopeTD = document.createElement("TD");
	var scopeInput = document.createElement("INPUT");
	scopeInput.type = 'text';
	scopeInput.name = 'AnnotationScope' + curNum;
	scopeInput.size = 60;
	scopeTD.appendChild(scopeInput);
	
	var removeTD = document.createElement("TD");
	var removeInput = document.createElement("INPUT");
	removeInput.type = 'button';
	removeInput.value = 'Remove this Annotation';
	//the following won't quite work...
	removeInput.onclick = removeAnnotation;
	if (removeInput.captureEvents) {
		removeInput.captureEvents(Event.CLICK);
	}
	removeTD.appendChild(removeInput);
	
	newAnnotationRow.appendChild(annotationTextTD);
	newAnnotationRow.appendChild(scopeTD);
	newAnnotationRow.appendChild(removeTD);
	endRow.parentNode.insertBefore(newAnnotationRow,endRow);
}
</script>
<cfoutput>
<cfif not isdefined("permit_id") and not isdefined('permit_num')>
	Need a permit to generate a report!
	<cfabort>
</cfif>
<!--- let's guarantee that permit_id is defined...
However, this may be bad if multiple permits have the same permit number
because the different specimens may be from different permits, so how do we know
which permit we want a report from? that's why I want this page reached by permit,
not by specimens. --->
<cfif not isdefined("permit_id") and isdefined("permit_num")>
<!--- validate permit_num --->
	<cfif findnocase('''',permit_num) gt 0 or findnocase('"',permit_num) gt 0 or
			findnocase(';',permit_num) gt 0>
		Invalid permit_num<cfabort>
	</cfif>
	<cfset sql="
		select permit_num, permit_id
		from permit
		where permit_num = '#permit_num#'">
	<cfquery name="getPermitID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<!--- debug code
	<cfif isdefined("variables.permit_id")>
		<cfoutput>variables.permit_id is defined before definition (not expected)! it is: #variables.permit_id#<br/></cfoutput>
	</cfif>
	<cfif isdefined("getPermitID.permit_id")>
		<cfoutput>getPermitID.permit_id is defined before definition (expected)! it is: #getPermitID.permit_id#<br/></cfoutput>
	</cfif>
	<cfif isdefined("permit_id")>
		<cfoutput>permit_id is defined before definition! it is: #permit_id#<br/></cfoutput>
	</cfif> --->
	<cfset Variables.permit_id = getPermitID.permit_id>
</cfif>
<cfset possibleOrderings = "
		<option value='cat_num'>Catalog Number</option>
		<option value='scientific_name'>Scientific Name</option>
		<option value='location'>Location</option>
		<!---<option value=''></option>--->
		">
<!--- area to decide which of the specimens go into the permit report. --->
<!--- validate order, permit_id --->
<cfset defaultOrder = "collection_cde, cat_num">
<cfif not isdefined('order')>
	<cfset order=defaultOrder>
</cfif>
<cfif findnocase(";",order) gt 0>
	Invalid ordering<cfabort>
</cfif>
<!--- Check to see if it is a date. If it is a date, then 
make the order by part correct, as in year, then month, then day,
and on day add a 0 to the front if it is one digit only--->
<cfif find("date",order) is not 0>
	<!---first extract asc or desc from it--->
	<cfif find("asc",order) is not 0>
		<cfset ascDesc = right(order,len("asc"))>
		<cfset order = left(order,len(order)-len("asc"))>
	</cfif>
		
	<cfif find("desc",order) is not 0>
		<cfset ascDesc = right(order,len("desc"))>
		<cfset order = left(order,len(order)-len("desc"))>
	</cfif>
	
	<!--- now remove any trailing spaces --->
	<cfset order = Trim(order)>
	<!--- now order by year, then month, then date --->
	<cfset order = "to_date(#order#,'dd-mon-yy')  #ascDesc#">
	
</cfif>
<!--- end date handling--->
<cfif not isnumeric(permit_id)>
	Permit_id must be numeric.<cfabort>
</cfif>
<!--- build query --->
<cfset sql="select
				cat_num,
				cataloged_item.collection_object_id,
				identification.scientific_name,
				permit.permit_id,
				permit_trans.transaction_id,
				cataloged_item.accn_id,
				accepted_id_fg,
				collection_cde,
				state_prov,
				country,
				county,
				island,
				verbatim_date
			from
				cataloged_item
				INNER JOIN collecting_event ON (cataloged_item.collecting_event_id = collecting_event.collecting_event_id)
				INNER JOIN locality ON (collecting_event.locality_id = locality.locality_id)
				INNER JOIN geog_auth_rec ON (locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id)
				LEFT OUTER JOIN identification ON (cataloged_item.collection_object_id = identification.collection_object_id)
				LEFT OUTER JOIN accn on (cataloged_item.accn_id = accn.transaction_id)
				LEFT OUTER JOIN permit_trans on (permit_trans.transaction_id=accn.transaction_id)
				LEFT OUTER JOIN permit on (permit.permit_id = permit_trans.permit_id)
			where
				permit.permit_id=#permit_id# AND
				accepted_id_fg=1
			order by
				#order#">
<cfquery name="specimens" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(sql)#
</cfquery>
<cfset collection_object_id="">
<cfif specimens.recordCount is 0>
	There are no specimens associated with this permit.
	<cfabort>
</cfif>
<cfloop query="specimens">
	<cfset Variables.collection_object_id="#Variables.collection_object_id#,#specimens.collection_object_id#">
</cfloop>
<cfset collection_object_id=right(collection_object_id,len(collection_object_id)-1)>
	
<form action='permit.cfm' name='myForm' method='POST'>
	<input type='hidden' name='collection_object_id' value='#URLDecode(collection_object_id)#'>
	<input type='hidden' name='order' value='#order#'>
	<input type='hidden' name='permit_id' value='#permit_id#'>
<table borders='1'>
	<tr>
		<td width='25%'>
		<h3>Specify your parameters</h3>
		</td>
	</tr>
		
<!---	<tr>
		<td align='right'>
			Catalog Institution:
		</td>
		<td>
			<select name='catalog_type'>#institutionCatalogs#</input>
		</td>
	</tr>--->
	<tr>
		<td colspan='3'>
		<cfset sql="
			select 
				issuedBy.agent_name as IssuedByAgent,
				issuedTo.agent_name as IssuedToAgent,
				permit_num,
				permit_id
			from 
				permit, preferred_agent_name issuedTo, preferred_agent_name issuedBy 
			where 
				permit_id = '#permit_id#' AND 
				permit.issued_by_agent_id = issuedBy.agent_id AND
				permit.issued_to_agent_id = issuedTo.agent_id">
		<cfquery name="permit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(sql)#
		</cfquery>
		<!--- here is where I add in the permit selection--->
		<cfloop query='permit'>
		<div id='permitOptions'>
			Permit Number: <input type='text' readonly='readonly' name='permitNum' size='25' id='permit_num' value='#permit_num#'/>
			Issued to: <input type='text' readonly='readonly' name='issuedToAgent' size='40' id='issuedToAgent' value='#IssuedToAgent#'/>
			Issued by: <input type='text' readonly='readonly' name='issuedByAgent' size='40' id='issuedByAgent' value='#IssuedByAgent#'/>
			<!---<input type='button' name='permitValues' id='permitValues' value='Select Permit' className='picBtn'
	onmouseover="this.className='picBtn btnhov'" onmouseout="this.className='picBtn'"
   onClick="javascript: var theWin=window.open('../picks/selectPermit.cfm?id=permitValues', 'SelectPermit', 
'resizable,scrollbars=yes,width=600,height=600'); "/>--->
		</div>
		</cfloop>
		</td>
	</tr>
	<tr>
		<td align='right'>
			Order by:
		</td>
		<td>
			<select name='data_order_by'>#possibleOrderings#</input>
		</td>
	</tr>
	<tr>
		<td>
		<input type='submit' name='action' value='Generate the PDF'>
		</td>
	</tr>
	</table>
	<strong>Annotations</strong>
<table style='#tableStyle#'>
	<tr>
		<td>Annotation Text:</td><td>Catalog number(s) (comma separated, ranges using "-") or blank for all entries</td>
	</tr>
	<cfset i = 1>
	<cfloop condition='isdefined("annotationText#i#")'>
		<tr id='Annotation#i#'>
			<td><input type='text' size='50' name='AnnotationText#i#' value='#Form["annotationText" & i]#'/></td>
			<td><input type='text' size='60' name='AnnotationScope#i#' value='#Form["annotationScope" & i]#'/></td>
			<td><input type='button' value='Remove this Annotation' onclick='removeAnnotation();'/></td>
		</tr>
		<cfset i=i+1>
	</cfloop>
	<tr id='endOfAnnotation'>
		<td><input type='button' className='picBtn' 
	<!---onmouseover="this.className='picBtn btnhov'" onmouseout="this.className='picBtn'"--->
	onclick='javascript: addNewAnnotation();' value='Add new annotation'/></td>
	</tr>
</table>
	<!--- next cool idea.
	People should be able to select all the specimens that they want that satisfy
	specific criteria. I'll implement this in the following way: every TD element
	will have two buttons: a circle and an X for simplicity (can be changed later).
	If the user clicks the circle, then all specimens that satisfy that criteria
	will be checked. If the user clicks the X, then all specimens that satisfy that
	criteria will be deselected. Example. You click scientific name "blargh". Then all
	specimens that have sciname "blargh" get deselected, and nothing else is changed.
	--->
	<strong>Specimen List</strong><br/>
	Unchecked light color:<input type='text' name='uncheckedLightColor' value='#lightUncheckedElementBGColor#'/>
	Unchecked dark color:<input type='text' name='uncheckedDarkColor' value='#darkUncheckedElementBGColor#'/>
	Checked light color:<input type='text' name='checkedLightColor' value='#lightCheckedElementBGColor#'/>
	Checked dark color:<input type='text' name='checkedDarkColor' value='#darkCheckedElementBGColor#'/>
	<br/><table>
			<td><input type='submit' value='Change color'></td>
		<tr id='specimenHeaderRow'>
			<td><strong>Catalog Number</strong>
			<br>
			<cfset thisTerm = "collection_cde,cat_num">
			<cfset thisName = #replace(thisTerm,",","_","all")#>
			<a href="javascript: void"
				onClick="myForm.order.value='#thisTerm#'.replace(/,/g, ' asc,').concat(' asc');myForm.submit();"
				onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
				onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
				<img src="/images/up.gif" border="0" name="#thisName#up"></a>
			<a href="javascript: void"
				onClick="myForm.order.value='#thisTerm#'.replace(/,/g, ' desc,').concat(' desc');myForm.submit();"
				onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
				onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
				<img src="/images/down.gif" border="0" name="#thisName#dn"></a></td>
			<td><strong>Scientific Name</strong>
			<br>
			<cfset thisTerm = "scientific_name">
			<cfset thisName = #replace(thisTerm,",","_","all")#>
			<a href="javascript: void"
				onClick="myForm.order.value='#thisTerm#'.replace(/,/g, ' asc,').concat(' asc');myForm.submit();"
				onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
				onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
				<img src="/images/up.gif" border="0" name="#thisName#up"></a>
			<a href="javascript: void"
				onClick="myForm.order.value='#thisTerm#'.replace(/,/g, ' desc,').concat(' desc');myForm.submit();"
				onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
				onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
				<img src="/images/down.gif" border="0" name="#thisName#dn"></a></td>
			<td><strong>Higher Geography</strong>
			<br>
			<cfset thisTerm = "country,state_prov,county,island">
			<cfset thisName = #replace(thisTerm,",","_","all")#>
			<a href="javascript: void"
				onClick="myForm.order.value='#thisTerm#'.replace(/,/g, ' asc,').concat(' asc');myForm.submit();"
				onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
				onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
				<img src="/images/up.gif" border="0" name="#thisName#up"></a>
			<a href="javascript: void"
				onClick="myForm.order.value='#thisTerm#'.replace(/,/g, ' desc,').concat(' desc');myForm.submit();"
				onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
				onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
				<img src="/images/down.gif" border="0" name="#thisName#dn"></a></td>
			<td><strong>Date</strong>
			<br>
			<cfset thisTerm = "verbatim_date">
			<cfset thisName = #replace(thisTerm,",","_","all")#>
			<a href="javascript: void"
				onClick="myForm.order.value='#thisTerm#'.replace(/,/g, ' asc,').concat(' asc');myForm.submit();"
				onMouseOver="self.status='Sort Ascending.';#thisName#up.src='/images/up_mo.gif';return true;"
				onmouseout="self.status='';#thisName#up.src='/images/up.gif';return true;">
				<img src="/images/up.gif" border="0" name="#thisName#up"></a>
			<a href="javascript: void"
				onClick="myForm.order.value='#thisTerm#'.replace(/,/g, ' desc,').concat(' desc');myForm.submit();"
				onMouseOver="self.status='Sort Descending.';#thisName#dn.src='/images/down_mo.gif';return true;"
				onmouseout="self.status='';#thisName#dn.src='/images/down.gif';return true;">
				<img src="/images/down.gif" border="0" name="#thisName#dn"></a></td>
		</tr>
	<cfset dark=true>
	<cfloop query='specimens'>
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
		<!--- 
		If the action is reorder, we want to preserve boxes already clicked from
		earlier. Thus:
		if action is reorder
			if collobjid is defined
				checked
			else
				unchecked
		else
			checked
		--->
		<tr
		<cfif order is defaultOrder or isdefined('$#collection_object_id#$')>
			<cfif dark>
				style='#darkCheckedElementStyle#'
				<cfset dark=false>
			<cfelse>
				style='#lightCheckedElementStyle#'
				<cfset dark=true>
			</cfif>
		<cfelse>
			<cfif dark>
				style='#darkUncheckedElementStyle#'
				<cfset dark=false>
			<cfelse>
				style='#lightUncheckedElementStyle#'
				<cfset dark=true>
			</cfif>
		</cfif>
			>
			<td name='cat_num'>
			<a href='../SpecimenDetail.cfm?collection_object_id=#collection_object_id#' target='Edit Specimen'>
				#collection_cde# #cat_num#</a>
			<input type='checkbox' 
			<cfif order is defaultOrder or isdefined('$#collection_object_id#$')>
					checked='checked'
			</cfif>
					name='$#collection_object_id#$'
					onclick='javascript:toggleColor(this);'/>
			</td>
			<td name='scientific_name'><span name='scientific_name_value'>#scientific_name#</span>
				<a href="javascript: void(0)" 
				onclick="selectAll('scientific_name','#scientific_name#');">O</a>
				<a href="javascript: void(0)" 
				onclick="deselectAll('scientific_name','#scientific_name#');">X</a></td>
			<td name='highergeog'><span name='highergeog_value'>#highergeog#</span>
				<a href="javascript: void(0)" 
				onclick="selectAll('highergeog','#highergeog#');">O</a>
				<a href="javascript: void(0)" 
				onclick="deselectAll('highergeog','#highergeog#');">X</a></td>
			<td name='verbatim_date'><span name='verbatim_date_value'>#verbatim_date#</span>
				<a href="javascript: void(0)" 
				onclick="selectAll('verbatim_date','#verbatim_date#');">O</a>
				<a href="javascript: void(0)" 
				onclick="deselectAll('verbatim_date','#verbatim_date#');">X</a></td>
		</tr>
	</cfloop>
	<tr id='endOfSpecimens'/>	
</table>
</form>
</cfoutput>
</cfif>
<cfinclude template = "/includes/_footer.cfm">