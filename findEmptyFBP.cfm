<cfinclude template = "/includes/_header.cfm">
	<cfoutput>
		<cfquery name="fb" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				label,
				barcode,
				container_id
			FROM
				container
			where
				container_type='freezer box'
				START WITH container_id=#container_id#
			CONNECT BY PRIOR
				container_id = parent_container_id
		</cfquery>
		<cfloop query="fb">
			<br>#label#-#barcode#
			<cfquery name="nep" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				SELECT count(*) c
				FROM (
				  select * from container where parent_container_id=#fb.container_id#
				) x
				WHERE NOT EXISTS (
				    SELECT 1 FROM container
				    WHERE container.parent_container_id = x.container_id
				)
			</cfquery>
			#nep.c#
		</cfloop>

	</cfoutput>




<cfinclude template = "/includes/_footer.cfm">