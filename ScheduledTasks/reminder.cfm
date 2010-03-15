<cfinclude template="/includes/_header.cfm">
	<cfoutput>
		<cfset eid="-30,-7,0,7,30,60,90,120,150,180">
		<cfquery name="expLoan" datasource="uam_god">
			select 
				loan.transaction_id,
				RETURN_DUE_DATE,
				LOAN_NUMBER,
				electronic_address.address,
				round(RETURN_DUE_DATE - sysdate)+1 expires_in_days,
				trans_agent.trans_agent_role,
				preferred_agent_name.agent_name,
				nnName.agent_name collection_agent_name,
				nnAddr.address collection_email,
				collection,
				collection.collection_id,
				nature_of_material
			FROM 
				loan,
				trans,
				collection,
				trans_agent,
				preferred_agent_name,
				preferred_agent_name nnName,
				(select * from electronic_address where address_type='e-mail') electronic_address,
				(select * from electronic_address where address_type='e-mail') nnAddr,
				(select * from collection_contacts where contact_role='loan request') collection_contacts
			WHERE
				loan.transaction_id = trans.transaction_id AND
				trans.collection_id=collection_contacts.collection_id (+) and
				trans.collection_id=collection.collection_id and
				collection_contacts.contact_agent_id=nnName.agent_id (+) and
				collection_contacts.contact_agent_id=nnAddr.agent_id (+) and
				trans.transaction_id=trans_agent.transaction_id and
				trans_agent.agent_id = preferred_agent_name.agent_id AND
				preferred_agent_name.agent_id = electronic_address.agent_id AND
				electronic_address.ADDRESS_TYPE='e-mail' AND
				trans_agent.trans_agent_role in ('notification contact','in-house contact') and
				round(RETURN_DUE_DATE - sysdate) +1 in (#eid#) and 
				LOAN_STATUS != 'closed'
		</cfquery>
		<cfdump var=#expLoan#>

		<cfquery name="loan" dbtype="query">
			select
				transaction_id,
				RETURN_DUE_DATE,
				LOAN_NUMBER,
				expires_in_days,
				collection,
				nature_of_material,
				collection_id
			from
				expLoan
			group by
				transaction_id,
				RETURN_DUE_DATE,
				LOAN_NUMBER,
				expires_in_days,
				collection,
				nature_of_material,
				collection_id
		</cfquery>
		<cfdump var=#loan#>
		<cfloop query="loan">
			#LOAN_NUMBER#
			<br>
			<cfquery name="inhouseAgents" dbtype="query">
				select
					address,
					agent_name
				from
					expLoan
				where
					transaction_id=#transaction_id# and
					trans_agent_role='in-house contact'
				group by
					address,
					agent_name
			</cfquery>
			<cfquery name="notificationAgents" dbtype="query">
				select
					address,
					agent_name
				from
					expLoan
				where
					transaction_id=#transaction_id# and
					trans_agent_role='notification contact'
				group by
					address,
					agent_name
			</cfquery>
			<cfquery name="collectionAgents" dbtype="query">
				select
					collection_agent_name,
					collection_email
				from
					expLoan
				where
					transaction_id=#transaction_id#
				group by
					collection_agent_name,
					collection_email
			</cfquery>
			
			<cfdump var=#inhouseAgents#>
			<cfdump var=#notificationAgents#>
			<cfdump var=#collectionAgents#>
			<cfif expires_in_days lt 0>
				<cfset c="Dear #valuelist(notificationAgents.agent_name)#,">
				<cfset c=c&"<p>You are receiving this message because you are listed as a contact for loan #collection# #loan_number#, which is due on #return_due_date#.</p>">
				<cfset c=c&"<p>Do not reply to this email.">
				<cfif notificationAgents.recordcount gt 0>
					<cfset c=c & "Contact the following with any questions or concerns:<ul>">
					<cfloop query="notificationAgents">
						<cfset c=c & "<li>#agent_name#: #address#</li>">
					</cfloop>
					<cfset c=c & "</ul>">
				<cfelseif collectionAgents.recordcount gt 0>
					<cfset c=c & "Contact the following with any questions or concerns:<ul>">
					<cfloop query="collectionAgents">
						<cfset c=c & "<li>#collection_agent_name#: #collection_email#</li>">
					</cfloop>
					<cfset c=c & "</ul>">
				<cfelse>
					<cfset c=c & 'Please contact the Arctos folks by visiting <a href="#application.serverRootUrl#/contact.cfm">#application.serverRootUrl#/contact.cfm</a>'>
				</cfif>
				<cfset c=c & "</p><p>The nature of the loaned material is:<blockquote>#nature_of_material#</blockquote></p>">
				<cfset c=c & "<p>Loaned specimen data, unless restricted, may be accessed at ">
				<cfset c=c & '<a href="#application.serverRootUrl#/SpecimenDetail.cfm?collection_id=#collection_id#&loan_number=#loan_number#">#application.serverRootUrl#/SpecimenDetail.cfm?collection_id=#collection_id#&loan_number=#loan_number#</a></p>".'>
				<hr>#c#<hr>
			
			
			</cfif>
			
------------------------------
Dear {notification_contact.preferred_agent_name},







{nature_of_material}


			<hr>
		</cfloop>
		<!----
		<cfloop query="expLoan">
			<cfquery name="expLoanAddr" dbtype="query">
				select ADDRESS from expLoan where AUTH_AGENT_ID=#expLoan.AUTH_AGENT_ID#
				group by ADDRESS
			</cfquery>
			<cfquery name="expLoanIndiv" dbtype="query">
				select * from expLoan where AUTH_AGENT_ID=#AUTH_AGENT_ID# order by expires_in_days
			</cfquery>
			<cfmail to="#expLoan.ADDRESS#" subject="Loans Due" from="reminder@#Application.fromEmail#" type="html">
				The following loans are coming due:
				<p>
					<cfloop query="expLoanIndiv">
						<a href="#Application.ServerRootUrl#/Loan.cfm?Action=editLoan&transaction_id=#transaction_id#">
							Loan##: #LOAN_NUMBER#</a> to #agent_name# is due on #dateformat(RETURN_DUE_DATE,'dd mmm yyyy')# (#expires_in_days# days)<br>
					</cfloop>
				</p>
			</cfmail>
		</cfloop>
	<!------------------- loan ---------------->
	I propose the following, all only for loans where loan_status is not "closed" and return_due_date is not NULL, and all dependent on agents having email addresses and loans having useful contacts.

return_due_date - 30: send email to "notification contact"
return_due_date - 7: send email to "notification contact" and "in-house contact"
return_due_date: send email to  "notification contact" and "in-house contact"
return_due_date + 7: send email to "in-house contact" and collection's "loan request" contact
return_due_date + 30, and every 30-day anniversary thereof: send email to "in-house contact" and collection's "loan request" contact

And a proposal for a pleasant pre-due contact form, sent as HTML email from loan_notification@arctos.database.museum:

------------------------------
Dear {notification_contact.preferred_agent_name},

You are receiving this message because you are listed as a contact for loan {collection} {loan number}, which is due on {due date}.

Do not reply to this email. Contact {in-house contact preferred name} at {in-house contact email address} with any questions or concerns.

The nature of the loaned material is:

{nature_of_material}

Loaned specimen data, unless restricted, may be accessed at {URL to specimens involved in the loan}.
------------------------------



And angry past-due notice, sent only to in-house contact and collection's "loan request" agents, beginning at return_due_date + 7:

------------------------------
Dear {in-house contact and loan request agent},

You are receiving this message because loan {collection} {loan number} is {days past due} days past it's due date of {due date}.

If this loan has been extended or renewed, please update the loan status at {edit loan link that works for signed-in operators}.
------------------------------
	
	
	
	
	
	
	

	
	
	<!----------- permit ------------>
		<cfset cInt = "365,180,30,0">
		<cfloop list="#cInt#" index="inDays">
			<cfquery name="permitExpOneYear" datasource="uam_god">
				select
					permit_id,
					EXP_DATE,
					PERMIT_NUM,
					ADDRESS,
					round(EXP_DATE - sysdate) expires_in_days,
					EXP_DATE,
					CONTACT_AGENT_ID
				FROM
					permit,
					electronic_address			
				WHERE
					permit.CONTACT_AGENT_ID = electronic_address.agent_id AND
					ADDRESS_TYPE='e-mail' AND
					round(EXP_DATE - sysdate) = #inDays#
			</cfquery>
			<cfquery name="expYearID" dbtype="query">
				select CONTACT_AGENT_ID from permitExpOneYear group by CONTACT_AGENT_ID
			</cfquery>
			<cfloop query="permitExpOneYear">
				<cfquery name="permitExpOneYearnames" dbtype="query">
					select ADDRESS from permitExpOneYear where CONTACT_AGENT_ID=#permitExpOneYear.CONTACT_AGENT_ID#
					group by ADDRESS
				</cfquery>
				<cfquery name="permitExpOneYearIndiv" dbtype="query">
					select * from permitExpOneYear where CONTACT_AGENT_ID=#CONTACT_AGENT_ID# order by expires_in_days
				</cfquery>
				<cfmail to="#permitExpOneYearnames.ADDRESS#" subject="Expiring Permits" from="reminder@#Application.fromEmail#" type="html">
					You are receiving this message because you are the contact person for the permits listed below, which are expiring.
					<p>
						<cfloop query="permitExpOneYearIndiv">
							<a href="#Application.ServerRootUrl#/Permit.cfm?Action=search&permit_id=#permit_id#">Permit##: #PERMIT_NUM#</a> expires on #dateformat(exp_date,'dd mmm yyyy')# (#expires_in_days# days)<br>
						</cfloop>
					</p>
				</cfmail>
			</cfloop>
		</cfloop>
		
		
			--->
			
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">