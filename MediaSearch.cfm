<cfset title="Media">
<div id="_header">
    <cfinclude template="/includes/_header.cfm">
</div>
<cfif isdefined("url.collection_object_id")>
    <cfoutput>
    <cflocation url="MediaSearch.cfm?action=search&relationship__1=cataloged_item&related_primary_key__1=#url.collection_object_id#" addtoken="false">
    </cfoutput>
</cfif>
<cfinclude template="/includes/functionLib.cfm">
<script type='text/javascript' src='/includes/media.js'></script>
<!----------------------------------------------------------------------------------------->
<cfif #action# is "search">
<cfoutput>
<cfset sel="select distinct media.media_id,media.media_uri,media.mime_type,media.media_type "> 
<cfset frm="from media">			
<cfset whr=" where media.media_id > 0">
<cfset srch=" ">		
<cfif isdefined("media_uri") and len(#media_uri#) gt 0>
	<cfset srch="#srch# AND upper(media_uri) like '%#ucase(media_uri)#%'">
</cfif>
<cfif isdefined("media_type") and len(#media_type#) gt 0>
	<cfset srch="#srch# AND upper(media_type) like '%#ucase(media_type)#%'">
</cfif>
<cfif isdefined("mime_type") and len(#mime_type#) gt 0>
	<cfset srch="#srch# AND mime_type = '#mime_type#'">
</cfif>
<cfif not isdefined("number_of_relations")>
    <cfset number_of_relations=1>
</cfif>
<cfif not isdefined("number_of_labels")>
    <cfset number_of_labels=1>
</cfif>
<cfloop from="1" to="#number_of_relations#" index="n">
	<cftry>
        <cfset thisRelationship = #evaluate("relationship__" & n)#>
	    <cfcatch>
	        <cfset thisRelationship = "">
	    </cfcatch>
    </cftry>
    <cftry>
        <cfset thisRelatedItem = #evaluate("related_value__" & n)#>
	    <cfcatch>
            <cfset thisRelatedItem = "">
	    </cfcatch>
    </cftry>
    <cftry>
         <cfset thisRelatedKey = #evaluate("related_primary_key__" & n)#>
	    <cfcatch>
            <cfset thisRelatedKey = "">
	    </cfcatch>
    </cftry>
    <cfset frm="#frm#,media_relations media_relations#n#">
	<cfset whr="#whr# and media.media_id=media_relations#n#.media_id">
	<cfif len(#thisRelationship#) gt 0>
		<cfset srch="#srch# AND media_relations#n#.media_relationship like '%#thisRelationship#%'">
	</cfif>
	<cfif len(#thisRelatedItem#) gt 0>
		<cfset srch="#srch# AND upper(media_relation_summary(media_relations#n#.media_relations_id)) like '%#ucase(thisRelatedItem)#%'">
	</cfif>
</cfloop>
	<cfloop from="1" to="#number_of_labels#" index="n">
		<cftry>
	        <cfset thisLabel = #evaluate("label__" & n)#>
		    <cfcatch>
	            <cfset thisLabel = "">
		    </cfcatch>
        </cftry>
        <cftry>
	        <cfset thisLabelValue = #evaluate("label_value__" & n)#>
		    <cfcatch>
	            <cfset thisLabelValue = "">
		    </cfcatch>
        </cftry>		
		<cfset frm="#frm#,media_labels media_labels#n#">
	    <cfset whr="#whr# and media.media_id=media_labels#n#.media_id">
        <cfif len(#thisLabel#) gt 0>
			<cfset srch="#srch# AND media_labels#n#.media_label = '#thisLabel#'">
		</cfif>
		<cfif len(#thisLabelValue#) gt 0>
			<cfset srch="#srch# AND upper(media_labels#n#.label_value) like '%#ucase(thisLabelValue)#%'">
		</cfif>
	</cfloop>
<cfset ssql="#sel# #frm# #whr# #srch#">
<cfquery name="findIDs" datasource="#application.web_user#">
	#preservesinglequotes(ssql)#
</cfquery>
<table>
<cfset i=1>
<cfloop query="findIDs">
	<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
		<td>
			URI: #media_uri# 
			<br>MIME Type: #mime_type# 
            <br>Media Type: #media_type#
             <cfif isdefined("client.roles") and listcontainsnocase(client.roles,"manage_media")>
		        <a href="media.cfm?action=edit&media_id=#media_id#" class="infoLink">edit</a>
		    </cfif>            
			<cfquery name="labels"  datasource="#application.web_user#">
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
			<br>Labels:	
			<cfif labels.recordcount gt 0>
				<ul>
					<cfloop query="labels">
						<li>
							#media_label#: #label_value#
							<cfif len(#agent_name#) gt 0>
								(Assigned by #agent_name#)
							</cfif>
						</li>
					</cfloop>
				</ul>
			</cfif>
			<br>Relationships:
			<cfset mrel=getMediaRelations(#media_id#)>
			<ul>
			<cfloop query="mrel">
				<li>#media_relationship#: #summary# 
                    <cfif len(#link#) gt 0>
                        <a class="infoLink" href="#link#" target="_blank">Specimens</a>
                    </cfif>
                </li>
			</cfloop>
			</ul>
		</td>
	</tr>
	<cfset i=i+1>
</cfloop>
</table>
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------------->
<cfif #action# is "nothing">
	<cfoutput>
    <cfquery name="ctmedia_relationship" datasource="#application.web_user#">
		select media_relationship from ctmedia_relationship order by media_relationship
	</cfquery>
	<cfquery name="ctmedia_label" datasource="#application.web_user#">
		select media_label from ctmedia_label order by media_label
	</cfquery>
	<cfquery name="ctmedia_type" datasource="#application.web_user#">
		select media_type from ctmedia_type order by media_type
	</cfquery>
	<cfquery name="ctmime_type" datasource="#application.web_user#">
		select mime_type from ctmime_type order by mime_type
	</cfquery>
	Search for Media 
    <cfif isdefined("client.roles") and listcontainsnocase(client.roles,"manage_media")>
        OR <a href="media.cfm?action=newMedia">Create media</a>
    </cfif>
		<form name="newMedia" method="post" action="">
			<input type="hidden" name="action" value="search">
			<input type="hidden" id="number_of_relations" name="number_of_relations" value="1">
			<input type="hidden" id="number_of_labels" name="number_of_labels" value="1">
			<label for="media_uri">Media URI</label>
			<input type="text" name="media_uri" id="media_uri" size="90">
			<label for="mime_type">MIME Type</label>
			<select name="mime_type" id="mime_type">
				<option value=""></option>
					<cfloop query="ctmime_type">
						<option value="#mime_type#">#mime_type#</option>
					</cfloop>
			</select>
            <label for="media_type">Media Type</label>
			<select name="media_type" id="media_type">
				<option value=""></option>
					<cfloop query="ctmedia_type">
						<option value="#media_type#">#media_type#</option>
					</cfloop>
			</select>
			<label for="relationships">Media Relationships</label>
			<div id="relationships" style="border:1px dashed red;">
				<select name="relationship__1" id="relationship__1" size="1">
					<option value=""></option>
					<cfloop query="ctmedia_relationship">
						<option value="#media_relationship#">#media_relationship#</option>
					</cfloop>
				</select>:&nbsp;<input type="text" name="related_value__1" id="related_value__1" size="80">
				<input type="hidden" name="related_id__1" id="related_id__1">
				<br><span class="infoLink" id="addRelationship" onclick="addRelation(2)">Add Relationship</span>
			</div>
			<br>
			<label for="labels">Media Labels</label>
			<div id="labels" style="border:1px dashed red;">
				<div id="labelsDiv__1">
				<select name="label__1" id="label__1" size="1">
					<option value=""></option>
					<cfloop query="ctmedia_label">
						<option value="#media_label#">#media_label#</option>
					</cfloop>
				</select>:&nbsp;<input type="text" name="label_value__1" id="label_value__1" size="80">
				</div>
				<span class="infoLink" id="addLabel" onclick="addLabel(2)">Add Label</span>
			</div>
			<br>
			<input type="submit" 
				value="Find Media" 
				class="insBtn"
				onmouseover="this.className='insBtn btnhov'" 
				onmouseout="this.className='insBtn'">
		</form>
		</cfoutput>
</cfif>
<div id="_footer">
<cfinclude template="/includes/_footer.cfm">
</div>
<!--- deal with the possibility of being called in a frame from SpecimenDetail --->
<script language="javascript" type="text/javascript">
    if (top.location!=document.location) {
    	document.getElementById('_header').style.display='none';
		document.getElementById('_footer').style.display='none';
		parent.dyniframesize();
	}
</script>