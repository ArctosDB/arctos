setInterval(checkRequired,500);
function getLabelForId(id) {
 	var label, labels = document.getElementsByTagName('label');
 	for (var i = 0; (label = labels[i]); i++) {
		if (label.htmlFor == id) {
	   		return label;
		}
	}
	return false;
} 
function checkRequired(){
	/*
		REQUIREMENTS:
			form submit button has a title
			form submit button has an ID
			form has an ID
			required hidden fields have the same ID as their visible field, plus "_id"
				so, agent + agent_id are treated as a pair (the visual clues go with agent)
				
		Usage:
		
		<script type='text/javascript' src='/includes/checkForm.js'></script>
	*/
	try {
		elementsForms = document.getElementsByTagName("form");  
		for (var f = 0; f < elementsForms.length; f++)  {  
			var fid = document.forms[f].id;
			var theForm=document.getElementById(fid);
			var hasIssues=0;
			for(e=0; e<theForm.elements.length; e++){
				if(document.getElementById(theForm.elements[e].id)){
					var theElem=document.getElementById(theForm.elements[e].id);
					if(theForm.elements[e].type=='submit'){
						var sbmBtn=theElem;
					}
					var c=theElem.className;
					if (c.indexOf('reqdClr') >-1){
						theId=theElem.id;
						var isId=theId.substr(theId.length-3,3);
						if (isId=='_id') {
							var lblElem=theId.substr(0,theId.length-3);
						} else {
							var lblElem=theId;
						}
						var thisVal=theElem.value;
						if (thisVal==''){
							hasIssues+=1;
							getLabelForId(lblElem).className='badPickLbl';
						} else {
							var lbl=getLabelForId(lblElem).className='';
						}
					}
				}
			}
			if (hasIssues > 0) {
				sbmBtn.setAttribute('onsubmit',"return false");
				sbmBtn.value="Not ready...";		
			} else {
				sbmBtn.removeAttribute('onsubmit');
				sbmBtn.value=sbmBtn.title;	
			}
		}
	 } catch(err)
  	{
  	//
  	}
}