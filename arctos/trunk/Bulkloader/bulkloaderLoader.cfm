<cfheader statuscode="301" statustext="Moved permanently">
<cfheader name="Location" value="/Bulkloader/BulkloadSpecimens.cfm">
<cfabort>

<cfinclude template="/includes/_header.cfm">

 <!--- these have to live in CF runtime to be accessable to cfexecute --->
 <!--- relies on a staging table:

 create table bulkloader_stage as select * from bulkloader;
 delete from bulkloader_stage;
 create public synonym bulkloader_stage for bulkloader_stage;
 grant all on bulkloader_stage to uam_query,uam_update;
 --->
 <!---
 <cfset filename = "/opt/coldfusionmx7/runtime/bin/bulk_data_upload.txt">
 <cfset outFile = "/opt/coldfusionmx7/runtime/bin/bulkData.ctl">

 <cfset logfile = "/opt/coldfusionmx7/runtime/bin/bulkData.log">
 <cfset badfile = "/opt/coldfusionmx7/runtime/bin/bulkData.bad">

 <cfset webFileName = "/var/www/html/Bulkloader/bulk_data_upload.txt">
 <cfset weboutFile = "/var/www/html/Bulkloader/bulkData.ctl">
 <cfset weblogfile = "/var/www/html/Bulkloader/bulkData.log">
 <cfset webbadfile = "/var/www/html/Bulkloader/bulkData.bad">
---->
 <!------------------------------------------->
<cfif action is "nothing">
	<strong> Load files to bulkload</strong>
	<ul>
		<li>You must load a CSV file</li>
		<li>The data may not contain newline characters.</li>
		<li><strong>Include</strong> headers on the first row; headers must match column names in table Bulkloader</li>
		<li>You don't need all available fields to use this application; if you don't want to look at part_name_8, just delete it.</li>
		<li><strong>Read</strong> the messages on this form; assume nothing.</li>
	</ul>
 	Upload a file:
 	<br>
	<cfform action="bulkloaderLoader.cfm?action=newScans" method="post" enctype="multipart/form-data">
		<input type="file" name="FiletoUpload" size="45">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>
</cfif>
<!------------------------------------------->
<cfif action is "newScans">
<cfoutput>
	 <cfset filename = "#Application.webDirectory#/Bulkloader/bulk_data_upload.txt">
	 <cfset controlFile = "#Application.webDirectory#/Bulkloader/bulkData.ctl">
	 <cfset logFile = "#Application.webDirectory#/Bulkloader/bulkData.log">
	 <cfset badFile = "#Application.webDirectory#/Bulkloader/bulkData.bad">
	 <cfif cgi.HTTP_HOST contains "database.museum">
		<cfset sqlldrScript = "/opt/coldfusion8/runtime/bin/runSqlldr">
	</cfif>
	<cfif FileExists("#filename#")>
		  <cffile action="delete" file="#filename#">
	</cfif>
	<cfif FileExists("#controlFile#")>
		<cffile action="delete" file="#controlFile#">
	</cfif>
	<cfif FileExists("#logFile#")>
		<cffile action="delete" file="#logFile#">
	</cfif>
	<cfif FileExists("#badFile#")>
		<cffile action="delete" file="#badFile#">
	</cfif>

    <cffile action="upload" destination="#filename#" nameConflict="overwrite" fileField="Form.FiletoUpload">
	<cfexecute name="/bin/sh" arguments="/usr/bin/dos2unix #filename#" timeout="240"></cfexecute>
	<cfquery name="remOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from bulkloader_stage
	</cfquery>
	<cfset stoopidLongColumns = "LAT_LONG_REMARKS,COLL_OBJECT_REMARKS">
	<cffile action="READ" file="#filename#" variable="fileContent"  charset="iso-8859-1" >
	<cfset fileContent=replace(fileContent,"#chr(13)##chr(10)#",chr(13), "all")>
	<cfset fileContent=replace(fileContent,chr(13),chr(10), "all")>
	<cfset ColumnList = listgetat(#filecontent#,1,"#chr(10)#")>
	<cfset theseData = replace(filecontent,ColumnList,"","all")>
	<!---
	<cfset ColumnList = replace(ColumnList,"#chr(9)#",",","all")>
	<cfset theseData = replace(theseData,"#chr(9)#","|","all")>
	--->
	<cfloop list="#stoopidLongColumns#" index="c">
 		<cfset ColumnList = replace(ColumnList,c,c & " char(4000)")>
 	</cfloop>
	<cfset thisHeader = "load data">
	<cfset thisHeader = thisHeader & chr(10) & "infile *">
	<cfset thisHeader = thisHeader & chr(10) & "insert into table bulkloader_stage">
	<cfset thisHeader = thisHeader & chr(10) & 'fields terminated by "," optionally enclosed by ' & "'" & '"' & "'">
	<cfset thisHeader = thisHeader & chr(10) & "TRAILING NULLCOLS ">
	<cfset thisHeader = thisHeader & chr(10) & "(#ColumnList#) ">
	<cfset thisHeader = thisHeader & chr(10) & "begindata" & theseData>
	<cffile action="write" file="#controlFile#" addnewline="no" output="#thisHeader#" charset="iso-8859-1">
	<cfexecute name="#sqlldrScript#" timeout="240"></cfexecute>
	<cflocation url="bulkloaderLoader.cfm?action=inStage">
</cfoutput>
</cfif>
<!---------------------------------------->
<cfif action is "inStage">
	<cfoutput>
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) as cnt from bulkloader_stage
	</cfquery>
	You successfully loaded #c.cnt# records into the <em><strong>staging</strong></em> table. They have not been checked or processed yet. You aren't done here!
	<p>
	Click <a href="/Bulkloader/bulkData.log" target="_blank">here</a> to view the logfile in a new window. Check data and time (near the bottom) to make sure this is your logfile. Times are AKST.
	</p>
	<p>
		Bad records are <a href="/Bulkloader/bulkData.bad" target="_blank">here</a>.
	</p>
	<p>
		Your data, as they were recieved by this application, are <a href="/Bulkloader/bulk_data_upload.txt" target="_blank">here</a>.
	</p>
	<p>
		The generated control file is <a href="/Bulkloader/bulkData.ctl" target="_blank">here</a>.
	</p>
	<p>
		If all of that looks reasonable,
		click <a href="/Bulkloader/bulkloaderLoader.cfm?action=checkStaged" target="_self">here</a>
		to continue.
		 It'll take awhile. Maybe a long while. Mashing the button more than once will make it take longer.
		 Don't do that. You'll probably break something. This means you. Yea, you. #session.username#. <<-- that you.

		 <p>
			NOTE: If you're loading a lot of records - more than a few hundred - you may need help from
			a DBA. Push the button if you're feeling lucky, it'll either time out or work, but
			won't break anything either way.
		</p>
	</p>
	</cfoutput>
</cfif>
<!---------------------------------------->
<cfif #action# is "checkStaged">
	<cfstoredproc datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" procedure="bulkloader_stage_check">
	</cfstoredproc>
	<cfquery name="anyBads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) as cnt from bulkloader_stage
		where loaded is not null
	</cfquery>
	<cfquery name="allData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) as cnt from bulkloader_stage
	</cfquery>
	<cfoutput>
		<cfif #anyBads.cnt# gt 0>
			<cfinclude template="getBulkloaderStageRecs.cfm">
				#anyBads.cnt# of #allData.cnt# records will not successfully load.
				Click <a href="bulkloader.txt" target="_blank">here</a>
				to retrieve all data including error messages. Fix them up and reload them.
				<p>
				Click <a href="bulkloaderLoader.cfm?action=loadAnyway">here</a> to load them to the
				bulkloader anyway. Use Arctos to fix them up and load them. You'll need Data Entry Admin permissions to use this option.
				</p>
	<cfelse>
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
	</cfif>


		<!--- SQL to accomplish above:
			create or replace PROCEDURE up_bs_id
			is
			  BEGIN
				FOR rec IN (SELECT collection_object_id FROM bulkloader_stage) LOOP
					update bulkloader_stage set collection_object_id = bulkloader_pkey.nextval
							where collection_object_id=rec.collection_object_id;
				END LOOP;
			END;
			/

			exec up_bs_id;

		--->
		<!--- now move em to the real bulkloader --->

		<!---
			update bulkloader_stage set loaded = 'BULKLOADED RECORD' where loaded is null;
		--->

	</cfoutput>
		<!---
	<cfquery name="b" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update bulkloader_stage set loaded = 'UNCHECKED BULKLOADED RECORD'
	</cfquery>
	<cftry>
	<cfquery name="i" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into bulkloader select * from bulkloader_stage
	</cfquery>
		<cfcatch>
			<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from bulkloader where loaded = 'UNCHECKED BULKLOADED RECORD'
			</cfquery>
		</cfcatch>
	</cftry>



		<cfoutput>


				<!--- make the text download file --->

				<!---
				no download here
				--->
				<cfinclude template="getBulkloaderStageRecs.cfm">
				#anyBads.cnt# of #allData.recordcount# records will not successfully load.
				Click <a href="bulkloader.txt" target="_blank">here</a>
				to retrieve all data including error messages.
			<cfelse>

					<!--- no problems, move the records into the real bulkloader table --->
					<!--- first, update collection_object_ids --->


			</cfif>
		</cfoutput>
		--->
</cfif>
<!---------------------------------------->
<cfif #action# is "loadAnyway">
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
</cfoutput>
</cfif>
<!---------------------------------------->
<cfif #action# is "logs">
<cfoutput>
	<strong>Something happened!</strong>
		<br>That's not necessarily a good thing. This application calls an Oracle application which sometimes produces cryptic logs, no logs at all, or otherwise fails for no apparent reason.
		<br>
		Click <a href="/Bulkloader/bulkData.log" target="_blank">here</a> to view the logfile in a new window. Check data and time (near the bottom) to make sure this is your logfile. Times are AKST. Near the bottom, you should see something like:
		<blockquote>
			<em><strong>Table "UAM"."BULKLOADER":<br>
  71 Rows successfully loaded.<br>
  0 Rows not loaded due to data errors.<br>
  0 Rows not loaded because all WHEN clauses were failed.<br>
  0 Rows not loaded because all fields were null.<br></strong></em>
		</blockquote>
	If there are problems, click <a href="/Bulkloader/bulkData.bad" target="_blank">here</a>
	to see bad records. You'll have to begin the process over.
	<p>
		Your data, as they were recieved by this application, are <a href="/Bulkloader/bulk_data_upload.txt" target="_blank">here</a>.
	</p>
	<p>
		The generated control file is <a href="/Bulkloader/bulkData.ctl" target="_blank">here</a>.
	</p>
	<cfquery name="whatsThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) cnt from bulkloader
	</cfquery>
	<p>
		<cfif #whatsThere.cnt# is 0>
			There are currently #whatsThere.cnt# records in table Bulkloader.
			That may be because this page loaded before the bulkloading process
			had completed.
			<a href="bulkloaderLoader.cfm?action=logs">Reload this page</a>
			 and see if you still get this message. If you do, you've probably really loaded nothing.
		<cfelse>
			There are currently #whatsThere.cnt# records in table Bulkloader.
		</cfif>

	</p>
	If nothing above scares you, click <a href="Bulkloader.cfm">here</a> to begin bulkloading!
	<p>
		If something does scare you, click <a href="bulkloaderLoader.cfm?action=killEmAll">here</a> to delete these records and restart the
		load process.
	</p>
</cfoutput>

</cfif>
 <cfinclude template="/includes/_footer.cfm">