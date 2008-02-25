<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Definitions">
<font size="-2"><a href="index.cfm">Help</a> >> <a href="definitions_standards_index.cfm">Definitions and Standards</a> >> <strong>Encumbrances</strong></font><br />
<font size="+2">Encumbrances</font>

<p>
<table border="0" align="left" cellpadding="10">
<tr><td>
<cfinclude template="includes/encumbrance_idx.cfm">
</td></tr></table>
Encumbrances restrict the use of specimens and specimen data, 
and they are applied to <a href="cataloged_item.cfm">Cataloged Items</a>.
Attributes of an encumbrance include an encubrancer,
a name for the encubrance, an expiration date and/or event,
and an encumbering action.</p>
<a name="encumbrancer" class="infoLink" href="#top">Top</a><br>
<p>The <strong>Encumbrancer</strong>
(encumbering <a href="agent.cfm">agent</a>) 
is the person or organization requiring the restriction.
This agent presumably has the authority to nullify the encumbrance.</p>

<p>
<a name="encumbrance_name" class="infoLink" href="#top">Top</a><br>
<strong>Encumbrance Name:</strong>
Encumbrances are described with a name.
This name should be as general as possible with the aim of avoiding 
separate encumbrances when the encumbrancer and the encumbering action are the same.
(If possible, additional specimens should be added to existing encubrances.)</p>

<p>
<a name="expiration" class="infoLink" href="#top">Top</a><br>
<strong>Expiration Date and/or Event:</strong>
Most encumbrances should be temporary.
  Some are negotiated intervals of time, and this should be reflected 
  by an expiration date.
  Other encumbrances are based upon a condition that might change.
  Examples of expiration events might include the death of the encumbrancer,
  death of the collector, expiration or retraction of encumbering legislation,
  or eradication of critical habitat (<i>e.g.</i>, locality of 
endangered butterfly becomes parking lot). </p>


<p>
<a name="action" class="infoLink" href="#top">Top</a><br>
<strong>Encumbering Action:</strong>
Encumbrances result in a procedural action in the database. For example:
<ul>
<li>Display collector as "anonymous" to non-privileged users.</li>
<li>Hide the specimen record from non-privileged users.</li>
<li>Display a usage warning when attemting to include the specimen in a loan.</li>
</ul>
</p>
<cfinclude template="/includes/_helpFooter.cfm">