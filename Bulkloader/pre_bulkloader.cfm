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
			as collector_agent_1=you,collector_agent_2=me.
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
				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=loadTable&table=xxxxxxxx">xxxx</a>
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





		<!---
	-- single-column stuff that should be handled elsewhere
		insert into pre_bulk_geog () (select distinct HIGHER_GEOG from pre_bulkloader);

		delete from pre_bulk_geog where HIGHER_GEOG in (select HIGHER_GEOG from geog_auth_rec);

		select distinct NATURE_OF_ID from pre_bulkloader where NATURE_OF_ID not in (select NATURE_OF_ID from ctNATURE_OF_ID);

		/*
			http://arctos.database.museum/info/ctDocumentation.cfm?table=CTNATURE_OF_ID
			update pre_bulkloader set NATURE_OF_ID='legacy' where NATURE_OF_ID is null;
		*/

		select distinct ORIG_LAT_LONG_UNITS from pre_bulkloader where ORIG_LAT_LONG_UNITS not in (select ORIG_LAT_LONG_UNITS from CTLAT_LONG_UNITS);
		/*
			http://arctos.database.museum/info/ctDocumentation.cfm?table=CTLAT_LONG_UNITS
			update pre_bulkloader set ORIG_LAT_LONG_UNITS='decimal degrees' where ORIG_LAT_LONG_UNITS is null and dec_lat is not null;
		*/

		select distinct GEOREFERENCE_PROTOCOL from pre_bulkloader where GEOREFERENCE_PROTOCOL not in (select GEOREFERENCE_PROTOCOL from CTGEOREFERENCE_PROTOCOL);

		/*
			http://arctos.database.museum/info/ctDocumentation.cfm?table=CTGEOREFERENCE_PROTOCOL
			update pre_bulkloader set GEOREFERENCE_PROTOCOL='not recorded' where GEOREFERENCE_PROTOCOL is null and ORIG_LAT_LONG_UNITS is not null;
		*/

		select distinct VERIFICATIONSTATUS from pre_bulkloader where VERIFICATIONSTATUS not in (select VERIFICATIONSTATUS from CTVERIFICATIONSTATUS);


		select distinct MAX_ERROR_UNITS from pre_bulkloader where MAX_ERROR_UNITS not in (select MAX_ERROR_UNITS from CTLAT_LONG_ERROR_UNITS);



		select distinct COLLECTING_SOURCE from pre_bulkloader where COLLECTING_SOURCE not in (select COLLECTING_SOURCE from CTCOLLECTING_SOURCE);


		select distinct DEPTH_UNITS from pre_bulkloader where DEPTH_UNITS not in (select DEPTH_UNITS from CTDEPTH_UNITS);


		select distinct DATUM from pre_bulkloader where DATUM not in (select DATUM from CTDATUM);










			<li><a href="pre_bulkloader.cfm?action=">get distinct HIGHER_GEOG</a>.</li>
			<li><a href="pre_bulkloader.cfm?action=uNATURE_OF_ID">get distinct NATURE_OF_ID</a>.</li>
			<li><a href="pre_bulkloader.cfm?action=uORIG_LAT_LONG_UNITS">get distinct ORIG_LAT_LONG_UNITS</a>.</li>
			<li><a href="pre_bulkloader.cfm?action=uGEOREFERENCE_PROTOCOL">get distinct GEOREFERENCE_PROTOCOL</a>.</li>
			<li><a href="pre_bulkloader.cfm?action=uVERIFICATIONSTATUS">get distinct VERIFICATIONSTATUS</a>.</li>
			<li><a href="pre_bulkloader.cfm?action=uMAX_ERROR_UNITS">get distinct MAX_ERROR_UNITS</a>.</li>
			<li><a href="pre_bulkloader.cfm?action=uCOLLECTING_SOURCE">get distinct COLLECTING_SOURCE</a>.</li>
			<li><a href="pre_bulkloader.cfm?action=uDEPTH_UNITS">get distinct DEPTH_UNITS</a>.</li>


	------->


		</ol>

				Upload the corrected CSV you downloaded for <a href="pre_bulkloader.cfm?action=&table=pre_bulk_agent">pre_bulk_agent</a>

	</cfif>
	<!------------------------------------------------------->
	<cfif action is "loadTable">
		<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			create table pre_bulk_geog as select distinct DATUM from pre_bulkloader where DATUM not in (select DATUM from CTDATUM)
		</cfquery>
		<a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_datum">download</a>
		DO NOT change any data. DO change "shouldbe." (if you get ORA-00942, there are no problems with the data)
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
