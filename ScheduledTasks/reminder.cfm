<cfinclude template="/includes/_header.cfm">
	<cfoutput>
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
					You are receiving this message because you are the contact person for the permits listed below.
					<p>
						<cfloop query="permitExpOneYearIndiv">
							<a href="#Application.ServerRootUrl#/Permit.cfm?Action=search&permit_id=#permit_id#">Permit##: #PERMIT_NUM#</a> expires on #dateformat(exp_date,'dd mmm yyyy')# (#expires_in_days# days)<br>
						</cfloop>
					</p>
				</cfmail>
			</cfloop>
		</cfloop>	

			<cfquery name="expLoan" datasource="uam_god">
				select 
					loan.transaction_id,
					RETURN_DUE_DATE,
					LOAN_NUMBER,
					agent_name,
					address,
					AUTH_AGENT_ID,
					round(RETURN_DUE_DATE - sysdate) expires_in_days
				FROM 
					loan,
					trans,
					preferred_agent_name,
					electronic_address
				WHERE
					loan.transaction_id = trans.transaction_id AND
					trans.RECEIVED_AGENT_ID = preferred_agent_name.agent_id AND
					trans.AUTH_AGENT_ID = electronic_address.agent_id AND
					ADDRESS_TYPE='e-mail' AND
					round(RETURN_DUE_DATE - sysdate) = 30 and 
					LOAN_STATUS != 'closed'
			</cfquery>
			<cfloop query="expLoan">
				<cfquery name="expLoanAddr" dbtype="query">
					select ADDRESS from expLoan where AUTH_AGENT_ID=#expLoan.AUTH_AGENT_ID#
					group by ADDRESS
				</cfquery>
				<cfquery name="expLoanIndiv" dbtype="query">
					select * from expLoan where AUTH_AGENT_ID=#AUTH_AGENT_ID# order by expires_in_days
				</cfquery>
				<cfmail to="#expLoan.ADDRESS#" subject="Loans Due" from="reminder@#Application.fromEmail#" type="html">
					The following loans are due within 30 days:
					<p>
						<cfloop query="expLoanIndiv">
							<a href="#Application.ServerRootUrl#/Loan.cfm?Action=editLoan&transaction_id=#transaction_id#">
								Loan##: #LOAN_NUMBER#</a> to #agent_name# is due on #dateformat(RETURN_DUE_DATE,'dd mmm yyyy')# (#expires_in_days# days)<br>
						</cfloop>
					</p>
				</cfmail>
			</cfloop>
	</cfoutput>
	
	
<cfinclude template="/includes/_footer.cfm">