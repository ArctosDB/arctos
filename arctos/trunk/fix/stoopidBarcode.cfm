<cfabort>

<cfquery name="fu" datasource="#Application.uam_dbo#">
	select * from container where container_type='collection object'
	and barcode is not null
</cfquery>
<cfoutput>
	<cfquery name="m" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select max(container_id) container_id from container
	</cfquery>
	<cfset cid=#m.container_id# + 1>
	<cftransaction>
	<cfloop query="fu">
		<p>
		<cfquery name="killBC" datasource="#Application.uam_dbo#">
		UPDATE container SET parent_container_id=#cid#,barcode=null where
		container_id=#container_id#
		</cfquery>
		</p>
		<!--- make a new container --->
		<cfquery name="insCont" datasource="#Application.uam_dbo#">
		INSERT INTO container (
			CONTAINER_ID,
			PARENT_CONTAINER_ID,
			CONTAINER_TYPE,
			LABEL,
			<cfif len(#description#) gt 0>
				DESCRIPTION,
			</cfif>			
			PARENT_INSTALL_DATE,
			CONTAINER_REMARKS,
			BARCODE,
			locked_position)
		VALUES (
			#cid#,
			#parent_container_id#,
			'legacy container',
			'#label#',
			<cfif len(#description#) gt 0>
				'#description#',
			</cfif>	
			'#dateformat(now(),"dd-mmm-yyyy")#',
			'This container inserted to remove barcode from collection object.',
			'#barcode#',
			0)
		</cfquery>

		<hr>
	<cfset cid=#cid#+1>
	</cfloop>
	</cftransaction>
</cfoutput>