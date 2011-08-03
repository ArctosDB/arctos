<cfset title="Media">
<cfset metaDesc="Locate Media, including audio (sound recordings), video (movies), and images (pictures) of specimens, collecting sites, habitat, collectors, and more.">
<div id="_header">
    <cfinclude template="/includes/_header.cfm">
</div>
<cfif isdefined("url.collection_object_id")>
    <cfoutput>
    	<cflocation url="MediaSearch.cfm?action=search&relationship__1=cataloged_item&related_primary_key__1=#url.collection_object_id#" addtoken="false">
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
        <a href="/media.cfm?action=newMedia">[ Create media ]</a>
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
<cfoutput>
	<cfset mediaFlatTableName="t_media_flat">
	
	<cfset sql = "SELECT * FROM #mediaFlatTableName# ">
	<cfset whr ="WHERE #mediaFlatTableName#.mime_type != 'image/dng' ">
	<cfset srch=" ">
	<cfset mapurl = "">
	<cfset terms="">
	<cfinclude template="MediaSearchSql.cfm">
	<cfset ssql="#sql# #whr# #srch# order by media_id">
	<cfquery name="findIDs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		#preservesinglequotes(ssql)#
	</cfquery>
	
	<table border><tr>
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
		<td><a href="/development/MediaSearch.cfm">[ Media Search ]</a></td>
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
		<td><a href="#h#">[ Create media ]</a></td>
	</cfif>
	
	
	<td>
	<form name="dlm" method="post" action="/bnhmMaps/bnhmMapMediaData.cfm">
	<input type="hidden" name="ssql" value="#ssql#">
	<input type="submit" class="lnkBtn" value="BerkeleyMapper">
</form>
	</td>
	<td>
	<form name="dlm" method="post" action="MediaSearchDownload.cfm">
	<input type="hidden" name="ssql" value="#ssql#">
	<input type="submit"  class="lnkBtn" value="Download">
</form>
	</td>
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
				<cfset Total_Pages=ceiling(Total_Records/Result_Per_Page)> 
				<!---
				<cfif URL.offset gt 10*Result_Per_Page>
					<cfset prev_link=URL.offset-1-(10*Result_Per_Page)> 
					<a href="#cgi.script_name#?offset=#prev_link#&#q#">PREV 10</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				</cfif>
				--->
				<cfif URL.offset GT Result_Per_Page> 
					<cfset prev_link=URL.offset-Result_Per_Page-1> 
					<a href="#cgi.script_name#?offset=#prev_link#&#q#">&lt;&lt;PREV</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
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
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="#cgi.script_name#?offset=#next_link#&#q#">NEXT>></a>
				</cfif>
				<!---
				<cfif end_page lt Total_Pages>
					<cfset next_link=(end_page*Result_Per_Page)> 
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="#cgi.script_name#?offset=#next_link#&#q#">NEXT #Result_Per_Page#</a>
				</cfif>
				--->
			</cfif>
		</div>
		</cfif>
	</cfsavecontent>
	
	
	<!---
	<cfquery name="mappable" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(distinct(media_id)) cnt from #session.MediaSrchTab# where lat_long is not null
	</cfquery>

	<cfif isdefined("session.ShowObservations") AND session.ShowObservations is true>
		<cfset mapurl = "#mapurl#&ShowObservations=#session.ShowObservations#">
	</cfif>
	<strong>#mappable.cnt#</strong> of these <strong>#findIDs.recordcount#</strong> records have coordinates and can be displayed with 
	<span class="controlButton"
		onclick="window.open('/bnhmMaps/bnhmMapMediaData.cfm?#mapurl#','_blank');">BerkeleyMapper</span>
		
	
	<span class="controlButton"
		onclick="saveSearch('#Application.ServerRootUrl#/development/MediaSearch.cfm?action=search#mapURL#');">Save&nbsp;Search</span>
	---->
	<br>
	#pager#
				
	<cfset rownum=1>
	<cfif url.offset is 0><cfset url.offset=1></cfif>

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
			<!---	
			
						<div style="font-size:smaller;max-width:60em;margin-left:3em;border:1px solid black;padding:2px;text-align:justify;">

			</div>

	
			<div style="color:green;font-size:small;max-width:60em;margin-left:3em;border:1px solid black;padding:2px;text-align:justify;">
				#keywords#
			</div>
			---->
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
<!---
		<br>Related Media
		<cfif len(relMedia) gt 0>
			<cfquery name="rel" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select
					media_id,
					media_uri,
					media_type,
					preview_uri,
					mime_type
				from
					media
				where
					media_id in (#relMedia#)
			</cfquery>
			<div class="thumbs">
				<div class="thumb_spcr">&nbsp;</div>
				<cfloop query="rel">
					<div class="one_thumb">
		               <a href="#media_uri#" target="_blank"><img style="max-width:75px;max-height:75px;" src="#getMediaPreview(preview_uri,media_type)#" alt="[ related media ]" class="theThumb"></a>
		               	<p>
							#media_type# (#mime_type#)
		                   	<br><a href="/media/#media_id#">Media Details</a>
						</p>
					</div>
				</cfloop>
				<div class="thumb_spcr">&nbsp;</div>
			</div>
		</cfif>
		
		--->
		</td>
	</tr>
	
	<!---
	<cfset rownum=rownum+1>
=======
	
	
	
	

	<tr #iif(rownum MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>


		<td align="middle">

			<a href="#media_uri#" target="_blank"><img src="#mp#" alt="#alt#" style="max-width:100px;max-height:100px;"></a>
			<br>
			<span style = "font-size:small;">#media_type# (#mime_type#)</span>
		
		</td>

		<td align="middle">					
			<!---
			<cfif len(dec_lat) gt 0 and len(dec_long) gt 0 and (dec_lat is not 0 and dec_long is not 0)>
				<cfset iu="http://maps.google.com/maps/api/staticmap?key=#application.gmap_api_key#&center=#dec_lat#,#dec_long#">
				<cfset iu=iu & "&markers=color:red|size:tiny|#dec_lat#,#dec_long#&sensor=false&size=100x100&zoom=2">
				<cfset iu=iu & "&maptype=roadmap">
				<a href="http://maps.google.com/maps?q=#dec_lat#,#dec_long#" target="_blank">
					<img src="#iu#" alt="Google Map">
				</a>
			</cfif>
			--->
			mappy
		</td>
		
		<td align="middle">							
			<div style="font-size:small;max-width:60em;margin-left:3em;border:1px solid black;padding:2px;text-align:justify;">
											
					<!---
					<cfset labels_details="">
					<cfset j = 1>
					<cfloop list="#media_labels#" delimiters=";" index="label">
						<cfset label = trim(#label#)>
						<cfif (#label# is not "use policy") and (#label# is not "usage") and (#label# is not "description")>
							<cfif len(labels_details) gt 0>
								<cfset labels_details = labels_details & "<br>" & #mlabels[j]# & " = " & #lvalues[j]#>
							<cfelse>
								<cfset labels_details = #mlabels[j]# & " = " & #lvalues[j]#>
							</cfif>			
						</cfif>
					<cfset j = j +1>
					</cfloop>
									
					<cfloop list="#terms#" index="k" delimiters=",;: ">
						<cfset top_text=highlight(top_text,k)>
						<cfset bottom_text=highlight(bottom_text,k)>
						<cfset labels_details=highlight(labels_details,k)>
					</cfloop>
					
					<cfif len(#top_text#) gt 0>
						<cfset top_text = replace(top_text, '@@', '<a href="http://arctos-test.arctos.database.museum/name/#scientific_name#">', "all")>
						<cfset top_text = replace(top_text, '**', '</a>', "all")>
						#top_text#						
						<br>
						<br>	
					</cfif>
					
					<cfif len(#bottom_text#) gt 0>
						#bottom_text#						
						<br>
					</cfif>
					#labels_details#
					
					--->
					
					bla bla bla labels & etc
			</div>			
		
		<!-- Related Media -->
		
		<br>
		<cfif media_type is "multi-page document">	
			<a href="/document.cfm?media_id=#media_id#">[ view as document ]</a>
		</cfif>
		<cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
	        <a href="/media.cfm?action=edit&media_id=#media_id#">[ edit media ]</a>
	        <a href="/TAG.cfm?media_id=#media_id#">[ add or edit TAGs ]</a>
	    </cfif>
	    <!---
	    hasTag
	    
	    <cfif tag.n gt 0>
			<a href="/showTAG.cfm?media_id=#media_id#">[ View #tag.n# TAGs ]</a>
		</cfif>
		
		--->
		<!--- wtff?
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
		--->
			<br>Related Media
			<!---
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
		---->
		</td>
	</tr>
	<cfset rownum=rownum+1>
>>>>>>> .r17930

	---->
	<!---
	<cfset rpkeys = ListToArray(related_primary_keys, ";")>

	<cfset mlabels = ListToArray(media_labels, ";")>
	<cfset lvalues = ListToArray(label_values, ";")>
		
	<cfset media_details_url = "/media/" & "" & #media_id#>											
	<cfset agent_name="#created_agent#">	

	<!-- Cataloged item information -->
	<cfset sci_name="#scientific_name#">	
	<cfif len(sci_name) gt 0>
		<cfset sci_name = '@@#sci_name#**'>
	</cfif>
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
	<cfset project="">			
	<cfset publication="">			
	<cfset shows_locality="">				
	<cfset descr_taxonomy="">
	<cfset shows_agent="">
	
	<cfset kw="">
	
	<cfset description="">
	<cfset desc_i = listContains(media_labels, "description", ";")>
	<cfif desc_i gt 0>
		<cfset description="description = #lvalues[desc_i]#">
	</cfif>

	<cfset alt="#media_uri#">
	
	<cfif findIDs.recordcount is 1>		
		<cfset alt=description>
		
		<cfset title = description>
		<cfset metaDesc = "#description# for #media_type# (#mime_type#)">
	</cfif>

	<tr #iif(rownum MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>

		<cfset top_text="">
		<cfset del = "">
		
		<cfif len(coll_event) gt 0>
			<cfset coll_event='<a href="/showLocality.cfm?action=srch&collecting_event_id=#coll_event_id#">#coll_event#</a>'>

			<cfset top_text=top_text & del & coll_event>
			<cfset del="; ">
		</cfif>
		
		<cfif len(created_agent) gt 0>
			<cfset top_text=top_text & del & created_agent>
			<cfset del="; ">
		</cfif>
		
		<cfif len(cat_item) gt 0>
			<cfset cat_item = '<a href="/guid/#guid_string#">#cat_item#</a>'>
			
			<cfset top_text=top_text & del & cat_item>
			<cfset del="; ">
		</cfif>
		



		<cfset i = 1>		
		<cfloop list="#media_relationships#" delimiters=";" index="rel">
			<cfset rel = trim(#rel#)>
			<cfif findNoCase("project", #rel#) gt 0>						
				<cfif len(#project_name#) gt 0>
					<cfset project = 'associated with project = <a href="/ProjectDetail.cfm?project_id=#rpkeys[i]#">' & project_name & '</a>'>
				</cfif>
				
			<cfelseif findNoCase("publications", #rel#) gt 0>
				<cfif len(#publication_name#) gt 0>
					<cfset publication = 'shows publication = <a href="/SpecimenUsage.cfm?publication_id=#rpkeys[i]#">' & publication_name  & '</a>'>
				</cfif>
				

			<cfelseif findNoCase("locality", #rel#) gt 0>
				<cfif len(#shows_loc_name#) gt 0>
					<cfset shows_locality = 'shows locality = <a href="/showLocality.cfm?action=srch&locality_id=#rpkeys[i]#">' & shows_loc_name & '</a>'>
				</cfif>
			
			<cfelseif findNoCase("taxonomy", #rel#) gt 0>
				<cfif len(#taxonomy_description#) gt 0>
					<cfset descr_taxonomy = 'describes taxonomy = <a href="/name/#taxonomy_description#">' & taxonomy_description & '</a>'>
				</cfif>
					
			<cfelseif findNoCase("shows agent", #rel#) gt 0>
			
				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select agent_name from preferred_agent_name where agent_id=#rpkeys[i]#
				</cfquery>
				<cfif len(#d.agent_name#) gt 0>
					<cfset shows_agent = 'shows agent = ' & d.agent_name>
				</cfif>		
			</cfif>
			
			<cfset i= i +1>				
		</cfloop>		


<!--- 
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
		 --->
	 	<cfset bottom_text="">
	 	<cfset bottom_text_list="">
	 	<cfif len(sci_name) gt 0>
		 	<cfset top_text = "#sci_name#; #top_text#">
			<cfset bottom_text_list = "#description#|#project#|#publication#|#shows_locality#|#descr_taxonomy#|#shows_agent#">
		<cfelse>		
			<cfset bottom_text_list = "#sci_name#|#description#|#project#|#publication#|#shows_locality#|#descr_taxonomy#|#shows_agent#">
		</cfif>
		
 		<cfloop list="#bottom_text_list#" index="s" delimiters="|">
			<cfif len(trim(s)) gt 0>
				<cfif len(bottom_text) gt 0>
					<cfset bottom_text = bottom_text & "<br>" & s>
				<cfelse>
					<cfset bottom_text = s & "">						
				</cfif> 
			</cfif>
		</cfloop>
		
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
		
		<td align="middle">							
			<div style="font-size:small;max-width:60em;margin-left:3em;border:1px solid black;padding:2px;text-align:justify;">
											
					<cfset labels_details="">
					<cfset j = 1>
					<cfloop list="#media_labels#" delimiters=";" index="label">
						<cfset label = trim(#label#)>
						<cfif (#label# is not "use policy") and (#label# is not "usage") and (#label# is not "description")>
							<cfif len(labels_details) gt 0>
								<cfset labels_details = labels_details & "<br>" & #mlabels[j]# & " = " & #lvalues[j]#>
							<cfelse>
								<cfset labels_details = #mlabels[j]# & " = " & #lvalues[j]#>
							</cfif>			
						</cfif>
					<cfset j = j +1>
					</cfloop>
									
					<cfloop list="#terms#" index="k" delimiters=",;: ">
						<cfset top_text=highlight(top_text,k)>
						<cfset bottom_text=highlight(bottom_text,k)>
						<cfset labels_details=highlight(labels_details,k)>
					</cfloop>
					
					<cfif len(#top_text#) gt 0>
						<cfset top_text = replace(top_text, '@@', '<a href="http://arctos-test.arctos.database.museum/name/#scientific_name#">', "all")>
						<cfset top_text = replace(top_text, '**', '</a>', "all")>
						#top_text#						
						<br>
						<br>	
					</cfif>
					
					<cfif len(#bottom_text#) gt 0>
						#bottom_text#						
						<br>
					</cfif>
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
	
	---->
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