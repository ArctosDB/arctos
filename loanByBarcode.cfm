<cfinclude template="/includes/_header.cfm">
<script>
	function addThis(i){
			 $.getJSON("/component/functions.cfc",
				{
					method : "addPartToLoan",
					transaction_id: $("#transaction_id").val(),
					partID : $("#partID_" + i).val(),
					remark : '',
					instructions: '',
					subsample: $("#ss_" + i).val(),
					returnformat : "json",
					queryformat : 'column'
				},
				function(r) {
					rA=r.split("|");
					if (rA[0]==0){
						alert('fail: ' + rA[1]);
					} else {
						$("#ctl_" + i).html('ADDED TO LOAN');
						$("#barcode_" + i).attr('readonly', true).addClass("readClr");
						$("#ss_" + i).attr('readonly', true).addClass("readClr");
					}
				}
			);
		}
	function remPart(i){
		$("#partID_" + i).val('');
		$("#sp_" + i).remove();
		$("#sn_" + i).remove();
		$("#ci_" + i).remove();
		$("#pn_" + i).remove();
		$("#co_" + i).remove();
		$("#pd_" + i).remove();
		$("#en_" + i).remove();
		$("#ctl_" + i).remove();
		$("#barcode_" + i).val('');
	}
	function getPartByContainer(i){
		$.getJSON("/component/functions.cfc",
			{
				method : "getPartByContainer",
				barcode : $("#barcode_" + i).val(),
				i : i,
				returnformat : "json",
				queryformat : 'column'
			},
			function(r) {
				if (r.DATA.C[0] == 1){
					$("#sp_" + i).remove();
					$("#sn_" + i).remove();
					$("#ci_" + i).remove();
					$("#pn_" + i).remove();
					$("#co_" + i).remove();
					$("#pd_" + i).remove();
					$("#en_" + i).remove();
					$("#ctl_" + i).remove();
					var d='<td id="sp_' + r.DATA.I + '"><a href="/SpecimenDetail.cfm?collection_object_id=' + r.DATA.COLLECTION_OBJECT_ID[0] + '">';
					d+=r.DATA.COLLECTION + ' ' + r.DATA.CAT_NUM + '</a></td>';
					d+='<td id="sn_' + r.DATA.I + '">' + r.DATA.SCIENTIFIC_NAME + '</td>';
					d+='<td id="ci_' + r.DATA.I + '">' + r.DATA.CUSTOMID + '</td>';
					d+='<td id="pn_' + r.DATA.I + '">' + r.DATA.PART_NAME;
					if(r.DATA.SAMPLED_FROM_OBJ_ID!=''){
						d+=' (subsample)';
					}
					d+='</td>';
					d+='<td id="co_' + r.DATA.I + '">' + r.DATA.CONDITION + '</td>';
					d+='<td id="pd_' + r.DATA.I + '">' + r.DATA.COLL_OBJ_DISPOSITION + '</td>';
					d+='<td id="en_' + r.DATA.I + '">' + r.DATA.ENCUMBRANCES + '</td>';
					
					d+='<td id="ctl_' + r.DATA.I + '"><span class="infoLink" onclick="remPart(' + r.DATA.I + ')">[ Remove ]</span>';
					d+='<span class="infoLink" onclick="addThis(' + r.DATA.I + ')">[ Add To Loan ]</span></td>';
					
					$("#tr_" + r.DATA.I).append(d);
					$("#partID_" + r.DATA.I).val(r.DATA.PARTID);
					
				} else {
					alert('fail: ' + r.DATA.C[0]);
				}
			}
		);
	}
	function allss(yn) {
		$("select[id^='ss_']").each(function(e){
			 $("#" + this.id).val(yn);
		});
	}
</script>
<cfif action is "nothing">
	<cfoutput>
		<cfquery name="l" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select 
				loan_number,
				loan_type,
				loan_status,
				loan_instructions,
				loan_description,
				nature_of_material,
				trans_remarks,
				return_due_date,
				trans.collection_id,
				collection.guid_prefix collection,
				concattransagent(trans.transaction_id,'entered by') enteredby
			 from 
				loan, 
				trans,
				collection
			where 
				loan.transaction_id = trans.transaction_id AND
				trans.collection_id=collection.collection_id and
				trans.transaction_id = #transaction_id#
		</cfquery> 
		Adding parts to loan #l.collection# #l.loan_number#.
		
		<br>loan_status: #l.loan_status#
		<br>loan_instructions: #l.loan_instructions#
		<br>nature_of_material: #l.nature_of_material#
		
		<cfquery name="getPartLoanRequests" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select 
				cat_num, 
				cataloged_item.collection_object_id,
				guid_prefix collection,
				part_name,
				condition,
				 sampled_from_obj_id,
				 item_descr,
				 item_instructions,
				 loan_item_remarks,
				 coll_obj_disposition,
				 scientific_name,
				 Encumbrance,
				 agent_name,
				 loan_number,
				 specimen_part.collection_object_id as partID,
				concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
				p1.barcode	 			 
			 from 
				loan_item, 
				loan,
				specimen_part, 
				coll_object,
				cataloged_item,
				coll_object_encumbrance,
				encumbrance,
				agent_name,
				identification,
				collection,
				coll_obj_cont_hist,
				container p,
				container p1
			WHERE
				loan_item.collection_object_id = specimen_part.collection_object_id AND
				loan.transaction_id = loan_item.transaction_id AND
				specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
				specimen_part.collection_object_id = coll_object.collection_object_id AND
				coll_object.collection_object_id = coll_object_encumbrance.collection_object_id (+) and
				coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id (+) AND
				encumbrance.encumbering_agent_id = agent_name.agent_id (+) AND
				cataloged_item.collection_object_id = identification.collection_object_id AND
				identification.accepted_id_fg = 1 AND
				cataloged_item.collection_id=collection.collection_id AND
				specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id (+) AND
				coll_obj_cont_hist.container_id=p.container_id (+) and
				p.parent_container_id=p1.container_id (+) and
			  	loan_item.transaction_id = #transaction_id#
			ORDER BY cat_num
		</cfquery>
		<cfif getPartLoanRequests.recordcount is 0>
			<br>This loan contains no parts.
		<cfelse>
			<br>Existing Parts (use <a href="/a_loanItemReview.cfm?transaction_id=#transaction_id#">Loan Item Review</a> to adjust):
			<table border>
				<tr>
					<th>Barcode</th>
					<th>Specimen</th>
					<th>ID</th>
					<th>#session.CustomOtherIdentifier#</th>
					<th>Part</th>
					<th>PartCondition</th>
					<th>SS?</th>
				</tr>
				<cfloop query="getPartLoanRequests">
					<tr>
						<td>#barcode#</td>
						<td>
							<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">
								#collection# #cat_num#
							</a>
						</td>
						<td>#scientific_name#</td>
						<td>#CustomID#</td>
						<td>#part_name#</td>
						<td>#condition#</td>
						<td>
							<cfif len(sampled_from_obj_id) gt 0>yes<cfelse>no</cfif>
						</td>
					</tr>
				</cfloop>
			</table>
		</cfif>
		<br>Add Parts by Barcode. Scan parts to add to table. Click the links in each part to confirm and add. Use the links below first, if necessary.
		<br>Disposition will automatically update to "on loan."
		<ul>
			<li><span class="likeLink" onclick="allss('1')">[ SubSample All ]</span> / <span class="likeLink" onclick="allss('0')">[ SubSample None ]</span></li>
			<li></li>
		</ul>
		 
		<form name="f" method="post" action="loanByBarcode.cfm">
			<input type="hidden" name="action" value="saveParts">
			<input type="hidden" name="transaction_id" id="transaction_id" value='#transaction_id#'>
			<table border>
				<tr>
					<th>Barcode</th>
					<th>SS?</th>
					<th>Specimen</th>
					<th>ID</th>
					<th>#session.CustomOtherIdentifier#</th>
					<th>Part</th>
					<th>PartCondition</th>
					<th>Disposition</th>
					<th>Encumbrances</th>
				</tr>
				<cfloop from="1" to="100" index="i">
					<tr id="tr_#i#">
						<td>
							<input type="text" id="barcode_#i#" onchange="getPartByContainer(#i#)">
							<input type="hidden" name="partID_#i#" id="partID_#i#">
						</td>
						<td><select name="ss_#i#" id="ss_#i#">
								<option value="0">no</option>
								<option value="1">yes</option>
							</select>
						</td>
					</tr>
				</cfloop>
		</form>
	</cfoutput>
</cfif>
<!----------------->
<cfinclude template="/includes/_footer.cfm">
