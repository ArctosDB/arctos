function tog_AgentRankDetail(o){
	if(o==1){
		document.getElementById('agentRankDetails').style.display='block';
		jQuery('#t_agentRankDetails').text('Hide Details').removeAttr('onclick').bind("click", function() {
			tog_AgentRankDetail(0);
		});
	} else {
		document.getElementById('agentRankDetails').style.display='none';
		jQuery('#t_agentRankDetails').text('Show Details').removeAttr('onclick').bind("click", function() {
			tog_AgentRankDetail(1);
		}); 
	}
}
function saveAgentRank(){
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "saveAgentRank",
			agent_id : jQuery('#agent_id').val(),
			agent_rank : jQuery('#agent_rank').val(),
			remark : jQuery('#remark').val(),
			transaction_type : jQuery('#transaction_type').val(),
			returnformat : "json",
			queryformat : 'column'
		},
		function (d) {
			if(d.length>0 && d.substring(0,4)=='fail'){
				alert(d);
			} else {
				var ih = 'Thank you for adding an agent rank.';
				ih+='<p><span class="likeLink" onclick="removePick();rankAgent(' + d + ')">Refresh</span></p>';
				ih+='<p><span class="likeLink" onclick="removePick();">Done</span></p>';				
				document.getElementById('pickDiv').innerHTML=ih;
			}
		}
	); 		
}
function rankAgent(agent_id) {
	addBGDiv('removePick()');
	var theDiv = document.createElement('div');
	theDiv.id = 'pickDiv';
	theDiv.className = 'pickDiv';
	theDiv.innerHTML='<br>Loading...';
	document.body.appendChild(theDiv);
	var ptl="/includes/forms/agentrank.cfm";			
	jQuery.get(ptl,{agent_id: agent_id},function(data){
		document.getElementById('pickDiv').innerHTML=data;
		viewport.init("#pickDiv");
	});
}
function pickThis (fld,idfld,display,aid) {
	document.getElementById(fld).value=display;
	document.getElementById(idfld).value=aid;
	document.getElementById(fld).className='goodPick';
	removePick();
}
function removePick() {
	if(document.getElementById('pickDiv')){
		jQuery('#pickDiv').remove();
	}
	removeBgDiv();
}
function addBGDiv(f){
	var bgDiv = document.createElement('div');
	bgDiv.id = 'bgDiv';
	bgDiv.className = 'bgDiv';
	if(f==null || f.length==0){
		f="removeBgDiv()";
	}
	bgDiv.setAttribute('onclick',f);
	document.body.appendChild(bgDiv);
	viewport.init("#bgDiv");
}
function removeBgDiv () {
	if(document.getElementById('bgDiv')){
		jQuery('#bgDiv').remove();
	}
}
function get_AgentName(name,fld,idfld){
	addBGDiv('removePick()');
	var theDiv = document.createElement('div');
	theDiv.id = 'pickDiv';
	theDiv.className = 'pickDiv';
	theDiv.innerHTML='<br>Loading...';
	document.body.appendChild(theDiv);
	var ptl="/picks/getAgentName.cfm";			
	jQuery.get(ptl,{agentname: name, fld: fld, idfld: idfld},function(data){
		document.getElementById('pickDiv').innerHTML=data;
		viewport.init("#pickDiv");
	});
}

function addLink (n) {
	var lid = jQuery('#linkTab tr:last').attr("id");
	console.log(lid);
	var lastID=lid.replace('linkRow','');
	console.log(lastID);
	var thisID=parseInt(lastID) + 1;
	console.log(thisID);
	var newRow='<tr id="linkRow' + thisID + '">';
	newRow+='<td>';
	newRow+='<input type="text"  size="60" name="link' + thisID + '" id="link' + thisID + '">';
	newRow+='</td>';
	newRow+='<td>';
	newRow+='<input type="text"  size="10" name="description' + thisID + '" id="description' + thisID + '">';
	newRow+='</td>';
	newRow+='</tr>';		
	jQuery('#linkTab tr:last').after(newRow);
	document.getElementById('numberLinks').value=thisID;
}

function addAgent (n) {
	var lid = jQuery('#authTab tr:last').attr("id");
	var lastID=lid.replace('authortr','');
	var thisID=parseInt(lastID) + 1;
	var newRow='<tr id="authortr' + thisID + '">';
	newRow+='<td>';
	newRow+='<select name="author_role_' + thisID + '" id="author_role_' + thisID + '1">';
	newRow+='<option value="author">author</option>';
	newRow+='<option value="editor">editor</option>';
	newRow+='</select>';
	newRow+='</td>';
	newRow+='<td>';
	newRow+='<input type="hidden" name="author_id_' + thisID + '" id="author_id_' + thisID + '">';
	newRow+='<input type="text" name="author_name_' + thisID + '" id="author_name_' + thisID + '" class="reqdClr"  size="50" ';
	newRow+='onchange="get_AgentName(this.value,this.id,\'author_id_' + thisID + '\');"';
	newRow+='onKeyPress="return noenter(event);">';
	newRow+='</td>';
	newRow+='</tr>';		
	jQuery('#authTab tr:last').after(newRow);
	document.getElementById('numberAuthors').value=thisID;
}
function removeAgent() {
	var lid = jQuery('#authTab tr:last').attr("id");
	var lastID=lid.replace('authortr','');
	var thisID=parseInt(lastID) - 1;
	document.getElementById('numberAuthors').value=thisID;
	if(thisID>=1){
		jQuery('#authTab tr:last').remove();
	} else {
		alert('You must have at least one author');
	}
}
function removeLastAttribute() {
	var lid = jQuery('#attTab tr:last').attr("id");
	if (lid.length==0) {
		alert('nothing to remove');
		return false;
	}
	var lastID=lid.replace('attRow','');
	var thisID=parseInt(lastID) - 1;
	document.getElementById('numberAttributes').value=thisID;
	jQuery('#attTab tr:last').remove();
}
function addAttribute(v){
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "getPubAttributes",
			attribute : v,
			returnformat : "json",
			queryformat : 'column'
		},
		function (d) {
			var lid=jQuery('#attTab tr:last').attr("id");
			if(lid.length==0){
				lid='attRow0';
			}
			var lastID=lid.replace('attRow','');
			var thisID=parseInt(lastID) + 1;
			var newRow='<tr id="attRow' + thisID + '"><td>' + v;
			newRow+='<input type="hidden" name="attribute_type' + thisID + '"';
			newRow+=' id="attribute_type' + thisID + '" class="reqdClr" value="' + v + '"></td><td>';
			if(d.length>0 && d.substring(0,4)=='fail'){
				alert(d);
				return false;
			} else if(d=='nocontrol'){
				newRow+='<input type="text" name="attribute' + thisID + '" id="attribute' + thisID + '" size="50" class="reqdClr">';
			} else {
				newRow+='<select name="attribute' + thisID + '" id="attribute' + thisID + '" class="reqdClr">';
				for (i=0; i<d.ROWCOUNT; ++i) {
					newRow+='<option value="' + d.DATA.v[i] + '">'+ d.DATA.v[i] +'</option>';
				}
				newRow+='</select>';
			}
			newRow+="</td></tr>";
			jQuery('#attTab tr:last').after(newRow);
			document.getElementById('numberAttributes').value=thisID;
		}
	); 		
}
function setDefaultPub(t){
	if(t=='journal article'){
    	addAttribute('journal name');
    	// crude but try to get this stuff in order if we can...
    	setTimeout( "addAttribute('begin page')", 1000);
    	setTimeout( "addAttribute('end page');", 1500);
    	setTimeout( "addAttribute('volume');", 2000);
    	setTimeout( "addAttribute('issue');", 2500);			
	} else if (t=='book'){
		addAttribute('volume');
    	setTimeout( "addAttribute('page total')", 1000);
    	setTimeout( "addAttribute('publisher')", 1500);
	} else if (t=='book section'){
    	addAttribute('publisher');
    	setTimeout( "addAttribute('volume')", 1000);
    	setTimeout( "addAttribute('page total')", 1500);
    	setTimeout( "addAttribute('section type')", 2000);
    	setTimeout( "addAttribute('section order')", 2500);
    	setTimeout( "addAttribute('begin page')", 3000);
    	setTimeout( "addAttribute('end page')", 3500);
	}
}
function deleteAgent(r){
	jQuery('#author_id_' + r).val("-1");	
	jQuery('#authortr' + r + ' td:nth-child(1)').addClass('red').text(jQuery('#author_role_' + r).val());
	jQuery('#authortr' + r + ' td:nth-child(2)').addClass('red').text(jQuery('#author_name_' + r).val());
	jQuery('#authortr' + r + ' td:nth-child(3)').addClass('red').text('deleted');						
}
function deletePubAtt(r){
	var newElem='<input type="hidden" name="attribute' + r + '" id="attribute' + r + '" value="deleted">';
	jQuery('#attRow' + r + ' td:nth-child(1)').addClass('red').text(jQuery('#attribute_type' + r).val());
	jQuery('#attRow' + r + ' td:nth-child(2)').addClass('red').text(jQuery('#attribute' + r).val()).append(newElem);
	jQuery('#attRow' + r + ' td:nth-child(3)').addClass('red').text('deleted');
}
function deleteLink(r){
	var newElem='<input type="hidden" name="link' + r + '" id="link' + r + '" value="deleted">';
	jQuery('#linkRow' + r + ' td:nth-child(1)').addClass('red').text('deleted');
	jQuery('#linkRow' + r + ' td:nth-child(1)').append(newElem);
	jQuery('#linkRow' + r + ' td:nth-child(2)').addClass('red').text('');
	//jQuery('#attRow' + r + ' td:nth-child(3)').addClass('red').text('deleted');
}