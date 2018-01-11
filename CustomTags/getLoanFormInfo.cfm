<cfoutput>
	<!----
		over-ride the default of getting addresses only for active operators on this form
	---->
<cfset transaction_id=caller.transaction_id>
<cfquery name="caller.getLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
       SELECT
		trans_date,
	    concattransagent(trans.transaction_id, 'authorized by') authAgentName,
	    concattransagent(trans.transaction_id, 'received by')   recAgentName,
	    concattransagent(trans.transaction_id, 'outside contact')   outside_contact_name,
	    concattransagent(trans.transaction_id, 'inside contact')   inside_contact_name,
		getAgentNameType(outside_contact.agent_id,'job title') outside_contact_title,
		getAgentNameType(inside_contact.agent_id,'job title') inside_contact_title,
		get_address(inside_contact.agent_id,'correspondence',0) inside_address,
		get_address(outside_contact.agent_id,'correspondence',0) outside_address,
		get_address(inside_contact.agent_id,'email',0) inside_email_address,
		get_address(outside_contact.agent_id,'email',0) outside_email_address,
		loan.return_due_date,
		trans.nature_of_material,
		trans.trans_remarks,
		loan.loan_instructions,
		loan.loan_description,
		loan.loan_type,
		loan.loan_number,
		loan.loan_status,
		shipment.shipped_date,
		case when  concattransagent(trans.transaction_id, 'received by') !=  concattransagent(trans.transaction_id, 'outside contact')  then
			'Attn: ' || concattransagent(trans.transaction_id, 'outside contact') || '<br>' || ship_to_addr.address
		else
			ship_to_addr.address
		end  shipped_to_address,
		ship_from_addr.address  shipped_from_address,
		getPreferredAgentName(shipment.PACKED_BY_AGENT_ID) processed_by_name,
		getPreferredAgentName(project_sponsor.PROJECT_AGENT_ID) project_sponsor_name,
		PROJECT_AGENT_REMARKS acknowledgement
	FROM
		loan,
		trans,
		shipment,
		address ship_to_addr,
		address ship_from_addr,
		(select * from trans_agent where trans_agent_role='in-house contact') inside_contact,
		(select * from trans_agent where trans_agent_role='outside contact') outside_contact,
		project_trans,
		(select * from project_agent where project_agent_role='Sponsor') project_sponsor
	WHERE
		loan.transaction_id = trans.transaction_id and
		loan.transaction_id = shipment.transaction_id (+) and
		shipment.SHIPPED_TO_ADDR_ID	= ship_to_addr.address_id (+) and
		shipment.SHIPPED_FROM_ADDR_ID	= ship_from_addr.address_id (+) and
		trans.transaction_id = 	inside_contact.transaction_id (+) and
		trans.transaction_id = 	outside_contact.transaction_id (+) and
		trans.transaction_id = 	project_trans.transaction_id (+) and
		project_trans.project_id =	project_sponsor.project_id (+) and
		loan.transaction_id=#transaction_id#
	group by
		trans_date,
	    concattransagent(trans.transaction_id, 'authorized by'),
	    concattransagent(trans.transaction_id, 'received by')  ,
	    concattransagent(trans.transaction_id, 'outside contact'),
	    concattransagent(trans.transaction_id, 'inside contact'),
		getAgentNameType(outside_contact.agent_id,'job title'),
		getAgentNameType(inside_contact.agent_id,'job title'),
		get_address(inside_contact.agent_id,'correspondence',0),
		get_address(outside_contact.agent_id,'correspondence',0),
		get_address(inside_contact.agent_id,'email',0),
		get_address(outside_contact.agent_id,'email',0),
		loan.return_due_date,
		trans.nature_of_material,
		trans.trans_remarks,
		loan.loan_instructions,
		loan.loan_description,
		loan.loan_type,
		loan.loan_number,
		loan.loan_status,
		shipment.shipped_date,
		case when  concattransagent(trans.transaction_id, 'received by') !=  concattransagent(trans.transaction_id, 'outside contact')  then
			'Attn: ' || concattransagent(trans.transaction_id, 'outside contact') || '<br>' || ship_to_addr.address
		else
			ship_to_addr.address
		end ,
		ship_from_addr.address ,
		getPreferredAgentName(shipment.PACKED_BY_AGENT_ID),
		getPreferredAgentName(project_sponsor.PROJECT_AGENT_ID),
		PROJECT_AGENT_REMARKS
</cfquery>
</cfoutput>