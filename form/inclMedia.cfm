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
				     descr,
				     license,
				     alt_text
				from (
			   		select
				        media_flat.media_id,
				        media_flat.media_uri,
				        media_flat.mime_type,
				        media_flat.media_type,
				        media_flat.preview_uri,
				        alt_text,
				        license,
				        media_flat.descr
				     from
				        media_flat,
				        media_relations,
				        identification,
				        identification_taxonomy
				     where
				        media_flat.media_id=media_relations.media_id and
				        media_relations.media_relationship like '% cataloged_item' and
				        identification.accepted_id_fg=1 and
				        media_relations.related_primary_key = identification.collection_object_id and
				        identification.identification_id=identification_taxonomy.identification_id and
				        --media.preview_uri is not null and
				        identification_taxonomy.taxon_name_id=#q#
				    UNION
				    select
				        media_flat.media_id,
				        media_flat.media_uri,
				        media_flat.mime_type,
				        media_flat.media_type,
				        media_flat.preview_uri,
                        alt_text,
                        license,
                        media_flat.descr
				     URI
				     from
				         media_flat,
				         media_relations
				     where
				         media_flat.media_id=media_relations.media_id and
				         media_relations.media_relationship like '%taxonomy' and
				         media_relations.related_primary_key = #q#
				 ) group by
				 	media_id,
				    media_uri,
				    mime_type,
				    media_type,
				    preview_uri,
                    alt_text,
                    license,
					descr
			)
		">
	<cfelseif typ is "accn">
		<cfset srchall="/MediaSearch.cfm?action=search&accn_id=#q#">
		<cfset sql="
			   	select
			   		media_flat.media_id,
			        media_flat.media_uri,
			        media_flat.mime_type,
			        media_flat.media_type,
			        media_flat.preview_uri,
                    alt_text,
                    license,
                        media_flat.descr
				from
					media_flat,
					media_relations
				where
					 media_flat.media_id=media_relations.media_id and
				     media_relations.media_relationship like '% accn' and
				     media_relations.related_primary_key=#q#
				group by
				 	media_flat.media_id,
			        media_flat.media_uri,
			        media_flat.mime_type,
			        media_flat.media_type,
			        media_flat.preview_uri,
                    alt_text,
                    license,
                        media_flat.descr
			">
	<cfelseif typ is "collecting_event">
		<cfset srchall="/MediaSearch.cfm?action=search&specimen_collecting_event_id=#q#">
		<cfset sql="
		   	select
		   		media_flat.media_id,
		        media_flat.media_uri,
		        media_flat.mime_type,
		        media_flat.media_type,
		        media_flat.preview_uri,
                alt_text,
                license,
                        media_flat.descr
			from
				media_flat,
				media_relations,
				specimen_event
			where
				 media_flat.media_id=media_relations.media_id and
			     media_relations.media_relationship like '% collecting_event' and
			     media_relations.related_primary_key=specimen_event.collecting_event_id and
				specimen_event.collection_object_id=#q#
			group by
			 	media_flat.media_id,
		        media_flat.media_uri,
		        media_flat.mime_type,
		        media_flat.media_type,
		        media_flat.preview_uri,
                alt_text,
                license,
                 media_flat.descr
		">
	<cfelseif typ is "accnspecimens">
		<cfset srchall="">

		<cfset sql="select
				media_flat.media_id,
				media_flat.preview_uri,
				media_flat.media_uri,
				media_flat.media_type,
				media_flat.mime_type,
                alt_text,
                license,
                media_flat.descr
			from
				cataloged_item,
				media_relations,
				media_flat
			where
				cataloged_item.collection_object_id=media_relations.related_primary_key and
				media_relations.media_relationship='shows cataloged_item' and
				media_relations.media_id=media_flat.media_id and
				cataloged_item.accn_id=#q#">

	<cfelseif typ is "specimenaccn">
		<cfset srchall="/MediaSearch.cfm?action=search&specimen_accn_id=#q#">

		<cfset sql="select
				media_flat.media_id,
				media_flat.preview_uri,
				media_flat.media_uri,
				media_flat.media_type,
				media_flat.mime_type,
                alt_text,
                license,
                media_flat.descr
			from
				cataloged_item,
				media_relations,
				media_flat
			where
				cataloged_item.ACCN_ID=media_relations.related_primary_key and
				media_relations.media_relationship='documents accn' and
				media_relations.media_id=media_flat.media_id and
				cataloged_item.collection_object_id=#q#">
	<cfelseif typ is "project">
		<cfset srchall="/MediaSearch.cfm?action=search&project_id=#q#">
		<cfset sql=" select distinct
	        media_flat.media_id,
	        media_flat.media_uri,
	        media_flat.mime_type,
	        media_flat.media_type,
	        media_flat.preview_uri,
                alt_text,
                license,
                        media_flat.descr
	     from
	         media_flat,
	         media_relations
	     where
	         media_flat.media_id=media_relations.media_id and
	         media_relations.media_relationship like '% project' and
	         media_relations.related_primary_key = #q#">
    <cfelseif typ is "specimen">
        <cfset srchall="/MediaSearch.cfm?collection_object_id=#q#">
        <cfset sql="
		 select distinct
        media_flat.media_id,
        media_flat.media_uri,
        media_flat.mime_type,
        media_flat.media_type,
        media_flat.preview_uri,
        media_flat.hastags,
		alt_text,
		license,
        media_flat.descr
     from
         media_flat,
         media_relations
     where
		media_flat.media_id=media_relations.media_id and
         media_relations.media_relationship like '%cataloged_item' and
         media_relations.related_primary_key = #q#
		">
	<cfelse>
		<cfabort>
	</cfif>

	<!-------->
	<cfquery name="mediaResultsQuery" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
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
            	<cfset puri=obj.getMediaPreview(preview_uri="#preview_uri#",media_type="#media_type#")>
               <div class="one_thumb">
					<cfif mime_type is "audio/mpeg3">
						<audio controls class="audiothumb">
							<source src="#media_uri#" type="audio/mp3">
							<a href="/media/#media_id#?show" target="_blank">
								<img src="#puri#" alt="#alt_text#" style="max-width:250px;max-height:250px;">
							</a>
						</audio>
						<div><a href="/media/#media_id#?show" download>download MP3</a></div>
					<cfelse>
						<cfif media_type is "multi-page document">
							<a href="/document.cfm?media_id=#media_id#" target="_blank">
								<img src="#puri#" altF="#alt_text#" style="max-width:250px;max-height:250px;">
							</a>
						<cfelse>
							<a href="/media/#media_id#?show" target="_blank">
								<img src="#puri#" alt="#alt_text#" style="max-width:250px;max-height:250px;">
							</a>
						</cfif>
					</cfif>
					<div>#media_type# (#mime_type#)</div>
					<div><a href="/media/#media_id#" target="_blank">Media Details</a></div>
					<cfif len(license) gt 0>
						<div>#license#</div>
					</cfif>
					<div>#descr#</div>
				</div>
			</cfloop>
			<div class="thumb_spcr">&nbsp;</div>
		</div>
</cfoutput>