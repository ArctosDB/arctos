<cfinclude template = "/includes/_frameHeader.cfm">
<cfoutput>
	<cfquery name="media" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	    select distinct 
	        media.media_id,
	        media.media_uri,
	        media.mime_type,
	        media.media_type,
	        media.preview_uri
	     from
	         media,
	         media_relations,
	         media_labels
	     where
	         media.media_id=media_relations.media_id and
	         media.media_id=media_labels.media_id (+) and
	         media_relations.media_relationship like '% project' and
	         media_relations.related_primary_key = #project_id#
	</cfquery>
	<cfif #media.recordcount# gt 0>
    	<h2>Media</h2>
		<div class="projMediaCell">
			<cfloop query="media">
            	<cfquery name="labels"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select
						media_label,
						label_value
					from
						media_labels
					where
						media_id=#media_id#
				</cfquery>
                <cfset mrel=getMediaRelations(#media_id#)>
               <div class="oneMedia">
	               <cfif len(#preview_uri#) gt 0>
	                   <a href="#media_uri#" target="_blank"><img src="#preview_uri#" alt="Media Preview Image"></a>
	                   <br>#media_type# (#mime_type#)
	               <cfelse>
	                   <cfset h=left(media_uri,40) & "...">
	                   <a href="#media_uri#" target="_blank">#h#</a>
	                   <br>#media_type# (#mime_type#)
	               </cfif>
                   <cfif #mrel.recordcount# gt 0>
						<br>Relations:
							<ul>
								<cfloop query="mrel">
									<li>#media_relationship#: #summary#
										<cfif len(#link#) gt 0>
					                        <a class="infoLink" href="#link#" target="_blank">More...</a>
					                    </cfif>
									</li>
								</cfloop>
							</ul>
					</cfif>
					<cfif #labels.recordcount# gt 0>
						<br>Labels:
						<ul>
							<cfloop query="labels">
								<li>#media_label#: #label_value#</li>
							</cfloop>
						</ul>
					</cfif>
				</div>
			</cfloop>
		</div>
	</cfif>
</cfoutput>