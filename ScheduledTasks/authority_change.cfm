<cfinclude template="/includes/_header.cfm">
<!---- v7.9.7 contains geology separate; this merges --->
	<cfoutput>
		<cfset title="authority file changes">
		<cfset allChanges="">
		<cfset ctChanges="">
		<cfset today = Now()>
		<cfset yesterday = dateformat(today-1,'yyyy-mm-dd') >
		<cfparam name="start" default="#dateformat(yesterday,'yyyy-mm-dd')#" type="string">
		<cfparam name="stop" default="#dateformat(now(),'yyyy-mm-dd')#" type="string">
		DEFAULT is last 24 hours. You can change that by manipulating URL parameters. Example:
		<a href="authority_change.cfm?start=#start#&stop=#stop#">authority_change.cfm?start=#start#&stop=#stop#</a>
		<cfquery name="ctlogtbl" datasource="uam_god">
			select
				table_name
			FROM
				user_tables
			WHERE
				table_name like 'LOG_%'
		</cfquery>
		<cfloop query="ctlogtbl">
			<cfquery name="ctab" datasource="uam_god">
				select * from #table_name# where WHEN between to_date('#start#') and to_date('#stop#') order by when
			</cfquery>
			<cfif ctab.recordcount gt 0>
				<cfsavecontent variable="ctChanges">
					#ctChanges#
					<p>Table #replace(table_name,'LOG_','','all')#:</p>
					<table border>
						<tr>
						<cfloop list="#ctab.columnlist#" index="c">
							<th>#c#</th>
						</cfloop>
						</tr>
						<cfloop query="#ctab#">
							<tr>
								<cfloop list="#ctab.columnlist#" index="c">
									<td>#evaluate("ctab." & c)#</td>
								</cfloop>
							</tr>
						</cfloop>
					</table>
				</cfsavecontent>
			</cfif>
		</cfloop>
		<cfif len(ctChanges) gt 0>
			<cfsavecontent variable="ctChanges">
				<p>
					Code tables changed between #start# and #stop#.
					These data may reflect discarded changes, changes that have not been used in data, or changes that your
					user cannot access. Contact any Arctos Advisory Group member for more information.
					<br>Rows with only N_xxx (new) values are INSERTS.
					<br>Rows with only O_xxx (old) values are DELETES.
					<br>Rows with N_xxx and O_xxx values are UPDATES.
				</p>
				#ctChanges#
			</cfsavecontent>
		</cfif>

		<!--- append everything together ---->
		<cfset allChanges=ctChanges>
		<cfif len(allChanges) is 0>
			no changes.
			<cfabort>
		</cfif>
		<cfif action is "sendEmail">
			<cfquery name="cc" datasource="uam_god">
				select
					get_address(collection_contacts.CONTACT_AGENT_ID,'email') address
				FROM
					collection_contacts
				where
					collection_contacts.contact_role='data quality'
				group by
					get_address(collection_contacts.CONTACT_AGENT_ID,'email')
			</cfquery>
			<cfsavecontent variable="emailChanges">
				<p>
					Authority values have changed.
				</p>
				<p>
					You are receiving this report because you are a collection "data quality" contact,
					or because you are receiving forwarded email from arctos.database@gmail.com.
					Before attempting to view the report via the link below, sign in to Arctos. You must be logged in to view the report.
				</p>
				<p>
					This report is available at #application.serverRootURL#/ScheduledTasks/authority_change.cfm?start=#start#&stop=#stop#
				</p>
				<p>#allChanges#</p>
			</cfsavecontent>
			<cfif isdefined("Application.version") and  Application.version is "prod">
				<cfset subj="Arctos Authority Change Notification">
				<cfset maddr="#valuelist(cc.address)#, arctos.database@gmail.com">
			<cfelse>
				<cfset maddr=application.bugreportemail>
				<cfset subj="TEST PLEASE IGNORE: Arctos Authority Change Notification">
			</cfif>
			<cfmail to="#maddr#" subject="#subj#" from="authority_notification@#Application.fromEmail#" type="html">
				#emailChanges#
			</cfmail>
		<cfelse>
			<!--- just display ---->
			#allChanges#
		</cfif>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">