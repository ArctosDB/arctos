<cfinclude template="../includes/_pickHeader.cfm">
	<b>Preparation</b>
	<p></p>Parts have several attributes in Arctos:
		<ul>
			<li>Part Name</li>
			<li>Part Modifier</li>
			<li>Preservation Method</li>
			<li>Condition</li>
		</ul>
		Each specimen may have one or more parts.
		<p>Part terminology has been somewhat inconsistent, particularly with frozen tissue samples. If you wish to find all hearts, you would have to search for: </p>
		<ul>
			<li>heart</li>
			<li>heart, lung</li>
			<li>...</li>
			<li>heart, liver, lung</li>
		</ul>
	To find all specimens for which there are frozen tissue samples, specify Preservation Method = "frozen."
<cfinclude template="../includes/_pickFooter.cfm">