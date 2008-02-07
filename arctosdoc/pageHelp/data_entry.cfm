<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Data Entry">
<font size="-2"><a href="../index.cfm">Help</a> >> <strong>Data Entry</strong> </font><br/>
<font size="+2">Data Entry</font>
<h2>Overview</h2>
<p>
	The Data Entry form allows users to enter data into a staging table via an entry screen.
</p>
<h2>Requirements</h2>
<p>
	This application relies heavily on JavaScript. User Firefox.
</p>
<h2>Groups</h2>
<p>
	Data Entry requires paired groups (agent type=group) with a specific naming convention:
	<ul>
		<li>x Data Entry Group</li>
		<li>x Data Admin Group</li>	
	</ul>
	x may be any string, as long as final group names are like:
	<ul>
		<li>UAM Mamm Data Entry Group</li>
		<li>UAM Mamm Data Admin Group</li>
	</ul>
</p>
<cfinclude template="/includes/_helpFooter.cfm">