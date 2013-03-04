<cfset title="Media">
<div id="_header">
    <cfinclude template="/includes/_header.cfm">
</div>
<script type='text/javascript' language="javascript" src='/includes/media.js'></script>
<cfif isdefined("url.collection_object_id")>
    <cfoutput>
    	<cflocation url="MediaSearch.cfm?action=search&relationships=shows cataloged_item&related_primary_key1=#url.collection_object_id#" addtoken="false">
    </cfoutput>
</cfif>
<!----------------------------------------------------------------------------------------->
<cfif action is "nothing">
<cfoutput>
    <cfquery name="ctmedia_relationship" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select media_relationship from ctmedia_relationship order by media_relationship
	</cfquery>
	<cfquery name="ctmedia_label" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select media_label from ctmedia_label order by media_label
	</cfquery>
	<cfquery name="ctmedia_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select media_type from ctmedia_type order by media_type
	</cfquery>
	<cfquery name="ctmime_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select mime_type from ctmime_type order by mime_type
	</cfquery>
	 <cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
        <a href="/media.cfm?action=newMedia">[ create media ]</a>
    </cfif>
	<cfquery name="hasCanned" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select SEARCH_NAME,URL
		from cf_canned_search,cf_users
		where cf_users.user_id=cf_canned_search.user_id
		and username='#session.username#'
		and URL like '%MediaSearch.cfm%'
		order by search_name
	</cfquery>
	<cfif hasCanned.recordcount gt 0>
		<label for="goCanned">Saved Searches</label>
		<select name="goCanned" id="goCanned" size="1" onchange="document.location=this.value;">
			<option value=""></option>
			<option value="saveSearch.cfm?action=manage">[ Manage ]</option>
			<cfloop query="hasCanned">
				<option value="#url#">#SEARCH_NAME#</option><br />
			</cfloop>
		</select>
	</cfif>
	Search for Media &nbsp;&nbsp;
	<style>
		.rdoCtl {
			font-size:small;
			font-weight:bold;
			border:1px dotted green;
		}
	</style>
	<form name="newMedia" method="post" action="">
		<input type="hidden" name="action" value="search">
		<label for="keyword">Keyword</label>
		<input type="text" name="keyword" id="keyword" size="40">
		<span class="rdoCtl">Match Any<input type="radio" name="kwType" value="any"></span>
		<span class="rdoCtl">Match All<input type="radio" name="kwType" value="all" checked="checked"></span>
		<span class="rdoCtl">Match Phrase<input type="radio" name="kwType" value="phrase"></span>
		<label for="media_uri">Media URI</label>
		<input type="text" name="media_uri" id="media_uri" size="90">
		<table>
			<tr>
				<td><label for="tag">Require TAG?</label></td>
				<td><input type="checkbox" id="tag" name="tag" value="1"></td>
			</tr>
			<tr>
				<td><label for="noDNG">Ignore DNG?</label></td>
				<td><input type="checkbox" id="noDNG" name="noDNG" value="1" checked="checked"></td>
			</tr>
		</table>
		<label for="mime_type">MIME Type</label>
		<select name="mime_type" id="mime_type" multiple="multiple" size="3">
			<option value="" selected="selected">Anything</option>
			<cfloop query="ctmime_type">
				<option value="#mime_type#">#mime_type#</option>
			</cfloop>
		</select>
        <label for="media_type">Media Type</label>
		<select name="media_type" id="media_type" multiple="multiple" size="3">
			<option value="" selected="selected">Anything</option>
			<cfloop query="ctmedia_type">
				<option value="#media_type#">#media_type#</option>
			</cfloop>
		</select>
		<label for="relationships">Media Relationships</label>
		<select name="relationships" id="relationships" size="5" multiple="multiple">
			<option selected="selected" value="">Anything</option>
			<cfloop query="ctmedia_relationship">
				<option value="#media_relationship#">#media_relationship#</option>
			</cfloop>
		</select>
		<label for="labels">Media Label</label>
		<select name="media_label" id="media_label" size="1">
			<option value=""></option>
			<cfloop query="ctmedia_label">
				<option value="#media_label#">#media_label#</option>
			</cfloop>
		</select>
		<label for="label_value">Media Label Value</label>
		<input type="text" name="label_value" id="label_value" size="80">
		<br>
		<input type="submit" value="Find Media" class="schBtn">
		<input type="reset" value="reset form" class="clrBtn">
	</form>
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------------->
<cfif action is "search">
<cfif not isdefined("session.displayrows")>
	<cfset session.displayrows=20>
</cfif>
<cfoutput>
	<cfset sql = "SELECT * FROM media_flat ">
	<cfset whr ="WHERE 1=1 ">
	<cfset srch=" ">
	<cfset mapurl = "">
	<cfparam name="relationships" default="">
	<cfset n=1>
	<cfloop list="#relationships#" delimiters="," index="thisRelationship">
		<cfset sql = "#sql#,media_relations media_relations#n#">
		<cfset whr ="#whr# AND media_flat.media_id = media_relations#n#.media_id ">
		<cfset srch="#srch# AND media_relations#n#.media_relationship = '#thisRelationship#'">
		<cfif isdefined ("related_primary_key#n#")>
			<cfset thisKey=evaluate("related_primary_key" & n)>
			<cfset srch="#srch# AND media_relations#n#.related_primary_key = #thisKey#">
		</cfif>
		<cfset n=n+1>
	</cfloop>
	<cfset mapurl="#mapurl#&relationships=#relationships#">
	<cfif isdefined("keyword") and len(keyword) gt 0>
		<cfif not isdefined("kwType")>
			<cfset kwType="all">
		</cfif>
		<cfif kwType is "any">
			<cfset kwsql="">
			<cfloop list="#keyword#" index="i" delimiters=",;: ">
				<cfset kwsql=listappend(kwsql,"upper(media_flat.keywords) like '%#ucase(trim(i))#%'","|")>
			</cfloop>
			<cfset kwsql=replace(kwsql,"|"," OR ","all")>
			<cfset srch="#srch# AND ( #kwsql# ) ">
		<cfelseif kwType is "all">
			<cfset kwsql="">
			<cfloop list="#keyword#" index="i" delimiters=",;: ">
				<cfset kwsql=listappend(kwsql,"upper(media_flat.keywords) like '%#ucase(trim(i))#%'","|")>
			</cfloop>
			<cfset kwsql=replace(kwsql,"|"," AND ","all")>
			<cfset srch="#srch# AND ( #kwsql# ) ">
		<cfelse>
			<cfset srch="#srch# AND upper(media_flat.keywords) like '%#ucase(keyword)#%'">
		</cfif>
		<cfset mapurl="#mapurl#&kwType=#kwType#&keyword=#keyword#">
	</cfif>
	<cfif isdefined("noDNG") and noDNG is 1>
		<cfset srch="#srch# AND media_flat.mime_type != 'image/dng'">
		<cfset mapurl="#mapurl#&noDNG=#noDNG#">
	</cfif>
	<cfif isdefined("media_uri") and len(media_uri) gt 0>
		<cfset srch="#srch# AND upper(media_flat.media_uri) like '%#ucase(media_uri)#%'">
		<cfset mapurl="#mapurl#&media_uri=#media_uri#">
	</cfif>
	<cfif isdefined("tag") and len(tag) gt 0>
		<cfset whr="#whr# AND media_flat.media_id IN (select media_id from tag)">
		<cfset mapurl="#mapurl#&tag=#tag#">
	</cfif>
	<cfif isdefined("media_type") and len(media_type) gt 0>
		<cfset srch="#srch# AND media_flat.media_type IN (#listQualify(media_type,"'")#)">
		<cfset mapurl="#mapurl#&media_type=#media_type#">
	</cfif>
	<cfif isdefined("media_id") and len(#media_id#) gt 0>
		<cfset whr="#whr# AND media_flat.media_id in (#media_id#)">
		<cfset mapurl="#mapurl#&media_id=#media_id#">
	</cfif>
	<cfif isdefined("mime_type") and len(#mime_type#) gt 0>
		<cfset srch="#srch# AND media_flat.mime_type in (#listQualify(mime_type,"'")#)">
		<cfset mapurl="#mapurl#&mime_type=#mime_type#">
	</cfif>
	<cfif (isdefined("media_label") and len(media_label) gt 0) or (isdefined("label_value") and len(label_value) gt 0)>
		<cfset sql = "#sql#,media_labels">
		<cfset whr ="#whr# AND media_flat.media_id = media_labels.media_id ">
		<cfif isdefined("media_label") and len(media_label) gt 0>
			<cfset srch="#srch# AND media_labels.media_label = '#media_label#'">
			<cfset mapurl="#mapurl#&media_label=#media_label#">
		</cfif>
		<cfif isdefined("label_value") and len(label_value) gt 0>
			<cfset srch="#srch# AND upper(media_labels.label_value) like '%#ucase(label_value)#%'">
			<cfset mapurl="#mapurl#&label_value=#label_value#">
		</cfif>
	</cfif>
	<cfif len(srch) is 0>
		<div class="error">You must enter search criteria.</div>
		<cfabort>
	</cfif>
	<cfset srch = "#srch# AND rownum <= 500">
	<cfset ssql="#sql# #whr# #srch# order by media_flat.media_id">
	<!--- --->
	<cfquery name="findIDs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		#preservesinglequotes(ssql)#
	</cfquery>
	<cfif session.username is "cfidler">
		<cfdump var=#findIDs#>
	</cfif>
	<table cellpadding="10"><tr>
	<cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
	    <cfset h="/media.cfm?action=newMedia">
		<cfif isdefined("url.relationships") and isdefined("url.related_primary_key1") and url.relationships is "shows cataloged_item">
			<cfset h=h & '&collection_object_id=#url.related_primary_key1#'>
			find Media and pick an item to link to existing Media
			<br>
		</cfif>
		<td><a href="#h#">[ create media ]</a></td>
	</cfif>
	<cfif findIDs.recordcount is 0>
		<div class="error">Nothing found.</div>
		<cfabort>
	<cfelse>
		<cfset title="Media Results: #findIDs.recordcount# records found">
		<cfif findIDs.recordcount is 500>
			<div style="border:2px solid red;text-align:center;margin:0 10em;">
				Note: This form will return a maximum of 500 records.
			</div>
		</cfif>
		<td><a href="/MediaSearch.cfm">[ Media Search ]</a></td>
	</cfif>
	<form name="dlm" method="post" action="/bnhmMaps/bnhmMapMediaData.cfm" target="_blank">
		<input type="hidden" name="ssql" value="#ssql#">
		<td valign="middle">
			<input type="submit" class="lnkBtn" value="BerkeleyMapper">
		</td>
	</form>
	<form name="dlm" method="post" action="MediaSearchDownload.cfm" target="_blank">
		<input type="hidden" name="ssql" value="#ssql#">
		<td valign="middle">
			<input type="submit"  class="lnkBtn" value="Download">
		</td>
	</form>
	<td>
		<span class="controlButton"
			onclick="saveSearch('#Application.ServerRootUrl#/MediaSearch.cfm?action=search#mapURL#');">Save&nbsp;Search</span>
	</td>
	</tr></table>
	<cfset q="">
	<cfloop list="#StructKeyList(form)#" index="key">
		<cfif len(form[key]) gt 0 and key is not "FIELDNAMES" and key is not "offset">
			<cfset q=listappend(q,"#key#=#form[key]#","&")>
		 </cfif>
	</cfloop>
	<cfloop list="#StructKeyList(url)#" index="key">
		 <cfif len(url[key]) gt 0 and key is not "FIELDNAMES" and key is not "offset">
			<cfset q=listappend(q,"#key#=#url[key]#","&")>
		 </cfif>
	</cfloop>
	<cfsavecontent variable="pager">
		<cfparam name="URL.offset" default="0">
			<cfif session.username is "cfidler" or session.username is "dlm">
				<cfdump var=#URL#>
			</cfif>
		<cfparam name="limit" default="1">
		<cfif findIDs.recordcount gt 1>
			<cfset Result_Per_Page=session.displayrows>
			<cfset Total_Records=findIDs.recordcount>
			<cfset limit=URL.offset+Result_Per_Page>
			<cfset start_result=URL.offset+1>
			<div style="margin-left:20%;">
				Showing results #start_result# -
				<cfif limit GT Total_Records> #Total_Records# <cfelse> #limit# </cfif> of #Total_Records#
				<cfif Total_Records GT Result_Per_Page>
					<cfset URL.offset=URL.offset+1>
					<br>
					<cfif URL.offset GT Result_Per_Page>
						<cfset prev_link=URL.offset-Result_Per_Page-1>
						<a href="#cgi.script_name#?offset=0&#q#">[ First ]</a>
						<a href="#cgi.script_name#?offset=#prev_link#&#q#">[ Previous ]</a>
					</cfif>
					<cfset Total_Pages=ceiling(Total_Records/Result_Per_Page)>
					<cfset currentPage=(url.offset + session.displayrows) / session.displayrows>
					<cfset minI=currentPage-5>
					<cfset maxI=currentPage+5>
					<cfloop index="i" from="1" to="#Total_Pages#">
						<cfset j=i-1>
						<cfset offset_value=j*Result_Per_Page>
						<cfif offset_value EQ URL.offset-1 >
							#i#
						<cfelseif i gt minI and i lt maxI>
							<a href="#cgi.script_name#?offset=#offset_value#&#q#">#i#</a>
						</cfif>
					</cfloop>
					<cfif limit LT Total_Records>
						<cfset next_link=URL.offset+Result_Per_Page-1>
						<a href="#cgi.script_name#?offset=#next_link#&#q#">[ Next ]</a>
						<a href="#cgi.script_name#?offset=#offset_value#&#q#">[ Last ]</a>
					</cfif>
				</cfif>
			</div>
		</cfif>
	</cfsavecontent>
	#pager#
	<cfset rownum=1>
<table>
<cfif url.offset is 0><cfset url.offset=1></cfif>
<cfset stuffToNotPlay="audio/x-wav">
<cfloop query="findIDs" startrow="#URL.offset#" endrow="#limit#">
	<cfinvoke component="/component/functions" method="getMediaPreview" returnVariable="mp">
		<cfinvokeargument name="preview_uri" value="#preview_uri#">
		<cfinvokeargument name="media_type" value="#media_type#">
	</cfinvoke>
	<cfset alt=''>
	<cfset lbl=replace(labels,"==",chr(7),"all")>
	<cfset rel=replace(relationships,"==",chr(7),"all")>
	<cfloop list="#lbl#" index="i" delimiters="|">
		<cfif listgetat(i,1,chr(7)) is "description">
			<cfset alt=listgetat(i,2,chr(7))>
		</cfif>
	</cfloop>
	<cfset addThisClass=''>
	<cfif listfind(stuffToNotPlay,mime_type)>
		<cfset addThisClass="noplay">
	</cfif>
	<cfif len(alt) is 0>
		<cfset alt=media_uri>
	</cfif>
	<tr #iif(rownum MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
		<td align="middle">
			<a href="#media_uri#" target="_blank" class="#addThisClass#" title="#alt#">
				<img src="#mp#" alt="#alt#" style="max-width:150px;max-height:150px;">
			</a>
			<br>
			<span style = "font-size:small;">#media_type# (#mime_type#)</span>
			<br>
			<span style = "font-size:small;">#license#</span>
			<br>
			<span style = "font-size:small;"><a href="/media/#media_id#">details</a></span>
		</td>
		<td align="middle">
			<div id="mapID_#media_uri#">
				<cfif len(coordinates) gt 0>
					<cfinvoke component="component.functions" method="getMap" returnvariable="contents">
					    <cfinvokeargument name="media_id" value="#media_id#">
					</cfinvoke>
					#contents#
				</cfif>
			</div>
		</td>
		<td>
			<div style="max-height:10em;overflow:auto;">
				<cfset relMedia=''>
				<cfloop list="#rel#" index="i" delimiters="|">
					<cfset r=listgetat(i,1,chr(7))>
					<cfset t=listgetat(i,2,chr(7))>
					<cfif right(r,6) is ' media'>
						<cfset relMedia=listAppend(relMedia,t)>
					<cfelse>
						#r#: #t#<br>
					</cfif>
				</cfloop>
				<cfloop list="#lbl#" index="i" delimiters="|">
					#listgetat(i,1,chr(7))#: #listgetat(i,2,chr(7))#<br>
				</cfloop>
			</div>
		<cfif media_type is "multi-page document">
			<a href="/document.cfm?media_id=#media_id#">[ view as document ]</a>
		</cfif>
		<cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
	        <a href="/media.cfm?action=edit&media_id=#media_id#">[ edit media ]</a>
	        <a href="/TAG.cfm?media_id=#media_id#">[ add or edit TAGs ]</a>
	    </cfif>
	    <cfif hastags gt 0>
			<a href="/showTAG.cfm?media_id=#media_id#">[ View #hastags# TAGs ]</a>
		</cfif>
		</td>
	</tr>
	<cfset rownum=rownum+1>
</cfloop>
</table>
#pager#
</cfoutput>
</cfif>
<div id="_footer">
<cfinclude template="/includes/_footer.cfm">
</div>
<!--- deal with the possibility of being called in a frame from SpecimenDetail --->
<script language="javascript" type="text/javascript">
    if (top.location!=document.location) {
    	document.getElementById('_header').style.display='none';
		document.getElementById('_footer').style.display='none';
		parent.dyniframesize();
	}
</script>