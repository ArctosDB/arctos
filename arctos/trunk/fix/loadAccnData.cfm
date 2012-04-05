<cfabort>
<cfinclude template="/includes/_header.cfm">
<cfform name="atts" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" size="45">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>
	
	
	
	<cfif action is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	
		<cfset d = querynew("num,status,nature_of_material,how_obtained,recfrom,recfrom2,received_date,entate,remarks,entered_by")>
		
		
		
		
		
		
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset numberOfColumns = ArrayLen(arrResult[1])>
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset temp = queryaddrow(d,1)>
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				 <cfset numColsRec = ArrayLen(arrResult[o])>
				<cfset thisBit=arrResult[o][i]>
				<cfif o is 1>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset thisFieldName=listgetat(colNames,i)>
					
						<cfset temp = QuerySetCell(d, "#thisFieldName#", thisBit, o)>
					
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
			</cfif><!---
			<hr>
			insert into ds_temp_agent_split (#colNames#) values (#preservesinglequotes(colVals)#)				
			<hr>
			--->
		</cfif>
	</cfloop>
	<cftransaction>
	<cfloop query="d">
		<cfif len(num) gt 0>
			<hr>got num=#num#
			<cfquery name="isthere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
				select * from accn where accn_number='#trim(num)#'
			</cfquery>
			<cfif isThere.recordcount is 0>
				<br>make it...
				
				<cfif len(remarks) gt 4000>
					<hr>#remarks#
				</cfif>
				<cfquery name="n" datasource="user_login" username="#session.username#" password="#decrypt(session.epw,session.sessionid)#">
					select sq_transaction_id.nextval n from dual
				</cfquery>
				
						<cfset d = querynew(",,,,recfrom,recfrom2,,,remarks,entered_by")>




				<cfquery name="newTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
					INSERT INTO trans (
						TRANSACTION_ID,
						TRANS_DATE,
						CORRESP_FG,
						collection_id,
						TRANSACTION_TYPE,
						NATURE_OF_MATERIAL,
						TRANS_REMARKS,
						is_public_fg
					) VALUES (
						#n.n#,
						'#dateformat(entate,"yyyy-mm-dd")#',
						0,
						4,
						'accn',
						'#nature_of_material#',
						'#REMARKS#',
						0
					)
					</cfquery>
					
					<cfquery name="newAccn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
						INSERT INTO accn (
							TRANSACTION_ID,
							ACCN_TYPE
							,accn_number
							,RECEIVED_DATE,
							ACCN_STATUS,
							estimated_count      
							)
						VALUES (
							#n.n#,
							'#how_obtained#'
							,'#num#'
							,'#dateformat(received_date,"yyyy-mm-dd")#',
							'#status#',
								null
							)
					</cfquery>
					
					
					<cfset thisAgent=entered_by>
				<cfset thisAgent=trim(thisAgent)>
				<cfset thisAgent=replace(thisAgent,"  "," ","all")>
				
				<cfquery name="entby" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
					select agent_id from agent_name where agent_name='#thisAgent#' group by agent_id
				</cfquery>
				<cfif entby.recordcount is not 1>
					<br>=======================entered_by=#entered_by#= not found
				</cfif>
				<cfquery name="newAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
						insert into trans_agent (
							transaction_id,
							agent_id,
							trans_agent_role
						) values (
							#n.n#,
							#entby.agent_id#,
							'entered by'
						)
					</cfquery>
					
					
				
				<cfset thisAgent=recfrom>
				<cfset thisAgent=trim(thisAgent)>
				<cfset thisAgent=replace(thisAgent,"  "," ","all")>
				
				<cfquery name="qrecfrom" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
					select agent_id from agent_name where agent_name='#thisAgent#' group by agent_id
				</cfquery>
				<cfif qrecfrom.recordcount is not 1>
					<br>=======================recfrom=#recfrom#= not found
				</cfif>
				
				<cfquery name="newAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
						insert into trans_agent (
							transaction_id,
							agent_id,
							trans_agent_role
						) values (
							#n.n#,
							#qrecfrom.agent_id#,
							'received from'
						)
					</cfquery>
					
					
				
				
				<cfif len(recfrom2) gt 0>
					<cfset thisAgent=recfrom2>
					<cfset thisAgent=trim(thisAgent)>
					<cfset thisAgent=replace(thisAgent,"  "," ","all")>
					<cfquery name="qrecfrom2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
						select agent_id from agent_name where agent_name='#thisAgent#' group by agent_id
					</cfquery>
					<cfif qrecfrom2.recordcount is not 1>
						<br>=======================recfrom2=#recfrom2#= not found
					</cfif>
					
					<cfquery name="newAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
						insert into trans_agent (
							transaction_id,
							agent_id,
							trans_agent_role
						) values (
							#n.n#,
							#qrecfrom2.agent_id#,
							'received from'
						)
					</cfquery>
					
					
				</cfif>
				
				
				
				
				
				
			<cfelse>
				<hr>==============================exists============================
			</cfif>
		</cfif>
	</cfloop>
	</cftransaction>
</cfoutput>
</cfif>