<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Arctos Help: Projects">
<font size="-2"><a href="index.cfm">Help</a> >> <a href="definitions_standards_index.cfm">Definitions and Standards</a> >> <strong>Projects</strong></font><br />
<font size="+2">Projects</font>
<p>
<table border="0" align="left" cellpadding="10">
<tr><td>
	<cfinclude template="includes/project_idx.cfm">
</td></tr></table>
Projects are endeavors that contribute specimens, use specimens, or both.
Dissertations and expeditions are two examples of potential projects. 
Because information about incoming specimens is recorded as accessions, 
and because information about specimen usage is recorded as loans, relationships 
between projects can be queried.</p>
<p>
Project descriptions, and their relationships to specimens and publications, 
are intended to:</p>

<ul>
	<li>Track the scientific context of specimens and thereby add to their utility and value.</li>
	<li>Demonstrate the scientific significance of collections by explicitly detailing 
	usage of individual specimens.</li>
	<li>Give credit where credit is due to contributors of specimens, 
	or to sponsors of collecting efforts.</li>
	<li>Allow contributors of specimens to track the usage of their contributions.</li>
</ul>
<p>Projects can be created retroactively in order to reflect the historic usage or 
origin of specimens, or projects can be created in the process of requesting a 
loan or describing an incoming accession. 
A project has a title, a description, a start date, an end date, 
and participating agents who have roles. 
Projects may also produce <a href="publication.cfm">publications</a>
to which they can be related 
even in the absence of specimen <a href="publication.cfm#citation">citations</a>.</p>

<p>
<a name="title" class="infoLink" href="#top">Top</a><br>
<strong>Title:</strong>
Like projects themselves, project titles may be composed retrospectively 
or they may be originated by the participants.  
Titles should avoid jargon and be understandable to non-specialists, 
such as educated taxpayers.  
In format, project titles are like journal article and book chapter
<a href="publication.cfm#title"> titles</a>.
(Capitalize only the first letter of the title and proper names. 
Punctuate the end of the title with a period unless it is otherwise punctuated.)</p>

<p>
<a name="description" class="infoLink" href="#top">Top</a><br>
<strong>Descriptions</strong>
are an abstract of one to about ten sentences.  
They should demonstrate the importance of the work and justify the use of museum specimens. 
Vocabulary and grammar must be suitable for public display.  
New projects requesting use of specimens should include such descriptions 
as part of their requests. 
As in titles, font control and special characters are 
implemented in hypertext markup language.</p>

<p>
<a name="date" class="infoLink" href="#top">Top</a><br>
<strong>Start Date</strong>
and <strong>End Date</strong> will often be approximate, 
and End Date can be ignored for projects that are active. 
Often, the date that a request for specimens is received is used as the start date, 
and the date that results are last published is used as the end date.</p>

<p>
<a name="agent" class="infoLink" href="#top">Top</a><br>
<strong>Project Agents</strong>
are the people or agencies doing the project. 
Their names are drawn from the agents-names table and must be entered 
there if they are not already in the database.</p>

<p>
<a name="agent_role" class="infoLink" href="#top">Top</a><br>
<strong>Agent Roles</strong>
describe what the agents do as project participants. 
The values for this field are controlled by a code table and include such things as:</p>
<ul>
<li>Principle Investigator</li>
<li>Co-investigator</li>
<li>Graduate Student</li>
<li>Major Academic Advisor</li>
</ul>

<p>
<a name="agent_order" class="infoLink" href="#top">Top</a><br>
<strong>Agent Order</strong>
is the order in which the agents will be displayed.  
A principle investigator would usually be number one followed by co-investigators. 
In the case of a doctoral thesis or dissertation, the student is usually first and 
the major advisor second, though this could be an issue of some delicacy. </p>

<cfinclude template="/includes/_helpFooter.cfm">