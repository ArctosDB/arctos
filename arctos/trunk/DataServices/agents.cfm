<!----




drop table ds_temp_agent;

create table ds_temp_agent (
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
	other_name_4  varchar2(255),
	other_name_type_4   varchar2(255),
	other_name_5  varchar2(255),
	other_name_type_5   varchar2(255),
	other_name_6  varchar2(255),
	other_name_type_6   varchar2(255),
	agent_remark varchar2(4000),
	agent_status_1 varchar2(255),
	agent_status_date_1 varchar2(255),
	agent_status_2 varchar2(255),
	agent_status_date_2 varchar2(255),
	requires_admin_override number,
	 status varchar2(4000);
	);
	
	
	
	
	alter table ds_temp_agent add status varchar2(4000);
	
create public synonym ds_temp_agent for ds_temp_agent;
grant all on ds_temp_agent to coldfusion_user;
grant select on ds_temp_agent to public;

 CREATE OR REPLACE TRIGGER ds_temp_agent_key                                         
 before insert  ON ds_temp_agent
 for each row 
    begin     
    	if :NEW.key is null then                                                                                      
    		select somerandomsequence.nextval into :new.key from dual;
    	end if;                                
    end;                                                                                            
/
sho err


create unique index iu_dsagnt_prefname on ds_temp_agent (preferred_name) tablespace uam_idx_1;

---->
<cfinclude template="/includes/_header.cfm">
<cfsetting requesttimeout="600">
<cfset title="bulkload agents">
<cfif action is "nothing">
	<cftry>
		<cfquery name="flushOldManipTable" datasource="uam_god">
			drop table cf_agent_isitadup
		</cfquery>
	<br>Old table flushed
	<cfcatch></cfcatch></cftry>
	<cftry>
	<cfquery name="buildNewManipTable" datasource="uam_god">
		create table cf_agent_isitadup as select
			agent_id,
			uppername,
			strippeduppername,
			upperstrippedagencyname
			from
			(select 
			  agent_id,
			  trim(upper(agent_name.agent_name)) uppername,
			  trim(upper(regexp_replace(agent_name.agent_name,'[ .,-]', ''))) strippeduppername,
			         trim(
			          replace(
			            replace(
			              replace(
			                upper(
			                  regexp_replace(agent_name.agent_name,'[ .,-]', '')
			                )
			              ,'US')
			            ,'UNITEDSTATES')
			          ,'THE')
			        ) upperstrippedagencyname
			         from
			         agent_name
					union
					select 
			  agent_id,
			  trim(upper(preferred_agent_name)) uppername,
			  trim(upper(regexp_replace(preferred_agent_name,'[ .,-]', ''))) strippeduppername,
			         trim(
			          replace(
			            replace(
			              replace(
			                upper(
			                  regexp_replace(preferred_agent_name,'[ .,-]', '')
			                )
			              ,'US')
			            ,'UNITEDSTATES')
			          ,'THE')
			        ) upperstrippedagencyname
			         from
			         agent
					)
					group by 
			         agent_id,
			uppername,
			strippeduppername,
			upperstrippedagencyname
	</cfquery>
	<cfcatch></cfcatch></cftry>
	<cftry>
	<cfquery name="di1" datasource="uam_god">
		drop index ix_cf_agent_dupchk_id
	</cfquery>
	<cfcatch></cfcatch></cftry>
	<cftry>
	<cfquery name="di2" datasource="uam_god">
		drop index ix_cf_agent_dupchk_un
	</cfquery>
	<cfcatch></cfcatch></cftry>
	<cftry>
	<cfquery name="di3" datasource="uam_god">
		drop index ix_cf_agent_dupchk_uns
	</cfquery>
	<cfcatch></cfcatch></cftry>
	<cftry>
	<cfquery name="di4" datasource="uam_god">
		drop index ix_cf_agent_dupchk_unsa
	</cfquery>
	<cfcatch></cfcatch></cftry>
	<cftry>
	<cfquery name="ci1" datasource="uam_god">
		create index ix_cf_agent_dupchk_id on cf_agent_isitadup (agent_id) tablespace uam_idx_1
	</cfquery>
	<cfcatch></cfcatch></cftry>
	<cftry>
	<cfquery name="ci2" datasource="uam_god">
		create index ix_cf_agent_dupchk_un on cf_agent_isitadup (uppername) tablespace uam_idx_1
	</cfquery>
	<cfcatch></cfcatch></cftry>
	<cftry>
	<cfquery name="ci3" datasource="uam_god">
		create index ix_cf_agent_dupchk_uns on cf_agent_isitadup (strippeduppername) tablespace uam_idx_1
	</cfquery>
	<cfcatch></cfcatch></cftry>
	<cftry>
	<cfquery name="ci4" datasource="uam_god">
		create index ix_cf_agent_dupchk_unsa on cf_agent_isitadup (upperstrippedagencyname) tablespace uam_idx_1
	</cfquery>
	<cfcatch></cfcatch></cftry>
	<br>indexes build....



	<p>
		<a href="agentNameSplitter.cfm">Agent Name Splitter</a> will accept a list of agent names and return a file that can be used here.
	</p>
	<p>
		Note: Due to large influxes of duplicate agents, this form is currently set on "paranoid." File an Issue to change how this form works.
		(The interactive form code is preserved as agents_interactive.)
	</p>
	Step 1: Upload a comma-delimited text file (csv). 
	Include column headings, spelled exactly as below. 
	<br>
	<a href="/info/ctDocumentation.cfm?table=ctagent_name_type">Valid agent name types</a>
	<br>
	<a href="/info/ctDocumentation.cfm?table=ctagent_type">Valid agent types</a>
	<div id="template">
		<label for="t">Copy and save as a .csv file</label>
		<textarea rows="2" cols="80" id="t">agent_type,preferred_name,other_name_1,other_name_type_1,other_name_2,other_name_type_2,other_name_3,other_name_type_3,other_name_4,other_name_type_4,other_name_5,other_name_type_5,other_name_6,other_name_type_6,agent_status_1,agent_status_date_1,agent_status_2,agent_status_date_2,agent_remark</textarea>
	</div> 
	<p>
		<table border>
			<tr>
				<th>Column</th>
				<th>Required</th>
				<th>Doc</th>
			</tr>
			<tr>
				<td>agent_type</td>
				<td>yes</td>
				<td><a href="/info/ctDocumentation.cfm?table=CTAGENT_TYPE">CTAGENT_TYPE</a></td>
			</tr>
			<tr>
				<td>preferred_name</td>
				<td>yes</td>
				<td><a href="http://arctosdb.org/documentation/agent/#names">http://arctosdb.org/documentation/agent/#names</a></td>
			</tr>
			<tr>
				<td>other_name_n</td>
				<td>no</td>
				<td><a href="http://arctosdb.org/documentation/agent/#names">http://arctosdb.org/documentation/agent/#names</a></td>
			</tr>
			<tr>
				<td>other_name_type_n</td>
				<td>if other_name_n is given</td>
				<td><a href="/info/ctDocumentation.cfm?table=CTAGENT_NAME_TYPE">/info/ctDocumentation.cfm?table=CTAGENT_NAME_TYPE</a></td>
			</tr>
			<tr>
				<td>agent_status_n</td>
				<td>no</td>
				<td><a href="/info/ctDocumentation.cfm?table=CTagent_status">/info/ctDocumentation.cfm?table=CTagent_status</a></td>
			</tr>
			<tr>
				<td>agent_status_date_n</td>
				<td>if agent_status_n is given</td>
				<td><a href="http://arctosdb.org/documentation/dates/">http://arctosdb.org/documentation/dates/</a></td>
			</tr>
			<tr>
				<td>agent_remark</td>
				<td>no</td>
				<td><a href="http://arctosdb.org/documentation/agent/#agent_remark">http://arctosdb.org/documentation/agent/#agent_remark</a></td>
			</tr>
		</table>
	</p>
	
	
	<cfform name="atts" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>

</cfif>
<cfif action is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from ds_temp_agent
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
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into ds_temp_agent (#colNames#) values (#preservesinglequotes(colVals)#)				
			</cfquery>
		</cfif>
	</cfloop>
</cfoutput>
<cflocation url="agents.cfm?action=splash" addtoken="false">
</cfif>


<!----------------------------------->
<cfif action is "splash">
	<br> Data loaded to temp table.
	
	<p>
		<a href="agents.cfm?action=validate">Validate (may time out at several hundred rows)</a>
	</p>
	<p>
		<a href="agents.cfm?action=validatecsv">Validate as CSV (can run iteratively)</a>
		<br>Note: Some browsers will spin forever or otherwise not let you know what's up. Click the button every 5 minutes or
		so if necessary. Things should progress at a rate of greater than 500 rows per minute (usually much greater), and time out every ~2 minutes.
	</p>
</cfif>


<!----------------------------------->
<cfif action is "validatecsv">

<p>
If you receive a timeout error, just reload - this page will pick up where it stopped
</p>
	<cfset obj = CreateObject("component","component.agent")>

	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_agent where status is null
	</cfquery>
	<cfquery name="rpn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from ds_temp_agent where preferred_name is null
	</cfquery>
	<cfif rpn.c is not 0>
		<div class="error">Preferred name is required for every agent.</div>
		<cfabort>
	</cfif>
	<cfquery name="ont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select nt from (
			select
				other_name_type_1 nt
			from
				ds_temp_agent
			union
			select
				other_name_type_2 nt
			from
				ds_temp_agent
			union
			select
				other_name_type_3 nt
			from
				ds_temp_agent
		)
		group by nt
	</cfquery>
	<cfif listfind(valuelist(ont.nt),"preferred")>
		<div class="error">Other name types may not be "preferred"</div>
		<cfabort>
	</cfif>
	<cfquery name="p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from ds_temp_agent where agent_type not in (select agent_type from ctagent_type)
	</cfquery>
	<cfif valuelist(p.c) is not 0>
		<div class="error">invalid agent type</div>
		<cfabort>
	</cfif>
	<cfquery name="ctont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select nt from  
		(
			select
				other_name_type_1 nt
			from
				ds_temp_agent
			union
			select
				other_name_type_2 nt
			from
				ds_temp_agent
			union
			select
				other_name_type_3 nt
			from
				ds_temp_agent
		)
		where nt not in (select agent_name_type from ctagent_name_type)
	</cfquery>
	<cfif ctont.recordcount gt 0>
		<div class="error">Unacceptable name type(s): <cfoutput>#valuelist(ctont.nt)#</cfoutput></div>
		<cfabort>
	</cfif>
	<cfloop query="d">
			<cfset fn="">
			<cfset mn="">
			<cfset ln="">
			
			<cfloop from="1" to="6" index="i">
				<cfset thisNameType=evaluate("other_name_type_" & i)>
				<cfset thisName=evaluate("other_name_" & i)>
				<cfif thisNameType is "first name">
					<cfset fn=thisName>
				<cfelseif thisNameType is "middle name">
					<cfset mn=thisName>
				<cfelseif thisNameType is "last name">
					<cfset ln=thisName>
				</cfif> 
			</cfloop>
			<cfset fnProbs = obj.checkAgent(
				preferred_name="#preferred_name#",
				agent_type="#agent_type#",
				first_name="#fn#",
				middle_name="#mn#",
				last_name="#ln#"
			)>
			<cfset fnProbs=left(fnProbs,4000)>
			<cfif len(fnProbs) is 0>
				<cfset fnProbs='no problems detected'>
			</cfif>
			<cfquery name="ud1" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update ds_temp_agent set status='#fnProbs#' where key=#key#
			</cfquery>
	</cfloop>
	<p>
		If you're seeing this and no errors, the check has probably completed. 
		<a href="agents.cfm?action=getCSV">click here to get CSV</a>. All "status" colunmns should contain something.
	</p>
</cfif>


<!---------------------------------------------------------------------------->
<cfif action is "getCSV">
	<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_agent
	</cfquery>
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset csv = util.QueryToCSV2(Query=mine,Fields=mine.columnlist)>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/checked_agents.csv"
    	output = "#csv#"
    	addNewLine = "no">
	<cflocation url="/download.cfm?file=checked_agents.csv" addtoken="false">
</cfif>


<!----------------------------------->
<cfif action is "validate">
<script src="/includes/sorttable.js"></script>
<cfoutput>
	<cfset obj = CreateObject("component","component.agent")>

	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_agent
	</cfquery>
	<cfquery name="rpn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from ds_temp_agent where preferred_name is null
	</cfquery>
	<cfif rpn.c is not 0>
		<div class="error">Preferred name is required for every agent.</div>
		<cfabort>
	</cfif>
	<cfquery name="ont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select nt from (
			select
				other_name_type_1 nt
			from
				ds_temp_agent
			union
			select
				other_name_type_2 nt
			from
				ds_temp_agent
			union
			select
				other_name_type_3 nt
			from
				ds_temp_agent
		)
		group by nt
	</cfquery>
	<cfif listfind(valuelist(ont.nt),"preferred")>
		<div class="error">Other name types may not be "preferred"</div>
		<cfabort>
	</cfif>
	<cfquery name="p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from ds_temp_agent where agent_type not in (select agent_type from ctagent_type)
	</cfquery>
	<cfif valuelist(p.c) is not 0>
		<div class="error">invalid agent type</div>
		<cfabort>
	</cfif>
	<cfquery name="ctont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select nt from  
		(
			select
				other_name_type_1 nt
			from
				ds_temp_agent
			union
			select
				other_name_type_2 nt
			from
				ds_temp_agent
			union
			select
				other_name_type_3 nt
			from
				ds_temp_agent
		)
		where nt not in (select agent_name_type from ctagent_name_type)
	</cfquery>
	<cfif ctont.recordcount gt 0>
		<div class="error">Unacceptable name type(s): #valuelist(ctont.nt)#</div>
		<cfabort>
	</cfif>
	
	<cfset failedKeyList="">
	Click headers to sort. Scroll to the bottom of the table to continue.
	
	
	
	<table border id="theTable" class="sortable">
		<tr>
			<th>agent_type</th>
			<th>preferred_name</th>
			<th>suggestions</th>
			<th>other_name_type_1</th>
			<th>other_name_1</th>
			<th>other_name_type_2</th>
			<th>other_name_2</th>
			<th>other_name_type_3</th>
			<th>other_name_3</th>
			<th>other_name_type_4</th>
			<th>other_name_4</th>
			<th>other_name_type_5</th>
			<th>other_name_5</th>
			<th>other_name_type_6</th>
			<th>other_name_6</th>
			<th>agent_status_1</th>
			<th>agent_status_date_1</th>
			<th>agent_status_2</th>
			<th>agent_status_date_2</th>
			<th>agent_remark</th>
		</tr>
		<cfset fileDir = "#Application.webDirectory#">
		<cfset variables.encoding="UTF-8">
		<cfset fname = "agent_bulk_down.csv">
		<cfset variables.fileName="#Application.webDirectory#/download/#fname#">

		<cfset clist='agent_type,preferred_name,other_name_1,other_name_type_1,other_name_2,other_name_type_2,other_name_3,other_name_type_3,other_name_4,other_name_type_4,other_name_5,other_name_type_5,other_name_6,other_name_type_6,agent_status_1,agent_status_date_1,agent_status_2,agent_status_date_2,agent_remark,suggestions'>
		<cfset autoColList=listdeleteat(clist,listfindnocase(clist,'suggestions'))>
			
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			variables.joFileWriter.writeLine(ListQualify(clist,'"')); 
		</cfscript>
	
	
		<cfset hasProbs=false>
		
			
		<cfloop query="d">
			<cfset fn="">
			<cfset mn="">
			<cfset ln="">
			
			<cfloop from="1" to="6" index="i">
				<cfset thisNameType=evaluate("other_name_type_" & i)>
				<cfset thisName=evaluate("other_name_" & i)>
				<cfif thisNameType is "first name">
					<cfset fn=thisName>
				<cfelseif thisNameType is "middle name">
					<cfset mn=thisName>
				<cfelseif thisNameType is "last name">
					<cfset ln=thisName>
				</cfif> 
			</cfloop>
			<cfset fnProbs = obj.checkAgent(
				preferred_name="#preferred_name#",
				agent_type="#agent_type#",
				first_name="#fn#",
				middle_name="#mn#",
				last_name="#ln#"
			)>
			
				
			
			
			
		
			
				<cfset oneLine = "">
				<cfloop list="#autoColList#" index="c">
					<cfset thisData = evaluate("d." & c)>
					<cfset thisData=replace(thisData,'"','""','all')>
					<cfif len(oneLine) is 0>
						<cfset oneLine = '"#thisData#"'>
					<cfelse>
						<cfset oneLine = '#oneLine#,"#thisData#"'>
					</cfif>
				</cfloop>
				<cfset oneLine=oneLine & ',"#fnProbs#"'>
				<cfset oneLine = trim(oneLine)>
				<cfscript>
					variables.joFileWriter.writeLine(oneLine);
				</cfscript>
			<tr id="row_#key#">
				<td>#agent_type#</td>
				<td>#preferred_name#</td>
				<td nowrap="nowrap" id="suggested__#key#">
					<div style="overflow:auto;max-height:10em;">
						<cfif len(fnProbs) gt 0>
							<cfset hasProbs=true>
							<cfset failedKeyList=listappend(failedKeyList,key)>
							<cfloop list="#fnProbs#" index="p" delimiters=";">
								<li>
									#p#
								</li>
							</cfloop>
						</cfif>
					</div>
				</td>
				<td>#other_name_type_1#</td>
				<td>#other_name_1#</td>
				<td>#other_name_type_2#</td>
				<td>#other_name_2#</td>
				<td>#other_name_type_3#</td>
				<td>#other_name_3#</td>
				<td>#other_name_type_4#</td>
				<td>#other_name_4#</td>
				<td>#other_name_type_5#</td>
				<td>#other_name_5#</td>
				<td>#other_name_type_6#</td>
				<td>#other_name_6#</td>
				<td>#agent_status_1#</td>
				<td>#agent_status_date_1#</td>
				<td>#agent_status_2#</td>
				<td>#agent_status_date_2#</td>
				<td>#agent_remark#</td>
				
				
				
		</tr>
		
		
		</cfloop>
	</table>
	<cfscript>	
		variables.joFileWriter.close();
	</cfscript>
	
	
	<cfif hasProbs is true>
	
		<cfif listlen(failedKeyList) lte 1000>
			<cfset fkl=failedKeyList>
		<cfelse>
			<!--- deal with oracle, hopefully not mely anything else....---->
			<cfset fkl=listgetat(failedKeyList,1)>
		</cfif>
		<cfquery name="fails" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update ds_temp_agent set requires_admin_override=1 where key in (#fkl#)
		</cfquery>
		<cfif session.roles contains "manage_codetables">
			<div style="border:2px solid red;padding:1em;margin:1em;">
				You have manage_codetables, which should mean that you are a member of the Arctos Advisory Committee.
				<br>Click <a href="agents.cfm?action=loadData">here</a> to use your awesome powers to load these data as they are. 
				<br>Be paranoid. Carefully review the suggestions in the table above before continuing.
			</div>
		</cfif> 
		<p>
			Potential problems have been detected in your data. You cannot use this form with these data. These should not be taken to mean
			that anything is "wrong," simply that this application, which is built to avoid the introduction of low-quality data and 
			duplicate agents, won't deal with them. You can create any name via "create agent," and members of the Arctos Advisory Committee can 
			override these warnings.
		</p>
		<p>
			This application is not magic, it just looks for things that have caused problems that have occurred in the past. 
			Be particularly careful of non-person agents (agencies often have many names and acronyms), commonly-changed names (William/Bill, etc.), and "low-quality" agents (J. Smith).
		</p>
		<p>
			Nothing (NULL) in the "status" column should never be interpreted as "these data are perfect," but rather consider it an indication that 
			the name may be horribly mangled either in your data or in existing Arctos data. This is especially true for prolific collectors and authors who
			have donated specimens to or used specimens from multiple collections.
		</p>
		<p>
			Consider using "unknown" for extremely vague agents. Is "Firstname" (or "Lastname" or initials or ....) somehow
			 functionally more useful than "unknown"? This is always a Curatorial decision, but please consider if a person discovering
			field notes, labels, or other information that clarify low-quality names would have used a different path or might have had a different result 
			if coming from agent "unknown" (or, where allowable, simply NULL).
		</p>
		<p>
			If there are a few false alerts, you can enter those agents manually, delete them from your load file, create manually as necessary, and continue.
		</p>
		<p>
			If there are many false alerts, send a DBA your data and an explanation of the problem.
		</p>
		<p>
			If you manually create agents because of something that happened here, there is a high probability that a "not the same as"
				relationship and a note explaining that relationship is necessary. Eliminating this step may result in inadvertent merger.
		</p>
		<p>
			If you accept suggestions made here, be sure to update the data which uses agents to incorporate the existing spelling. Alternatively,
			you may add agent_names to the existing agents instead of altering your data.
		</p>
		<p>
			<a href="/download/#fname#">Download CSV with suggestions</a>
		</p>
	<cfelse>
		 No problems detected. Review the data one last time, then click <a href="agents.cfm?action=loadData">here</a> to create agents.
	</cfif>
</cfoutput>
</cfif>
<cfif action is "loadData">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from ds_temp_agent
		</cfquery>
	
		<cfif session.roles does not contain "manage_codetables">
			<!---- doublecheck --->
			<cfquery name="requiresOverride" dbtype="query">
				select count(*) c from d where requires_admin_override is not null
			</cfquery>
			<cfif requiresOverride.c is not 0>
				<cfthrow detail = "unauthorized agent load" errorCode = "666"
				    extendedInfo = "@agents.loadData with admin override required and no auth"
				    message = "You are not allowed to be here.">
				<cfabort>
			</cfif>
		</cfif>
		
			<cftransaction>
				<cfloop query="d">
					<br>loading #preferred_name#....
					<cfquery name="agentID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select sq_agent_id.nextval nextAgentId from dual
					</cfquery>
					<cfquery name="insPerson" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						INSERT INTO agent (
							agent_id,
							agent_type,
							PREFERRED_AGENT_NAME,
							AGENT_REMARKS
						) VALUES (
							#agentID.nextAgentId#,
							'#agent_type#',
							'#escapeQuotes(preferred_name)#',
							'#trim(d.agent_remark)#'
							)
					</cfquery>
					
					<cfloop from="1" to="6" index="i">
						<cfset thisNameType=evaluate("other_name_type_" & i)>
						<cfset thisName=evaluate("other_name_" & i)>
						<cfif LEN(thisNameType) GT 0 AND LEN(thisName) GT 0>
							<cfquery name="insName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								INSERT INTO agent_name (
									agent_name_id,
									agent_id,
									agent_name_type,
									agent_name
								) VALUES (
									SQ_AGENT_NAME_ID.NEXTVAL,
									#agentID.nextAgentId#,
									'#thisNameType#',
									'#escapeQuotes(trim(thisName))#'
								)
							</cfquery>
						</cfif> 
					</cfloop>
					<cfloop from="1" to="2" index="i">
						<cfset thisStatus=evaluate("agent_status_" & i)>
						<cfset thisSDate=evaluate("agent_status_date_" & i)>
						<cfif LEN(thisStatus) GT 0 AND LEN(thisSDate) GT 0>
							<cfquery name="insName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
								INSERT INTO AGENT_STATUS (
									AGENT_STATUS_ID,
									agent_id,
									AGENT_STATUS,
									STATUS_DATE
								) VALUES (
									SQ_AGENT_STATUS_ID.NEXTVAL,
									#agentID.nextAgentId#,
									'thisStatus',
									'#thisSDate#'
								)
							</cfquery>
						</cfif>
					</cfloop>
					</cfloop>
					
				</cftransaction>
			
			
	</cfoutput>

	<p>
		everything loaded
	</p>
</cfif>
<cfinclude template="/includes/_footer.cfm">