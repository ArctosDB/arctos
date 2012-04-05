<cfoutput>
	<!----
<cfquery name="d" datasource="uam_god">
	select preferred_name, other_name_2 from sikesagent where other_name_2 in (select agent_name from agent_name) and
preferred_name not in (select agent_name from agent_name)
	order by other_name_2
</cfquery>
<cfdump var=#d#>
<cfloop query="d">
	<cftransaction>
	<cfquery name="a" datasource="uam_god">
		select agent_id from agent_name where agent_name='#other_name_2#'
	</cfquery>
	<br>	INSERT INTO agent_name (
				agent_name_id, agent_id, agent_name_type, agent_name)
			VALUES (
				sq_agent_name_id.nextval, #a.agent_id#, 'aka','#preferred_name#')
	<cfquery name="updateName" datasource="uam_god">
			INSERT INTO agent_name (
				agent_name_id, agent_id, agent_name_type, agent_name)
			VALUES (
				sq_agent_name_id.nextval, #a.agent_id#, 'aka','#preferred_name#')
		</cfquery>
		<cfquery name="die" datasource="uam_god">
			delete from sikesagent where preferred_name='#preferred_name#'
		</cfquery>
		
		</cftransaction>
</cfloop>
---->


<cfquery name="d" datasource="uam_god">
select * from sikesagent order by preferred_name
</cfquery>
<cfloop query="d">
	<cftransaction>
		<hr>#preferred_name#
		<cfquery name="agentID"  datasource="uam_god">
			select sq_agent_id.nextval nextAgentId from dual
		</cfquery>
		<cfquery name="agentNameID" datasource="uam_god">
			select sq_agent_name_id.nextval nextAgentNameId from dual
		</cfquery>		
		<br>
		INSERT INTO agent (
				agent_id,
				agent_type,
				preferred_agent_name_id)
			VALUES (
				#agentID.nextAgentId#,
				'group',
				#agentNameID.nextAgentNameId#
				)
				
				
				
				
		<cfquery name="insA" datasource="uam_god">
			INSERT INTO agent (
				agent_id,
				agent_type,
				preferred_agent_name_id)
			VALUES (
				#agentID.nextAgentId#,
				'group',
				#agentNameID.nextAgentNameId#
				)
		</cfquery>	
			
			
		<br>
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
					'#preferred_name#',
					0
					)
			<cfquery name="insName"  datasource="uam_god">
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
					'#preferred_name#',
					0
					)
			</cfquery>
			
			
			
		<cfset i=1>
		<cfloop list="#preferred_name#" index="a">
			<cfquery name="p" datasource="uam_god">
				select * from agent_name where agent_name='#a#'
			</cfquery>
			<cfif p.recordcount is 1>
				
				
				<br>
				#p.agent_name# found!!<br>
				INSERT INTO group_member (GROUP_AGENT_ID, MEMBER_AGENT_ID, MEMBER_ORDER)
					values (#agentID.nextAgentId#,#p.agent_id#,#i#)
				<cfquery name="newGroupMember" datasource="uam_god">
					INSERT INTO group_member (GROUP_AGENT_ID, MEMBER_AGENT_ID, MEMBER_ORDER)
					values (#agentID.nextAgentId#,#p.agent_id#,#i#)
				</cfquery>
				<cfset i=i+1>
			</cfif>
		</cfloop>
	</cftransaction>
</cfloop>
<!------------







	<cfquery name="newGroupMember" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
		INSERT INTO group_member (GROUP_AGENT_ID, MEMBER_AGENT_ID, MEMBER_ORDER)
		values (#agent_id#,#member_id#,#MEMBER_ORDER#)
	</cfquery>
	
	
	
	
<cfloop query="d">
	<cftransaction>
		<cfquery name="agentID"  datasource="uam_god">
				select sq_agent_id.nextval nextAgentId from dual
			</cfquery>
			<cfquery name="agentNameID" datasource="uam_god">
				select sq_agent_name_id.nextval nextAgentNameId from dual
			</cfquery>		
			<br>
			
			
			INSERT INTO agent (
					agent_id,
					agent_type,
					preferred_agent_name_id)
				VALUES (
					#agentID.nextAgentId#,
					'person',
					#agentNameID.nextAgentNameId#
					)
					
					
					
					
			<cfquery name="insPerson" datasource="uam_god">
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
			
			
			<br>
			
			INSERT INTO person ( 
					PERSON_ID
					<cfif len(#prefix#) gt 0>
						,prefix
					</cfif>
					<cfif len(#LAST_NAME#) gt 0>
						,LAST_NAME
					</cfif>
					<cfif len(#FIRST_NAME#) gt 0>
						,FIRST_NAME
					</cfif>
					<cfif len(#MIDDLE_NAME#) gt 0>
						,MIDDLE_NAME
					</cfif>
					<cfif len(#SUFFIX#) gt 0>
						,SUFFIX
					</cfif>
					)
				VALUES
					(#agentID.nextAgentId#
					<cfif len(#prefix#) gt 0>
						,'#prefix#'
					</cfif>
					<cfif len(#LAST_NAME#) gt 0>
						,'#LAST_NAME#'
					</cfif>
					<cfif len(#FIRST_NAME#) gt 0>
						,'#FIRST_NAME#'
					</cfif>
					<cfif len(#MIDDLE_NAME#) gt 0>
						,'#MIDDLE_NAME#'
					</cfif>
					<cfif len(#SUFFIX#) gt 0>
						,'#SUFFIX#'
					</cfif>
					)
					
					
							
			<cfquery name="insPerson"  datasource="uam_god">
				INSERT INTO person ( 
					PERSON_ID
					<cfif len(#prefix#) gt 0>
						,prefix
					</cfif>
					<cfif len(#LAST_NAME#) gt 0>
						,LAST_NAME
					</cfif>
					<cfif len(#FIRST_NAME#) gt 0>
						,FIRST_NAME
					</cfif>
					<cfif len(#MIDDLE_NAME#) gt 0>
						,MIDDLE_NAME
					</cfif>
					<cfif len(#SUFFIX#) gt 0>
						,SUFFIX
					</cfif>
					)
				VALUES
					(#agentID.nextAgentId#
					<cfif len(#prefix#) gt 0>
						,'#prefix#'
					</cfif>
					<cfif len(#LAST_NAME#) gt 0>
						,'#LAST_NAME#'
					</cfif>
					<cfif len(#FIRST_NAME#) gt 0>
						,'#FIRST_NAME#'
					</cfif>
					<cfif len(#MIDDLE_NAME#) gt 0>
						,'#MIDDLE_NAME#'
					</cfif>
					<cfif len(#SUFFIX#) gt 0>
						,'#SUFFIX#'
					</cfif>
					)
			</cfquery>
			
			....inserted
			<br>
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
					'#preferred_name#',
					0
					)
			<cfquery name="insName"  datasource="uam_god">
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
					'#preferred_name#',
					0
					)
			</cfquery>
			
						....inserted

			<cfset fu=preferred_name>
			<cfif len(other_name_1) gt 0 and not listfind(fu,other_name_1)>
				<cfset fu=listappend(fu,other_name_1)>
				
				
				
				<cfquery name="agentNameID" datasource="uam_god">
					select sq_agent_name_id.nextval nextAgentNameId from dual
				</cfquery>	
				
				
					<br>
					
					INSERT INTO agent_name (
						agent_name_id,
						agent_id,
						agent_name_type,
						agent_name,
						donor_card_present_fg)
					VALUES (
						#agentNameID.nextAgentNameId#,
						#agentID.nextAgentId#,
						'#other_name_type_1#',
						'#other_name_1#',
						0
						)
						
						
							
				<cfquery name="insName1"  datasource="uam_god">
					INSERT INTO agent_name (
						agent_name_id,
						agent_id,
						agent_name_type,
						agent_name,
						donor_card_present_fg)
					VALUES (
						#agentNameID.nextAgentNameId#,
						#agentID.nextAgentId#,
						'#other_name_type_1#',
						'#other_name_1#',
						0
						)
				</cfquery>
				
							....inserted

			</cfif>
			<cfif len(other_name_2) gt 0 and not listfind(fu,other_name_2)>
				<cfset fu=listappend(fu,other_name_2)>
				<cfquery name="agentNameID" datasource="uam_god">
					select sq_agent_name_id.nextval nextAgentNameId from dual
				</cfquery>	
				<cfquery name="insName2" datasource="uam_god">
					INSERT INTO agent_name (
						agent_name_id,
						agent_id,
						agent_name_type,
						agent_name,
						donor_card_present_fg)
					VALUES (
						#agentNameID.nextAgentNameId#,
						#agentID.nextAgentId#,
						'#other_name_type_2#',
						'#other_name_2#',
						0
						)
				</cfquery>
			</cfif>
			<cfif len(other_name_3) gt 0 and not listfind(fu,other_name_3)>
				<cfset fu=listappend(fu,other_name_3)>
				<cfquery name="agentNameID" datasource="uam_god">
					select sq_agent_name_id.nextval nextAgentNameId from dual
				</cfquery>	
				
				<cfquery name="insName3" datasource="uam_god">
					INSERT INTO agent_name (
						agent_name_id,
						agent_id,
						agent_name_type,
						agent_name,
						donor_card_present_fg)
					VALUES (
						#agentNameID.nextAgentNameId#,
						#agentID.nextAgentId#,
						'#other_name_type_3#',
						'#other_name_3#',
						0
						)
				</cfquery>
			</cfif>
		<cfquery name="a" datasource="uam_god">
			update sikesagent set status='loaded' where preferred_name='#preferred_name#'
		</cfquery>

		
		
			
	</cftransaction>

</cfloop>


------------------>
<cfdump var=#d#>


</cfoutput>
