<cfinclude template="/includes/_header.cfm">
<cfset title="Genbank Submission Form">
<cfif action is "nothing">
	<cfoutput>
		<p>
			<a href="genbank_submit.cfm?action=mkbatch">create a batch (first step)</a>
		</p>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from genbank_batch order by batch_name
		</cfquery>
		<cfloop query="d">
			<br><a href="genbank_submit.cfm?action=edbatch">edit batch #batch_name#</a>

		</cfloop>
	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------->
<cfif action is "edbatch">
	<cfoutput>
		<cfquery name="b" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from genbank_batch where batch_name='#batch_name#'
		</cfquery>
		<cfdump var=#b#>
	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------->
<cfif action is "mkbatch">
	<cfoutput>
		<p>
			Create a "batch" - a way of organizing one or more sequence submissions, usually for a publication.
		</p>
		<form name="f" method="post" action="genbank_submit.cfm">
			<input type="hidden" name="action" value="create_batch">
			<label for="batch_name">batch_name</label>
			<input type="text" name="batch_name" id="batch_name" size="80">
			<br><input type="submit" value="create batch" class="insBtn">
		</form>
	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------->

<cfif action is "create_batch">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into genbank_batch (
			genbank_batch_id,
			created_agent_id,
			batch_name
		) values (
			someRandomSequence.nextval,
			#session.myAgentID#,
			'#batch_name#'
		)
	</cfquery>
	<cflocation url="genbank_submit.cfm?action=edbatch&batch_name=#batch_name#" addtoken="false">
</cfif>
<!--------------------------------------------------------------------------------------------->



<cfinclude template="/includes/_footer.cfm">
