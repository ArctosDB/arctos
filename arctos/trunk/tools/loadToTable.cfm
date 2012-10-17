<cfinclude template="/includes/_header.cfm">
<cfsetting requesttimeout="600"> 
Upload CSV
<cfform name="atts" method="post" enctype="multipart/form-data">
	<input type="hidden" name="Action" value="getFile">
	<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
	<input type="submit" value="Upload CSV" class="savBtn">
 </cfform>


<cfoutput>
	<cfif action is "getFile">
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset numberOfColumns = ArrayLen(arrResult[1])>
	
	<cftry>
		<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			drop table #session.username#.my_temp_cf			
		</cfquery>
	<cfcatch>
		<!--- whatever --->
	</cfcatch>
	</cftry>
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				 <!---
				 <cfdump var="#arrResult[o]#">
				 --->
				 <cfset numColsRec = ArrayLen(arrResult[o])>
				<cfset thisBit=arrResult[o][i]>
				<cfif o is 1>
					<cfset thisBit=replace(thisBit," ","_","all")>
					<cfset thisBit=replace(thisBit,")","","all")>
					<cfset thisBit=replace(thisBit,"(","","all")>
					<cfset thisBit=replace(thisBit,"##","","all")>
					
					<cfset thisBit=rereplace(thisBit,"^_","")>
					<cfset thisBit=left(thisBit,28)>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset colVals="#colVals#,'#thisBit#'">
				</cfif>
			</cfloop>
		<cfif o is 1>
			<hr>
			colNames: <br>
			#colNames#
			<hr>
			<cfset colNames=replace(colNames,",","","first")>
			<cfset s='create table #session.username#.my_temp_cf ('>
			<cfset c=1>
			<cfloop list="#colNames#" index="x">
				<cfset s="#s# #x# varchar2(4000),">
			</cfloop>
			<cfset s=rereplace(s,",[^,]*$","")  & ")">
			<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				#preservesinglequotes(s)#							
			</cfquery>
		</cfif>	
		<cfif len(colVals) gt 1>
			<!--- Excel randomly and unpredictably whacks values off
				the end when they're NULL. Put NULLs back on as necessary.
				--->
			<cfset colVals=replace(colVals,",","","first")>
			<cfif numColsRec lt numberOfColumns>
				<cfset missingNumber = numberOfColumns - numColsRec>
				<cfloop from="1" to="#missingNumber#" index="c">
					<cfset colVals = "#colVals#,''">
				</cfloop>
			</cfif>
			<cfquery name="ins" datasource="uam_god">
				insert into #session.username#.my_temp_cf (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	</cfif>
	<hr>
	loaded to #session.username#.my_temp_cf
</cfoutput>
<cfinclude template="/includes/_footer.cfm">