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
<script type='text/javascript' src='/includes/media.js'></script>
<!----------------------------------------------------------------------------------------->
<cfif action is "search">
<cfoutput>
	<cfif srchType is "key">
		<cfset sel="select distinct media.media_id,media.media_uri,media.mime_type,media.media_type,media.preview_uri "> 
		<cfset frm="from media">			
		<cfset whr=" where media.media_id > 0">
		<cfset srch=" ">
		<cfif isdefined("keywords") and len(keywords) gt 0>
			<cfset frm="#frm#,media_keywords">
			<cfset whr="#whr# and media.media_id=media_keywords.media_id">
			<cfset srch="#srch# AND upper(keyword) like '%#ucase(keywords)#%'">
		</cfif>
		<cfset ssql="#sel# #frm# #whr# #srch#">
		<cfquery name="findIDs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(ssql)#
		</cfquery>
		
	<cfelse>
		<cfset sel="select distinct media.media_id,media.media_uri,media.mime_type,media.media_type,media.preview_uri "> 
		<cfset frm="from media">			
		<cfset whr=" where media.media_id > 0">
		<cfset srch=" ">
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
				<cfset srch="#srch# AND upper(media_relation_summary(media_relations#n#.media_relations_id)) like '%#ucase(thisRelatedItem)#%'">
			</cfif>
		    <cfif len(#thisRelatedKey#) gt 0>
				<cfset srch="#srch# AND media_relations#n#.related_primary_key = #thisRelatedKey#">
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
				<cfset frm="#frm#,media_labels media_labels#n#">
			    <cfset whr="#whr# and media.media_id=media_labels#n#.media_id (+)">
		        <cfif len(#thisLabel#) gt 0>
					<cfset srch="#srch# AND media_labels#n#.media_label = '#thisLabel#'">
				</cfif>
				<cfif len(#thisLabelValue#) gt 0>
					<cfset srch="#srch# AND upper(media_labels#n#.label_value) like '%#ucase(thisLabelValue)#%'">
				</cfif>
			</cfloop>
		<cfif len(srch) is 0>
			<div class="error">You must enter search criteria.</div>
			<cfabort>
		</cfif>
		<cfset ssql="#sel# #frm# #whr# #srch#">
		<cfquery name="findIDs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(ssql)#
		</cfquery>
	</cfif><!--- end srchType --->

<cfif findIDs.recordcount is 0>
	<div class="error">Nothing found.</div>
<cfelseif findIDs.recordcount is 1 and not listfindnocase(cgi.REDIRECT_URL,'media',"/")>
	<cfheader statuscode="301" statustext="Moved permanently">
	<cfheader name="Location" value="/media/#findIDs.media_id#">
<cfelse>
	<cfset title="Media Results: #findIDs.recordcount# records found">
	<cfset metaDesc="Results of Media search: Multiple records found.">
</cfif>
<table>
<cfset r=1>
<cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
    <cfset h="/media.cfm?action=newMedia">
	<cfif isdefined("url.relationship__1") and isdefined("url.related_primary_key__1")>
		<cfif url.relationship__1 is "cataloged_item">
			<cfset h=h & '&collection_object_id=#url.related_primary_key__1#'>
			( find Media and pick an item to link to existing Media )
			<br>
		</cfif>
	</cfif>
	<a href="#h#">Create media</a>
</cfif>
<cfloop query="findIDs">
	<cfquery name="labels_raw"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
			media_label,
			label_value,
			agent_name
		from
			media_labels,
			preferred_agent_name
		where
			media_labels.assigned_by_agent_id=preferred_agent_name.agent_id (+) and
			media_id=#media_id#
	</cfquery>
	<cfquery name="labels" dbtype="query">
		select media_label,label_value from labels_raw where media_label != 'description'
	</cfquery>
	<cfquery name="desc" dbtype="query">
		select label_value from labels_raw where media_label='description'
	</cfquery>
	<cfset alt="#media_uri#">
	<cfif desc.recordcount is 1>
		<cfif findIDs.recordcount is 1>
			<cfset title = desc.label_value>
			<cfset metaDesc = "#desc.label_value# for #media_type# (#mime_type#)">
		</cfif>
		<cfset alt=desc.label_value>
	</cfif>
	<tr #iif(r MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
		<td>
			<cfset mp=getMediaPreview(preview_uri,media_type)>
            <table>
				<tr>
					<td align="middle">
						<a href="#media_uri#" target="_blank"><img src="#mp#" alt="#alt#"></a>
						<br><span style='font-size:small'>#media_type#&nbsp;(#mime_type#)</span>
					</td>
					<td>
						<cfif len(desc.label_value) gt 0>
							<ul><li>#desc.label_value#</li></ul>
						</cfif>
						<cfif labels.recordcount gt 0>
							<ul>
								<cfloop query="labels">
									<li>
										#media_label#: #label_value#
									</li>
								</cfloop>
							</ul>
						</cfif>
						
						<cfset mrel=getMediaRelations(#media_id#)>
						<cfif mrel.recordcount gt 0>
							<ul>
							<cfloop query="mrel">
								<li>#media_relationship#  
				                    <cfif len(#link#) gt 0>
				                        <a href="#link#" target="_blank">#summary#</a>
				                    <cfelse>
										#summary#
									</cfif>
				                </li>
							</cfloop>
							</ul>
						</cfif>
					</td>
				</tr>
			</table>
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
	<cfset r=r+1>
</cfloop>
</table>
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------------->
<cfif #action# is "nothing">
	<cfoutput>
    <cfquery name="ctmedia_relationship" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select media_relationship from ctmedia_relationship order by media_relationship
	</cfquery>
	<cfquery name="ctmedia_label" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select media_label from ctmedia_label order by media_label
	</cfquery>
	<cfquery name="ctmedia_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select media_type from ctmedia_type order by media_type
	</cfquery>
	<cfquery name="ctmime_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select mime_type from ctmime_type order by mime_type
	</cfquery>
	Search for Media 
	<form name="newMedia" method="post" action="">
		<input type="hidden" name="action" value="search">
		<input type="hidden" name="srchType" value="key">
		<label for="keyword">Keyword</label>
		<input type="text" name="keyword" id="keyword">
		
		<br>
		<input type="submit" 
			value="Find Media" 
			class="insBtn"
			onmouseover="this.className='insBtn btnhov'" 
			onmouseout="this.className='insBtn'">
	</form>
	<hr>
	
    <cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
        OR <a href="/media.cfm?action=newMedia">Create media</a>
    </cfif>
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
				class="insBtn"
				onmouseover="this.className='insBtn btnhov'" 
				onmouseout="this.className='insBtn'">
		</form>
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