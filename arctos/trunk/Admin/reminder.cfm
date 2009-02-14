<cfinclude template="/includes/_header.cfm">
	<!--- check to see if permits are expiring and send email (if available) if they are --->
	<!--- only allow this script to run on the first day of the month --->
	<cfset dayOfMonth = datepart("d",now())>
	<cfoutput>
		<cfif #dayOfMonth# is not 1>
			This script only runs on the first of the month.
		<cfelse>
			<cfquery name="permitExp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					permit_id,
					EXP_DATE,
					PERMIT_NUM,
					CONTACT_AGENT_ID
				FROM permit
			</cfquery>
			<cfloop query="permitExp">
				<!--- loop through all permits and see if they're about to expire --->
				<cfset whine = "">
				<cfif len(#exp_Date#) gt 0>
					<cfset ExpiresInDays = #datediff("d",now(),exp_Date)#>
					<cfif #ExpiresInDays# gt -30 and #ExpiresInDays# lt 181>
						<cfset whine = "
							<a href=""http://arctos.database.museum/Permit.cfm?Action=search&permit_id=#permit_id#"">Permit #PERMIT_NUM#</a> expires on #dateformat(exp_date,'dd mmm yyyy')# (#ExpiresInDays# days)">
						
					</cfif>
				<cfelse>
					<!--- there's a permit with no exp date - treat this as bad! --->
					<cfset whine = "
						<a href=""http://arctos.database.museum/Permit.cfm?Action=search&permit_id=#permit_id#"">Permit #PERMIT_NUM#</a>
						 has no expiration date. That isn't illegal, but it's probably bad!<br>">
				</cfif>
				<cfif len(#whine#) gt 0>
					<cfif len(#CONTACT_AGENT_ID#) gt 0>
						<cfquery name="email" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							SELECT
								ADDRESS
							FROM
								electronic_address
							WHERE
								AGENT_ID=#CONTACT_AGENT_ID# and
								ADDRESS_TYPE='e-mail'
						</cfquery>
						<cfif  #email.recordcount# is 0>
							<cfset thisMail = "fndlm@uaf.edu">
							<cfset whine = "#whine# <hr>You are getting this because the contact agent for this
								permit has no email address recorded. Please review the permit and
								their address list. <hr> #whine#">
						<cfelseif #email.recordcount# is 1>
							<cfset thisMail = #email.address#>
						<cfelse>
							<cfset thisMail = "">
							<cfloop query="email">
								<cfif len(#thisMail#) is 0>
									<cfset thisMail = #address#>
								<cfelse>
									<cfset thisMail = "#thisMail#,#address#">
								</cfif>
							</cfloop>
						</cfif>
					<cfelse><!--- no contact --->
						<cfset thisMail = "fndlm@uaf.edu">
						<cfset whine = "#whine# <hr>You are getting this because there is no contact agent for this
							permit. Please review the permit and notify the appropriate persons that it is
							expiring. <hr> #whine#">
					</cfif>
					
					<cfset whine = "This is an automated message sent out on the first of every month to remind 
					you that the following permit is expiring. You will receive one email for every expiring permit. 
					If you are not the correct contact, please 
					pass this message on to the appropriate person(s). You may have to log in to the database 
					before the links in this message will work properly. <p>
					#whine# ">
					<cfmail to="#thisMail#" subject="Your permits are expiring" from="#mailFromAddress#" type="html">
						#whine#
					</cfmail>
					#whine#
					<hr><hr>
				</cfif>
			</cfloop>
		</cfif>
	</cfoutput>
	
	
<cfinclude template="/includes/_footer.cfm">