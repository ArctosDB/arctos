<cfinclude template="/includes/_header.cfm">
<script type='text/javascript' src='/includes/media.js'></script>
<cfif #action# is "newMedia">
	<cfquery name="ctmedia_relationship" datasource="#application.web_user#">
		select media_relationship from ctmedia_relationship order by media_relationship
	</cfquery>
	<cfquery name="ctmedia_label" datasource="#application.web_user#">
		select media_label from ctmedia_label order by media_label
	</cfquery>
	<cfoutput>
		<form name="newMedia" method="post" action="media.cfm">
			<input type="hidden" name="action" value="saveNew">
			<label for="media_uri">Media URI</label>
			<input type="text" name="media_uri" id="media_uri" size="90"><span class="infoLink" id="uploadMedia">Upload</span>
			<label for="relationships">Media Relationships</label>
			<div id="relationships" style="border:1px dashed red;">
				<div id="relationshipDiv__1">
				<select name="relationship__1" id="relationship__1" size="1" onchange="pickedRelationship(this.id)">
					<option value=""></option>
					<cfloop query="ctmedia_relationship">
						<option value="#media_relationship#">#media_relationship#</option>
					</cfloop>
				</select>
				</div>
				<span class="infoLink" id="addRelationship" onclick="addRelation(2)">More...</span>
			</div>
			<br>
			<div id="labels" style="border:1px dashed red;">
				<div id="labelsDiv__1">
				<select name="labels__1" id="labels__1" size="1">
					<option value=""></option>
					<cfloop query="ctmedia_label">
						<option value="#media_label#">#media_label#</option>
					</cfloop>
				</select>:&nbsp;
				<input type="text" name="label_value__1" id="label_value__1" size="80">
				</div>
				<span class="infoLink" id="addLabel" onclick="addLabels(2)">More...</span>
			</div>
		</form>
	</cfoutput>
	<script>
		var elem = document.getElementById('uploadMedia');
		elem.addEventListener('click',clickUpload,false);
	</script>
</cfif>
<cfinclude template="/includes/_footer.cfm">