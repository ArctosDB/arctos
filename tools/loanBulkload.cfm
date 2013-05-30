<cfinclude template="/includes/_header.cfm">

<!---

alter table cf_temp_loan_item add barcode varchar2(255);

alter table cf_temp_loan_item modify OTHER_ID_TYPE null;
alter table cf_temp_loan_item modify OTHER_ID_NUMBER null;
alter table cf_temp_loan_item modify PART_NAME null;



create table cf_temp_loan_item (
 KEY                                                            NUMBER,
 INSTITUTION_ACRONYM                                            VARCHAR2(5),
COLLECTION_CDE                                                 VARCHAR2(4),
 OTHER_ID_TYPE                                                  VARCHAR2(30),
 OTHER_ID_NUMBER                                                VARCHAR2(30),
 PART_NAME                                                      VARCHAR2(30),
 SUBSAMPLE                                                      VARCHAR2(3),
item_description varchar2(255),
item_remarks varchar2(255),
 LOAN_number                                                           VARCHAR2(30),
partID number,
transaction_id number
);

alter table cf_temp_loan_item add PART_DISPOSITION varchar2(255);

alter table cf_temp_loan_item add PART_CONDITION varchar2(255);

alter table cf_temp_loan_item add guid_prefix varchar2(255);
alter table cf_temp_loan_item drop column INSTITUTION_ACRONYM;
alter table cf_temp_loan_item drop column COLLECTION_CDE;

--->
<cfset title="Load Loan Items">
<script type='text/javascript' src='/includes/loadLoanPart.js'></script>
<cfif action is "makeTemplate">
	<cfset header="BARCODE,GUID_PREFIX,OTHER_ID_TYPE,OTHER_ID_NUMBER,PART_NAME,PART_DISPOSITION,PART_CONDITION,ITEM_DESCRIPTION,ITEM_REMARKS,SUBSAMPLE,LOAN_NUMBER">
	<cffile action = "write"
    file = "#Application.webDirectory#/download/BulkLoanItemTemplate.csv"
    output = "#header#"
    addNewLine = "no">
	<cflocation url="/download.cfm?file=BulkLoanItemTemplate.csv" addtoken="false">
</cfif>
<!----------------------------------------------------------------------------->
<cfif action is "downloadForBulkSpecSrchRslt">
<cfoutput>
	<cfset header="BARCODE,GUID_PREFIX,OTHER_ID_TYPE,OTHER_ID_NUMBER,PART_NAME,PART_DISPOSITION,PART_CONDITION,ITEM_DESCRIPTION,ITEM_REMARKS,SUBSAMPLE,LOAN_NUMBER">
	<cfset fileDir = "#Application.webDirectory#">
	<cfset variables.encoding="UTF-8">
	<cfset fname = "loan_bulkloader_prefill.csv">
	<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		variables.joFileWriter.writeLine(ListQualify(header,'"')); 
	</cfscript>
	<cfquery name="getLoanNumber" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select loan_number from loan where transaction_id=#transaction_id#
	</cfquery>

	<cfquery name="getData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			'' barcode,
			SUBSTR(guid, 1 ,INSTR(guid, ':', 1, 2)-1) guid_prefix,
			'catalog number' OTHER_ID_TYPE,
			SUBSTR(guid, INSTR(guid,':', -1, 1)+1) OTHER_ID_NUMBER,
			'' PART_NAME,
			'' PART_DISPOSITION,
			'' PART_CONDITION,
			'' ITEM_DESCRIPTION,
			'' ITEM_REMARKS,
			'' SUBSAMPLE,
			'#getLoanNumber.loan_number#' LOAN_NUMBER
		from
			#session.SpecSrchTab#
	</cfquery>
	<cfloop query="getData">
		<cfset oneLine = "">
		<cfloop list="#header#" index="c">
			<cfset thisData = evaluate("getData." & c)>
			<cfset thisData=replace(thisData,'"','""','all')>			
			<cfif len(oneLine) is 0>
				<cfset oneLine = '"#thisData#"'>
			<cfelse>
				<cfset oneLine = '#oneLine#,"#thisData#"'>
			</cfif>
		</cfloop>
		<cfset oneLine = trim(oneLine)>
		<cfscript>
			variables.joFileWriter.writeLine(oneLine);
		</cfscript>
	</cfloop>
	<cfscript>	
		variables.joFileWriter.close();
	</cfscript>
	<a href="/download/#fname#">Click here</a>
	to download a loan bulkload template containing the results of your search.
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------->
<cfif action is "nothing">
<cfoutput>
	The following must all be true to use this form:
	<ul>
		<li>
			Items in the file you load are not already on loan (check part_disposition)
		</li>
		<li>
			Encumbrances have been checked
		</li>
		<li>A loan has been created in Arctos.</li>
		<li>Loan Item reconciled person is you (<i>#session.username#</i>)</li>
		<li>Loan Item reconciled date is today (#dateformat(now(),"yyyy-mm-dd")#)</li>
	</ul>
</cfoutput>
	Step 1: Upload a file comma-delimited text file (CSV). Include column headers.
	<br>
	<a href="loanBulkload.cfm?action=makeTemplate">[ get a template ]</a>
	<table border>
		<tr>
			<th>ColumnName</th>
			<th>Required</th>
			<th>Explanation</th>
			<th>Documentation</th>
		</tr>
		<tr>
			<td>barcode</td>
			<td>yes (or specimen+part)</td>
			<td>
				Part's immediate parent container - the cryovial holding a tissue sample, for example.
				Used preferentially instead of cataloged item + part information.
			</td>
			<td><a  target="_blank" class="external" href="http://arctosdb.org/documentation/container/">docs</a></td>
		</tr>
		<tr>
			<td>guid_prefix</td>
			<td>yes (or barcode)</td>
			<td>find under Manage Collections - things like "UAM:Mamm"</td>
			<td><a  target="_blank" class="external" href="http://arctosdb.org/documentation/catalog/#guid">docs</a></td>
		</tr>
		<tr>
			<td>other_id_type</td>
			<td>yes (or barcode)</td>
			<td>"catalog number" is valid but not in teh code table</td>
			<td><a target="_blank" href="/info/ctDocumentation.cfm?table=CTCOLL_OTHER_ID_TYPE">CTCOLL_OTHER_ID_TYPE</a></td>
		</tr>
		<tr>
			<td>other_id_number</td>
			<td>yes (or barcode)</td>
			<td>the value of the identifier/catalog number</td>
			<td></td>
		</tr>
		<tr>
			<td>PART_NAME</td>
			<td>yes (or barcode)</td>
			<td>full name of a part that exists for the cataloged item</td>
			<td><a target="_blank" href="/info/ctDocumentation.cfm?table=CTSPECIMEN_PART_NAME">CTSPECIMEN_PART_NAME</a></td>
		</tr>
		<tr>
			<td>PART_DISPOSITION</td>
			<td>yes</td>
			<td>update the part to this disposition - generally "on loan"</td>
			<td><a target="_blank" href="/info/ctDocumentation.cfm?table=CTCOLL_OBJ_DISP">CTCOLL_OBJ_DISP</a></td>
		</tr>
		<tr>
			<td>PART_CONDITION</td>
			<td>no</td>
			<td>provide a value to update condition; leave blank to make no changes</td>
			<td></td>
		</tr>
		<tr>
			<td>ITEM_DESCRIPTION</td>
			<td>no</td>
			<td>will default to collection.collection || ' ' || cat_num || ' ' || part_name if left null</td>
			<td></td>
		</tr>
		<tr>
			<td>ITEM_REMARKS</td>
			<td>no</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td>SUBSAMPLE</td>
			<td>yes</td>
			<td>1 creates a new part subsample. 0 puts the entire part on loan</td>
			<td>0 or 1</td>
		</tr>
		<tr>
			<td>LOAN_NUMBER</td>
			<td>yes</td>
			<td>Loan.Loan_Number - does not include collection as is often displayed with loan number; collection comes from part's owning collection</td>
			<td></td>
		</tr>
	</table>
	<cfform name="catnum" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<label for="FiletoUpload">Load CSV</label>
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" #saveClr#>
	</cfform>
</cfif>
<!------------------------------------------------------->
<cfif action is "getFile">
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from cf_temp_loan_item
	</cfquery>
	<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
	<cfset fileContent=replace(fileContent,"'","''","all")>
	<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
	<cfset colNames="">
	<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
		<cfset colVals="">
			<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
				<cfset thisBit=arrResult[o][i]>
				<cfif #o# is 1>
					<cfset colNames="#colNames#,#thisBit#">
				<cfelse>
					<cfset colVals="#colVals#,'#trim(thisBit)#'">
				</cfif>
			</cfloop>
		<cfif #o# is 1>
			<cfset colNames=replace(colNames,",","","first")>
		</cfif>
		<cfif len(#colVals#) gt 1>
			<cfset colVals=replace(colVals,",","","first")>
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into cf_temp_loan_item (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<cfquery name="gotit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_loan_item
	</cfquery>
	CSV loaded - <a href="loanBulkload.cfm?action=verify">click here to proceed</a>.
</cfif>
<!------------------------------------------------------->
<cfif action is "verify">
<cfoutput>
<cftransaction>
	<cfquery name="loanID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_loan_item
		set
			(guid_prefix)
		= (select
				collection.guid_prefix
			from
				collection,
				cataloged_item,
				specimen_part,
				coll_obj_cont_hist,
				container partcontainer,
				container barcodecontainer
			where
				collection.collection_id=cataloged_item.collection_id and
				cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
				specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
				coll_obj_cont_hist.container_id=partcontainer.container_id and
				partcontainer.parent_container_id=barcodecontainer.container_id and
				barcodecontainer.barcode=cf_temp_loan_item.barcode
			)
			where
				guid_prefix is null and
				barcode is not null
	</cfquery>
	<cfquery name="loanID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_loan_item
		set
			(transaction_id)
		= (select
				loan.transaction_id
			from
				trans,loan,collection
			where
				trans.transaction_id = loan.transaction_id and
				trans.collection_id = collection.collection_id and
				upper(collection.guid_prefix)=upper(cf_temp_loan_item.guid_prefix) and
				loan.loan_number = cf_temp_loan_item.loan_number
			)
	</cfquery>
	<cfquery name="missedMe" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update cf_temp_loan_item set status = 'loan not found' where transaction_id is null
	</cfquery>
	<cfquery name="missedMe2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update
			cf_temp_loan_item
		set
			status = 'disposition not found'
		where
			PART_DISPOSITION is not null and
			PART_DISPOSITION not in (select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP)
	</cfquery>
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_loan_item where status is null
	</cfquery>
		<cfloop query="data">
			<cfset msg="spiffy">
			<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
					specimen_part.collection_object_id
				from
					cataloged_item,
					collection,
					specimen_part,
					coll_object,
					coll_obj_other_id_num
					<cfif len(barcode) gt 0>
						,coll_obj_cont_hist,
						container partcontainer,
						container barcodecontainer
					</cfif>
				where
					cataloged_item.collection_id = collection.collection_id and
					cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id (+) and
					cataloged_item.collection_object_id = specimen_part.derived_from_cat_item and
					specimen_part.collection_object_id = coll_object.collection_object_id and
					coll_obj_disposition != 'on loan' and
					sampled_from_obj_id  is null
					<cfif len(barcode) gt 0>
						and specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
						coll_obj_cont_hist.container_id=partcontainer.container_id and
						partcontainer.parent_container_id=barcodecontainer.container_id and
						barcodecontainer.barcode='#barcode#'
					<cfelse>
						and upper(collection.guid_prefix) = '#ucase(guid_prefix)#' and
						part_name = '#part_name#' and
						<cfif other_id_type is "catalog number">
							and cat_num='#other_id_number#'
						<cfelse>
							and display_value = '#other_id_number#' and
							other_id_type = '#other_id_type#'
						</cfif>
					</cfif>
				group by
					specimen_part.collection_object_id
			</cfquery>



			select
					specimen_part.collection_object_id
				from
					cataloged_item,
					collection,
					specimen_part,
					coll_object,
					coll_obj_other_id_num
					<cfif len(barcode) gt 0>
						,coll_obj_cont_hist,
						container partcontainer,
						container barcodecontainer
					</cfif>
				where
					cataloged_item.collection_id = collection.collection_id and
					cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id (+) and
					cataloged_item.collection_object_id = specimen_part.derived_from_cat_item and
					specimen_part.collection_object_id = coll_object.collection_object_id and
					coll_obj_disposition != 'on loan' and
					sampled_from_obj_id  is null
					<cfif len(barcode) gt 0>
						and specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
						coll_obj_cont_hist.container_id=partcontainer.container_id and
						partcontainer.parent_container_id=barcodecontainer.container_id and
						barcodecontainer.barcode='#barcode#'
					<cfelse>
						and upper(collection.guid_prefix) = '#ucase(guid_prefix)#' and
						part_name = '#part_name#' and
						<cfif other_id_type is "catalog number">
							and cat_num='#other_id_number#'
						<cfelse>
							and display_value = '#other_id_number#' and
							other_id_type = '#other_id_type#'
						</cfif>
					</cfif>
				group by
					specimen_part.collection_object_id



			<cfif collObj.recordcount is not 1>
				<cfset msg="coll object found #collObj.recordcount# times">
			</cfif>
			<cfquery name="YayCollObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update
					cf_temp_loan_item
				set
					status='#msg#',
					partID = <cfif len(collObj.collection_object_id) gt 0>#collObj.collection_object_id#<cfelse>NULL</cfif>
				where
					key=#key#
			</cfquery>
		</cfloop>
		<cfquery name="defDescr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				cf_temp_loan_item
			set (ITEM_DESCRIPTION) = (
				select
					collection.collection || ' ' || cataloged_item.cat_num || ' ' || specimen_part.part_name
				from
					cataloged_item,
					collection,
					specimen_part
				where
					specimen_part.collection_object_id = cf_temp_loan_item.partID and
					specimen_part.derived_from_cat_item = cataloged_item.collection_object_id and
					cataloged_item.collection_id = collection.collection_id
				)
			where ITEM_DESCRIPTION is null and status='spiffy'
		</cfquery>
	</cftransaction>
	<cfquery name="valData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_loan_item
	</cfquery>
	<script src="/includes/sorttable.js"></script>
	<cfset header="STATUS,BARCODE,GUID_PREFIX,OTHER_ID_TYPE,OTHER_ID_NUMBER,PART_NAME,PART_DISPOSITION,PART_CONDITION,ITEM_DESCRIPTION,ITEM_REMARKS,SUBSAMPLE,LOAN_NUMBER">
	<table border id="t" class="sortable">
		<tr>
			<cfloop list="#header#" index="i">
				<th>#i#</th>
			</cfloop>
		</tr>
		<cfloop query="valData">
			<tr>
				<cfloop list="#header#" index="i">
					<td>#evaluate("valData." & i)#</td>
				</cfloop>
			</tr>
		</cfloop>
	</table>
	<cfquery name="bads" dbtype="query">
		select count(*) c from valData where status != 'spiffy'
	</cfquery>
	---------#bads.c#-------------
	<cfif bads.c is 0 or bads.c is ''>
		If everything in the table above looks OK, <a href="loanBulkload.cfm?action=loadData">click here to finalize loading</a>.
	<cfelse>
		Something isn't happy. Check the status column in the above table, fix your data, and try again.
		<br> Duplicate parts? <a href="loanBulkload.cfm?action=pickPart">You can pick them</a>.
	</cfif>

</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "pickPart">
<cfoutput>
	<cfquery name="mPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_loan_item where status='multiple parts found'
	</cfquery>
	<table border>
		<tr>
			<th>Specimen</th>
		</tr>
	<cfset i=1>
	<form name="f" method="post" action="loanBulkload.cfm">
		<input type="hidden" name="action" value="savePickPart">
	<cfloop query="mPart">
		<tr>
			<td>
				#INSTITUTION_ACRONYM# #COLLECTION_CDE# #OTHER_ID_TYPE# #OTHER_ID_NUMBER#
			</td>
			<td>
				Part: <input type="text" name="part#key#" id="part#key#" value="#PART_NAME#">
				<input type="hidden" name="partid#key#" id="partid#key#">
				<span class="likeLink" onclick="getPart('partid#key#','part#key#','part=#PART_NAME#&INSTITUTION_ACRONYM=#INSTITUTION_ACRONYM#&COLLECTION_CDE=#COLLECTION_CDE#&id_type=#OTHER_ID_TYPE#&id_value=#OTHER_ID_NUMBER#')">
					pick...
				</span>
			</td>
		</tr>
		<cfset i=i+1>
	</cfloop>
	<cfset nr=i-1>
	<input type="hidden" name="numRows" value="#nr#">
	<tr>
		<td colspan="2">
			<input type="submit" class="savBtn" value="Save Picks">
		</td>
	</tr>
	</form>
	</table>
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "savePickPart">
<cfoutput>
	<cfloop list="#form.fieldnames#" index="f">
		<cfif left(f,6) is "PARTID">
			<cfset thisKey = replace(f,"PARTID","","all")>
			<cfset thisPartId=evaluate(f)>
			<cfquery name="lData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from cf_temp_loan_item where key=#thisKey#
			</cfquery>
			<cfquery name="mPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update cf_temp_loan_item set status='spiffy', partID=#thisPartId# where key=#thisKey#
			</cfquery>
			<cfif len(lData.ITEM_DESCRIPTION) is 0>
				<cfquery name="defDescr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					update
						cf_temp_loan_item
						set (ITEM_DESCRIPTION)
						= (
							select collection.collection || ' ' || cat_num || ' ' || part_name
							from
							cataloged_item,
							collection,
							specimen_part
							where
							specimen_part.collection_object_id = #thisPartId# and
							specimen_part.derived_from_cat_item = cataloged_item.collection_object_id and
							cataloged_item.collection_id = collection.collection_id
					)
					where ITEM_DESCRIPTION is null and key=#thisKey#
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
	<cflocation url="loanBulkload.cfm?action=verify">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif action is "loadData">
<cfoutput>
	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_loan_item
	</cfquery>
	<cftransaction>
		<cfloop query="getTempData">
			<cfif subsample is 1>
				<cfquery name="nid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select sq_collection_object_id.nextval nid from dual
				</cfquery>
				<cfset thisPartId=nid.nid>
				<cfquery name="makeSubsampleObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO coll_object (
						COLLECTION_OBJECT_ID,
						COLL_OBJECT_TYPE,
						ENTERED_PERSON_ID,
						COLL_OBJECT_ENTERED_DATE,
						LAST_EDITED_PERSON_ID,
						COLL_OBJ_DISPOSITION,
						LOT_COUNT,
						CONDITION,
						FLAGS
					) (select
							#thisPartId#,
							'ss',
							#session.myAgentId#,
							sysdate,
							NULL,
							'on loan',
							lot_count,
							condition,
							flags
						from
							coll_object
						where
							collection_object_id = #partID#
					)
				</cfquery>
				<cfquery name="makeSubsample" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO specimen_part (
		 				COLLECTION_OBJECT_ID,
		  				PART_NAME,
		  				DERIVED_FROM_cat_item,
		  				sampled_from_obj_id)
		  			( select
		  				#thisPartId#,
		  				part_name,
		  				DERIVED_FROM_cat_item,
		  				#partID#
		  			FROM
		  				specimen_part
		  			WHERE
		  				collection_object_id = #partID#)
		  		</cfquery>
			<cfelse>
				<cfset thisPartId=partID>
			</cfif>
			<cfquery name="move" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO loan_item (
					transaction_id,
					collection_object_id,
					RECONCILED_BY_PERSON_ID,
					reconciled_date,
					item_descr
					<cfif len(ITEM_REMARKS) gt 0>
						,LOAN_ITEM_REMARKS
					</cfif>
					)
				VALUES (
					 #transaction_id#,
					  #thisPartId#,
					  #session.myAgentId#,
					  sysdate,
					  '#ITEM_DESCRIPTION#'
					  <cfif len(ITEM_REMARKS) gt 0>
						,'#ITEM_REMARKS#'
					</cfif>
					)
			</cfquery>
			<cfquery name="usp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update
					coll_object
				set
					COLL_OBJ_DISPOSITION='#PART_DISPOSITION#'
					<cfif len(PART_CONDITION) gt 0>
						condition='#PART_CONDITION#'
					</cfif>
				where
					collection_object_id=#partID#
			</cfquery>
		</cfloop>
	</cftransaction>
	Spiffy, all done.
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
