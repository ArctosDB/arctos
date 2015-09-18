<cfset title="Review Loan Items">
<cfinclude template="includes/_header.cfm">
<script type='text/javascript' src='/includes/_loanReview.js'></script>
<script src="/includes/sorttable.js"></script>
<script type='text/javascript' language="javascript" src='/includes/jtable/jquery.jtable.min.js'></script>
<link rel="stylesheet" title="lightcolor-blue"  href="/includes/jtable/themes/lightcolor/blue/jtable.min.css" type="text/css">
<cfquery name="ctDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select coll_obj_disposition from ctcoll_obj_disp
</cfquery>
<cfif not isdefined("transaction_id")>
	You did something very naughty.<cfabort>
</cfif>
<cfif action is "nothing">

	<script>
		 $(document).ready(function () {
		 	// save condition with change
			$(document).on("change", '[id^="condition_"]', function(){
				i=this.id.replace("condition_", "");
				$(this).addClass('red');
				jQuery.getJSON("/component/functions.cfc",
					{
						method : "updateCondition",
						part_id : i,
						condition : $(this).val(),
						returnformat : "json",
						queryformat : 'column'
					},
					function(r) {
						if (r.DATA.MESSAGE == 'success') {
							$("#condition_" + r.PART_ID).removeClass();
						} else {
							alert('An error occured: \n' + r.DATA.MESSAGE);
						}
					}
				);
			});
			$(document).on("change", '[id^="disposition_"]', function(){
				i=this.id.replace("disposition_", "");
				$(this).addClass('red');
				jQuery.getJSON("/component/functions.cfc",
					{
						method : "updatePartDisposition",
						part_id : i,
						disposition : $(this).val(),
						returnformat : "json",
						queryformat : 'column'
					},
					function(r) {
						if (r.DATA.STATUS == 'success') {
							$("#disposition_" + r.DATA.PART_ID).removeClass();
						} else {
							alert('An error occured: \n' + r.DATA.STATUS);
						}
					}
				);
			});
			$(document).on("change", '[id^="item_instructions_"]', function(){
				i=this.id.replace("item_instructions_", "");
				$(this).addClass('red');

				jQuery.getJSON("/component/functions.cfc",
					{
						method : "updateInstructions",
						part_id : i,
						transaction_id : $("#transaction_id").val(),
						item_instructions : $(this).val(),
						returnformat : "json",
						queryformat : 'column'
					},
					function(r) {
						if (r.DATA.MESSAGE == 'success') {
							$("#item_instructions_" + r.DATA.PART_ID).removeClass();
						} else {
							alert('An error occured: \n' + r.DATA.STATUS);
						}
					}
				);
			});

			$(document).on("change", '[id^="loan_item_remark_"]', function(){
				i=this.id.replace("loan_item_remark_", "");
				$(this).addClass('red');

				jQuery.getJSON("/component/functions.cfc",
					{
						method : "updateLoanItemRemarks",
						part_id : i,
						transaction_id : $("#transaction_id").val(),
						loan_item_remarks : $(this).val(),
						returnformat : "json",
						queryformat : 'column'
					},
					function(r) {
						if (r.DATA.MESSAGE == 'success') {
							$("#loan_item_remark_" + r.DATA.PART_ID).removeClass();
						} else {
							alert('An error occured: \n' + r.DATA.STATUS);
						}
					}
				);
			});












			$(document).on("click", '[id^="delimg_"]', function(){
				// if subsample, offer to also delete the part
				// if not subsample, error if on loan.
				// otherwise remove part from loan
				i=this.id.replace("delimg_", "");
				if ($("#isSubsample" + i).val() > 0) {
					var dialog = $('<p>Delete Confirmation</p>').dialog({
	                    buttons: {
	                        "DELETE this subsample": function() {deleteSubsample(i);},
	                        "REMOVE subsample from loan, keep as part":  function() {removePartFromLoan(i);},
	                        "Cancel":  function() {dialog.dialog('close');}
	                    }
	                });
				} else {
					// confirm and try delete
					var dialog = $('<p>Delete Confirmation</p>').dialog({
	                    buttons: {
	                        "Remove part from loan":  function() {removePartFromLoan(i);},
	                        "Cancel":  function() {dialog.dialog('close');}
	                    }
	                });
				}
			});




		 });// end docready


		function removePartFromLoan(i){
			$(".ui-dialog-content").dialog("close");
			if ($("#disposition_" + i).val() == 'on loan') {
				alert('The part cannot be removed because the disposition is "on loan".');
				return false;
			}
			jQuery.getJSON("/component/functions.cfc",
				{
					method : "remPartFromLoan",
					part_id : i,
					transaction_id : $("#transaction_id").val(),
					returnformat : "json",
					queryformat : 'column'
				},
				function(r) {
					if (r.DATA.MESSAGE=='success'){
						 $('tr[data-record-key="' + i + '"]').remove();
					} else {
						alert('An error occured: \n' + r.DATA.MESSAGE);
					}
				}
			);
		}

		function deleteSubsample(i){
			$(".ui-dialog-content").dialog("close");
			jQuery.getJSON("/component/functions.cfc",
				{
					method : "del_remPartFromLoan",
					part_id : i,
					transaction_id : $("#transaction_id").val(),
					returnformat : "json",
					queryformat : 'column'
				},
				// and remove the row
				function(r) {
					if (r.DATA.MESSAGE=='success'){
						// its deleted, remove the row
							console.log('removerow');
						 $('tr[data-record-key="' + i + '"]').remove();
					} else {
						alert('An error occured: \n' + r.DATA.MESSAGE);
					}
				}
			);
		}

		function processEditStuff(){
			var pid,d,h;
			// condition, history
		    $("tr[data-record-key]").each(function(){
		    	pid=$(this).data("record-key");
		    	d=$("#jsoncond_" + pid).text();
		    	h='<textarea name="condition' + pid + '" rows="2" cols="20" id="condition_' + pid + '">' + d + '</textarea>';
		    	h+='<span class="infoLink" onClick="chgCondition(\'' + pid + '\')">History</span>';
				$("#jsoncond_" + pid).html(h);
			});
			// change disposition to select
			 $('input[id^="disposition_"]').each(function(){
			 	//var i=this.id.replace("disposition_", "");
			 	var v = $(this).val();
				var i=this.id;
			 	var h='<select name="' + this.id + '" id="' +this.id+ '"></select>';
			 	$(this).parent().html(h);
				$('#coll_obj_disposition').find('option').clone().appendTo($("#" + i));
				$("#" + i).val(v);
			});

			//return '<input id="disposition_' + data.record.PARTID + '" type="text" value="' + data.record.COLL_OBJ_DISPOSITION + '">';

			// add a delete button
			//$("span.jtable-column-header-text:contains('Remove'):last").parent().parent().parent().each(function(){
			//	console.log('hi: ' + $(this).html() );
			//	$(this).addClass('red');

			//});



		}

	</script>

	<cfoutput>
		<script type="text/javascript">
		    $(document).ready(function () {
				//$("##usertools").menu();
				//$("##goWhere").menu();
		        $('##loanitems').jtable({
		            title: 'Loan Items',
					paging: true, //Enable paging
		            pageSize: 10, //Set page size (default: 10)
		            sorting: true, //Enable sorting
		            defaultSorting: 'GUID ASC', //Set default sorting
					columnResizable: true,
					multiSorting: true,
					columnSelectable: false,
					recordsLoaded: processEditStuff,
					multiselect: false,
					selectingCheckboxes: false,
	  				selecting: false, //Enable selecting
	          		//selectingCheckboxes: true, //Show checkboxes on first column
	            	selectOnRowClick: false, //Enable this to only select using checkboxes
					pageSizes: [10, 25, 50, 100, 250, 500,5000],
					saveUserPreferences: true,
					actions: {
		                listAction: '/component/functions.cfc?method=getLoanItems&transaction_id=' + $("##transaction_id").val()
		            },
		            fields:  {
						 PARTID: {
		                    key: true,
		                    create: false,
		                    edit: false,
		                    list: false
		                },
		                GUID: {title: 'GUID'},
		                <cfif len(session.CustomOtherIdentifier) gt 0>
		                	#session.CustomOtherIdentifier#: {title: '#session.CustomOtherIdentifier#'},
		                </cfif>
		                SCIENTIFIC_NAME: {title: 'ID as'},
		                PART_NAME: {title: 'Part'},
		                CONDITION: {title: 'Condition'},
		                SAMPLED_FROM_OBJ_ID: {
		                	title: 'Subsmpl?',
		                	display: function (data) {
		                		if (data.record.SAMPLED_FROM_OBJ_ID.length>0){
		                			var h='Yes';
		                		} else {
		                			var h='No';
		                		}
		                		h+='<input id="isSubsample' + data.record.PARTID + '" type="hidden" value="' + data.record.SAMPLED_FROM_OBJ_ID + '">';
								return h;
							}
		                },
		                ITEM_INSTRUCTIONS: {
		                	title: 'Instructions',
		                	display: function (data) {
		                		return '<textarea id="item_instructions_' + data.record.PARTID + '">' + data.record.ITEM_INSTRUCTIONS + '</textarea>';
							}
		                },
		                LOAN_ITEM_REMARKS: {
		                	title: 'ItemRemark',
		                	display: function (data) {
		                		return '<textarea id="loan_item_remark_' + data.record.PARTID + '">' + data.record.LOAN_ITEM_REMARKS + '</textarea>';
							}
		                },
		                COLL_OBJ_DISPOSITION: {
		                	title: 'Disposition',
		                	display: function (data) {
		                		// need a select so do this post-process, but make it easy to find for now
								return '<input id="disposition_' + data.record.PARTID + '" type="text" value="' + data.record.COLL_OBJ_DISPOSITION + '">';
							}
		                },
		                PARTLASTSCANDATE: {
		                	title: 'LastScan'},
		                ENCUMBRANCES: {title: 'Encumbrances'},
		                removecell: {
		                	title: 'Remove',
							display: function (data) {
								return '<img src="/images/del.gif" class="likeLink" id="delimg_' + data.record.PARTID + '">';
							}
						}
		            }
		        });
		        $('##loanitems').jtable('load');
		    });
		</script>
		<cfquery name="theLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				loan_number,
				guid_prefix collection,
				loan_type
			from
				loan,
				trans,
				collection
			where
				loan.transaction_id=trans.transaction_id and
				trans.collection_id=collection.collection_id and
				trans.transaction_id=#transaction_id#
		</cfquery>
		<br><a href="loanItemReview.cfm?action=nothing&transaction_id=#transaction_id#&Ijustwannadownload=yep">Download (csv)</a> - non-data loans only!
		<br><a href="Loan.cfm?action=editLoan&transaction_id=#transaction_id#">back to Edit Loan</a>
		<cfquery name="getDataLoanRequests" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				flat.collection_object_id,
				guid,
				concatSingleOtherId(flat.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
				flat.scientific_name,
				flat.encumbrances
			 from
				flat,
				loan,
				loan_item
			WHERE
				loan.transaction_id = loan_item.transaction_id AND
				loan_item.collection_object_id = flat.collection_object_id AND
			  	loan_item.transaction_id = #transaction_id#
		</cfquery>
		<cfif getDataLoanRequests.recordcount gt 0>
			<p>This loan contains cataloged items (data loan) Manage them here......</p>
		<cfelse>
			<p>This loan contains only parts; you can manage them all here.</p>
		</cfif>
		<hr>
		Remove ALL PARTS from the loan. This form will NOT work with any "on loan" parts so use the disposition-updated first.
		<input type="hidden" id="transaction_id" value="#transaction_id#">
		<form name="BulkUpdateDisp" method="post" action="loanItemReview.cfm">
			<input type="hidden" name="transaction_id" value="#transaction_id#">
			<input type="hidden" name="action" value="deleteEverything">
			<label for="noSrsly">Sure?</label>
			<select name="noSrsly" id="noSrsly" class="reqdClr">
				<option selected="selected">nope</option>
				<option value="yesreally">Yep, delete it all</option>
			</select>
			<label for="sshandlr">Subsamples</label>
			<select name="sshandlr" id="sshandlr" class="reqdClr">
				<option selected="selected"></option>
				<option value="keep">Remove subsamples from the loan, keep the parts</option>
				<option value="delete">DELETE subsamples</option>
			</select>
			<br><input type="submit" value="DELETE EVERYTHING" class="delClr">
		</form>
		<hr>
		<form name="BulkUpdateDisp" method="post" action="loanItemReview.cfm">
			<br>Change disposition to:
			<input type="hidden" name="Action" value="BulkUpdateDisp">
			<input type="hidden" name="transaction_id" value="#transaction_id#">
			<select name="coll_obj_disposition" size="1" id="coll_obj_disposition">
				<option>pick one</option>
				<cfloop query="ctDisp">
					<option value="#coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
				</cfloop>
			</select>
			when disposition is
			<select name="currentcoll_obj_disposition" id="currentcoll_obj_disposition" size="1">
				<option value="">- anything -</option>
				<cfloop query="ctDisp">
					<option value="#coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
				</cfloop>
			</select>
			for all items in this loan, including those not shown on this page.
			<input type="submit" value="Update Disposition" class="savBtn">
		</form>
		<hr>
	</cfoutput>
	<div id="loanitems"></div>
</cfif>
------------------------------------------------------------------------>
<cfif action is "deleteEverything">
	<cfoutput>
		<cfif noSrsly is not "yesreally">
			"Sure?" is required.<cfabort>
		</cfif>
		<cfquery name="ckd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				count(*)
			from
				loan_item,
				specimen_part,
				coll_object
			where
				loan_item.collection_object_id=specimen_part.collection_object_id and
				specimen_part.collection_object_id=coll_object.collection_object_id and
				coll_object.COLL_OBJ_DISPOSITION='on loan' and
				loan_item.transaction_id = #transaction_id#
		</cfquery>
		<cfif ckd.recordcount gt 0>
			Cannot delete with "on loan" disposition.<cfabort>
		</cfif>

		<cftransaction>
			<cfif sshandlr is "delete">
				<!--- DELETE subsamples ---->
				<!---- loopidy because it make easier queries ---->
				<cfquery name="sspls" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select
						specimen_part.DERIVED_FROM_CAT_ITEM,
						specimen_part.collection_object_id
					from
						loan_item,
						specimen_part
					where
						loan_item.collection_object_id=specimen_part.collection_object_id and
						specimen_part.SAMPLED_FROM_OBJ_ID is not null and
						loan_item.transaction_id = #transaction_id#
				</cfquery>
				<cfloop query="sspls">
					<!--- this will cause later failure if the subsample is in another loan ---->
					<cfquery name="deleLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						DELETE FROM loan_item WHERE collection_object_id = #collection_object_id#
						and transaction_id=#transaction_id#
					</cfquery>
					<cfquery name="delePart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						DELETE FROM specimen_part WHERE collection_object_id = #collection_object_id#
					</cfquery>
					<cfquery name="delePartCollObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						DELETE FROM coll_object WHERE collection_object_id = #collection_object_id#
					</cfquery>
					<cfquery name="delePartRemark" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						DELETE FROM coll_object_remark WHERE collection_object_id = #collection_object_id#
					</cfquery>
					<cfquery name="getContID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select container_id from coll_obj_cont_hist where
						collection_object_id = #collection_object_id#
					</cfquery>

					<cfquery name="deleCollCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						DELETE FROM coll_obj_cont_hist WHERE collection_object_id = #collection_object_id#
					</cfquery>
					<cfquery name="deleCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						DELETE FROM container_history WHERE container_id = #getContID.container_id#
					</cfquery>
					<cfquery name="deleCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						DELETE FROM container WHERE container_id = #getContID.container_id#
					</cfquery>
					<cfquery name="delepart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						DELETE FROM specimen_part WHERE collection_object_id = #collection_object_id#
					</cfquery>
					<cfquery name="delepart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						DELETE FROM coll_object WHERE collection_object_id = #collection_object_id#
					</cfquery>
				</cfloop>
			</cfif>
			<!--- and for everything else just remove from the loan ---->
			<cfquery name="deleLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				DELETE FROM loan_item WHERE transaction_id=#transaction_id# and
				collection_object_id in (
					select
						specimen_part.collection_object_id
					from
						loan_item,
						specimen_part
					where
						loan_item.collection_object_id=specimen_part.collection_object_id and
						loan_item.transaction_id = #transaction_id#
				)
			</cfquery>
		</cftransaction>
		<cflocation url="loanItemReview.cfm?transaction_id=#transaction_id#">
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------->
<cfif action is "delete">
	<cfoutput>
		<cfif isdefined("coll_obj_disposition") AND coll_obj_disposition is "on loan">
			<!--- see if it's a subsample --->
			<cfquery name="isSSP" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select SAMPLED_FROM_OBJ_ID from specimen_part where collection_object_id = #partID#
			</cfquery>
			<cfif isSSP.SAMPLED_FROM_OBJ_ID gt 0>
				You cannot remove this item from a loan while it's disposition is "on loan."
				<br />Use the form below if you'd like to change the disposition and remove the item
				from the loan, or to delete the item from the database completely.
				<form name="cC" method="post" action="a_loanItemReview.cfm">
					<input type="hidden" name="action" />
					<input type="hidden" name="transaction_id" value="#transaction_id#" />
					<input type="hidden" name="item_instructions" value="#item_instructions#" />
					<input type="hidden" name="loan_item_remarks" value="#loan_item_remarks#" />
					<input type="hidden" name="partID" value="#partID#" />
					<input type="hidden" name="spRedirAction" value="delete" />
					Change disposition to: <select name="coll_obj_disposition" size="1">
						<cfloop query="ctDisp">
							<option value="#coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
						</cfloop>
					</select>
					<p />
					<input type="button"
						class="delBtn"
						value="Remove Item from Loan"
						onclick="cC.action.value='saveDisp'; submit();" />
					<p /><input type="button"
						class="delBtn"
						value="Delete Subsample From Database"
						onclick="cC.action.value='killSS'; submit();"/>
						<p /><input type="button"
						class="qutBtn"
						value="Discard Changes"
						onclick="cC.action.value='nothing'; submit();"/>
				</form>
				<cfabort>
			<cfelse><!--- not a subsample; disallow delete ---->
				You cannot remove this item from a loan while it's disposition is "on loan."
				<br />Use the form below if you'd like to change the disposition and remove the item
				from the loan.
				<form name="cC" method="post" action="a_loanItemReview.cfm">
					<input type="hidden" name="action" />
					<input type="hidden" name="transaction_id" value="#transaction_id#" />
					<input type="hidden" name="item_instructions" value="#item_instructions#" />
					<input type="hidden" name="loan_item_remarks" value="#loan_item_remarks#" />
					<input type="hidden" name="partID" id="partID" value="#partID#" />
					<input type="hidden" name="spRedirAction" value="delete" />
					<br />Change disposition to: <select name="coll_obj_disposition" size="1">
						<cfloop query="ctDisp">
							<option value="#coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
						</cfloop>
					</select>
					<br /><input type="button"
						class="delBtn"
						value="Remove Item from Loan"
						onclick="cC.action.value='saveDisp'; submit();" />
					<br /><input type="button"
						class="qutBtn"
						value="Discard Changes"
						onclick="cC.action.value='nothing'; submit();"/>
				</form>
				<cfabort>
			</cfif>
		</cfif>
		<cfquery name="deleLoanItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			DELETE FROM loan_item where collection_object_id = #partID#
			and transaction_id = #transaction_id#
		</cfquery>
		<cflocation url="a_loanItemReview.cfm?transaction_id=#transaction_id#">
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------->
<cfif action is "killSS">
	<cfoutput>
		<cftransaction>
			<cfquery name="deleLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				DELETE FROM loan_item WHERE collection_object_id = #partID#
				and transaction_id=#transaction_id#
			</cfquery>
			<cfquery name="delePart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				DELETE FROM specimen_part WHERE collection_object_id = #partID#
			</cfquery>
			<cfquery name="delePartCollObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				DELETE FROM coll_object WHERE collection_object_id = #partID#
			</cfquery>
			<cfquery name="delePartRemark" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				DELETE FROM coll_object_remark WHERE collection_object_id = #partID#
			</cfquery>
			<cfquery name="getContID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select container_id from coll_obj_cont_hist where
				collection_object_id = #partID#
			</cfquery>

			<cfquery name="deleCollCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				DELETE FROM coll_obj_cont_hist WHERE collection_object_id = #partID#
			</cfquery>
			<cfquery name="deleCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				DELETE FROM container_history WHERE container_id = #getContID.container_id#
			</cfquery>
			<cfquery name="deleCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				DELETE FROM container WHERE container_id = #getContID.container_id#
			</cfquery>
		</cftransaction>
		<cflocation url="a_loanItemReview.cfm?transaction_id=#transaction_id#">
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------->
<cfif action is "BulkUpdateDisp">
	<cfoutput>
		<cfquery name="getCollObjId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select collection_object_id FROM loan_item where transaction_id=#transaction_id#
		</cfquery>
		<cfloop query="getCollObjId">
			<cfquery name="upDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			UPDATE coll_object SET coll_obj_disposition = '#coll_obj_disposition#'
			where collection_object_id = #collection_object_id#
			<cfif len(currentcoll_obj_disposition) gt 0>
				and coll_obj_disposition = '#currentcoll_obj_disposition#'
			</cfif>
			</cfquery>
		</cfloop>
	<cflocation url="a_loanItemReview.cfm?transaction_id=#transaction_id#">
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------->
<cfif action is "saveDisp">
	<cfoutput>
		<cftransaction>
			<cfquery name="upDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				UPDATE coll_object SET coll_obj_disposition = '#coll_obj_disposition#'
				where collection_object_id = #partID#
			</cfquery>
			<cfquery name="upItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				UPDATE loan_item SET
					 transaction_id=#transaction_id#
					<cfif len(#item_instructions#) gt 0>
						,item_instructions = '#item_instructions#'
					<cfelse>
						,item_instructions = null
					</cfif>
					<cfif len(#loan_item_remarks#) gt 0>
						,loan_item_remarks = '#loan_item_remarks#'
					<cfelse>
						,loan_item_remarks = null
					</cfif>
				WHERE
					collection_object_id = #partID# AND
					transaction_id=#transaction_id#
			</cfquery>
		</cftransaction>
		<cfif isdefined("spRedirAction") and len(spRedirAction) gt 0>
			<cfset action=spRedirAction>
		<cfelse>
			<cfset action="nothing">
		</cfif>
		<cflocation url="a_loanItemReview.cfm?transaction_id=#transaction_id#&item_instructions=#item_instructions#&partID=#partID#&loan_item_remarks=#loan_item_remarks#&action=#action#">
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------->
<cfif action is "nothing_old">
	<cfquery name="getPartLoanRequests" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			guid_prefix || ':' || cat_num guid,
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
			to_char(pbc.PARENT_INSTALL_DATE,'YYYY-MM-DD"T"HH24:MI:SS') partLastScanDate
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
			container partc,
			container pbc
		WHERE
			loan_item.collection_object_id = specimen_part.collection_object_id AND
			loan.transaction_id = loan_item.transaction_id AND
			specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
			specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id (+) and
			coll_obj_cont_hist.container_id=partc.container_id (+) and
			partc.parent_container_id=pbc.container_id (+) and
			specimen_part.collection_object_id = coll_object.collection_object_id AND
			coll_object.collection_object_id = coll_object_encumbrance.collection_object_id (+) and
			coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id (+) AND
			encumbrance.encumbering_agent_id = agent_name.agent_id (+) AND
			cataloged_item.collection_object_id = identification.collection_object_id AND
			identification.accepted_id_fg = 1 AND
			cataloged_item.collection_id=collection.collection_id AND
		  	loan_item.transaction_id = #transaction_id#
		ORDER BY cat_num
	</cfquery>
	<cfquery name="getDataLoanRequests" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			flat.collection_object_id,
			guid,
			concatSingleOtherId(flat.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
			flat.scientific_name,
			flat.encumbrances
		 from
			flat,
			loan,
			loan_item
		WHERE
			loan.transaction_id = loan_item.transaction_id AND
			loan_item.collection_object_id = flat.collection_object_id AND
		  	loan_item.transaction_id = #transaction_id#
	</cfquery>
	<cfquery name="theLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			loan_number,
			guid_prefix collection,
			loan_type
		from
			loan,
			trans,
			collection
		where
			loan.transaction_id=trans.transaction_id and
			trans.collection_id=collection.collection_id and
			trans.transaction_id=#transaction_id#
	</cfquery>
	<cfoutput>
		Review Loan Items for #theLoan.collection# #theLoan.loan_number# (#theLoan.loan_type#)
		<br><a href="a_loanItemReview.cfm?action=nothing&transaction_id=#transaction_id#&Ijustwannadownload=yep">Download (csv)</a> - non-data loans only!
		<br><a href="Loan.cfm?action=editLoan&transaction_id=#transaction_id#">back to Edit Loan</a>
		<cfif getDataLoanRequests.recordcount gt 0>
			<p>
				This loan contains #getDataLoanRequests.recordcount# data loan items.
			</p>
			<form name="dcli" method="post" action="a_loanItemReview.cfm">
				<input type="hidden" name="action" value="deleteCatItemLoanItem">
				<input type="hidden" name="transaction_id" value="#transaction_id#">
				<table border id="t" class="sortable">
					<tr>
						<th>GUID</th>
						<th>#session.CustomOtherIdentifier#</th>
						<th>Scientific Name</th>
						<th>Encumbrances</th>
						<th>remove</th>
					</tr>
					<cfloop query="getDataLoanRequests">
						<tr>
							<td>
								<a href="/guid/#guid#">#guid#</a>
							</td>
							<td>
								#CustomID#&nbsp;
							</td>
							<td>
								<em>#scientific_name#</em>&nbsp;
							</td>
							<td>
								#encumbrances#
							</td>
							<td>
								<input type="checkbox" name="collection_object_id" value="#collection_object_id#">
							</td>
						</tr>
					</cfloop>
				</table>
				<input type="submit" class="delBtn" value="remove checked items">
			</form>
			<p>
				<input type="button" class="delBtn" value="remove ALL items" onclick="removeAllDataLoanItems();">
				<script>
					function removeAllDataLoanItems(){
						var yesno=confirm('Are you sure you want to REMOVE ALL specimens from the data loan?');
						if (yesno==true) {
							document.location='/a_loanItemReview.cfm?action=removeAllDataLoanItems&transaction_id=#transaction_id#';
					 	} else {
						  	return false;
					  	}
					}
				</script>
			</p>
		</cfif>
		<cfif getPartLoanRequests.recordcount gt 0>
			<cfif isdefined("Ijustwannadownload") and Ijustwannadownload is "yep">
				<cfset fileName = "ArctosLoanData_#getPartLoanRequests.loan_number#.csv">
				<cfset ac=getPartLoanRequests.columnlist>
				<cfset header=trim(ac)>
				<cffile action="write" file="#Application.webDirectory#/download/#fileName#" addnewline="yes" output="#header#">
				<cfloop query="getPartLoanRequests">
					<cfset oneLine = "">
					<cfloop list="#ac#" index="c">
						<cfset thisData = evaluate(c)>
						<cfif len(oneLine) is 0>
							<cfset oneLine = '"#thisData#"'>
						<cfelse>
							<cfset oneLine = '#oneLine#,"#thisData#"'>
						</cfif>
					</cfloop>
					<cfset oneLine = trim(oneLine)>
					<cffile action="append" file="#Application.webDirectory#/download/#fileName#" addnewline="yes" output="#oneLine#">
				</cfloop>
				<cflocation url="/download.cfm?file=#fileName#" addtoken="false">
				<a href="/download/#fileName#">Click here if your file does not automatically download.</a>
				<cfabort>
			</cfif>
			<cfquery name="catCnt" dbtype="query">
				select count(distinct(collection_object_id)) c from getPartLoanRequests
			</cfquery>
			<cfquery name="prtItemCnt" dbtype="query">
				select count(distinct(partID)) c from getPartLoanRequests
			</cfquery>
			<br>There are #prtItemCnt.c# non-data loan items from #catCnt.c# specimens in this loan.
			<form name="BulkUpdateDisp" method="post" action="a_loanItemReview.cfm">

				<br>Change disposition to:
				<input type="hidden" name="Action" value="BulkUpdateDisp">
				<input type="hidden" name="transaction_id" value="#transaction_id#" id="transaction_id">
				<select name="coll_obj_disposition" size="1">
					<cfloop query="ctDisp">
						<option value="#coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
					</cfloop>
				</select>
				when disposition is

				<select name="currentcoll_obj_disposition" id="currentcoll_obj_disposition" size="1">
					<option value="">- anything -</option>
					<cfloop query="ctDisp">
						<option value="#coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
					</cfloop>
				</select>

				<input type="submit" value="Update Disposition" class="savBtn">
			</form>
			<p>
				View
				<a href="/findContainer.cfm?loan_trans_id=#transaction_id#">Part Locations</a>
				or <a href="loanFreezerLocn.cfm?transaction_id=#transaction_id#">Print Freezer Locations</a>
			</p>
			<table border id="t" class="sortable">
				<tr>
					<th>GUID</th>
					<th>#session.CustomOtherIdentifier#</th>
					<th>Scientific Name</th>
					<th>Item</th>
					<th>Condition</th>
					<th>Subsample?</th>
					<th>Item Instructions</th>
					<th>Item Remarks</th>
					<th>Disposition</th>
					<th>Encumbrance</th>
					<th>partLastScanDate</th>
					<th>&nbsp;</th>
				</tr>
				<cfset i=1>
				<cfloop query="getPartLoanRequests">
					<tr id="rowNum#partID#">
						<td>
							<a href="/guid/#guid#">#guid#</a>
						</td>
						<td>
							#CustomID#&nbsp;
						</td>
						<td>
							<em>#scientific_name#</em>&nbsp;
						</td>
						<td>
							<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">#part_name#</a>
						</td>
						<td>
							<textarea name="condition#partID#"
								rows="2" cols="20"
								id="condition#partID#"
								onchange="this.className='red';updateCondition('#partID#')">#condition#</textarea>
								<span class="infoLink" onClick="chgCondition('#partID#')">History</span>
						</td>
						<td>
							<cfif len(sampled_from_obj_id) gt 0>
								yes
							<cfelse>
								no
							</cfif>
							<input type="hidden" name="isSubsample#partID#" id="isSubsample#partID#" value="#sampled_from_obj_id#" />
						</td>
						<td valign="top">
							<textarea name="item_instructions#partID#" id="item_instructions#partID#" rows="2" cols="20" onchange="this.className='red';updateInstructions('#partID#')">#Item_Instructions#</textarea>
						</td>
						<td valign="top">
							<textarea name="loan_Item_Remarks#partID#" id="loan_Item_Remarks#partID#" rows="2" cols="20"
							onchange="this.className='red';updateLoanItemRemarks('#partID#')">#loan_Item_Remarks#</textarea>
						</td>
						<td>
							<cfset thisDisp = #coll_obj_disposition#>
							<select name="coll_obj_disposition#partID#"
								id="coll_obj_disposition#partID#"
								 size="1" onchange="this.className='red';updateDispn('#partID#')">
									<cfloop query="ctDisp">
										<option
											<cfif #ctDisp.coll_obj_disposition# is "#thisDisp#"> selected </cfif>
											value="#coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
									</cfloop>
							</select>
						</td>
						<td>
							#Encumbrance# <cfif len(#agent_name#) gt 0> by #agent_name#</cfif>&nbsp;
						</td>
						<td>#partLastScanDate#</td>
						<td>
							<img src="/images/del.gif" class="likeLink" onclick="remPartFromLoan(#partID#);" />
						</td>
					</tr>
					<cfset i=#i#+1>
				</cfloop>
			</table>
		</cfif>
	</cfoutput>
</cfif>
<!------------------------------------------------------>
<cfif action is "deleteCatItemLoanItem">
	<cfquery name="buhBye" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from loan_item where transaction_id=#transaction_id# and
		collection_object_id in (#collection_object_id#)
	</cfquery>
	<cflocation url="a_loanItemReview.cfm?transaction_id=#transaction_id#" addtoken="false">
</cfif>
<!------------------------------------------------------>
<cfif action is "removeAllDataLoanItems">
	<cfquery name="buhBye" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from loan_item where transaction_id=#transaction_id# and
		collection_object_id in (select collection_object_id from cataloged_item)
	</cfquery>
	<cflocation url="a_loanItemReview.cfm?transaction_id=#transaction_id#" addtoken="false">
</cfif>


<cfinclude template="includes/_footer.cfm">