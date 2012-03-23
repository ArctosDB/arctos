<!----
drop table ds_temp_taxcheck;

create table ds_temp_taxcheck (
	key number not null,
	scientific_name varchar2(255)
	);
	
	alter table ds_temp_taxcheck add status varchar2(255);
	
create public synonym ds_temp_taxcheck for ds_temp_taxcheck;
grant all on ds_temp_taxcheck to coldfusion_user;
grant select on ds_temp_taxcheck to public;

 CREATE OR REPLACE TRIGGER ds_temp_taxcheck_key                                         
 before insert  ON ds_temp_taxcheck
 for each row 
    begin     
    	if :NEW.key is null then                                                                                      
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;                                
    end;                                                                                            
/
sho err

---->
<cfinclude template="/includes/_header.cfm">

<cfif action is "nothing">
	
	Columns in <span style="color:red">red</span> are required; others are optional:
	<ul>
		<li style="color:red">scientific_name</li>
	</ul>
	
	
	<cfform name="atts" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>

</cfif>

<cfif action is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from ds_temp_taxcheck
	</cfquery>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset numberOfColumns = ArrayLen(arrResult[1])>
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				 <cfset numColsRec = ArrayLen(arrResult[o])>
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
		<cfif len(colVals) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfif numColsRec lt numberOfColumns>
				<cfset missingNumber = numberOfColumns - numColsRec>
				<cfloop from="1" to="#missingNumber#" index="c">
					<cfset colVals = "#colVals#,''">
				</cfloop>
			</cfif>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into ds_temp_taxcheck (#colNames#) values (#preservesinglequotes(colVals)#)				
			</cfquery>
		</cfif>
	</cfloop>
</cfoutput>
<cflocation url="SciNameCheck.cfm?action=validate" addtoken="false">

<!---
---->
</cfif>
<cfif action is "validate">
	<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select scientific_name from ds_temp_taxcheck
	</cfquery>
	<cfloop query="r">
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select count(*) c from taxonomy where scientific_name='#scientific_name#'
		</cfquery>
		<cfif d.c is 1>
			<cfquery name="s" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				update ds_temp_taxcheck set status='OK' where key=#key#
			</cfquery>
		<cfelse>
			<cfquery name="s" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				update ds_temp_taxcheck set status='FAIL' where key=#key#
			</cfquery>
		</cfif>
	</cfloop>
	<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from ds_temp_taxcheck
	</cfquery>
	anything below isn't in Arctos.
	<cfdump var=#r#>
	
</cfif>