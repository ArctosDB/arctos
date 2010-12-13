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

<cfoutput>
	<cfif typ is "taxon">
		<cfset sql="select * from (
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
				        --media.preview_uri is not null and
				        identification_taxonomy.taxon_name_id=#q#
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
				         media_relations.related_primary_key = #q#
				 ) group by
				 	media_id,
				    media_uri,
				    mime_type,
				    media_type,
				    preview_uri,
				    related_primary_key
			) 
			--where rownum <= 500">
	</cfif>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
	   	#preservesinglequotes(sql)#
	</cfquery>
	<cfif d.recordcount gt 0>
		<cfset cnt=d.recordcount>
		<cfset start=(pg*rpp)-(rpp-1)> 
		<cfset stop=pg*rpp-1>
		<br>cnt: #cnt#
		<br>start: #start#
		<br>stop: #stop#
		<br>pg: #pg#
		<cfsavecontent variable="pager">
			<cfif d.recordcount gt 1>
				<div style="width:100%;text-align:center;" id="imgBrowserCtlDiv">
				Showing Media results #start# - 
				<cfif stop GT cnt> #cnt# <cfelse> #stop# </cfif> of #cnt# 
				<cfif cnt GT rpp> 
					<br> 
					<cfif (pg*rpp) GT rpp> 
						<cfset prev_link=pg-rpp-1>
						
						<cfset pp=pg-1>
<!---
						<span class="likeLink" onclick="mediaPage('#prev_link#','#rpp#','#q#','#type#');">&lt;&lt;PREVIOUS&nbsp;&nbsp;&nbsp;</span>
						---->
						<span onclick="getImg('#typ#','#q#','#tgt#','#rpp#','#pp#')">--prev--</span>

					</cfif> 
					<cfset Total_Pages=ceiling(cnt/rpp)> 
					<cfloop index="i" from="1" to="#Total_Pages#"> 
						<cfset j=i-1> 
						<cfset pg=j*rpp> 
					</cfloop> 
					<cfif stop LT cnt> 
						<cfset next_link=pg+rpp-1> 
					<!---	<span class="likeLink" onclick="npPage('#next_link#','#rpp#','#q#');">&nbsp;&nbsp;&nbsp;NEXT&gt;&gt;</span>
--->
<cfset np=pg+1>
<span onclick="getImg('#typ#','#q#','#tgt#','#rpp#','#np#')">--next--</span>



					</cfif> 
				</cfif>
			</div>
			</cfif>
		</cfsavecontent>
		<cfset rownum=1>
		<cfif pg is 1>
			<cfset pg=1>
		</cfif>
		<div class="thumbs">
			#pager#
			<div class="thumb_spcr">&nbsp;</div>
			<cfloop query="d" startrow="#start#" endrow="#stop#">
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
				<cfif len(alt) gt 50>
					<cfset aTxt=REReplaceNoCase(left(alt,50) & "...","<[^>]*>","","ALL")>
				<cfelse>
					<cfset aTxt=alt>
				</cfif>
               <div class="one_thumb">
	               <a href="#media_uri#" target="_blank"><img src="#getMediaPreview(preview_uri,media_type)#" alt="#alt#" class="theThumb"></a>
                   	<p>
						#media_type# (#mime_type#)
	                   	<br><a href="/media/#media_id#" target="_blank">Media Details</a>
						<br>#aTxt#
					</p>
				</div>
			</cfloop>
			<div class="thumb_spcr">&nbsp;</div>
		</div>
	</cfif>
</cfoutput>