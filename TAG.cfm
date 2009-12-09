<cfinclude template = "/includes/_header.cfm">
<cfif action is "nothing">
<script language="JavaScript" src="/includes/jquery/jquery.imgareaselect.pack.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="/includes/jquery/css/imgareaselect-default.css">
<link rel="stylesheet" type="text/css" href="/includes/jquery/css/ui-lightness/jquery-ui-1.7.2.custom.css">
<script language="JavaScript" src="/includes/jquery/jquery-ui-1.7.2.custom.min.js" type="text/javascript"></script>
<script language="JavaScript" src="/includes/jquery/scrollTo.js" type="text/javascript"></script>

<script language="JavaScript" src="/includes/TAG.js" type="text/javascript"></script>
<style>
.highlight {
	border:2px solid yellow;
	z-index:300;
}
.refPane_highlight {
	border:3px solid yellow;
}
</style>
<cfoutput>
	<cfset title="TAG Images">
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from media where media_id=#media_id#
	</cfquery>
	<cfif (c.media_type is not "image" and c.media_type is not "multi-page document") or c.mime_type does not contain 'image/'>
		FAIL@images only.
		<cfabort>
	</cfif>
	<script>
		$(document).ready(function () {		
			loadTAG(#c.media_id#,'#c.media_uri#');
		});
	</script>
	<!---
	
	<div id="navDiv">
		<div id="info"></div>
		<form name="f">
			<label for="RefType_new">Create TAG type....</label>
			<div id="newRefCell" class="newRec">
			<select id="RefType_new" name="RefType_new" onchange="pickRefType(this.id,this.value);">
				<option value=""></option>
				<option value="comment">Comment Only</option>
				<option value="cataloged_item">Cataloged Item</option>
				<option value="collecting_event">Collecting Event</option>
				<option value="locality">Locality</option>
				<option value="agent">Agent</option>
			</select>
			<span id="newRefHidden" style="display:none">
				<label for="RefStr_new">Reference</label>
				<input type="text" id="RefStr_new" name="RefStr_new" size="50">
				<input type="hidden" id="RefId_new" name="RefId_new">
				<label for="Remark_new">Remark</label>
				<input type="text" id="Remark_new" name="Remark_new" size="50">
				<input type="hidden" id="t_new">
				<input type="hidden" id="l_new">
				<input type="hidden" id="h_new">
				<input type="hidden" id="w_new">
				<br>
				<input type="button" id="newRefBtn" value="create TAG">
			</span>
			</div>
		</form>
		<hr>
		<form name="ef" method="post" action="TAG.cfm">
		<input type="hidden" name="imgH" id="imgH">
		<input type="hidden" name="imgW" id="imgW">
		<div id="editRefDiv"></div>
		<input type="hidden" id="media_id" name="media_id" value="#c.media_id#">
		<input type="hidden" name="action" value="fd">
		</form>
	</div>
	---->
</cfoutput>
<div style="clear:both;">&nbsp;</div>
<cfinclude template="/includes/_footer.cfm">
</cfif>
<cfif action is "fd">
	<cfoutput>
		<cfset tagids="">
		<cfloop list="#form.fieldnames#" index="e">
			<cfif e contains "REFTYPE">
				<cfset tid=replace(e,"REFTYPE_","")>
				<cfset tagids=listappend(tagids,tid)>
			</cfif>
		</cfloop>
		<cftransaction>
			<cfloop list="#tagids#" index="i">
				<cfset TAG_ID =  #i#>
				<cfset REMARK = evaluate("REMARK_" & i)>
				<cfset REFH = evaluate("H_" & i)>
				<cfset REFTOP = evaluate("T_" & i)>
				<cfset REFLEFT = evaluate("L_" & i)>
				<cfset REFW = evaluate("W_" & i)>
				<cfset reftype = evaluate("REFTYPE_" & i)>
				<cfset refid = evaluate("REFID_" & i)>
				<cfif REFH lt 0 or
					REFTOP lt 0 or
					REFLEFT lt 0 or
					REFW lt 0 or
					(REFTOP + REFH) gt imgH or
					(REFLEFT + REFW gt imgW)>
					bad juju. 
					<cfdump var="#form#">
					<cfabort>
				</cfif>
				<cfset s="update tag set
					REMARK='#escapeQuotes(REMARK)#',
					REFH=#REFH#,
					REFTOP=#REFTOP#,
					REFLEFT=#REFLEFT#,
					REFW=#REFW#,
					imgH=#imgH#,
					imgW=#imgW#">
				<cfif reftype is "collecting_event">
					<cfset s=s & ",COLLECTION_OBJECT_ID=null
					,COLLECTING_EVENT_ID=#refid#">
				<cfelseif reftype is "cataloged_item">
					<cfset s=s & ",COLLECTING_EVENT_ID=null
					,COLLECTION_OBJECT_ID=#refid#">
				<cfelse>
					<cfset s=s & ",COLLECTION_OBJECT_ID=null
					,COLLECTING_EVENT_ID=null">
				</cfif>
				<cfset s=s & " where tag_id=#tag_id#">
				<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					#preservesinglequotes(s)#
				</cfquery>
			</cfloop>
		</cftransaction>
		<cflocation url="TAG.cfm?media_id=#media_id#" addtoken="false">
	</cfoutput>
</cfif>