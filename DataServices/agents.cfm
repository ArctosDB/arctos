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
	agent_remark varchar2(4000)
	);
	
	
	alter table ds_temp_agent add requires_admin_override number;
	
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




---->
<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
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
		<textarea rows="2" cols="80" id="t">agent_type,preferred_name,first_name,middle_name,last_name,birth_date,death_date,prefix,suffix,other_name_1,other_name_type_1,other_name_2,other_name_type_2,other_name_3,other_name_type_3,agent_remark</textarea>
	</div> 
	<p></p>	
	Columns in <span style="color:red">red</span> are required; others are optional:
	<ul>
		<li style="color:red">agent_type</li>
		<li style="color:red">preferred_name</li>
		<li>first_name (agent_type="person" only)</li>
		<li>middle_name (agent_type="person" only)</li>
		<li style="color:red">last_name (agent_type="person" only)</li>
		<li>birth_date (agent_type="person" only; format 1-Jan-2000)</li>
		<li>death_date (agent_type="person" only; format 1-Jan-2000)</li>
		<li>agent_remark</li>
		<li>prefix (agent_type="person" only)</li>
		<li>suffix (agent_type="person" only)</li>
		<li>other_name_1</li>
		<li>other_name_type_1</li>
		<li>other_name_2</li>
		<li>other_name_type_2</li>
		<li>other_name_3</li>
		<li>other_name_type_3</li>	 
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
<cflocation url="agents.cfm?action=validate" addtoken="false">
</cfif>
<!----------------------------------->
<cfif action is "validate">
<script src="/includes/sorttable.js"></script>
<cfoutput>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_agent
	</cfquery>
	
	
	
	<cfquery name="p" dbtype="query">
		select distinct(agent_type) agent_type from d
	</cfquery>
	<cfif valuelist(p.agent_type) is not "person">
		<div class="error">Sorry, we can only deal with agent type=person here.</div>
		<cfabort>
	</cfif>
	
	
	
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
		<div class="error">Unaccepable name type(s): #valuelist(ctont.nt)#</div>
		<cfabort>
	</cfif>
	
	<cfset failedKeyList="">
	Scroll to the bottom of the table to continue.
	
	
	
	<table border id="theTable" class="sortable">
		<tr>
			<th>preferred_name</th>
			<th>Status</th>
			<th>first_name</th>
			<th>middle_name</th>
			<th>last_name</th>
			<th>prefix</th>
			<th>suffix</th>
			<th>aka_1</th>
			<th>aka_2</th>
			<th>aka_3</th>
			<th>agent_type</th>
			<th>birth_date</th>
			<th>death_date</th>
			<th>Remark</th>
		</tr>
		<cfset regexStripJunk='[ .,-]'>
		
		
		<cfset fileDir = "#Application.webDirectory#">
		<cfset variables.encoding="UTF-8">
		<cfset fname = "agent_bulk_down.csv">
		<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
		
		<cfset clist='agent_type,preferred_name,first_name,middle_name,last_name,birth_date,death_date,prefix,suffix,other_name_1,other_name_type_1,other_name_2,other_name_type_2,other_name_3,other_name_type_3,agent_remark,suggestions'>
		<cfset autoColList=listdeleteat(clist,listfindnocase(clist,'suggestions'))>
			
		<cfscript>
			variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
			variables.joFileWriter.writeLine(ListQualify(clist,'"')); 
		</cfscript>
	
	
		<cfset hasProbs=false>
		<cfloop query="d">
			<cfset strippedUpperFML=ucase(rereplace(d.first_name & d.middle_name & d.last_name,regexStripJunk,"","all"))>
			<cfset strippedUpperFL=ucase(rereplace(d.first_name & d.last_name,regexStripJunk,"","all"))>
			<cfset strippedUpperLF=ucase(rereplace(d.last_name & d.first_name,regexStripJunk,"","all"))>
			<cfset strippedUpperLFM=ucase(rereplace(d.last_name & d.first_name & d.middle_name,regexStripJunk,"","all"))>
			<cfset strippedP=ucase(rereplace(d.preferred_name,regexStripJunk,"","all"))>
			<cfset strippedo1=ucase(rereplace(d.other_name_1,regexStripJunk,"","all"))>
			<cfset strippedo2=ucase(rereplace(d.other_name_2,regexStripJunk,"","all"))>
			<cfset strippedo3=ucase(rereplace(d.other_name_3,regexStripJunk,"","all"))>
				
			<cfset strippedNamePermutations=strippedUpperFML>
			<cfset strippedNamePermutations=listappend(strippedNamePermutations,strippedUpperFL)>
			<cfset strippedNamePermutations=listappend(strippedNamePermutations,strippedUpperLF)>
			<cfset strippedNamePermutations=listappend(strippedNamePermutations,strippedUpperLFM)>
			<cfset strippedNamePermutations=listappend(strippedNamePermutations,strippedP)>
			<cfset strippedNamePermutations=listappend(strippedNamePermutations,strippedo1)>
			<cfset strippedNamePermutations=listappend(strippedNamePermutations,strippedo2)>
			<cfset strippedNamePermutations=listappend(strippedNamePermutations,strippedo3)>
			
			<cfset strippedNamePermutations=ListQualify(strippedNamePermutations,"'")>
			
			<cfquery name="isdup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
			        'agent name match' reason,
			        #KEY# key,
			        preferred_agent_name.agent_id, 
			        preferred_agent_name.agent_name preferred_agent_name
				from 
			        agent_name srch,
			        preferred_agent_name
				where 
			        srch.agent_id=preferred_agent_name.agent_id and
			        trim(srch.agent_name) in (
			        	trim('#d.preferred_name#'),
			        	trim('#d.other_name_1#'),
			        	trim('#d.other_name_2#'),
			        	trim('#d.other_name_3#')
			        )
			    group by
			    	preferred_agent_name.agent_id, 
			        preferred_agent_name.agent_name,
			        #key#
			    union
			    select
			    	'first and last name match' reason,
			    	#KEY# key,
			        preferred_agent_name.agent_id, 
			        preferred_agent_name.agent_name preferred_agent_name
				from
					person,
					preferred_agent_name
				where
					person.person_id=preferred_agent_name.agent_id and
					upper(first_name) = trim(upper('#d.first_name#')) and
					upper(last_name) = trim(upper('#d.last_name#'))	
				UNION
				
				 select
			        'nodots-nospaces match on person' reason,
			    	#KEY# key,
			        preferred_agent_name.agent_id, 
			        preferred_agent_name.agent_name preferred_agent_name
				from
					person srch,
					preferred_agent_name
				where
					srch.person_id=preferred_agent_name.agent_id and
					( 
						upper(regexp_replace(srch.first_name || srch.middle_name || srch.last_name ,'#regexStripJunk#', '')) in (
							#preserveSingleQuotes(strippedNamePermutations)#
				     	) or (
						upper(regexp_replace(srch.first_name || srch.last_name ,'#regexStripJunk#', '')) in (
							#preserveSingleQuotes(strippedNamePermutations)#
				        )
				      )
				     )
				 UNION
			    select
			        'nodots-nospaces match on agent name' reason,
			        #KEY# key,
			        preferred_agent_name.agent_id, 
			        preferred_agent_name.agent_name preferred_agent_name
				from 
			        agent_name srch,
			        preferred_agent_name
				where 
			        srch.agent_id=preferred_agent_name.agent_id and
			        upper(regexp_replace(srch.agent_name,'#regexStripJunk#', '')) in (
			        	#preserveSingleQuotes(strippedNamePermutations)#
			        )
			    group by
			    	preferred_agent_name.agent_id, 
			        preferred_agent_name.agent_name,
			        #key#
			</cfquery>
			
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
			<cfquery name="uSugPrefName" dbtype="query">
				select PREFERRED_AGENT_NAME from isdup group by PREFERRED_AGENT_NAME order by PREFERRED_AGENT_NAME
			</cfquery>
			<cfset sugnConcat=replace(valuelist(uSugPrefName.PREFERRED_AGENT_NAME,"|"),'"','""','all')>
			<cfset oneLine=oneLine & ',"#sugnConcat#"'>
			<cfset oneLine = trim(oneLine)>
			<cfscript>
				variables.joFileWriter.writeLine(oneLine);
			</cfscript>
			<tr id="row_#key#">
				<td>#preferred_name#</td>
				<td nowrap="nowrap" id="suggested__#key#">
					<cfloop query="isdup">
						<cfset hasProbs=true>
						<cfset failedKeyList=listappend(failedKeyList,key)>
						<div>
							<a href="/agents.cfm?agent_id=#isdup.AGENT_ID#">#isdup.PREFERRED_AGENT_NAME#</a> (#isdup.REASON#)
						</div>
					</cfloop>
				</td>
				<td>#first_name#&nbsp;</td>
				<td>#middle_name#&nbsp;</td>
				<td>#last_name#&nbsp;</td>
				<td>#prefix#&nbsp;</td>
				<td>#suffix#&nbsp;</td>
				<td>
					<cfif len(other_name_1) gt 0>
						#other_name_1# (#other_name_type_1#)
					</cfif>
				</td>
				<td>
					<cfif len(other_name_2) gt 0>
						#other_name_2# (#other_name_type_2#)
					</cfif>
				</td>
				<td>
					<cfif len(other_name_3) gt 0>
						#other_name_3# (#other_name_type_3#)
					</cfif>
				</td>
				<td>#agent_type#</td>
				<td>#birth_date#&nbsp;</td>
				<td>#death_date#&nbsp;</td>
				<td nowrap="nowrap">#agent_remark#</td>
			</tr>
		</cfloop>
	</table>
	<cfscript>	
		variables.joFileWriter.close();
	</cfscript>
	
	
	<cfif hasProbs is true>
		<cfquery name="fails" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update ds_temp_agent set requires_admin_override=1 where key in (#failedKeyList#)
		</cfquery>
		<cfif session.roles contains "manage_codetables">
			<div style="border:2px solid red;padding:1em;margin:1em;">
				You have manage_codetables, which should mean that you are a member of the Arctos Advisory Committee.
				<br>Click <a href="agents.cfm?action=loadData">here</a> to use your awesome powers to load these data as they are. 
				<br>Be paranoid, please - these warnings still apply.
			</div>
		</cfif> 
		<p>
			Potential problems have been detected in your data. You cannot use this form with these data. 
		</p>
		<p>
			If there are a few false alerts, you can enter those agents manually, delete them from your load file, and continue.
		</p>
		<p>
			If there are many false alerts, send a DBA your data and an explanation of the problem.
		</p>
		<p>
			If you manually create agents because of something that happened here, there is a very high probability that a "not the same as"
				relationship and a note explaining that relationship is necessary. Eliminating this step may result in inadvertent merger.
		</p>
		<p>
			Members of the Arctos Advisory Committee can override these restrictions.
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
	</cfoutput>
	<cftransaction>
		<cfloop query="d">
			<cfquery name="agentID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select sq_agent_id.nextval nextAgentId from dual
			</cfquery>
			<cfquery name="agentNameID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select sq_agent_name_id.nextval nextAgentNameId from dual
			</cfquery>		
			<cfquery name="insPerson" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO agent (
					agent_id,
					agent_type,
					preferred_agent_name_id,
					AGENT_REMARKS
				) VALUES (
					#agentID.nextAgentId#,
					'person',
					#agentNameID.nextAgentNameId#,
					'#trim(d.agent_remark)#'
					)
			</cfquery>		
			<cfquery name="insPerson" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO person ( 
					PERSON_ID
					,prefix
					,LAST_NAME
					,FIRST_NAME
					,MIDDLE_NAME
					,SUFFIX,
					BIRTH_DATE,
					DEATH_DATE
				) VALUES (
					#agentID.nextAgentId#
					,'#trim(d.prefix)#'
					,'#trim(d.LAST_NAME)#'
					,'#trim(d.FIRST_NAME)#'
					,'#trim(d.MIDDLE_NAME)#'
					,'#trim(d.SUFFIX)#'
					,'#trim(d.birth_date)#'
					,'#trim(d.death_date)#'
				)
			</cfquery>
			<cfquery name="insName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO agent_name (
					agent_name_id,
					agent_id,
					agent_name_type,
					agent_name,
					donor_card_present_fg
				) VALUES (
					#agentNameID.nextAgentNameId#,
					#agentID.nextAgentId#,
					'preferred',
					'#trim(d.preferred_name)#',
					0
				)
			</cfquery>
		<!--- stoopid trigger workaround to have preferred name <cftransaction action="commit">--->
			<cfif len(d.other_name_1) gt 0>
				<cfquery name="insName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO agent_name (
						agent_name_id,
						agent_id,
						agent_name_type,
						agent_name,
						donor_card_present_fg
					) VALUES (
						sq_agent_name_id.nextval,
						#agentID.nextAgentId#,
						'#d.other_name_type_1#',
						'#trim(d.other_name_1)#',
						0
					)
				</cfquery>
			</cfif>
			<cfif len(d.other_name_2) gt 0>
				<cfquery name="insName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO agent_name (
						agent_name_id,
						agent_id,
						agent_name_type,
						agent_name,
						donor_card_present_fg
					) VALUES (
						sq_agent_name_id.nextval,
						#agentID.nextAgentId#,
						'#d.other_name_type_2#',
						'#trim(d.other_name_2)#',
						0
					)
				</cfquery>
			</cfif>
			<cfif len(d.other_name_3) gt 0>
				<cfquery name="insName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO agent_name (
						agent_name_id,
						agent_id,
						agent_name_type,
						agent_name,
						donor_card_present_fg
					) VALUES (
						sq_agent_name_id.nextval,
						#agentID.nextAgentId#,
						'#d.other_name_type_3#',
						'#trim(d.other_name_3)#',
						0
					)
				</cfquery>
			</cfif>
		</cfloop>
	</cftransaction>
	everything loaded		
</cfif>
<cfinclude template="/includes/_footer.cfm">