
<cfoutput>
<table id="t_identifiers" class="ssrch">

    <!------
	<cfquery name="ctmedia_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select media_type from ctmedia_type order by media_type
</cfquery>
		<tr>
        <td class="lbl">
            <span class="helpLink" id="_media_type">Media Type:</span>
        </td>
        <td class="srch">
			<select name="media_type" id="media_type" size="1">
				<option value=""></option>
                <option value="any">Any</option>
				<cfloop query="ctmedia_type">
					<option value="#ctmedia_type.media_type#">#ctmedia_type.media_type#</option>
				</cfloop>
			</select>
		</td>
    </tr>
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
			<span class="helpLink" id="accessioned_by_project">Contributed by Project:</span>
		</td>
		<td class="srch">
			<input type="text" name="project_name" id="project_name" size="50">					
			<span class="infoLink" onclick="getHelp('get_proj_name');">Pick</span>	
		</td>
	</tr>	
	<tr>
		<td class="lbl">
			<span class="helpLink" id="loaned_to_project">Used by Project:</span>
		</td>
		<td class="srch">
			<input type="text" name="loan_project_name" id="loan_project_name" size="50">
		</td>
	</tr>		
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_project_sponsor">Project Sponsor:</span>
		</td>
		<td class="srch">
			<input type="text" name="project_sponsor" id="project_sponsor" size="50">
		</td>
	</tr>		
</table>
</cfoutput>