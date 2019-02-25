<cfinclude template="/includes/_header.cfm">
<cfsetting requesttimeout="600">
<cfset title="bulkload loan">

<!---
drop table cf_temp_loan;

create table cf_temp_loan (
	i$key number not null,
	guid_prefix varchar2(255) not null,
	LOAN_NUMBER varchar2(255) not null,
	LOAN_TYPE varchar2(255) not null,
	LOAN_STATUS varchar2(255) not null,
	LOAN_DESCRIPTION varchar2(4000),
	NATURE_OF_MATERIAL varchar2(4000) not null,
	TRANS_DATE varchar2(30),
	DUE_DATE varchar2(30),
	CLOSED_DATE varchar2(30),
	LOAN_INSTRUCTIONS  varchar2(4000),
	TRANS_REMARKS varchar2(4000),
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


ALTER TABLE cf_temp_loan ADD CONSTRAINT fk_temp_loan_type FOREIGN KEY (LOAN_TYPE) REFERENCES CTLOAN_TYPE(LOAN_TYPE);
ALTER TABLE cf_temp_loan ADD CONSTRAINT fk_temp_loan_status FOREIGN KEY (LOAN_STATUS) REFERENCES CTLOAN_STATUS(LOAN_STATUS);


ALTER TABLE cf_temp_loan ADD CONSTRAINT fk_temp_loan_T_AGNT_RL_1 FOREIGN KEY (TRANS_AGENT_ROLE_1) REFERENCES ctTRANS_AGENT_ROLE(TRANS_AGENT_ROLE);
ALTER TABLE cf_temp_loan ADD CONSTRAINT fk_temp_loan_T_AGNT_RL_2 FOREIGN KEY (TRANS_AGENT_ROLE_2) REFERENCES ctTRANS_AGENT_ROLE(TRANS_AGENT_ROLE);
ALTER TABLE cf_temp_loan ADD CONSTRAINT fk_temp_loan_T_AGNT_RL_3 FOREIGN KEY (TRANS_AGENT_ROLE_3) REFERENCES ctTRANS_AGENT_ROLE(TRANS_AGENT_ROLE);
ALTER TABLE cf_temp_loan ADD CONSTRAINT fk_temp_loan_T_AGNT_RL_4 FOREIGN KEY (TRANS_AGENT_ROLE_4) REFERENCES ctTRANS_AGENT_ROLE(TRANS_AGENT_ROLE);
ALTER TABLE cf_temp_loan ADD CONSTRAINT fk_temp_loan_T_AGNT_RL_5 FOREIGN KEY (TRANS_AGENT_ROLE_5) REFERENCES ctTRANS_AGENT_ROLE(TRANS_AGENT_ROLE);
ALTER TABLE cf_temp_loan ADD CONSTRAINT fk_temp_loan_T_AGNT_RL_6 FOREIGN KEY (TRANS_AGENT_ROLE_6) REFERENCES ctTRANS_AGENT_ROLE(TRANS_AGENT_ROLE);


create public synonym cf_temp_loan for cf_temp_loan;

grant all on cf_temp_loan to coldfusion_user;

grant select on cf_temp_loan to public;

 CREATE OR REPLACE TRIGGER cf_temp_loan_key
 before insert  ON cf_temp_loan
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
<cfif action is "dupagntrole">
	<cfoutput>
		<cfquery name="q" datasource="uam_god">
			select * from CF_TEMP_LOAN
		</cfquery>
		<cfloop query="q">
			<cfquery name="dup" dbtype="query">
				select a,r from (
					select
					I$AGENT_ID_1 a,
					TRANS_AGENT_ROLE_1 r
					from q where i$key =#i$key#
					union select
					I$AGENT_ID_2 a,
					TRANS_AGENT_ROLE_2 r
					from q where i$key =#i$key#
					)
			</cfquery>
			<cfdump var=#dup#>
		</cfloop>
	</cfoutput>
</cfif>


<cfif action is "nothing">
Step 1: Upload a comma-delimited text file (csv).
<p>
<a href="BulkloadLoan.cfm?action=template">get CSV template</a>
</p>
<p>
	Columns
</p>

	<ul>
		<li style="text-align:left;" id="guid_prefix" class="helpLink">GUID_PREFIX (required)</li>
		<li style="text-align:left;" id="loan_number" class="helpLink">LOAN_NUMBER (required)</li>
		<li style="text-align:left;" id="loan_type" class="helpLink">LOAN_TYPE (required)</li>
		<li style="text-align:left;" id="loan_status" class="helpLink">LOAN_STATUS (required)</li>
		<li style="text-align:left;" id="loan_description" class="helpLink">LOAN_DESCRIPTION</li>
		<li style="text-align:left;" id="nature_of_material" class="helpLink">NATURE_OF_MATERIAL (required)</li>
		<li style="text-align:left;" id="trans_date" class="helpLink">TRANS_DATE</li>
		<li style="text-align:left;" id="due_date" class="helpLink">DUE_DATE</li>
		<li style="text-align:left;" id="closed_date" class="helpLink">CLOSED_DATE</li>
		<li style="text-align:left;" id="loan_instructions" class="helpLink">LOAN_INSTRUCTIONS</li>
		<li style="text-align:left;" id="trans_remarks" class="helpLink">TRANS_REMARKS</li>
		<li style="text-align:left;" id="trans_agent" class="helpLink">TRANS_AGENT_n (1-6)</li>
		<li style="text-align:left;" id="trans_agent_role" class="helpLink">TRANS_AGENT_ROLE_n (1-6)</li>
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
			select column_name from user_tab_cols where table_name='CF_TEMP_LOAN' and column_name not like 'I$%' order by INTERNAL_COLUMN_ID
		</cfquery>
		<cffile action = "write"
		    file = "#Application.webDirectory#/download/BulkloadLoan.csv"
		   	output = "#valuelist(q.column_name)#"
		   	addNewLine = "no">
		<cflocation url="/download.cfm?file=BulkloadLoan.csv" addtoken="false">
		<a href="/download/BulkloadLoan.csv">Click here if your file does not automatically download.</a>
	</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "getFile">
<cfoutput>
	<!--- put this in a temp table --->
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from CF_TEMP_LOAN
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
				insert into CF_TEMP_LOAN (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
</cfoutput>
<cflocation url="BulkloadLoan.cfm?action=validate" addtoken="false">
</cfif>
<!------------------------------------------------------->
<cfif action is "validate">
<cfoutput>
<cfquery name="gaid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update CF_TEMP_LOAN set
		i$agent_id_1=getAgentID(TRANS_AGENT_1),
		i$agent_id_2=getAgentID(TRANS_AGENT_2),
		i$agent_id_3=getAgentID(TRANS_AGENT_3),
		i$agent_id_4=getAgentID(TRANS_AGENT_4),
		i$agent_id_5=getAgentID(TRANS_AGENT_5),
		i$agent_id_6=getAgentID(TRANS_AGENT_6)
</cfquery>


<cfquery name="td" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update CF_TEMP_LOAN set i$status='invalid trans_date' where is_iso8601(trans_date) != 'valid'
</cfquery>

<cfquery name="cdc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update CF_TEMP_LOAN set i$status='invalid CLOSED_DATE' where isdate(CLOSED_DATE)!=1
</cfquery>
<cfquery name="cdc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update CF_TEMP_LOAN set i$status='invalid DUE_DATE' where isdate(DUE_DATE)!=1
</cfquery>



<cfquery name="cid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update CF_TEMP_LOAN set
		i$collection_id=(select collection_id from collection where collection.guid_prefix=CF_TEMP_LOAN.guid_prefix)
</cfquery>
<cfquery name="dup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	update
		CF_TEMP_LOAN
	set
		i$status='duplicate loan number'
	where
		i$collection_id || ':' || loan_NUMBER in (select collection_id || ':' || loan_number from trans,loan where trans.transaction_id=loan.transaction_id)
</cfquery>


<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from CF_TEMP_LOAN where i$status is null
</cfquery>
<cfloop query="d">
	<cfset status="">
	<cfif len(i$collection_id) is 0>
		<cfset status=listappend(status,'guid_prefix could not be resolved.',';')>
	</cfif>
	<cfloop from ="1" to="6" index="i">
		<cfset tas=evaluate("TRANS_AGENT_" & i)>
		<cfset tai=evaluate("i$agent_id_" & i)>
		<cfset tar=evaluate("TRANS_AGENT_ROLE_" & i)>
		<cfif len(tas) gt 0 and len(tai) is 0>
			<cfset status=listappend(status,'TRANS_AGENT_#i# could not be resolved.',';')>
		</cfif>
		<cfif (len(tas) gt 0 and len(tar) is 0) or (len(tas) is 0 and len(tar) gt 0)>
			<cfset status=listappend(status,'TRANS_AGENT and TRANS_AGENT_ROLE must be paired.',';')>
		</cfif>
	</cfloop>

	<cfif len(status) gt 0>
		<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update CF_TEMP_LOAN set i$status='#status#' where i$key=#i$key#
		</cfquery>
	</cfif>
</cfloop>

<cfquery name="bads" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from CF_TEMP_LOAN where i$status is not null
</cfquery>

<cfif bads.recordcount gt 0>
	Your data will not load! See STATUS column below for more information.
	<cfdump var=#bads#>
<cfelse>
	Review the dump below. If everything seems OK,
	<a href="BulkloadLoan.cfm?action=loadData">click here to proceed</a>.
	<cfdump var=#d#>
</cfif>


</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "loadData">

<cfoutput>



	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from CF_TEMP_LOAN
	</cfquery>
	<cftransaction>
	<cfloop query="getTempData">
		<br>#loan_number#
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
				'#TRANS_DATE#',
				'#i$collection_id#',
				'loan'
				<cfif len(#NATURE_OF_MATERIAL#) gt 0>
					,'#NATURE_OF_MATERIAL#'
				</cfif>
				<cfif len(#TRANS_REMARKS#) gt 0>
					,'#TRANS_REMARKS#'
				</cfif>,
				0
			)
			</cfquery>
			<cfquery name="newLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO loan (
					TRANSACTION_ID,
					LOAN_TYPE,
					LOAN_NUMBER,
					LOAN_STATUS,
					LOAN_INSTRUCTIONS,
					RETURN_DUE_DATE,
					LOAN_DESCRIPTION,
					CLOSED_DATE
					)
				VALUES (
					sq_transaction_id.currval,
					'#LOAN_TYPE#'
					,'#LOAN_NUMBER#',
					'#LOAN_STATUS#',
					'#LOAN_INSTRUCTIONS#',
					<cfif len(DUE_DATE) gt 0>
						to_date('#DUE_DATE#'),
					<cfelse>
						NULL,
					</cfif>
					'#LOAN_DESCRIPTION#',
					<cfif len(CLOSED_DATE) gt 0>
						to_date('#CLOSED_DATE#')
					<cfelse>
						NULL
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