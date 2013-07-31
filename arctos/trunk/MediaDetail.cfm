<cfinclude template="/includes/_header.cfm">
<script type="text/javascript" src="http://webplayer.yahooapis.com/player.js"></script>
<cfoutput>
	<cfset stuffToNotPlay="audio/x-wav">
	<cfquery name="findIDs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			media.media_id,
			media.media_uri,
			media.mime_type,
			media.media_type,
			media.preview_uri,
			ctmedia_license.uri,
			ctmedia_license.display,
			doi
		from
			media,
			ctmedia_license,
			doi
		where
			media.media_license_id=ctmedia_license.media_license_id (+) and
			media.media_id=doi.media_id (+) and
			media.media_id = #media_id#
	  </cfquery>
	  <cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
	  	<cfset h="/media.cfm?action=newMedia">
        <cfif isdefined("url.relationship__1") and isdefined("url.related_primary_key__1")>
        	<cfif url.relationship__1 is "cataloged_item">
            	<cfset h=h & '&collection_object_id=#url.related_primary_key__1#'>
                ( find Media and pick an item to link to existing Media )<br>
            </cfif>
		</cfif>
		<a href="#h#">[ Create media ]</a>
	</cfif>
	<cfquery name="labels_raw"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
        <cfset alt="#findIDs.media_uri#">
        <cfif desc.recordcount is 1 and findIDs.recordcount is 1>
			<cfset title = desc.label_value>
            <cfset alt=desc.label_value>
        </cfif>
        <cfinvoke component="/component/functions" method="getMediaPreview" returnVariable="mp">
			<cfinvokeargument name="preview_uri" value="#findIDs.preview_uri#">
			<cfinvokeargument name="media_type" value="#findIDs.media_type#">
		</cfinvoke>
		<cfset addThisClass=''>
		<cfif listfind(stuffToNotPlay,findIDs.mime_type)>
			<cfset addThisClass="noplay">
		</cfif>
		<cfquery name="coord"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select coordinates from media_flat where coordinates is not null and media_id=#media_id#
		</cfquery>
        <table>
			<tr>
				<td align="middle">
					<a class="#addThisClass#" href="#findIDs.media_uri#" target="_blank">
						<img src="#mp#" alt="#alt#" style="max-width:250px;max-height:250px;">
					</a>
					<br>
					<span style='font-size:small'>#findIDs.media_type#&nbsp;(#findIDs.mime_type#)</span>
					<cfif len(findIDs.display) gt 0>
						<br>
						<span style='font-size:small'>License: <a href="#findIDs.uri#" target="_blank" class="external">#findIDs.display#</a></span>
					<cfelse>
						<br><span style='font-size:small'>unlicensed</span>
					</cfif>
				</td>
				<td>
					<cfif coord.recordcount is 1>
						<cfinvoke component="component.functions" method="getMap" returnvariable="contents">
							<cfinvokeargument name="media_id" value="#media_id#">
							<cfinvokeargument name="size" value="100x100">
						</cfinvoke>
						#contents#
					</cfif>
				</td>
				<td>
					<cfif len(findIDs.doi) gt 0>
						<ul><li>DOI: #findIDs.doi#</li></ul>
					<cfelse>
						<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>
							<ul><li><a href="/tools/doi.cfm?media_id=#media_id#">get a DOI</a></li></ul>
						</cfif>
					</cfif>
					<cfif len(desc.label_value) gt 0>
						<ul><li>#desc.label_value#</li></ul>
					</cfif>
					<cfif labels.recordcount gt 0>
						<ul>
							<cfloop query="labels">
								<li>#media_label#: #label_value#</li>
							</cfloop>
						</ul>
					</cfif>
					<cfset mrel=getMediaRelations(findIDs.media_id)>
					<cfif mrel.recordcount gt 0>
						<ul>
						<cfloop query="mrel">
							<li>
								#media_relationship#
								<cfif len(link) gt 0>
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
			<tr>
				<td colspan="3" align="center">
					<cfquery name="tag" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select count(*) n from tag where media_id=#media_id#
					</cfquery>
					<cfif findIDs.media_type is "multi-page document">
						<a href="/document.cfm?media_id=#findIDs.media_id#">[ view as document ]</a>
					</cfif>
					<cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
						<a href="/media.cfm?action=edit&media_id=#media_id#">[ edit media ]</a>
						<a href="/TAG.cfm?media_id=#media_id#">[ add or edit TAGs ]</a>
					</cfif>
					<cfif tag.n gt 0>
						<a href="/showTAG.cfm?media_id=#media_id#">[ View #tag.n# TAGs ]</a>
					</cfif>
				</td>
			</tr>
			<cfquery name="relM" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
			<tr>
				<td colspan="3">
				<cfif relM.recordcount gt 0>
					<br>Related Media
					<div class="thumbs">
						<div class="thumb_spcr">&nbsp;</div>
							<cfloop query="relM">
								<cfinvoke component="/component/functions" method="getMediaPreview" returnVariable="puri">
									<cfinvokeargument name="preview_uri" value="#preview_uri#">
									<cfinvokeargument name="media_type" value="#media_type#">
								</cfinvoke>
								<cfset addThisClass=''>
								<cfif listfind(stuffToNotPlay,mime_type)>
									<cfset addThisClass="noplay">
								</cfif>
								<cfquery name="labels"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
									<a href="#media_uri#" class="#addThisClass#" target="_blank"><img src="#puri#" alt="#alt#" class="theThumb"></a>
									<p>
										#media_type# (#mime_type#)
										<br><a href="/media/#media_id#">Media Details</a>
										<br>#alt#
									</p>
								</div>
							</cfloop>
							<div class="thumb_spcr">&nbsp;</div>
						</div>
					</div>
				</cfif>
			</td>
		</tr>
	</table>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">