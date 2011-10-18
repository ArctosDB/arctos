<!---
drop table ds_temp_agent_split;

create table ds_temp_agent_split (
	key number not null,
	agent_type varchar2(255),
	preferred_name varchar2(255),
	first_name varchar2(255),
	middle_name varchar2(255),
	last_name varchar2(255),
	birth_date date,
	death_date date,
	prefix varchar2(255),
	suffix varchar2(255),
	other_name_1  varchar2(255),
	other_name_type_1   varchar2(255),
	other_name_2  varchar2(255),
	other_name_type_2   varchar2(255),
	other_name_3  varchar2(255),
	other_name_type_3   varchar2(255),
	agent_remark varchar2(4000),
	status varchar2(4000)
	);
	
create public synonym ds_temp_agent_split for ds_temp_agent_split;
grant all on ds_temp_agent_split to coldfusion_user;
grant select on ds_temp_agent_split to public;

 CREATE OR REPLACE TRIGGER ds_temp_agent_split_key                                         
 before insert  ON ds_temp_agent_split
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
	upload a CSV list of agent names with header "preferred_name"
	<cfform name="atts" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" size="45">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>
</cfif>
<cfif action is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from ds_temp_agent_split
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
				insert into ds_temp_agent_split (#colNames#) values (#preservesinglequotes(colVals)#)				
			</cfquery>
		</cfif>
	</cfloop>
</cfoutput>
<cflocation url="agentNameSplitter.cfm?action=validate" addtoken="false">
</cfif>
<cfif action is "validate">
<cfoutput>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from ds_temp_agent_split			
	</cfquery>
	<cfquery name="ctsuffix" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select suffix from ctsuffix
	</cfquery>
	<cfloop query="d">
		<hr>
		<br>'#preferred_name#'
		<cfset s=''>
		<cfif len(trim(preferred_name)) is 0>
			<cfset s=listappend(s,"preferred_name may not be blank",";")>
		</cfif>
		<cfif trim(preferred_name) is not preferred_name>
			<cfset s=listappend(s,"leading or trailing spaces",";")>
		</cfif>
		<cfif preferred_name contains "  ">
			<cfset s=listappend(s,"preferred_name may not contain double spaces",";")>
		</cfif>
		<cfquery name="isThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select agent_id from agent_name where agent_name='#preferred_name#'
		</cfquery>
		<cfif isThere.recordcount is 1>
			<cfset s=listappend(s,"found #isThere.recordcount# match",";")>	
		<cfelseif isThere.recordcount gt 1>
			<cfset s=listappend(s,"found #isThere.recordcount# matches-merge or make unique",";")>
		</cfif>
		<cfloop index="i" list="#preferred_name#" delimiters=" ,;">
			<br>=+#i#
		</cfloop>
		<br>#s#
	</cfloop>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
