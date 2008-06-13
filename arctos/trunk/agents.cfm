<cfif not isdefined("agent_id")>
	<cfset agent_id=-1>
</cfif>
<cfinclude template="/includes/_header.cfm">
<cfset title='Manage Agents'>
<cfoutput>
<script>
	function dyniframesize() {
	
	var iframeids=["theFrame"]
	var iframehide="yes"
	var getFFVersion=navigator.userAgent.substring(navigator.userAgent.indexOf("Firefox")).split("/")[1]
	var FFextraHeight=parseFloat(getFFVersion)>=0.1? 18 : 0 //extra height in px to add to iframe in FireFox 1.0+ browsers
	FFextraHeight = 60; // DLM - sometimes it doesn't fit
	
	var dyniframe=new Array()
	for (i=0; i<iframeids.length; i++){
	    if (document.getElementById){ //begin resizing iframe procedure
	        dyniframe[dyniframe.length] = document.getElementById(iframeids[i]);
	        if (dyniframe[i] && !window.opera){
	            dyniframe[i].style.display="block"
	            if (dyniframe[i].contentDocument && dyniframe[i].contentDocument.body.offsetHeight) //ns6 syntax
	                dyniframe[i].height = dyniframe[i].contentDocument.body.offsetHeight+FFextraHeight;
	            else if (dyniframe[i].Document && dyniframe[i].Document.body.scrollHeight) //ie5+ syntax
	                dyniframe[i].height = dyniframe[i].Document.body.scrollHeight;
	            }
	        }
	        if ((document.all || document.getElementById) && iframehide=="no"){
	            var tempobj=document.all? document.all[iframeids[i]] : document.getElementById(iframeids[i])
	            tempobj.style.display="block"
	        }
	    }
	}
	

function autofitIframe(id){
	if (!window.opera && !document.mimeType && document.all && document.getElementById){
		parent.document.getElementById(id).style.height=this.document.body.offsetHeight+"px";
	} else if(document.getElementById) {
		parent.document.getElementById(id).style.height=this.document.body.scrollHeight+"px"
	}
} 
</script>
<table>
	<tr>
		<td>
			<iframe src="/AgentSearch.cfm" id="_search" name="_search"></iframe>
		</td>
		<td colspan="2">
			<iframe src="/editAllAgent.cfm" name="_person" id="_person"></iframe>
		</td>
	</tr>
	<tr>
		<td>
			<iframe src="/AgentGrid.cfm" name="_pick" id="_pick"></iframe>
		</td>
	</tr>
</table>
<span onclick="autofitIframe('_search')">_search</span>
<span onclick="autofitIframe('_person')">_person</span>
<span onclick="autofitIframe('_pick')">_pick</span>
</cfoutput>
