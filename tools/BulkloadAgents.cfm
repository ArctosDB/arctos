obsolete
<cfabort>
<!---
drop table cf_temp_agents;

create table cf_temp_agents (
	key number not null,
	agent_type varchar2(255),
	preferred_name varchar2(255),
	first_name varchar2(255),
	middle_name varchar2(255),
	last_name varchar2(255),
	birth_date date,
	death_date date,
	agent_remark varchar2(255),
	prefix varchar2(255),
	suffix varchar2(255),
	other_name_type varchar2(255),
	other_name varchar2(255),
	status varchar2(255),
    other_name_type_2 varchar2(255),
    other_name_2 varchar2(255),
    other_name_type_3 varchar2(255),
    other_name_3 varchar2(255)    
	);
	
create public synonym cf_temp_agents for cf_temp_agents;
grant all on cf_temp_agents to coldfusion_user;
grant select on cf_temp_agents to public;

 CREATE OR REPLACE TRIGGER cf_temp_agents_key                                         
 before insert  ON cf_temp_agents
 for each row 
    begin     
    	if :NEW.key is null then                                                                                      
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;                                
    end;                                                                                            
/
sho err


--->

<cfinclude template="/includes/_header.cfm">
<cfif #action# is "nothing">
Step 1: Upload a comma-delimited text file (csv). 
Include column headings, spelled exactly as below. 
<br><span class="likeLink" onclick="document.getElementById('template').style.display='block';">view template</span>
	<div id="template" style="display:none;">
		<label for="t">Copy and save as a .csv file</label>
		<textarea rows="2" cols="80" id="t">agent_type,preferred_name,first_name,middle_name,last_name,birth_date,death_date,agent_remark,prefix,suffix,other_name_type,other_name,other_name_2,other_name_type_2,other_name_3,other_name_type_3</textarea>
	</div> 
<p></p>




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

<cfform name="atts" method="post" enctype="multipart/form-data">
			<input type="hidden" name="Action" value="getFile">
			  <input type="file"
		   name="FiletoUpload"
		   size="45">
			 <input type="submit" value="Upload this file"
		class="savBtn"
		onmouseover="this.className='savBtn btnhov'" 
		onmouseout="this.className='savBtn'">
  </cfform>

</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->

<!------------------------------------------------------->
<cfif #action# is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from cf_temp_agents
</cfquery>
<cfquery name="setStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='missing_data'
	where agent_type is null OR
	preferred_name is null
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='bad_type'
	where status is null AND (
		agent_type not in (select agent_type from ctagent_type))
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='bad_prefix'
	where status is null AND 
	prefix is not null and (
		prefix not in (select prefix from ctprefix))
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='bad_suffix'
	where status is null AND 
	suffix is not null and (
		suffix not in (select suffix from ctsuffix))
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='last_name_required'
	where status is null AND 
		agent_type ='person' and
		last_name is null
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='missing_name_type'
	where status is null AND 
	other_name is not null and other_name_type is null
</cfquery>
<cfquery name="setStatus2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='bad_name_type'
	where status is null AND 
	other_name is not null and other_name_type is not null and
	other_name_type not in (select agent_name_type from ctagent_name_type)
</cfquery>
<cfquery name="setStatus3" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='bad_name_type'
	where status is null AND 
	other_name_2 is not null and other_name_type_2 is not null and
	other_name_type_2 not in (select agent_name_type from ctagent_name_type)
</cfquery>
<cfquery name="setStatus4" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	update cf_temp_agents set status='bad_name_type'
	where status is null AND 
	other_name_3 is not null and other_name_type_3 is not null and
	other_name_type_3 not in (select agent_name_type from ctagent_name_type)
</cfquery>
<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	
		
	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_agents
	</cfquery>
	<cftransaction>
	<cfloop query="getTempData">
		<cfquery name="newAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into agent ( AGENT_ID,AGENT_TYPE ,AGENT_REMARKS , PREFERRED_AGENT_NAME_ID)
			values (sq_agent_id.nextval,'#agent_type#','#agent_remark#',#agent_name_id#)
		</cfquery>
		<cfquery name="newAgentName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into agent_name ( AGENT_NAME_ID,AGENT_ID,AGENT_NAME_TYPE,AGENT_NAME )
			values (sq_agent_name_id.nextval,sq_agent_id.currval,'preferred','#preferred_name#')
		</cfquery>
		
		<cfif #agent_type# is "person">
			<cfquery name="newProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into person (PERSON_ID,PREFIX,LAST_NAME,FIRST_NAME,
					MIDDLE_NAME,SUFFIX,BIRTH_DATE,DEATH_DATE)
				values (sq_agent_id.currval,'#PREFIX#','#LAST_NAME#','#FIRST_NAME#',
					'#MIDDLE_NAME#','#SUFFIX#','#dateformat(BIRTH_DATE,"dd-mmm-yyyy")#', '#dateformat(DEATH_DATE,"dd-mmm-yyyy")#')
			</cfquery>
		</cfif>
		<cfif len(#OTHER_NAME#) gt 0>
			<cfset agent_name_id = #agent_name_id# + 1>
			<cfquery name="newAgentName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into agent_name ( AGENT_NAME_ID,AGENT_ID,AGENT_NAME_TYPE,AGENT_NAME )
				values (sq_agent_name_id.nextval,sq_agent_id.currval,'#OTHER_NAME_TYPE#','#OTHER_NAME#')
			</cfquery>
		</cfif>
        <cfif len(#OTHER_NAME_2#) gt 0>
			<cfset agent_name_id = #agent_name_id# + 1>
			<cfquery name="newAgentName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into agent_name ( AGENT_NAME_ID,AGENT_ID,AGENT_NAME_TYPE,AGENT_NAME )
				values (sq_agent_name_id.nextval,sq_agent_id.currval,'#OTHER_NAME_TYPE_2#','#OTHER_NAME_2#')
			</cfquery>
		</cfif>
        <cfif len(#OTHER_NAME_3#) gt 0>
			<cfset agent_name_id = #agent_name_id# + 1>
			<cfquery name="newAgentName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
