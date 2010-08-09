<cfset title="Media">
<cfset metaDesc="Locate Media, including audio (sound recordings), video (movies), and images (pictures) of specimens, collecting sites, habitat, collectors, and more.">
<div id="_header">
    <cfinclude template="/includes/_header.cfm">
</div>
<cfif isdefined("url.collection_object_id")>
    <cfoutput>
    	<cflocation url="/development/MediaSearch.cfm?action=search&relationship__1=cataloged_item&related_primary_key__1=#url.collection_object_id#" addtoken="false">
    </cfoutput>
</cfif>
<script type='text/javascript' src='/includes/media.js'></script>

<!----------------------------------------------------------------------------------------->
<cfif #action# is "nothing">
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
        <a href="/media.cfm?action=newMedia">[ Create media ]</a>
    </cfif> 
	<br>
	<cfquery name="hasCanned" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select SEARCH_NAME,URL
		from cf_canned_search,cf_users
		where cf_users.user_id=cf_canned_search.user_id
		and username='#session.username#'
		and URL like '%MediaSearch.cfm%'
		order by search_name
	</cfquery>
	<cfif #hasCanned.recordcount# gt 0>
		<div style="padding-left:2em;padding-right:2em;">
			Saved Searches: 
			<select name="goCanned" id="goCanned" size="1" onchange="document.location=this.value;">
				<option value=""></option>
				<option value="saveSearch.cfm?action=manage">[ Manage ]</option>
				<cfloop query="hasCanned">
					<option value="#url#">#SEARCH_NAME#</option><br />
				</cfloop>
			</select>
		</div>
	</cfif>	
	
	<div id="keyForm" style="display:block">
		Search for Media &nbsp;&nbsp;
		<br>		
		<a href="javascript:void(0);" onclick="toggle_visibility('relForm', 'keyForm');" style="font-size:x-small">Advanced search</a>
		<style>
			.rdoCtl {
				font-size:small;
				font-weight:bold;
				border:1px dotted green;
			}
		</style>
		<form name="newMedia" method="post" action="">
			<input type="hidden" name="action" value="search">
			<input type="hidden" name="srchType" value="key">
			<label for="keyword">Keyword</label>
			<input type="text" name="keyword" id="keyword" size="40">
			<span class="rdoCtl">Match Any<input type="radio" name="kwType" value="any"></span>
			<span class="rdoCtl">Match All<input type="radio" name="kwType" value="all" checked="checked"></span>
			<span class="rdoCtl">Match Phrase<input type="radio" name="kwType" value="phrase"></span>
			<label for="media_uri">Media URI</label>
			<input type="text" name="media_uri" id="media_uri" size="90">
			<label for="tag">Require TAG?</label>
			<input type="checkbox" id="tag" name="tag" value="1">
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
			<br>
			<input type="submit" 
				value="Find Media" 
				class="insBtn">
			<input type="reset" 
				value="reset form" 
				class="clrBtn">
		</form>
	</div>
	
	<div id="relForm" style="display:none">
		Advanced Search for Media
		<br>
		<a href="javascript:void(0);" onclick="toggle_visibility('keyForm', 'relForm');" style="font-size:x-small">Simple Keywords Search</a>
		<form name="newMedia" method="post" action="">
			<input type="hidden" name="action" value="search">
			<input type="hidden" name="srchType" value="full">
			<input type="hidden" id="number_of_relations" name="number_of_relations" value="1">
			<input type="hidden" id="number_of_labels" name="number_of_labels" value="1">
			<label for="media_uri">Media URI</label>
			<input type="text" name="media_uri" id="media_uri" size="90">
			<label for="mime_type">MIME Type</label>
			<select name="mime_type" id="mime_type">
				<option value=""></option>
					<cfloop query="ctmime_type">
						<option value="#mime_type#">#mime_type#</option>
					</cfloop>
			</select>
            <label for="media_type">Media Type</label>
			<select name="media_type" id="media_type">
				<option value=""></option>
					<cfloop query="ctmedia_type">
						<option value="#media_type#">#media_type#</option>
					</cfloop>
			</select>
			<label for="tag">Require TAG?</label>
			<input type="checkbox" id="tag" name="tag" value="1">
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

<cfif not isdefined("mapurl")>
	<cfset mapurl = "null">
</cfif>

<cfoutput>
<cfscript>
    function highlight(findIn,replaceThis) {
    	foundAt=FindNoCase(replaceThis,findIn);
    	endAt=FindNoCase(replaceThis,findIn)+len(replaceThis);
    	if(foundAt gt 0) {
    		findIn=Insert('</span>', findIn, endAt-1);
    		findIn=Insert('<span style="background-color:yellow">', findIn, foundAt-1);
    	}
    	return findIn;
    }
</cfscript>
	<!-- Default mediaSearch sql query-->
	<cfset sql = "SELECT * FROM media_flat ">	
	
	<cfset whr ="WHERE media_flat.media_id > 0">
	<cfset srch=" ">
	<cfif isdefined("srchType") and srchType is "key">

		<cfif isdefined("keyword") and len(keyword) gt 0>

			<cfif not isdefined("kwType")><cfset kwType="all"></cfif>
			<cfif kwType is "any">
				<cfset kwsql="">
				<cfloop list="#keyword#" index="i" delimiters=",;: ">
					<cfset kwsql=listappend(kwsql,"upper(keywords) like '%#ucase(trim(i))#%'","|")>
				</cfloop>
				<cfset kwsql=replace(kwsql,"|"," OR ","all")>
				<cfset srch="#srch# AND ( #kwsql# ) ">
			<cfelseif kwType is "all">
				<cfset kwsql="">
				<cfloop list="#keyword#" index="i" delimiters=",;: ">
					<cfset kwsql=listappend(kwsql,"upper(keywords) like '%#ucase(trim(i))#%'","|")>
				</cfloop>
				<cfset kwsql=replace(kwsql,"|"," AND ","all")>
				<cfset srch="#srch# AND ( #kwsql# ) ">
			<cfelse>
				<cfset srch="#srch# AND upper(keywords) like '%#ucase(keyword)#%'">
			</cfif>
		</cfif>
		
		<cfif isdefined("media_uri") and len(media_uri) gt 0>
			<cfset srch="#srch# AND upper(media_uri) like '%#ucase(media_uri)#%'">
		</cfif>
		<cfif isdefined("tag") and len(tag) gt 0>
			<cfset whr="#whr# AND media_flat.media_id IN (select media_id from tag)">
		</cfif>
		<cfif isdefined("media_type") and len(media_type) gt 0>
			<cfset srch="#whr# AND media_type IN (#listQualify(media_type,"'")#)">
		</cfif>
		
		<cfif isdefined("media_id") and len(#media_id#) gt 0>
			<cfset whr="#whr# AND media_flat.media_id in (#media_id#)">
		</cfif>
		<cfif isdefined("mime_type") and len(#mime_type#) gt 0>
			<cfset srch="#whr# AND mime_type in (#listQualify(mime_type,"'")#)">
		</cfif>

	<cfelse>

		<cfif isdefined("media_uri") and len(media_uri) gt 0>
			<cfset srch="#srch# AND upper(media_uri) like '%#ucase(media_uri)#%'">
		</cfif>
		<cfif isdefined("media_type") and len(media_type) gt 0>
			<cfset srch="#srch# AND upper(media_type) like '%#ucase(media_type)#%'">
		</cfif>
		<cfif isdefined("tag") and len(tag) gt 0>
			<cfset whr="#whr# AND media.media_id in (select media_id from tag)">
		</cfif>
		<cfif isdefined("media_id") and len(#media_id#) gt 0>
			<cfset whr="#whr# AND media.media_id in (#media_id#)">
		</cfif>
		<cfif isdefined("mime_type") and len(#mime_type#) gt 0>
			<cfset srch="#srch# AND mime_type = '#mime_type#'">
		</cfif>
		
		<cfif not isdefined("number_of_relations")>
		    <cfif (isdefined("relationship") and len(relationship) gt 0) or (isdefined("related_to") and len(related_to) gt 0)>
				<cfset number_of_relations=1>
				<cfif isdefined("relationship") and len(relationship) gt 0>
					<cfset relationship__1=relationship>
				</cfif>
				 <cfif isdefined("related_to") and len(related_to) gt 0>
					<cfset related_value__1=related_to>
				</cfif>
			<cfelse>
				<cfset number_of_relations=1>
			</cfif>
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
		<cfloop from="1" to="#number_of_relations#" index="n">
			<cftry>
		        <cfset thisRelationship = #evaluate("relationship__" & n)#>
			    <cfcatch>
			        <cfset thisRelationship = "">
			    </cfcatch>
		    </cftry>
		    <cftry>
		        <cfset thisRelatedItem = #evaluate("related_value__" & n)#>
			    <cfcatch>
		            <cfset thisRelatedItem = "">
			    </cfcatch>
		    </cftry>
		    <cftry>
		         <cfset thisRelatedKey = #evaluate("related_primary_key__" & n)#>
			    <cfcatch>
		            <cfset thisRelatedKey = "">
			    </cfcatch>
		    </cftry>
		    <cfset frm="#frm#,media_relations media_relations#n#">
			<cfset whr="#whr# and media.media_id=media_relations#n#.media_id (+)">
			<cfif len(#thisRelationship#) gt 0>
				<cfset srch="#srch# AND media_relations#n#.media_relationship like '%#thisRelationship#%'">
			</cfif>
			<cfif len(#thisRelatedItem#) gt 0>
				<cfset srch="#srch# AND upper(media_rel_values) like '%#ucase(thisRelatedItem)#%'">
			</cfif>
		    <cfif len(#thisRelatedKey#) gt 0>
				<cfset srch="#srch# AND related_primary_keys like '%#thisRelatedKey#%'">
			</cfif>
		</cfloop>
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
	        <cfif len(#thisLabel#) gt 0>
				<cfset srch="#srch# AND upper(media_labels) like '#ucase(thisLabel)#'">
			</cfif>
			<cfif len(#thisLabelValue#) gt 0>
				<cfset srch="#srch# AND upper(label_values) like '%#ucase(thisLabelValue)#%'">
			</cfif>
		</cfloop>
		<cfif len(srch) is 0>
			<div class="error">You must enter search criteria.</div>
			<cfabort>
		</cfif>
		

	</cfif><!--- end srchType --->
	
	<!-- Limit results to 500 rows -->
	<cfset srch = "#srch# AND rownum <= 500">
	
	<!-- Finalize query -->
	<cfset ssql="#sql# #whr# #srch# order by media_id">		
	<cfquery name="findIDs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		#preservesinglequotes(ssql)#
	</cfquery>
	
	<cfif findIDs.recordcount is 0>
		<div class="error">Nothing found.</div>
		<cfabort>
	<cfelseif findIDs.recordcount is 1 and not listfindnocase(cgi.REDIRECT_URL,'media',"/")>
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="/media/#findIDs.media_id#">
		<cfabort>
	<cfelse>
		<cfset title="Media Results: #findIDs.recordcount# records found">
		<cfset metaDesc="Results of Media search: #findIDs.recordcount# records found.">
		<cfif findIDs.recordcount is 500>
			<div style="border:2px solid red;text-align:center;margin:0 10em;">
				Note: This form will return a maximum of 500 records.
			</div>
		</cfif>
		<a href="/development/MediaSearch.cfm">[ Media Search ]</a>
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
		<a href="#h#">[ Create media ]</a>
	</cfif>
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
		<cfset Result_Per_Page=10>
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
				<cfset Total_Pages=ceiling(Total_Records/Result_Per_Page)> 

				<cfif URL.offset gt 10*Result_Per_Page>
					<cfset prev_link=URL.offset-1-(10*Result_Per_Page)> 
					<a href="#cgi.script_name#?offset=#prev_link#&#q#">PREV 10</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				</cfif>
				
				<cfif URL.offset GT Result_Per_Page> 
					<cfset prev_link=URL.offset-Result_Per_Page-1> 
					<a href="#cgi.script_name#?offset=#prev_link#&#q#">PREV</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				</cfif> 
				
				<cfset start_page=((int(URL.offset/100)*100)/Result_Per_Page)+1>
				<cfset end_page=min(start_page+9,Total_Pages)>
				
				<cfloop index="i" from="#start_page#" to="#end_page#"> 
						<cfset j=i-1> 
						<cfset offset_value=j*Result_Per_Page> 
						<cfif offset_value EQ URL.offset-1 > 
							#i# 
						<cfelse> 
							<a href="#cgi.script_name#?offset=#offset_value#&#q#">#i#</a>
						</cfif> 
				</cfloop> 
								
				<cfif limit LT Total_Records> 
					<cfset next_link=URL.offset+Result_Per_Page-1> 
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="#cgi.script_name#?offset=#next_link#&#q#">NEXT</a>
				</cfif>
				
				<cfif end_page lt Total_Pages>
					<cfset next_link=(end_page*Result_Per_Page)> 
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="#cgi.script_name#?offset=#next_link#&#q#">NEXT 10</a>
				</cfif>
				
			</cfif>
		</div>
		</cfif>
	</cfsavecontent>
	
	<br>
	<cfset mapurl="">
	<span class="controlButton"
		onclick="window.open('/development/MediaSearchDownload.cfm?tableName=#session.MediaSrchTab#','_blank');">Bulk Download Media Results</span>
	<span class="controlButton"
		onclick="window.open('/bnhmMaps/bnhmMapData.cfm?#mapurl#','_blank');">BerkeleyMapper</span>
	<span class="controlButton"
		onclick="saveSearch('#Application.ServerRootUrl#/MediaSearch.cfm?#mapURL#');">Save&nbsp;Search</span>
	<br>
	#pager#
				
	<cfset rownum=1>
	<cfif url.offset is 0><cfset url.offset=1></cfif>

<table>

<!-- Results Table Header for grid view (for more than one result)-->
<tr>
	<td><center><strong>Media Preview<br>(Click to View)</strong></center></td>
	<td><center><strong>Map</strong></center></td>
	<td><center><strong>Details</strong></center></td>		
</tr>

<!--<cfset downloadResults = querynew("scientific_name,agent_name,locality,description")> -->

<cfloop query="findIDs" startrow="#URL.offset#" endrow="#limit#">

	<cfset mp=getMediaPreview(preview_uri,media_type)>

	<cfset mrel = ListToArray(media_relationships, ";")>
	<cfset rpkeys = ListToArray(related_primary_keys, ";")>

	<cfset mlabels = ListToArray(media_labels, ";")>
	<cfset lvalues = ListToArray(label_values, ";")>

	<cfset media_details_url = "/media/" & "" & #media_id#>											
	<cfset agent_name="#created_agent#">	

	<!-- Cataloged item information -->
	<cfset sci_name="#scientific_name#">	
	<cfset cat_item="#cat_num#">	
	<cfset coll_obj_id="#collecting_object_id#">

	<!-- Collecting event info -->
	<cfset coll_event_id="#collecting_event_id#">			
	<cfset coll_event="#locality#">
	<cfset coll_event_uri="/showLocality.cfm?action=srch&collecting_event_id=#coll_event_id#">

	<!-- Lat/Long-->
	<cfset dec_latlong=ListToArray(lat_long, "; ")>
	<cfset dec_lat="#dec_latlong[1]#">
	<cfset dec_long=dec_latlong[2]>

	<!-- Other relationships-->
	<cfset project="#project_name#">			
	<cfset publication="#publication_name#">			
	<cfset shows_locality="#shows_loc_name#">				
	<cfset descr_taxonomy="#taxonomy_description#">
	
	<cfset kw="">
	
	<cfset desc_i = 1>
	<cfloop list="#media_labels#" delimiters=";" index="lab">
		<cfif lab is 'description'>
			<cfbreak />
		</cfif>
		<cfset desc_i= desc_i+1>
	</cfloop>

	<cfset description="#lvalues[desc_i]#">
	 
	<cfset alt="#media_uri#">
	
	<cfif findIDs.recordcount is 1>		
		<cfset alt=description>
		
		<cfset title = description>
		<cfset metaDesc = "#description# for #media_type# (#mime_type#)">
	</cfif>

	<tr #iif(rownum MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>

		<cfif len(cat_item) gt 0>
			<cfset cat_item = '<a href="/guid/#guid_string#">#cat_item#</a>'>
		</cfif>
		
		<cfif len(coll_event) gt 0>
			<cfset coll_event='<a href="/showLocality.cfm?action=srch&collecting_event_id=#coll_event_id#">#coll_event#</a>'>
		</cfif>

		<cfif ArrayLen(mrel) gt 0>		
			<cfset i = 1>		
			<cfloop list="media_relationships" delimiters="; " index="rel">
				<!--- <cfif #rel# is "created by agent">
					<cfset agent_name_id=#rpkeys[i]#>
				<cfelseif #rel# is "cataloged_item">
					<cfset cat_item_sum=#rpkeys[i]#>
					<cfset coll_obj_id=#related_primary_key#>
					
					<!-- extract the scientific name -->
					<cfset begPos = find('(', cat_item_sum)>
					
					<cfif begPos gt 0>
						<cfset endPos = find(')', cat_item_sum)>
						<cfset scientific_name=mid(cat_item_sum,begPos+1, endPos-begPos-1)>
						<cfset scientific_name=trim(scientific_name)>	
						
						<cfset cat_num = left(cat_item_sum, begPos-1)>
					<cfelse>
						<cfset cat_num = cat_item_sum>						
					</cfif>
					
					<cfif len(#link#) gt 0>
						<cfset cat_item = '<a href="#link#">#cat_num#</a>'>
					<cfelse>
						<cfset cat_item = cat_num>
					</cfif>

				<cfelseif #rel_type# is "collecting_event">		
					<cfset coll_event_id=#related_primary_key#>		
					
					<cfif len(#link#) gt 0>
						<cfset coll_event = '<a href="#link#">' & trim(summary) & '</a>'>
					<cfelse>
						<cfset coll_event =  trim(summary)>
					</cfif>
					 --->
				<cfif #rel# is "project">						
					<cfif len(#project_name#) gt 0>
						<cfset project = 'Project: <a href="/ProjectDetail.cfm?project_id=#rpkeys[i]#">' & project_name & '</a>'>
					</cfif>
					
				<cfelseif #rel# is "publication">
					<cfif len(#publication_name#) gt 0>
						<cfset publication = 'Publication: <a href="/SpecimenUsage.cfm?publication_id=#rpkeys[i]#">' & publication_name  & '</a>'>
					</cfif>
					

				<cfelseif #rel# is "shows locality">
					<cfif len(#shows_loc_name#) gt 0>
						<cfset shows_locality = 'Shows locality: <a href="/showLocality.cfm?action=srch&locality_id=#rpkeys[i]#">' & shows_loc_name & '</a>'>
					</cfif>
				
				<cfelseif #rel# is "taxonomy">
					<cfif len(#taxonomy_description#) gt 0>
						<cfset descr_taxonomy = 'Describes Taxonomy: <a href="/name/#taxonomy_description#">' & taxonomy_description & '</a>'>
					</cfif>
		
				</cfif>
				
				<cfset i= i +1>				
			</cfloop>		

			
<!--- 			<!-- If can't find a collecting event, try to find one through available cataloged item -->		
			<cfif len(coll_event) lte 0 and coll_obj_id gt 0>
				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select 
						higher_geog || ': ' || spec_locality || ' (' || verbatim_date || ')' data , collecting_event.collecting_event_id id
					from 
						collecting_event,
						locality, 
						geog_auth_rec,
						cataloged_item
					where 
						collecting_event.locality_id=locality.locality_id and
						locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
						collecting_event.collecting_event_id=cataloged_item.collecting_event_id and
						cataloged_item.collection_object_id=#coll_obj_id#
				</cfquery>
				
				
				
				<cfset coll_event_id=#d.id#>
				
				<cfif coll_event_id gt 0>
					
					<cfset coll_event_uri="/showLocality.cfm?action=srch&collecting_event_id=" & #d.id#>
					<cfset coll_event = '<a href="#coll_event_uri#">' & trim(d.data) & '</a>'>
					
				<cfelse>
					<cfset coll_event = trim(d.data)>
				</cfif>					
				
				

			</cfif>
								
			<!-- query lat/long for inputting to map -->
			<cfif coll_event_id gt 0>
				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select dec_lat, dec_long
					from collecting_event, lat_long
					where collecting_event.collecting_event_id=#coll_event_id#
						and collecting_event.locality_id=lat_long.locality_id
				</cfquery>
				
				<cfset dec_lat=#d.dec_lat#>
				<cfset dec_long=#d.dec_long#>
			</cfif> 
			--->

		</cfif>


		<!-- Orders the keywords -->
		<cfset kw_list = "#scientific_name#|#coll_event#|#description#|#agent_name#|#cat_item#|#project#|#publication#|#shows_locality#|#descr_taxonomy#">
		<cfloop list="#kw_list#" index="s" delimiters="|">
			<cfif len(trim(s)) gt 0>
				<cfif len(kw) gt 0>
					<cfset kw = kw & "; " & s>
				<cfelse>
					<cfset kw = s & "">						
				</cfif> 
			</cfif>
		</cfloop>
	
		<!--- 
		<!-- Set up/fill query table used for bulk downloading-->
		<cfset tempResult = queryaddrow(downloadResults,1)>
		<cfset tempResult = QuerySetCell(downloadResults, "scientific_name", "#scientific_name#", rownum)>
		<cfset tempResult = QuerySetCell(downloadResults, "agent_name", "#agent_name#", rownum)>
		<cfset tempResult = QuerySetCell(downloadResults, "locality", "#locality#", rownum)>
		<cfset tempResult = QuerySetCell(downloadResults, "description", "#description#", rownum)>
		--->
		
		<!-- Grid Display -->

		<td align="middle">

			<a href="#media_uri#" target="_blank"><img src="#mp#" alt="#alt#" style="max-width:100px;max-height:100px;"></a>
			<br>
			<span style = "font-size:small;">#media_type# (#mime_type#)</span>
		
		</td>

		<td align="middle">					
			<cfif len(dec_lat) gt 0 and len(dec_long) gt 0 and (dec_lat is not 0 and dec_long is not 0)>
				<cfset iu="http://maps.google.com/maps/api/staticmap?key=#application.gmap_api_key#&center=#dec_lat#,#dec_long#">
				<cfset iu=iu & "&markers=color:red|size:tiny|#dec_lat#,#dec_long#&sensor=false&size=100x100&zoom=2">
				<cfset iu=iu & "&maptype=roadmap">
				<a href="http://maps.google.com/maps?q=#dec_lat#,#dec_long#" target="_blank">
					<img src="#iu#" alt="Google Map">
				</a>
			</cfif>
		</td>
		#media_id#
		<td align="middle">							
			<div style="font-size:small;max-width:60em;margin-left:3em;border:1px solid black;padding:2px;text-align:justify;">
											
					<cfset labels_details="">
					<cfset i = 1>
					<cfloop list="#media_labels#" delimiters=";" index="label">
						<cfif (#label# is not "use policy") and (#label# is not "usage")>
							<cfif len(labels_details) gt 0>
								<cfset labels_details = labels_details & "; " & #mlabels[i]# & " = " & #lvalues[i]#>
							<cfelse>
								<cfset labels_details = #mlabels[i]# & " = " & #lvalues[i]#>
							</cfif>			
						</cfif>
					<cfset i = i +1>
					</cfloop>
										
					<cfloop list="#keyword#" index="k" delimiters=",;: ">
						<cfset kw=highlight(kw,k)>
						<cfset labels_details=highlight(labels_details,k)>
					</cfloop>
					
					#kw#
					<br>
					<br>
					#labels_details#
			</div>			
		
		<!-- Related Media -->
		<cfquery name="tag" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select count(*) n from tag where media_id=#media_id#
		</cfquery>
		<br>
		<cfif media_type is "multi-page document">	
			<a href="/document.cfm?media_id=#media_id#">[ view as document ]</a>
		</cfif>
		<cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
	        <a href="/media.cfm?action=edit&media_id=#media_id#">[ edit media ]</a>
	        <a href="/TAG.cfm?media_id=#media_id#">[ add or edit TAGs ]</a>
	    </cfif>
	    <cfif tag.n gt 0>
			<a href="/showTAG.cfm?media_id=#media_id#">[ View #tag.n# TAGs ]</a>
		</cfif>
		<cfquery name="relM" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				media.media_id, 
				media.media_type, 
				media.mime_type, 
				media.preview_uri, 
				media.media_uri 
			from 
				media, 
				media_relations 
			where 
				media.media_id=media_relations.related_primary_key and
				media_relationship like '% media' 
				and media_relations.media_id =#media_id#
				and media.media_id != #media_id#
			UNION
			select media.media_id, media.media_type,
				media.mime_type, media.preview_uri, media.media_uri 
			from media, media_relations 
			where 
				media.media_id=media_relations.media_id and
				media_relationship like '% media' and 
				media_relations.related_primary_key=#media_id#
				 and media.media_id != #media_id#
		</cfquery>
		<cfif relM.recordcount gt 0>
			<br>Related Media
			<div class="thumbs">
				<div class="thumb_spcr">&nbsp;</div>
				<cfloop query="relM">
					<cfset puri=getMediaPreview(preview_uri,media_type)>
	            	<cfquery name="labels"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select
							media_label,
							label_value
						from
							media_labels
						where
							media_id=#media_id#
					</cfquery>
					<cfquery name="desc" dbtype="query">
						select label_value from labels where media_label='description'
					</cfquery>
					<cfset alt="Media Preview Image">
					<cfif desc.recordcount is 1>
						<cfset alt=desc.label_value>
					</cfif>
	               <div class="one_thumb">
		               <a href="#media_uri#" target="_blank"><img src="#getMediaPreview(preview_uri,media_type)#" alt="#alt#" class="theThumb"></a>
	                   	<p>
							#media_type# (#mime_type#)
		                   	<br><a href="/media/#media_id#">Media Details</a>
							<br>#alt#
						</p>
					</div>
				</cfloop>
				<div class="thumb_spcr">&nbsp;</div>
			</div>
		</cfif>
		</td>
	</tr>
	<cfset rownum=rownum+1>
</cfloop>
</table>

<!---
<!-- try to kill any old tables that they may have laying around -->
<cftry>
	<cfquery name="die" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		drop table #session.MediaSrchTab#
	</cfquery>
	<cfcatch><!-- not there, so what? -->
	</cfcatch>
</cftry>
<!-- build a temp table -->

<cfset SqlString = "create table #session.MediaSrchTab# AS (Select * from #downloadResults#)">
<cfquery name="buildIt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preserveSingleQuotes(SqlString)#
</cfquery>
--->
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