<!----

cheater script:




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


alter table ds_temp_agent drop column REQUIRES_ADMIN_OVERRIDE;
alter table ds_temp_agent drop column FIRST_NAME;
alter table ds_temp_agent drop column MIDDLE_NAME;
alter table ds_temp_agent drop column LAST_NAME;
alter table ds_temp_agent drop column BIRTH_DATE;
alter table ds_temp_agent drop column DEATH_DATE;
alter table ds_temp_agent drop column PREFIX;
alter table ds_temp_agent drop column SUFFIX;

create unique index iu_dsagnt_prefname on ds_temp_agent (preferred_name) tablespace uam_idx_1;

---->
<cfinclude template="/includes/_header.cfm">
<cfsetting requesttimeout="600">
<cfset title="bulkload agents">
<a href="agents.cfm?action=splash">agent loader home</a>


<!----------------------------------->
<cfif action is "splash">
	<cfoutput>


		<p>
			<a href="agents.cfm?action=nothing">Load CSV</a>. This will DELETE anything currently in the loader.
		</p>
		<p>
			<a href="agentNameSplitter.cfm">Agent Name Splitter</a> will accept a list of agent names and return a file that can be bulkloaded here.
		</p>

		<cfquery name="smr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select count(*) c from ds_temp_agent
		</cfquery>
		<p>
			There are #smr.c# records in the agent loader.
		</p>
		<cfif smr.c gt 0>
			<p>
				<a href="agents.cfm?action=validatecsv">Validate</a>
				<br>Note: The validation process is slow. Validation is iterative, so simply reloading your browser will pick up where things left off.
				Some browsers will spin forever or otherwise get confused and not let you know what's up. Click the reload button every 5 minutes or
				so if necessary. Validation should progress at a rate of greater than 500 rows per minute (usually much greater), and time out every ~10 minutes.
				<br>Records with anything in "status" will be ignored. You may <a href="agents.cfm?action=resetstatus">click here to reset status to NULL</a>.
			</p>
			<p>
				<a href="agents.cfm?action=getCSV">Download</a> the agent bulkload data (including status and recommendations) as CSV
			</p>
			<p>
				<a href="/tools/agentPreload.cfm">Agent Preload Thingee</a> will do things with the CSV which can be downloaded from the agent bulkloader. Large datasets
				are manageable in this tool.
			</p>
			<p>
				<a href="agents.cfm?action=viewtable">View Table</a> is a tabular view of the data in the Agent Bulkloader. Large datasets may eat your browser.
			</p>
		</cfif>
		<cfquery name="ns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select count(*) c from ds_temp_agent where status is null
		</cfquery>
		<cfif ns.c is not 0>
			There are #ns.c# records which have not been validated. Use the link above to validate.
		<cfelse>
			<!--- everything validated, see if they all passed ---->
			<cfquery name="aok" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select count(*) c from ds_temp_agent where status = 'no problems detected'
			</cfquery>
			<cfif aok.c is smr.c>
				All records passed validation.
				<p>
					"no problems detected" in the "status" column should never be interpreted as "these data are perfect," but is simply an
					indication that Arctos could not detect similarities between your data and existing data. This may be because
					<ul>
						<li>Your data are so mangled that comparing them to anything is difficult.</li>
						<li>The data in Arctos are so mangled that comparing them to anything is difficult.</li>
						<li>The verification process is busted.</li>
						<li>Your data are useful representations of new-to-Arctos agents.</li>
					</ul>
				</p>
				<p>
					Please take a few minutes to spot-check your data against existing Arctos agents before proceeding.
				</p>
				<p>
					<a href="agents.cfm?action=loadData">Proceed to load agents</a>
				</p>
			<cfelse>
				<cfquery name="fatals" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select count(*) c from ds_temp_agent where status like '%FATAL%'
				</cfquery>
				<cfif fatals.c gt 0>
					Fatal errors have been detected. These must be corrected.
				<cfelse>
					<cfif session.roles contains "manage_codetables">
						<div style="border:2px solid red;padding:1em;margin:1em;">
							You have manage_codetables, which should mean that you are a member of the Arctos Advisory Committee.
							<br>Click <a href="agents.cfm?action=loadData">here</a> to use your awesome powers to load these data as they are.
							<br>Be paranoid. Carefully review the suggestions in the data before continuing.
						</div>
					</cfif>
					Non-fatal errors have been detected. A member of the Arctos Advisory Committee can force-load these data. Please keep the following in mind.
					Further documentation is available at <a href="http://arctosdb.org/documentation/agent/##create">http://arctosdb.org/documentation/agent/##create</a>
					<p>
						This application errs strongly on the side of preventing the introduction of potentially-problematic agents.
					</p>
					<p>
						Potential problems are often reflections of the limitations in Arctos data and the pre-load tools. Any user with create agents access may
						over-ride these warning by creating agents individually, and members of the Arctos Advisory Committee can ignore these warnings in
						the agent bulkloader.
					</p>
					<p>
						This application is not magic, it just looks for things that have caused problems in the past.
						Be particularly careful of non-person agents (agencies often have many names and acronyms), commonly-changed names (William/Bill, etc.),
						 and "low-quality" agents (J. Smith).
					</p>
					<p>
						We appreciate feedback. Please use the contact link.
					</p>
					<p>
						In the case of any ambiguity (e.g., the sorts of things that cause you to be reading this), a "not the same as"
						relationship and agent remarks will prevent future problems.
					</p>
					<p>
						If you are loading agents as part of a bulkload process, you may need to re-map your data. This can be accomplished by changing
						your data to the suggestions provided by this tool, or by adding "your" agent_names to existing agents.
					</p>
				</cfif>
			</cfif>
		</cfif>

	</cfoutput>
</cfif>
<!------------------------------------------------>
<cfif action is "resetstatus">
	<cfquery name="resetstatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update ds_temp_agent set status=null
	</cfquery>
	<p>
		Status has been reset. Use the link above, or <a href="agents.cfm?action=validatecsv">proceed to validate</a>
	</p>
</cfif>
<!------------------------------------------------>
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
	<br>indexes rebuilt....




	<p>See also /procedures/bulkload_agents.sql</p>
	<p>
		Note: Due to large influxes of duplicate agents, this form is currently set on "paranoid." File an Issue to change how this form works.
		(The interactive form code is preserved as agents_interactive.)
	</p>
	Step 1: Upload a comma-delimited text file (csv).
	Include column headings, spelled exactly as below. This will delete anything currently in the agent bulkloader.
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
	<form name="atts" method="post" action="agents.cfm" enctype="multipart/form-data">
		<input type="hidden" name="action" value="getFile">
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</form>
</cfif>

<!---------------------------------------------------------------->
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
<p>
	Data loaded. Proceed to the <a href="agents.cfm?action=splash">agent bulkloader home page</a>.
</p>
</cfif>
<!----------------------------------->
<cfif action is "validatecsv">

<p>
	If you receive a timeout error, just reload - this page will pick up where it stopped.
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
			<cfset fnProbs="">

	<cfoutput>
			<br>preferred_name="#preferred_name#",
			<br>first_name="#fn#",
			<br>middle_name="#mn#",
			<br>last_name="#ln#"
			<cfset fnProbs = obj.checkAgent(
				preferred_name="#preferred_name#",
				agent_type="#agent_type#",
				first_name="#fn#",
				middle_name="#mn#",
				last_name="#ln#"
			)>
			<cfdump var=#fnProbs#>

	<cfflush>
</cfoutput>
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
		<p>
			<a href="agents.cfm?action=splash">go to the agent loader home page for options</a>
		</p>
	</p>
</cfif>
<!---------------------------------------------------------------------------->
<cfif action is "getCSV">
	<cfquery name="mine" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ds_temp_agent
	</cfquery>
	<cfset  util = CreateObject("component","component.utilities")>
	<cfset fldlst=mine.columnlist>
	<cfset fldlst=listdeleteat(fldlst,listfindnocase(fldlst,'key'))>
	<cfset csv = util.QueryToCSV2(Query=mine,Fields=fldlst)>
	<cffile action = "write"
	    file = "#Application.webDirectory#/download/checked_agents.csv"
    	output = "#csv#"
    	addNewLine = "no">
	<cflocation url="/download.cfm?file=checked_agents.csv" addtoken="false">
</cfif>
<!----------------------------------->
<cfif action is "viewtable">
	<script src="/includes/sorttable.js"></script>
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from ds_temp_agent
		</cfquery>
		Click headers to sort.
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
			<cfloop query="d">
				<tr id="row_#key#">
					<td>#agent_type#</td>
					<td>#preferred_name#</td>
					<td nowrap="nowrap" id="suggested__#key#">
						<div style="overflow:auto;max-height:10em;">
							<cfloop list="#status#" index="p" delimiters=";">
								<li>
									#p#
								</li>
							</cfloop>
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
	</cfoutput>
</cfif>
<cfif action is "loadData">
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from ds_temp_agent
		</cfquery>

		<cfquery name="unvalidated" dbtype="query">
			select count(*) c from d where status is null
		</cfquery>

		<cfif unvalidated.c gt 0>
			There are unvalidated records in the bulkloader. You can't be here. Try the <a href="agents.cfm?action=splash">agent loader home</a> page.
			<cfabort>
		</cfif>


		<cfif session.roles does not contain "manage_codetables">
			<!---- doublecheck --->
			<cfquery name="requiresOverride" dbtype="query">
				select count(*) c from d where status != 'no problems detected'
			</cfquery>
			<cfif requiresOverride.c gt 0>
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