<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfif action is "nothing">
		Pre-bulkloader magic lives here.

		<p>Howto:</p>

		<ol>
			<li><a href="pre_bulkloader.cfm?action=deleteAll">Clear out the pre-bulkloader</a>. Use with caution. Be courteous.</li>
			<li>Get your data into pre-bulkloader. The specimen bulkloader will push here.</li>
			<li><a href="pre_bulkloader.cfm?action=nullLoaded">NULLify loaded</a>.</li>
			<li>Grab a donut.</li>
			<li><a href="pre_bulkloader.cfm?action=checkStatus">checkStatus</a>. The checks are done when ALL loaded=init_pull_complete</li>
		</ol>


	</cfif>
	<!------------------------------------------------------->
	<cfif action is "checkStatus">
		<cfquery name="checkStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select loaded,count(*) c from pre_bulkloader group by loaded
		</cfquery>
		<cfdump var=#checkStatus#>
		<a href="pre_bulkloader.cfm">return</a>
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "nullLoaded">
		<cfquery name="nullLoaded" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update pre_bulkloader set loaded=null
		</cfquery>
		<cflocation url="pre_bulkloader.cfm" addtoken="false">
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "deleteAll">
		<cfquery name="deleteAll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from pre_bulkloader
		</cfquery>
		<cflocation url="pre_bulkloader.cfm" addtoken="false">
	</cfif>

</cfoutput>
<cfinclude template="/includes/_footer.cfm">
