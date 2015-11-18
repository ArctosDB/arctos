<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfif action is "nothing">
		Pre-bulkloader magic lives here.

		<p>
			get your data into pre-bulkloader.
		</p>
		<ul>
			<li><a href="pre_bulkloader.cfm?action=deleteAll">deleteAll</a></li>
		</ul>

	</cfif>
	<cfif action is "deleteAll">
		<cfquery name="deleteAll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from pre_bulkloader
		</cfquery>
		<cflocation url="pre_bulkloader.cfm" addtoken="false">

	</cfif>

</cfoutput>
<cfinclude template="/includes/_footer.cfm">
