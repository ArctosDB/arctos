<cfinclude template="/includes/_header.cfm">
<cfif not isdefined("session.username") OR len(session.username) is 0>
	<div class="error">
		You must be a registered user to download data.
		<br><a href="/login.cfm">Log in or create a user account</a>
	</div>
	<cfabort>
</cfif>
<cfif action is "bulkloaderFormat">
	<cfoutput>
	<cfif len(collection_object_id) is 0>
		This form requires collection_object_id (LIST)
		<cfabort>
	</cfif>
	<!--- 
		kinda stoopid but simple - copypasta columns list in, in order, frmo the function
		so things don't come out alpha-sorted
	---->
	<cfset clist = "
		COLLECTION_OBJECT_ID,
		LOADED,
		ENTEREDBY,
		ACCN,
		TAXON_NAME,
		NATURE_OF_ID,
		MADE_DATE,
		IDENTIFICATION_REMARKS,
		collection_cde,
		institution_acronym,
		COLL_OBJECT_REMARKS,
		COLLECTING_EVENT_ID,
		ID_MADE_BY_AGENT,
		OTHER_ID_NUM_1,
		OTHER_ID_NUM_2,
		OTHER_ID_NUM_3,
		OTHER_ID_NUM_4,
		OTHER_ID_NUM_5,
		OTHER_ID_NUM_TYPE_1,
		OTHER_ID_NUM_TYPE_2,
		OTHER_ID_NUM_TYPE_3,
		OTHER_ID_NUM_TYPE_4,
		OTHER_ID_NUM_TYPE_5,
		COLLECTOR_AGENT_1,
		COLLECTOR_ROLE_1,
		COLLECTOR_AGENT_2,
		COLLECTOR_ROLE_2,
		COLLECTOR_AGENT_3,
		COLLECTOR_ROLE_3,
		COLLECTOR_AGENT_4,
		COLLECTOR_ROLE_4,
		COLLECTOR_AGENT_5,
		COLLECTOR_ROLE_5,
		COLLECTOR_AGENT_6,
		COLLECTOR_ROLE_6,
		COLLECTOR_AGENT_7,
		COLLECTOR_ROLE_7,
		COLLECTOR_AGENT_8,
		COLLECTOR_ROLE_8,
		PART_NAME_1,
		PART_CONDITION_1,
		PART_BARCODE_1,
		PART_CONTAINER_LABEL_1,
		PART_LOT_COUNT_1,
		PART_DISPOSITION_1,
		PART_REMARK_1,
		PART_NAME_2,
		PART_CONDITION_2,
		PART_BARCODE_2,
		PART_CONTAINER_LABEL_2,
		PART_LOT_COUNT_2,
		PART_DISPOSITION_2,
		PART_REMARK_2,
		PART_NAME_3,
		PART_CONDITION_3,
		PART_BARCODE_3,
		PART_CONTAINER_LABEL_3,
		PART_LOT_COUNT_3,
		PART_DISPOSITION_3,
		PART_REMARK_3,
		PART_NAME_4,
		PART_CONDITION_4,
		PART_BARCODE_4,
		PART_CONTAINER_LABEL_4,
		PART_LOT_COUNT_4,
		PART_DISPOSITION_4,
		PART_REMARK_4,
		PART_NAME_5,
		PART_CONDITION_5,
		PART_BARCODE_5,
		PART_CONTAINER_LABEL_5,
		PART_LOT_COUNT_5,
		PART_DISPOSITION_5,
		PART_REMARK_5,
		PART_NAME_6,
		PART_CONDITION_6,
		PART_BARCODE_6,
		PART_CONTAINER_LABEL_6,
		PART_LOT_COUNT_6,
		PART_DISPOSITION_6,
		PART_REMARK_6,
		PART_NAME_7,
		PART_CONDITION_7,
		PART_BARCODE_7,
		PART_CONTAINER_LABEL_7,
		PART_LOT_COUNT_7,
		PART_DISPOSITION_7,
		PART_REMARK_7,
		PART_NAME_8,
		PART_CONDITION_8,
		PART_BARCODE_8,
		PART_CONTAINER_LABEL_8,
		PART_LOT_COUNT_8,
		PART_DISPOSITION_8,
		PART_REMARK_8,
		PART_NAME_9,
		PART_CONDITION_9,
		PART_BARCODE_9,
		PART_CONTAINER_LABEL_9,
		PART_LOT_COUNT_9,
		PART_DISPOSITION_9,
		PART_REMARK_9,
		PART_NAME_10,
		PART_CONDITION_10,
		PART_BARCODE_10,
		PART_CONTAINER_LABEL_10,
		PART_LOT_COUNT_10,
		PART_DISPOSITION_10,
		PART_REMARK_10 ,
		PART_NAME_11,
		PART_CONDITION_11,
		PART_BARCODE_11,
		PART_CONTAINER_LABEL_11,
		PART_LOT_COUNT_11,
		PART_DISPOSITION_11,
		PART_REMARK_11 ,
		PART_NAME_12,
		PART_CONDITION_12,
		PART_BARCODE_12,
		PART_CONTAINER_LABEL_12,
		PART_LOT_COUNT_12,
		PART_DISPOSITION_12,
		PART_REMARK_12,
		ATTRIBUTE_1,
		ATTRIBUTE_VALUE_1,
		ATTRIBUTE_UNITS_1,
		ATTRIBUTE_REMARKS_1,
		ATTRIBUTE_DATE_1,
		ATTRIBUTE_DET_METH_1,
		ATTRIBUTE_DETERMINER_1,
		ATTRIBUTE_2,
		ATTRIBUTE_VALUE_2,
		ATTRIBUTE_UNITS_2,
		ATTRIBUTE_REMARKS_2,
		ATTRIBUTE_DATE_2,
		ATTRIBUTE_DET_METH_2,
		ATTRIBUTE_DETERMINER_2,
		ATTRIBUTE_3,
		ATTRIBUTE_VALUE_3,
		ATTRIBUTE_UNITS_3,
		ATTRIBUTE_REMARKS_3,
		ATTRIBUTE_DATE_3,
		ATTRIBUTE_DET_METH_3,
		ATTRIBUTE_DETERMINER_3,
		ATTRIBUTE_4,
		ATTRIBUTE_VALUE_4,
		ATTRIBUTE_UNITS_4,
		ATTRIBUTE_REMARKS_4,
		ATTRIBUTE_DATE_4,
		ATTRIBUTE_DET_METH_4,
		ATTRIBUTE_DETERMINER_4,
		ATTRIBUTE_5,
		ATTRIBUTE_VALUE_5,
		ATTRIBUTE_UNITS_5,
		ATTRIBUTE_REMARKS_5,
		ATTRIBUTE_DATE_5,
		ATTRIBUTE_DET_METH_5,
		ATTRIBUTE_DETERMINER_5,
		ATTRIBUTE_6,
		ATTRIBUTE_VALUE_6,
		ATTRIBUTE_UNITS_6,
		ATTRIBUTE_REMARKS_6,
		ATTRIBUTE_DATE_6,
		ATTRIBUTE_DET_METH_6,
		ATTRIBUTE_DETERMINER_6,
		ATTRIBUTE_7,
		ATTRIBUTE_VALUE_7,
		ATTRIBUTE_UNITS_7,
		ATTRIBUTE_REMARKS_7,
		ATTRIBUTE_DATE_7,
		ATTRIBUTE_DET_METH_7,
		ATTRIBUTE_DETERMINER_7,
		ATTRIBUTE_8,
		ATTRIBUTE_VALUE_8,
		ATTRIBUTE_UNITS_8,
		ATTRIBUTE_REMARKS_8,
		ATTRIBUTE_DATE_8,
		ATTRIBUTE_DET_METH_8,
		ATTRIBUTE_DETERMINER_8,
		ATTRIBUTE_9,
		ATTRIBUTE_VALUE_9,
		ATTRIBUTE_UNITS_9,
		ATTRIBUTE_REMARKS_9,
		ATTRIBUTE_DATE_9,
		ATTRIBUTE_DET_METH_9,
		ATTRIBUTE_DETERMINER_9,
		ATTRIBUTE_10,
		ATTRIBUTE_VALUE_10,
		ATTRIBUTE_UNITS_10,
		ATTRIBUTE_REMARKS_10,
		ATTRIBUTE_DATE_10,
		ATTRIBUTE_DET_METH_10,
		ATTRIBUTE_DETERMINER_10
	">
	<cfset cList=rereplace(clist,'[^[:print:]\n]','','all')>
	<cfset cList=replace(clist,' ','','all')>
	<cfset cList=replace(clist,chr(10),'','all')>
	<cfset cList=replace(clist,chr(9),'','all')>
	<cfset cList=replace(clist,chr(13),'','all')>				
	<cfinvoke component="component.functions" method="getCloneOfCatalogedItemInBulkloaderFormat" returnvariable="getData">
		<cfinvokeargument name="collection_object_id" value="#collection_object_id#">
	</cfinvoke>
	<cfset fileDir = "#Application.webDirectory#">
	<cfset variables.encoding="UTF-8">
	<cfset fname = "download_4_bulkloader.csv">
	<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		variables.joFileWriter.writeLine(ListQualify(clist,'"')); 
	</cfscript>
	<cfloop query="getData">
		<cfset oneLine = "">
		<cfloop list="#clist#" index="c">
			<cfset thisData = evaluate("getData." & c)>
			<cfset thisData=replace(thisData,'"','""','all')>			
			<cfif len(oneLine) is 0>
				<cfset oneLine = '"#thisData#"'>
			<cfelse>
				<cfset oneLine = '#oneLine#,"#thisData#"'>
			</cfif>
		</cfloop>
		<cfset oneLine = trim(oneLine)>
		<cfscript>
			variables.joFileWriter.writeLine(oneLine);
		</cfscript>
	</cfloop>
	<cfscript>	
		variables.joFileWriter.close();
	</cfscript>
	<cflocation url="/download.cfm?file=#fname#" addtoken="false">
	<a href="/download/#fname#">Click here if your file does not automatically download.</a>
</cfoutput>
</cfif>

<!---------------------------------------------------------------->
<cfif action is "nothing">
	<cfoutput>
		<cfset title="Download Agreement">
		<cfquery name="getUserData" datasource="cf_dbuser">
			SELECT   
				cf_users.user_id,
				first_name,
		        middle_name,
		        last_name,
		        affiliation,
				email,
				download_format,
				ask_for_filename
			FROM 
				cf_user_data,
				cf_users
			WHERE
				cf_users.user_id = cf_user_data.user_id (+) AND
				username = '#session.username#'
		</cfquery>
		<cfif len(getUserData.first_name) is 0 or 
			len(getUserData.last_name) is 0 or
			len(getUserData.affiliation) is 0>
			<div class="error">
				You must fill out yellow-backgroud fields in your <a href="/myArctos.cfm">Profile</a> before you may download data.
			</div>
			<cfabort>
		</cfif>
		<cfif isdefined("session.roles") and listcontainsnocase(session.roles,"coldfusion_user")>
			<cfif getUserData.ask_for_filename is 1>
				<form method="post" action="SpecimenResultsDownload.cfm" name="dlForm">
					<input type="hidden" name="tableName" value="#tableName#">
					<input type="hidden" name="action" value="down">
					<input type="hidden" name="agree" value="yes">
					<table>
						<tr>
							<td align="right">Purpose of Download</td>
							<cfquery name="ctPurpose" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
								select * from ctdownload_purpose order by download_purpose
							</cfquery>
							<td>
							<select name="download_purpose" size="1" class="reqdClr">
								<cfloop query="ctPurpose">
									<option <cfif ctPurpose.download_purpose is "research"> selected="selected" </cfif>value="#ctPurpose.download_purpose#">#ctPurpose.download_purpose#</option>
								</cfloop>
							</select>
							</td>
						</tr>
						<tr>
							<td align="right">File Format</td>
							<td>
								<select name="fileFormat" size="1">
									<option <cfif getUserData.download_format is "csv"> selected="selected" </cfif>value="csv">CSV</option>
									<option <cfif getUserData.download_format is "text"> selected="selected" </cfif>value="text">tab-delimited text</option>
									<option <cfif getUserData.download_format is "xml"> selected="selected" </cfif>value="xml">XML</option>
								</select>
							</td>
						</tr>
						<tr>
							<td align="right">File Name</td>
							<td>
								<input type="text" name="filename" value="ArctosData_#left(session.sessionKey,10)#">
							</td>
						</tr>
						<tr>
							<td colspan="2">
								You can skip this page by setting "Ask for Filename" to "no" in your <a href="/myArctos.cfm">Profile</a>.
							</td>
							
						</tr>
						<tr>
							<td colspan="2" align="center">
							<input type="submit" value="Continue to Download" class="savBtn">
							</td>
						</tr>
					</table>
				</form>
			<cfelse>
				<cfif not isdefined("getUserData.download_format") or len(getUserData.download_format) is 0>
					<cfset ff='csv'>
				<cfelse>
					<cfset ff=getUserData.download_format>
				</cfif>
				<cflocation url="SpecimenResultsDownload.cfm?fileformat=#getUserData.download_format#&agree=yes&action=down&tablename=#tablename#&download_purpose=research&filename=ArctosData_#left(session.sessionKey,10)#" addtoken="false">
			</cfif>			
		<cfelse>
			<form method="post" action="SpecimenResultsDownload.cfm" name="dlForm">
				<input type="hidden" name="tableName" value="#tableName#">
				<input type="hidden" name="action" value="down">
				<table>
					<tr>
						<td align="right">Purpose of Download</td>
						<cfquery name="ctPurpose" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
							select * from ctdownload_purpose order by download_purpose
						</cfquery>
						<td>
						<select name="download_purpose" size="1" class="reqdClr">
							<cfloop query="ctPurpose">
								<option value="#ctPurpose.download_purpose#">#ctPurpose.download_purpose#</option>
							</cfloop>
						</select>
						</td>
					</tr>
					<tr>
						<td align="right">File Format</td>
						<td>
							<select name="fileFormat" size="1">
								<option <cfif getUserData.download_format is "csv"> selected="selected" </cfif>value="csv">CSV</option>
								<option <cfif getUserData.download_format is "text"> selected="selected" </cfif>value="text">tab-delimited text</option>
								<option <cfif getUserData.download_format is "xml"> selected="selected" </cfif>value="xml">XML</option>
							</select>
						</td>
					</tr>
					<tr>
						<td align="right">File Name</td>
						<td>
							<input type="text" name="filename" value="ArctosData_#left(session.sessionKey,10)#">
						</td>
					</tr>
					<tr>
						<td colspan="2">
						These data are intended for use in education and research and may not be repackaged, redistributed, or sold in any form 
						without prior written consent from the Museum. Those wishing to include these data in analyses or reports must acknowledge 
						the provenance of the original data and notify the appropriate curator prior to publication. These are secondary data, and
						 their accuracy is not guaranteed. Citation of the data is no substitute for examination of specimens. The Museum and its staff 
						 are not responsible for loss or damages due to use of these data.
						</td>
						
					</tr>
					<tr>
						<td colspan="2">
						<input type="radio" name="agree" value="yes">
						<a href="javascript: void(0);" onClick="dlForm.agree[0].checked='true'"><font color="##00FF00" size="+1">
							I agree that the data that I am now downloading are for my own use and will not be repackaged, redistributed, or sold.
						</font></a>
						</td>
						
					</tr>
					<tr>
						<td colspan="2">
							<input type="radio" name="agree" value="no" checked>
							<a href="javascript: void(0);" onClick="dlForm.agree[1].checked='true'">
								<font color="##FF0000" size="+1">
									I do not agree
								</font>.
							</a>
						</td>
					</tr>
					<tr>
						<td colspan="2" align="center">
						<input type="submit" value="Continue to Download" class="savBtn">
						</td>
					</tr>
				</table>
			</form>
		</cfif>
	</cfoutput>
</cfif>	
<cfif action is "down">
	<cfif agree is "no">
		You must agree to the terms of usage to download these data.
		<ul>
			<li>Click <a href="/home.cfm">here</a> to return to the home page.</li>
			<li>Use your browser's back button or click <a href="javascript: history.back();">here</a> 
				if you wish to agree to the terms and proceed with the download.</li>
			<li>
				<a href="/contact.cfm">Contact us</a> if you wish to discuss the terms of
				usage.
			</li>
		</ul>
		<cfabort>
	</cfif>
	<cfquery name="cols" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select 
			user_tab_cols.column_name 
		from 
			user_tab_cols
			left outer join 
				cf_spec_res_cols on 
				(upper(user_tab_cols.column_name) = upper(cf_spec_res_cols.column_name)) 
		where 
			upper(table_name)=upper('#tableName#') order by DISP_ORDER
	</cfquery>
	
	<cfdump var=#cols#>
	
	<cfif not listfindnocase(valuelist(cols.column_name),"collection_object_id")>
		<cfmail subject="download without collection_object_id" to="#Application.PageProblemEmail#" from="funkydownload@#application.fromEmail#" type="html">
			valuelist(cols.column_name): #valuelist(cols.column_name)#
			<cfdump var=#session#>
		</cfmail>
		<cfquery name="getData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from #tableName#
		</cfquery>
	<cfelse>
		<cfquery name="getData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select filtered_flat.USE_LICENSE_URL
			<cfloop list="#valuelist(cols.column_name)#" index="cname">
				,#tableName#.#cname#
			</cfloop>
			from #tableName#
			,filtered_flat where #tableName#.collection_object_id=filtered_flat.collection_object_id	
		</cfquery>
	</cfif>
	
	
		<cfdump var=#getData#>
		
		
		<cfabort>

	<cfquery name="dl" datasource="cf_dbuser">
		INSERT INTO cf_download (
			user_id,
			download_purpose,
			download_date,
			num_records,
			agree_to_terms
		) VALUES (
			(select user_id from cf_users where username='#session.username#'),
			'#download_purpose#',
			sysdate,
			nvl(#getData.recordcount#,0),
			'yes'
		)
	</cfquery>
	<cfset ac = valuelist(cols.column_name)>
	<!--- strip internal columns --->
	<cfif ListFindNoCase(ac,'COLLECTION_OBJECT_ID')>
			<cfset ac = ListDeleteAt(ac, ListFindNoCase(ac,'COLLECTION_OBJECT_ID'))>
	</cfif>
	<cfif ListFindNoCase(ac,'CUSTOMIDINT')>
		<cfset ac = ListDeleteAt(ac, ListFindNoCase(ac,'CUSTOMIDINT'))>
	</cfif>
	<cfif ListFindNoCase(ac,'COLLECTION_ID')>
		<cfset ac = ListDeleteAt(ac, ListFindNoCase(ac,'COLLECTION_ID'))>
	</cfif>
	<cfif ListFindNoCase(ac,'TAXON_NAME_ID')>
		<cfset ac = ListDeleteAt(ac, ListFindNoCase(ac,'TAXON_NAME_ID'))>
	</cfif>
	<cfif ListFindNoCase(ac,'COLLECTION_CDE')>
		<cfset ac = ListDeleteAt(ac, ListFindNoCase(ac,'COLLECTION_CDE'))>
	</cfif>
	<cfif ListFindNoCase(ac,'INSTITUTION_ACRONYM')>
		<cfset ac = ListDeleteAt(ac, ListFindNoCase(ac,'INSTITUTION_ACRONYM'))>
	</cfif>
	<cfset fileDir = "#Application.webDirectory#">
	
	<!--- add one and only one line break back onto the end --->
	
	<cfoutput>
		<cfset variables.encoding="UTF-8">
		<cfif fileFormat is "csv">
			<cfset fname = "#fileName#.csv">
			<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
			<cfset header=trim(ac)>
			<cfscript>
				variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
				variables.joFileWriter.writeLine(header); 
			</cfscript>
			<cfloop query="getData">
				<cfset oneLine = "">
				<cfloop list="#ac#" index="c">
					<cfset thisData = evaluate(c)>
					<cfif c is "MEDIA">
						<cfset thisData='#application.serverRootUrl#/MediaSearch.cfm?collection_object_id=#collection_object_id#'>
					</cfif>
					<cfif len(oneLine) is 0>
						<cfset oneLine = '"#thisData#"'>
					<cfelse>
						<cfset thisData=replace(thisData,'"','""','all')>
						<cfset oneLine = '#oneLine#,"#thisData#"'>
					</cfif>
				</cfloop>
				<cfset oneLine = trim(oneLine)>
				<cfscript>
					variables.joFileWriter.writeLine(oneLine);
				</cfscript>
			</cfloop>
			<cfscript>	
				variables.joFileWriter.close();
			</cfscript>
			<cflocation url="/download.cfm?file=#fname#" addtoken="false">
			<a href="/download/#fname#">Click here if your file does not automatically download.</a>
		<cfelseif fileFormat is "text">
			<cfset fname = "#fileName#.txt">
			<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
			<cfset header = replace(ac,",","#chr(9)#","all")>
			<cfset header=#trim(header)#>
			<cfscript>
				variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
				variables.joFileWriter.writeLine(header); 
			</cfscript>
			<cfloop query="getData">
				<cfset oneLine = "">
				<cfloop list="#ac#" index="c">
					<cfset thisData = #evaluate(c)#>
					<cfif c is "MEDIA">
						<cfset thisData='#application.serverRootUrl#/MediaSearch.cfm?collection_object_id=#collection_object_id#'>
					</cfif>
					<cfif len(#oneLine#) is 0>
						<cfset oneLine = '#thisData#'>
					<cfelse>
						<cfset oneLine = '#oneLine##chr(9)##thisData#'>
					</cfif>
				</cfloop>
				<cfset oneLine = trim(oneLine)>
				<cfscript>
					variables.joFileWriter.writeLine(oneLine);
				</cfscript>
			</cfloop>
			<cfscript>	
				variables.joFileWriter.close();
			</cfscript>
			<cflocation url="/download.cfm?file=#fname#" addtoken="false">
			<a href="/download/#fname#">Click here if your file does not automatically download.</a>
		
		<cfelseif fileFormat is "xml">
			<cfset fname = "#fileName#.xml">
			<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
			<cfset header = "<result>">
			<cfscript>
				variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
				variables.joFileWriter.writeLine(header); 
			</cfscript>
			<cfloop query="getData">
				<cfset oneLine = "<record>">
				<cfloop list="#ac#" index="c">
					<cfset thisData = #evaluate(c)#>
					<cfif c is "MEDIA">
						<cfset thisData='#application.serverRootUrl#/MediaSearch.cfm?collection_object_id=#collection_object_id#'>
					</cfif>
					<cfif len(#oneLine#) is 0>
						<cfset oneLine = '<#c#>#xmlformat(thisData)#</#c#>'>
					<cfelse>
						<cfset oneLine = '#oneLine#<#c#>#xmlformat(thisData)#</#c#>'>
					</cfif>
				</cfloop>
				<cfset oneLine = "#oneLine#</record>">
				<cfset oneLine = trim(oneLine)>
				<cfscript>
					variables.joFileWriter.writeLine(oneLine);
				</cfscript>
			</cfloop>
			<cfset oneLine = "</result>">				
			<cfscript>	
				variables.joFileWriter.writeLine(oneLine);
				variables.joFileWriter.close();
			</cfscript>
			<cflocation url="/download.cfm?file=#fname#" addtoken="false">
			<a href="/download/#fname#">Click here if your file does not automatically download.</a>
		<cfelse>
			That file format doesn't seem to be supported yet!
		</cfif>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">