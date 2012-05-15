<p>
	Potential specimens-by-taxonomy seach tool.
</p>
<p>
Citations would be removed if we refactor the table to point to IDs rather than taxonomy.
</p>
<table border>
	<tr>
		<th>Search in Tables</th>
		<th>Operator</th>
		<th>StringToMatch</th>
	</tr>
	<tr>
		<td>
			<select multiple size="6">
				<option selected>Current ID</option>
				<option selected>Any ID</option>
				<option selected>Taxonomy Metadata</option>
				<option selected>Related Taxonomy Metadata</option>
				<option selected>Common Names</option>
				<option selected>Citations</option>
			</select>
		</td>
		<td>
			<select>
				<option selected>contains</option>
				<option>is</option>
				<option>in list</option>
				<option>is not</option>
			</select>
		</td>
		<td>
			<input value="some scientific name">
		</td>
	</tr>
</table>
