function thisOne(ret_val_id,ret_id_id,id,str) {
	document.getElementById(ret_val_id).value=str;
	document.getElementById(ret_id_id).value=id;
	document.getElementById(ret_val_id).className='goodPick';
	var p=document.getElementById('ppDiv');
	var b=document.getElementById('bgDiv');
	document.body.removeChild(p);
	document.body.removeChild(b);	
}
function getPart(id,disp,params) {
	var bgDiv=document.createElement('div');
	bgDiv.id='bgDiv';
	bgDiv.className='bgDiv';
	document.body.appendChild(bgDiv);
	var theDiv = document.createElement('div');
	theDiv.id = 'ppDiv';
	theDiv.className = 'pickBox';
	theDiv.innerHTML='Loading....';
	theDiv.src = "";
	document.body.appendChild(theDiv);		
	var guts = "/picks/partPick.cfm?ret_val_id=" + disp + '&ret_id_id=' + id + "&" + params;
	ahah(guts,'ppDiv');				
}
function locationSubmit(fid){
	theForm=document.getElementById(fid);
	var out = new Array();
	formInputs = theForm.getElementsByTagName("select");
	for (var i = 0; i < formInputs.length; i++) {
		if (formInputs.item(i).value.length > 0) {
			out.push( formInputs.item(i).name + '=' + formInputs.item(i).value );
		}
	}
	formInputs = theForm.getElementsByTagName("input");
	for (var i = 0; i < formInputs.length; i++) {
		if (formInputs.item(i).value.length > 0 && formInputs.item(i).name.length>0) {
			out.push( formInputs.item(i).name + '=' + formInputs.item(i).value );
		}
	}
	formInputs = theForm.getElementsByTagName("textarea");
	for (var i = 0; i < formInputs.length; i++) {
		if (formInputs.item(i).value.length > 0) {
			out.push( formInputs.item(i).name + '=' + formInputs.item(i).value );
		}
	}
	var l=out.join("&");
	var u=theForm.getAttribute('action') + '?' + l;
	ahah(u,'thisWholePage');
}
	
function ahah(url, target, delay) {
	var req;
	document.getElementById(target).innerHTML = 'waiting...';
  if (window.XMLHttpRequest) {
    req = new XMLHttpRequest();
  } else if (window.ActiveXObject) {
    req = new ActiveXObject("Microsoft.XMLHTTP");
  }
  if (req != undefined) {
    req.onreadystatechange = function() {ahahDone(req, url, target, delay);};
    req.open("GET", url, true);
    req.send("");
  }
}  

function ahahDone(req, url, target, delay) {
  if (req.readyState == 4) { // only if req is "loaded"
    if (req.status == 200) { // only if "OK"
      document.getElementById(target).innerHTML = req.responseText;
    } else {
      document.getElementById(target).innerHTML="ahah error:\n"+req.statusText;
    }
    if (delay != undefined) {
       setTimeout("ahah(url,target,delay)", delay); // resubmit after delay
	    //server should ALSO delay before responding
    }
  }
}
	