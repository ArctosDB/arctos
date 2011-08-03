<cfset title="Media">
<cfset metaDesc="Locate Media, including audio (sound recordings), video (movies), and images (pictures) of specimens, collecting sites, habitat, collectors, and more.">
<div id="_header">
    <cfinclude template="/includes/_header.cfm">
</div>
<script type='text/javascript' language="javascript" src='/includes/media.js'></script>
<cfif isdefined("url.collection_object_id")>
    <cfoutput>
    	<cflocation url="MediaSearch.cfm?action=search&relations=shows cataloged_item&related_primary_key1=#url.collection_object_id#" addtoken="false">
    </cfoutput>
</cfif>
<!----------------------------------------------------------------------------------------->
<cfif action is "nothing">
	<cfoutput>
    <cfquery name="ctmedia_relationship" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select media_relationship from ctmedia_relationship order by media_relationship
	</cfquery>
	<cfquery name="ctmedia_label" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select media_label from ctmedia_label order by media_label
	</cfquery>
	<cfquery name="ctmedia_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select media_type from ctmedia_type order by media_type
	</cfquery>
	<cfquery name="ctmime_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select mime_type from ctmime_type order by mime_type
	</cfquery>
	 <cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
        <a href="/media.cfm?action=newMedia">[ create media ]</a>
    </cfif> 
	<cfquery name="hasCanned" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<br>		
		<span class="likeLink" onclick="toggle_visibility('relForm', 'keyForm');">[ use advanced search ]</span>
		<style>
			.rdoCtl {
				font-size:small;
				font-weight:bold;
				border:1px dotted green;
			}
		</style>
		<form name="newMedia" method="post" action="">
			
			
			
			
			
			
			
				<input type="hidden" id="number_of_relations" name="number_of_relations" value="1">
			<input type="hidden" id="number_of_labels" name="number_of_labels" value="1">
			
			
			
			
			
			<input type="hidden" name="action" value="search">
			<label for="keyword">Keyword</label>
			<input type="text" name="keyword" id="keyword" size="40">
			<span class="rdoCtl">Match Any<input type="radio" name="kwType" value="any"></span>
			<span class="rdoCtl">Match All<input type="radio" name="kwType" value="all" checked="checked"></span>
			<span class="rdoCtl">Match Phrase<input type="radio" name="kwType" value="phrase"></span>
			<label for="media_uri">Media URI</label>
			<input type="text" name="media_uri" id="media_uri" size="90">
			<label for="tag">Require TAG?</label>
			<input type="checkbox" id="tag" name="tag" value="1">
			<label for="noDNG">Ignore DNG?</label>
			<input type="checkbox" id="noDNG" name="noDNG" value="1" checked="checked">
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
				<option value="">Anything</option>
				<cfloop query="ctmedia_relationship">
					<option value="#media_relationship#">#media_relationship#</option>
				</cfloop>
			</select>
			
			<label for="labels">Media Labels</label>
			<div id="labels" style="border:1px dashed red;">
				<div id="labelsDiv__1">
				<select name="label__1" id="label__1" size="1">
					<option value=""></option>
					<cfloop query="ctmedia_label">
						<option value="#media_label#">#media_label#</option>
					</cfloop>
				</select>:&nbsp;<input type="text" name="label_value__1" id="label_value__1" size="80">
				</div>
				<span class="infoLink" id="addLabel" onclick="addLabel(2)">Add Label</span>
			</div>
			<br>
			<!------
				<label for="relationships">Media Relationships</label>
				<div id="relationships" style="border:1px dashed red;">
					<select name="relationship__1" id="relationship__1" size="1">
						<option value=""></option>
						<cfloop query="ctmedia_relationship">
							<option value="#media_relationship#">#media_relationship#</option>
						</cfloop>
					</select>:&nbsp;<input type="text" name="related_value__1" id="related_value__1" size="80">
					<input type="hidden" name="related_id__1" id="related_id__1">
					<br><span class="infoLink" id="addRelationship" onclick="addRelation(2)">Add Relationship</span>
				</div>
				<br>			
			-------->
			<br>
			<input type="submit" 
				value="Find Media" 
				class="insBtn">
			<input type="reset" 
				value="reset form" 
				class="clrBtn">
		</form>
	
	

	</div>
	</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------------->
<cfif action is "search">
<cfoutput>	
	<cfset sql = "SELECT * FROM media_flat ">
	<cfset whr ="WHERE 1=1 ">
	<cfset srch=" ">
	<cfset mapurl = "">
	<cfset terms="">
	<cfif not isdefined("mapurl")>
		<cfset mapurl = "">
	</cfif>
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
		<cfset terms="#keyword#">
		
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

	<cfif not isdefined("number_of_labels")>
	    <cfif (isdefined("label") and len(label) gt 0) or (isdefined("label__1") and len(label__1) gt 0)>
			<cfset number_of_labels=1>
			<cfif isdefined("label") and len(label) gt 0>
				<cfset label__1=label>
			</cfif>
			<cfif isdefined("label_value") and len(label_value) gt 0>
				<cfset label_value__1=label_value>
			</cfif>
		<cfelse>
			<cfset number_of_labels=0>
		</cfif>
	</cfif>
	<cfset mapurl="#mapurl#&number_of_labels=#number_of_labels#">	
	<cfloop from="1" to="#number_of_labels#" index="n">
		<cftry>
	        <cfset thisLabel = #evaluate("label__" & n)#>
		    <cfcatch>
	            <cfset thisLabel = "">
		    </cfcatch>
        </cftry>
        <cftry>
	        <cfset thisLabelValue = #evaluate("label_value__" & n)#>
		    <cfcatch>
	            <cfset thisLabelValue = "">
		    </cfcatch>
        </cftry>		
        <cfif len(thisLabel) gt 0 OR len(thisLabelValue) gt 0>
			<cfset sql = "#sql#,media_labels media_labels#n#">
			<cfset whr ="#whr# AND media_flat.media_id = media_labels#n#.media_id ">
			<cfif len(thisLabel) gt 0>
				<cfset srch="#srch# AND media_labels#n#.media_label = '#thisLabel#'">
			</cfif>
			<cfif len(thisLabelValue) gt 0>
				<cfset srch="#srch# AND upper(media_labels#n#.label_value) = '%#ucase(thisLabelValue)#%'">
			</cfif>
		</cfif>
	</cfloop>
	
	
	
	
	
	
	<cfif len(srch) is 0>
		<div class="error">You must enter search criteria.</div>
		<cfabort> 
	</cfif>




<cfset srch = "#srch# AND rownum <= 500">
<cfset ssql="#sql# #whr# #srch# order by media_id">
	<hr>#ssql#
	<cfquery name="findIDs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		#preservesinglequotes(ssql)#
	</cfquery>
	<table cellpadding="10"><tr>
	<cfif findIDs.recordcount is 0>
		<div class="error">Nothing found.</div>
		<cfabort>
<!--- 	<cfelseif findIDs.recordcount is 1 and not listfindnocase(cgi.REDIRECT_URL,'media',"/")>
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="/media/#findIDs.media_id#">
		<cfabort> --->
	<cfelse>
		<cfset title="Media Results: #findIDs.recordcount# records found">
		<cfset metaDesc="Results of Media search: #findIDs.recordcount# records found.">
		<cfif findIDs.recordcount is 500>
			<div style="border:2px solid red;text-align:center;margin:0 10em;">
				Note: This form will return a maximum of 500 records.
			</div>
		</cfif>
		<td><a href="/MediaSearch.cfm">[ Media Search ]</a></td>
	</cfif>
	<cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
	    <cfset h="/media.cfm?action=newMedia">
		<cfif isdefined("url.relationship__1") and isdefined("url.related_primary_key__1")>
			<cfif url.relationship__1 is "cataloged_item">
				<cfset h=h & '&collection_object_id=#url.related_primary_key__1#'>
				( find Media and pick an item to link to existing Media )
				<br>
			</cfif>
		</cfif>
		<td><a href="#h#">[ create media ]</a></td>
	</cfif>
	
	<form name="dlm" method="post" action="/bnhmMaps/bnhmMapMediaData.cfm">
	<input type="hidden" name="ssql" value="#ssql#">
	<td valign="middle">
	
	<input type="submit" class="lnkBtn" value="BerkeleyMapper">

	</td>
	</form>
	<form name="dlm" method="post" action="MediaSearchDownload.cfm">
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
		<cfset Result_Per_Page=session.displayrows>
		<cfset Total_Records=findIDs.recordcount> 
		<cfparam name="URL.offset" default="0"> 
		<cfparam name="limit" default="1">
		<cfset limit=URL.offset+Result_Per_Page> 
		<cfset start_result=URL.offset+1> 
		<cfif findIDs.recordcount gt 1>
			<div style="margin-left:20%;">
			Showing results #start_result# - 
			<cfif limit GT Total_Records> #Total_Records# <cfelse> #limit# </cfif> of #Total_Records# 
			<cfset URL.offset=URL.offset+1> 
			<cfif Total_Records GT Result_Per_Page> 
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
	<br>
	#pager#
	<cfset rownum=1>
<table>
<cfloop query="findIDs" startrow="#URL.offset#" endrow="#limit#">
	<cfset mp=getMediaPreview(preview_uri,media_type)>
	<cfset alt=''>
	<cfset lbl=replace(labels,"==",chr(7),"all")>
	<cfset rel=replace(relationships,"==",chr(7),"all")>		
	<cfloop list="#lbl#" index="i" delimiters="|">
		<cfif listgetat(i,1,chr(7)) is "description">
			<cfset alt=listgetat(i,2,chr(7))>
		</cfif>
	</cfloop>
	<cfif len(alt) is 0>
		<cfset alt=media_uri>
	</cfif>
	<tr #iif(rownum MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
		<td align="middle">
			<a href="#media_uri#" target="_blank">
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
					<cfset iu="http://maps.google.com/maps/api/staticmap?key=#application.gmap_api_key#&center=#coordinates#">
					<cfset iu=iu & "&markers=color:red|size:tiny|#coordinates#&sensor=false&size=100x100&zoom=2">
					<cfset iu=iu & "&maptype=roadmap">
					<a href="http://maps.google.com/maps?q=#coordinates#" target="_blank">
						<img src="#iu#" alt="Google Map">
					</a>
				</cfif>
			</div>			
		</td>
		<td>							
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
		<br>
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

 here we are

<cfabort>
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