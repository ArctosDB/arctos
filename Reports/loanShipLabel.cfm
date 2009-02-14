<cf_
<!---
<cfdocument 
	format="pdf"
	pagetype="letter"
	margintop=".25"
	marginbottom=".25"
	marginleft=".25"
	marginright=".25"
	orientation="portrait"
	fontembed="yes" filename="#Application.webDirectory#/temp/loanShipLabel.pdf" overwrite="true">
	
<link rel="stylesheet" type="text/css" href="/includes/_cfdocstyle.css">

<cfquery name="getLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
        SELECT
                authAgent.agent_name  authAgentName,
                trans_date,
                recAgent.agent_name  recAgentName,
                return_due_date,
                nature_of_material,
                trans_remarks,
                loan_instructions,
                loan_description,
                loan_type,
                loan_number,
                loan_status,
                loan_instructions,
                authAddr.job_title  authorizerTitle,
                authAddr.formatted_addr  authorizerAddr,
                authAddrEmail.address  authEmail
        FROM
                loan
                inner join trans ON (loan.transaction_id = trans.transaction_id)
                inner join preferred_agent_name  recAgent ON (trans.received_agent_id = recAgent.agent_id)
                inner join preferred_agent_name  authAgent ON (trans.auth_agent_id = authAgent.agent_id)
               inner join addr authAddr ON (trans.auth_agent_id = authAddr.agent_id)
               inner join electronic_address  authAddrEmail ON (trans.auth_agent_id = authAddrEmail.agent_id)
        WHERE
                loan.transaction_id=#transaction_id# and
                authAddrEmail.address_type ='e-mail'
</cfquery>
	<cfquery name="shipTo" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select formatted_addr from addr, shipment
		where addr.addr_id = shipment.shipped_to_addr_id AND
		shipment.transaction_id=#transaction_id#
	</cfquery>
<cfoutput>
<table border="0" height="95%">
	<tr>
		<td>
			<table border="0" width="100%">
				<tr>
					<td align="right" valign="top">From:</td>
					<td>
						<span style="font-size:1.2em;font-weight:bold;">
							#getLoan.authorizerAddr#
							<br>&nbsp;
						</span>						
					</td>
				</tr>
			</table>
			<table width="100%">
				<tr>
					<td>
						<div style="width:200px;">
							&nbsp;
						</div>
					</td>
					<td align="right" valign="top">
						<span style="font-size:1.1em;">
							To:
						</span>
					</td>
					<td>
						<span style="font-size:2em;font-weight:bold;">
							#replace(shipTo.formatted_Addr,"#chr(10)#","<br>","all")#
						</span>
					</td>
				</tr>
				<tr>
					<td colspan="3" align="center">
						<span style="font-size:.8em;font-weight:bolder;">
						</span>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<div style="border-top:1px dashed black;width:100%">
			&nbsp;</div>
		</td>
	</tr>
	<tr>
		<td>
			<table border="0" width="100%">
				<tr>
					<td align="right" valign="top">From:</td>
					<td>
						<span style="font-size:1.2em;font-weight:bold;">
							#getLoan.authorizerAddr#
							<br>&nbsp;
						</span>						
					</td>
				</tr>
			</table>
			<table width="100%">
				<tr>
					<td>
						<div style="width:200px;">
							&nbsp;
						</div>
					</td>
					<td align="right" valign="top">
						<span style="font-size:1.1em;">
							To:
						</span>
					</td>
					<td>
						<span style="font-size:2em;font-weight:bold;">
							#replace(shipTo.formatted_Addr,"#chr(10)#","<br>","all")#
						</span>
					</td>
				</tr>
				<tr>
					<td colspan="3" align="center">
						Scientific Specimens - Museum Loan (Loan ## #getLoan.loan_number#)
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>

</cfoutput>
</cfdocument>

	<A href="/temp/loanShipLabel.pdf">Get the PDF</a>
	
	--->
