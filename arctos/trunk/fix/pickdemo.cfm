<cfinclude template="/includes/_header.cfm">
<script type='text/javascript' src='/includes/checkForm.js'></script>
<!---
<script>
	jQuery( function($) {
	setInterval(checkRequired,500);
});
	function itsAllDone(vl){
		
	}
	
	function checkThisForm(){
		itsAllDone('a','b');
		checkNames('a','b');
		console.log(c);
	}
	function checkNames(v_f,i_f){
		var a=document.getElementById(v_f);
		var b=document.getElementById(i_f);
		if(a.value.length>0 && b.value.length==0){
			DWREngine._execute(_cfscriptLocation, null, 'agent_lookup', a.value,v_f,i_f, success_checkNames);
		} else {
			return 'gotboth';
			alert('submitting now....');
			//document.getElementById('test').submit();
		}
	}
	function success_checkNames(result){
		console.log('back');
		if (result>0) {
			document.getElementById('b').value=result;
			return 'spiffy';
			alert('submitting now....');
		} else {
			document.getElementById('a').className='red';
			return 'unspiffy';
			return false;
		}
	}
	
	function checkRequired(){	
	// loop over all the forms...
	$('form').each(function(){
		var fid=this.id;
		var hasIssues=0;
		var allFormObjs = $('#' + fid).formSerialize();
		var AFA=allFormObjs.split('&');
		for (i=0;i<AFA.length;i++){
			var fp=AFA[i].split('=');
			var ffName=fp[0];
			var ffVal=fp[1];
			var ffClass=$("#" + ffName).attr('class');
			var isId=ffName.substr(ffName.length-3,3);
			if (isId=='_id') {
				var thisElem=ffName.substr(0,ffName.length-3);
			} else {
				var thisElem=ffName;
			}
			if (ffClass=='reqdClr' && ffVal==''){
				hasIssues+=1;
				

				var lbl=getLabelForId(thisElem).className='badPickLbl';

			} else {
				var lbl=getLabelForId(thisElem).className='';
			}
		}
		// get the form submit
		// REQUIREMENT: form submit button has id of formID + _submit
		// REQUIREMENT: form submit has a title
		// REQUIREMENT: required hidden fields have the same ID as their visible field, plus "_id"
		// so, agent + agent_id are treated as a pair (the visual clues go with agent)
		var sbmBtnStr=fid + "_submit";
		var sbmBtn=document.getElementById(sbmBtnStr);
		var v=sbmBtn.value;
		if (hasIssues > 0) {
			// form is NOT ready for submission
			document.getElementById(fid).setAttribute('onsubmit',"return false");
			sbmBtn.value="Not ready...";		
		} else {
			document.getElementById(fid).removeAttribute('onsubmit');
			sbmBtn.value=sbmBtn.title;	
		}
	});
}
	
</script>
---->
<cfif action is "nothing">
<cfoutput>
	
	
	<span onclick="checkRequired()">checkRequired</span>
<form method="post" name="test" id="test" action="pickdemo.cfm">
	<input type="hidden" name="action" value="#action#">
	<input type="hidden" name="save" value="true">
	
	<label for="a">This is the text field</label>
	<input type="text" name="a" id="a"  onchange="getAgent('a_id','a','test',this.value);" class="reqdClr">
	<input type="text" name="a_id" id="a_id" class="reqdClr">
	
	<label for="a1">This is the text field</label>
	
	<input type="text" name="a1" id="a1"  class="reqdClr">


	<label for="a3">This is the text field</label>
	<input type="text" name="a3" id="a3"  onchange="getAgent('a3_id','a3','test',this.value);" class="reqdClr">
	<input type="text" name="a3_id" id="a3_id" class="reqdClr red">


	
	<br><input type="submit" id="test_submit" title="submit" value="submit">
</form>

<cfif isdefined("save") and save is true>
<script>
	var bgDiv=document.createElement('div');
	bgDiv.id='bgDiv';
	bgDiv.className='bgDiv';
	document.body.appendChild(bgDiv);
</script>
	<cfquery datasource="uam_god" name="data">
		SELECT agent_name,agent_id
		FROM agent_name
		WHERE upper(agent_name) LIKE ('#ucase(a)#%')
		ORDER BY agent_name
	</cfquery>
	<div class="saver">
	<cfif data.recordcount is 1>
		saving....
	<cfelse>
		pick thingee.....
		<cfdump var=#form#>
	</cfif>
	</div>
</cfif>
</cfoutput>
</cfif>