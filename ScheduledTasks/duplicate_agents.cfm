<cfinclude template="/includes/_header.cfm">
<!---
create table cf_dup_agent (
	cf_dup_agent_id number not null,
	AGENT_ID number not null,
	RELATED_AGENT_ID number not null,
	agent_pref_name varchar2(255) not null,
	rel_agent_pref_name varchar2(255) not null,
	detected_date timestamp not null,
	resolved_date timestamp,
	status varchar2(255)
);

ALTER TABLE cf_dup_agent MODIFY resolved_date NULL;


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
				status
			) values (
				#AGENT_ID#,
				#RELATED_AGENT_ID#,
				(select agent_name from preferred_agent_name where agent_id=#AGENT_ID#),
				(select agent_name from preferred_agent_name where agent_id=#RELATED_AGENT_ID#),
				systimestamp,
				'new'
			)
		</cfquery>
	</cfloop>
</cfif>
<cfif action is "notify">
	<cfquery name="findDups" datasource="uam_god">
		select 
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
			 status='new'
	</cfquery>
	<cfset theseAgents="#findDups.AGENT_ID#,#findDups.RELATED_AGENT_ID#">
	<!--- need collections for both agents --->
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
	select 
		cataloged_item.collection_id
	from 
		collector,
		cataloged_item,
	where 
		collector.collection_object_id = cataloged_item.collection_object_id AND
		agent_id in (#theseAgents#)
		
	
	select 
		collection_id
	from 
		coll_object,
		cataloged_item
	where 
		coll_object.collection_object_id = cataloged_item.collection_object_id and
		ENTERED_PERSON_ID in (#theseAgents#)
	
	
	select 
			collection_id
		from 
			coll_object,
			cataloged_item
		where 
			coll_object.collection_object_id = cataloged_item.collection_object_id and
			LAST_EDITED_PERSON_ID in (#theseAgents#)
		
		
		select 
			collection_id
		from
			attributes,
			cataloged_item
		where
			cataloged_item.collection_object_id=attributes.collection_object_id and
			determined_by_agent_id in (#theseAgents#)
			
			
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
				
				
				
			select 
				collection_id
			from
				trans_agent,
				accn,
				trans,
				collection
			where
				trans_agent.transaction_id=accn.transaction_id and
				accn.transaction_id=trans.transaction_id and
				trans.collection_id=collection.collection_id and
				AGENT_ID=#agent_id#
			group by
				accn.transaction_id,
				TRANS_AGENT_ROLE,
				accn_number,
				collection
			order by
				collection,
				accn_number,
				TRANS_AGENT_ROLE
		</cfquery>
		<cfloop query="trans_agent_a">
			<li>#TRANS_AGENT_ROLE# for Accession <a href="/editAccn.cfm?action=edit&transaction_id=#transaction_id#">#collection# #accn_number#</a></li>
		</cfloop>
		<cfquery name="loan_item" datasource="uam_god">
			select 
				trans.transaction_id,
				loan_number,
				count(*) cnt,
				collection
			from
				trans,
				loan,
				collection,
				loan_item
			where
				trans.transaction_id=loan.transaction_id and
				loan.transaction_id=loan_item.transaction_id and
				trans.collection_id=collection.collection_id and
				RECONCILED_BY_PERSON_ID =#agent_id#
			group by
				trans.transaction_id,
				loan_number,
				collection				
		</cfquery>
		<cfloop query="loan_item">
			<li>Reconciled #cnt# items for Loan 
				<a href="/Loan.cfm?action=editLoan&transaction_id=#transaction_id#">#collection# #loan_number#</a>
			</li>		
		</cfloop>
	</ul>
</cfoutput>
<cfinclude template = "/includes/_footer.cfm">







	
	
	
	<cfdump var=#findDups#>
</cfif>

<cfinclude template="/includes/_footer.cfm">