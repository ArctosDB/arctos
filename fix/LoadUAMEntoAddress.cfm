<cfinclude template="/includes/_header.cfm">
<cfform name="atts" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" size="45">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>
	
	
	
	<cfif action is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	
		<cfset d = querynew("prefix,first,last,addr1,addr2,dept,inst,city,state,zip,country,phone,email")>
		
		
		
		
		
		
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
		<cfif len(last) gt 0>
			<cfquery name="isthere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
					select agent_name, agent_id from person,preferred_agent_name where
					person.person_id=preferred_agent_name.agent_id and
					upper(person.last_name)='#trim(ucase(last))#' and 
					upper(person.first_name)='#trim(ucase(first))#' 
				</cfquery>
				<cfdump var=#isThere#>
				<cfif isThere.recordcount is 0>
					<br>create everything
					<cfquery name="agentID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
						select sq_agent_id.nextval nextAgentId from dual
					</cfquery>
					<cfquery name="agentNameID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
						select sq_agent_name_id.nextval nextAgentNameId from dual
					</cfquery>		
					<cfquery name="insPerson" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
						INSERT INTO agent (
							agent_id,
							agent_type,
							preferred_agent_name_id)
						VALUES (
							#agentID.nextAgentId#,
							'person',
							#agentNameID.nextAgentNameId#
							)
					</cfquery>			
					<cfquery name="insPerson" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
						INSERT INTO person ( 
							PERSON_ID
							<cfif len(#prefix#) gt 0>
								,prefix
							</cfif>
							<cfif len(#last#) gt 0>
								,last_name
							</cfif>
							<cfif len(#first#) gt 0>
								,first_name
							</cfif>
							)
						VALUES
							(#agentID.nextAgentId#
							<cfif len(#prefix#) gt 0>
								,'#trim(prefix)#'
							</cfif>
							<cfif len(#last#) gt 0>
								,'#last#'
							</cfif>
							<cfif len(#first#) gt 0>
								,'#first#'
							</cfif>
							)
					</cfquery>
					<cfset prefName='#prefix# #first# #last#'>
					<cfset prefName=trim(prefName)>
					<cfquery name="insName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
						INSERT INTO agent_name (
							agent_name_id,
							agent_id,
							agent_name_type,
							agent_name,
							donor_card_present_fg)
						VALUES (
							#agentNameID.nextAgentNameId#,
							#agentID.nextAgentId#,
							'preferred',
							'#prefName#',
							0
							)
					</cfquery>
					<cfquery name="inssta" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
							INSERT INTO addr (
							ADDR_ID
							,STREET_ADDR1
							,STREET_ADDR2
							,institution
							,department
							,CITY
							,state
							,ZIP
						 	,COUNTRY_CDE
						 	,MAIL_STOP
						 	,agent_id
						 	,addr_type
						 	,job_title
							,valid_addr_fg
							,addr_remarks
						) VALUES (
							 sq_addr_id.nextval,
						 	<cfif len(addr1) gt 0>
								'#addr1#'
							<cfelse>
								'NOT GIVEN'
							</cfif>
						 	,'#addr2#'
						 	,'#inst#'
						 	,'#dept#'
						 	,'#city#'
						 	,'#state#'
						 	,'#ZIP#'
						 	,'#country#'
						 	,''
						 	,#agentID.nextAgentId#
						 	,'Correspondence'
						 	,''
						 	,1
						 	,'Created from UAM Insect loan data.'
						)
					</cfquery>
					<cfif len(phone) gt 0>
						<cfquery name="inssea" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
							INSERT INTO electronic_address (
								AGENT_ID
								,address_type
							 	,address	
							 ) VALUES (
								#agentID.nextAgentId#
								,'phone'
							 	,'#phone#'
							)
						</cfquery>
					</cfif>
					<cfif len(email) gt 0>
						<cfquery name="inssem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
							INSERT INTO electronic_address (
								AGENT_ID
								,address_type
							 	,address	
							 ) VALUES (
								#agentID.nextAgentId#
								,'e-mail'
							 	,'#email#'
							)
						</cfquery>
					</cfif>
				<cfelseif isThere.recordcount is 1>
					<cfquery name="inssta" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
							INSERT INTO addr (
							ADDR_ID
							,STREET_ADDR1
							,STREET_ADDR2
							,institution
							,department
							,CITY
							,state
							,ZIP
						 	,COUNTRY_CDE
						 	,MAIL_STOP
						 	,agent_id
						 	,addr_type
						 	,job_title
							,valid_addr_fg
							,addr_remarks
						) VALUES (
							 sq_addr_id.nextval,
						 	<cfif len(addr1) gt 0>
								'#addr1#'
							<cfelse>
								'NOT GIVEN'
							</cfif>
						 	,'#addr2#'
						 	,'#inst#'
						 	,'#dept#'
						 	,'#city#'
						 	,'#state#'
						 	,'#ZIP#'
						 	,'#country#'
						 	,''
						 	,#isThere.agent_id#
						 	,'Correspondence'
						 	,''
						 	,1
						 	,'Created from UAM Insect loan data.'
						)
					</cfquery>
					<cfif len(phone) gt 0>
						<cfquery name="inssea" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
							INSERT INTO electronic_address (
								AGENT_ID
								,address_type
							 	,address	
							 ) VALUES (
								#isThere.agent_id#
								,'phone'
							 	,'#phone#'
							)
						</cfquery>
					</cfif>
					<cfif len(email) gt 0>
						<cfquery name="inssem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
							INSERT INTO electronic_address (
								AGENT_ID
								,address_type
							 	,address	
							 ) VALUES (
								#isThere.agent_id#
								,'e-mail'
							 	,'#email#'
							)
						</cfquery>
					</cfif>
	
	
					
				
				<cfelse>
					<br>==========================================================================================wtf??
				</cfif>
			</cfif>
		</cfloop>
		</cftransaction>
	</cfoutput>
	</cfif>