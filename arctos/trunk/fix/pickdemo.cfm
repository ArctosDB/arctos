<cfinclude template="/includes/_header.cfm">
<style>
	.saver{
		border:2px solid red; 
		width:90%; 
		left:5%;
		top:5%;
		position:absolute;
		z-index:2001;
		background-color:white;
		text-align:center;
	}
	.badPickLbl {
		color:red;color:green;
border:1px solid purple;
width:2em;
height:1em;
	}
</style>
<script type='text/javascript' src='/includes/jquery/jquery.js'></script>
<script type='text/javascript' src='/includes/jquery/jquery.field.js'></script>
<script type='text/javascript' src='/includes/jquery/jquery.form.js'></script>
<script>
	jQuery( function($) {
	setInterval(checkRequired,500);
});
	function itsAllDone(vl){
		
	}
	function getLabelForId(id) {
 		var label, labels = document.getElementsByTagName('label');
 		for (var i = 0; (label = labels[i]); i++) {
	  		if (label.htmlFor == id) {
	     		return label;
	   		}
	 	}
	 		return false;
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
				

				//var lbl=getLabelForId(thisElem).className='badPickLbl';

			} else {
				//var lbl=getLabelForId(thisElem).className='';
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
<cfif action is "nothing">
<cfoutput>
<form method="post" name="test" id="test" action="pickdemo.cfm">
	<input type="hidden" name="action" value="#action#">
	<input type="hidden" name="save" value="true">
	<label for="a">This is the text field</label>
	
	<input type="text" name="a" id="a"  onchange="getAgent('a_id','a','test',this.value);" class="reqdClr">
	<label for="b">This is the ID field, and is normally hidden</label>
	<input type="text" name="a_id" id="a_id" class="reqdClr">
	
	<label for="afsdafsd" class="badPickLbl">Demo Thingee</label>
	<input type="text" name="afsdafsd" id="afsdafsd">
	
	
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