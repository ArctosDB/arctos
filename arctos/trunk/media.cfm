<cfinclude template="/includes/_header.cfm">
<cfinclude template="/includes/functionLib.cfm">
<script type='text/javascript' src='/includes/media.js'></script>
<cfquery name="ctmedia_relationship" datasource="#application.web_user#">
	select media_relationship from ctmedia_relationship order by media_relationship
</cfquery>
<cfquery name="ctmedia_label" datasource="#application.web_user#">
	select media_label from ctmedia_label order by media_label
</cfquery>
<cfquery name="ctmedia_label" datasource="#application.web_user#">
	select mime_type from ctmime_type order by mime_type
</cfquery>

<cfif #action# is "nothing">
	<cfoutput>
	Search for Media OR <a href="media.cfm?action=newMedia">Create media</a>
		<form name="newMedia" method="post" action="media.cfm">
			<input type="hidden" name="action" value="search">
			<input type="text" id="number_of_relations" name="number_of_relations" value="1">
			<input type="text" id="number_of_labels" name="number_of_labels" value="1">
			<label for="media_uri">Media URI</label>
			<input type="text" name="media_uri" id="media_uri" size="90">
			<label for="mime_type">MIME Type</label>
			<select name="mime_type" id="mime_type">
				<option value=""></option>
					<cfloop query="ctmime_type">
						<option value="#mime_type#">#mime_type#</option>
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
<!----------------------------------------------------------------------------------------->
<cfif #action# is "search">
<cfoutput>
<cfset sel="select media.media_id "> 
<cfset frm="from media,
			media_relations,
			media_labels ">
<cfset whr=" where
				media.media_id=media_relations.media_id (+) and
				media.media_id=media_labels.media_id (+)">
<cfset srch=" ">		
<cfif isdefined("media_uri") and len(#media_uri#) gt 0>
	<cfset srch="#srch# AND upper(media_uri) like '%#ucase(media_uri)#%'">
</cfif>
<cfif isdefined("mime_type") and len(#mime_type#) gt 0>
	<cfset srch="#srch# AND mime_type = '#mime_type#'">
</cfif>
<cfloop from="1" to="#number_of_relations#" index="n">
	<cfset thisRelationship = #evaluate("relationship__" & n)#>
	<cfset thisRelatedId = #evaluate("related_id__" & n)#>
	<cfset thisTableName=ListLast(thisRelationship," ")>
	<cfif len(#thisRelationship#) gt 0>
		<cfset srch="#srch# AND media_relations.media_relationship = '#thisRelationship#'">
	</cfif>
	<cfif len(#thisRelatedId#) gt 0>
		<cfif #thisTableName# is "agent">
			<cfset frm="#frm#,preferred_agent_name preferred_agent_name_#n#">
			<cfset whr="#whr# AND media_relations.related_agent_id=preferred_agent_name_#n#.agent_id">
			<cfset srch="#srch# AND upper(preferred_agent_name_#n#.agent_name) like '%#ucase(thisRelatedId)#%'">
		<cfelseif #thisTableName# is "locality">
			<cfset frm="#frm#,locality locality_#n#">
			<cfset whr="#whr# AND media_relations.locality_id=locality_#n#.locality_id">
			<cfset srch="#srch# AND upper(locality_#n#.spec_locality) like '%#ucase(thisRelatedId)#%'">
		<cfelse>
			Table name not found or handled. Aborting..............
		</cfif>
		<cfset srch="#srch# AND media_relations.media_relationship = '#thisRelationship#'">
	</cfif>	
</cfloop>
	<cfloop from="1" to="#number_of_labels#" index="n">
		<cfset thisLabel = #evaluate("label__" & n)#>
		<cfset thisLabelValue = #evaluate("label_value__" & n)#>
		<cfif len(#thisLabel#) gt 0>
			<cfset srch="#srch# AND media_label = '#thisLabel#'">
		</cfif>
		<cfif len(#thisLabelValue#) gt 0>
			<cfset srch="#srch# AND upper(label_value) like '%#ucase(thisLabelValue)#%'">
		</cfif>
	</cfloop>
<cfset ssql="#sel# #frm# #whr# #srch#">
<hr>#ssql#<hr>
<cfquery name="findIDs" datasource="#application.web_user#">
	#preservesinglequotes(ssql)#
</cfquery>
<cfdump var=#findIDs#>

</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------------->
<cfif #action# is "newMedia">
	
	<cfoutput>
		<form name="newMedia" method="post" action="media.cfm">
			<input type="hidden" name="action" value="saveNew">
			<input type="text" id="number_of_relations" name="number_of_relations" value="1">
			<input type="text" id="number_of_labels" name="number_of_labels" value="1">
			<label for="media_uri">Media URI</label>
			<input type="text" name="media_uri" id="media_uri" size="90"><span class="infoLink" id="uploadMedia">Upload</span>
			<label for="relationships">Media Relationships</label>
			<div id="relationships" style="border:1px dashed red;">
				<select name="relationship__1" id="relationship__1" size="1" onchange="pickedRelationship(this.id)">
					<option value=""></option>
					<cfloop query="ctmedia_relationship">
						<option value="#media_relationship#">#media_relationship#</option>
					</cfloop>
				</select>:&nbsp;<input type="text" name="related_value__1" id="related_value__1" size="80" readonly="readonly">
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
				value="Create Media" 
				class="insBtn"
				onmouseover="this.className='insBtn btnhov'" 
				onmouseout="this.className='insBtn'">
		</form>
	</cfoutput>
	<script>
		var elem = document.getElementById('uploadMedia');
		elem.addEventListener('click',clickUpload,false);
	</script>
</cfif>
<!------------------------------------------------------------------------------------------>
<cfif #action# is "saveNew">
<cfoutput>
	<cftransaction>
		<cfquery name="mid" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			select seq_media.nextval nv from dual
		</cfquery>
		<cfset media_id=mid.nv>
		<cfquery name="makeMedia" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			insert into media (media_id,media_uri) values (#media_id#,'#escapeQuotes(media_uri)#')
		</cfquery>
	<br>
	<cfloop from="1" to="#number_of_relations#" index="n">
		<cfset thisRelationship = #evaluate("relationship__" & n)#>
		<cfset thisRelatedId = #evaluate("related_id__" & n)#>
		<cfset thisTableName=ListLast(thisRelationship," ")>
		<cfif len(#thisRelationship#) gt 0 and len(#thisRelatedId#) gt 0>
			<cfquery name="makeRelation" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				insert into media_relations (media_id,media_relationship,
				<cfif #thisTableName# is "agent">
					related_agent_id
				<cfelseif #thisTableName# is "locality">
					related_locality_id
				<cfelse>
					Table name not found or handled. Aborting..............
				</cfif>
				 ) values (#media_id#,'#thisRelationship#',#thisRelatedId#)
			</cfquery>
		</cfif>	
	</cfloop>
	<cfloop from="1" to="#number_of_labels#" index="n">
		<cfset thisLabel = #evaluate("label__" & n)#>
		<cfset thisLabelValue = #evaluate("label_value__" & n)#>
		<cfif len(#thisLabel#) gt 0 and len(#thisLabelValue#) gt 0>
			<cfquery name="makeRelation" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				insert into media_labels (media_id,media_label,label_value)
				values (#media_id#,'#thisLabel#','#thisLabelValue#')
			</cfquery>
		</cfif>
	</cfloop>
		</cftransaction>
		spiffiriffic!
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">