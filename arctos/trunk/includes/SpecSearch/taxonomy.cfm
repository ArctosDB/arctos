<script type="text/javascript" language="javascript">
	jQuery(document).ready(function() {
		jQuery("#phylclass").autocomplete("/ajax/phylclass.cfm", {
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
<cfquery name="ctNatureOfId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
	SELECT DISTINCT(nature_of_id) FROM ctnature_of_id ORDER BY nature_of_id
</cfquery>
<cfoutput>
<table id="t_identifiers" class="ssrch">
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_scientific_name">Scientific&nbsp;Name:</span>
		</td>
		<td class="srch">
			<select name="sciNameOper" id="sciNameOper" size="1">
				<option value="">contains</option>
				<option value="NOT LIKE">does not contain</option>
				<option value="=">is exactly</option>
				<option value="was">is/was/cited/related</option>
				<option value="OR">in list</option>
		  	</select>
			<input type="text" name="scientific_name" id="scientific_name" size="28">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_phylclass">Class:</span>
		</td>
		<td class="srch">
		 	<input type="text" name="phylclass" id="phylclass" size="50">
			<span class="infoLink" onclick="var e=document.getElementById('phylclass');e.value='='+e.value;">Add = for exact match</span>		
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_genus">Genus:</span>
		</td>
		<td class="srch">
			<input type="text" name="genus" id="genus" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_species">Species:</span>
		</td>
		<td class="srch">
			<input type="text" name="species" id="species" size="50">
			<span class="infoLink" onclick="var e=document.getElementById('species');e.value='='+e.value;">Add = for exact match</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_subspecies">Subspecies:</span>
		</td>
		<td class="srch">
			<input type="text" name="subspecies" id="subspecies" size="50">
			<span class="infoLink" onclick="var e=document.getElementById('subspecies');e.value='='+e.value;">Add = for exact match</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_common_name">Common Name:</span>
		</td>
		<td class="srch">
			<input name="common_name" id="common_name" type="text" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_nature_of_id">Nature of ID:</span>
		</td>
		<td class="srch">
			<select name="nature_of_id" id="nature_of_id" size="1">
				<option value=""></option>
				<cfloop query="ctNatureOfId">
					<option value="#ctNatureOfId.nature_of_id#">#ctNatureOfId.nature_of_id#</option>
				</cfloop>
			</select><span class="infoLink" 
							onclick="getCtDoc('ctnature_of_id',SpecData.nature_of_id.value);">Define</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="identifier">Determiner:</span>
		</td>
		<td class="srch">
			<input type="text" name="identified_agent" id="identified_agent">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_identification_remarks">ID Remarks:</span>
		</td>
		<td class="srch">
			<input type="text" name="identification_remarks" id="identification_remarks">
		</td>
	</tr>
</table>
</cfoutput>	