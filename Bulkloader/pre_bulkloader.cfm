<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfif action is "nothing">
		Pre-bulkloader magic lives here.
		<p>
			This app is in early beta. Lots of stuff won't work. Some stuff will probably make messes.
			Make backups of your backups at every step.
		</p>

		<p>
			This form will NOT deal with multi-agent strings ("collector=you and me"). Split them out (there are agent tools) and load them
			as collector_agent_1=you,collector_agent_2=me, then use this form to download, standardize, and repatriate.
		</p>
		<p>
			Very few datasets will need everything in there.
		</p>
		<p>
			File an Issue if we've missed something.
		</p>
		<cfquery name="sts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select loaded,enteredby from pre_bulkloader group by loaded,enteredby
		</cfquery>
		<p>
			Currrent state of pre-bulkloader:
			<cfdump var=#sts#>
		</p>
		<p>Howto:</p>

		<ol>
			<li><a href="pre_bulkloader.cfm?action=deleteAll">Clear out the pre-bulkloader</a>. Use with caution. Be courteous.</li>
			<li>Get your data into pre-bulkloader. The specimen bulkloader will push here.</li>
			<li><a href="pre_bulkloader.cfm?action=nullLoaded">NULLify loaded</a>.</li>
			<li>Grab a donut.</li>
			<li><a href="pre_bulkloader.cfm?action=checkStatus">checkStatus</a>. The checks are done when ALL loaded=init_pull_complete</li>
			<li>
				Download <a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_agent">pre_bulk_agent</a>. DO NOT change any data. DO change "shouldbe."
			</li>
			<li>
				Download <a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_taxa">pre_bulk_taxa</a>. DO NOT change any data. DO change "shouldbe."
			</li>
			<li>
				Download <a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_attributes">pre_bulk_attributes</a>. DO NOT change any data. DO change "shouldbe."
			</li>
			<li>
				Download <a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_oidt">pre_bulk_oidt</a>. DO NOT change any data. DO change "shouldbe."
			</li>
			<li>
				Download <a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_date">pre_bulk_date</a>. DO NOT change any data. DO change "shouldbe."
			</li>
			<li>
				Download <a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_parts">pre_bulk_parts</a>. DO NOT change any data. DO change "shouldbe."
			</li>
			<li>
				Download <a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_disposition">pre_bulk_disposition</a>. DO NOT change any data. DO change "shouldbe."
			</li>
			<li>
				Download <a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_collrole">pre_bulk_collrole</a>. DO NOT change any data. DO change "shouldbe."
			</li>
			<li>
				Download <a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_accn">pre_bulk_accn</a>. DO NOT change any data. DO change "shouldbe."
			</li>
			<li>
				Download <a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_geog">pre_bulk_geog</a>. DO NOT change any data. DO change "shouldbe."
			</li>
			<li>
				Download <a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_NATURE_OF_ID">pre_bulk_NATURE_OF_ID</a>. DO NOT change any data. DO change "shouldbe."
			</li>
			<li>
				Download <a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_ORIG_LAT_LONG_UNITS">pre_bulk_ORIG_LAT_LONG_UNITS</a>. DO NOT change any data. DO change "shouldbe."
			</li>
			<li>
				Download <a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_GEOREFERENCE_PROTOCOL">pre_bulk_GEOREFERENCE_PROTOCOL</a>. DO NOT change any data. DO change "shouldbe."
			</li>
			<li>
				Download <a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_VERIFICATIONSTATUS">pre_bulk_VERIFICATIONSTATUS</a>. DO NOT change any data. DO change "shouldbe."
			</li>
			<li>
				Download <a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_MAX_ERROR_UNITS">pre_bulk_MAX_ERROR_UNITS</a>. DO NOT change any data. DO change "shouldbe."
			</li>
			<li>
				Download <a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_COLLECTING_SOURCE">pre_bulk_COLLECTING_SOURCE</a>. DO NOT change any data. DO change "shouldbe."
			</li>
			<li>
				Download <a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_DEPTH_UNITS">pre_bulk_DEPTH_UNITS</a>. DO NOT change any data. DO change "shouldbe."
			</li>
			<li>
				Download <a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_DATUM">pre_bulk_DATUM</a>. DO NOT change any data. DO change "shouldbe."
			</li>
			<li>change "shouldbe" on all of the above.</li>

			<li>
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=pre_bulk_agent">pre_bulk_agent</a>
			</li>

			<li>
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=pre_bulk_taxa">pre_bulk_taxa</a>
			</li>
			<li>
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=pre_bulk_attributes">pre_bulk_attributes</a>
			</li>
			<li>
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=pre_bulk_oidt">pre_bulk_oidt</a>
			</li>
			<li>
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=pre_bulk_date">pre_bulk_date</a>
			</li>
			<li>
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=pre_bulk_parts">pre_bulk_parts</a>
			</li>
			<li>
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=pre_bulk_disposition">pre_bulk_disposition</a>
			</li>
			<li>
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=pre_bulk_collrole">pre_bulk_collrole</a>
			</li>
			<li>
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=pre_bulk_accn">pre_bulk_accn</a>
			</li>
			<li>
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=pre_bulk_geog">pre_bulk_geog</a>
			</li>
			<li>
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=pre_bulk_NATURE_OF_ID">pre_bulk_NATURE_OF_ID</a>
			</li>
			<li>
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=pre_bulk_ORIG_LAT_LONG_UNITS">pre_bulk_ORIG_LAT_LONG_UNITS</a>
			</li>
			<li>
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=pre_bulk_GEOREFERENCE_PROTOCOL">pre_bulk_GEOREFERENCE_PROTOCOL</a>
			</li>
			<li>
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=pre_bulk_VERIFICATIONSTATUS">pre_bulk_VERIFICATIONSTATUS</a>
			</li>
			<li>
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=pre_bulk_MAX_ERROR_UNITS">pre_bulk_MAX_ERROR_UNITS</a>
			</li>
			<li>
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=pre_bulk_COLLECTING_SOURCE">pre_bulk_COLLECTING_SOURCE</a>
			</li>
			<li>
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=pre_bulk_DEPTH_UNITS">pre_bulk_DEPTH_UNITS</a>
			</li>
			<li>
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=pre_bulk_DATUM">pre_bulk_DATUM</a>
			</li>
			<li>
				 <a href="pre_bulkloader.cfm?action=repatriate">repatriate the stuff you just re-loaded</a>
			</li>
			<li>
				Grab another donut. It'll take a while for the scripts to run.
			</li>
			<li><a href="pre_bulkloader.cfm?action=checkStatus">checkStatus</a>. The repatriation is done when ALL loaded=repatriation_complete</li>

		</ol>


	</cfif>

	<!------------------------------------------------------->
	<cfif action is "repatriate">
		<cfquery name="nullLoaded" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update pre_bulkloader set loaded='go_go_gadget_repatriate'
		</cfquery>
		<cflocation url="pre_bulkloader.cfm" addtoken="false">
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "loadTable">
		<form name="atts" method="post" enctype="multipart/form-data" action="pre_bulkloader.cfm">
			<input type="hidden" name="action" value="getFile">
			<input type="hidden" name="table" value="#table#">
			<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
			<input type="submit" value="Upload CSV" class="savBtn">
		 </form>
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "getFile">
	hi i am getfile
		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
        <cfset  util = CreateObject("component","component.utilities")>
		<cfset x=util.CSVToQuery(fileContent)>
        <cfset cols=x.columnlist>
		<cftransaction>
	        <cfloop query="x">
	            <cfquery name="ins" datasource="uam_god">
		            insert into #table# (#cols#) values (
		            <cfloop list="#cols#" index="i">
		            	'#escapeQuotes(evaluate(i))#'
		            	<cfif i is not listlast(cols)>
		            		,
		            	</cfif>
		            </cfloop>
		            )
	            </cfquery>
	        </cfloop>
		</cftransaction>
		loaded to #table# <a href="pre_bulkloader.cfm">return</a>
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "uDATUM">
		<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			create table pre_bulk_datum as select distinct DATUM from pre_bulkloader where DATUM not in (select DATUM from CTDATUM)
		</cfquery>
		<a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_datum">download</a>
		DO NOT change any data. DO change "shouldbe." (if you get ORA-00942, there are no problems with the data)
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
