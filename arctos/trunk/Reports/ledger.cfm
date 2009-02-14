<!---
Title: ledger.cfm
Author: Peter DeVore
Email: pdevore@berkeley.edu

Description:
	Allows users to extract information from the database by accession
	in a .pdf (Adobe Acrobat) file to be put in the ledger.
Parameters:
	action (optional):
		If unspecified or 'nothing', will go to formatting page.
		If generatePDF, additional parameters become available
		(for a list of those parameters, look at the form in
		<cfif action is 'nothing'> tag).
	collection_object_id:
		List of comma separate specimen IDs.
	accn_number:
		The accession number for the ledger.
Based on:
	loanShipLabel.cfm for its cfdocument usage
	narrowLabels.cfm and wideLabels.cfm for its queries.
--->

<cfinclude template="/includes/_header.cfm">

<cfif not isdefined("institution_appearance")>
	<cfset institution_appearance = "">
</cfif>

<cfif not isdefined("accn_number") and not isdefined("collection_object_id")>
	Need an accession number and specimens for the ledger!
	<cfabort>
</cfif>
<cfif not isdefined('action')>
	<cfset action='nothing'>
</cfif>

<cfif #action# is 'generatePDF'>
<cfquery name="ctAtt" datasource="#Application.web_user#">
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
		distinct cataloged_item.collection_object_id,
		collection_cde,
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
		accn_number printThis,
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
        orientation="landscape" 
		filename="#Application.webDirectory#/temp/ledger_#cfid#_#cftoken#.pdf" overwrite="true">

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
<cfset maxPage = (maxRecord-1) \ maxRowsPerPage + 1>
<!--- end layout defaults and settings --->
<!--- text settings and defaults --->
<!--- text defaults --->
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

		<cfset headerText = '#headerText#, Accession #data.printThis#'>

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
        <cfquery name="tCollNum" datasource="#Application.web_user#">
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
<!--- The ledger is going to be bound, so we must make sure that the binding
side margin is 1 inch. For even and odd pages, this changes: odd => top side
is 1 inch, even => bottom side is 1 inch. --->
			<cfif (pageNum mod 2) is 1>
				<tr><td>&nbsp;</td></tr>
				<tr><td>&nbsp;</td></tr>
			</cfif>
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
					<cfif len(age) gt 0 and collection_cde is "Bird">
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
					<br/><br/>#theDate#<br/><br/>&nbsp;
					</div>
				</td>
      		</tr>
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
</cfloop>
</cfdocument>
<a href="/temp/ledger_#cfid#_#cftoken#.pdf">Get the PDF</a><br />
</cfoutput>
</cfif> <!--- end the action generatePDF --->

<!-------------------------------------------------------------->

<cfif #action# is 'nothing'>
<cfoutput>
<cfset possibleOrderings = "
		<option value='cat_num'>Catalog Number</option>
		<option value='scientific_name'>Scientific Name</option>
		<option value='location'>Location</option>
		<!---<option value=''></option>--->
		">
<cfset collectionCodes = "
		<option value='Bird'>Bird</option>
		<option value='Egg'>Egg</option>
		<option value='Herp'>Herp</option>
		<option value='Mamm'>Mammal</option>
		">
<cfif not isdefined('accn_number')>
	<cfset accn_number = ''>
</cfif>
<table borders='1'>
	<tr>
		<td width='25%'>
		<h3>Specify your parameters</h3>
		</td>
	</tr>
	<form action='ledger.cfm' method='POST'>
		<input type='hidden' name='action' value='generatePDF'>
		<input type='hidden' name='collection_object_id' value='#URLDecode(collection_object_id)#'>
		<input type='hidden' name='accn_number' value='#accn_number#'>
	<tr>
		<td align='right'>
			Collection:
		</td>
		<td>
			<select name='catalog_type'>#collectionCodes#</input>
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
		<td>
		<input type='submit' value='Generate the PDF'>
		</td>
	</tr>
	</form>
</table>
</cfoutput>
</cfif>
	<cfinclude template = "/includes/_footer.cfm">