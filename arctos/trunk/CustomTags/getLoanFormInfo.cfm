<cfoutput>
<cfset transaction_id=caller.transaction_id>
<cfquery name="caller.getLoan" datasource="#Application.web_user#">
       SELECT
	trans_date,
    concattransagent(trans.transaction_id, 'authorized by') authAgentName,
    concattransagent(trans.transaction_id, 'received by')   recAgentName,
    outside_contact.agent_name outside_contact_name,
    inside_contact.agent_name inside_contact_name,
	outside_addr.job_title  outside_contact_title,
	inside_addr.job_title  inside_contact_title,
	inside_addr.FORMATTED_ADDR inside_address,
	outside_addr.FORMATTED_ADDR outside_address,
	inside_email.address inside_email_address,
	outside_email.address outside_email_address,
               return_due_date,
                nature_of_material,
                trans_remarks,
                loan_instructions,
                loan_description,
                loan_type,
                loan_number,
                loan_status,
				shipped_date,
				ship_to_addr.formatted_addr  shipped_to_address   ,
				ship_from_addr.formatted_addr  shipped_from_address  ,
				processed_by.agent_name processed_by_name   
        FROM
                loan,
				trans,
				trans_agent inside_trans_agent,
				trans_agent outside_trans_agent,
				preferred_agent_name outside_contact,
				preferred_agent_name inside_contact,								
				(select * from electronic_address where address_type ='e-mail') inside_email,
				(select * from electronic_address where address_type ='e-mail') outside_email,
				(select * from addr where addr_type='Correspondence') outside_addr,
				(select * from addr where addr_type='Correspondence') inside_addr,
				shipment,
				(select * from addr where addr_type='Shipping') ship_to_addr,
				(select * from addr where addr_type='Shipping') ship_from_addr,
				preferred_agent_name processed_by
        WHERE
                loan.transaction_id = trans.transaction_id and
				trans.transaction_id = inside_trans_agent.transaction_id and				
				inside_trans_agent.agent_id = inside_contact.agent_id and
				inside_trans_agent.trans_agent_role='in-house contact' and
				inside_trans_agent.agent_id = inside_email.agent_id (+) and
				inside_trans_agent.agent_id = inside_addr.agent_id (+) and	
				trans.transaction_id = outside_trans_agent.transaction_id and				
				outside_trans_agent.agent_id = outside_contact.agent_id (+) and
				outside_trans_agent.trans_agent_role='outside contact' and
				outside_trans_agent.agent_id = outside_email.agent_id (+) and
				outside_trans_agent.agent_id = outside_addr.agent_id (+) and
				loan.transaction_id = shipment.transaction_id (+) and
				shipment.SHIPPED_TO_ADDR_ID	= ship_to_addr.addr_id (+) and
				shipment.SHIPPED_FROM_ADDR_ID	= ship_from_addr.addr_id (+) and
				shipment.PACKED_BY_AGENT_ID = 	processed_by.agent_id (+) and					
				loan.transaction_id=#transaction_id#
		group by
			 	trans_date,
    concattransagent(trans.transaction_id, 'authorized by'),
    concattransagent(trans.transaction_id, 'received by')  ,
    outside_contact.agent_name,
    inside_contact.agent_name ,
	outside_addr.job_title  ,
	inside_addr.job_title  ,
	inside_addr.FORMATTED_ADDR ,
	outside_addr.FORMATTED_ADDR ,
	inside_email.address ,
	outside_email.address ,
               return_due_date,
                nature_of_material,
                trans_remarks,
                loan_instructions,
                loan_description,
                loan_type,
                loan_number,
                loan_status,
				shipped_date,
				ship_to_addr.formatted_addr     ,
				ship_from_addr.formatted_addr ,
				processed_by.agent_name             
</cfquery>
</cfoutput>