setInterval(checkRequired,500);
function formNotReady() {
	alert('formNotReady');
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
function checkRequired(){
	/*
		REQUIREMENTS:
			form submit button has a title (this is the default value)
			form submit button has an ID
			form has an ID
			required hidden fields have the same ID as their visible field, plus "_id"
				so, agent + agent_id are treated as a pair (the visual clues go with agent)
			Required elements (not of type _id) have a label that refers to their ID
		Usage:
			Meet the above requirements, and
			<script type='text/javascript' src='/includes/checkForm.js'></script>
	*/
	//try {
		elementsForms = document.getElementsByTagName("form");
		for (var f = 0; f < elementsForms.length; f++)  {  
			var fid = document.forms[f].id;
			var theForm=document.getElementById(fid);
			var badElems=new Array();
			for(e=0; e<theForm.elements.length; e++){
				if(document.getElementById(theForm.elements[e].id)){
					try{
						var lbl=getLabelForId(theForm.elements[e].id).className='';
					}
						catch(errr){
					}
					var theElem=document.getElementById(theForm.elements[e].id);
					if(theForm.elements[e].type=='submit'){
						var sbmBtn=theElem;
					}
					if (theElem.className.indexOf('reqdClr')>-1 && theElem.value==''){
						badElems.push(theElem.id);
					}
				}
			}
			if (badElems.length>0){
				theForm.setAttribute('onsubmit',"return formNotReady()");
				sbmBtn.value="Not ready...";	
			} else {
				sbmBtn.removeAttribute('onsubmit');
				sbmBtn.value=sbmBtn.title;	
			}
			for (i=0;i<badElems.length;i++){
				var theId=badElems[i];
				var isId=theId.substr(theId.length-3,3);
				if (isId=='_id') {
					var lblElem=theId.substr(0,theId.length-3);
				} else {
					var lblElem=theId;
				}
				getLabelForId(lblElem).className='badPickLbl';
			}			
		}
	// } catch(err)
  	//{
  	//
  //	}
}