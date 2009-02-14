<!--- no security --->
<cfinclude template="../includes/_pickHeader.cfm">
 <cfif not isdefined("collection_object_id")>
	Didn't get a collection_object_id.<cfabort>
</cfif>
<cfif not isdefined("Action")>
	<cfset Action = "nothing">
</cfif>

<cfif  isdefined("session.loan_request_id")>

<cfif #Action# is "nothing">
<cfoutput>
<cfquery name="getLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select project_title from user_loan_request where loan_request_id = #session.loan_request_id#
</cfquery>

Add #collection_cde# #cat_num# #item# to loan #getLoan.project_title#
<br>Note that requests for more than 0.1g of tissue samples will not be approved without additional correspondence to the appropriate curator. 
<br>Parts are usually loaned as a whole item; subsample requests are granted on a case-by-case basis.
<form name="additems" method="post" action="AddLoanItem.cfm">
	<input type="hidden" name="Action" value="AddItem">
	<input type="hidden" name="volume">
	<input type="hidden" name="project_title" value="#getLoan.project_title#">
	<input type="hidden" name="collection_object_id" value="#collection_object_id#">
	<input type="hidden" name="cat_num" value="#cat_num#">
	<input type="hidden" name="item" value="#item#">
	<input type="hidden" name="collection_cde" value="#collection_cde#">
	<br>Item Remarks: 
	<textarea name="remarks" cols="40" rows="4"></textarea>
	<br><input type="button" onClick="additems.volume.value='0.1g';submit();" value="Add 0.1g subsample">
	<br><input type="button" onClick="additems.volume.value='0.25g';submit();" value="Add 0.25g subsample">
	<br><input type="button" onClick="additems.volume.value='0.5g';submit();" value="Add 0.5g subsample">
	<br><input type="button" onClick="additems.volume.value='1g';submit();" value="Add 1g subsample">

	<br><input type="button" onClick="additems.volume.value='whole item';submit();" value="Add whole item">
</form>



</cfoutput>
</cfif>

<cfif #Action# is "AddItem">
	<cfoutput>
	
	<cftransaction action="begin">
		<cftry>
	
	<cfquery name="addLoanItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	
	INSERT INTO user_loan_item (
		LOAN_REQUEST_ID,
		COLLECTION_OBJECT_ID,
		ITEM_REQUEST_DATE,
		VOLUME_REQUESTED
		<cfif len(#remarks#) gt 0>
			,REMARKS
		</cfif> )
	VALUES (
		#session.loan_request_id#,
		#collection_object_id#,
		'#dateformat(now(),"dd-mmm-yyyy")#',
		'#volume#' 
		<cfif len(#remarks#) gt 0>
			,'#REMARKS#'
		</cfif> )
		</cfquery>
			
			<cfcatch type="database">
				#cfcatch.Message#
				<br> You've probably already added this item to your request. 
				<br>Please <a href="##" onClick="self.close();">close</a> this window and try again.
				
				<cfabort>
				
			</cfcatch>
		</cftry>
	</cftransaction>
		
		You have added #collection_cde# #cat_num# #item# <cfif not #volume# is "whole item">(#volume# subsample)</cfif> to loan #project_title#
		<br> Click <a href="##" onClick="self.close();">here</a> to close this window.
</cfoutput>
</cfif>
</cfif>
<cfinclude template="../includes/_pickFooter.cfm">