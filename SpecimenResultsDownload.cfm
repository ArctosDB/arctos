<cfinclude template="/includes/_header.cfm">
<cfif not isdefined("session.username") OR len(session.username) is 0>
	<div class="error">
		You must be a registered user to download data.
		<br><a href="/login.cfm">Log in or create a user account</a>
	</div>
	<cfabort>
</cfif>
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
							<cfquery name="ctPurpose" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
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
								<input type="text" name="filename" value="ArctosData_#cfid#_#cftoken#">
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
				<cflocation url="SpecimenResultsDownload.cfm?fileformat=#getUserData.download_format#&agree=yes&action=down&tablename=#tablename#&download_purpose=research&filename=ArctosData_#cfid#_#cftoken#" addtoken="false">
			</cfif>			
		<cfelse>
			<form method="post" action="SpecimenResultsDownload.cfm" name="dlForm">
				<input type="hidden" name="tableName" value="#tableName#">
				<input type="hidden" name="action" value="down">
				<table>
					<tr>
						<td align="right">Purpose of Download</td>
						<cfquery name="ctPurpose" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
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
							<input type="text" name="filename" value="ArctosData_#cfid#_#cftoken#">
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
	<cfquery name="cols" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cfquery name="getData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from #tableName#
	</cfquery>
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