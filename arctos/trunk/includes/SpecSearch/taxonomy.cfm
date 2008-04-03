<script type='text/javascript' src='/includes/SpecSearch/jqLoad.js'></script>	
<cfquery name="ctClass" datasource="#Application.web_user#">
	SELECT DISTINCT(phylclass) FROM ctclass ORDER BY phylclass
</cfquery>
<cfquery name="ctNatureOfId" datasource="#Application.web_user#">
	SELECT DISTINCT(nature_of_id) FROM ctnature_of_id ORDER BY nature_of_id
</cfquery>
<table id="t_identifiers" class="ssrch">
	<tr>
		<td class="lbl">
			<span class="helpLink" id="scientific_name">Scientific&nbsp;Name:</span>
		</td>
		<td class="srch">
			<select name="sciNameOper" size="1">
				<option value="">contains</option>
				<option value="NOT LIKE">does not contain</option>
				<option value="=">is exactly</option>
				<option value="was">is/was/cited/related</option>
		  	</select>
			<input type="text" name="scientific_name" size="28">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="full_taxon_name">Taxonomy:</span>
		</td>
		<td class="srch">
			<input type="text" name="HighTaxa" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="phylclass">Class:</span>
		</td>
		<td class="srch">
		 	<select name="phylclass" size="1">
				<option value=""></option>
				<cfloop query="ctClass">
					<option value="#ctClass.phylclass#">#ctClass.phylclass#</option>
				</cfloop>
			</select><span class="infoLink" 
	  				onclick="getCtDoc('ctclass',SpecData.phylclass.value);">Define</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="common_name">Common Name:</span>
		</td>
		<td class="srch">
			<input name="Common_Name" type="text" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="nature_of_id">Nature of ID:</span>
		</td>
		<td class="srch">
			<select name="nature_of_id" size="1">
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
			<span class="helpLink" id="identifier">Identifier:</span>
		</td>
		<td class="srch">
			<input type="text" name="identified_agent">
		</td>
	</tr>
</table>		