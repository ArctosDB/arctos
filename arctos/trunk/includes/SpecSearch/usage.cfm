<script type='text/javascript' src='/includes/SpecSearch/jqLoad.js'></script>	
<cfquery name="ctmedia_type" datasource="#Application.web_user#">
	select media_type from ctmedia_type order by media_type
</cfquery>
<cfoutput>
<table id="t_identifiers" class="ssrch">
	<tr>
        <td class="lbl">
            <span class="helpLink" id="media_type">Media Type:</span>
        </td>
        <td class="srch">
			<select name="media_type" size="1">
				<option value=""></option>
                <option value="any">Any</option>
				<cfloop query="ctmedia_type">
					<option value="#ctmedia_type.media_type#">#ctmedia_type.media_type#</option>
				</cfloop>
			</select>
		</td>
    </tr>
    <!------
    <tr>
		<td class="lbl">
			<span class="helpLink" id="images">Find items with images:</span>
		</td>
		<td class="srch">
			<input type="checkbox" name="onlyImages" value="yes">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="image_subject">Image Subject:</span>
		</td>
		<td class="srch">
			<select name="subject" size="1">
				<option value=""></option>
				<cfloop query="ctSubject">
					<option value="#ctSubject.subject#">#ctSubject.subject#</option>
				</cfloop>
			</select>
			<span class="infoLink" onclick="getCtDoc('ctbin_obj_subject',SpecData.subject.value);">Define</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="image_description">Image Description:</span>
		</td>
		<td class="srch">
			<input type="text" name="imgDescription" size="50">
		</td>
	</tr>
    --->
	<tr>
		<td class="lbl">
			<span class="helpLink" id="accessioned_by_project">Accessioned By Project Name:</span>
		</td>
		<td class="srch">
			<input type="text" name="project_name" size="50">					
			<span class="infoLink" onclick="getHelp('get_proj_name');">Pick</span>	
		</td>
	</tr>	
	<tr>
		<td class="lbl">
			<span class="helpLink" id="loaned_to_project">Loaned To Project Name:</span>
		</td>
		<td class="srch">
			<input type="text" name="loan_project_name" size="50">
		</td>
	</tr>		
	<tr>
		<td class="lbl">
			<span class="helpLink" id="project_sponsor">Project Sponsor:</span>
		</td>
		<td class="srch">
			<input type="text" name="project_sponsor" size="50">
		</td>
	</tr>		
</table>
</cfoutput>