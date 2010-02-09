<cfinclude template="/includes/_header.cfm">
<h2>Suspect Data Reports</h2>
Arctos offers several methods by which users may investigate suspect data. None are perfect - black-and-white issues are
encoded as database rules, rather than after-the-fact reports.

<p>
	This is a static page, and may be incomplete, incorrect, or out of date. Please notify a developer if that seems 
	to be the case. Last updated 9 Feb 2010 by DLM.
</p>

<h3>Agents</h3>
<p>
	<strong>Reports/Funky Data/Duplicate agents</strong>
</p>
<p>
	This form dynamically searches for agents which may be duplicates (that is, an individual with two or more agent_id entries).
	Curators are encouraged to inspect these reports regularly, track down any recently-created duplicates, and offer 
	additional training to operators who create duplicate agents.
</p>
<cfinclude template="/includes/_footer.cfm">
