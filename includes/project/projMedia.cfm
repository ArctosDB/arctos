<cfinclude template = "/includes/functionLib.cfm">
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
	<style>
	div.thumb_spcr {
		clear: both;
	}
div.projMediaCell {
	
}

div.bigThumb {
 	float: left;
 	width: 130px;
 	padding: 1px;
	border:1px solid green;
	height:2500px;
	overflow:hidden;
	text-align: center;
}
div.one_thumb p {
	font-size:smaller;
	margin-top:0px;
 }
.theThumb{
	max-width:120px;
	max-height:120px;
}
	</style>
	<cfif #media.recordcount# gt 0>
    	<h2>Media</h2>
		<div class="projMediaCell"><div class="thumb_spcr">&nbsp;</div>
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
               <div class="bigThumb">
	               <a href="#media_uri#" target="_blank"><img src="#getMediaPreview(preview_uri,media_type)#" alt="#alt#"></a>
	                   <p>#media_type# (#mime_type#)
		               <br><a href="/media/#media_id#">Media Details</a>
		            	<cfloop query="mrel">
			            	#media_relationship#: 
							<cfif len(link) gt 0>
					    		<a  href="#link#" target="_blank">#summary#</a>
						    <cfelse>
								#summary#
							</cfif>
						</cfloop>
						<cfloop query="labels">
							<br>#media_label#: #label_value#
						</cfloop>
					</p>
				</div>
			</cfloop>
		<div class="thumb_spcr">&nbsp;</div></div>
	</cfif>
</cfoutput>