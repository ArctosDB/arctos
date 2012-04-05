<cfquery name="ctmedia_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select media_type from ctmedia_type order by media_type
</cfquery>
<script type="text/javascript" language="javascript">
	jQuery(document).ready(function() {
		jQuery("#project_name").autocomplete("/ajax/project.cfm", {
			width: 320,
			max: 50,
			autofill: false,
			multiple: false,
			scroll: true,
			scrollHeight: 300,
			matchContains: true,
			minChars: 1,
			selectFirst:false
		});
		jQuery("#loan_project_name").autocomplete("/ajax/project.cfm", {
			width: 320,
			max: 50,
			autofill: false,
			multiple: false,
			scroll: true,
			scrollHeight: 300,
			matchContains: true,
			minChars: 1,
			selectFirst:false
		});
	});
</script>
<cfoutput>
<table id="t_identifiers" class="ssrch">
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
			</select><span class="infoLink" onclick="getCtDoc('ctmedia_type',SpecData.media_type.value);">Define</span>

		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="accessioned_by_project">Contributed by Project:</span>
		</td>
		<td class="srch">
			<input type="text" name="project_name" id="project_name" size="50">					
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