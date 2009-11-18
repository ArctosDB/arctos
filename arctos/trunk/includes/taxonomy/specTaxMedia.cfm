<cfinclude template = "/includes/functionLib.cfm">
<style>
	div.thumb_spcr {
		clear: both;
  	}
	div.thumbs {
  		border: 1px dashed black;
overflow:scroll;
height:400px;
  	}
	div.one_thumb {
	  float: left;
	  width: 130px;
	  padding: 1px;
border:1px solid green;
height:180px;
overflow:hidden;
   text-align: center;

	}
  
	
div.one_thumb p {
font-size:smaller;
   }
.theThumb{
max-width:120px;
max-height:120px;
}




	</style>
<cfoutput>
	<cfquery name="media" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	   	select
	   		 media_id,
		     media_uri,
		     mime_type,
		     media_type,
		     preview_uri,
		     related_primary_key
		from (
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
		    UNION
		    select 
		        media.media_id,
		        media.media_uri,
		        media.mime_type,
		        media.media_type,
		        media.preview_uri,
		        media_relations.related_primary_key
		     from
		         media,
		         media_relations
		     where
		         media.media_id=media_relations.media_id and
		         media_relations.media_relationship like '%taxonomy' and
		         media_relations.related_primary_key = #taxon_name_id#
		 ) group by
		 	media_id,
		    media_uri,
		    mime_type,
		    media_type,
		    preview_uri,
		    related_primary_key
	</cfquery>
	
	<cfif media.recordcount gt 0>
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
	               <a href="#media_uri#" target="_blank"><img src="#getMediaPreview(preview_uri,media_type)#" alt="#alt#" class="theThumb"></a>
                   	<p>
	                   	<a class="infoLink" href="/media/#media_id#" target="_blank">#media_type# (#mime_type#)</a>
						<br>#alt#
					</p>
				</div>
			</cfloop>
			<div class="thumb_spcr">&nbsp;</div>
		</div>
	</cfif>
</cfoutput>