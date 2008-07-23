<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Agents">

<font size="-2"><a href="index.cfm">Help</a> >> <a href="definitions_standards_index.cfm">Definitions and Standards</a> >> <strong>Agents</strong> </font><br />
<font size="+2">Agents</font>

<p>
<table border="0" align="left" cellpadding="10">
<tr><td>
	<cfinclude template="includes/agent_idx.cfm">
</td></tr></table>
Agents are people, organizations, or groups that perform actions.  
Collectors are agents, authors of publications are agents,
users of specimens are agents, and, 
if you enter or edit data, you are an agent.
A single agent can have many roles and many names.

<p>Ideally, no matter how many roles or names an agent has,
a single person (or agency) should be in the database only once.
Before new agent records are created, the database should be queried
to check that the "new" agent is not already in the database.
A collector may have married and now be submitting
specimens as collected under her married name.
Agents with non-English names may exist in the database under alternative transliterations.
(Felix Chernyavski's name is published in English as Tchernyavski and Chernyavsky.)
In these cases, additional Agent Names are required, not additional Agents.</p>

<p>For legacy data, the above is a difficult standard. 
Are Robert Smith, R. Smith, and Bob Smith three agents or one?
Sometimes, the activities already recorded for an agent makes the answer clear, <i>e.g.</i>, 
there were probably not two Eleazer Fitzgarrolds collecting grasshoppers in 
northern Madagascar in the the 1930s.
Thus, it is useful to provide as much information
as possible when creating and editing agent records.
If you can figure it out, the database can usefully handle the information.
If you cannot figure it out, create separate agents; searches on the substring "Smith" 
will still find them all.
If necessary, more two or more agents sharing identical names should be treated discretely.
</p>
<p>The Unknown Agent , or &quot;Agent Zero&quot; (Agent_id = 0) to his friends, has the name &quot;unknown&quot; and should be used where appropriate.  Do not creat new agents for &quot;Collector unknown,&quot; &quot;Determiner unknown,&quot; etc.
<p>
<div class="fldDef">
	Agent . Agent_Type<br/>
	VARCHAR2(15) not null
</div>
<a name="agent_type" class="infoLink" href="#top">Top</a><br>
<strong>Agent Type</strong> 
There are four types of agent:
<ul>
<li><b>Persons</b> - People</li>
<li><b>Organizations</b> - Mostly agencies.</li>
<li><b>Groups</b> - Two or more persons (agents) can be described with a group name.</li>
<li><b>Other Agents</b> - A miscellaneous legacy of weirdness.</li>
</ul>
<p>
<a name="person" class="infoLink" href="#top">Top</a><br>
<strong>Persons:</strong>
Data about a person-agent include the following: 

<table border="2" cellspacing="1" cellpadding="2">
  <tr>
    <th scope="col">Prefix</th>
    <th scope="col">First Name</th>
    <th scope="col">Middle Name</th>
    <th scope="col">Last Name</th>
    <th scope="col">Suffix</th>
    <th scope="col">DOB</th>
    <th scope="col">DOD</th>
  </tr>
  <tr>
    <td>Dr.</td>
    <td>Gordon</td>
    <td>Hamilton</td>
    <td>Jarrell</td>
    <td>The First </td>
    <td>28 May 1946 </td>
    <td><code>null</code></td>
  </tr>
</table>
These fields are used to distinguish similar agents and are hidden to most users.
The values displayed and queried come from a separate table (Agent_Name). 

<p>
<a name="organization" class="infoLink" href="#top">Top</a><br>
<strong>Organizations:</strong>
Examples of organizations include:
<ul>
		<li>University of Alaska Museum</li>
		<li>Alaska Department of Fish and Game</li>
		<li>U.S. National Park Sevice</li>
</ul>
Agencies can have hierarchical relationships, <i>e.g.</i>:
<ul>
<li>Kanuti National Wildlife Refuge</li>
<li>U. S. Fish and Wildlife Service</li>
<li>U. S. Department of the Interior</li>
</ul>

For most purposes, person agents are more explicit and preferrable to organizations;
designations such "U.S. Department of the Interior" are next to useless.
Nevertheless within a hierarchy of agencies, the more explicit the designation, the
more ephemeral the designation  is likely to be.

<p>
<a name="group" class="infoLink" href="#top">Top</a><br>
<strong>Groups:</strong>
A group is envisioned as two or more agents, most likely people,
and functioning in some named capacity.  
So, instead of listing several collectors on an expedition,
one might make all the collectors members of something like
the "1994 Swedish-Russian Tundra Ecology Expedition."
The group concept has not yet been implemented,
though existing applications would support group names.</p> 

<p>
<div class="fldDef">
	Agent_Name . Agent_Name<br/>
	VARCHAR2(184) not null
</div>	
<a name="names" class="infoLink" href="#top">Top</a><br>
<strong>Names:</strong>
Agent names are text strings, some of which may have default values generated 
by concatenating data from the Agent Table. 
All agents must have one and only one "preferred name".
An agent can have any number of other names.
<p>
<div class="fldDef">
	Agent_Name . Agent_Name_Type<br/>
	VARCHAR2(18) not null<br/>
	ctagent_name_type
</div>	
<a name="names" class="infoLink" href="#top">Top</a><br>
<strong>Name Type:</strong>
The Agent_Name table contains columns for Agent_id to link it to an agent, a name type, and a name.
Examples of name types include:
<table BORDER="2" CELLSPACING="2" bordercolor="#191970">
<tr><th>Name Type</th> <th>Agent Name</th></tr>
<tr><td>preferred</td> <td>Gordon H. Jarrell</td></tr>
<tr><td>login</td> <td>gordon</td></tr>
<tr><td>initials plus last</td> <td>G. H. Jarrell</td></tr>
<tr><td>last plus initials</td> <td>Jarrell, G. H.</td></tr>
<tr><td>aka</td> <td>Gordon Jarrell</td></tr>
<tr><td>aka</td> <td>G. Jarrell</td></tr>
<tr><td>initials</td> <td>GHJ</td></tr>
</table>
<p>This gives us the power to report names exactly as they were used in any particular circumstance.
For example, in Publications, names of <a href="publication.cfm#author">authors</a> should be entered in the same 
format in which they appeared on the author line of the publication.</p>
<p>
<a name="relations" class="infoLink" href="#top">Top</a><br>	
<b>Relations:</b>
Relationships between agents can be recorded.  
Like date of birth and date of death, relationships can be critical to understanding 
duplication and similarities in names, and in understanding relationships within the
literature, taxonomic opinions, etc.
The pulldowns are self-evident.
If you know of a relationship between agents, please record it.</p>




<!-------------------------------------------------------->
<a name="namesearch" class="infoLink" href="#top">Top</a><br>	
Search for agents by any combination of the fields provided.
<p>
	First Name, Middle Name, and Last Name are exact-match fields. Partial strings and 
	improper case WILL NOT match.
</p>
<p>To force a partial match, you may use the special characters _ and % to match any single character
or any string, respectively.</p>

<p>Examples:</p>
<table border="2" bordercolor="#191970">
	<tr>
		<td><strong>Agent Name</strong></td>
		<td><strong>Search Term</strong></td>
		<td><strong>Search Field</strong></td>
		<td><strong>Match?</strong></td>
	</tr>
	<tr>
		<td>Gordon H. Jarrell</td>
		<td>jarrell</td>
		<td>Last Name</td>
		<td><font color="#FF0000">no</font></td>
	</tr>
	<tr>
		<td>Gordon H. Jarrell</td>
		<td>Jar</td>
		<td>Last Name</td>
		<td><font color="#FF0000">no</font></td>
	</tr>
	<tr>
		<td>Gordon H. Jarrell</td>
		<td>Jarrell</td>
		<td>Last Name</td>
		<td><font color="#00FF00">yes</font></td>
	</tr>
	<tr>
		<td>Gordon H. Jarrell</td>
		<td>jarrell</td>
		<td>Any part of any name</td>
		<td><font color="#00FF00">yes</font></td>
	</tr>
	<tr>
		<td>Gordon H. Jarrell</td>
		<td>rrell</td>
		<td>Any part of any name</td>
		<td><font color="#00FF00">yes</font></td>
	</tr>
	<tr>
		<td>Gordon H. Jarrell</td>
		<td>_arrell</td>
		<td>Last Name</td>
		<td><font color="#00FF00">yes</font></td>
	</tr>
	<tr>
		<td>Gordon H. Jarrell</td>
		<td>%rell</td>
		<td>Last Name</td>
		<td><font color="#00FF00">yes</font></td>
	</tr>
</table>

<p>
<a name="anynamesearch" class="infoLink" href="#top">Top</a><br>	
<strong>Any part of any name</strong> will match any part of any agent name, including non-person agents. 
<a name="idsearch"></a>
<p></p>
<strong>ID</strong> finds agents by their agent_id, the primary key in table Agent.
<cfinclude template="/includes/_helpFooter.cfm">