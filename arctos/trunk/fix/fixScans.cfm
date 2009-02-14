<cfoutput>
<!---
<cfquery name="s" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from scans
</cfquery>

<table border="1">
<tr><td>barcode</td>
<td>status</td>
</tr>
	<cfloop query="s">
		<tr>
			<td>#barcode#</td>
			<!---
			<cfquery name="wtf" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select container_type,container_id from container where
				barcode='#barcode#'
			</cfquery>
			---->
			
			<td>
				<!---
				<!--- clean up the bullshit that keeps getting passed back to me - again - grrrr.... --->
				<cfif #wtf.container_type# is "legacy container">
					<cfquery name="dammit" datasource="#Application.uam_dbo#">
						delete from scans where barcode='#barcode#'
					</cfquery>
				</cfif>
				--->
				
				<!---
				<!--- fix the specimen label --> legacy container thing (for TWO records!) --->
				<cfif #wtf.container_type# is "specimen label">
					<cfquery name="dammit" datasource="#Application.uam_dbo#">
						update container set container_type='legacy container'
						where barcode='#barcode#'
					</cfquery>
				</cfif>
				--->
				#wtf.recordcount#
			</td>
			<td>
				#wtf.container_type#
			</td>
		</tr>
	</cfloop>
	</table>
	--->
	<cfquery name="wtf" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select scans.barcode from scans,container 
				where scans.barcode=container.barcode (+) and
				container.barcode is null
			</cfquery>
			<table border>
			<cfquery name="n" datasource="#Application.uam_dbo#">
				select max(container_id) as container_id from container
			</cfquery>
			<cfset contid = #n.container_id# + 1>
			<cftransaction>
			<cfloop query="wtf">
				<tr>
					<td>#barcode#</td>
					<cfif #left(barcode,1)# is "L">
						<td>
						
						<cfquery name="nt" datasource="#Application.uam_dbo#">
							insert into container (
								CONTAINER_ID,
								PARENT_CONTAINER_ID,
								CONTAINER_TYPE,
								LABEL ,
								BARCODE ,
								LOCKED_POSITION,
								INSTITUTION_ACRONYM)
							values (
								#contid#,
								0,
								'tray',
								'#barcode#',
								'#barcode#',
								0,
								'UAM')
						</cfquery>
						tray</td>
					<cfelse>
						<cfquery name="nlc" datasource="#Application.uam_dbo#">
							insert into container (
								CONTAINER_ID,
								PARENT_CONTAINER_ID,
								CONTAINER_TYPE,
								LABEL ,
								BARCODE ,
								LOCKED_POSITION,
								INSTITUTION_ACRONYM)
							values (
								#contid#,
								0,
								'legacy container',
								'#barcode#',
								'#barcode#',
								0,
								'UAM')
						</cfquery>
						<td>--legacy container --</td>
					</cfif>
				</tr>
				<cfset contid = #contid# + 1>
			</cfloop>
			</cftransaction>
			</table>
</cfoutput>