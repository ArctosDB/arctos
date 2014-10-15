<cfinclude template = "/includes/functionLib.cfm">
<cfif not isdefined("typ")>
	<cfabort>
</cfif>
<cfif not isdefined("q") or len(q) eq 0>
	<cfabort>
</cfif>
<cfif not isdefined("tgt") or len(tgt) eq 0>
	<cfabort>
</cfif>
<cfif not isdefined("rpp") or len(rpp) eq 0>
	<cfset rpp=10>
</cfif>
<cfif not isdefined("pg") or len(pg) eq 0>
	<cfset pg=1>
</cfif>
<style>
 .audiothumb { width:180px; }
</style>
<cfoutput>
	<cfif typ is "taxon">
		<cfset srchall="/MediaSearch.cfm?action=search&taxon_name_id=#q#">
		<cfset sql="select * from (
			   	select
			   		 media_id,
				     media_uri,
				     mime_type,
				     media_type,
				     preview_uri,
				     description,
				     DISPLAY,
				     URI
				from (
			   		select
				        media.media_id,
				        media.media_uri,
				        media.mime_type,
				        media.media_type,
				        media.preview_uri,
				        concatMediaDescription(media.media_id) description,
				        DISPLAY,
				     	URI
				     from
				        media,
				        ctmedia_license,
				        media_relations,
				        identification,
				        identification_taxonomy
				     where
				        media.media_id=media_relations.media_id and
				        media.MEDIA_LICENSE_ID=ctmedia_license.MEDIA_LICENSE_ID (+) and
				        media_relations.media_relationship like '% cataloged_item' and
				        identification.accepted_id_fg=1 and
				        media_relations.related_primary_key = identification.collection_object_id and
				        identification.identification_id=identification_taxonomy.identification_id and
				        --media.preview_uri is not null and
				        identification_taxonomy.taxon_name_id=#q#
				    UNION
				    select
				        media.media_id,
				        media.media_uri,
				        media.mime_type,
				        media.media_type,
				        media.preview_uri,
				        concatMediaDescription(media.media_id) description,
				         DISPLAY,
				     URI
				     from
				         media,
				        ctmedia_license,
				         media_relations
				     where
				         media.media_id=media_relations.media_id and
				        media.MEDIA_LICENSE_ID=ctmedia_license.MEDIA_LICENSE_ID (+) and
				         media_relations.media_relationship like '%taxonomy' and
				         media_relations.related_primary_key = #q#
				 ) group by
				 	media_id,
				    media_uri,
				    mime_type,
				    media_type,
				    preview_uri,
				    description,
				     DISPLAY,
				     URI
			)
		">
	<cfelseif typ is "accn">
		<cfset srchall="/MediaSearch.cfm?action=search&accn_id=#q#">
		<cfset sql="
			   	select
			   		media.media_id,
			        media.media_uri,
			        media.mime_type,
			        media.media_type,
			        media.preview_uri,
			        concatMediaDescription(media.media_id) description,
				     DISPLAY,
				     URI
				from
					media,
				        ctmedia_license,
					media_relations
				where
					 media.media_id=media_relations.media_id and
				        media.MEDIA_LICENSE_ID=ctmedia_license.MEDIA_LICENSE_ID (+) and
				     media_relations.media_relationship like '% accn' and
				     media_relations.related_primary_key=#q#
				group by
				 	media.media_id,
			        media.media_uri,
			        media.mime_type,
			        media.media_type,
			        media.preview_uri,
			        description,
				     DISPLAY,
				     URI
			">
	<cfelseif typ is "collecting_event">
		<cfset srchall="">
		<cfset sql="
		   	select
		   		media.media_id,
		        media.media_uri,
		        media.mime_type,
		        media.media_type,
		        media.preview_uri,
		        concatMediaDescription(media.media_id) description,
				DISPLAY,
				URI
			from
				media,
				ctmedia_license,
				media_relations,
				specimen_event
			where
				 media.media_id=media_relations.media_id and
				 media.MEDIA_LICENSE_ID=ctmedia_license.MEDIA_LICENSE_ID (+) and
			     media_relations.media_relationship like '% collecting_event' and
			     media_relations.related_primary_key=specimen_event.collecting_event_id and
				specimen_event.collection_object_id=#q#
			group by
			 	media.media_id,
		        media.media_uri,
		        media.mime_type,
		        media.media_type,
		        media.preview_uri,
		        description,
				DISPLAY,
				URI
		">
	<cfelseif typ is "accnspecimens">
		<cfset srchall="/MediaSearch.cfm?action=search&specimen_accn_id=#q#">

		<cfset sql="select 
				media.media_id,
				media.preview_uri,
				media.media_uri,
				media.media_type,
				media.mime_type,
				concatMediaDescription(media.media_id) description,
				DISPLAY,
				URI
			from 
				cataloged_item,
				media_relations,
				media,
				ctmedia_license
			where
				cataloged_item.collection_object_id=media_relations.related_primary_key and
				media_relations.media_relationship='shows cataloged_item' and
				media_relations.media_id=media.media_id and
				media.MEDIA_LICENSE_ID=ctmedia_license.MEDIA_LICENSE_ID (+) and
				cataloged_item.accn_id=#q#">
	<cfelseif typ is "project">
		<cfset srchall="/MediaSearch.cfm?action=search&project_id=#q#">
		<cfset sql=" select distinct 
	        media.media_id,
	        media.media_uri,
	        media.mime_type,
	        media.media_type,
	        media.preview_uri,
	        concatMediaDescription(media.media_id) description,
			DISPLAY,
			URI
	     from
	         media,
	         media_relations,
	         ctmedia_license
	     where
	         media.media_id=media_relations.media_id and
			media.MEDIA_LICENSE_ID=ctmedia_license.MEDIA_LICENSE_ID (+) and
	         media_relations.media_relationship like '% project' and
	         media_relations.related_primary_key = #q#">
	<cfelse>
		<cfabort>
	</cfif>
	<cfquery name="mediaResultsQuery" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#"  cachedwithin="#createtimespan(0,0,60,0)#">
	   	#preservesinglequotes(sql)#
	</cfquery>
	<cfif mediaResultsQuery.recordcount is 0>
		<div style="margin-left:2em;font-weight:bold;font-style:italic;">
			No Media Found
		</div>
		<cfabort>
	</cfif>
	<cfset obj = CreateObject("component","component.functions")>

	<cfset cnt=mediaResultsQuery.recordcount>
	<cfset start=(pg*rpp)-(rpp-1)>
	<cfif start lt 1>
		<cfset start=1>
	</cfif>
	<cfif start gte cnt>
		<cfset start=cnt>
	</cfif>
	<cfset stop=start+(rpp-1)>
	<cfif stop gt cnt>
		<cfset stop=cnt>
	</cfif>
	<cfset np=pg+1>
	<cfset pp=pg-1>
	<div style="width:100%;text-align:center;" id="imgBrowserCtlDiv">
		Showing Media results #start# - <cfif stop GT cnt> #cnt# <cfelse> #stop# </cfif> of #cnt#
		<cfif len(srchall) gt 0>
			[ <a href="#srchall#">[ view details ]</a>
		</cfif>
		
		<cfif cnt GT rpp>
			<br>
			<cfif (pg*rpp) GT rpp>
				<span class="likeLink" onclick="getMedia('#typ#','#q#','#tgt#','#rpp#','#pp#');"> &lt;&lt;Previous </span>
			</cfif>
			<cfif stop lt cnt>
				<span class="likeLink" onclick="getMedia('#typ#','#q#','#tgt#','#rpp#','#np#');"> Next&gt;&gt; </span>
			</cfif>
		</cfif>
	</div>
	<cfset rownum=1>
		<div class="thumbs">
			<div class="thumb_spcr">&nbsp;</div>
			<cfloop query="mediaResultsQuery" startrow="#start#" endrow="#stop#">
            	
				<cfset alt="Media Preview Image">
				<cfset alt=description>
				<cfif len(alt) gt 50>
					<cfset aTxt=REReplaceNoCase(left(alt,50) & "...","<[^>]*>","","ALL")>
				<cfelse>
					<cfset aTxt=alt>
				</cfif>
               <div class="one_thumb">
			
					<cfset puri=obj.getMediaPreview(preview_uri="#preview_uri#",media_type="#media_type#")>
					<cfif mime_type is "audio/mpeg3">
						<audio controls class="audiothumb">
							<source src="#media_uri#" type="audio/mp3">
							<a href="/exit.cfm?target=#media_uri#" target="_blank">
								<img src="#puri#" alt="#alt#" style="max-width:250px;max-height:250px;">
							</a>
						</audio>
						<br><a href="/exit.cfm?target=#media_uri#" download>download MP3</a>
					<cfelse>
						<a href="/exit.cfm?target=#media_uri#" target="_blank">
							<img src="#puri#" alt="#alt#" style="max-width:250px;max-height:250px;">
						</a>
					</cfif>
					<p>
						#media_type# (#mime_type#)<br>
						<cfif len(uri) gt 0>
							<a href="#URI#">#DISPLAY#</a>
						<cfelse>
							unlicensed
						</cfif>
						
	                   	<br><a href="/media/#media_id#" target="_blank">Media Details</a>
						<br>#aTxt#
					</p>
					
					<!----
	               <a href="/exit.cfm?target=#media_uri#" target="_blank"><img src="#puri#" alt="#alt#" class="theThumb"></a>
                   	<p>
						#media_type# (#mime_type#)
	                   	<br><a href="/media/#media_id#" target="_blank">Media Details</a>
						<br>#aTxt#
					</p>
					---->
				</div>
			</cfloop>
			<div class="thumb_spcr">&nbsp;</div>
		</div>
</cfoutput>