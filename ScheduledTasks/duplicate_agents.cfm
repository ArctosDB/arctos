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
			
	
	<cfquery name="entered" datasource="uam_god">
		
	</cfquery>
	<ul>
		<cfloop query="entered">
			<li>
				<a href="/SpecimenResults.cfm?entered_by_id=#agent_id#&collection_id=#collection_id#">#cnt# #collection#</a> specimens
			</li>
		</cfloop>
	</ul>
Edited:	
	<cfquery name="last_edit" datasource="uam_god">
		select 
			count(*) cnt,
			collection,
			collection.collection_id
		from 
			coll_object,
			cataloged_item,
			collection
		where 
			coll_object.collection_object_id = cataloged_item.collection_object_id and
			cataloged_item.collection_id=collection.collection_id and
			LAST_EDITED_PERSON_ID=#agent_id#
		group by
			collection,
			collection.collection_id
	</cfquery>
	<ul>
		<cfloop query="last_edit">
			<li>
				<a href="/SpecimenResults.cfm?edited_by_id=#agent_id#&collection_id=#collection_id#">#cnt# #collection#</a> specimens
			</li>
		</cfloop>
	</ul>
Attribute Determiner:
	<cfquery name="attributes" datasource="uam_god">
		select 
			count(attributes.collection_object_id) c,
			count(distinct(cataloged_item.collection_object_id)) s,
			collection.collection_id,
			collection 
		from
			attributes,
			cataloged_item,
			collection
		where
			cataloged_item.collection_object_id=attributes.collection_object_id and
			cataloged_item.collection_id=collection.collection_id and
			determined_by_agent_id=#agent_id#
		group by
			collection.collection_id,
			collection 
	</cfquery>
	<ul>
		<cfloop query="attributes">
			<li>
				#c# attributes for #s#
				<a href="/SpecimenResults.cfm?attributed_determiner_agent_id=#agent_id#&collection_id=#attributes.collection_id#">
					#attributes.collection#</a> specimens
			</li>
		</cfloop>
	</ul>
Media:
	<cfquery name="media" datasource="uam_god">
		select media_id from media_relations where media_relationship like '% agent' and
		related_primary_key=#agent_id#
	</cfquery>
	<cfquery name="media_assd_relations" datasource="uam_god">
		select media_id from media_relations where CREATED_BY_AGENT_ID=#agent_id#
	</cfquery>
	<cfquery name="media_labels" datasource="uam_god">
		select media_id from media_labels where ASSIGNED_BY_AGENT_ID=#agent_id#
	</cfquery>
	<ul>
		<li>
			Subject of #media.recordcount# <a href="/MediaSearch.cfm?action=search&related_primary_key__1=#agent_id#"> Media entries.</a>
		</li>
		<li>
			Assigned #media_assd_relations.recordcount# Media Relationships.
		</li>
		<li>
			Assigned #media_labels.recordcount# Media Labels.
		</li>
	</ul>
Encumbrances:
	<ul>
		<cfquery name="encumbrance" datasource="uam_god">
			select count(*) cnt from encumbrance where encumbering_agent_id=#agent_id#
		</cfquery>
		<cfquery name="coll_object_encumbrance" datasource="uam_god">
			select 
				count(distinct(coll_object_encumbrance.collection_object_id)) specs,
				collection,
				collection.collection_id
			 from 
			 	encumbrance,
			 	coll_object_encumbrance,
			 	cataloged_item,
			 	collection
			 where
			 	encumbrance.encumbrance_id = coll_object_encumbrance.encumbrance_id and
			 	coll_object_encumbrance.collection_object_id=cataloged_item.collection_object_id and
			 	cataloged_item.collection_id=collection.collection_id and
			 	encumbering_agent_id=#agent_id#
			 group by
			 	collection,
				collection.collection_id
		</cfquery>
		<li>Owns #encumbrance.cnt# encumbrances</li>
		<cfloop query="coll_object_encumbrance">
			<li>Encumbered <a href="/SpecimenResults.cfm?encumbering_agent_id=#agent_id#&collection_id=#collection_id#">
				#specs# #collection#</a> records</li>
		</cfloop>
	</ul>
Identification:
	<cfquery name="identification" datasource="uam_god">
		select 
			count(*) cnt, 
			count(distinct(identification.collection_object_id)) specs,
			collection.collection_id,
			collection.collection
		from 
        	identification,
        	identification_agent,
			cataloged_item,
			collection
        where 
        	cataloged_item.collection_id=collection.collection_id and
			cataloged_item.collection_object_id=identification.collection_object_id and
			identification.identification_id=identification_agent.identification_id and
        	identification_agent.agent_id=#agent_id#
		group by
			collection.collection_id,
			collection.collection
	</cfquery>
	<ul>
		<cfloop query="identification">
			<li>
				#cnt# identifications for <a href="/SpecimenResults.cfm?identified_agent_id=#agent_id#&collection_id=#collection_id#">
					#specs# #collection#</a> specimens
			</li>
		</cfloop>
	</ul>
Coordinates:
	<cfquery name="lat_long" datasource="uam_god">
		select 
			count(*) cnt,
			count(distinct(locality_id)) locs from lat_long where determined_by_agent_id=#agent_id#
	</cfquery>
	<ul>
		<li>Determined #lat_long.cnt# coordinates for #lat_long.locs# localities</li>
	</ul>
Permits:	
	<cfquery name="permit_to" datasource="uam_god">
		select 
			PERMIT_NUM,
			PERMIT_TYPE 
		from 
			permit 
		where 
			ISSUED_TO_AGENT_ID=#agent_id#
	</cfquery>
	<ul>
		<cfloop query="permit_to">
			<li>
				Permit <a href="/Permit.cfm?action=search&ISSUED_TO_AGENT_ID=#agent_id#">#PERMIT_NUM#: #PERMIT_TYPE#</a> was issued to
			</li>
		</cfloop>
		<cfquery name="permit_by" datasource="uam_god">
			select 
				PERMIT_NUM,
				PERMIT_TYPE 
			from 
				permit 
			where ISSUED_by_AGENT_ID=#agent_id#
		</cfquery>
		<cfloop query="permit_by">
			<li>
				Issued Permit <a href="/Permit.cfm?action=search&ISSUED_by_AGENT_ID=#agent_id#">#PERMIT_NUM#: #PERMIT_TYPE#</a>
			</li>
		</cfloop>
		<cfquery name="permit_contact" datasource="uam_god">
			select 
				PERMIT_NUM,
				PERMIT_TYPE 
			from 
				permit 
			where CONTACT_AGENT_ID=#agent_id#
		</cfquery>
		<cfloop query="permit_by">
			<li>
				Contact for Permit <a href="/Permit.cfm?action=search&CONTACT_AGENT_ID=#agent_id#">#PERMIT_NUM#: #PERMIT_TYPE#</a>
			</li>
		</cfloop>
	</ul>
Transactions
	<ul>
		<cfquery name="shipment" datasource="uam_god">
			select 
				LOAN_NUMBER,
				loan.transaction_id,
				collection
			from
				shipment,
				loan,
				trans,
				collection
			where
				shipment.transaction_id=loan.transaction_id and
				loan.transaction_id =trans.transaction_id and
				trans.collection_id=collection.collection_id and
				PACKED_BY_AGENT_ID=#agent_id#		
		</cfquery>
		<cfloop query="shipment">
			<li>Packed Shipment for <a href="/Loan.cfm?action=editLoan&transaction_id=#transaction_id#">#collection# #loan_number#</a></li>
		</cfloop>
		<cfquery name="ship_to" datasource="uam_god">
			select 
				LOAN_NUMBER,
				loan.transaction_id,
				collection
			from
				shipment,
				addr,
				loan,
				trans,
				collection
			where
				shipment.transaction_id=loan.transaction_id and
				loan.transaction_id =trans.transaction_id and
				trans.collection_id=collection.collection_id and
				shipment.SHIPPED_TO_ADDR_ID=addr.addr_id and
				addr.agent_id=#agent_id#
		</cfquery>
		<cfloop query="ship_to">
			<li><a href="/Loan.cfm?action=editLoan&transaction_id=#transaction_id#">#collection# #loan_number#</a> shipped to addr</li>
		</cfloop>
		<cfquery name="ship_from" datasource="uam_god">
			select 
				LOAN_NUMBER,
				loan.transaction_id,
				collection
			from
				shipment,
				addr,
				loan,
				trans,
				collection
			where
				shipment.transaction_id=loan.transaction_id and
				loan.transaction_id =trans.transaction_id and
				trans.collection_id=collection.collection_id and
				shipment.SHIPPED_FROM_ADDR_ID=addr.addr_id and
				addr.agent_id=#agent_id#
		</cfquery>
		<cfloop query="ship_from">
			<li><a href="/Loan.cfm?action=editLoan&transaction_id=#transaction_id#">#collection# #loan_number#</a> shipped from</li>
		</cfloop>
		<cfquery name="trans_agent_l" datasource="uam_god">
			select 
				loan.transaction_id,
				TRANS_AGENT_ROLE,
				loan_number,
				collection
			from
				trans_agent,
				loan,
				trans,
				collection
			where
				trans_agent.transaction_id=loan.transaction_id and
				loan.transaction_id=trans.transaction_id and
				trans.collection_id=collection.collection_id and
				AGENT_ID=#agent_id#
			group by
				loan.transaction_id,
				TRANS_AGENT_ROLE,
				loan_number,
				collection
			order by
				collection,
				loan_number,
				TRANS_AGENT_ROLE
		</cfquery>
		<cfloop query="trans_agent_l">
			<li>#TRANS_AGENT_ROLE# for Loan <a href="/Loan.cfm?action=editLoan&transaction_id=#transaction_id#">#collection# #loan_number#</a></li>
		</cfloop>
		<cfquery name="trans_agent_a" datasource="uam_god">
			select 
				accn.transaction_id,
				TRANS_AGENT_ROLE,
				accn_number,
				collection
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