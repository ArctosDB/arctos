<cfinclude template="/includes/_header.cfm">
<!---

drop table cf_dup_agent;


create table cf_dup_agent (
	cf_dup_agent_id number not null,
	AGENT_ID number not null,
	RELATED_AGENT_ID number not null,
	agent_pref_name varchar2(255) not null,
	rel_agent_pref_name varchar2(255) not null,
	detected_date date not null,
	last_date date not null,
	status varchar2(255)
);



CREATE OR REPLACE TRIGGER tr_cf_dup_agent_key
BEFORE INSERT ON cf_dup_agent
FOR EACH ROW
BEGIN
        IF :new.cf_dup_agent_id IS NULL THEN
        	SELECT somerandomsequence.nextval
    		INTO :new.cf_dup_agent_id
    		FROM dual;
        END IF;
END;
/


--->

<cfif action is "nothing">
	<a href="duplicate_agents.cfm?action=merge">merge</a>
	<br><a href="duplicate_agents.cfm?action=findDups">findDups</a>
	<br><a href="duplicate_agents.cfm?action=notify">notify</a>
</cfif>
<!------------------------------------------------------------------------>
<cfif action is "merge">
	<cfoutput>		
		<cfquery name="bads" datasource="uam_god">
			select 
				cf_dup_agent.cf_dup_agent_id,
				agent_relations.AGENT_ID,
				agent_relations.RELATED_AGENT_ID,
				cf_dup_agent.agent_pref_name,
				cf_dup_agent.rel_agent_pref_name,
				detected_date
			from
				agent_relations,
				cf_dup_agent
			where
				AGENT_RELATIONSHIP='bad duplicate of' and 
				agent_relations.AGENT_ID=cf_dup_agent.AGENT_ID and
				agent_relations.RELATED_AGENT_ID=cf_dup_agent.RELATED_AGENT_ID and
				status='pass_email_sent' and
				round(sysdate-last_date) >= 7
		</cfquery>
		<cfloop query="bads">
			#cf_dup_agent_id#<br>
			<cftransaction>
				<cftry>				
					<!--- if there are non-electronic addresses, merge them and update shipments ---->
					<cfquery name="addr" datasource="uam_god">
						select 
							ADDR_ID,
							STREET_ADDR1,
							STREET_ADDR2,
							CITY,
							STATE,
							ZIP,
							COUNTRY_CDE,
							MAIL_STOP,
							FORMATTED_ADDR,
							AGENT_ID,
							ADDR_TYPE,
							JOB_TITLE,
							VALID_ADDR_FG,
							ADDR_REMARKS,
							INSTITUTION,
							DEPARTMENT
						from 
							addr 
						where 
							agent_id=#bads.agent_id#
					</cfquery>
					
					<cfloop query="addr">
						<br>got some addresses.....
						<!--- see if there's a functional duplicate ---->
						<cfquery name="goodHasDupAddr" datasource="uam_god">
							select 
								min(addr_id) addr_id 
							from 
								addr 
							where 
								agent_id=#bads.RELATED_AGENT_ID# and
								STREET_ADDR1='#STREET_ADDR1#' and
								nvl(STREET_ADDR2,'NULL')=nvl('#STREET_ADDR2#','NULL') and
								CITY='#CITY#' and
								nvl(STATE,'NULL')=nvl('#STATE#','NULL') and
								nvl(ZIP,'NULL')=nvl('#ZIP#','NULL') and
								nvl(COUNTRY_CDE,'NULL')=nvl('#COUNTRY_CDE#','NULL') and
								nvl(MAIL_STOP,'NULL')=nvl('#MAIL_STOP#','NULL') and
								nvl(JOB_TITLE,'NULL')=nvl('#JOB_TITLE#','NULL') and
								nvl(INSTITUTION,'NULL')=nvl('#INSTITUTION#','NULL') and
								nvl(DEPARTMENT,'NULL')=nvl('#DEPARTMENT#','NULL')
						</cfquery>
						<cfif len(goodHasDupAddr.addr_id) gt 0>
							<!--- the good dup has a dup address; update shipment to use it and delete the old ---->
							<cfquery name="upShipTo" datasource="uam_god">
								update shipment set SHIPPED_TO_ADDR_ID=#goodHasDupAddr.addr_id# where SHIPPED_TO_ADDR_ID=#addr.addr_id#
							</cfquery>
							<cfquery name="upShipFrom" datasource="uam_god">
								update shipment set SHIPPED_FROM_ADDR_ID=#goodHasDupAddr.addr_id# where SHIPPED_FROM_ADDR_ID=#addr.addr_id#
							</cfquery>
						<cfelse>
							<!--- create new address, update shipments ---->
							<cfquery name="newAddrID" datasource="uam_god">
								select sq_addr_id.nextval nid from dual
							</cfquery>
							<cfquery name="newAddr" datasource="uam_god">
								insert into addr (
									ADDR_ID,
									STREET_ADDR1,
									STREET_ADDR2,
									CITY,
									STATE,
									ZIP,
									COUNTRY_CDE,
									MAIL_STOP,
									AGENT_ID,
									ADDR_TYPE,
									JOB_TITLE,
									VALID_ADDR_FG,
									ADDR_REMARKS,
									INSTITUTION,
									DEPARTMENT
								) values (
									#newAddrID.nid#,
									'#escapequotes(addr.STREET_ADDR1)#',
									'#escapequotes(addr.STREET_ADDR2)#',
									'#escapequotes(addr.CITY)#',
									'#escapequotes(addr.STATE)#',
									'#escapequotes(addr.ZIP)#',
									'#escapequotes(addr.COUNTRY_CDE)#',
									'#escapequotes(addr.MAIL_STOP)#',
									'#bads.related_agent_id#',
									'#escapequotes(addr.ADDR_TYPE)#',
									'#escapequotes(addr.JOB_TITLE)#',
									#addr.VALID_ADDR_FG#,
									'#escapequotes(addr.ADDR_REMARKS)#',
									'#escapequotes(addr.INSTITUTION)#',
									'#escapequotes(addr.DEPARTMENT)#'
								)
							</cfquery>
							<cfquery name="upShipTo" datasource="uam_god">
								update shipment set SHIPPED_TO_ADDR_ID=#newAddrID.nid# where SHIPPED_TO_ADDR_ID=#addr.addr_id#
							</cfquery>
							<cfquery name="upShipFrom" datasource="uam_god">
								update shipment set SHIPPED_FROM_ADDR_ID=#newAddrID.nid# where SHIPPED_FROM_ADDR_ID=#addr.addr_id#
							</cfquery>
						</cfif>
					</cfloop>
					<cfquery name="electronic_address" datasource="uam_god">
						select 
							AGENT_ID,
							ADDRESS_TYPE,
							ADDRESS 
						from 
							electronic_address 
						where 
							agent_id=#bads.agent_id#
					</cfquery>
					<cfloop query="electronic_address">
						<cfquery name="hasgood_electronic_address" datasource="uam_god">
							select 
								count(*) cnt 
							from 
								electronic_address 
							where 
								agent_id=#bads.RELATED_AGENT_ID# and
								ADDRESS_TYPE='#electronic_address.ADDRESS_TYPE#' and
								ADDRESS='#electronic_address.ADDRESS#'
						</cfquery>
						<cfif hasgood_electronic_address.cnt is 0>
							<!--- no dup, create address ---->
							<cfquery name="new_electronic_address" datasource="uam_god">
								insert into electronic_address (
									AGENT_ID,
									ADDRESS_TYPE,
									ADDRESS
								) values (
									#bads.RELATED_AGENT_ID#,
									'#electronic_address.ADDRESS_TYPE#',
									'#electronic_address.ADDRESS#'
								)
							</cfquery>
						</cfif>
					</cfloop>
					<cfquery name="electronic_address" datasource="uam_god">
						delete from electronic_address where agent_id=#bads.agent_id#
					</cfquery>
<br>delete from addr where agent_id=#bads.agent_id#
					<cfquery name="addr" datasource="uam_god">
						delete from addr where agent_id=#bads.agent_id#
					</cfquery>
					
					<!--- avoid unique constraint ---->
					
					
					<cfquery name="collector_conflict" datasource="uam_god">
						delete from collector where agent_id=#bads.agent_id# and collection_object_id in 
						(select collection_object_id from collector where agent_id=#bads.related_agent_id#)
					</cfquery>
					
					<cfquery name="collector" datasource="uam_god">
						UPDATE collector SET agent_id = #bads.related_agent_id#
						WHERE agent_id = #bads.agent_id#
					</cfquery>
					
					

					got collector<br><cfflush>
					<cfquery name="attributes" datasource="uam_god">
						update attributes SET determined_by_agent_id=#bads.related_agent_id#
						where determined_by_agent_id = #bads.agent_id#
					</cfquery>
					got attributes<br><cfflush>
					<cfquery name="mediarc" datasource="uam_god">
						UPDATE 
						media_relations SET CREATED_BY_AGENT_ID=#bads.related_agent_id#
						where CREATED_BY_AGENT_ID=#bads.agent_id#
					</cfquery>
					got media 1<br><cfflush>
					<cfquery name="mediard" datasource="uam_god">
						UPDATE 
							media_relations 
						SET RELATED_PRIMARY_KEY=#bads.related_agent_id#
						where RELATED_PRIMARY_KEY=#bads.agent_id# and
						upper(SUBSTR(media_relationship,instr(media_relationship,' ',-1)+1))='AGENT'
					</cfquery>
					got media 2<br><cfflush>
					<cfquery name="medialbl" datasource="uam_god">
						UPDATE 
							media_labels 
						SET ASSIGNED_BY_AGENT_ID=#bads.related_agent_id#
						where ASSIGNED_BY_AGENT_ID=#bads.agent_id# 
					</cfquery>
					got media label<br><cfflush>
					<cfquery name="encumbrance" datasource="uam_god">
						UPDATE encumbrance SET encumbering_agent_id = #bads.related_agent_id#
						where encumbering_agent_id = #bads.agent_id#
					</cfquery>
					got encumbrance<br><cfflush>
					<cfquery name="identification_agent" datasource="uam_god">
						update identification_agent set
						agent_id = #bads.related_agent_id#
						where agent_id = #bads.agent_id#
					</cfquery>
					got ID agnt<br><cfflush>
					<cfquery name="specimen_event" datasource="uam_god">
						update
						specimen_event set 
						ASSIGNED_BY_AGENT_ID = #bads.related_agent_id# where
						ASSIGNED_BY_AGENT_ID = #bads.agent_id#
					</cfquery>
					got latlong<br><cfflush>
					<cfquery name="permit_to" datasource="uam_god">
						update permit set
							ISSUED_TO_AGENT_ID = #bads.related_agent_id# where
							ISSUED_TO_AGENT_ID = #bads.agent_id#
					</cfquery>
					update trans_agent set
							AGENT_ID = #bads.related_agent_id# where
							AGENT_ID = #bads.agent_id#killagent<CFFLUSH>
					<cfquery name="trans_agent" datasource="uam_god">
						update trans_agent set
							AGENT_ID = #bads.related_agent_id# where
							AGENT_ID = #bads.agent_id#
					</cfquery>
					got tagent<br><cfflush>
					<cfquery name="permit_by" datasource="uam_god">
						update permit set
							ISSUED_by_AGENT_ID = #bads.related_agent_id# where
							ISSUED_by_AGENT_ID = #bads.agent_id#
					</cfquery>
					<cfquery name="permit_contact" datasource="uam_god">
						update permit set
							CONTACT_AGENT_ID = #bads.related_agent_id# where
							CONTACT_AGENT_ID = #bads.agent_id#
					</cfquery>
					got permit<br><cfflush>
					<cfquery name="shipment" datasource="uam_god">
						update shipment set 
						PACKED_BY_AGENT_ID = #bads.related_agent_id# where
						PACKED_BY_AGENT_ID = #bads.agent_id#
					</cfquery>
					got shipment<br><cfflush>
					<cfquery name="entered" datasource="uam_god">
						update coll_object set
						ENTERED_PERSON_ID = #bads.related_agent_id# where
						ENTERED_PERSON_ID = #bads.agent_id#
					</cfquery>
					got collobject<br><cfflush>
					<cfquery name="last_edit" datasource="uam_god">
						update coll_object set
						LAST_EDITED_PERSON_ID = #bads.related_agent_id# where
						LAST_EDITED_PERSON_ID = #bads.agent_id#
					</cfquery>
					got collobjed<br><cfflush>
					<cfquery name="loan_item" datasource="uam_god">
						update loan_item set
						RECONCILED_BY_PERSON_ID = #bads.related_agent_id# where
						RECONCILED_BY_PERSON_ID = #bads.agent_id#
					</cfquery>
					
					<cfquery name="media_relations" datasource="uam_god">
						update media_relations set
						RELATED_PRIMARY_KEY = #bads.related_agent_id# where
						RELATED_PRIMARY_KEY = #bads.agent_id# and
						MEDIA_RELATIONSHIP like '% agent'
					</cfquery>
					<cfquery name="media_relations_creator" datasource="uam_god">
						update media_relations set
						CREATED_BY_AGENT_ID = #bads.related_agent_id# where
						CREATED_BY_AGENT_ID = #bads.agent_id#
					</cfquery>
					<cfquery name="media_labels" datasource="uam_god">
						update media_labels set
						ASSIGNED_BY_AGENT_ID = #bads.related_agent_id# where
						ASSIGNED_BY_AGENT_ID = #bads.agent_id#
					</cfquery>
					got media labels<br><cfflush>
					<cfquery name="group_member" datasource="uam_god">
						update group_member set
						MEMBER_AGENT_ID = #bads.related_agent_id# where
						MEMBER_AGENT_ID = #bads.agent_id#
					</cfquery>
					got group_member<br><cfflush>
					<cfquery name="object_condition" datasource="uam_god">
						update object_condition set
						DETERMINED_AGENT_ID = #bads.related_agent_id# where
						DETERMINED_AGENT_ID = #bads.agent_id#
					</cfquery>
					got object_condition<br><cfflush>
					<cfquery name="collection_contacts" datasource="uam_god">
						update collection_contacts set
						CONTACT_AGENT_ID = #bads.related_agent_id# where
						CONTACT_AGENT_ID = #bads.agent_id#
					</cfquery>
					got collection_contacts<br><cfflush>
					<cfquery name="publication_agent" datasource="uam_god">
						update publication_agent set
						agent_id = #bads.related_agent_id# where
						agent_id = #bads.agent_id#
					</cfquery>
					
					
					<cfquery name="project_agent" datasource="uam_god">
						update project_agent set
						agent_id = #bads.related_agent_id# where
						agent_id = #bads.agent_id#
					</cfquery>
					

					got project_agent<br><cfflush>
				
				
				
					<cfquery name="agent_status" datasource="uam_god">
						update agent_status set
						agent_id = #bads.related_agent_id# where
						agent_id = #bads.agent_id#
					</cfquery>
					got agent_status<br><cfflush>
				
			



					<cfquery name="related" datasource="uam_god">
						DELETE FROM agent_relations WHERE agent_id = #bads.agent_id# OR related_agent_id = #bads.agent_id#
					</cfquery>
					NO SKIPPED del agntreln<br><cfflush>
					<cfquery name="killnames" datasource="uam_god">
						DELETE FROM agent_name WHERE agent_id = #bads.agent_id#
					</cfquery>
					del agntname<br><cfflush>
					
					
					<cfquery name="killagent" datasource="uam_god">
						DELETE FROM agent WHERE agent_id = #bads.agent_id#
					</cfquery>
					del agnt<br><cfflush>
					
					<!--- send email & mark as merged --->
					
					<cfquery name="sentEmail" datasource="uam_god">
						update 
							cf_dup_agent
						set 
							status='merged',
							last_date=sysdate
						where
							cf_dup_agent_id=#cf_dup_agent_id#
					</cfquery>
					<cfinvoke component="component.functions" method="agentCollectionContacts" returnvariable="colns">
						<cfinvokeargument name="agent_id" value="#bads.related_agent_id#,#bads.agent_id#">
					</cfinvoke>
					<cfif len(valuelist(colns.address)) gt 0>
						<cfset mailto=valuelist(colns.address)>
					<cfelse>
						<cfset mailto=Application.DataProblemReportEmail>
					</cfif>
					
					
											<br>Agent merger for #bads.agent_pref_name# --> #bads.rel_agent_pref_name# is complete.


					<cfmail to="#mailto#" subject="agent merger success" cc="#Application.bugReportEmail#,#Application.DataProblemReportEmail#" from="agentmerge@#Application.fromEmail#" type="html">
						<br>Agent merger for #bads.agent_pref_name# --> #bads.rel_agent_pref_name# is complete.
					</cfmail>
					
					
					.........commit...
					<cfcatch>
					.........rollback...
						<cftransaction action="rollback">
							<cfdump var=#cfcatch#>
							
							
							<!-----
							<cfquery name="sentEmail" datasource="uam_god">
								update 
									cf_dup_agent
								set 
									status='catch: #cfcatch.message#',
									last_date=sysdate
								where
									cf_dup_agent_id=#cf_dup_agent_id#
							</cfquery>
							<cfmail to="#Application.PageProblemEmail#" subject="agent merger failed" from="agentmerge@#Application.fromEmail#" type="html">
								<br>Agent merger for #bads.agent_pref_name# --> #bads.rel_agent_pref_name# failed and was rolled back.
								<br>
								
								cleanup SQL: update cf_dup_agent set last_date=sysdate-8,status='pass_email_sent' where AGENT_ID=#bads.agent_id#;
								<br>cfcatch dump follows.
								<br>
								<cfdump var=#cfcatch#>
							</cfmail>
							----->
					</cfcatch>
					</cftry>
				</cftransaction>
				
				
				
				
			<!-----
			<cftry>
			
				<cfcatch>
					<cfset s='merged_failed: #cfcatch.message#: #cfcatch.detail#'>1
					<cfquery name="disableTrig" datasource="uam_god">
						alter trigger TR_AGENT_NAME_BIUD enable
					</cfquery>
					<cfquery name="sentEmail" datasource="uam_god">
						update 
							cf_dup_agent
						set 
							status='#escapeQuotes(left(s,250))#',
							last_date=sysdate
						where
							cf_dup_agent_id=#cf_dup_agent_id#
					</cfquery>
					<cfdump var=#cfcatch#>
				</cfcatch>
				</cftry>
				---->
		</cfloop>
		
		
<!---------- have to disable triggers outside the transaction --









<cfquery name="enableTrig" datasource="uam_god">
	alter trigger TR_AGENT_NAME_BIUD enable
</cfquery>

---------------->

	
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------>
<cfif action is "findDups">
	<cfquery name="findDups" datasource="uam_god">
		select 
			agent_relations.AGENT_ID,
			agent_relations.RELATED_AGENT_ID
		from
			agent_relations,
			cf_dup_agent
		where
			AGENT_RELATIONSHIP='bad duplicate of' and 
			agent_relations.AGENT_ID=cf_dup_agent.AGENT_ID (+) and
			 agent_relations.RELATED_AGENT_ID=cf_dup_agent.RELATED_AGENT_ID (+) and
			cf_dup_agent.AGENT_ID is null and
			cf_dup_agent.RELATED_AGENT_ID is null	
	</cfquery>
	<cfloop query="findDups">
		<cfquery name="findedDups" datasource="uam_god">
			insert into cf_dup_agent (
				AGENT_ID,
				RELATED_AGENT_ID,
				agent_pref_name,
				rel_agent_pref_name,
				detected_date,
				status,
				last_date
			) values (
				#AGENT_ID#,
				#RELATED_AGENT_ID#,
				(select agent_name from preferred_agent_name where agent_id=#AGENT_ID#),
				(select agent_name from preferred_agent_name where agent_id=#RELATED_AGENT_ID#),
				sysdate,
				'new',
				sysdate-7
			)
		</cfquery>
	</cfloop>
</cfif>
<!------------------------------------------------------------------------>
<cfif action is "notify">
	<cfoutput>
		<cfquery name="findDups" datasource="uam_god">
			select 
				cf_dup_agent.cf_dup_agent_id,
				agent_relations.AGENT_ID,
				agent_relations.RELATED_AGENT_ID,
				cf_dup_agent.agent_pref_name,
				cf_dup_agent.rel_agent_pref_name,
				detected_date,
				last_date,
				round(sysdate-last_date) days_since_last,
				status
			from
				agent_relations,
				cf_dup_agent
			where
				AGENT_RELATIONSHIP='bad duplicate of' and 
				agent_relations.AGENT_ID=cf_dup_agent.AGENT_ID and
				agent_relations.RELATED_AGENT_ID=cf_dup_agent.RELATED_AGENT_ID and
				(
					(status='new') or
					(round(sysdate-last_date) >= 1 and
					status not in ('pass_email_sent','merged'))
				)
		</cfquery>
		<cfloop query="findDups">
			<cfset theseAgents="#findDups.AGENT_ID#,#findDups.RELATED_AGENT_ID#">
			<cfinvoke component="component.functions" method="agentCollectionContacts" returnvariable="colns">
				<cfinvokeargument name="agent_id" value="#theseAgents#">
			</cfinvoke>
			<cfquery name="agent_relations" datasource="uam_god">
				select count(*) cnt from agent_relations where 
					(agent_id=#findDups.agent_id# OR related_agent_id = #findDups.agent_id#)
					AND NOT (
					(related_agent_id = #findDups.related_agent_id# AND agent_id = #findDups.agent_id# AND agent_relationship = 'bad duplicate of')
					OR (related_agent_id = #findDups.agent_id# AND agent_id = #findDups.related_agent_id# AND agent_relationship = 'good duplicate of')
					)
			</cfquery>
			
			
			<!--------------------->
			<cfmail to="#Application.DataProblemReportEmail#,#valuelist(colns.address)#" subject="agents marked for merge" from="agentmerge@#Application.fromEmail#" type="html">
				<br>Agents have been marked for merger.
				
				<br>The following agents are scheduled for merger on #dateformat(dateadd("d",7,detected_date),"yyyy-mm-dd")#.
				
				<br>#findDups.agent_pref_name# is a bad duplicate of #findDups.rel_agent_pref_name#.
				
				<br>To allow this merger, do nothing.
			
				<br>To stop this merger, remove the "bad duplicate of" relationship.
				
				<br>To permanently stop this merger, add a "not the same as" relationship.
				
				<hr>
				
				<br>You are receiving this notification because one of more of the agents may have activities pertaining to
				your collections. See Agent Activity for complete information.
				<br>Log in to Arctos before clicking the links below.
				
				<br>
				
				<a href="#Application.serverRootUrl#/Admin/ActivityLog.cfm?action=search&sql=#findDups.AGENT_ID#&object=agent_relations">search audit logs for whodunit</a> (possible 24h delay)
				
				<br>Good Agent: <a href="#Application.serverRootUrl#/agents.cfm?agent_id=#findDups.RELATED_AGENT_ID#">#findDups.rel_agent_pref_name#</a>
				<br>Duplicate Agent: <a href="#Application.serverRootUrl#/agents.cfm?agent_id=#findDups.AGENT_ID#">#findDups.agent_pref_name#</a>
				<br>Marked As Dup On: #dateformat(detected_date,"yyyy-mm-dd")#
				<br>Last Action: #dateformat(last_date,"yyyy-mm-dd")#
				<br>Status: #status#
			</cfmail>

		
			
			<cfquery name="sentEmail" datasource="uam_god">
				update 
					cf_dup_agent
				set 
					status='pass_email_sent',
					last_date=sysdate 
				where
					cf_dup_agent_id=#cf_dup_agent_id#
			</cfquery>
		</cfloop>
	</cfoutput>
</cfif>

<cfinclude template="/includes/_footer.cfm">