<cfinclude template="/includes/_header.cfm">
<cfsetting requesttimeout="600"> 

<cfform name="atts" method="post" enctype="multipart/form-data">
	<input type="hidden" name="Action" value="getFile">
	<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
	<input type="submit" value="Upload CSV" class="savBtn">
 </cfform>


<cfoutput>
	<cfif action is "getFile">
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset numberOfColumns = ArrayLen(arrResult[1])>
	
	<cftry>
		<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			drop table #session.username#.my_temp_cf			
		</cfquery>
	<cfcatch>
		<!--- whatever --->
	</cfcatch>
	</cftry>
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				 <!---
				 <cfdump var="#arrResult[o]#">
				 --->
				 <cfset numColsRec = ArrayLen(arrResult[o])>
				<cfset thisBit=arrResult[o][i]>
				<cfif #o# is 1>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset colVals="#colVals#,'#thisBit#'">
				</cfif>
			</cfloop>
		<cfif o is 1>
			<cfset colNames=replace(colNames,",","","first")>
			<cfset colNames=replace(colNames," ","_","all")>
			<cfset s='create table #session.username#.my_temp_cf ('>
			<cfset c=1>
			<cfloop list="#colNames#" index="x">
				<cfset s="#s# #x# varchar2(4000),">
			</cfloop>
			<cfset s=rereplace(s,",[^,]*$","")>
			
			<cfset s=s & ")">
			<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				#preservesinglequotes(s)#							
			</cfquery>
		</cfif>	
		<cfif len(colVals) gt 1>
			<!--- Excel randomly and unpredictably whacks values off
				the end when they're NULL. Put NULLs back on as necessary.
				--->
			<cfset colVals=replace(colVals,",","","first")>
			<cfif numColsRec lt numberOfColumns>
				<cfset missingNumber = numberOfColumns - numColsRec>
				<cfloop from="1" to="#missingNumber#" index="c">
					<cfset colVals = "#colVals#,''">
				</cfloop>
			</cfif>
			<cfquery name="ins" datasource="uam_god">
				insert into #session.username#.my_temp_cf (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	</cfif>
	
	loaded
	<cfabort>
	
	
	
	
	
	
	
	
	
	
	
	-- temp table - upload to it with this app
	create table t_bc (old varchar2(255),new varchar2(255));

	-- add temp barcodes and container ID placeholders
	alter table t_bc add told varchar2(255);
	alter table t_bc add tnew varchar2(255);
	update t_bc set told='temp_uames_' || old;
	update t_bc set tnew='temp_uames_' || new;
	alter table t_bc add nc number;
	alter table t_bc add oc number;
	
	-- set the container ID
	
	
	declare 
		ocid number;
		ncid number;
		
	begin
	for r in (select * from t_bc) loop
	
		dbms_output.put_line('old: ' || r.old);
		select container_id into ocid from container where barcode = r.old;
		
		dbms_output.put_line('ocid: ' || ocid);
		dbms_output.put_line('new: ' || r.new);
		select container_id into ncid from container where barcode = r.new;
		
		dbms_output.put_line('ocid: ' || ocid);
		
		update t_bc set oc=ocid,nc=ncid where old=r.old and new=r.new;
		
		
	end loop;
	end;
	/
	
	
	--- flip old and new with intermediate step to avoid unique key constraints
	
	declare 
		ocid number;
		ncid number;
		
	begin
	for r in (select * from t_bc) loop
	
		-- update container to temp barcodes to avoid any unique constraint issues
		update container set barcode = r.told where container_id = r.oc;
		update container set barcode = r.tnew where container_id = r.nc;
		
		-- update the old container to have the new barcode
		-- this will keep parentage, etc. in place
		
		update container set barcode=r.new where container_id=r.oc;
		
		-- "new" (now old) containers should be kept around for reuse
		-- update container type and remarks
		
		update container set 
			barcode=r.old,
			container_type='container label',
			parent_container_id=0
		where container_id=r.nc;
	
		
		
	end loop;
	end;
	/
	
	
	
		<cfif action is "mup">
			<cfquery name="d" datasource="uam_god">
				select * from t_bc
			</cfquery>
			<cftransaction>
				<cfloop query="d">
					
				</cfloop>
				
			</cftransaction>
		</cfif>
</cfoutput>

 