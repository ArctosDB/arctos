<cfcomponent>
	
<cffunction name="getAllAgentNames" access="remote">
	<cfargument name="filename" type="any" required="yes">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) c from media where media_uri like '%#filename#%'
	</cfquery>
	<cfreturn d.c>
</cffunction>
<cffunction name="getAllAgentNames" access="remote">
	<cfargument name="agent_id" type="any" required="yes">
	<cfif isnumeric(agent_id) and len(agent_id) gt 0>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select agent_name from agent_name where agent_id=#agent_id# order by agent_name
		</cfquery>
		<cfreturn valuelist(d.agent_name,';')>
	<cfelse>
		<cfreturn "">
	</cfif>
</cffunction>


<cffunction name="loadAgent" access="remote">
	<cfargument name="key" type="numeric" required="yes">
	<cfargument name="agent_id" type="any" required="yes">
	<cfset status="">
	<cfset msg="">
	<cfif isnumeric(agent_id) and agent_id gt -1>
		<cftry>
			<cfset msg="">
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from ds_temp_agent where key=#key#
			</cfquery>
			<cftransaction>
				<cfset thisName=trim(d.preferred_name)>
				<cfset nametype='aka'>
				<cftry>
					<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						insert into agent_name (
							agent_name_id,
							AGENT_ID,
							AGENT_NAME_TYPE,
							AGENT_NAME
						) values (
							sq_agent_name_id.nextval,
							#agent_id#,
							'#nametype#',
							'#thisName#'
						)
					</cfquery>
					<cfset msg=listappend(msg,'Added #thisName# (#nametype#)')>
				<cfcatch>
					<cfset msg=listappend(msg,'Failed: add #thisName# (#nametype#)<br><span class="cfcatch">#replace(cfcatch.detail,"[Macromedia][Oracle JDBC Driver][Oracle]ORA-00001: ","","all")#</span>')>
				</cfcatch>
				</cftry>
				<cfif len(d.other_name_1) gt 0>
					<cfset thisName=trim(d.other_name_1)>
					<cfset nametype=d.other_name_type_1>
					<cftry>
						<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							insert into agent_name (
								agent_name_id,
								AGENT_ID,
								AGENT_NAME_TYPE,
								AGENT_NAME
							) values (
								sq_agent_name_id.nextval,
								#agent_id#,
								'#nametype#',
								'#thisName#'
							)
						</cfquery>
						<cfset msg=listappend(msg,'Added #thisName# (#nametype#)')>
					<cfcatch>
						<cfset msg=listappend(msg,'Failed: add #thisName# (#nametype#)<br><span class="cfcatch">#replace(cfcatch.detail,"[Macromedia][Oracle JDBC Driver][Oracle]ORA-00001: ","","all")#</span>')>
					</cfcatch>
					</cftry>
				</cfif>
				
				<cfif len(d.other_name_2) gt 0>
					<cfset thisName=trim(d.other_name_2)>
					<cfset nametype=d.other_name_type_2>
					<cftry>
						<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							insert into agent_name (
								agent_name_id,
								AGENT_ID,
								AGENT_NAME_TYPE,
								AGENT_NAME
							) values (
								sq_agent_name_id.nextval,
								#agent_id#,
								'#nametype#',
								'#thisName#'
							)
						</cfquery>
						<cfset msg=listappend(msg,'Added #thisName# (#nametype#)')>
					<cfcatch>
						<cfset msg=listappend(msg,'Failed: add #thisName# (#nametype#)<br><span class="cfcatch">#replace(cfcatch.detail,"[Macromedia][Oracle JDBC Driver][Oracle]ORA-00001: ","","all")#</span>')>
					</cfcatch>
					</cftry>
				</cfif>
				<cfif len(d.other_name_3) gt 0>
					<cfset thisName=trim(d.other_name_3)>
					<cfset nametype=d.other_name_type_3>
					<cftry>
						<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							insert into agent_name (
								sq_agent_name_id.nextval,
								agent_name_id,
								AGENT_ID,
								AGENT_NAME_TYPE,
								AGENT_NAME
							) values (
								#agent_id#,
								'#nametype#',
								'#thisName#'
							)
						</cfquery>
						<cfset msg=listappend(msg,'Added #thisName# (#nametype#)')>
					<cfcatch>
						<cfset msg=listappend(msg,'Failed: add #thisName# (#nametype#)<br><span class="cfcatch">#replace(cfcatch.detail,"[Macromedia][Oracle JDBC Driver][Oracle]ORA-00001: ","","all")#</span>')>
					</cfcatch>
					</cftry>
				</cfif>
				<cfif len(d.agent_remark) gt 0>
					<cftry>
						<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							update agent set agent_remarks=
								decode(trim(agent_remarks),
								null,'#trim(d.agent_remark)#',
								'#trim(d.agent_remark)#','#trim(d.agent_remark)#',
								agent_remarks || '; #trim(d.agent_remark)#')
								where agent_id=#agent_id#
						</cfquery>
						<cfset msg=listappend(msg,'Added remark')>
					<cfcatch>
						<cfset msg=listappend(msg,'Failed: add remark<br><span class="cfcatch">#replace(cfcatch.detail,"[Macromedia][Oracle JDBC Driver][Oracle]ORA-00001: ","","all")#</span>')>
					</cfcatch>
					</cftry>
				</cfif>
			</cftransaction>
			<cfset status="PASS">
			<cfset msg=listappend(msg,'<a href="/agents.cfm?agent_id=#agent_id#" target="_blank">agent record</a>')>
			<cfset msg=listchangedelims(msg,"<br>")>
		<cfcatch>
			<cfset status="FAIL">
			<cfset msg='Failed: update agent<br><span class="cfcatch">#replace(cfcatch.detail,"[Macromedia][Oracle JDBC Driver][Oracle]ORA-00001: ","","all")#</span>'>
		</cfcatch>
		</cftry>
	<cfelseif agent_id is -1>
		<cftry>
			<cftransaction>
				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select * from ds_temp_agent where key=#key#
				</cfquery>
				<cfquery name="agentID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select sq_agent_id.nextval nextAgentId from dual
				</cfquery>
				<cfquery name="agentNameID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select sq_agent_name_id.nextval nextAgentNameId from dual
				</cfquery>		
				<cfquery name="insPerson" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					INSERT INTO agent (
						agent_id,
						agent_type,
						preferred_agent_name_id,
						AGENT_REMARKS
					) VALUES (
						#agentID.nextAgentId#,
						'person',
						#agentNameID.nextAgentNameId#,
						'#trim(d.agent_remark)#'
						)
				</cfquery>		
				<cfquery name="insPerson" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					INSERT INTO person ( 
						PERSON_ID
						,prefix
						,LAST_NAME
						,FIRST_NAME
						,MIDDLE_NAME
						,SUFFIX,
						BIRTH_DATE,
						DEATH_DATE
					) VALUES (
						#agentID.nextAgentId#
						,'#trim(d.prefix)#'
						,'#trim(d.LAST_NAME)#'
						,'#trim(d.FIRST_NAME)#'
						,'#trim(d.MIDDLE_NAME)#'
						,'#trim(d.SUFFIX)#'
						,'#trim(d.birth_date)#'
						,'#trim(d.death_date)#'
					)
				</cfquery>
				<cfquery name="insName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					INSERT INTO agent_name (
						agent_name_id,
						agent_id,
						agent_name_type,
						agent_name,
						donor_card_present_fg
					) VALUES (
						#agentNameID.nextAgentNameId#,
						#agentID.nextAgentId#,
						'preferred',
						'#trim(d.preferred_name)#',
						0
					)
				</cfquery>
			<cftransaction action="commit"><!--- stoopid trigger workaround to have preferred name --->
				<cfif len(d.other_name_1) gt 0>
					<cfquery name="insName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						INSERT INTO agent_name (
							agent_name_id,
							agent_id,
							agent_name_type,
							agent_name,
							donor_card_present_fg
						) VALUES (
							sq_agent_name_id.nextval,
							#agentID.nextAgentId#,
							'#d.other_name_type_1#',
							'#trim(d.other_name_1)#',
							0
						)
					</cfquery>
				</cfif>
				<cfif len(d.other_name_2) gt 0>
					<cfquery name="insName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						INSERT INTO agent_name (
							agent_name_id,
							agent_id,
							agent_name_type,
							agent_name,
							donor_card_present_fg
						) VALUES (
							sq_agent_name_id.nextval,
							#agentID.nextAgentId#,
							'#d.other_name_type_2#',
							'#trim(d.other_name_2)#',
							0
						)
					</cfquery>
				</cfif>
				<cfif len(d.other_name_3) gt 0>
					<cfquery name="insName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						INSERT INTO agent_name (
							agent_name_id,
							agent_id,
							agent_name_type,
							agent_name,
							donor_card_present_fg
						) VALUES (
							sq_agent_name_id.nextval,
							#agentID.nextAgentId#,
							'#d.other_name_type_3#',
							'#trim(d.other_name_3)#',
							0
						)
					</cfquery>
				</cfif>
			</cftransaction>
			<cfset status="PASS">
			<cfset agent_id=agentID.nextAgentId>
			<cfset msg='<a href="/agents.cfm?agent_id=#agent_id#" target="_blank">agent</a> created'>	
		<cfcatch>
			<cfset status="FAIL">
			<cfset agent_id="">
			<cfset msg='Failed: Create agent<span class="cfcatch">#replace(cfcatch.detail,"[Macromedia][Oracle JDBC Driver][Oracle]","","all")#</span>'>
		</cfcatch>
		</cftry>
	</cfif>
	<cfset result = querynew("KEY,STATUS,MSG,AGENT_ID")>
	<cfset temp = queryaddrow(result,1)>
	<cfset temp = QuerySetCell(result, "KEY", key, 1)>
	<cfset temp = QuerySetCell(result, "STATUS", status, 1)>
	<cfset temp = QuerySetCell(result, "MSG", msg, 1)>
	<cfset temp = QuerySetCell(result, "AGENT_ID", agent_id, 1)>
	<cfreturn result>
</cffunction>


<cffunction name="findAgentMatch" access="remote">
	<cfargument name="key" type="numeric" required="yes">	
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select first_name,middle_name,last_name,preferred_name,other_name_1,other_name_2,other_name_3 
		from ds_temp_agent where key=#key#
	</cfquery>
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
	        #KEY# key,
	        preferred_agent_name.agent_id, 
	        preferred_agent_name.agent_name preferred_agent_name
		from 
	        agent_name srch,
	        preferred_agent_name
		where 
	        srch.agent_id=preferred_agent_name.agent_id and
	        trim(srch.agent_name) in (
	        	trim('#d.preferred_name#'),
	        	trim('#d.other_name_1#'),
	        	trim('#d.other_name_2#'),
	        	trim('#d.other_name_3#')
	        )
	    group by
	    	preferred_agent_name.agent_id, 
	        preferred_agent_name.agent_name,
	        #key#
	    union
	    select
	    	#KEY# key,
	        preferred_agent_name.agent_id, 
	        preferred_agent_name.agent_name preferred_agent_name
		from
			person,
			preferred_agent_name
		where
			person.person_id=preferred_agent_name.agent_id and
			upper(first_name) = trim(upper('#d.first_name#')) and
			upper(last_name) = trim(upper('#d.last_name#'))			
	</cfquery>
	<cfreturn result>
</cffunction>
<cffunction name="findAgentMatchOld" access="remote">
	<cfargument name="key" type="numeric" required="yes">	
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from ds_temp_agent where key=#key#
	</cfquery>
	<cfquery name="n" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
	        first_name,
	        middle_name,
	        last_name,
	        birth_date,
	        death_date,
	        suffix,
	        preferred_agent_name.agent_id, 
	        preferred_agent_name.agent_name preferred_agent_name
		from 
	        person,
	        agent_name srch,
	        preferred_agent_name
		where 
	        person.person_id=srch.agent_id and
	        person.person_id=preferred_agent_name.agent_id and
	        srch.agent_name in ('#d.preferred_name#','#d.other_name_1#','#d.other_name_2#','#d.other_name_3#')
	    group by
	    	first_name,
	        middle_name,
	        last_name,
	        birth_date,
	        death_date,
	        suffix,
	        preferred_agent_name.agent_id, 
	        preferred_agent_name.agent_name
	</cfquery>
	<cfset result = querynew("key,first_name,middle_name,last_name,birth_date,death_date,suffix,agent_id,
			preferred_agent_name,othernames,n_agent_type,n_preferred_name,n_first_name,n_middle_name,n_last_name,n_birth_date,n_death_date,
			n_prefix,n_suffix,n_other_name_1,n_other_name_type_1,n_other_name_2,n_other_name_type_2,n_other_name_3,
			n_other_name_type_3")>
	
	
	
	<cfset i=1>
	<cfloop query="n">
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "key", key, i)>
		<cfset temp = QuerySetCell(result, "first_name", n.first_name, i)>
		<cfset temp = QuerySetCell(result, "middle_name", n.middle_name, i)>
		<cfset temp = QuerySetCell(result, "last_name", n.last_name, i)>
		<cfset temp = QuerySetCell(result, "birth_date", n.birth_date, i)>
		<cfset temp = QuerySetCell(result, "death_date", n.death_date, i)>
		<cfset temp = QuerySetCell(result, "suffix", n.suffix, i)>
		<cfset temp = QuerySetCell(result, "agent_id", n.agent_id, i)>
		<cfset temp = QuerySetCell(result, "preferred_agent_name", n.preferred_agent_name, i)>
		<cfset temp = QuerySetCell(result, "n_agent_type", d.n_agent_type, i)>
		<cfset temp = QuerySetCell(result, "n_preferred_name", d.n_preferred_name, i)>
		<cfset temp = QuerySetCell(result, "n_first_name", d.n_first_name, i)>
		<cfset temp = QuerySetCell(result, "n_middle_name", d.n_middle_name, i)>
		<cfset temp = QuerySetCell(result, "n_last_name", d.n_last_name, i)>
		<cfset temp = QuerySetCell(result, "n_birth_date", d.n_birth_date, i)>
		<cfset temp = QuerySetCell(result, "n_death_date", d.n_death_date, i)>
		<cfset temp = QuerySetCell(result, "n_prefix", d.n_prefix, i)>
		<cfset temp = QuerySetCell(result, "n_suffix", d.n_suffix, i)>
		<cfset temp = QuerySetCell(result, "n_other_name_1", d.n_other_name_1, i)>
		<cfset temp = QuerySetCell(result, "n_other_name_type_1", d.n_other_name_type_1, i)>
		<cfset temp = QuerySetCell(result, "n_other_name_2", d.n_other_name_2, i)>
		<cfset temp = QuerySetCell(result, "n_other_name_type_2", d.n_other_name_type_2, i)>
		<cfset temp = QuerySetCell(result, "n_other_name_3", d.n_other_name_3, i)>
		<cfset temp = QuerySetCell(result, "n_other_name_type_3", d.n_other_name_type_3, i)>
		<cfset i=i+1>
	</cfloop>
	<cfreturn result>
</cffunction>
</cfcomponent>