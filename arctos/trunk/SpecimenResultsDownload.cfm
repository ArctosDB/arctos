<cfinclude template="/includes/_header.cfm">
<cfset title="Download Agreement">
<!--- make sure they have an account --->
<cfif not isdefined("cnt") OR len(#cnt#) is 0>
	<cfset cnt=0>
</cfif>
<cfif not isdefined("session.username") OR len(#session.username#) is 0>
	<span style="color: #FF0000">You must be a registered user to download data!</span>  <br>
	Click <a href="/login.cfm">here</a> to log in or create a user account.
	<cfabort>
</cfif>

<cfif #action# is "nothing">
<cfquery name="getUserData" datasource="#Application.web_user#">
	SELECT   
		cf_users.user_id,
		first_name,
        middle_name,
        last_name,
        affiliation,
		email
	FROM 
		cf_user_data,
		cf_users
	WHERE
		cf_users.user_id = cf_user_data.user_id (+) AND
		username = '#session.username#'
</cfquery>
<cfoutput>
<table>

<form method="post" action="SpecimenResultsDownload.cfm" name="dlForm">
	<input type="hidden" name="user_id" value="#getUserData.user_id#">
	<input type="hidden" name="tableName" value="#tableName#">
	
	<input type="hidden" name="action" value="continue">
	<input type="hidden" name="cnt" value="#cnt#">
	<tr>
		<td colspan="2"><span style="font-weight: bold; font-style: italic;">
			You must fill out this form before you may download data. Fields with a 
		    <input type="text" size="2" class="reqdClr"> 
		    background color are required.
	</span></td>
	</tr>
	<tr>
		<td align="right" width="20%">First Name</td>
		<td> <input type="text" name="first_name" value="#getUserData.first_name#" class="reqdClr"></td>
	</tr>
	<tr>
		<td align="right">Middle Name</td>
		<td><input type="text" name="middle_name" value="#getUserData.middle_name#"></td>
	</tr>
	<tr>
		<td align="right">Last Name</td>
		<td><input type="text" name="last_name" value="#getUserData.last_name#" class="reqdClr"></td>
	</tr>
	<tr>
		<td align="right">Affiliation</td>
		<td><input type="text" name="affiliation" value="#getUserData.affiliation#" class="reqdClr"></td>
	</tr>
	<tr>
		<td align="right">Purpose of Download</td>
		<cfquery name="ctPurpose" datasource="#Application.web_user#">
			select * from ctdownload_purpose
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
		<td align="right">Email</td>
		<td><input type="text" name="email" value="#getUserData.email#"></td>
	</tr>
	<tr>
		<td align="right">File Format</td>
		<td>
			<select name="fileFormat" size="1">
				<option value="text">tab-delimited text</option>
				<option value="csv">CSV</option>
				<option value="xml">XML</option>
			</select>
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
		<a href="javascript: void(0);" onClick="dlForm.agree[0].checked='true'"><font color="##00FF00" size="+1">I agree that the data that I am now downloading are for my own use 
and will not be repackaged, redistributed, or sold.</font></a>
		
		</td>
		
	</tr>
	<tr>
		<td colspan="2">
		
<input type="radio" name="agree" value="no" checked>
<a href="javascript: void(0);" onClick="dlForm.agree[1].checked='true'"><font color="##FF0000" size="+1">I
do not agree</font>.</a>
 
		</td>
		
	</tr>
	<tr>
		<td colspan="2" align="center">
		<input type="submit" value="Continue" 
			class="savBtn"
   			onmouseover="this.className='savBtn btnhov'" 
			onmouseout="this.className='savBtn'">
		</td>
		
	</tr>
</form>

</table>
</cfoutput>
</cfif>

<cfif #action# is "continue">
	<!--- get the values they filled in --->
	<cfif len(#first_name#) is 0 OR
		len(#last_name#) is 0 OR
		len(#download_purpose#) is 0 OR
		len(#affiliation#) is 0>
		You haven't filled in all required values! Please use your browser's back button to try again.
		<cfabort>
	</cfif>
	<cfset thisDate = #dateformat(now(),"dd-mmm-yyyy")#>
	<cfquery name="dl" datasource="#Application.uam_dbo#">
		INSERT INTO cf_download (
			user_id,
			download_purpose,
			download_date,
			num_records,
			agree_to_terms)
		VALUES (
			#user_id#,
			'#download_purpose#',
			'#thisDate#',
			#cnt#,
			'#agree#')
	</cfquery>
	
	<cfquery name="isUser" datasource="#Application.web_user#">
		select * from cf_user_data where user_id=#user_id#
	</cfquery>
		<!---- already have a user_data entry ---->
		<cfif #isUser.recordcount# is 1>
			<cfquery name="upUser" datasource="#Application.uam_dbo#">
				UPDATE cf_user_data SET
					first_name = '#first_name#',
					last_name = '#last_name#',
					affiliation = '#affiliation#'
					<cfif len(#middle_name#) gt 0>
						,middle_name = '#middle_name#'
					</cfif>
					<cfif len(#email#) gt 0>
						,email = '#email#'
					</cfif>
				WHERE
					user_id = #user_id#
			</cfquery>
		</cfif>
		<cfif #isUser.recordcount# is not 1>
			<cfquery name="newUser" datasource="#Application.uam_dbo#">
				INSERT INTO cf_user_data (
					user_id,
					first_name,
					last_name,
					affiliation
					<cfif len(#middle_name#) gt 0>
						,middle_name
					</cfif>
					<cfif len(#email#) gt 0>
						,email
					</cfif>
					)
				VALUES (
					#user_id#,
					'#first_name#',
					'#last_name#',
					'#affiliation#'
					<cfif len(#middle_name#) gt 0>
						,'#middle_name#'
					</cfif>
					<cfif len(#email#) gt 0>
						,'#email#'
					</cfif>
					)
			</cfquery>
		</cfif>
	<!--- if they agree to the terms, send them to their download --->
	<cfif #agree# is "yes">
		<cfquery name="cols" datasource="#Application.web_user#">
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
		<cfquery name="getData" datasource="#Application.web_user#">
			select * from #tableName#
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

			<cfif #fileFormat# is "csv">
				<cfset fileName = "/download/ArctosData_#cfid#_#cftoken#.csv">
				<cfset header=#trim(ac)#>
				<cffile action="write" file="#fileDir##fileName#" addnewline="yes" output="#header#">
				<cfloop query="getData">
					<cfset oneLine = "">
					<cfloop list="#ac#" index="c">
						<cfset thisData = #evaluate(c)#>
						<cfif #c# is "BEGAN_DATE" or #c# is "ENDED_DATE">
							<cfset thisData=dateformat(thisData,"dd-mmm-yyyy")>
						</cfif>
						<cfif len(#oneLine#) is 0>
							<cfset oneLine = '"#thisData#"'>
						<cfelse>
							<cfset oneLine = '#oneLine#,"#thisData#"'>
						</cfif>
					</cfloop>
					<cfset oneLine = trim(oneLine)>
					<cffile action="append" file="#fileDir##fileName#" addnewline="yes" output="#oneLine#">
				</cfloop>
				<a href="#Application.serverRootUrl#/#fileName#">Right-click to save your download.</a>
				
			<cfelseif #fileFormat# is "text">
				<cfset fileName = "/download/ArctosData_#cfid#_#cftoken#.txt">
				<cfset header = replace(ac,",","#chr(9)#","all")>
				<cfset header=#trim(header)#>
				<cffile action="write" file="#fileDir##fileName#" addnewline="yes" output="#header#">
				<cfloop query="getData">
					<cfset oneLine = "">
					<cfloop list="#ac#" index="c">
						<cfset thisData = #evaluate(c)#>
						<cfif #c# is "BEGAN_DATE" or #c# is "ENDED_DATE">
							<cfset thisData=dateformat(thisData,"dd-mmm-yyyy")>
						</cfif>
						<cfif len(#oneLine#) is 0>
							<cfset oneLine = '#thisData#'>
						<cfelse>
							<cfset oneLine = '#oneLine##chr(9)##thisData#'>
						</cfif>
					</cfloop>
					<cfset oneLine = trim(oneLine)>
					<cffile action="append" file="#fileDir##fileName#" addnewline="yes" output="#oneLine#">
				</cfloop>
				<a href="#Application.serverRootUrl#/#fileName#">Right-click to save your download.</a>
			
			
			<cfelseif #fileFormat# is "xml">
				<cfset fileName = "/download/ArctosData_#cfid#_#cftoken#.xml">
				<cfset header = "<result>">
				<cffile action="write" file="#fileDir##fileName#" addnewline="no" output="#header#">
				<cfloop query="getData">
					<cfset oneLine = "<record>">
					<cfloop list="#ac#" index="c">
						<cfset thisData = #evaluate(c)#>
						<cfif #c# is "BEGAN_DATE" or #c# is "ENDED_DATE">
							<cfset thisData=dateformat(thisData,"dd-mmm-yyyy")>
						</cfif>
						<cfif len(#oneLine#) is 0>
							<cfset oneLine = '<#c#>#xmlformat(thisData)#</#c#>'>
						<cfelse>
							<cfset oneLine = '#oneLine#<#c#>#xmlformat(thisData)#</#c#>'>
						</cfif>
					</cfloop>
					<cfset oneLine = "#oneLine#</record>">
					<cfset oneLine = trim(oneLine)>
					<cffile action="append" file="#fileDir##fileName#" addnewline="no" output="#oneLine#">
				</cfloop>
				<cfset oneLine = "</result>">
				<cffile action="append" file="#fileDir##fileName#" addnewline="no" output="#oneLine#">
				<a href="#Application.serverRootUrl#/#fileName#">Right-click to save your download.</a>
			<cfelse>
				That file format doesn't seem to be supported yet!
			</cfif>
		</cfoutput>
	</cfif>
	<cfif #agree# is "no">
		<cfoutput>
		You must agree to the terms of usage to download these data.
		<ul>
			<li>Click <a href="/home.cfm">here</a> to return to the home page.</li>
			<li>Use your browser's back button or click <a href="javascript: history.back();">here</a> 
				if you wish to agree to the terms and proceed with the download.</li>
			<li>Email <a href="mailto: #Application.bugReportEmail#">#Application.bugReportEmail#</a> if you wish to discuss the terms of
				usage.</li>
		</ul>
		<br>
		<br>
		</cfoutput>
	</cfif>
</cfif>
<cfinclude template="/includes/_footer.cfm">