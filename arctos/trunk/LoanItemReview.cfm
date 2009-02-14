<cfinclude template="includes/_header.cfm">
 
 
 
 
<cfif not isdefined("loan_request_id")>
	You did something very naughty.<cfabort>
</cfif>
<cfif #Action# is "delete">
	<cfoutput>
	<cfquery name="deleLoanItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	DELETE FROM user_loan_item where collection_object_id = #collection_object_id#
		and loan_request_id = #loan_request_id#
	</cfquery>
		
	</cfoutput>
</cfif>
<!---
<cfquery name="getTissLoanRequests" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from 
		user_loan_item, 
		user_loan_request,
		tissue_sample, 
		coll_object,
		cataloged_item,
		coll_object_encumbrance,
		encumbrance,
		agent_name,
		identification,
		taxonomy
	WHERE
		user_loan_item.collection_object_id = tissue_sample.collection_object_id AND
		user_loan_item.loan_request_id = user_loan_request.loan_request_id AND
		tissue_sample.derived_from_biol_indiv = cataloged_item.collection_object_id AND
		tissue_sample.collection_object_id = coll_object.collection_object_id AND
		coll_object.collection_object_id = coll_object_encumbrance.collection_object_id (+) and
		coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id (+) AND
		encumbrance.encumbering_agent_id = agent_name.agent_id (+) AND
		cataloged_item.accepted_identification_id = identification.identification_id AND
		identification.taxon_name_id = taxonomy.taxon_name_id AND
	 user_loan_item.loan_request_id = #loan_request_id#
</cfquery>
--->
<cfquery name="getPartLoanRequests" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from 
		user_loan_item, 
		user_loan_request,
		specimen_part, 
		coll_object,
		cataloged_item,
		coll_object_encumbrance,
		encumbrance,
		agent_name,
		identification,
		taxonomy
	WHERE
		user_loan_item.collection_object_id = specimen_part.collection_object_id AND
		user_loan_item.loan_request_id = user_loan_request.loan_request_id AND
		specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
		specimen_part.collection_object_id = coll_object.collection_object_id AND
		coll_object.collection_object_id = coll_object_encumbrance.collection_object_id (+) and
		coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id (+) AND
		encumbrance.encumbering_agent_id = agent_name.agent_id (+) AND
		cataloged_item.collection_object_id = identification.collection_object_id AND
		identification.accepted_id_fg = 1 AND
		identification.taxon_name_id = taxonomy.taxon_name_id AND
	 user_loan_item.loan_request_id = #loan_request_id#
</cfquery>
<cfoutput>
Review items in 
	
		#getTissLoanRequests.project_title#
	
		#getPartLoanRequests.project_title#

	.
</cfoutput>
<table border>
	<tr>
		<td>
			CN
		</td>
		<td>
			Item
		</td>
		<td>
			Condition
		</td>
		<td>
			Is Subsample?
		</td>
		<td>
			Remarks
		</td>
		<td>
			Volume Requested
		</td>
		<td>
			Disposition
		</td>
		<td>
			Scientific Name
		</td>
		<td>
			Encumbrance
		</td>
		<td>&nbsp;
			
		</td>
	</tr>
	<!---
<cfoutput query="getTissLoanRequests">




	<tr>
		<td>
			#collection_cde# #cat_num# &nbsp;
		</td>
		<td>
			#tissue_type#&nbsp;
		</td>
		<td>
			#Condition#&nbsp;
		</td>
		<td>
			coming soon....&nbsp;
		</td>
		<td>
			#remarks#&nbsp;
		</td>
		<td>
			#Volume_Requested#&nbsp;
		</td>
		<td>
			#coll_obj_disposition#&nbsp;
		</td>
		<td>
			#scientific_name#&nbsp;
		</td>
		<td>
			#Encumbrance#&nbsp;
		</td>
		<td>
			<form name="remItem" action="LoanItemReview.cfm" method="post">
				<input type="hidden" name="Action" value="delete">
				<input type="hidden" name="collection_object_id" value="#collection_object_id#">
				<input type="hidden" name="loan_request_id" value="#loan_request_id#">
				<input type="submit" value="Remove this item">
			</form>
		</td>
		
	</tr>

</cfoutput>
--->
<cfoutput query="getPartLoanRequests">




	<tr>
		<td>
			#collection_cde# #cat_num#&nbsp;
		</td>
		<td>
			#part_modifier# #part_name# #preserv_method#&nbsp;
		</td>
		<td>
			#Condition#&nbsp;
		</td>
		<td>
			N/A
		</td>
		<td>
			#remarks#&nbsp;
		</td>
		<td>
			#Volume_Requested#&nbsp;
		</td>
		<td>
			#coll_obj_disposition#&nbsp;
		</td>
		<td>
			#scientific_name#&nbsp;
		</td>
		<td>
			#Encumbrance# <cfif len(#agent_name#) gt 0> by #agent_name#</cfif>&nbsp;
		</td>
		<td>
			<form name="remItem" action="LoanItemReview.cfm" method="post">
				<input type="hidden" name="Action" value="delete">
				<input type="hidden" name="collection_object_id" value="#collection_object_id#">
				<input type="hidden" name="loan_request_id" value="#loan_request_id#">
				<input type="submit" value="Remove this item">
			</form>
		</td>
		
	</tr>

</cfoutput>
</table>

<cfinclude template="includes/_footer.cfm">