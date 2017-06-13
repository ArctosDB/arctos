<cfinclude template="/includes/_header.cfm">
<style>
	@media screen{
    .tbl{display:table;}
	.tbl-row{display:table-row;}
    .tbl-cell{display:table-cell;vertical-align: top;}
	}
    @media (max-width: 600px) {
    .tbl{display:block;}
    .tbl-row{display:block}
    .tbl-cell{display:block}
}
</style>
<cfoutput>
	<cfif not isdefined("media_id")>
		Noid<cfabort>
	</cfif>
	<cfset  func = CreateObject("component","component.functions")>
	<cfquery name="findIDs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			media_flat.media_id,
			media_flat.media_uri,
			media_flat.mime_type,
			media_flat.media_type,
			media_flat.preview_uri,
			media_flat.descr,
			media_flat.alt_text,
			media_flat.license,
			doi
		from
			media_flat,
			ctmedia_license,
			doi
		where
			media_flat.media_id=doi.media_id (+) and
			media_flat.media_id = #media_id#
	 </cfquery>
	<cfif findIDs.recordcount is 0>
		notfound<cfabort>
	</cfif>
	<cfif isdefined("open") and open is not false>
		<cfset  utils = CreateObject("component","component.utilities")>
		<cfset x=utils.exitLink(target=URLEncodedFormat(findIDs.media_uri))>
		<cfif x.code is "200">
			<cfheader statuscode="303" statustext="Redirecting to external resource">
			<cfheader name="Location" value="#x.http_target#">
		<cfelse>
			<cfheader statuscode="#x.code#" statustext="#x.msg#">
			<cftry>
				<cfhtmlhead text='<title>An external resource is not responding properly</title>'>
				<cfcatch type="template"></cfcatch>
			</cftry>
			<div style="border:4px solid red; padding:1em;margin:1em;">
				There may be a problem with the linked resource.
				<p>
					Status: #x.code# #x.msg#
				</p>
				<p>
					Click the following link(s) to attempt to load the resource manually.
				</p>
				<p>
					Please <a href="/contact.cfm?ref=#findIDs.media_uri#">contact us</a> if you experience additional problems with the link.
				</p>
				<p>Link as provided: <a href="#findIDs.media_uri#">#findIDs.media_uri#</a></p>
				<cfif x.http_target is not findIDs.media_uri>
					<br>Or our guess at the intended link: <a href="#x.http_target#">#x.http_target#</a>
				</cfif>
			</div>
		</cfif>
		<cfabort>
	</cfif>
<cftry>
	<div class="tbl" style="width:100%;">
		<div class="tbl-row">
			  <cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
			  	<cfset h="/media.cfm?action=newMedia">
		        <cfif isdefined("url.relationship__1") and isdefined("url.related_primary_key__1")>
		        	<cfif url.relationship__1 is "cataloged_item">
		            	<cfset h=h & '&collection_object_id=#url.related_primary_key__1#'>
		                ( find Media and pick an item to link to existing Media )<br>
		            </cfif>
				</cfif>
				<div class="tbl-cell">
					<a href="#h#">[ Create media ]</a>
				</div>
			</cfif>
			<div class="tbl-cell" style="text-align:right;">
				<div id="annotateSpace">
					<cfquery name="existingAnnotations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select
							decode(REVIEWER_AGENT_ID,NULL,0,1) isreviewed,
							count(*) cnt
						from
							annotations
						where
							media_id = #media_id#
						group by
							decode(REVIEWER_AGENT_ID,NULL,0,1)
					</cfquery>
					<cfquery name="ra" dbtype="query">
						select sum(cnt) c from existingAnnotations where isreviewed=1
					</cfquery>
					<cfquery name="ua" dbtype="query">
						select sum(cnt) c from existingAnnotations where isreviewed=0
					</cfquery>
					<cfif len(ra.c) is 0>
						<cfset gac=0>
					<cfelse>
						<cfset gac=ra.c>
					</cfif>
					<cfif len(ua.c) is 0>
						<cfset bac=0>
					<cfelse>
						<cfset bac=ua.c>
					</cfif>
					<button type="button" onclick="openAnnotation('media_id=#media_id#')" class="annobtn">
						<span class="abt">Report Bad Data&nbsp;<span class="gdAnnoCt">[#gac#]</span><span class="badAnnoCt">[#bac#]</span>
					</button>
				</div>
			</div>
		</div>
	</div>

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
        <cfset alt=findIDs.alt_text>
			<cfset title = findIDs.descr>
            <cfset alt=findIDs.alt_text>
        <cfinvoke component="/component/functions" method="getMediaPreview" returnVariable="mp">
			<cfinvokeargument name="preview_uri" value="#findIDs.preview_uri#">
			<cfinvokeargument name="media_type" value="#findIDs.media_type#">
		</cfinvoke>
		<cfquery name="coord"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select coordinates from media_flat where coordinates is not null and media_id=#media_id#
		</cfquery>






		<div class="tbl">
		  <div class="tbl-row">
			  <div class="tbl-cell">
                    <cfif findIDs.mime_type is "audio/mpeg3">
                        <br>
                        <audio controls>
                            <source src="#findIDs.media_uri#" type="audio/mp3">
                            <a href="/media/#findIDs.media_id#?open" target="_blank">
                                <img src="#mp#" alt="#alt#" style="max-width:250px;max-height:250px;">
                            </a>
                        </audio>
                    <cfelse>
                        <a href="/media/#findIDs.media_id#?open" target="_blank">
                            <img src="#mp#" alt="#alt#" style="max-width:250px;max-height:250px;">
                        </a>
                    </cfif>
                    <br>
                    <span style='font-size:small'>#findIDs.media_type#&nbsp;(#findIDs.mime_type#)</span>
                    <cfif len(findIDs.license) gt 0>
                        <br>
                        <span style='font-size:small'>#findIDs.license#</span>
                    <cfelse>
                        <br><span style='font-size:small'>unlicensed</span>
                    </cfif>

                </div>
                <div class="tbl-cell">
                    <cfif coord.recordcount is 1>
                        <cfinvoke component="component.functions" method="getMap" returnvariable="contents">
                            <cfinvokeargument name="media_id" value="#media_id#">
                            <cfinvokeargument name="size" value="100x100">
                        </cfinvoke>
                        #contents#
                    </cfif>
                </div>
                <div class="tbl-cell">
                    <cfif len(findIDs.doi) gt 0>
                        <ul><li>DOI: #findIDs.doi#</li></ul>
                    <cfelse>
                        <cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>
                            <ul><li><a href="/tools/doi.cfm?media_id=#media_id#">get a DOI</a></li></ul>
                        </cfif>
                    </cfif>
                    <cfif len(findIDs.descr) gt 0>
                        <ul><li>#findIDs.descr#</li></ul>
                    </cfif>
                    <cfif labels.recordcount gt 0>
                        <ul>
                            <cfloop query="labels">
                                <li>#media_label#: #label_value#</li>
                            </cfloop>
                        </ul>
                    </cfif>
                    <cfset mrel=func.getMediaRelations(findIDs.media_id)>
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
                </div>
            </div>
             <div class="tbl-row">
                <div class="tbl-cell">
                    <cfquery name="tag" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
                        select count(*) n from tag where media_id=#media_id#
                    </cfquery>
                    <cfif findIDs.media_type is "multi-page document">
                        <a href="/document.cfm?media_id=#findIDs.media_id#">[ view as document ]</a>
                    </cfif>
                    <cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
                        <a href="/media.cfm?action=edit&media_id=#media_id#">[ edit media ]</a>
                        <div class="nowrap">
							<a href="/TAG.cfm?media_id=#media_id#">[ add or edit TAGs ]</a>
						</div>
                    </cfif>
                    <cfif tag.n gt 0>
                        <a href="/showTAG.cfm?media_id=#media_id#">[ View #tag.n# TAGs ]</a>
                    </cfif>
               </div>
            </div>
            <cfquery name="relM" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
                select
                    media_flat.media_id,
                    media_flat.media_type,
                    media_flat.mime_type,
                    media_flat.preview_uri,
                    media_flat.media_uri,
                    media_flat.descr,
                    media_flat.alt_text
                from
                    media_flat,
                    media_relations
                where
                    media_flat.media_id=media_relations.related_primary_key and
                    media_relationship like '% media'
                    and media_relations.media_id =#media_id#
                    and media_flat.media_id != #media_id#
                    UNION
                    select media_flat.media_id, media_flat.media_type,
                    media_flat.mime_type, media_flat.preview_uri, media_flat.media_uri,media_flat.descr,
                    media_flat.alt_text
                    from media_flat, media_relations
                    where
                    media_flat.media_id=media_relations.media_id and
                    media_relationship like '% media' and
                    media_relations.related_primary_key=#media_id#
                    and media_flat.media_id != #media_id#
            </cfquery>
            <div class="tbl-row">
                <div class="tbl-cell">
                <cfif relM.recordcount gt 0>
                    <br>Related Media
                    <div class="thumbs">
                        <div class="thumb_spcr">&nbsp;</div>
                            <cfloop query="relM">
                                <cfinvoke component="/component/functions" method="getMediaPreview" returnVariable="puri">
                                    <cfinvokeargument name="preview_uri" value="#preview_uri#">
                                    <cfinvokeargument name="media_type" value="#media_type#">
                                </cfinvoke>
                                <div class="one_thumb">
                                    <a href="/media/#media_id#?open" target="_blank"><img src="#puri#" alt="#alt#" class="theThumb"></a>
                                    <p>
                                        #media_type# (#mime_type#)
                                        <br><a href="/media/#media_id#">Media Details</a>
                                        <br>#alt_text#
                                    </p>
                                </div>
                            </cfloop>
                            <div class="thumb_spcr">&nbsp;</div>
                        </div>
                    </div>
                </cfif>
            </div>
        </div>
    </div>
<cfcatch>
<cfdump var=#cfcatch#>
</cfcatch>
</cftry>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">