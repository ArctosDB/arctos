<cfinclude template="/includes/_header.cfm">
<cfsetting requesttimeout="600">

<!---

drop table cf_temp_accn;

create table cf_temp_accn (
	i$key number not null,
	guid_prefix varchar2(255) not null,
	ACCN_NUMBER varchar2(255) not null,
	ACCN_TYPE varchar2(255) not null,
	ACCN_STATUS varchar2(255) not null,
	NATURE_OF_MATERIAL varchar2(255) not null,
	ESTIMATED_COUNT number,
	TRANS_DATE date,
	TRANS_REMARKS varchar2(255),
	IS_PUBLIC_FG number,
	TRANS_AGENT_1  varchar2(255),
	NEW_TRANS_AGENT_ROLE_1  varchar2(255), 
	TRANS_AGENT_2  varchar2(255),
	NEW_TRANS_AGENT_ROLE_2  varchar2(255),
	TRANS_AGENT_3  varchar2(255),
	NEW_TRANS_AGENT_ROLE_3  varchar2(255),
	TRANS_AGENT_4  varchar2(255),
	NEW_TRANS_AGENT_ROLE_4  varchar2(255),
	TRANS_AGENT_5  varchar2(255),
	NEW_TRANS_AGENT_ROLE_5  varchar2(255),
	TRANS_AGENT_6  varchar2(255),
	NEW_TRANS_AGENT_ROLE_6  varchar2(255),
	i$status varchar2(255),
	i$collection_id number,
	i$agent_id_1 number,
	i$agent_id_2 number,
	i$agent_id_3 number,
	i$agent_id_4 number,
	i$agent_id_5 number,
	i$agent_id_6 number
	);
			
		

create public synonym cf_temp_accn for cf_temp_accn;
grant all on cf_temp_accn to coldfusion_user;
grant select on cf_temp_accn to public;


 CREATE OR REPLACE TRIGGER cf_temp_accn_key
 before insert  ON cf_temp_accn
 for each row
    begin
    	if :NEW.i$key is null then
    		select somerandomsequence.nextval into :new.i$key from dual;
    	end if;
    end;
/
sho err
--->

<cfif action is "nothing">
Step 1: Upload a comma-delimited text file (csv). 
Include column headings, spelled exactly as below. 

guid_prefix varchar2(255) not null,
	ACCN_NUMBER varchar2(255) not null,
	ACCN_TYPE varchar2(255) not null,
	ACCN_STATUS varchar2(255) not null,
	NATURE_OF_MATERIAL varchar2(255) not null,
	ESTIMATED_COUNT number,
	TRANS_DATE date,
	TRANS_REMARKS varchar2(255),
	IS_PUBLIC_FG number,
	TRANS_AGENT_1  varchar2(255),
	NEW_TRANS_AGENT_ROLE_1  varchar2(255), 
	TRANS_AGENT_2  varchar2(255),
	NEW_TRANS_AGENT_ROLE_2  varchar2(255),
	TRANS_AGENT_3  varchar2(255),
	NEW_TRANS_AGENT_ROLE_3  varchar2(255),
	TRANS_AGENT_4  varchar2(255),
	NEW_TRANS_AGENT_ROLE_4  varchar2(255),
	TRANS_AGENT_5  varchar2(255),
	NEW_TRANS_AGENT_ROLE_5  varchar2(255),
	TRANS_AGENT_6  varchar2(255),
	NEW_TRANS_AGENT_ROLE_6  varchar2(255),
	i$status varchar2(255),
	i$collection_id number,
	i$agent_id_1 number,
	i$agent_id_2 number,
	i$agent_id_3 number,
	i$agent_id_4 number,
	i$agent_id_5 number,
	i$agent_id_6 number
	);
			
	<ul>
		<li id="guid_prefix" class="helpLink">GUID_PREFIX</li>
		<li id="ACCN_NUMBER" class="helpLink">ACCN_NUMBER</li>
	</ul>	
			
Columns in <span style="color:red">red</span> are required; others are optional:
<ul>
	<li style="color:red">agent_type</li>
	<li style="color:red">preferred_name</li>
	<li>first_name (agent_type="person" only)</li>
	<li>middle_name (agent_type="person" only)</li>
	<li>last_name (agent_type="person" only)</li>
	<li>birth_date (agent_type="person" only; format 1-Jan-2000)</li>
	<li>death_date (agent_type="person" only; format 1-Jan-2000)</li>
	<li>agent_remark</li>
	<li>prefix (agent_type="person" only)</li>
	<li>suffix (agent_type="person" only)</li>
	<li>other_name_type (second name type)</li>
	<li>other_name (second name)</li>
    <li>other_name_type_2</li>
	<li>other_name_2</li>
    <li>other_name_type_3</li>
	<li>other_name_3</li>				 
</ul>

<cfform name="d" method="post" enctype="multipart/form-data">
	<input type="hidden" name="Action" value="getFile">
	<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
	<input type="submit" value="Upload this file" class="savBtn">
  </cfform>

</cfif>
<!------------------------------------------------------->


<cfif action is "template">
	<cfoutput>
		<cfquery name="q" datasource="uam_god">
			select column_name from user_tab_cols where table_name='CF_TEMP_ACCN' and column_name not like 'I$%' order by INTERNAL_COLUMN_ID
		</cfquery>

		<cfset d=valuelist(q.column_name)>
		<cfset variables.encoding="UTF-8">
		<cfset variables.fileName="#Application.webDirectory#/download/BulkloadAccn.csv">
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			variables.joFileWriter.writeLine(d);
			variables.joFileWriter.close();
		</cfscript>
		<cflocation url="/download.cfm?file=BulkloadAccn.csv" addtoken="false">
		<a href="/download/BulkloadAccn.csv">Click here if your file does not automatically download.</a>
	</cfoutput>
</cfif>


<!------------------------------------------------------->

<!------------------------------------------------------->
<cfif #action# is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_agents
	</cfquery>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset numberOfColumns = ArrayLen(arrResult[1])>

	
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
		<cfif #o# is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>	
		<cfif len(#colVals#) gt 1>
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
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into cf_temp_agents (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
</cfoutput>

 
	<cflocation url="BulkloadAgents.cfm?action=validate">

</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->
<cfif #action# is "validate">
<cfoutput>
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from cf_temp_agents
</cfquery>
<cfquery name="setStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update cf_temp_agents set status='missing_data'
	where agent_type is null OR
	preferred_name is null
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update cf_temp_agents set status='bad_type'
	where status is null AND (
		agent_type not in (select agent_type from ctagent_type))
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update cf_temp_agents set status='bad_prefix'
	where status is null AND 
	prefix is not null and (
		prefix not in (select prefix from ctprefix))
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update cf_temp_agents set status='bad_suffix'
	where status is null AND 
	suffix is not null and (
		suffix not in (select suffix from ctsuffix))
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update cf_temp_agents set status='last_name_required'
	where status is null AND 
		agent_type ='person' and
		last_name is null
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update cf_temp_agents set status='not_a_person'
	where status is null AND 
	agent_type != 'person' and (
		suffix is not null OR
		prefix is not null OR
		birth_date is not null OR
		death_date is not null OR
		first_name is not null OR
		middle_name is not null OR
		last_name is not null)
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update cf_temp_agents set status='missing_name_type'
	where status is null AND 
	other_name is not null and other_name_type is null
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update cf_temp_agents set status='bad_name_type'
	where status is null AND 
	other_name is not null and other_name_type is not null and
	other_name_type not in (select agent_name_type from ctagent_name_type)
</cfquery>
<cfquery name="setStatus3" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update cf_temp_agents set status='bad_name_type'
	where status is null AND 
	other_name_2 is not null and other_name_type_2 is not null and
	other_name_type_2 not in (select agent_name_type from ctagent_name_type)
</cfquery>
<cfquery name="setStatus4" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update cf_temp_agents set status='bad_name_type'
	where status is null AND 
	other_name_3 is not null and other_name_type_3 is not null and
	other_name_type_3 not in (select agent_name_type from ctagent_name_type)
</cfquery>
<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from cf_temp_agents where status is not null
</cfquery>

<cfif bads.recordcount gt 0>
	Your data will not load! See STATUS column below for more information.
	<cfdump var=#bads#>
<cfelse>
	Review the dump below. If everything seems OK, 
	<a href="BulkloadAgents.cfm?action=loadData">click here to proceed</a>.
	<cfdump var=#d#>
</cfif>


</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "loadData">

<cfoutput>
	
		
	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_agents
	</cfquery>
	<cftransaction>
	<cfloop query="getTempData">
		<cfquery name="newAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into agent ( AGENT_ID,AGENT_TYPE ,AGENT_REMARKS , PREFERRED_AGENT_NAME_ID)
			values (sq_agent_id.nextval,'#agent_type#','#agent_remark#',#agent_name_id#)
		</cfquery>
		<cfquery name="newAgentName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into agent_name ( AGENT_NAME_ID,AGENT_ID,AGENT_NAME_TYPE,AGENT_NAME )
			values (sq_agent_name_id.nextval,sq_agent_id.currval,'preferred','#preferred_name#')
		</cfquery>
		
		<cfif #agent_type# is "person">
			<cfquery name="newProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into person (PERSON_ID,PREFIX,LAST_NAME,FIRST_NAME,
					MIDDLE_NAME,SUFFIX,BIRTH_DATE,DEATH_DATE)
				values (sq_agent_id.currval,'#PREFIX#','#LAST_NAME#','#FIRST_NAME#',
					'#MIDDLE_NAME#','#SUFFIX#','#dateformat(BIRTH_DATE,"yyyy-mm-dd")#', '#dateformat(DEATH_DATE,"yyyy-mm-dd")#')
			</cfquery>
		</cfif>
		<cfif len(#OTHER_NAME#) gt 0>
			<cfset agent_name_id = #agent_name_id# + 1>
			<cfquery name="newAgentName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into agent_name ( AGENT_NAME_ID,AGENT_ID,AGENT_NAME_TYPE,AGENT_NAME )
				values (sq_agent_name_id.nextval,sq_agent_id.currval,'#OTHER_NAME_TYPE#','#OTHER_NAME#')
			</cfquery>
		</cfif>
        <cfif len(#OTHER_NAME_2#) gt 0>
			<cfset agent_name_id = #agent_name_id# + 1>
			<cfquery name="newAgentName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into agent_name ( AGENT_NAME_ID,AGENT_ID,AGENT_NAME_TYPE,AGENT_NAME )
				values (sq_agent_name_id.nextval,sq_agent_id.currval,'#OTHER_NAME_TYPE_2#','#OTHER_NAME_2#')
			</cfquery>
		</cfif>
        <cfif len(#OTHER_NAME_3#) gt 0>
			<cfset agent_name_id = #agent_name_id# + 1>
			<cfquery name="newAgentName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into agent_name ( AGENT_NAME_ID,AGENT_ID,AGENT_NAME_TYPE,AGENT_NAME )
				values (sq_agent_name_id.nextval,sq_agent_id.currval,'#OTHER_NAME_TYPE_3#','#OTHER_NAME_3#')
			</cfquery>
		</cfif>
	</cfloop>
	</cftransaction>

	Spiffy, all done.
</cfoutput>
</cfif>

<cfinclude template="/includes/_footer.cfm">