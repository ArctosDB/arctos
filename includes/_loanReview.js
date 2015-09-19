$(document).ready(function () {
	$(".reqdClr:visible").each(function(e){
	    $(this).prop('required',true);
	});
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
}
function deleteDataLoan(tid){
	var yesno=confirm('Are you sure you want to REMOVE ALL specimens from the data loan?');
	if (yesno==true) {
		document.location='/loanItemReview.cfm?action=removeAllDataLoanItems&transaction_id=' + tid;
	} else {
	  	return false;
	}
}