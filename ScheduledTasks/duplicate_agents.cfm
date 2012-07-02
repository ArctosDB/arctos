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
			<cfset fail="">
			<cfquery name="addr" datasource="uam_god">
				select count(*) cnt from addr where agent_id=#bads.agent_id#
			</cfquery>
			<cfif addr.cnt gt 0>
				<cfset fail="Agent ID #bads.agent_id# has addresses.">
			</cfif>
			<cfquery name="electronic_address" datasource="uam_god">
				select count(*) cnt from electronic_address where agent_id=#bads.agent_id#
			</cfquery>
			<cfif electronic_address.cnt gt 0>
				<cfset fail="Agent ID #bads.agent_id# has electronic addresses.">
			</cfif>
			<cfif len(fail) gt 0>
				<br>fail: #fail#
				<cfquery name="sentEmail" datasource="uam_god">
					update 
						cf_dup_agent
					set 
						status='fail: #fail#',
						last_date=sysdate
					where
						cf_dup_agent_id=#cf_dup_agent_id#
				</cfquery>
				<cfmail to="arctos.database@gmail.com" subject="agent merger failed" cc="arctos.database@gmail.com" from="agentmerge@#Application.fromEmail#" type="html">
					<br>Agent merger for #bads.agent_pref_name# --> #bads.rel_agent_pref_name# failed.
					<br>fail reason: #fail#
				</cfmail>
			<cfelse>
				doing it...
				<cftransaction>
					<cftry>
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
						<cfquery name="lat_long" datasource="uam_god">
							update
							lat_long set 
							determined_by_agent_id = #bads.related_agent_id# where
							determined_by_agent_id = #bads.agent_id#
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
						got publication_agent<br><cfflush>
						<!----
						
						---->
						<cfquery name="related" datasource="uam_god">
							DELETE FROM agent_relations WHERE agent_id = #bads.agent_id# OR related_agent_id = #bads.agent_id#
						</cfquery>
						NO SKIPPED del agntreln<br><cfflush>
						
						<cfquery name="disableTrig" datasource="uam_god">
							alter trigger TR_AGENT_NAME_BIUD disable
						</cfquery>
						<cfquery name="killnames" datasource="uam_god">
							DELETE FROM agent_name WHERE agent_id = #bads.agent_id#
						</cfquery>
						del agntname<br><cfflush>
						
						
						<cfquery name="killperson" datasource="uam_god">
							DELETE FROM person WHERE person_id = #bads.agent_id#
						</cfquery>
						del person<br><cfflush>
						<cfquery name="killagent" datasource="uam_god">
							DELETE FROM agent WHERE agent_id = #bads.agent_id#
						</cfquery>
						<cfquery name="disableTrig" datasource="uam_god">
							alter trigger TR_AGENT_NAME_BIUD enable
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
						<cfmail to="arctos.database@gmail.com" subject="agent merger success" cc="arctos.database@gmail.com" from="agentmerge@#Application.fromEmail#" type="html">
							<br>---------------adjust email settings-----------------
							<br>Agent merger for #bads.agent_pref_name# --> #bads.rel_agent_pref_name# is complete.
						</cfmail>
						.........commit...
						<cftransaction action="commit">
						<cfcatch>
						.........rollback...
							<cftransaction action="rollback">
								<cfdump var=#cfcatch#>
								<cfquery name="sentEmail" datasource="uam_god">
									update 
										cf_dup_agent
									set 
										status='catch: #cfcatch.message#',
										last_date=sysdate
									where
										cf_dup_agent_id=#cf_dup_agent_id#
								</cfquery>
								<cfmail to="arctos.database@gmail.com" subject="agent merger failed" cc="arctos.database@gmail.com" from="agentmerge@#Application.fromEmail#" type="html">
									<br>---------------adjust email settings-----------------
									<br>Agent merger for #bads.agent_pref_name# --> #bads.rel_agent_pref_name# failed and was rolled back.
									<br>cfcatch dump follows.
									<br>
									<cfdump var=#cfcatch#>
								</cfmail>
						</cfcatch>
						</cftry>
					</cftransaction>
				</cfif>
				
				
				
				
			<!-----
			<cftry>
			
				<cfcatch>
					<cfset s='merged_failed: #cfcatch.message#: #cfcatch.detail#'>
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
			<cfquery name="colns" datasource="uam_god">
				select 
					agent_name,
					ADDRESS
				from
					collection_contacts,
					electronic_address,
					preferred_agent_name
				where
					collection_contacts.CONTACT_AGENT_ID=preferred_agent_name.agent_id and
					collection_contacts.CONTACT_AGENT_ID=electronic_address.agent_id and
					electronic_address.address_type='e-mail' and
					CONTACT_ROLE='data quality' and
					collection_contacts.collection_id in  (
				select 
					collection_id 
				from 
					cataloged_item,
					citation,
					publication_agent
				where
					cataloged_item.collection_object_id=citation.collection_object_id and
					citation.publication_id=publication_agent.publication_id and
					publication_agent.agent_id in (#theseAgents#)
				union
				select 
					cataloged_item.collection_id
				from 
					collector,
					cataloged_item
				where 
					collector.collection_object_id = cataloged_item.collection_object_id AND
					agent_id in (#theseAgents#)
				union
				select 
					collection_id
				from 
					coll_object,
					cataloged_item
				where 
					coll_object.collection_object_id = cataloged_item.collection_object_id and
					ENTERED_PERSON_ID in (#theseAgents#)
				union
				select 
					collection_id
				from 
					coll_object,
					cataloged_item
				where 
					coll_object.collection_object_id = cataloged_item.collection_object_id and
					LAST_EDITED_PERSON_ID in (#theseAgents#)
				union
					select 
						collection_id
					from
						attributes,
						cataloged_item
					where
						cataloged_item.collection_object_id=attributes.collection_object_id and
						determined_by_agent_id in (#theseAgents#)
				union
					select 
							collection_id
						 from 
						 	encumbrance,
						 	coll_object_encumbrance,
						 	cataloged_item
						 where
						 	encumbrance.encumbrance_id = coll_object_encumbrance.encumbrance_id and
						 	coll_object_encumbrance.collection_object_id=cataloged_item.collection_object_id and
						 	encumbering_agent_id in (#theseAgents#)
				union
					select 
						collection_id
					from 
			        	identification,
			        	identification_agent,
						cataloged_item
			        where 
						cataloged_item.collection_object_id=identification.collection_object_id and
						identification.identification_id=identification_agent.identification_id and
			        	identification_agent.agent_id in (#theseAgents#)
				union
					select 
						collection_id
					from 
						cataloged_item,
						collecting_event,
						lat_long 
					where 
						cataloged_item.collecting_event_id=collecting_event.collecting_event_id and
						collecting_event.locality_id=lat_long.locality_id and
						determined_by_agent_id in (#theseAgents#)
				union
					select 
							collection_id
						from
							shipment,
							loan,
							trans
						where
							shipment.transaction_id=loan.transaction_id and
							loan.transaction_id =trans.transaction_id and
							PACKED_BY_AGENT_ID in (#theseAgents#)
				union
					select 
										collection_id
						from
							shipment,
							addr,
							loan,
							trans
						where
							shipment.transaction_id=loan.transaction_id and
							loan.transaction_id =trans.transaction_id and
							shipment.SHIPPED_TO_ADDR_ID=addr.addr_id and
							addr.agent_id in (#theseAgents#)
				union
						select 							collection_id
						from
							shipment,
							addr,
							loan,
							trans
						where
							shipment.transaction_id=loan.transaction_id and
							loan.transaction_id =trans.transaction_id and
							shipment.SHIPPED_FROM_ADDR_ID=addr.addr_id and
							addr.agent_id in (#theseAgents#)
				union
						select 
							collection_id
						from
							trans_agent,
							loan,
							trans
						where
							trans_agent.transaction_id=loan.transaction_id and
							loan.transaction_id=trans.transaction_id and
							AGENT_ID in (#theseAgents#)
				union
						select 
							collection_id
						from
							trans_agent,
							accn,
							trans
						where
							trans_agent.transaction_id=accn.transaction_id and
							accn.transaction_id=trans.transaction_id and
							AGENT_ID in (#theseAgents#)
				union
						select 
							collection_id
						from
							trans,
							loan,
							loan_item
						where
							trans.transaction_id=loan.transaction_id and
							loan.transaction_id=loan_item.transaction_id and
							RECONCILED_BY_PERSON_ID in (#theseAgents#)
							)
				group by
					agent_name,
					ADDRESS
			</cfquery>
			<cfquery name="agent_relations" datasource="uam_god">
				select count(*) cnt from agent_relations where 
					(agent_id=#findDups.agent_id# OR related_agent_id = #findDups.agent_id#)
					AND NOT (
					(related_agent_id = #findDups.related_agent_id# AND agent_id = #findDups.agent_id# AND agent_relationship = 'bad duplicate of')
					OR (related_agent_id = #findDups.agent_id# AND agent_id = #findDups.related_agent_id# AND agent_relationship = 'good duplicate of')
					)
			</cfquery>
			<cfset prob="">		
			<cfif agent_relations.cnt gt 0>
				<cfset prob=listappend(prob,"The bad duplicate agents is involved in relationships.",";")>
			</cfif>
			<cfquery name="addr" datasource="uam_god">
				select count(*) cnt from addr where agent_id=#findDups.agent_id#
			</cfquery>
			<cfif addr.cnt gt 0>
				<cfset prob=listappend(prob,"The bad duplicate agent has addresses.",";")>
			</cfif>
			<cfquery name="electronic_address" datasource="uam_god">
				select count(*) cnt from electronic_address where agent_id=#findDups.agent_id#
			</cfquery>
			<cfif electronic_address.cnt gt 0>
				<cfset prob=listappend(prob,"The bad duplicate agent has electronic addresses.",";")>
			</cfif>
			<cfmail to="#Application.DataProblemReportEmail#,#valuelist(colns.address)#" subject="agents marked for merge" cc="arctos.database@gmail.com" from="agentmerge@#Application.fromEmail#" type="html">
				<br>Agents have been marked for merger.
				<br>#findDups.agent_pref_name# is a bad duplicate of #findDups.rel_agent_pref_name#.
				<br>The following agents are scheduled for merger on #dateformat(dateadd("d",7,detected_date),"yyyy-mm-dd")#.
				<cfif len(prob) gt 0>
					<p>
						The following must be fixed before the merger can proceed:
						<cfloop list="#prob#" delimiters=";" index="p">
							<br>#p#
						</cfloop>
					</p>
				<cfelse>
					<br>To allow this merger, do nothing.
				
					<br>To stop this merger, remove the "bad duplicate of" relationship.
				</cfif>
				
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
					<cfif len(prob) gt 0>
						status='fail_email_sent',
					<cfelse>
						status='pass_email_sent',
					</cfif>
					last_date=sysdate 
				where
					cf_dup_agent_id=#cf_dup_agent_id#
			</cfquery>
		</cfloop>
	</cfoutput>
</cfif>

<cfinclude template="/includes/_footer.cfm">