<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkload Specimens">
<cfif #action# is "nothing">
Step 1: Upload a comma-delimited text file (csv). You may build templates using the
<a href="/Bulkloader/bulkloaderBuilder.cfm">Bulkloader Builder</a>
<cfform name="oids" method="post" enctype="multipart/form-data">
	<input type="hidden" name="Action" value="getFile">
	  <cfinput type="file" name="FiletoUpload" size="45" >
	  <input type="submit" value="Upload this file" class="savBtn">
  </cfform>
</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->

<!------------------------------------------------------->
<cfif #action# is "getFile">
<cfoutput>
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from bulkloader_stage
	</cfquery>
<cfset fileContent=FiletoUpload>
<!---
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	--->
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
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into bulkloader_stage (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="BulkloadSpecimens.cfm?action=validate" addtoken="false">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "validate">
<cfoutput>
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) as cnt from bulkloader_stage
	</cfquery>
	You successfully loaded #c.cnt# records into the <em><strong>staging</strong></em> table. 
	They have not been checked or processed yet. You aren't done here!
	<ul>
		<li>
			<a href="BulkloadSpecimens.cfm?action=checkStaged" target="_self">Check and load these records</a>.
			This is a slow process, but completing it will allow you to re-load your data as necessary.
			Email a DBA if you wish to check your records at this stage but the process times out. We can schedule
			the process, allowing it to take as long as necessary to complete, and notify you when it's done.
			This method is strongly preferred.
		</li>
		<li>
			<a href="BulkloadSpecimens.cfm?action=loadAnyway" target="_self">Just load these records</a>.
			Use this method if you wish to use Arctos' tools to fix any errors. Everything will go to the normal 
			Bulkloader tables and be available via <a href="Bulkloader/browseBulk.cfm">the Browse Bulk</a> app.
			You need a thorough understanding of Arctos' bulkloader tools and great confidence in your data
			to use this application. Misuse can result in duplicate data being loaded to Arctos or
			a huge mess, which may require sorting out record by record, in the Bulkloader.
		</li>
	</ul>	
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "loadAnyway">
<cfoutput>
	<cfquery name="allId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection_object_id from bulkloader_stage
	</cfquery>
	<cfloop query="allId">
		<cfquery name="newID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update bulkloader_stage set collection_object_id=bulkloader_pkey.nextval
			where collection_object_id=#collection_object_id#
		</cfquery>
	</cfloop>
	<cfquery name="flag" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update bulkloader_stage set loaded = 'BULKLOADED RECORD'
	</cfquery>
	<cfquery name="moveEm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		insert into bulkloader select * from bulkloader_stage
	</cfquery>
	Your records have been checked and are now in table Bulkloader and flagged as
		loaded='BULKLOADED RECORD'. A data administrator can un-flag
		and load them.
</cfoutput>
</cfif>
<!------------------------------------------->
<cfif #action# is "checkStaged">
<cfoutput>
	<cfstoredproc datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" procedure="bulkloader_stage_check">
	</cfstoredproc>
	<cfquery name="anyBads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) as cnt from bulkloader_stage
		where loaded is not null
	</cfquery>
	<cfquery name="allData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) as cnt from bulkloader_stage
	</cfquery>
	<cfif #anyBads.cnt# gt 0>
		<cfinclude template="getBulkloaderStageRecs.cfm">
			#anyBads.cnt# of #allData.cnt# records will not successfully load. 
			Click <a href="bulkloader.txt" target="_blank">here</a> 
			to retrieve all data including error messages. Fix them up and reload them.
			<p>
			Click <a href="bulkloaderLoader.cfm?action=loadAnyway">here</a> to load them to the
			bulkloader anyway. Use Arctos to fix them up and load them.
			</p>
	<cfelse>
		<cftransaction >
			<cfquery name="allId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select collection_object_id from bulkloader_stage
			</cfquery>
			<cfloop query="allId">
				<cfquery name="newID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update bulkloader_stage set collection_object_id=bulkloader_pkey.nextval
					where collection_object_id=#collection_object_id#
				</cfquery>
			</cfloop>
			<cfquery name="flag" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				update bulkloader_stage set loaded = 'BULKLOADED RECORD'
			</cfquery>
			<cfquery name="moveEm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into bulkloader select * from bulkloader_stage
			</cfquery>
			Your records have been checked and are now in table Bulkloader and flagged as
			loaded='BULKLOADED RECORD'. A data administrator can un-flag
			and load them.
		</cftransaction>
	</cfif>
		
</cfoutput>
</cfif>
<!-------------------------------------------------------------------------->
<cfif #action# is "allDone">
	<cfoutput>
		<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select publication_id,publication_title,status from cf_temp_citation group by publication_id,publication_title,status 	
		</cfquery>
		<cfif #getTempData.recordcount# is 0>
			something very strange happened. Contact a sysadmin.
		</cfif>
		<cfloop query="getTempData">
			<cfif #status# is not "loaded">
				Something bad happened with #publication_title#. Contact your friendly local sysadmin.
			<cfelse>
				Everything seems to have worked! View citations for <a href="/Citation.cfm?publication_id=#publication_id#">#publication_title#</a>
			</cfif>
		</cfloop>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
