<cfoutput>
<table id="t_identifiers" class="ssrch">
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_media_relations">Media related to specimens by:</span>
		</td>
		<td class="srch">
			Only Media related to specimens is discoverable here. All Media can
			be found through <a href="/media">Media Search</a>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_media_relations">Media related to specimens by:</span>
		</td>
		<td class="srch">
			<select name="spec_media_relation" id="spec_media_relation" size="5" multiple="multiple">
				<option value="cataloged_item" selected="selected">directly</option>
				<option value="locality">locality</option>
			</select>
		</td>
	</tr>
</table>
</cfoutput>