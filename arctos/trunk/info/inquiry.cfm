<cfinclude template="/includes/_header.cfm">
<script type='text/javascript' src='/ajax/core/engine.js'></script>
	<script type='text/javascript' src='/ajax/core/util.js'></script>
	<script type='text/javascript' src='/ajax/core/settings.js'></script>
	<cfinclude template="/ajax/core/cfajax.cfm">
<script>
function getContacts (contact_role) {
	
		DWREngine._execute(_cfscriptLocation, null, 'getContacts',contact_role, successGetContacts);
}
function sTest () {
	alert('spiffy');
}
</script>
<cfif #Action# is "nothing">
<cfset title="Arctos Inquiry">
<center>
<table>
<tr>
	<td colspan="2" align="center">
		<div style="width:600px;" align="left">
		<font color="#FF0000">Submit an Inquiry or Request </font>		<br>
		If you wish to report a data error, please use the <img src="/images/bad.gif" /> icon available on data pages. Doing so will include information that may help us quickly resolve your problem.
		</div>
	</td>
</tr>
</table>
<table border>
<cfoutput>
<form action="inquiry.cfm" method="post" name="inq">
<input type="hidden" name="action" value="sendMail" />
<cfquery name="ctContactRole" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select contact_role from ctcoll_contact_role
</cfquery>
<tr>
	<td colspan="2" align="right">
		What is the nature of your inquiry?
	</td>
	<td colspan="2">
		<select name="contact_role" size="1">
			<cfloop query="ctContactRole">
				<option value="#contact_role#">#contact_role#</option>
			</cfloop>
		</select>
	</td>
</tr>
<tr>
	<td colspan="2" align="right">
		What is your name?
	</td>
	<td colspan="2">
		<input type="subName" type="text" size="40" />
	</td>
</tr>
	<cfquery name="collections" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection_cde,institution_acronym,collection_id
		from collection
		order by institution_acronym,collection
	</cfquery>
	<tr>
		<td align="right">
			Collection
		</td>
		<td>Contact?</td>
		<td align="right">
			Collection
		</td>
		<td>Contact?</td>
	</tr>
	<cfset i=1>
	<cfloop query="collections">
		 <cfif #i# mod 2>
		 <tr>
		 </cfif>
			<td align="right">
			#institution_acronym# #collection_cde#</td>
			<td><input type="checkbox" name="collection_id" value="#collection_id#" /></td>
		 <cfif not (#i# mod 2)>
		 </tr>
		 </cfif>
		 <cfset i=#i#+1>
	</cfloop>
	<tr>
		<td colspan="4">
			<input type="submit" />
		</td>
	</tr>
</form>
</cfoutput>
</table>
</cfif>
<!------------------------------------------------------------>
<cfif #action# is "sendMail">
<cfoutput>
#collection_id#
<!--- see what we got --->
<cfquery name="whatC" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		address,institution_acronym,collection_cde
	from
		collection,
		collection_contacts,
		electronic_address
	where
		collection.collection_id = collection_contacts.collection_id  AND
		contact_agent_id = agent_id AND
		contact_role='#contact_role#' and
		address_type='e-mail' AND
		collection.collection_id IN (#collection_id#)
</cfquery>
<!--- get names of collections with no contact info --->
<cfquery name="whatCollNames" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select institution_acronym,collection_cde
	from
		collection
		where
	collection_id IN (#collection_id#)
</cfquery>
<cfloop query="whatC">
	<br />--#institution_acronym#,#collection_cde#,#address#--
</cfloop>
<cfloop query="whatCollNames">
	<br />--#institution_acronym#,#collection_cde#
</cfloop>
<!---
<cfset user_id=0>
<cfif isdefined("session.username") and len(#session.username#) gt 0>
	<cfquery name="isUser" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT user_id FROM cf_users WHERE username = '#session.username#'
	</cfquery>
	<cfset user_id = #isUser.user_id#>
</cfif>
	<cfquery name="bugID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select max(bug_id) + 1 as id from cf_bugs
	</cfquery>
	<cfset thisDate = #dateformat(now(),"dd-mmm-yyyy")#>
	
	<cfquery name="newBug" datasource="#Application.uam_dbo#">
		INSERT INTO cf_bugs (
			bug_id,
			user_id,
			reported_name,
			complaint,
			suggested_solution,
			user_remarks,
			user_email,
			submission_date)
		VALUES (
			#bugID.id#,
			#user_id#,
			'#reported_name#',
			'<a href="#Application.ServerRootUrl#/SpecimenResults.cfm?collection_object_id=#newCollObjId#">Specimens</a>',
			'#suggested_solution#',
			'#user_remarks#',
			'#user_email#',
			'#thisDate#')				
	</cfquery>
	
	<!--- get the proper emails to report this to --->
	<cfquery name="whatEmails" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select address from
			electronic_address,
			collection_contacts,
			cataloged_item
		WHERE
			electronic_address.agent_id = collection_contacts.contact_agent_id AND
			collection_contacts.collection_id = cataloged_item.collection_id AND
			address_type='e-mail' AND
			contact_role='data quality' AND
			cataloged_item.collection_object_id IN (#newCollObjId#)
		GROUP BY address
	</cfquery>
	<cfset thisAddress = #Application.DataProblemReportEmail#><!--- always send data problems to SOMEONE, even if we don't 
		find additional contacts --->
	<cfloop query="whatEmails">
		<cfset thisAddress = "#thisAddress#,#address#">
	</cfloop>
	
	<cfmail to="#thisAddress#" subject="ColdFusion Bad Data Report" from="#mailFromAddress#" type="html">
		<p>Reported Name: #reported_name# (AKA #session.username#) submitted a data report on #thisDate#.</p>
		
		<P>Solution: #suggested_solution#</P>
		
		<P>Remarks: #user_remarks#</P>
		
		<P>Email: #user_email#</P>
		
		<p>Link: 
		<a href="#Application.ServerRootUrl#/info/bugs.cfm?action=read&bug_id=#bugID.id#">#Application.ServerRootUrl#/info/bugs.cfm?action=read&bug_id=#bugID.id#</a></p>
	</cfmail>
	
	
	
	<div align="center">Your report has been successfully submitted.
	  
	</div>
	<P align="center">Thank you for helping to improve this site!
	<p>
		<div align="center">Click <a href="/SpecimenResults.cfm?collection_object_id=#newCollObjId#">here</a> to return to your search results.
</div>
	</p>
<p>	
<div align="center">Click <a href="/home.cfm">here</a> to return to Arctos home.
</div>
<p>	
<div align="center">Click <a href="bugs.cfm?action=read">here</a> to read bug reports.
</div>
--->
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">