<cfinclude template='includes/_header.cfm'>

<cfif not isdefined("collection_object_id")>
	Need specimens to make labels!
	<cfabort>
</cfif>
<cfif not isdefined('action')>
	<cfset action='nothing'>
	Action was not defined! That's the whole problem.
</cfif>

<cffunction name='replaceNonVarNameChars' returntype="string">
	<cfargument name="varName" type="String" required="true">
	<cfset varName=REReplace('#varName#',"[^A-Za-z0-9_$]","_","all")>
	<cfreturn varName>
</cffunction>

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
following SQL query. --->
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


<!------>

<cfset sql="
	select
		cataloged_item.collection_object_id,
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
		accn_num_prefix,
		accn_num,
		accn_num_suffix
		,getLabelName(cataloged_item.collection_object_id) as labels_agent_name	

		#seleAttributes#
	FROM
		cataloged_item
		INNER JOIN identification ON (cataloged_item.collection_object_id = identification.collection_object_id)
		INNER JOIN collecting_event ON (cataloged_item.collecting_event_id = collecting_event.collecting_event_id)
		INNER JOIN locality ON (collecting_event.locality_id = locality.locality_id)
		INNER JOIN geog_auth_rec ON (locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id)
		LEFT OUTER JOIN accepted_lat_long ON (locality.locality_id = accepted_lat_long.locality_id)
		LEFT OUTER JOIN accn ON (cataloged_item.accn_id=accn.transaction_id)
	WHERE
		accepted_id_fg=1 AND cataloged_item.collection_object_id IN (#collection_object_id#)
	ORDER BY
		cat_num
">
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(sql)#
</cfquery>
<!------------------------------->
<!--- Create geography modification Array --->
<cfset i=1>
<cfset geogMods = ArrayNew(1)>
<cfloop condition='isdefined("geogModFind#i#")'>
	<cfset geogMods[i] = StructNew()>
	<cfset geogMods[i].find = Form["geogModFind" & i]>
	<cfset geogMods[i].replace = Form["geogModReplace" & i]>
	<cfset geogMods[i].scope = Form["geogModScope" & i]>
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

<cfset headerClass="times14">
<cfset textClass="times12">
<cfset divWidth=180>
<cfset divHeight=140>
<cfset titleTop=3>
<cfset titleLeft=0>
<cfset titleWidth=175>
<cfset titleHeight=20>
<cfset catnumTop=22>
<cfset catnumLeft=2>
<cfset catnumWidth=100>
<cfset catnumHeight=10>
<cfset catnumPaddingLeft=2>
<cfset catnumPaddingRight=2>
<cfset sexTop=22>
<cfset sexLeft=78>
<cfset sexWidth=14>
<cfset sexHeight=10>
<cfset sexPaddingLeft=2>
<cfset sexPaddingRight=2>
<cfset oinTop=22>
<cfset oinRight=0>
<cfset oinWidth=80>
<cfset oinHeight=10>
<cfset oinPaddingLeft=2>
<cfset oinPaddingRight=2>
<cfset scigeogTop=36>
<cfset scigeogLeft=0>
<cfset scigeogWidth=180>
<cfset scigeogHeight=35>
<cfset sciPadding=0>
<cfset dateCollTop=99>
<cfset dateLeft=1>
<cfset dateWidth=70>
<cfset dateHeight=10>
<cfset datePaddingLeft=2>
<cfset datePaddingRight=2>
<cfset collRight=0>
<cfset collWidth=120>
<cfset collHeight=14>
<cfset collPaddingLeft=2>
<cfset collPaddingRight=2>
<cfset partsBottom=0>
<cfset partsLeft=-1>
<cfset partsWidth=180>
<cfset partsHeight=10>
<cfset partsPaddingLeft=0>
<cfset partsPaddingRight=0>

<cffunction name='label' returntype = "String">
	<cfargument name='borderstyle' required = true>
	<cfargument name='cat_num' required = true>
	<cfargument name='sexcde' required = true>
	<cfargument name='oin' required = true>
	<cfargument name='Scientific_Name' required = true>
	<cfargument name='geog' required = true>
	<cfargument name='verbatim_date' required = true>
	<cfargument name='thisColl' required = true>
	<cfargument name='stripParts' required = true>
	<cfset thestring='
		<td style="padding:0px; #borderstyle#">
			<div style="position:relative;
					width:#divWidth#px;
					height:#divHeight#px;"
					align="center">
				<div style="position:absolute;
						top:#titleTop#px;
						left:#titleLeft#px;
						width:#titleWidth#px;
						height:#titleHeight#px;"
						align="center"
						class="#headerClass#">
					<u>University of California</u></div>
				<div style="position:absolute; top:#catnumTop#px; left:#catnumLeft#px; width:#catnumWidth#; overflow:visible;
						height:#catnumHeight#px; padding-left:#catnumPaddingLeft#px; padding-right:#catnumPaddingRight#px;" align="left"  class="#textClass#">
					MVZ #cat_num#
				</div>
				<div style="position:absolute; top:#sexTop#px; left:#sexLeft#px; width:#sexWidth#px; overflow:visible;
						height:#sexHeight#px; padding-left:#sexPaddingLeft#px; padding-right:#sexPaddingRight#px;" align="right"  class="#textClass#">
					#sexcde#
				</div>
				<div style="position:absolute; top:#oinTop#px; right:#oinRight#px; width:#oinWidth#; overflow:visible;
						height:#oinHeight#px; padding-left:#oinPaddingLeft#px; padding-right:#oinPaddingRight#px;" align="right"  class="#textClass#">
					#oin#
				</div>
				<div style="position:absolute; top:#scigeogTop#px; left:#scigeogLeft#px; width:#scigeogWidth#px;
						height:#scigeogHeight#px;">
					<table>
						<tr><td><div style="padding:#sciPadding#px" align="center" class="#textClass#"><i>#Scientific_Name#</i></div></td></tr>
						<tr><td><div align="left" class="#textClass#">#geog#</div></td></tr></table>
				</div>
				<div style="position:absolute; top:#dateCollTop#px; left:#dateLeft#px; width:#dateWidth#;
						height:#dateHeight#px; padding-left:#datePaddingLeft#px; padding-right:#datePaddingRight#px;" align="left"  class="#textClass#">
					#verbatim_date#</div>
				<div style="position:absolute; top:#dateCollTop#px; right:#collRight#px; width:#collWidth#; overflow:hidden;
						height:#collHeight#px; padding-left:#collPaddingLeft#px; padding-right:#collPaddingRight#px;" align="right"  class="#textClass#">
					#thisColl#
				</div>
				<div style="position:absolute; bottom:#partsBottom#px; left:#partsLeft#px; width:#partsWidth#px;
						height:#partsHeight#px; padding-left:#partsPaddingLeft#px; padding-right:#partsPaddingRight#px;" align="center"  class="#textClass#">
					<i>#stripParts#</i>
				</div>
		</div>
		</td>'>
	<cfreturn thestring>
</cffunction>
	
	
<cfoutput>
<!---

--->
<!--- Please note that when making a pdf, changing the left/right margins will scale
the WHOLE document.  Thus, fix the left and right margins, then change the top
and bottom ones to make it fit.
To you programmers, that means DON'T TOUCH THE MARGINS!!!--->
<cfdocument
        format="pdf"
        pagetype="letter"
        margintop=".2"
        marginbottom=".2"
        marginleft=".754"
        marginright=".754"  overwrite="true"
        filename="#Application.webDirectory#/temp/narrowlabels_#cfid#_#cftoken#.pdf" orientation="portrait" >

<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">
<cfset i=0>
<cfset t=0>
<cfset numRows = 7>
<cfset numCols = 4>
<cfset pageNum = 1><!--- position from top --->
<cfset bug="">
<cfset thisRow = 1>
<cfset r=1>
<cfset rc = data.recordcount>

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
        <cfset coordinates = "">
        <cfif len(#verbatimLatitude#) gt 0 AND len(#verbatimLongitude#) gt 0>
                <cfset coordinates = "#verbatimLatitude# / #verbatimLongitude#">
                <cfset coordinates = replace(coordinates,"d","&##176;","all")>
                <cfset coordinates = replace(coordinates,"m","'","all")>
                <cfset coordinates = replace(coordinates,"s","''","all")>
        </cfif>
		<!--- see parameters page below for new way of doing customized geography --->
		<cfif isdefined('useCustGeog$#collection_object_id#')>
			<cfset temp='geogText$#collection_object_id#'>
			<cfset geog=#temp#>
		<cfelse>
        	<cfset geog = "#spec_locality#">
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
			<cfset geog=replace(geog,": , ",": ","all")>
		</cfif>
		<!--- Go through all find/replace items, modify geog as necessary. --->
		<cfloop index="index" from='1' to='#ArrayLen(geogMods)#'>
			<cfif withinScope(cat_num, geogMods[index].scope) and len(geogMods[index].find) gt 0>
				<cfset geog=replace(geog,geogMods[index].find,geogMods[index].replace,'all')>
			</cfif>
		</cfloop>
		
		<cfif len(#tCollNum.other_id_number#) gt 0>
			<cfset oin = "Orig#tCollNum.other_id_number#">
		<cfelse>
			<cfset oin = "">
		</cfif>
			
				<cfif sex contains 'female' or sex contains 'male'>
					<cfset sexcde=sex>
				<cfelse>
					<cfset sexcde='?'>
				</cfif>
				<cfif collection_cde is 'Egg'>
					<cfset sexcde=''>
				</cfif>
				
                <!---<cfif #sex# contains "female">
                        <cfset sexcde = replace(sex,"female","&##9792;")>
                <cfelseif #sex# contains "male">
                        <cfset sexcde = replace(sex,"male","&##9794;")>
                <cfelse>
                        <cfset sexcde = "?">
                </cfif>--->



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
				<cfif isdefined('labels_agent_name') and len(labels_agent_name) gt 0>
					<cfset thisColl = labels_agent_name>
				<cfelse>
               		<cfif #collectors# contains ",">
                        <Cfset spacePos = find(",",collectors)>
                        <cfset thisColl = left(collectors,#SpacePos# - 1)>
                        <cfset thisColl = "#thisColl# et al.">
                	<cfelse>
                        <cfset thisColl = #collectors#>
                	</cfif>
				</cfif>
				<!--- portion to eliminiate certain parts from report
				as specified by the parts matrix--->
				<!--- Definitions:
				parts is the parts obtained from the query; 
				tempParts is the subset of those parts that are checked in the parts matrix;
				stripParts is the parts string that gets printed; does collection logic--->
				<cfset stripParts=''>
				<cfset tempParts=''>
                <cfset tiss = "">
				<cfloop index='p' list="#parts#" delimiters=';'>
					<!--- eliminate characters that cannot be used in CF variables --->
					<cfset pVar = replaceNonVarNameChars(trim(p))>
					<!---p = (#p#)<br/>
					pVar = (#pVar#)<br/>--->
					<!--- end eliminate characters that cannot be used in CF variables --->
					<cfif isdefined('#pVar#$#collection_object_id#')>
						<cfif tempParts is ''>
							<cfset tempParts = p>
						<cfelse>
							<cfset tempParts = '#tempParts#,#p#'>
						</cfif>
					</cfif>
				</cfloop>
				<!--- end portion to eliminiate certain parts from report
				as specified by the parts matrix--->
		<!---
		Here is the logic of whether to add skin and skull stuff.
		If the parts contains both skin and skull we don't want either to show up.
		If it contains skin and skull and at least one other thing, we want a '+' at the beginning.
		If the parts contains skin or skull, we want that one to show up.
		--Peter DeVore, email: pdevore@berkeley.edu
		Note that the logic here is institution specific, but
		untested
		--Peter DeVore, email: pdevore@berkeley.edu
		Delimiter for parts is ";" while delimiter for tempParts is ","
		--Peter DeVore, email: pdevore@berkeley.edu--->
		<cfif collection_cde is 'Mamm'>
				<cfset studyskin=false>
				<cfset skull=false>
				<cfset otherPartAdded=false>
				<cfloop list='#tempParts#' delimiters=',' index='p'>
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
                <cfloop list="#tempParts#" delimiters="," index="p">
					<cfif otherPartAdded>
						<cfif (not (#p# contains 'skull') and
								not (#p# contains 'skin')) or
								not (studyskin and skull)>
	                       	<cfif len(#stripParts#) is 0>
								<cfset stripParts = #p#>
							<cfelse>
	                           	<cfset stripParts = "#stripParts#; #p#">
							</cfif>
						</cfif>
					<cfelse>
                       	<cfif len(#stripParts#) is 0>
							<cfset stripParts = #p#>
						<cfelse>
                           	<cfset stripParts = "#stripParts#; #p#">
						</cfif>
					</cfif>
                </cfloop>
				<cfif studyskin and skull and otherPartAdded>
					<cfset stripParts = '+#Trim(stripParts)#'>
				</cfif>
		<cfelseif collection_cde is 'Bird'>
			<!--- test it --->
				<cfset studyskin=false>
				<cfset otherPartAdded=false>
				<cfloop list='#tempParts#' delimiters=',' index='p'>
					<cfif #p# contains 'skin'>
						<cfset studyskin=true>
					</cfif>
					<cfif not (#p# contains 'skin')>
						<cfset otherPartAdded = true>
					</cfif>
				</cfloop>
                <cfloop list="#tempParts#" delimiters="," index="p">
					<cfif otherPartAdded>
						<cfif not (#p# contains 'skin') or
								not (studyskin)>
	                       	<cfif len(#stripParts#) is 0>
								<cfset stripParts = #p#>
							<cfelse>
	                           	<cfset stripParts = "#stripParts#; #p#">
							</cfif>
						</cfif>
					<cfelse>
                       	<cfif len(#stripParts#) is 0>
							<cfset stripParts = #p#>
						<cfelse>
                           	<cfset stripParts = "#stripParts#; #p#">
						</cfif>
					</cfif>
                </cfloop>
				<cfif studyskin and otherPartAdded>
					<cfset stripParts = '+#Trim(stripParts)#'>
				</cfif>
		<cfelseif collection_cde is 'Herp'>
			<!--- test it  --->
				<cfset wholeanimal=false>
				<cfset otherPartAdded=false>
				<cfloop list='#tempParts#' delimiters=',' index='p'>
					<cfif #p# contains 'whole animal (frozen)'>
						<cfset wholeanimal=true>
					</cfif>
					<cfif not (#p# contains 'whole animal (frozen)')>
						<cfset otherPartAdded = true>
					</cfif>
				</cfloop>
                <cfloop list="#tempParts#" delimiters="," index="p">
					<cfif otherPartAdded>
						<cfif not (#p# contains "(frozen)") or
								not (wholeanimal)>
	                       	<cfif len(#stripParts#) is 0>
								<cfset stripParts = #p#>
							<cfelse>
	                           	<cfset stripParts = "#stripParts#; #p#">
							</cfif>
						</cfif>
					<cfelse>
                       	<cfif len(#stripParts#) is 0>
							<cfset stripParts = #p#>
						<cfelse>
                           	<cfset stripParts = "#stripParts#; #p#">
						</cfif>
					</cfif>
                </cfloop>
				<cfif wholeanimal and otherPartAdded>
					<cfset stripParts = '+#Trim(stripParts)#'>
				</cfif>
		<cfelseif collection_cde is 'Egg'>
			<cfset stripParts=tempParts>
		</cfif>
				<!--- portion to abbreviate common words from parts --->
				<cfset stripParts = replace(stripParts,'partial','part.','all')>
				<cfset stripParts = replace(stripParts,'skeleton','skel.','all')>
				<cfset stripParts = replace(stripParts,'complete','comp.','all')>
				<cfset stripParts = replace(stripParts,'incomplete','incomp.','all')>
				<!--- end portion to abbreviate common words from parts--->
                <cfset thisDate = "">
                <cftry>
                        <cfset thisDate = #dateformat(verbatim_date,"dd mmm yyyy")#>
                        <cfcatch>
                                <cfset thisDate = #verbatim_date#>
                        </cfcatch>
                </cftry>
        <cfset t=#t#+1>
        <cfset i=#i#+1>
        <!--- each page holds 28 labels --->
        <cfif #i# is 1>
                <table cellpadding="0" cellspacing="0">
		</cfif>
		<cfif #t# is 1>
        <tr>
        </cfif>
        <cfset borderstyle = "border-bottom: 1 px dashed ##CCCCCC; border-right: 1 px dashed ##CCCCCC;">
        <cfif #i# lt numCols+1><!--- first row of the table --->
			<cfset borderstyle = "#borderstyle#; border-top: 1 px dashed ##CCCCCC;">
		</cfif>
		<cfif #t# is 1><!--- first column of the table --->
			<cfset borderstyle = "#borderstyle#; border-left: 1 px dashed ##CCCCCC;">
		</cfif>
		#label(borderstyle,cat_num,sexcde,oin,Scientific_Name,geog,verbatim_date,thisColl,stripParts)#
		<cfif #t# is numCols>
			<cfset t=0>
			</tr>
		</cfif>
		<cfif #i# is numRows*numCols>
			<cfset i=0>
			</table>
			<cfdocumentitem type="pagebreak"></cfdocumentitem>
		</cfif>
		<cfset r=#r#+1>
		<cfset usedRecords=r>
	<cfcatch type="continue"><!--- ignore ---></cfcatch>
</cftry>
</cfloop>
<!--- insert dummy labels so that spacing on last labels is correct --->
<cfloop condition="#r#lt#usedRecords#+#numCols#">
        <cfset t=#t#+1>
        <cfset i=#i#+1>
        <!--- each page holds numRows*numCols labels --->
        <cfif #i# is 1>
                <table cellpadding="0" cellspacing="0">
		</cfif>
		<cfif #t# is 1>
        <tr>
        </cfif>
        <cfset borderstyle = "border-bottom: 1 px dashed ##CCCCCC; border-right: 1 px dashed ##CCCCCC;">
        <cfif #i# lt numCols+1><!--- first row of the table --->
			<cfset borderstyle = "#borderstyle#; border-top: 1 px dashed ##CCCCCC;">
		</cfif>
		<cfif #t# is 1><!--- first column of the table --->
			<cfset borderstyle = "#borderstyle#; border-left: 1 px dashed ##CCCCCC;">
		</cfif>
		#label(borderstyle,'','','','','','','','')#
		<cfif #t# is numCols>
			<cfset t=0>
			</tr>
		</cfif>
		<cfif #i# is numRows*numCols>
			<cfset i=0>
			</table>
			<cfdocumentitem type="pagebreak"></cfdocumentitem>
		</cfif>
		<cfset r=#r#+1>
</cfloop>
</cfdocument>
<a href="/temp/narrowlabels_#cfid#_#cftoken#.pdf">Get the PDF</a><br />
<!---removing the debugging area
Start debugging area:<br/>
<cfdump var='#form#'>
<cfloop query='data'>

				<!--- portion to eliminiate certain parts from report
				as specified by the parts matrix--->
				<strong>Start processing parts for id=(#collection_object_id#) cat=(#cat_num#) <br/>
				put ()'s around every item to show whitespace</strong><br/>
				parts=(#parts#)<br/>
				<cfset stripParts=''>
				<cfset tempParts=''>
                <cfset tiss = "">
				<cfloop index='p' list="#parts#" delimiters=';'>
					<!--- eliminate characters that cannot be used in CF variables --->
					<cfset pVar = replaceNonVarNameChars(trim(p))>
					<!---p = (#p#)<br/>
					pVar = (#pVar#)<br/>--->
					<!--- end eliminate characters that cannot be used in CF variables --->
					<cfif isdefined('#pVar#$#collection_object_id#')>
						<cfif tempParts is ''>
							<cfset tempParts = trim(p)>
						<cfelse>
							<cfset tempParts = '#tempParts#,#trim(p)#'>
						</cfif>
					</cfif>
				</cfloop>
				<!--- end portion to eliminiate certain parts from report
				as specified by the parts matrix--->
				Ending tempParts: #tempParts#<br/>
				<cfset studyskin=false>
				<cfset skull=false>
				<cfset otherPartAdded=false>
				<cfloop list='#tempParts#' delimiters=',' index='p'>
					*current item is #p#<br/>
					<cfif #p# contains 'skin'>
						<cfset studyskin=true>
					</cfif>
					<cfif #p# contains 'skull'>
						<cfset skull=true>
					</cfif>
					<cfif not (#p# contains 'skin') and not (#p# contains 'skull')>
						<cfset otherPartAdded = true>
					<cfelse>
						**not considered otherPart<br/>
					</cfif>
				</cfloop>
				After the checking loop:<br/>
				studyskin=(#studyskin#), skull=(#skull#), otherPartAdded=(#otherPartAdded#)<br/>
                <cfloop list="#tempParts#" delimiters="," index="p">
					*processing part (#p#)<br/>
					<!--- the logic for adding is this:
					add it:
					if otherPartAdded
					then
						add if it is not skull or skin
						add if we dont have both skull and skin in parts
					else
						add
					--->
					<cfif otherPartAdded>
						<cfif (not (#p# contains 'skull') and
								not (#p# contains 'skin')) or
								not (studyskin and skull)>
	                       	<cfif len(#stripParts#) is 0>
		                       	**added at 1<br/>
								<cfset stripParts = #p#>
							<cfelse>
		                       	**added at 2<br/>
	                           	<cfset stripParts = "#stripParts#; #p#">
							</cfif>
						</cfif>
					<cfelse>
                       	<cfif len(#stripParts#) is 0>
		                    **added at 3<br/>
							<cfset stripParts = #p#>
						<cfelse>
		                    **added at 4<br/>
                           	<cfset stripParts = "#stripParts#; #p#">
						</cfif>
					</cfif>
                </cfloop>
				After the processing loop<br/>
				stripParts=(#stripParts#)<br/>
				<cfif studyskin and skull and otherPartAdded and stripParts is not ''>
					<cfset stripParts = '+#trim(stripParts)#'>
				</cfif>
				After dealing with '+'<br/>
				stripParts=(#stripParts#)<br/>
				<!--- portion to abbreviate common words from parts --->
				<cfset stripParts = replace(stripParts,'partial','part.','all')>
				<cfset stripParts = replace(stripParts,'skeleton','skel.','all')>
				<cfset stripParts = replace(stripParts,'complete','comp.','all')>
				<cfset stripParts = replace(stripParts,'incomplete','incomp.','all')>
				<!--- end portion to abbreviate common words from parts--->
				<br/>
</cfloop>
end commenting out debug area--->
</cfoutput>
</cfif> <!--- end the action generatePDF --->


<cfif action is 'nothing'>
<cfset title='Narrow Labels Parameters'>
<cfset checkedElementBGColor = "green">
<cfset uncheckedElementBGColor = "red">
<cfset partsMatrixStyle = 'border: 1px solid black; padding: 0.3em;'>
<cfset checkedElementStyle = '#partsMatrixStyle# background-color: #checkedElementBGColor#;'>
<cfset uncheckedElementStyle = '#partsMatrixStyle# background-color: #uncheckedElementBGColor#;'>
<cfset tableStyle = 'padding: 3px;'>
<script type='text/javascript'>
<!--- cool javascript functions to help with parts --->
function selectAll(partVar) {
	var header = document.getElementById('partsHeaderRow');
	for (var row = header.nextSibling; row.id != 'endOfParts'; row = row.nextSibling) {
		if (row.nodeType == 1 && row.nodeName == 'TR') {
			for (var td = row.childNodes[0]; td != null && td.nodeName != 'TR'; td = td.nextSibling) {
				if (td.nodeType == 1 && td.nodeName == 'TD') {
					for (var e = td.childNodes[0]; e != null && e.nodeName != 'TD'; e = e.nextSibling) {
						if (e != null && e.id && e.id.indexOf(partVar) != -1) {
							var num = e.id.indexOf(partVar);
							e.checked = true;
							e.parentNode.style.backgroundColor = <cfoutput>"#checkedElementBGColor#"</cfoutput>;
						}
					}
				}
			}
		}
	}
}
function deselectAll(partVar) {
	var header = document.getElementById('partsHeaderRow');
	for (var row = header.nextSibling; row.id != 'endOfParts'; row = row.nextSibling) {
		if (row.nodeType == 1 && row.nodeName == 'TR') {
			for (var td = row.childNodes[0]; td != null && td.nodeName != 'TR'; td = td.nextSibling) {
				if (td.nodeType == 1 && td.nodeName == 'TD') {
					for (var e = td.childNodes[0]; e != null && e.nodeName != 'TD'; e = e.nextSibling) {
						if (e != null && e.id && e.id.indexOf(partVar) != -1) {
							var num = e.id.indexOf(partVar);
							e.checked = false;
							e.parentNode.style.backgroundColor = <cfoutput>"#uncheckedElementBGColor#"</cfoutput>;
						}
					}
				}
			}
		}
	}
}
function updateBGColor(that) {
	if (that.checked==true) {
		that.parentNode.style.backgroundColor=<cfoutput>"#checkedElementBGColor#"</cfoutput>;
	} else {
		that.parentNode.style.backgroundColor=<cfoutput>"#uncheckedElementBGColor#"</cfoutput>;
	}
}
<!--- end cool javascript functions to help with parts --->
<!--- js functions for Geography Modifiers --->
function removeGeogMod() {
	var that = this.parentNode.parentNode;
	var num = that.id.substr(7);
	var theNextRow = that.nextSibling;
	that.parentNode.removeChild(that);
	reIndexGeogMod(theNextRow, num);
}
function reIndexGeogMod(theRow, num) {
	while (theRow.id != 'endOfGeogMod') {
		//Go through all of the children, changing the numbers
		for (var td = theRow.firstChild; td != null; td = td.nextSibling) {
			for (var e = td.firstChild; e != null; e = e.nextSibling) {
				if (e.name.indexOf("geogModFind") == 0) {
					//Then this is the find element.
					e.name = "geogModFind" + num;
				}
				if (e.name.indexOf("geogModReplace") == 0) {
					//Then this is the replace element.
					e.name = "geogModReplace" + num;
				}
				if (e.name.indexOf("geogModScope") == 0) {
					//Then this is the scope element.
					e.name = "geogModScope" + num;
				}
			}
		}
		theRow.id = 'geogMod' + num;
		num++;
		theRow = theRow.nextSibling;
	}
}
function addNewGeogMod() {
	var endRow = document.getElementById("endOfGeogMod");
	var prevRow = endRow.previousSibling;
	var curNum = 1;
	if (prevRow.id && prevRow.id.indexOf("geogMod") == 0) {
		//The the previous row is a geogMod entry, so we add a new one,
		//incrementing the number.
		var previousNum = prevRow.id.substr(7);
		var curNum = 1 + Number(previousNum);
	}
	var newGeogModRow = document.createElement("tr");
	newGeogModRow.id = "geogMod" + curNum;
	
	var findTD = document.createElement("TD");
	var findInput = document.createElement("INPUT");
	findInput.type = 'text';
	findInput.name = 'geogModFind' + curNum;
	findInput.size = 50;
	findTD.appendChild(findInput);
	
	var replaceTD = document.createElement("TD");
	var replaceInput = document.createElement("INPUT");
	replaceInput.type = 'text';
	replaceInput.name = 'geogModReplace' + curNum;
	replaceInput.size = 30;
	replaceTD.appendChild(replaceInput);

	var scopeTD = document.createElement("TD");
	var scopeInput = document.createElement("INPUT");
	scopeInput.type = 'text';
	scopeInput.name = 'geogModScope' + curNum;
	scopeInput.size = 60;
	scopeTD.appendChild(scopeInput);
	
	var removeTD = document.createElement("TD");
	var removeInput = document.createElement("INPUT");
	removeInput.type = 'button';
	removeInput.value = 'Remove this Geography Modifier';
	//the following won't quite work...
	removeInput.onclick = removeGeogMod;
	if (removeInput.captureEvents) {
		removeInput.captureEvents(Event.CLICK);
	}
	removeTD.appendChild(removeInput);
	
	newGeogModRow.appendChild(findTD);
	newGeogModRow.appendChild(replaceTD);
	newGeogModRow.appendChild(scopeTD);
	newGeogModRow.appendChild(removeTD);
	endRow.parentNode.insertBefore(newGeogModRow,endRow);
}
<!--- --->
</script>
<!--- start geography (locality, country, state/province, etc) query --->
<!---<cfset sql="
	SELECT
		cataloged_item.collection_object_id,
		cat_num,
		state_prov,
		country,
		quad,
		county,
		island,
		sea,
		feature,
		spec_locality
	FROM
		cataloged_item
		INNER JOIN identification ON (cataloged_item.collection_object_id = identification.collection_object_id)
		INNER JOIN collecting_event ON (cataloged_item.collecting_event_id = collecting_event.collecting_event_id)
		INNER JOIN locality ON (collecting_event.locality_id = locality.locality_id)
		INNER JOIN geog_auth_rec ON (locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id)
	WHERE
		accepted_id_fg=1 AND cataloged_item.collection_object_id IN (#collection_object_id#)
">
<cfquery name="geogQuery" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(sql)#
</cfquery>--->
<!--- No longer need geography query because new idea does not require the
specific geography information. --->
<!--- end geography query --->
<!--- get data for parts--->
<cfset sql="
	SELECT
		cataloged_item.collection_object_id,
		collection_cde,
		concatparts(cataloged_item.collection_object_id) as parts,
		cat_num,
		accepted_id_fg
	FROM
		cataloged_item
		INNER JOIN identification ON (cataloged_item.collection_object_id = identification.collection_object_id)
	WHERE
		accepted_id_fg=1 AND cataloged_item.collection_object_id IN (#collection_object_id#)
	ORDER BY
		cat_num
">
<cfquery name="partsQuery" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(sql)#
</cfquery>
<!--- end get data for parts--->
<cfoutput>
<h3>Specify your parameters</h3>
<form action='narrowLabels.cfm' method='post'>
<table style='#tableStyle#'>
		<input type='hidden' name='action' value='generatePDF'>
		<input type='hidden' name='collection_object_id' value='#URLDecode(collection_object_id)#'>
	<tr>
		<td>
		<input type='submit' value='Generate the PDF' className='lnkBtn'
	<!---onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"---> />
		</td>
	</tr>
</table>
<!--- locality changing code --->
<!--- the idea is that we want to have the option to fully change the locality
text. This is necessary since often the locality will not be able to fit. since
most of the localities will not be changed, I am thinking the format should be
a table with three elements per row: specimen cat number, locality text,
checkbox asking whether to overwrite it.

First idea, above, does NOT scale to over 500 labels.  New idea is to be able to
do a global replace of certain strings (possibly with regex).  So we will have a
table with one row that allows you do string replace for all labels or one specific
label. A javascript function will allow the user to add more rows of data.
An implementation may be to save the items as a list of key value pairs.--->
<strong>Geography Modifiers</strong>
<table style='#tableStyle#'>
	<tr>
		<td>Find:</td><td>Replace with:</td><td>Catalog number(s) (comma separated, ranges using "-") or blank for all geographies</td>
	</tr>
	<tr id='endOfGeogMod'>
		<td><input type='button' className='picBtn' 
	<!---onmouseover="this.className='picBtn btnhov'" onmouseout="this.className='picBtn'"--->
	onclick='javascript: addNewGeogMod();' value='Add new geography modifier' /></td>
	</tr>
</table>
<!--- end locality changing code --->
<!--- This is where we start the parts matrix.
The idea behind the parts matrix is that it lets users specify whether they
want certain parts of certain specimens to appear on the labels.  This way,
they do not have to edit the generated PDF.  Rather, they specify which
parts they want BEFORE the PDF is generated, and that way the formatting
will be done automatically instead of being corrected later, which is a BIG
hassle.
--Peter DeVore, email: pdevore@berkeley.edu--->
<strong>Parts Matrix</strong>
<cfset headerPeriod = 20>
<table style='#tableStyle#'>
	<tr id='partsHeaderRow'>
		<td style='#partsMatrixStyle#'>Specimen<br/>Catalog<br/>Number</td>
	<cfset partColumnHeaderList = "">
	<cfloop query='partsQuery'>
		<cfloop list='#parts#' delimiters=';' index='p'>
			<cfset trimmedP = trim(p)>
			<cfif not listcontains(partColumnHeaderList,trimmedP)>
				<cfset pVar = replaceNonVarNameChars(trimmedP)>
				<!--- did not find the part in the column header list so add it--->
				<td style='#partsMatrixStyle#'>#trimmedP#<br />
				<span onclick='javascript:selectAll("#pVar#");'
						class='likeLink'>Select All</span><br />
				<span onclick='javascript:deselectAll("#pVar#");'
						class='likeLink'>Deselect All</span><br />
				</td>
				<cfset partColumnHeaderList = ListAppend(partColumnHeaderList,trimmedP)>
			</cfif>
		</cfloop>
	</cfloop>
	</tr>
	<cfset rowsSinceHeader = 0>
	<cfloop query='partsQuery'>
		<tr><td style='#partsMatrixStyle#'>
			<a href='SpecimenDetail.cfm?collection_object_id=#collection_object_id#' target='Edit Specimen'>
				#collection_cde# #cat_num#</a>
			<input type='checkbox' checked='checked' name='$#collection_object_id#$'/>
		</td>
			<cfloop list='#partColumnHeaderList#' index='col'>
				<cfif FindNoCase(col,parts) gt 0>
					<!--- eliminate characters that cannot be used in CF variables --->
					<cfset colVar = replaceNonVarNameChars(trim(col))>
					<!--- end eliminate characters that cannot be used in CF variables --->
					<td style='#checkedElementStyle#'>
					<input type='checkbox' checked='checked' id='#colVar#$#collection_object_id#' 
							name='#colVar#$#collection_object_id#'
							onchange='javascript: updateBGColor(this);'></input>
					</td>
				<cfelse>
					<td style='#partsMatrixStyle#'>&nbsp;</td>
				</cfif>
			</cfloop>
			<cfset rowsSinceHeader = rowsSinceHeader + 1>
		</tr>
		<cfif rowsSinceHeader is headerPeriod>
		<tr><td style='#partsMatrixStyle#'>Specimen<br/>Catalog<br/>Number</td>
			<cfloop list='#partColumnHeaderList#' index='part'>
				<cfset pVar = replaceNonVarNameChars(part)>
				<td style='#partsMatrixStyle#'>#part#<br />
				<span onclick='javascript:selectAll("#pVar#");'
						class='likeLink'>Select All</span><br />
				<span onclick='javascript:deselectAll("#pVar#");'
						class='likeLink'>Deselect All</span><br />
				</td>
			</cfloop></tr>
			<cfset rowsSinceHeader = 0>
		</cfif>
	</cfloop>
	<tr id='endOfParts'/>
</table>
</form>
</cfoutput>


</cfif>
<cfinclude template = "includes/_footer.cfm">