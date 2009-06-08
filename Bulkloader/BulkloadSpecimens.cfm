<cfinclude template="/includes/_header.cfm">
<cfset title="Bulkload Specimens">
<cfif #action# is "nothing">
Step 1: Upload a comma-delimited text file (csv). You may build templates using the
<a href="/Bulkloader/bulkloaderBuilder.cfm">Bulkloader Builder</a>
<cfform name="oids" method="post" enctype="multipart/form-data">
	<input type="hidden" name="Action" value="getFile">
	  <input type="file"
   name="FiletoUpload"
   size="45">
	  <input type="submit" value="Upload this file" #saveClr#>
  </cfform>
</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->

<!------------------------------------------------------->
<cfif #action# is "getFile">
<cfoutput>


	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from bulkloader_stage
	</cfquery>
	<cfdump var="#getTempData#">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "loadData">

<cfoutput>
	
		
	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_citation
	</cfquery>
	
	<cftransaction>
	<cfloop query="getTempData">
		<cfquery name="insert" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into citation (
				PUBLICATION_ID,
				COLLECTION_OBJECT_ID,
				CITED_TAXON_NAME_ID,
				CIT_CURRENT_FG
				<cfif len(#OCCURS_PAGE_NUMBER#) gt 0>
					,OCCURS_PAGE_NUMBER
				</cfif>
				<cfif len(#TYPE_STATUS#) gt 0>
					,TYPE_STATUS
				</cfif>
				<cfif len(#CITATION_REMARKS#) gt 0>
					,CITATION_REMARKS
				</cfif>
			) values (
				#PUBLICATION_ID#,
				#COLLECTION_OBJECT_ID#,
				#CITED_TAXON_NAME_ID#,
				1
				<cfif len(#OCCURS_PAGE_NUMBER#) gt 0>
					,#OCCURS_PAGE_NUMBER#
				</cfif>
				<cfif len(#TYPE_STATUS#) gt 0>
					,'#TYPE_STATUS#'
				</cfif>
				<cfif len(#CITATION_REMARKS#) gt 0>
					,'#CITATION_REMARKS#'
				</cfif>
			)
		</cfquery>
		<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update cf_temp_citation set status='loaded' where key=#key#			
		</cfquery>
	</cfloop>
	</cftransaction>
<cflocation url="BulkloadCitations.cfm?action=allDone">
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
