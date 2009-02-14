
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
 <cfif #action# is "nothing">
 
<strong> Load files to bulkload</strong>
<ul>
	<li>You must load a tab-delimited text file</li>
	<li><strong>Include</strong> headers on the first row; headers must match column names in table Bulkloader</li>
	<li>Do not put quotes around fields (and you cannot have a tab in the data you are loading)</li>
	<li>You don't need all available fields to use this application; if you don't want to look at part_name_8, just delete it.</li>
	<li><strong>Read</strong> the messages on this form; assume nothing.</li>
</ul>
 Upload a file:
 <br>

  <cfform action="bulkloaderLoader.cfm?action=newScans" method="post" enctype="multipart/form-data">
      <input type="file"
   name="FiletoUpload"
   size="45">
   
      <input type="submit" 
				value="Upload this file" 
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'"
				onmouseout="this.className='savBtn'">
				
				
    </cfform>
</cfif>
<!------------------------------------------->
<cfif #action# is "newScans">
 <cfoutput>
	 
	 <cfset filename = "#Application.webDirectory#/Bulkloader/bulk_data_upload.txt">
	 <cfset controlFile = "#Application.webDirectory#/Bulkloader/bulkData.ctl">
	 <cfset logFile = "#Application.webDirectory#/Bulkloader/bulkData.log">
	 <cfset badFile = "#Application.webDirectory#/Bulkloader/bulkData.bad">
	 
	 
	 <cfif #cgi.HTTP_HOST# contains "database.museum">
		<cfset sqlldrScript = "/opt/coldfusion8/runtime/bin/runSqlldr">	
	<cfelse>
		 <cfset sqlldrScript = "/users/mvzarctos/bin/runSqlldr">
		 
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
	  
	  
	  
	  
 	<!---<cffile action="write" file="#filename#" nameconflict="overwrite" output="blank" mode="777">--->
    <cffile action="upload"
      destination="#filename#"
      nameConflict="overwrite"
      fileField="Form.FiletoUpload">

	 <!---- see if the bulkloader is deletable ---->
	 <cfquery name="remOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	 	delete from bulkloader_stage
	 </cfquery>
	
	 <!----table is empty, get the data to memory ---->
	 <!--- kill old files 
	
	 <cftry>
		 <cffile action="delete" file="#webbadfile#">
		 <cffile action="delete" file="#weblogfile#">
		 <cffile action="delete" file="#webFileName#">
		 <cffile action="delete" file="#weboutFile#">
	 	<cfcatch>
			<!--- whatever - isn't there, don't care ---->
			
		</cfcatch>
	 </cftry>
	 <!--- Get rid of files in CF runtime, create new blanks with the proper rights --->
		<cffile action="write" file="#logfile#" nameconflict="overwrite" output="blank" mode="777">
		<cffile action="write" file="#badfile#" nameconflict="overwrite" output="blank" mode="777">
		<cffile action="write" file="#outFile#" nameconflict="overwrite" output="blank" mode="777">
	 
	 ---->
	 <!--- first line of file should be column names ---->
	<cfset stoopidLongColumns = "LAT_LONG_REMARKS,COLL_OBJECT_REMARKS">  
	
	

	<cffile action="READ" file="#filename#" variable="fileContent"  charset="iso-8859-1" >
	 	<cfset fileContent=replace(fileContent,chr(13),chr(10),"all")>
	 	<cfset ColumnList = listgetat(#filecontent#,1,"#chr(10)#")>
	 	
	 	
	 	
		<cfset theseData = replace(filecontent,ColumnList,"","all")>
		<cfset ColumnList = replace(ColumnList,"#chr(9)#",",","all")>
		
		<cfset theseData = replace(theseData,"#chr(9)#","|","all")>
		
		<cfloop list="#stoopidLongColumns#" index="c">
	 		<cfset ColumnList = replace(ColumnList,c,c & " char(4000)")>
	 	</cfloop>
		<cfset thisHeader = "load data
			infile *
			insert into table bulkloader_stage
			fields terminated by ""|""
			TRAILING NULLCOLS 
			(#ColumnList#) 
			begindata #theseData#">
		
		<cffile action="write" file="#controlFile#" addnewline="no" output="#thisHeader#" charset="iso-8859-1">		
		
		
		<!---
		ORACLE_HOME=/opt/oracle/10.2.0/client
export ORACLE_HOME
#ls -latr
#source /home/fndlm/.bash_profile
echo $ORACLE_HOME
/opt/oracle/10.2.0/client/bin/sqlldr uam_query@arctos/uamdb1 control=/var/www/ht
ml/Bulkloader/bulkData.ctl log=/var/www/html/Bulkloader/bulkData.log

		--->
		
		
		<cfexecute name="#sqlldrScript#"  timeout="240">
		
		</cfexecute>
		<!--- move the files from CF runtime to a web dir <cftry>
	 	<cffile action="copy" destination="#weblogfile#" source="#logfile#" nameconflict="overwrite">
		 <cffile action="copy" destination="#webbadfile#" source="#badfile#" nameconflict="overwrite">
		 <cffile action="copy" destination="#weboutFile#" source="#outFile#" nameconflict="overwrite">
		 <cffile action="copy" destination="#webFileName#" source="#filename#" nameconflict="overwrite">
	 	<cfcatch><!--- so what? ---></cfcatch>
		</cftry>

		<cffile action="copy" destination="/var/www/html/Bulkloader" source="#logfile#" nameconflict="overwrite">
		 <cffile action="copy" destination="#webBadFile#" source="#badfile#" nameconflict="overwrite">
		 <cffile action="copy" destination="#weboutFile#" source="#outFile#" nameconflict="overwrite">
		 <cffile action="copy" destination="#webFileName#" source="#filename#" nameconflict="overwrite">

--->
<cflocation url="bulkloaderLoader.cfm?action=inStage">
		<!--- 
		<cfscript>
  // first of we set the command to call
  cmd = "/var/www/html/Bulkloader/a";
  // the environment variable is empty
  envp = arraynew(1);
  // and we want to run from a given "root"
  path = "/var/www/html/Bulkloader";
  dir = createobject("java", "java.io.File").init(path);
  // get the java runtime object
  rt = createobject("java", "java.lang.Runtime").getRuntime();
  // and make the exec call to run the command
  rt.exec(cmd, envp, dir);
</cfscript>
		
 uam_query@arctos/uamdb1 control=/var/www/html/Bulkloader/bulkData.ctl log=/var/www/html/Bulkloader/bulkData.log ---->
		
	 </cfoutput>
</cfif>	 

<!---------------------------------------->
<cfif #action# is "inStage">
	<cfoutput>
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cfstoredproc datasource="#Application.web_user#" procedure="bulkloader_stage_check">
	</cfstoredproc>
	<cfquery name="anyBads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) as cnt from bulkloader_stage
		where loaded is not null
	</cfquery>
	<cfquery name="allData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cfquery name="b" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update bulkloader_stage set loaded = 'UNCHECKED BULKLOADED RECORD' 
	</cfquery>
	<cftry>
	<cfquery name="i" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		insert into bulkloader select * from bulkloader_stage
	</cfquery>
		<cfcatch>
			<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cfquery name="whatsThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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