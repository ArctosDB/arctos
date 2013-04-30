<cfinclude template="/includes/_header.cfm">
<cfset title='Nonprinting character finder'>
<cfif action is "nothing">
	<br>Upload a CSV file of agent names with one column, header "preferred_name". 
	<br>This app accepts only agent type=person; create everything else manually.
	<br>This app is a tool, not magic; you are responsible for the result.
	<br>This app only returns a file which may then be cleaned up and bulkloaded. Clean and reload as many times as necessary before
	accepting the result.
	<br>Upload a smaller file if you get a timeout.
	<br>status=found one match agents exist and do not need loaded, or match the namestring of an existing agent and need made unique.
	<br>status "did you mean...." suggestions are last-name matches. Fix your data or add an alias to the existing agent if there's a good suggestion.
	<br>status=null records will, all else being correct, probably load
	<br>seemingly conflicting status concatenations happen; create them manually if all else fails.
	<br>"...trimmed..." warnings have been fixed in the return. You'll need to fix them in your data.
	<cfform name="atts" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>
</cfif>
<cfif action is "getFile">
<cfoutput>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from ds_temp_agent_split
	</cfquery>
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset numberOfColumns = ArrayLen(arrResult[1])>
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				 <cfset numColsRec = ArrayLen(arrResult[o])>
				<cfset thisBit=arrResult[o][i]>
				<cfif #o# is 1>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset colVals="#colVals#,'#thisBit#'">
				</cfif>
			</cfloop>
		<cfif #o# is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>	
		<cfif len(colVals) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfif numColsRec lt numberOfColumns>
				<cfset missingNumber = numberOfColumns - numColsRec>
				<cfloop from="1" to="#missingNumber#" index="c">
					<cfset colVals = "#colVals#,''">
				</cfloop>
			</cfif>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into ds_temp_agent_split (#colNames#) values (#preservesinglequotes(colVals)#)				
			</cfquery>
		</cfif>
	</cfloop>
</cfoutput>
<cflocation url="agentNameSplitter.cfm?action=validate" addtoken="false">
</cfif>
<cfif action is "validate">
<cfoutput>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_agent_split where preferred_name is not null		
	</cfquery>
	<cfquery name="ctsuffix" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select suffix from ctsuffix
	</cfquery>
	<cfquery name="ctprefix" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select prefix from ctprefix
	</cfquery>
	<cfset sfxLst=valuelist(ctsuffix.suffix)>
	<cfset pfxLst=valuelist(ctprefix.prefix)>
	<cfloop query="d">
		<p>#preferred_name#</p>
		<cfset s=''>
		<cfset pfx=''>
		<cfset sfx=''>
		<cfset firstn=''>
		<cfset lastn=''>
		<cfset mdln=''>
		<cfset thisName=trim(preferred_name)>
		<cfif len(thisName) is 0>
			<cfset s=listappend(s,"preferred_name may not be blank",";")>
		</cfif>
		<cfif thisName is not preferred_name>
			<cfset s=listappend(s,"leading or trailing spaces trimmed",";")>
		</cfif>
		<cfif thisName contains "  ">
			<cfset thisName=replace(thisName,"  "," ","all")>
			<cfset s=listappend(s,"trimmed double spaces",";")>
		</cfif>
		<cfquery name="isThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select agent_id from agent_name where agent_name='#thisName#'
		</cfquery>
		<cfif isThere.recordcount is 1>
			<cfset s=listappend(s,"found #isThere.recordcount# match",";")>	
		<cfelseif isThere.recordcount gt 1>
			<cfset s=listappend(s,"found #isThere.recordcount# matches-merge or make unique",";")>
		</cfif>
		<cfloop index="i" list="#thisName#" delimiters=" ,;">
			<cfif listfindnocase(pfxLst,i)>
				<cfset pfx=i>
			</cfif>
			<cfif listfindnocase(sfxLst,i)>
				<cfset sfx=i>
			</cfif>
		</cfloop>
		<cfset tempName=thisName>
		<cfif len(pfx) gt 0>
			<cfset tempName=replace(tempName,pfx,'')>
		</cfif>
		<cfif len(sfx) gt 0>
			<cfset tempName=replace(tempName,sfx,'')>
		</cfif>
		<cfset tempName=trim(tempName)>
		<cfif right(tempName,1) is ",">
			<cfset tempName=left(tempName,len(tempName)-1)>
		</cfif>
		<cfif listlen(tempName," ") is 1>
			<cfset s=listappend(s,"will not deal with no-space agents",";")>	
		<cfelseif listlen(tempName," ") is 2>
			<cfset firstn=listFirst(tempName," ")>
			<cfset lastn=listLast(tempName," ")>
		<cfelse>
			<cfset firstn=listFirst(tempName," ")>
			<cfset lastn=listLast(tempName," ")>
			<cfset mdln=tempName>
			<cfset mdln=replace(mdln,firstn,'')>
			<cfset mdln=replace(mdln,lastn,'')>
			<cfset mdln=trim(mdln)>
		</cfif>
		<cfset ProbNotPersonClue="class,biol,alaska,california,field,station,research,summer,student,students,uaf,national,estate">
		<cfset pnap=false>
		<cfloop list="#ProbNotPersonClue#" index="i">
			<cfif listfindnocase(thisName,i," ,;-")>
				<cfset pnap=true>
			</cfif>
		</cfloop>
		<cfif refind("[A-Z][A-Z]",thisName)>
			<cfset pnap=true>
		</cfif>
		<cfif refind("[0-9]",thisName)>
			<cfset pnap=true>
		</cfif>
		<cfif pnap>
			<cfset s=listappend(s,"probably not a person",";")>
		</cfif>
		<cfif s does not contain "found">
			<cfquery name="ln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select agent_name from preferred_agent_name,person where 
				person.person_id=preferred_agent_name.agent_id and
				person.last_name='#lastn#'
				group by agent_name
			</cfquery>
			<cfif ln.recordcount gt 0>
				<cfset s=listappend(s,"did you mean any of: #valuelist(ln.agent_name,"; ")#?",";")>	
			</cfif>
		</cfif>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update ds_temp_agent_split set
				agent_type='person',
				preferred_name='#thisName#',
				first_name='#firstn#',
				middle_name='#mdln#',
				last_name='#lastn#',
				birth_date='',
				death_date='',
				prefix='#pfx#',
				suffix='#sfx#',
				other_name_1='',
				other_name_type_1='',
				other_name_2='',
				other_name_type_2='',
				other_name_3='',
				other_name_type_3='',
				agent_remark='',
				status='#s#'
			where key=#key#
		</cfquery>
	</cfloop>
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_agent_split			
	</cfquery>
	<cfset theCols=data.columnList>
	<cfset theCols=listdeleteat(theCols,listFindNoCase(theCols,"key"))>
	<script src="/includes/sorttable.js"></script>
	<table border id="t" class="sortable">
		<tr>
			<cfloop list="#theCols#" index="i">
				<th>#i#</th>
			</cfloop>
		</tr>
		<cfloop query="data">
			<tr>
				<cfloop list="#theCols#" index="i">
					<td>
						#evaluate("data." & i)#
					</td>
				</cfloop>
			</tr>
		</cfloop>
	</table>
	<a href="agentNameSplitter.cfm?action=download">[ download ]</a>
	<br><a href="agentNameSplitter.cfm?action=delete&s=foundOneMatch">[ delete all "found one match" records ]</a>
	<br><a href="agentNameSplitter.cfm?action=delete&s=pnap">[ delete all "probably not a person" records ]</a>
	
		
</cfoutput>
</cfif>
<cfif action is "delete">
	<cfif s is "foundOneMatch">
		<cfset sql="delete from ds_temp_agent_split where status like '%found 1 match%'">
	<cfelseif s is "pnap">
		<cfset sql="delete from ds_temp_agent_split where status like '%probably not a person%'">
	</cfif>
	
	<cfquery name="delete" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preserveSingleQuotes(sql)#
	</cfquery>
	<cflocation url="agentNameSplitter.cfm?action=validate" addtoken="false">
</cfif>
<cfif action is "download">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_agent_split			
	</cfquery>
	<cfset theCols=data.columnList>
	<cfset theCols=listdeleteat(theCols,listFindNoCase(theCols,"key"))>
	<cfset variables.encoding="UTF-8">
	<cfset variables.fileName="#Application.webDirectory#/download/splitAgentNames.csv">
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		variables.joFileWriter.writeLine(theCols); 
	</cfscript>
	
	<cfloop query="data">
		<cfset d=''>
		<cfloop list="#theCols#" index="i">
			<cfset t='"' & evaluate("data." & i) & '"'>
			<cfset d=listappend(d,t,",")>
		</cfloop>
		<cfscript>
			variables.joFileWriter.writeLine(d); 
		</cfscript>
	</cfloop>
	<cfscript>	
		variables.joFileWriter.close();
	</cfscript>
	<cflocation url="/download.cfm?file=splitAgentNames.csv" addtoken="false">
	<a href="/download/splitAgentNames.csv">Click here if your file does not automatically download.</a>		
</cfif>
<cfinclude template="/includes/_footer.cfm">
