<cfinclude template = "includes/_header.cfm">
<!--------------
	drop table cf_temp_barcodeload;
	
	create table cf_temp_barcodeload (
		key number not null,
		child_barcode varchar2(255) not null,
		parent_barcode varchar2(255) not null,
		install_date date);
		
	create or replace public synonym cf_temp_barcodeload for cf_temp_barcodeload;
	
	grant all on cf_temp_barcodeload to manage_container;
	
	
	CREATE OR REPLACE TRIGGER cf_temp_barcodeload_key                                         
	 before insert  ON cf_temp_barcodeload  
	 for each row 
	    begin     
	    	if :NEW.key is null then                                                                                      
	    		select somerandomsequence.nextval into :new.key from dual;
	    	end if;                                
	    end;                                                                                            
	/
	sho err 

	alter table cf_temp_barcodeload add status varchar2(255);
	alter table cf_temp_barcodeload add child_id number;
	alter table cf_temp_barcodeload add parent_id number;

--------------->
<cfif action is "nothing">
	<cfoutput> 
    	Upload container scans
    	<br>
    	Duplicate scans will be ignored. 
		<p>CSV headers are <strong>child_barcode,parent_barcode,install_date</strong></p>
	    Upload a new file: <br>
    	<cfform action="LoadBarcodes.cfm" method="post" enctype="multipart/form-data">
			<input type="hidden" name="action" value="newScans" />
      		<input type="file"  name="FiletoUpload" size="45">
   			<input type="submit" value="Upload this file" class="savBtn">
		</cfform>
	</cfoutput>
</cfif>  
<cfif action is "newScans">
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_barcodeload
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
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into cf_temp_barcodeload (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<a href="LoadBarcodes.cfm?action=verify">data loaded to temp table - click to verify</a>
</cfif>
<cfif action is "verify">
	<cfquery name="child_not_found" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_barcodeload set status='child_not_found' where child_barcode not in (select barcode from container where barcode is not null)
	</cfquery>
	<cfquery name="parent_not_found" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_barcodeload set status='parent_not_found' where parent_barcode not in (select barcode from container where barcode is not null)
	</cfquery>
	
	<cfquery name="child_is_label" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_barcodeload set status='child_is_label' where child_barcode in 
			(select barcode from container where barcode is not null and container_type like '%label%')
	</cfquery>
	<cfquery name="parent_is_label" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_barcodeload set status='parent_is_label' where parent_barcode in 
			(select barcode from container where barcode is not null and container_type like '%label%')
	</cfquery>
	<cfquery name="infinite_loop" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_barcodeload set status='infinite_loop' where parent_barcode = child_barcode
	</cfquery>
	<cfquery name="parent_is_colobj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_barcodeload set status='parent_is_colobj' where parent_barcode in 
			(select barcode from container where barcode is not null and container_type = 'collection object')
	</cfquery>
	
	<cfquery name="ucid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_barcodeload set child_id=(select container_id from container where container.barcode=cf_temp_barcodeload.child_barcode)
	</cfquery>
	
	<cfquery name="upid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_barcodeload set parent_id=(select container_id from container where container.barcode=cf_temp_barcodeload.parent_barcode)
	</cfquery>
	
	
	<cfquery name="parent_is_colobj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_barcodeload set status='barcode_not_found' where child_id is null or parent_id is null
	</cfquery>
	
	
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_barcodeload where status is not null
	</cfquery>
	<cfif d.recordcount gt 0>
		The data will not load.
		<cfdump var=#d#>
	<cfelse>
		The data will probably load - <a href="LoadBarcodes.cfm?action=load">click to continue....</a>
	</cfif>
</cfif>

<cfif action is "load">
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_barcodeload
	</cfquery>
	<cftransaction>
		<cfloop query="d">
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update container set parent_container_id=#parent_id# where container_id=#child_id#
			</cfquery>
		</cfloop>
	</cftransaction>
	
	Errors above? nothing loaded - try again.
	
	No errors? All done.
</cfif>
<cfinclude template = "includes/_footer.cfm">