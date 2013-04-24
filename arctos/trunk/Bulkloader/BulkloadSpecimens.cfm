<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkload Specimens">
<cfif action is "nothing">
	<h2>Bulkloading Specimens</h2>
	<p>
		This web-based specimen bulkloader will handle a few thousand records.
	</p>
	<p>
		If that won't work, split your load into smaller files or contact a DBA. We're happy to help, and can load files of any size.
	</p>
	<p>
		You may create your own templates with the <a href="/Bulkloader/bulkloaderBuilder.cfm">Bulkloader Builder</a>. This is the only valid place to
		find bulkloader fields. It is not static: That year-old template probably won't work.
	</p>
	<p>
		Use <a href="/Bulkloader/bulkloader_status.cfm">Bulkloader Status</a> to see what's made it to the
		bulkloader but not yet to Arctos
	</p>
	<p>
		Documentation, including field definitions, is at <a href="https://arctosdb.wordpress.com/how-to/create/bulkloader/">Bulkloader Docs</a>
	</p>

	<p>
		<a href="/Bulkloader/BulkloadSpecimens.cfm?action=validate">validate</a> whatever's in the bulkloader staging table
	</p>
	<p>
		<a href="/Bulkloader/BulkloadSpecimens.cfm?action=delete">delete</a> everything from the bulkloader staging table
		(or just load new data to delete)
	</p>

	<cfquery name="whatsThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			enteredby,
			collection_cde,
			institution_acronym,
			collection_id,
			max(ENTEREDTOBULKDATE) last_enter_date
		from
			bulkloader_stage
		group by
			enteredby,
			collection_cde,
			institution_acronym,
			collection_id
	</cfquery>
	<cfoutput>
		<cfif whatsThere.recordcount is 0>
			There is nothing in the staging table. You are free to proceed.
		<cfelse>
			<p>
				This is a single-user application. There are data in the staging table. Don't be a jerk.
			</p>
			<p>
				If dates are recent, someone's probably working in here. Talk to them. They may be done, or they may be in the middle of a load.
			</p>
			<p>
				If dates are more than a week old, you can probably just delete everything.
			</p>
			<p>
				If all else fails, <a href="/contact.cfm">contact admin</a>.
			</p>
			<table border>
				<tr>
					<th>Enteredby</th>
					<th>Enteredby Name</th>
					<th>Enteredby Email</th>
					<th>Collection</th>
					<th>Entered Date</th>
					<th>Collection Contacts</th>
				</tr>
				<cfloop query="whatsThere">
						<cfquery name="cid" datasource="uam_god">
							select
								ADDRESS
							from
								electronic_address,
								agent,
								collection_contacts,
								collection
							where
								ADDRESS_TYPE='e-mail' and
								electronic_address.agent_id=agent.agent_id and
								agent.agent_id=collection_contacts.CONTACT_AGENT_ID and
								collection_contacts.collection_id=collection.collection_id and
								<cfif len(collection_id) lt 1>
									collection.collection_cde='#collection_cde#' and
									collection.institution_acronym='#institution_acronym#'
								<cfelse>
									collection.collection_id=#collection_id#
								</cfif>
						</cfquery>
						<cfquery name="enteredbyRealName" datasource="uam_god">
							select
								preferred_agent_name.agent_name
							from
								preferred_agent_name,
								agent_name
							where
								preferred_agent_name.agent_id=agent_name.agent_id and
								agent_name.agent_name='#enteredby#'
						</cfquery>
						<cfquery name="eid" datasource="uam_god">
							select
								ADDRESS
							from
								electronic_address,
								agent_name
							where
								ADDRESS_TYPE='e-mail' and
								electronic_address.agent_id=agent_name.agent_id and
								agent_name='#enteredby#'
						</cfquery>
						<cfquery name="coln" datasource="uam_god">
							select
								collection
							from
								collection
							where
							<cfif len(collection_id) lt 1>
								collection.collection_cde='#collection_cde#' and
								collection.institution_acronym='#institution_acronym#'
							<cfelse>
								collection.collection_id=#collection_id#
							</cfif>
						</cfquery>
					<tr>
						<td>#enteredby#</td>
						<td>#enteredbyRealName.agent_name#</td>
						<td>#valuelist(eid.address)#</td>
						<td>#coln.collection#</td>
						<td>#last_enter_date#</td>
						<td>#valuelist(cid.address)#</td>
					</tr>
				</cfloop>
			</table>
		</cfif>
	</cfoutput>
	<hr>
	<label for="oids">Bulkload Specimens</label>
	<cfform name="oids" method="post" enctype="multipart/form-data">
	<label for="FiletoUpload">Upload a comma-delimited text file (csv)</label>
	<input type="hidden" name="Action" value="getFile">
	  <cfinput type="file" name="FiletoUpload" size="45" >
	  <input type="submit" value="Upload this file" class="savBtn">
  </cfform>
</cfif>


<!------------------------------------------------------->
<cfif action is "delete">
	Are you sure you want to delete everything from the bulkloader stage?
	<ul>
		<li><a href="BulkloadSpecimens.cfm?action=reallydelete">yep, delete away</a></li>
		<li><a href="BulkloadSpecimens.cfm">whoa, back up</a></li>
	</ul>
</cfif>
<!------------------------------------------------------->
<cfif action is "reallydelete">
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from bulkloader_stage
	</cfquery>
	deleted.
	<a href="BulkloadSpecimens.cfm">back to bulkloader</a>
</cfif>
<!------------------------------------------------------->
<cfif action is "getFile">
<cfoutput>

	Seeing errors? Here are some common causes and their solution. <a href="/contact.cfm">Let us know</a> if you find more problems and/or solutions.

	<ul>
		<li>
			<strong>not enough values</strong>: Excel hates you, and has served up invalid CSV. Columns with trailing NULL values have
			been lopped off. Select all colums to the right of your data, and delete them. Select all columns under your data and delete tehm.
			Save as CSV.
		</li>
		<li><strong>SOME_RANDOM_STRING: invalid identifier</strong>: You've made up a column name. See BulkloaderBuilder.
			Check your headers for spaces, commas, etc.
		</li>
		<LI><strong>duplicate column name</strong>: You got all carried away with the sheer joy of copypasta, and have the same column name entered twice.
		Hopefully with identical values.... </LI>
		<li>
			<strong>"{triangle-question-mark-thingees}{some column name}": invalid identifier</strong>. Excel hates you, and has chosen to ignore the <a href="http://en.wikipedia.org/wiki/Byte_order_mark"
				>BOM</a>, which was probably there to signify a UTF8 file, which might have contained UTF8 data - which Excel will not support. Check your headers, check your
				data, consider using a different application.
		</li>
		<li>
			<strong>invalid user.table.column, table.column, or column specification </strong>. You've made up a column name. See BulkloaderBuilder.
			Check for NULL column names, and periods or other punctuation in column names.
		</li>
	</ul>

	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from bulkloader_stage
	</cfquery>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				<cfset thisBit=arrResult[o][i]>
				<cfif #o# is 1>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset colVals="#colVals#,'#thisBit#'">
				</cfif>
			</cfloop>
		<cfif #o# is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>
		<cfif len(#colVals#) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<!----
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into bulkloader_stage (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
			
			---->
			
			
							insert into bulkloader_stage (#colNames#) values (#preservesinglequotes(colVals)#)

<cfabort>


		</cfif>
	</cfloop>
	<cflocation url="BulkloadSpecimens.cfm?action=validate" addtoken="false">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "validate">
<cfoutput>
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) as cnt from bulkloader_stage
	</cfquery>
	There are #c.cnt# records in the <em><strong>staging</strong></em> table.
	They have not been checked or processed yet.
	<ul>
		<li>
			<a href="BulkloadSpecimens.cfm?action=checkStaged" target="_self">Check and load these records</a>.
			This can be a slow process, but completing it will allow you to re-load your data as necessary.
			Email a DBA if you wish to check your records at this stage but the process times out. We can schedule
			the process, allowing it to take as long as necessary to complete, and notify you when it's done.
			This method is strongly preferred.
		</li>
		<li>
			<a href="BulkloadSpecimens.cfm?action=loadAnyway" target="_self">Just load these records</a>.
			Use this method if you wish to use Arctos' tools to fix any errors. Everything will go to the normal
			Bulkloader tables and be available via <a href="Bulkloader/browseBulk.cfm">the Browse Bulk</a> app.
			You need a thorough understanding of Arctos' bulkloader tools and great confidence in your data
			to use this application. Misuse can result in
			a huge mess in the Bulkloader, which may require sorting out record by record.
		</li>

		<li>
			<a href="BulkloaderStageCleanup.cfm" target="_self">Cleanup</a>.
			Fill in the blanks and stuff.
		</li>
	</ul>
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "loadAnyway">
<cfoutput>
	<cfquery name="allId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collection_object_id from bulkloader_stage
	</cfquery>
	<cfloop query="allId">
		<cfquery name="newID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update bulkloader_stage set collection_object_id=bulkloader_pkey.nextval
			where collection_object_id=#collection_object_id#
		</cfquery>
	</cfloop>
	<cfquery name="flag" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update bulkloader_stage set loaded = 'BULKLOADED RECORD'
	</cfquery>
	<cfquery name="moveEm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into bulkloader select * from bulkloader_stage
	</cfquery>
	Your records have been checked and are now in table Bulkloader and flagged as
		loaded='BULKLOADED RECORD'. A data administrator can un-flag
		and load them.
	<p><a href="BulkloadSpecimens.cfm?action=delete">please delete from the staging table</a></p>
</cfoutput>
</cfif>
<!------------------------------------------->
<cfif action is "checkStaged">
<cfoutput>
	<cfstoredproc datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" procedure="bulkloader_stage_check">
	</cfstoredproc>
	<cfquery name="anyBads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) as cnt from bulkloader_stage
		where loaded is not null
	</cfquery>
	<cfquery name="allData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) as cnt from bulkloader_stage
	</cfquery>
	<cfif anyBads.cnt gt 0>
		<cfinclude template="getBulkloaderStageRecs.cfm">
		<p>
			#anyBads.cnt# of #allData.cnt# records will not successfully load.
		</p>
		<p>
			<a href="/download/bulkloader_stage.csv">download data with errors</a>
		</p>
			<p>
						<a href="BulkloaderStageCleanup.cfm">fix/view with Arctos tools</a>
					</p>
		<p>
			Click <a href="BulkloadSpecimens.cfm?action=loadAnyway">here</a> to load them to the
			bulkloader anyway.
		</p>
	<cfelse>
		<cftransaction >
			<cfquery name="allId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select collection_object_id from bulkloader_stage
			</cfquery>
			<cfloop query="allId">
				<cfquery name="newID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update bulkloader_stage set collection_object_id=bulkloader_pkey.nextval
					where collection_object_id=#collection_object_id#
				</cfquery>
			</cfloop>
			<cfquery name="flag" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update bulkloader_stage set loaded = 'BULKLOADED RECORD'
			</cfquery>
			<cfquery name="moveEm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into bulkloader select * from bulkloader_stage
			</cfquery>
			Your records have been checked and are now in table Bulkloader and flagged as
			loaded='BULKLOADED RECORD'. A data administrator can un-flag
			and load them.
			<p><a href="BulkloadSpecimens.cfm?action=delete">please delete from the staging table</a></p>
		</cftransaction>
	</cfif>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">