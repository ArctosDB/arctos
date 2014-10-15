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
audio { width:140px; }
</style>
<cfoutput>
	<cfif typ is "taxon">
		<cfset sql="select * from (
			   	select
			   		 media_id,
				     media_uri,
				     mime_type,
				     media_type,
				     preview_uri
				from (
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
				        media.preview_uri
				     from
				         media,
				         media_relations
				     where
				         media.media_id=media_relations.media_id and
				         media_relations.media_relationship like '%taxonomy' and
				         media_relations.related_primary_key = #q#
				 ) group by
				 	media_id,
				    media_uri,
				    mime_type,
				    media_type,
				    preview_uri
			)
			--where rownum <= 500">
	<cfelseif typ is "accn">
		<cfset sql="
			   	select
			   		media.media_id,
			        media.media_uri,
			        media.mime_type,
			        media.media_type,
			        media.preview_uri
				from
					media,
					media_relations
				where
					 media.media_id=media_relations.media_id and
				     media_relations.media_relationship like '% accn' and
				     media_relations.related_primary_key=#q#
				group by
				 	media.media_id,
			        media.media_uri,
			        media.mime_type,
			        media.media_type,
			        media.preview_uri
			">
	<cfelseif typ is "collecting_event">
		<cfset sql="
		   	select
		   		media.media_id,
		        media.media_uri,
		        media.mime_type,
		        media.media_type,
		        media.preview_uri
			from
				media,
				media_relations,
				specimen_event
			where
				 media.media_id=media_relations.media_id and
			     media_relations.media_relationship like '% collecting_event' and
			     media_relations.related_primary_key=specimen_event.collecting_event_id and
				specimen_event.collection_object_id=#q#
			group by
			 	media.media_id,
		        media.media_uri,
		        media.mime_type,
		        media.media_type,
		        media.preview_uri
		">
	<cfelseif typ is "accnspecimens">
		<cfset sql="select 
				media.media_id,
				media.preview_uri,
				media.media_uri,
				media.media_type,
				media.mime_type
			from 
				cataloged_item,
				collection,
				media_relations,
				media
			where
				cataloged_item.collection_id=collection.collection_id and
				cataloged_item.collection_object_id=media_relations.related_primary_key and
				media_relations.media_relationship='shows cataloged_item' and
				media_relations.media_id=media.media_id and
				cataloged_item.accn_id=#q#">
	<cfelseif typ is "project">
		<cfset sql=" select distinct 
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
				<cfif len(alt) gt 50>
					<cfset aTxt=REReplaceNoCase(left(alt,50) & "...","<[^>]*>","","ALL")>
				<cfelse>
					<cfset aTxt=alt>
				</cfif>
               <div class="one_thumb">
			
					<cfset puri=obj.getMediaPreview(preview_uri="#preview_uri#",media_type="#media_type#")>
					<cfif mime_type is "audio/mpeg3">
						<audio controls>
							<source src="#media_uri#" type="audio/mp3">
							<a href="/exit.cfm?target=#media_uri#" target="_blank">
								<img src="#puri#" alt="#alt#" style="max-width:250px;max-height:250px;">
							</a>
						</audio>
					<cfelse>
						<a href="/exit.cfm?target=#media_uri#" target="_blank">
							<img src="#puri#" alt="#alt#" style="max-width:250px;max-height:250px;">
						</a>
					</cfif>
					
					
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