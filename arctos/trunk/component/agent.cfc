<cfcomponent>	
<cffunction name="newAgentAddr" access="remote">
	<cftry>
		<cfquery name="addr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
				 sq_addr_id.nextval
			 	,'#STREET_ADDR1#'
			 	,'#STREET_ADDR2#'
			 	,'#institution#'
			 	,'#department#'
			 	,'#CITY#'
			 	,'#state#'
			 	,'#ZIP#'
			 	,'#COUNTRY_CDE#'
			 	,'#MAIL_STOP#'
			 	,#agent_id#
			 	,'#addr_type#'
			 	,'#job_title#'
			 	,#valid_addr_fg#
			 	,'#addr_remarks#'
			)
		</cfquery>
		<cfreturn "success">
	<cfcatch>
		<cfset m=cfcatch.message & ': ' & cfcatch.detail>
		<cfif isdefined("cfcatch.sql")>
			<cfset m= m & ' SQL:' & cfcatch.sql>
		</cfif>
		<cfreturn m>
	</cfcatch>
	</cftry>
</cffunction>	
<!---------------------------------------------------------------->
<cffunction name="deleteAgentAddrEdit" access="remote">
	<cftry>
		<cfquery name="editAddr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from addr where addr_id=#addr_id#
		</cfquery>
		<cfreturn "success">
	<cfcatch>
		<cfset m=cfcatch.message & ': ' & cfcatch.detail>
		<cfif isdefined("cfcatch.sql")>
			<cfset m= m & ' SQL:' & cfcatch.sql>
		</cfif>
		<cfreturn m>
	</cfcatch>
	</cftry>
</cffunction>
<!---------------------------------------------------------------->
<cffunction name="saveAgentAddrEdit" access="remote">
	<cftry>
		<cfquery name="editAddr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			UPDATE addr SET 
				STREET_ADDR1 = '#STREET_ADDR1#'
				,STREET_ADDR2 = '#STREET_ADDR2#'
				,department = '#department#'
				,institution = '#institution#'
				,CITY = '#CITY#'
				,STATE = '#STATE#'
				,ZIP = '#ZIP#'
				,COUNTRY_CDE = '#COUNTRY_CDE#'
				,MAIL_STOP = '#MAIL_STOP#'
				,ADDR_TYPE = '#ADDR_TYPE#'
				,JOB_TITLE = '#JOB_TITLE#'
				,VALID_ADDR_FG = '#VALID_ADDR_FG#'
				,ADDR_REMARKS = '#ADDR_REMARKS#'
			where addr_id=#addr_id#
		</cfquery>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select 
				'success' status, 
				addr_id, 
				formatted_addr, 
				decode(VALID_ADDR_FG,0,'invalid','valid') VALID_ADDR_FG,
				ADDR_TYPE
			from addr where addr_id=#addr_id#
		</cfquery>	
		<cfreturn d>
	<cfcatch>
		<cfset m=cfcatch.message & ': ' & cfcatch.detail>
		<cfif isdefined("cfcatch.sql")>
			<cfset m= m & ' SQL:' & cfcatch.sql>
		</cfif>
		<cfset d = querynew("status,msg")>
		<cfset temp = queryaddrow(d,1)>
		<cfset temp = QuerySetCell(d, "status", "fail",1)>
		<cfset temp = QuerySetCell(d, "msg", m,1)>
		<cfreturn d>
	</cfcatch>
	</cftry>
</cffunction>
<!---------------------------------------------------------------->
<cffunction name="saveAgent" access="remote">
	<cfif not isdefined("escapeQuotes")>
		<cfinclude template="/includes/functionLib.cfm">
	</cfif>
	<cfoutput>
		<cftry>
			<cftransaction>
				<!--- agent --->
				<cfquery name="updateAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					UPDATE agent SET 
						agent_remarks = '#escapeQuotes(agent_remarks)#',
						agent_type='#agent_type#',
						preferred_agent_name='#escapeQuotes(preferred_agent_name)#'
					WHERE
						agent_id = #agent_id#
				</cfquery>
				<!---- agent names --->
				<cfloop list="#structKeyList(url)#" index="key">
					<cfif left(key,16) is "agent_name_type_">
						<cfset thisAgentNameID=listlast(key,"_")>
						<cfset thisAgentNameType=url["agent_name_type_#thisAgentNameID#"]>
						<cfset thisAgentName=url["agent_name_#thisAgentNameID#"]>
						<cfif thisAgentNameID contains "new">
							<cfif len(thisAgentName) gt 0>
								<cfquery name="nan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
									INSERT INTO agent_name (
										agent_name_id,
										agent_id,
										agent_name_type,
										agent_name
									) VALUES (
										sq_agent_name_id.nextval,
										<cfqueryparam value = "#agent_ID#" CFSQLType = "CF_SQL_INTEGER">,
										'#thisAgentNameType#',
										'#escapeQuotes(thisAgentName)#'
									)
								</cfquery>
							</cfif>
						<cfelseif thisAgentNameType is "DELETE">
							<cfquery name="nan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								delete from agent_name where agent_name_id=<cfqueryparam value = "#thisAgentNameID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						<cfelse>
							<cfquery name="nan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								update 
									agent_name 
								set 
									agent_name='#escapeQuotes(thisAgentName)#',
									agent_name_type='#thisAgentNameType#'
								where agent_name_id=<cfqueryparam value = "#thisAgentNameID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						</cfif>
					</cfif>
				</cfloop>
				<!---- relationships ---->
				<cfloop list="#structKeyList(url)#" index="key">
					<cfif left(key,19) is "agent_relationship_">
						<cfset thisAgentRelationsID=listlast(key,"_")>
						<cfset thisAgentRelationship=url["agent_relationship_#thisAgentRelationsID#"]>
						<cfset thisRelatedAgentName=url["related_agent_#thisAgentRelationsID#"]>
						<cfset thisRelatedAgentID=url["related_agent_id_#thisAgentRelationsID#"]>
						<cfif thisAgentRelationsID contains "new">
							<cfif len(thisAgentRelationship) gt 0>
								<cfquery name="newReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
									INSERT INTO agent_relations (
										AGENT_ID,
										RELATED_AGENT_ID,
										AGENT_RELATIONSHIP)
									VALUES (
										<cfqueryparam value = "#agent_id#" CFSQLType = "CF_SQL_INTEGER">,
										<cfqueryparam value = "#thisRelatedAgentID#" CFSQLType = "CF_SQL_INTEGER">,
										'#thisAgentRelationship#')		  
								</cfquery>
							</cfif>
						<cfelseif thisAgentRelationship is "DELETE">
							<cfquery name="killRel" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								delete from agent_relations where agent_relations_id=<cfqueryparam value = "#thisAgentRelationsID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						<cfelse>
							<cfquery name="changeRelated" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								UPDATE agent_relations SET
									related_agent_id = <cfqueryparam value = "#thisRelatedAgentID#" CFSQLType = "CF_SQL_INTEGER">,
									agent_relationship='#thisAgentRelationship#'
								WHERE AGENT_RELATIONS_ID=<cfqueryparam value = "#thisAgentRelationsID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						</cfif>
					</cfif>
				</cfloop>
			
				<!---- group members ---->
				<cfloop list="#structKeyList(url)#" index="key">
					<cfif left(key,16) is "member_agent_id_">
						<cfset thisGroupMemberID=listlast(key,"_")>
						<cfset thisMemberAgentID=url["member_agent_id_#thisGroupMemberID#"]>
						<cfset thisMemberAgentName=url["group_member_#thisGroupMemberID#"]>
						<cfif thisGroupMemberID contains "new">
							<cfif len(thisMemberAgentID) gt 0>
								<cfquery name="newReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
									INSERT INTO group_member (
										GROUP_AGENT_ID,
										MEMBER_AGENT_ID)
									VALUES (
										<cfqueryparam value = "#agent_id#" CFSQLType = "CF_SQL_INTEGER">,
										<cfqueryparam value = "#thisMemberAgentID#" CFSQLType = "CF_SQL_INTEGER">
									)		  
								</cfquery>
							</cfif>
						<cfelseif thisMemberAgentName is "DELETE">
							<cfquery name="killRel" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								delete from group_member where GROUP_MEMBER_ID=<cfqueryparam value = "#thisGroupMemberID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						<cfelse>
							<cfquery name="changeRelated" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								UPDATE group_member SET
									MEMBER_AGENT_ID = <cfqueryparam value = "#thisMemberAgentID#" CFSQLType = "CF_SQL_INTEGER">
								WHERE GROUP_MEMBER_ID=<cfqueryparam value = "#thisGroupMemberID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						</cfif>
					</cfif>
				</cfloop>
				<!---- status ---->
				<cfloop list="#structKeyList(url)#" index="key">
					<cfif left(key,13) is "agent_status_">
						<cfset thisAgentStatusID=listlast(key,"_")>
						<cfset thisAgentStatus=url["agent_status_#thisAgentStatusID#"]>
						<cfset thisAgentStatusDate=url["status_date_#thisAgentStatusID#"]>
						<cfset thisAgentStatusRemark=url["status_remark_#thisAgentStatusID#"]>
						<cfif thisAgentStatusID contains "new">
							<cfif len(thisAgentStatus) gt 0>
								<cfquery name="newStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
									insert into agent_status (
										AGENT_STATUS_ID,
										AGENT_ID,
										AGENT_STATUS,
										STATUS_DATE,
										STATUS_REMARK
									) values (
										sq_AGENT_STATUS_ID.nextval,
										#agent_id#,
										'#thisAgentStatus#',
										'#thisAgentStatusDate#',
										'#escapequotes(thisAgentStatusRemark)#'
									)
								</cfquery>
							</cfif>
						<cfelseif thisAgentStatus is "DELETE">
							<cfquery name="newStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								delete from  agent_status where agent_status_id=<cfqueryparam value = "#thisAgentStatusID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						<cfelse>
							<cfquery name="newStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								update agent_status 
								set
									AGENT_STATUS='#thisAgentStatus#',
									STATUS_DATE='#thisAgentStatusDate#',
									STATUS_REMARK='#escapequotes(thisAgentStatusRemark)#'
								where AGENT_STATUS_ID=<cfqueryparam value = "#thisAgentStatusID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						</cfif>
					</cfif>
				</cfloop>
				<cfloop list="#structKeyList(url)#" index="key">
					<cfif left(key,24) is "electronic_address_type_">
						<cfset thisElectronicAddressID=listlast(key,"_")>
						<cfset thisElectronicAddressType=url["electronic_address_type_#thisElectronicAddressID#"]>
						<cfset thisElectronicAddress=url["electronic_address_#thisElectronicAddressID#"]>
						<cfif thisElectronicAddressID contains "new">
							<cfif len(thisElectronicAddressType) gt 0>
								<cfquery name="elecaddr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
									INSERT INTO electronic_address (
										AGENT_ID
										,address_type
									 	,address	
									 ) VALUES (
										<cfqueryparam value = "#agent_ID#" CFSQLType = "CF_SQL_INTEGER">
										,'#thisElectronicAddressType#'
									 	,'#thisElectronicAddress#'
									)
								</cfquery>
							</cfif>
						<cfelseif thisElectronicAddressType is "DELETE">
							<cfquery name="newStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								delete from  electronic_address where electronic_address_id=<cfqueryparam value = "#thisElectronicAddressID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						<cfelse>						
							<cfquery name="newStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								update electronic_address 
								set
									address_type='#thisElectronicAddressType#',
									address='#thisElectronicAddress#'
								where
									electronic_address_id=<cfqueryparam value = "#thisElectronicAddressID#" CFSQLType = "CF_SQL_INTEGER">
							</cfquery>
						</cfif>
					</cfif>
				</cfloop>
			</cftransaction>
		<cfreturn "success">
		<cfcatch>
			<cf_logError subject="error caught: saveAgent" attributeCollection=#cfcatch#>
			<cfset m=cfcatch.message & ': ' & cfcatch.detail>
			<cfif isdefined("cfcatch.sql")>
				<cfset m= m & ' SQL:' & cfcatch.sql>
			</cfif>
			<cfreturn m>
		</cfcatch>
		</cftry>
	</cfoutput>
</cffunction>
<!---------------------------------------------------------------->
<cffunction name="findAgents" access="remote">
	<cfoutput>
	<cfif not isdefined("escapeQuotes")>
		<cfinclude template="/includes/functionLib.cfm">
	</cfif>	
	<cfset sql = "SELECT 
					agent.agent_id,
					agent.preferred_agent_name,
					agent.agent_type
				FROM 
					agent,
					agent_name,
					agent_status
				WHERE 
					agent.agent_id=agent_name.agent_id (+) and
					agent.agent_id=agent_status.agent_id (+) and
					agent.agent_id > -1
					">
	<cfset srch=false>
	<cfif isdefined("anyName") AND len(anyName) gt 0>
		<cfset srch=true>
		<cfset sql = "#sql# AND upper(agent_name.agent_name) like '%#trim(ucase(escapeQuotes(anyName)))#%'">
	</cfif>
	<cfif isdefined("agent_id") AND isnumeric(agent_id)>
		<cfset srch=true>
		<cfset sql = "#sql# AND agent.agent_id = #agent_id#">
	</cfif>
	<cfif isdefined("status_date") AND len(status_date) gt 0>
		<cfset srch=true>
		<cfset sql = "#sql# AND status_date #status_date_oper# '#status_date#'">
	</cfif>
	<cfif isdefined("agent_status") AND len(agent_status) gt 0>
		<cfset srch=true>
		<cfset sql = "#sql# AND agent_status='#agent_status#'">
	</cfif>			
	<cfif isdefined("address") AND len(address) gt 0>
		<cfset srch=true>
		<cfset sql = "#sql# AND agent.agent_id IN (select agent_id from addr where upper(formatted_addr) like '%#ucase(address)#%')">
	</cfif>
	<cfif isdefined("agent_name_type") AND len(agent_name_type) gt 0>
		<cfset sql = "#sql# AND agent_name_type='#agent_name_type#'">
	</cfif>
	<cfif isdefined("agent_type") AND len(agent_type) gt 0>
		<cfset sql = "#sql# AND agent.agent_type='#agent_type#'">
	</cfif>
	<cfif isdefined("agent_name") AND len(agent_name) gt 0>
		<cfset srch=true>
		<cfset sql = "#sql# AND upper(agent_name.agent_name) like '%#ucase(escapeQuotes(agent_name))#%'">
	</cfif>
	<cfif isdefined("created_by") AND len(created_by) gt 0>
		<cfset srch=true>
		<cfset sql = "#sql# AND agent.created_by_agent_id in (select agent_id from agent_name where upper(agent_name.agent_name) like '%#ucase(escapeQuotes(created_by))#%')">
	</cfif>
	
	<cfif isdefined("created_date") AND len(created_date) gt 0>
		<cfset srch=true>
		<cfif len(created_date) is 4>
			<cfset filter='YYYY'>
		<cfelseif len(created_date) is 7>
			<cfset filter='YYYY-MM'>
		<cfelseif len(created_date) is 10>
			<cfset filter='YYYY-MM-DD'>
		<cfelse>
			<cfreturn 'error: Search created date as YYYY, YYYY-MM, YYYY-MM-DD'>
		</cfif>
		<cfset sql = "#sql# AND to_char(CREATED_DATE,'#filter#') #create_date_oper# '#created_date#'">
	</cfif>
	<cfset sql = "#sql# GROUP BY  agent.agent_id,
						agent.preferred_agent_name,
						agent.agent_type">
	<cfset sql = "#sql# ORDER BY agent.preferred_agent_name">
	<cfif srch is false>
		<cfreturn 'error: You must provide criteria to search.'>
	</cfif>
	<cfquery name="getAgents" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfreturn getAgents>
</cfoutput>
</cffunction>
<!-------------------------------------------------------------------------------->
<cffunction name="checkAgent" access="remote" returnformat="json">
   	<cfargument name="preferred_name" required="true" type="string">
   	<cfargument name="agent_type" required="true" type="string">
   	<cfargument name="first_name" required="false" type="string" default="">
   	<cfargument name="middle_name" required="false" type="string" default="">
   	<cfargument name="last_name" required="false" type="string" default="">
	<cfif not isdefined("escapeQuotes")>
		<cfinclude template="/includes/functionLib.cfm">
	</cfif>
	<cfif agent_type is "person">
		<cfquery name="CTPREFIX" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select prefix from CTPREFIX
		</cfquery>
		<cfquery name="CTsuffix" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select suffix from CTsuffix
		</cfquery>
		<cfset regexStripJunk='[ .,-]'>
		<cfset problems="">
		<!--- list of terms that PROBABLY should not appear in agent names ---->
		<cfset disallowPersons="Animal,al,alaska,and,Anonymous">
		<cfset disallowPersons=disallowPersons & ",biol,biology">
		<cfset disallowPersons=disallowPersons & ",Class,california,company,co.,Club,center">
		<cfset disallowPersons=disallowPersons & ",Ecology,et,estate">
		<cfset disallowPersons=disallowPersons & ",field">
		<cfset disallowPersons=disallowPersons & ",Group,Growth">
		<cfset disallowPersons=disallowPersons & ",Hospital,hunter">
		<cfset disallowPersons=disallowPersons & ",illegible,inc">
		<cfset disallowPersons=disallowPersons & ",Lab">
		<cfset disallowPersons=disallowPersons & ",Management,Museum">
		<cfset disallowPersons=disallowPersons & ",National,native">
		<cfset disallowPersons=disallowPersons & ",Old,other">
		<cfset disallowPersons=disallowPersons & ",Rangers,Ranger,research">
		<cfset disallowPersons=disallowPersons & ",Predatory,Project,Puffin">
		<cfset disallowPersons=disallowPersons & ",Sanctuary,Science,Seabird,Society,Study,student,students,station,summer,shop,service,store,system">
		<cfset disallowPersons=disallowPersons & ",the">
		<cfset disallowPersons=disallowPersons & ",University,uaf">
		<cfset disallowPersons=disallowPersons & ",various">
		<cfset disallowPersons=disallowPersons & ",Zoological,zoo">
		<!---- 
			random lists of things may be indicitave of garbage. 
				disallowWords are " me AND you" but not "ANDy"
				disallowCharacters are just that "me/you" and me /  you" and ....	
			Expect some false positives - sorray! 
		---->
		<cfset disallowWords="and,or,cat">
		<cfset disallowCharacters="/,\,&">
		<cfset strippedUpperFML=ucase(rereplace(first_name & middle_name & last_name,regexStripJunk,"","all"))>
		<cfset strippedUpperFL=ucase(rereplace(first_name & last_name,regexStripJunk,"","all"))>
		<cfset strippedUpperLF=ucase(rereplace(last_name & first_name,regexStripJunk,"","all"))>
		<cfset strippedUpperLFM=ucase(rereplace(last_name & first_name & middle_name,regexStripJunk,"","all"))>
		<cfset strippedP=ucase(rereplace(preferred_name,regexStripJunk,"","all"))>
		<cfset strippedNamePermutations=strippedP>
		<cfset strippedNamePermutations=listappend(strippedNamePermutations,strippedUpperFML)>
		<cfset strippedNamePermutations=listappend(strippedNamePermutations,strippedUpperFL)>
		<cfset strippedNamePermutations=listappend(strippedNamePermutations,strippedUpperLF)>
		<cfset strippedNamePermutations=listappend(strippedNamePermutations,strippedUpperLFM)>
		<cfset strippedNamePermutations=listappend(strippedNamePermutations,strippedP)>
		<cfif len(strippedNamePermutations) is 0>
			<cfset problems=listappend(problems,'Check apostrophy/single-quote. "O&apos;Neil" is fine. "Jim&apos;s Cat" should be entered as "unknown".',';')>
		</cfif>
				
		<cfloop list="#disallowCharacters#" index="i">
			<cfif preferred_name contains i>
				<cfset problems=listappend(problems,'Check name for #i#: do not create unnecessary variations of "unknown."',';')>
			</cfif>
		</cfloop>
				
		<cfloop list="#disallowWords#" index="i">
			<cfif listfindnocase(preferred_name,i," ;,.")>
				<cfset problems=listappend(problems,'Check name for #i#: do not create unnecessary variations of "unknown."',';')>
			</cfif>
		</cfloop>
		<cfif agent_type is "person">
			<cfloop list="#disallowPersons#" index="i">
				<cfif listfindnocase(preferred_name,i,"() ;,.")>
					<cfset problems=listappend(problems,'Check name for #i#: do not create non-person agents as persons."',';')>
				</cfif>
			</cfloop>
		</cfif>
		<!--- try to avoid unnecessary acronyms --->
		<cfif refind('[A-Z]{3,}',preferred_name) gt 0>
			<cfset problems=listappend(problems,'Check for abbreviations and acronyms. do not create unnecessary variations of "unknown."',';')>
		</cfif>
		<cfif Compare(ucase(preferred_name), preferred_name) is 0 or Compare(lcase(preferred_name), preferred_name) is 0>
			<cfset problems=listappend(problems,'Check for abbreviations and acronyms. Do not create unnecessary variations of "unknown."',';')>
		</cfif>
		<cfif preferred_name does not contain " ">
			<cfset problems=listappend(problems,'Check for abbreviations and acronyms. Do not create unnecessary variations of "unknown."',';')>
		</cfif>
		<cfif preferred_name contains ".">
			<cfset problems=listappend(problems,'Check for abbreviations and acronyms. Do not create unnecessary variations of "unknown."',';')>
		</cfif>
		<cfset strippedNamePermutations=trim(escapeQuotes(strippedNamePermutations))>	
		<cfset strippedNamePermutations=ListQualify(strippedNamePermutations,"'")>	
		<!--- if we did not get a first or last name passed in, try to guess from the preferred name string ---->
		<cfset srchFirstName=first_name>
		<cfset srchMiddleName=middle_name>
		<cfset srchLastName=last_name>
		<cfif len(first_name) is 0 or len(last_name) is 0 or len(middle_name) is 0>
			<cfset x=splitAgentName(preferred_name)>
			<cfif len(first_name) is 0 and len(x.first) gt 0>
				<cfset srchFirstName=x.first>
			</cfif>
			<cfif len(middle_name) is 0 and len(x.middle) gt 0>
				<cfset srchMiddleName=x.middle>
			</cfif>
			<cfif len(last_name) is 0 and len(x.last) gt 0>
				<cfset srchLastName=x.last>
			</cfif>
			<cfif len(x.formatted_name) gt 0>
				<cfset schFormattedName=trim(escapeQuotes(x.formatted_name))>
			</cfif>
		</cfif>
		<cfset srchFirstName=trim(escapeQuotes(srchFirstName))>
		<cfset srchMiddleName=trim(escapeQuotes(srchMiddleName))>
		<cfset srchLastName=trim(escapeQuotes(srchLastName))>
		<cfset srchPrefName=trim(escapeQuotes(preferred_name))>
		
		<cfset nvars=ArrayNew(1)>
		
		<cfset temp=ArrayAppend(nvars, 'Abraham,Abe')>
		<cfset temp=ArrayAppend(nvars, 'Albert,Al,Bert,Alfred,Alonzo')>
		<cfset temp=ArrayAppend(nvars, 'Alexandria,Alexandra,Sandy,Sasha,Cassandra,Cassie,Cassy,Alexander,Alec,Alex,Sasha')>
		<cfset temp=ArrayAppend(nvars, 'Allen,Alan,Al')>
		<cfset temp=ArrayAppend(nvars, 'Amanda,Manda,Mandy')>
		<cfset temp=ArrayAppend(nvars, 'Amos,Moses')>
		<cfset temp=ArrayAppend(nvars, 'Andrew,Andy,Drew')>
		<cfset temp=ArrayAppend(nvars, 'Angela,Angie')>
		<cfset temp=ArrayAppend(nvars, 'Anna,Ann,Anna,Hannah,Anne,Annie')>
		<cfset temp=ArrayAppend(nvars, 'Anthony,Tony')>
		<cfset temp=ArrayAppend(nvars, 'Arthur,Art,Arturo,Artie')>
		
		<cfset temp=ArrayAppend(nvars, 'Barbara,Barb,Barby,Barbie,Babs')>
		<cfset temp=ArrayAppend(nvars, 'Barnabas,Barnard,Bernard,Bernie,Berny')>
		<cfset temp=ArrayAppend(nvars, 'Bartholomew,Bart')>
		<cfset temp=ArrayAppend(nvars, 'Benjamin,Ben,Benny')>
		<cfset temp=ArrayAppend(nvars, 'Beverly,Bev')>
		<cfset temp=ArrayAppend(nvars, 'Bradford,Brad,Bradly')>
		<cfset temp=ArrayAppend(nvars, 'Brian,Bryan,Bryant')>
		
		<cfset temp=ArrayAppend(nvars, 'Caleb,Cal')>
		<cfset temp=ArrayAppend(nvars, 'Charles,Charlie,Charley,Chuck,Chaz')>
		<cfset temp=ArrayAppend(nvars, 'Christopher,Chris')>
		<cfset temp=ArrayAppend(nvars, 'Curtis,Curt,Kurtis,Kurt')>
		<cfset temp=ArrayAppend(nvars, 'Cynthia,Cindi,Cindy')>
		<cfset temp=ArrayAppend(nvars, 'Carolyn,Carol,Carrie,Cary')>
		
		<cfset temp=ArrayAppend(nvars, 'Daniel,Dan,Danny')>
		<cfset temp=ArrayAppend(nvars, 'Danielle,Danelle')>
		<cfset temp=ArrayAppend(nvars, 'David,Dave,Davey')>
		<cfset temp=ArrayAppend(nvars, 'Deborah,Deb,Debbie,Debby,Debra')>
		<cfset temp=ArrayAppend(nvars, 'Dennis,Denny')>
		<cfset temp=ArrayAppend(nvars, 'Donald,Don,Donny')>
		<cfset temp=ArrayAppend(nvars, 'Douglas,Doug')>
		<cfset temp=ArrayAppend(nvars, 'Dorothy,Dot,Dottie')>
		<cfset temp=ArrayAppend(nvars, 'Duane,Dewayne,Dwayne,Dwane')>
		<cfset temp=ArrayAppend(nvars, 'Dusty,Dustin')>
		
		<cfset temp=ArrayAppend(nvars, 'Earnest,Ernest,Erny,Ernie')>
		<cfset temp=ArrayAppend(nvars, 'Edmund,Edward,Ed,Edgar,Eddy,Eddie,Edwin,Ted')>
		<cfset temp=ArrayAppend(nvars, 'Egbert,Bert,Burt')>
		<cfset temp=ArrayAppend(nvars, 'Elaine,Eleanor')>
		<cfset temp=ArrayAppend(nvars, 'Elizabeth,Liz,Beth,Betty')>
		<cfset temp=ArrayAppend(nvars, 'Eugene,Gene')>
		
		<cfset temp=ArrayAppend(nvars, 'Frank,Franklin,Frances')>
		
		<cfset temp=ArrayAppend(nvars, 'Gabriel,Gabe,Gabby,Gabbie')>
		<cfset temp=ArrayAppend(nvars, 'George,Jorge')>
		<cfset temp=ArrayAppend(nvars, 'Gerald,Jerry,Gerry')>
		<cfset temp=ArrayAppend(nvars, 'Gregory,Greg,Gregg')>
		
		<cfset temp=ArrayAppend(nvars, 'Howard,Hal,Howie')>
		
		<cfset temp=ArrayAppend(nvars, 'Irwin,Erwin')>
		
		<cfset temp=ArrayAppend(nvars, 'Jacob,Jake,Jakob')>
		<cfset temp=ArrayAppend(nvars, 'Jacqueline,Jacky,Jackie,Jaclyn,Jacklyn')>
		<cfset temp=ArrayAppend(nvars, 'James,Jamie,Jamey,Jim,Jimmy,Jimmie,Jay')>
		<cfset temp=ArrayAppend(nvars, 'Janet,Jan')>
		<cfset temp=ArrayAppend(nvars, 'Jeffrey,Joffrey,Jeff,Joff')>
		<cfset temp=ArrayAppend(nvars, 'Jennifer,Jenny,Jennie')>
		<cfset temp=ArrayAppend(nvars, 'Jessica,Jess,Jesse,Jessy,Jessie')>
		<cfset temp=ArrayAppend(nvars, 'John,Jon,Hans,Ian,Ivan,Jack,Jan,Jean,Jaques,Jock,Johnathan,Jonathan,Johnny,Jonny')>
		<cfset temp=ArrayAppend(nvars, 'Joseph,Joe,Jose,Joey')>
		<cfset temp=ArrayAppend(nvars, 'Joshua,Josh')>
		<cfset temp=ArrayAppend(nvars, 'Joyce,Joy')>
		<cfset temp=ArrayAppend(nvars, 'Judith,Judy')>
		
		<cfset temp=ArrayAppend(nvars, 'Katherine,Katarina,Kathleen,Cathy,Kat,Kitty,Kate,Katy,Katie,Kayey,Kathy,Kathey,Kit,Cathleen,Catherine,Kathryn,Katherina,Kathe,Katrina')>
		<cfset temp=ArrayAppend(nvars, 'Kenneth,Ken,Kenney,Kenny')>
		<cfset temp=ArrayAppend(nvars, 'Kimberly,Kimberly,Kimberlee,Kim,Kym,Kimmy,Kimmie')>
		
		<cfset temp=ArrayAppend(nvars, 'Lauryn,Laurie,Lorrie')>
		<cfset temp=ArrayAppend(nvars, 'Leonard,Leo,Leon,Len,Lenny,Lennie,Lineau,Lenhart')>
		<cfset temp=ArrayAppend(nvars, 'Leroy,Lee,Roy')>
		<cfset temp=ArrayAppend(nvars, 'Leslie,Les,Lester')>
		<cfset temp=ArrayAppend(nvars, 'Lillian,Lil,Lilly,Lillie')>
		<cfset temp=ArrayAppend(nvars, 'Lincoln,Link')>
		<cfset temp=ArrayAppend(nvars, 'Linda,Lynn,Lynette,Linette')>
		<cfset temp=ArrayAppend(nvars, 'Lois,Louise')>
		<cfset temp=ArrayAppend(nvars, 'Louis,Lewis,Lou,Louie')>
		
		<cfset temp=ArrayAppend(nvars, 'Margaret,Maggy,Maggie,Marge,Peg,Peggy,Peggie')>
		<cfset temp=ArrayAppend(nvars, 'Matthew,Matt,Matthias')>
		<cfset temp=ArrayAppend(nvars, 'Michael,Mickey,Micky,Mike,Mitchell,Micah,Mick')>
		<cfset temp=ArrayAppend(nvars, 'Michelle,Mickey,Micky,Shelley,Shelly')>
		<cfset temp=ArrayAppend(nvars, 'Megan,Meg')>
		
		<cfset temp=ArrayAppend(nvars, 'Nicholas,Nick,Nicky,Nico')>
		<cfset temp=ArrayAppend(nvars, 'Nathan,Nathaniel,Nat,Nate')>
		
		<cfset temp=ArrayAppend(nvars, 'Pamela,Pam')>
		<cfset temp=ArrayAppend(nvars, 'Patricia,Pat,Tricia,Patsy,Patsie,Pattie,Patty,Trixie,Trixi,Trixy,Trish,Tish')>
		<cfset temp=ArrayAppend(nvars, 'Patrick,Paddie,Paddy,Paddey,Pat,Patsie,Patsy,Peter,Patricia,Pate')>
		<cfset temp=ArrayAppend(nvars, 'Paulina,Paula,Pollie,Polly,Lina,Pauline')>
		<cfset temp=ArrayAppend(nvars, 'Peter,Pete,Petey,Pate')>
		
		<cfset temp=ArrayAppend(nvars, 'Rebecca,Becka,Becky')>
		<cfset temp=ArrayAppend(nvars, 'Richard,Dick,Rich,Rick,Richey,Dickon,Dickson,Ricky,Rickey')>
		<cfset temp=ArrayAppend(nvars, 'Robert,Dob,Dobbin,Bob,Bobby,Bobbie,Rob,Robin,Rupert,Hob,Hobkin,Robbie,Robby')>
		<cfset temp=ArrayAppend(nvars, 'Rodney,Rod,Ronald')>
		<cfset temp=ArrayAppend(nvars, 'Raymond,Ray')>
		
		<cfset temp=ArrayAppend(nvars, 'Samuel,Sam,Sammy,Sammey,Samantha,Samson')>
		<cfset temp=ArrayAppend(nvars, 'Sharon,Sharyn,Sharrey,Sharrie,Sharry,Shar,Sharey,Sharie,Sheron,Sheryn,Sheryl,Cheryl')>
		<cfset temp=ArrayAppend(nvars, 'Shaun,Sean,Shawn,Shane,Shayne')>
		<cfset temp=ArrayAppend(nvars, 'Stephen,Steve,Steven')>
		<cfset temp=ArrayAppend(nvars, 'Stephanie,Steph,Steffi,Stephy,Steffy')>
		<cfset temp=ArrayAppend(nvars, 'Susan,Sue,Susie,Suzy')>
		
		
		<cfset temp=ArrayAppend(nvars, 'Theodore,Ted,Theodrick,Theodorick,Tad,Theo,Teddy,Teddie')>
		<cfset temp=ArrayAppend(nvars, 'Theresa,Therese,Terry,Terrie,Tess Tessy,Tessie,Thursa,Teresa,Thirsa,Tessa')>
		<cfset temp=ArrayAppend(nvars, 'Thomas,Thom,Tom,Tommy,Tommie')>
		<cfset temp=ArrayAppend(nvars, 'Timothy,Tim,Timmy,Timmey,Timmie')>
		<cfset temp=ArrayAppend(nvars, 'Vanessa,,Nessa,Vanna')>
		<cfset temp=ArrayAppend(nvars, 'Victor,Vic.Vick')>
		<cfset temp=ArrayAppend(nvars, 'Victoria,Vickie,Vickey,Vicky')>
		<cfset temp=ArrayAppend(nvars, 'Vincent,Vin,Vince,Vinnie,Vinny')>
		<cfset temp=ArrayAppend(nvars, 'Virgil,Virg')>
		<cfset temp=ArrayAppend(nvars, 'Walter,Walt')>
		<cfset temp=ArrayAppend(nvars, 'Wesley,Wes')>
		<cfset temp=ArrayAppend(nvars, 'Wilber,Will,Wilbert')>
		<cfset temp=ArrayAppend(nvars, 'William,Bill,Will,Willy,Willie,Billy,Billie,Bell,Bela,Willie,WIlly,Wilhelm,Willis')>
		
		<cfset temp=ArrayAppend(nvars, 'Virginia,Ginger,Ginny,Jane,Jenni,Jenny,Gina')>
		<cfset temp=ArrayAppend(nvars, 'Yolanda,Yolonda')>
		
		<cfset temp=ArrayAppend(nvars, 'Zachariah,Zach,Zacharias,Zachary,Zeke')>
		<cfset temp=ArrayAppend(nvars, 'Zebedee,Zebulon,Zeb')>
		    
		
		<cfset sqlinlist="">
		
		<!--- try to find name variants in preferred name ---->
		<cfset fnOPN=listgetat(srchPrefName,1,' ,;')>
		<cfset restOPN=trim(replace(srchPrefName,fnOPN,''))>

		<cfloop array="#nvars#" index="p">
			<cfif listfindnocase(p,fnopn)>
				<cfset varnts=p>
				<cfset varnts=listdeleteat(varnts,listfindnocase(p,fnopn))>
				<cfset sqlinlist=listappend(sqlinlist,varnts)>
				<!----
				<cfloop list="#varnts#" index="f">
					<cfset sqlinlist=listappend(sqlinlist,"#f# #restOPN#")>
				</cfloop>
				---->
			</cfif>
		</cfloop>
		
			
		<cfset sqlinlist=ucase(sqlinlist)>
		
		<cfdump var=#sqlinlist#>
		<cfabort>
		<!--- nocase preferred name match ---->	
		<cfset sql="select 
						'nocase preferred name match' reason,
				        agent.agent_id, 
				        agent.preferred_agent_name
					from 
				        agent
					where 
				        trim(upper(agent.preferred_agent_name))=trim(upper('#srchPrefName#'))">
		<cfset sql="select 
						'exact preferred name match' reason,
				        agent.agent_id, 
				        agent.preferred_agent_name
					from 
				        agent
					where 
				        agent.preferred_agent_name='#srchPrefName#'">	
		<cfif isdefined("schFormattedName") and len(schFormattedName) gt 0>
			<cfset sql=sql & "
				 union select
					'nodots-nospaces match on agent name' reason,
					 agent.agent_id, 
					 agent.preferred_agent_name
				from 
					agent,
					agent_name
				where 
				    agent.agent_id=agent_name.agent_id and
					upper(agent_name.agent_name) like '%#ucase(schFormattedName)#%'">	     
		</cfif>
		<cfif isdefined("sqlinlist") and len(sqlinlist) gt 0 and listlen(sqlinlist) lt 1000>
			<cfset sql=sql & "
				union select 
						'nocase name variant match' reason,
				        agent.agent_id, 
				        agent.preferred_agent_name
					from 
				        agent,
				        agent_name
					where 
				        agent.agent_id=agent_name.agent_id and
				        upper(agent_name.agent_name) in (#listqualify(sqlinlist,chr(39))#)">
		</cfif>
		
		<cfset sql=sql & "
			    union 
				  select
				        'nodots-nospaces match on first last' reason,
				        agent.agent_id, 
				        agent.preferred_agent_name
					from
						agent,
						(select agent_id,agent_name from agent_name where agent_name_type='first name') first_name,
						(select agent_id,agent_name from agent_name where agent_name_type='last name') last_name
					where
						agent.agent_id=first_name.agent_id and
						agent.agent_id=last_name.agent_id and
						trim(upper(first_name.agent_name)) = trim(upper('#srchFirstName#')) and
						trim(upper(last_name.agent_name)) = trim(upper('#srchLastName#')) and
						  upper(regexp_replace(first_name.agent_name || last_name.agent_name ,'#regexStripJunk#', '')) in (
							#preserveSingleQuotes(strippedNamePermutations)#
					     )">
		<cfset sql=sql & "
			 union select
				'nodots-nospaces match on agent name' reason,
				 agent.agent_id, 
				 agent.preferred_agent_name
			from 
				agent,
				agent_name
			where 
			    agent.agent_id=agent_name.agent_id and
				upper(regexp_replace(agent_name.agent_name,'#regexStripJunk#', '')) in (#preserveSingleQuotes(strippedNamePermutations)#)">	     
		<cfif len(srchFirstName) gt 0 and len(srchLastName) gt 0>
			<cfset sql=sql & "
				        union
					    select
					    	'nocase first and last name match' reason,
					        agent.agent_id, 
					        agent.preferred_agent_name
						from
							agent,
							(select agent_id,agent_name from agent_name where agent_name_type='first name') first_name,
							(select agent_id,agent_name from agent_name where agent_name_type='last name') last_name
						where
							agent.agent_id=first_name.agent_id and
							agent.agent_id=last_name.agent_id and
							trim(upper(first_name.agent_name)) = trim(upper('#srchFirstName#')) and
							trim(upper(last_name.agent_name)) = trim(upper('#srchLastName#'))">
		</cfif>		        	
		<cfif len(srchFirstName) gt 0 and len(srchMiddleName) gt 0 and len(srchLastName) gt 0>
			<cfset sql=sql & "
						 union
					    select
					        'nodots-nospaces-nocase match on first middle last' reason,
					        agent.agent_id, 
					        agent.preferred_agent_name
						from
							agent,
							(select agent_id,agent_name from agent_name where agent_name_type='first name') first_name,
							(select agent_id,agent_name from agent_name where agent_name_type='middle name') middle_name,
							(select agent_id,agent_name from agent_name where agent_name_type='last name') last_name
						where
							agent.agent_id=first_name.agent_id and
							agent.agent_id=middle_name.agent_id and
							agent.agent_id=last_name.agent_id and
							upper(regexp_replace(first_name.agent_name || middle_name.agent_name || last_name.agent_name ,'#regexStripJunk#', '')) in (
								#preserveSingleQuotes(strippedNamePermutations)#
						     )">
		</cfif>
	<cfelse><!--- not a person --->
		<cfset regexStripJunk='[ .,-]'>
		<cfset problems="">
		<!---- 
			random lists of things may be indicitave of garbage. 
				disallowWords are " me AND you" but not "ANDy"
				disallowCharacters are just that "me/you" and me /  you" and ....	
			Expect some false positives - sorray! 
		---->
		<cfset disallowWords="or,cat,biol,boat,co,Corp,et,illegible,inc,other,uaf,ua,NY,AK,CA,various,Mfg">		
		
		<cfset disallowCharacters="/,\,&">		
		<cfset strippedNamePermutations=ucase(rereplace(preferred_name,regexStripJunk,"","all"))>
		<cfset srchPrefName=trim(escapeQuotes(preferred_name))>
	
		<cfif len(strippedNamePermutations) is 0>
			<cfset problems=listappend(problems,'Check apostrophy/single-quote. "O&apos;Neil" is fine. "Jim&apos;s Cat" should be entered as "unknown".',';')>
		</cfif>
		
		<cfif compare(ucase(preferred_name),preferred_name) eq 0 or compare(lcase(preferred_name),preferred_name) eq 0>
			<cfset problems=listappend(problems,'Check case: Most agents should be Proper Case.',';')>
		</cfif>
			
		<cfloop list="#disallowCharacters#" index="i">
			<cfif preferred_name contains i>
				<cfset problems=listappend(problems,'Check name for #i#: do not create unnecessary variations of "unknown."',';')>
			</cfif>
		</cfloop>
				
		<cfloop list="#disallowWords#" index="i">
			<cfif listfindnocase(preferred_name,i," ;,.")>
				<cfset problems=listappend(problems,'Check name for #i#: do not create unnecessary variations of "unknown."',';')>
			</cfif>
		</cfloop>
		<cfif agent_type is "person">
			<cfloop list="#disallowPersons#" index="i">
				<cfif listfindnocase(preferred_name,i,"() ;,.")>
					<cfset problems=listappend(problems,'Check name for #i#: do not create non-person agents as persons."',';')>
				</cfif>
			</cfloop>
		</cfif>
		<!--- try to avoid unnecessary acronyms --->
		<cfif refind('[A-Z]{3,}',preferred_name) gt 0>
			<cfset problems=listappend(problems,'Check for abbreviations and acronyms. do not create unnecessary variations of "unknown."',';')>
		</cfif>
		<cfif Compare(ucase(preferred_name), preferred_name) is 0 or Compare(lcase(preferred_name), preferred_name) is 0>
			<cfset problems=listappend(problems,'Check for abbreviations and acronyms. Do not create unnecessary variations of "unknown."',';')>
		</cfif>
		<cfif preferred_name does not contain " ">
			<cfset problems=listappend(problems,'Check for abbreviations and acronyms. Do not create unnecessary variations of "unknown."',';')>
		</cfif>
		<cfif preferred_name contains ".">
			<cfset problems=listappend(problems,'Check for abbreviations and acronyms. Do not create unnecessary variations of "unknown."',';')>
		</cfif>
		<cfset strippedNamePermutations=trim(escapeQuotes(strippedNamePermutations))>	
		<cfset strippedNamePermutations=ListQualify(strippedNamePermutations,"'")>	
		<!--- if we did not get a first or last name passed in, try to guess from the preferred name string ---->
		<!--- nocase preferred name match ---->	
		<cfset sql="select 
						'nocase preferred name match' reason,
				        agent.agent_id, 
				        agent.preferred_agent_name
					from 
				        agent
					where 
				        trim(upper(agent.preferred_agent_name))=trim(upper('#srchPrefName#'))">
		<cfset sql="select 
						'exact preferred name match' reason,
				        agent.agent_id, 
				        agent.preferred_agent_name
					from 
				        agent
					where 
				        agent.preferred_agent_name='#srchPrefName#'">
		<cfset sql=sql & "
			 union select
				'nodots-nospaces match on agent name' reason,
				 agent.agent_id, 
				 agent.preferred_agent_name
			from 
				agent,
				cf_agent_isitadup
			where 
				agent.agent_id=cf_agent_isitadup.agent_id and
				strippeduppername in (#preserveSingleQuotes(strippedNamePermutations)#) ">
				
		<!--- 
			common "shortcuts"
		
			new: national park service
			old: U. S. National Park service
		 ---->

		<cfset agencystrip=strippedNamePermutations>
		<cfset agencystrip=replace(agencystrip,'US','','all')>
		<cfset agencystrip=replace(agencystrip,'UNITEDSTATES','','all')>
		<cfset agencystrip=replace(agencystrip,'THE','','all')>
		<cfset agencystrip=replace(agencystrip,'THE','','all')>
		<cfset sql=sql & "
			 union select
				'manipulated match on agent name' reason,
				 agent.agent_id, 
				 agent.preferred_agent_name
			from 
				agent,
				cf_agent_isitadup
			where 
				agent.agent_id=cf_agent_isitadup.agent_id and
				upperstrippedagencyname  in (#preserveSingleQuotes(agencystrip)#) 				
				">
				
	</cfif><!--- end agent type check ---->
	
	<cfquery name="isdup" datasource="uam_god">
		select 
			agent_id,
			preferred_agent_name,
			reason
		from (
			#preservesinglequotes(sql)#
		)  group by
	    	reason,
	    	agent_id, 
	        preferred_agent_name
	    order by
	    	preferred_agent_name
	</cfquery>
	<cfquery name="daid" dbtype="query">
		select preferred_agent_name,agent_id from isdup group by preferred_agent_name,agent_id
	</cfquery>	
	<cfset d = querynew("preferred_agent_name,agent_id,reasons,rcount")>
	<cfset i=1>
	<cfloop query="daid">
		<!--- some really craptacular agents return thousands of "matches" --->
		<cfif i lt 20>
				<cfquery name="thisReasons" dbtype="query">
					select * from isdup where agent_id=#agent_id#
				</cfquery>
				<cfset temp = queryaddrow(d,1)>
				<cfset temp = QuerySetCell(d, "preferred_agent_name", daid.preferred_agent_name, i)>
				<cfset temp = QuerySetCell(d, "agent_id", daid.agent_id, i)>
				<cfset temp = QuerySetCell(d, "reasons", valuelist(thisReasons.reason), i)>
				<cfset temp = QuerySetCell(d, "rcount", thisReasons.recordcount, i)>
				<cfset i=i+1>
		</cfif>
	</cfloop>
	<cfquery name="ff" dbtype="query">
		select * from d order by rcount desc,preferred_agent_name
	</cfquery>
	<cfloop query="ff">
		<cfset thisProb='possible duplicate of <a href="/agents.cfm?agent_id=#agent_id#" target="_blank">#preferred_agent_name#</a> (#reasons#)'>
		<cfset problems=listappend(problems,thisProb,';')>
	</cfloop>
	<cfreturn problems>
</cffunction>
<!--------------------------------------------------------------------------------------->
<cffunction name="splitAgentName" access="remote" returnformat="json">
   	<cfargument name="name" required="true" type="string">
   	<cfargument name="agent_type" required="false" type="string" default="person">
	<cfif isdefined("agent_type") and len(agent_type) gt 0 and agent_type neq 'person'>
		<cfset d = querynew("name,nametype,first,middle,last,formatted_name")>
		<cfset temp = queryaddrow(d,1)>
		<cfset temp = QuerySetCell(d, "name", name, 1)>
		<cfreturn d>
	</cfif>
	
	<cfquery name="CTPREFIX" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select prefix from CTPREFIX
	</cfquery>
	<cfquery name="CTsuffix" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select suffix from CTsuffix
	</cfquery>	
	<cfset temp=name>
	<cfset removedPrefix="">
	<cfset removedSuffix="">
	<cfloop query="CTPREFIX">
		<cfif listfind(temp,prefix," ,")>
			<cfset removedPrefix=prefix>
			<cfset temp=listdeleteat(temp,listfind(temp,prefix," ,")," ,")>
		</cfif>
	</cfloop>
	<cfloop query="CTsuffix">
		<cfif listfind(temp,suffix," ,")>
			<cfset removedSuffix=suffix>
			<cfset temp=listdeleteat(temp,listfind(temp,suffix," ,")," ,")>
		</cfif>
	</cfloop>	
	<cfset temp=trim(replace(temp,'  ',' ','all'))>
	<cfset snp="Von,Van,La,Do,Del,De,St,Der">
	<cfloop list="#snp#" index="x">
		<cfset temp=replace(temp, "#x# ","#x#|","all")>
	</cfloop>
	<cfset nametype="">		
	<cfset first="">
	<cfset middle="">
	<cfset last="">
	<cfif REFind("^[^, ]+ [^, ]+$",temp)>
		<cfset nametype="first_last">
		<cfset first=listgetat(temp,1," ")>
		<cfset last=listlast(temp," ")>
	<cfelseif REFind("^[^,]+ [^,]+ .+$",temp)>
		<cfset nametype="first_middle_last">
		<cfset first=listgetat(temp,1," ")>
		<cfset last=listlast(temp," ")>		
		<cfset middle=replace(replace(temp,first,"","first"),last,"","all")>	
	<cfelseif REFind("^.+, .+ .+$",temp)>
		<cfset nametype="last_comma_first_middle">		
		<cfset last=listfirst(temp," ")>
		<cfset first=listgetat(temp,2," ")>
		<cfset middle=replace(replace(temp,first,"","all"),last,"","all")>		
	<cfelseif REFind("^.+, .+$",temp)>
		<cfset nametype="last_comma_first">
		<cfset last=listgetat(temp,1," ")>
		<cfset first=listgetat(temp,2," ")>	
	<cfelse>
		<cfset nametype="nonstandard">
	</cfif>
	<cfset last=replace(last, "|"," ","all")>
	<cfset middle=replace(middle, "|"," ","all")>
	<cfset first=replace(first, "|"," ","all")>
	<cfset first=trim(replace(first, ',','','all'))>
	<cfset middle=trim(replace(middle, ',','','all'))>
	<cfset last=trim(replace(last, ',','','all'))>
	<cfset formatted_name=trim(replace(removedPrefix & ' ' & 	first & ' ' & middle & ' ' & last & ' ' & removedSuffix, ',','','all'))>
	<cfset formatted_name=replace(formatted_name, '  ',' ','all')>
	<cfif nametype is "nonstandard">
		<cfset formatted_name="">
	</cfif>
	<cfset d = querynew("name,nametype,first,middle,last, formatted_name")>
	<cfset temp = queryaddrow(d,1)>
	<cfset temp = QuerySetCell(d, "name", name, 1)>
	<cfset temp = QuerySetCell(d, "nametype", nametype, 1)>
	<cfset temp = QuerySetCell(d, "first", trim(first), 1)>
	<cfset temp = QuerySetCell(d, "middle", trim(middle), 1)>
	<cfset temp = QuerySetCell(d, "last", trim(last), 1)>
	<cfset temp = QuerySetCell(d, "formatted_name", trim(formatted_name), 1)>
	<cfreturn d>	
</cffunction>
<!--------------------------------------------------------------------------------------->
</cfcomponent>