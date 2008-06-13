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






/***********************************************
* IFrame SSI script II- © Dynamic Drive DHTML code library (http://www.dynamicdrive.com)
* Visit DynamicDrive.com for hundreds of original DHTML scripts
* This notice must stay intact for legal use
***********************************************/

//Input the IDs of the IFRAMES you wish to dynamically resize to match its content height:
//Separate each ID with a comma. Examples: ["myframe1", "myframe2"] or ["myframe"] or [] for none:
var iframeids=["_search","_person","_pick"]

//Should script hide iframe from browsers that don't support this script (non IE5+/NS6+ browsers. Recommended):
var iframehide="yes"

var getFFVersion=navigator.userAgent.substring(navigator.userAgent.indexOf("Firefox")).split("/")[1]
var FFextraHeight=parseFloat(getFFVersion)>=0.1? 60 : 0 //extra height in px to add to iframe in FireFox 1.0+ browsers

function resizeCaller() {
	var dyniframe=new Array()
	for (i=0; i<iframeids.length; i++){
		if (document.getElementById)
		resizeIframe(iframeids[i])
		//reveal iframe for lower end browsers? (see var above):
		if ((document.all || document.getElementById) && iframehide=="no"){
			var tempobj=document.all? document.all[iframeids[i]] : document.getElementById(iframeids[i])
			tempobj.style.display="block"
		}
	}
}

function resizeIframe(frameid){
	var currentfr=document.getElementById(frameid)
	if (currentfr && !window.opera){
		currentfr.style.display="block"
		if (currentfr.contentDocument && currentfr.contentDocument.body.offsetHeight) {//ns6 syntax
			currentfr.height = currentfr.contentDocument.body.offsetHeight+FFextraHeight;
			currentfr.width = currentfr.contentDocument.body.offsetWidth+FFextraHeight;
		} else if (currentfr.Document && currentfr.Document.body.scrollHeight) {//ie5+ syntax
			currentfr.height = currentfr.Document.body.scrollHeight;
			currentfr.width = currentfr.Document.body.scrollWidth;
			if (currentfr.addEventListener) {
				currentfr.addEventListener("load", readjustIframe, false)
			} else if (currentfr.attachEvent){
				currentfr.detachEvent("onload", readjustIframe) // Bug fix line
				currentfr.attachEvent("onload", readjustIframe)
			}
		}
	}
}
function readjustIframe(loadevt) {
var crossevt=(window.event)? event : loadevt
var iframeroot=(crossevt.currentTarget)? crossevt.currentTarget : crossevt.srcElement
if (iframeroot)
resizeIframe(iframeroot.id);
}

function loadintoIframe(iframeid, url){
if (document.getElementById)
document.getElementById(iframeid).src=url
}

if (window.addEventListener)
window.addEventListener("load", resizeCaller, false)
else if (window.attachEvent)
window.attachEvent("onload", resizeCaller)
else
window.onload=resizeCaller


</script>
<table>
	<tr>
		<td>
			<iframe src="/AgentSearch.cfm" id="_search" name="_search"></iframe>
		</td>
		<td rowspan="2">
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
<span onclick="autofitIframe('resizeCaller')">resizeCaller</span>

</cfoutput>
