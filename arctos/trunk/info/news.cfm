<cfinclude template="/includes/_header.cfm">
<strong>Major functional Database Changes</strong>
<br>
<font size="-1"><em>Not everything listed here will be available to all users.</em></font>
<p>
</p><strong>20 June 2005</strong>
<ul>
	<li>Redirect one-specimen results directly to Specimen Detail</li>
	<li>Add "in list" to Custom Other Identifier search</li>
	<li>Add file upload option to 
		<a href="/aps.cfm">Add a collection object to a container using barcode</a>
	</li>
</ul>
<hr>
<strong>17 June 2005</strong>
<ul>
	<li>Enable Query By Errors on BerkeleyMapper</li>
</ul>
<hr>
<strong>15 June 2005</strong>
<ul>
	<li>Added link from SpecimenResults to part locations for privileged users</li>
</ul>
<hr>
<strong>14 June 2005</strong>
	<ul>
		<li>
			Add <a href="javascript:void(0);"
									onClick="getHelp('max_error_in_meters'); return false;"
									>Maximum Error</a> to Specimen Search
		</li>
		<li>
			Add <a href="javascript:void(0);"
									onClick="getHelp('chronological_extent'); return false;"
									>Chronological Extent</a> to Specimen Search
		</li>
		<LI>
			Begin implementing ToolTips for select links and buttons
				<ul>
					<li>Please <a href="/info/bugs.cfm">report</a> any browser-related issues concerning ToolTips</li>
				</ul>
		</LI>
		<LI>
			Add this (Changes) link to header
		</LI>
		<LI>
			Replaced Specimen Search results option Geographic Count with Specimen Summary.
			Added "Year" option to results.
		</LI>
	</ul>

</p>
<cfinclude template="/includes/_footer.cfm">