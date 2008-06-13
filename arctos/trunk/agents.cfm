<cfif not isdefined("agent_id")>
	<cfset agent_id=-1>
</cfif>
<cfinclude template="/includes/_header.cfm">
<cfset title='Manage Agents'>
<cfoutput>
<script>

function autoIframe(frameId){
try{
frame = document.getElementById(frameId);
innerDoc = (frame.contentDocument) ? frame.contentDocument : frame.contentWindow.document;
objToResize = (frame.style) ? frame.style : frame;
objToResize.height = innerDoc.body.scrollHeight + 10;
}
catch(err){
window.status = err.message;
}
}









</script>
<table>
	<tr>
		<td>
			<iframe src="/AgentSearch.cfm" id="_search" name="_search"
				onload="if (window.parent && window.parent.autoIframe) {window.parent.autoIframe('_search');}"></iframe>
		</td>
		<td rowspan="2">
			<iframe src="/editAllAgent.cfm" name="_person" id="_person"
				onload="if (window.parent && window.parent.autoIframe) {window.parent.autoIframe('_person');}"></iframe>
		</td>
	</tr>
	<tr>
		<td>
			<iframe src="/AgentGrid.cfm" name="_pick" id="_pick"
				onload="if (window.parent && window.parent.autoIframe) {window.parent.autoIframe('_pick');}"></iframe>
		</td>
	</tr>
</table>
<span onclick="autofitIframe('_search')">_search</span>
<span onclick="autofitIframe('_person')">_person</span>
<span onclick="autofitIframe('_pick')">_pick</span>
<span onclick="autofitIframe('resizeCaller')">resizeCaller</span>

</cfoutput>
