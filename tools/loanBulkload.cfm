<cfinclude template="/includes/_header.cfm">
<!---
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


--->
<cfset title="Load Loan Items">


<script type='text/javascript' src='/includes/loadLoanPart.js'></script>


		
<cfif #action# is "nothing">
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
		<li>Loan Item reconciled date is today (#dateformat(now(),"dd mmm yyyy")#)</li>
	</ul>
Step 1: Upload a file comma-delimited text file (CSV) in the following format. (You may copy the template below and save as .CSV)
 Include column headers. 
<ul>
	<li>Institution_Acronym (required)</li>
	<li>Collection_Cde (required)</li>
	<li>Other_Id_Type (required. "catalog number" is acceptable)</li>
	<li>Other_Id_Number (required; display value)</li>
	<li>Part_Name (required)</li>
	<li>Item_Description</li>
	<li>Item_Remarks</li>
	<li>subsample (required. "yes" creates a new part subsample. "no" puts the entire part on loan)</li>
	<li>Loan_Number (required)</li>
</ul>
</cfoutput>

<p>
<div id="template">
		<textarea rows="2" cols="80" id="t">INSTITUTION_ACRONYM,COLLECTION_CDE,OTHER_ID_TYPE,OTHER_ID_NUMBER,PART_NAME,ITEM_DESCRIPTION,ITEM_REMARKS,SUBSAMPLE,LOAN_NUMBER</textarea>
	</div> 

<cfform name="catnum" method="post" enctype="multipart/form-data">
			<input type="hidden" name="Action" value="getFile">
			  <input type="file"
		   name="FiletoUpload"
		   size="45">
			  <input type="submit" value="Upload this file" #saveClr#>
		</cfform>
</cfif>
<!------------------------------------------------------->
<!------------------------------------------------------->
<cfif #action# is "getFile">
	<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into cf_temp_loan_item (#colNames#) values (#preservesinglequotes(colVals)#)
			</cfquery>
		</cfif>
	</cfloop>
	<cfquery name="gotit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_loan_item
	</cfquery>
	<cfdump var="#gotit#">
	If the above table is accurate, <a href="loanBulkload.cfm?action=verify">click here to proceed</a>.
</cfif>
<!------------------------------------------------------->
<cfif #action# is "verify">
<cfoutput>
<cftransaction>
	<cfquery name="loanID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
				collection.institution_acronym=cf_temp_loan_item.institution_acronym and
				collection.collection_cde=cf_temp_loan_item.collection_cde and
				loan.loan_number = cf_temp_loan_item.loan_number
			)
	</cfquery>
	<cfquery name="missedMe" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update cf_temp_loan_item set status = 'loan not found' where
		transaction_id is null
	</cfquery>
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_loan_item where status is null
	</cfquery>  
		<cfloop query="data">
			<cfif #other_id_type# is "catalog number">
				<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select 
						specimen_part.collection_object_id 
					from
						cataloged_item,
						collection,
						specimen_part,
						coll_object
					where
						cataloged_item.collection_id = collection.collection_id and
						cataloged_item.collection_object_id = specimen_part.derived_from_cat_item and
						specimen_part.collection_object_id = coll_object.collection_object_id and
						collection.institution_acronym = '#institution_acronym#' and
						collection.collection_cde = '#collection_cde#' and
						part_name = '#part_name#' and
						cat_num = #other_id_number# and
						coll_obj_disposition != 'on loan' and
						sampled_from_obj_id is null
				</cfquery>
			<cfelse>
				<cfquery name="collObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select 
						specimen_part.collection_object_id 
					from
						cataloged_item,
						collection,
						specimen_part,
						coll_object,
						coll_obj_other_id_num
					where
						cataloged_item.collection_id = collection.collection_id and
						cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id and
						cataloged_item.collection_object_id = specimen_part.derived_from_cat_item and
						specimen_part.collection_object_id = coll_object.collection_object_id and
						collection.institution_acronym = '#institution_acronym#' and
						collection.collection_cde = '#collection_cde#' and
						part_name = '#part_name#' and
						display_value = '#other_id_number#' and
						other_id_type = '#other_id_type#' and
						coll_obj_disposition != 'on loan' and
						sampled_from_obj_id  is null
				</cfquery>
			</cfif>
			<cfif #collObj.recordcount# is 1>
				collObj.recordcount is 1....
				<cfquery name="defDescr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
							specimen_part.collection_object_id = #collObj.collection_object_id# and
							specimen_part.derived_from_cat_item = cataloged_item.collection_object_id and
							cataloged_item.collection_id = collection.collection_id
					)
					where key=#key#
				</cfquery>
				<cfif #subsample# is "no">
					<cfif len(partID) is 0>
						<cfquery name="YayCollObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							update
								cf_temp_loan_item
							set
								partID = #collObj.collection_object_id#,
								status='spiffy'
							where
								key=#key#
						</cfquery>
					</cfif>
				<cfelse>
					<!--- make a subsample from the part we found--->
					<cfquery name="makeSubsampleObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
								sq_collection_object_id.nextval,
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
								collection_object_id = #collObj.collection_object_id#)
					</cfquery>
					<cfquery name="makeSubsample" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						INSERT INTO specimen_part (
			 				COLLECTION_OBJECT_ID,
			  				PART_NAME,
			  				PART_MODIFIER,
			  				PRESERVE_METHOD,
			  				DERIVED_FROM_cat_item,
			  				sampled_from_obj_id,
			  				is_tissue)
			  			( select
			  				sq_collection_object_id.currval,
			  				part_name,
			  				part_modifier,
			  				preserve_method,
			  				DERIVED_FROM_cat_item,
			  				#collObj.collection_object_id#,
			  				is_tissue
			  			FROM
			  				specimen_part
			  			WHERE
			  				collection_object_id = #collObj.collection_object_id#)
			  		</cfquery>
					<cfquery name="YayCollObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						update
							cf_temp_loan_item
						set
							partID = sq_collection_object_id.currval,
							status='spiffy'
						where
							key=#key#
					</cfquery>
				</cfif>
			<cfelseif #collObj.recordcount# is 0><!--- no part --->
				no part
				<cfquery name="BooCollObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update
						cf_temp_loan_item
					set
						status='no part found'
					where
						key=#key#
				</cfquery>
			<cfelseif #collObj.recordcount# gt 1 and len(partID) is 0>
				<cfquery name="BooCollObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update
						cf_temp_loan_item
					set
						status='multiple parts found'
					where
						key=#key#
				</cfquery>
			</cfif>
		</cfloop>
	</cftransaction>
	<cfquery name="done" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_loan_item
	</cfquery> 
	<cfdump var=#done#>
	<cfquery name="bads" dbtype="query">
		select count(*) c from done where status != 'spiffy'
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
<!------------------------------------------------------->
<cfif #action# is "pickPart">
<cfoutput>
	<cfquery name="mPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			<cfquery name="mPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				update cf_temp_loan_item set status='spiffy', partID=#thisPartId# where key=#thisKey#
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="loanBulkload.cfm?action=verify">
</cfoutput>
</cfif>
<!------------------------------------------------------->
<cfif #action# is "loadData">
<cfoutput>
	
		<cfset RECONCILED_DATE = #dateformat(now(),"dd-mmm-yyyy")#>
		
		
		
	<cfquery name="getTempData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_temp_loan_item
	</cfquery>
	<cftransaction>
	<cfloop query="getTempData">
	<cfquery name="move" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		INSERT INTO loan_item (
			transaction_id,
			collection_object_id,
			RECONCILED_BY_PERSON_ID,
			reconciled_date,
			item_descr
			<cfif len(#ITEM_REMARKS#) gt 0>
				,LOAN_ITEM_REMARKS
			</cfif>
			)
		VALUES (
			 #transaction_id#,
			  #partID#,
			  #session.myAgentId#,
			  '#reconciled_date#',
			  '#ITEM_DESCRIPTION#'
			  <cfif len(#ITEM_REMARKS#) gt 0>
				,'#ITEM_REMARKS#'
			</cfif>
			)
			</cfquery>
	</cfloop>
	</cftransaction>
	Spiffy, all done.
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
