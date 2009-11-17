<cfinclude template = "/includes/functionLib.cfm">
<style>
		div.thumb_spcr {
  clear: both;
  }

div.thumbs {
  border: 2px dashed #333;
  background-color: #fff;
  }
div.one_thumb {
  float: left;
  width: 120px;
  padding: 10px;
  }
  
div.one_thumb p {
   text-align: center;
   }


	</style>
<cfoutput>
	<cfquery name="media" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	    select * from (
		    select  
		        media.media_id,
		        media.media_uri,
		        media.mime_type,
		        media.media_type,
		        media.preview_uri,
		        media_relations.related_primary_key
		     from
		        media,
		        media_relations,
		        identification,
		        identification_taxonomy
		     where
		        media.media_id=media_relations.media_id and
		        media_relations.media_relationship like '% cataloged_item' and
		        identification.accepted_id_fg=1 and
		        media_relations.related_primary_key = identification.collection_object_id and
		        identification.identification_id=identification_taxonomy.identification_id and
		        media.preview_uri is not null and
		        identification_taxonomy.taxon_name_id=#taxon_name_id#
		     group by
		     	media.media_id,
		        media.media_uri,
		        media.mime_type,
		        media.media_type,
		        media.preview_uri,
		        media_relations.related_primary_key
		  ) where rownum < 11
	</cfquery>
	
	<cfif media.recordcount gt 0>
    	<h2>Media</h2>
		<div class="thumbs">
			<div class="thumb_spcr">&nbsp;</div>
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
               <div class="one_thumb">
	               <a href="#media_uri#" target="_blank"><img src="#getMediaPreview(preview_uri,media_type)#" alt="#alt#"></a>
	                   	<p>#media_type# (#mime_type#)
		                   	<br><a class="infoLink" href="/SpecimenDetail.cfm?collection_object_id=#related_primary_key#" target="_blank">Specimen</a>
							<br>#alt#
						</p>
				</div>
			</cfloop>
			<div class="thumb_spcr">&nbsp;</div>
		</div>
	</cfif>
</cfoutput>