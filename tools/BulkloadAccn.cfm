<cfinclude template="/includes/_header.cfm">
<cfsetting requesttimeout="600">
<cfset title="bulkload accession">
<!---

drop table cf_temp_accn;

create table cf_temp_accn (
	i$key number not null,
	guid_prefix varchar2(255) not null,
	ACCN_NUMBER varchar2(255) not null,
	ACCN_TYPE varchar2(255) not null,
	ACCN_STATUS varchar2(255) not null,
	NATURE_OF_MATERIAL varchar2(4000) not null,
	ESTIMATED_COUNT number,
	TRANS_DATE date,
	RECEIVED_DATE date,
	TRANS_REMARKS varchar2(4000),
	IS_PUBLIC_FG number,
	TRANS_AGENT_1  varchar2(255),
	TRANS_AGENT_ROLE_1  varchar2(255),
	TRANS_AGENT_2  varchar2(255),
	TRANS_AGENT_ROLE_2  varchar2(255),
	TRANS_AGENT_3  varchar2(255),
	TRANS_AGENT_ROLE_3  varchar2(255),
	TRANS_AGENT_4  varchar2(255),
	TRANS_AGENT_ROLE_4  varchar2(255),
	TRANS_AGENT_5  varchar2(255),
	TRANS_AGENT_ROLE_5  varchar2(255),
	TRANS_AGENT_6  varchar2(255),
	TRANS_AGENT_ROLE_6  varchar2(255),
	i$status varchar2(255),
	i$collection_id number,
	i$agent_id_1 number,
	i$agent_id_2 number,
	i$agent_id_3 number,
	i$agent_id_4 number,
	i$agent_id_5 number,
	i$agent_id_6 number
	);

ALTER TABLE cf_temp_accn ADD CONSTRAINT fk_temp_accn_ACCN_TYPE FOREIGN KEY (ACCN_TYPE) REFERENCES ctACCN_TYPE(ACCN_TYPE);
ALTER TABLE cf_temp_accn ADD CONSTRAINT fk_temp_accn_ACCN_TYPE FOREIGN KEY (ACCN_STATUS) REFERENCES ctACCN_STATUS(ACCN_STATUS);
ALTER TABLE cf_temp_accn ADD CONSTRAINT fk_temp_accn_T_AGNT_RL_1 FOREIGN KEY (TRANS_AGENT_ROLE_1) REFERENCES ctTRANS_AGENT_ROLE(TRANS_AGENT_ROLE);
ALTER TABLE cf_temp_accn ADD CONSTRAINT fk_temp_accn_T_AGNT_RL_2 FOREIGN KEY (TRANS_AGENT_ROLE_2) REFERENCES ctTRANS_AGENT_ROLE(TRANS_AGENT_ROLE);
ALTER TABLE cf_temp_accn ADD CONSTRAINT fk_temp_accn_T_AGNT_RL_3 FOREIGN KEY (TRANS_AGENT_ROLE_3) REFERENCES ctTRANS_AGENT_ROLE(TRANS_AGENT_ROLE);
ALTER TABLE cf_temp_accn ADD CONSTRAINT fk_temp_accn_T_AGNT_RL_4 FOREIGN KEY (TRANS_AGENT_ROLE_4) REFERENCES ctTRANS_AGENT_ROLE(TRANS_AGENT_ROLE);
ALTER TABLE cf_temp_accn ADD CONSTRAINT fk_temp_accn_T_AGNT_RL_5 FOREIGN KEY (TRANS_AGENT_ROLE_5) REFERENCES ctTRANS_AGENT_ROLE(TRANS_AGENT_ROLE);
ALTER TABLE cf_temp_accn ADD CONSTRAINT fk_temp_accn_T_AGNT_RL_6 FOREIGN KEY (TRANS_AGENT_ROLE_6) REFERENCES ctTRANS_AGENT_ROLE(TRANS_AGENT_ROLE);

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


<!------------------------------------------------------->
<cfif action is "splitagent">
	for CHAS - customize to use elsewhere
	I$KEY								   NOT NULL NUMBER
 GUID_PREFIX							   NOT NULL VARCHAR2(255)
 ACCN_NUMBER							   NOT NULL VARCHAR2(255)
 ACCN_TYPE							   NOT NULL VARCHAR2(255)
 ACCN_STATUS							   NOT NULL VARCHAR2(255)
 NATURE_OF_MATERIAL						   NOT NULL VARCHAR2(4000)
 ESTIMATED_COUNT							    NUMBER
 TRANS_DATE								    VARCHAR2(22)
 RECEIVED_DATE								    VARCHAR2(22)
 TRANS_REMARKS								    VARCHAR2(4000)
 IS_PUBLIC_FG								    NUMBER
 TRANS_AGENT_1								    VARCHAR2(255)
 TRANS_AGENT_ROLE_1							    VARCHAR2(255)
 TRANS_AGENT_2								    VARCHAR2(255)
 TRANS_AGENT_ROLE_2							    VARCHAR2(255)
 TRANS_AGENT_3								    VARCHAR2(255)
 TRANS_AGENT_ROLE_3							    VARCHAR2(255)
 TRANS_AGENT_4								    VARCHAR2(255)
 TRANS_AGENT_ROLE_4							    VARCHAR2(255)
 TRANS_AGENT_5								    VARCHAR2(255)
 TRANS_AGENT_ROLE_5							    VARCHAR2(255)
 TRANS_AGENT_6								    VARCHAR2(255)
 TRANS_AGENT_ROLE_6							    VARCHAR2(255)
 I$STATUS								    VARCHAR2(255)
 I$COLLECTION_ID							    NUMBER
 I$AGENT_ID_1								    NUMBER
 I$AGENT_ID_2								    NUMBER
 I$AGENT_ID_3								    NUMBER
 I$AGENT_ID_4								    NUMBER
 I$AGENT_ID_5								    NUMBER
 I$AGENT_ID_6								    NUMBER
 TID									    NUMBER

UAM@ARCTOS>

	<cfoutput>
		<cfquery name="q" datasource="uam_god">
			select * from CF_TEMP_ACCN
		</cfquery>
		<cfloop query="q">
			<cfloop from="1" to="4" index="i">
				<cfset thisAgent=evaluate("TRANS_AGENT_" & i)>
				<cfif len(thisAgent) gt 0>
					<br>i=#i#, thisAgent=#thisAgent#
					<cfquery name="d" datasource="uam_god">
						select getAgentID('#thisAgent#') d from dual
					</cfquery>
					<cfif len(d.d) gt 0>
						 id=#d.d#
					<cfelse>
						keep looking....
					</cfif>
				</cfif>
			</cfloop>

		</cfloop>
	</cfoutput>
</cfif>











<cfif action is "nothing">
Step 1: Upload a comma-delimited text file (csv).
<p>
<a href="BulkloadAccn.cfm?action=template">get CSV template</a>
</p>
<p>
	Columns
</p>

	<ul>
		<li style="text-align:left;" id="guid_prefix" class="helpLink">GUID_PREFIX (required)</li>
		<li style="text-align:left;" id="ACCN_NUMBER" class="helpLink">ACCN_NUMBER (required)</li>
		<li style="text-align:left;" id="ACCN_TYPE" class="helpLink">ACCN_TYPE (required)</li>
		<li style="text-align:left;" id="ACCN_STATUS" class="helpLink">ACCN_STATUS (required)</li>
		<li style="text-align:left;" id="NATURE_OF_MATERIAL" class="helpLink">NATURE_OF_MATERIAL (required)</li>
		<li style="text-align:left;" id="ESTIMATED_COUNT" class="helpLink">ESTIMATED_COUNT</li>
		<li style="text-align:left;" id="TRANS_DATE" class="helpLink">TRANS_DATE</li>
		<li style="text-align:left;" id="RECEIVED_DATE" class="helpLink">RECEIVED_DATE</li>
		<li style="text-align:left;" id="TRANS_REMARKS" class="helpLink">TRANS_REMARKS</li>
		<li style="text-align:left;" id="IS_PUBLIC_FG" class="helpLink">IS_PUBLIC_FG (1=yes; anything else=no)</li>
		<li style="text-align:left;" id="TRANS_AGENT" class="helpLink">TRANS_AGENT_n (1-6)</li>
		<li style="text-align:left;" id="TRANS_AGENT_ROLE" class="helpLink">TRANS_AGENT_ROLE_n (1-6)</li>
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
<cfif action is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from CF_TEMP_ACCN
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
				insert into CF_TEMP_ACCN (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
</cfoutput>
<cflocation url="BulkloadAccn.cfm?action=validate" addtoken="false">
</cfif>
<!------------------------------------------------------->
<cfif action is "validate">
<cfoutput>
<cfquery name="gaid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update CF_TEMP_ACCN set
		i$agent_id_1=getAgentID(TRANS_AGENT_1),
		i$agent_id_2=getAgentID(TRANS_AGENT_2),
		i$agent_id_3=getAgentID(TRANS_AGENT_3),
		i$agent_id_4=getAgentID(TRANS_AGENT_4),
		i$agent_id_5=getAgentID(TRANS_AGENT_5),
		i$agent_id_6=getAgentID(TRANS_AGENT_6)
</cfquery>
<cfquery name="cid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update CF_TEMP_ACCN set
		i$collection_id=(select collection_id from collection where collection.guid_prefix=CF_TEMP_ACCN.guid_prefix)
</cfquery>
<cfquery name="cid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update CF_TEMP_ACCN set IS_PUBLIC_FG=0 where IS_PUBLIC_FG is null or IS_PUBLIC_FG != 1
</cfquery>
<cfquery name="dup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update
		CF_TEMP_ACCN
	set
		i$status='duplicate accn number'
	where
		i$collection_id || ':' || ACCN_NUMBER in (select collection_id || ':' || accn_number from trans,accn where trans.transaction_id=accn.transaction_id)
</cfquery>


<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from CF_TEMP_ACCN where i$status is null
</cfquery>
<cfloop query="d">
	<cfset status="">
	<cfif len(i$collection_id) is 0>
		<cfset status=listappend(status,'guid_prefix could not be resolved.',';')>
	</cfif>
	<cfif len(TRANS_AGENT_1) gt 0 and len(i$agent_id_1) is 0>
		<cfset status=listappend(status,'TRANS_AGENT_1 could not be resolved.',';')>
	</cfif>
	<cfif len(status) gt 0>
		<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update CF_TEMP_ACCN set i$status='#status#' where i$key=#i$key#
		</cfquery>
	</cfif>
</cfloop>

<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from CF_TEMP_ACCN where i$status is not null
</cfquery>

<cfif bads.recordcount gt 0>
	Your data will not load! See STATUS column below for more information.
	<cfdump var=#bads#>
<cfelse>
	Review the dump below. If everything seems OK,
	<a href="BulkloadAccn.cfm?action=loadData">click here to proceed</a>.
	<cfdump var=#d#>
</cfif>


</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "loadData">

<cfoutput>



	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from CF_TEMP_ACCN
	</cfquery>
	<cftransaction>
	<cfloop query="getTempData">
		<cfquery name="newTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO trans (
				TRANSACTION_ID,
				TRANS_DATE,
				collection_id,
				TRANSACTION_TYPE
				<cfif len(#NATURE_OF_MATERIAL#) gt 0>
					,NATURE_OF_MATERIAL
				</cfif>
				<cfif len(#TRANS_REMARKS#) gt 0>
					,TRANS_REMARKS
				</cfif>,
				is_public_fg
			) VALUES (
				sq_transaction_id.nextval,
				'#dateformat(TRANS_DATE,"yyyy-mm-dd")#',
				'#i$collection_id#',
				'accn'
				<cfif len(#NATURE_OF_MATERIAL#) gt 0>
					,'#NATURE_OF_MATERIAL#'
				</cfif>
				<cfif len(#TRANS_REMARKS#) gt 0>
					,'#TRANS_REMARKS#'
				</cfif>,
				#is_public_fg#
			)
			</cfquery>
			<cfquery name="newAccn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO accn (
					TRANSACTION_ID,
					ACCN_TYPE
					,accn_number
					,RECEIVED_DATE,
					ACCN_STATUS,
					estimated_count
					)
				VALUES (
					sq_transaction_id.currval,
					'#accn_type#'
					,'#accn_number#'
					,'#dateformat(TRANS_DATE,"yyyy-mm-dd")#',
					'#accn_status#',
					<cfif len(estimated_count) gt 0>
						#estimated_count#
					<cfelse>
						null
					</cfif>
					)
			</cfquery>
			<cfloop from="1" to="6" index="i">
				<cfset thisAgentID=evaluate("i$agent_id_" & i)>
				<cfset thisAgentRole=evaluate("TRANS_AGENT_ROLE_" & i)>
				<cfif len(thisAgentID) gt 0 and len(thisAgentRole) gt 0>
					<cfquery name="newAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into trans_agent (
							transaction_id,
							agent_id,
							trans_agent_role
						) values (
							sq_transaction_id.currval,
							#thisAgentID#,
							'#thisAgentRole#'
						)
					</cfquery>
				</cfif>
			</cfloop>
		</cfloop>
	</cftransaction>

	Spiffy, all done.
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">