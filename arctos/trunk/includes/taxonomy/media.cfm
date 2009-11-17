<cfinclude template = "/includes/functionLib.cfm">
<cfoutput>
	<cfquery name="media" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	    select * from (
		    select  
		        media.media_id,
		        media.media_uri,
		        media.mime_type,
		        media.media_type,
		        media.preview_uri
		     from
		         media,
		         media_relations,
		         identification,
		         identification_taxonomy
		     where
		         media.media_id=media_relations.media_id and
		         media_relations.media_relationship like ' %cataloged_item' and
		         identification.accepted_id_fg=1 and
		         media_relations.related_primary_key = identification.collection_object_id and
		         identification.identification_id=identification_taxonomy.identification_id and
		         identification_taxonomy.taxon_name_id=#taxon_name_id#
		     group by
		     	media.media_id,
		        media.media_uri,
		        media.mime_type,
		        media.media_type,
		        media.preview_uri
		  ) where rownum < 11
	</cfquery>
	<cfif media.recordcount gt 0>
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
				<cfquery name="desc" dbtype="query">
					select label_value from labels where media_label='description'
				</cfquery>
				<cfset alt="Media Preview Image">
				<cfif desc.recordcount is 1>
					<cfset alt=desc.label_value>
				</cfif>
                <cfset mrel=getMediaRelations(#media_id#)>
               <div class="oneMedia">
	               <a href="#media_uri#" target="_blank"><img src="#getMediaPreview(preview_uri,media_type)#" alt="#alt#"></a>
	                   <br>#media_type# (#mime_type#)
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