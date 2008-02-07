<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Results Search">
<a name="results"></a>
<font size="-2"><a href="../index.cfm">Help</a> >> <strong>Publication/Project Search</strong> </font><br />
<font size="+1">Publication/Project Search</font>

<p>This form lets you search for the results of 
specimen-based activities by simultaneously searching for 
<a href="#pubs">publications</a> and for
<a href="#proj">projects</a>.
From the records of individual publications and projects,
you can go to explict information about their use of specimens
and their relationships to other projects and publications.

<p>While publications and projects are distinct entities, both 
have participants (or authors) and titles, and both are associated 
with particular times.
Links to separate search screens for Publications and Projects 
allow more explict searches (particularly of publications with specimen citations)
and provide additional tools to curatorial users.
</p>
<a name="pubs" class="infoLink" href="#top">Top</a><br>
<font size="+1">Publication Search</font>
<p>Publications are included because they have cited specific specimens, 
or because the described research used specimens that are associated with 
a project.</p>
<p>In addition to searching by author, title, and year, you can also search
for publications by the scientific name of the specimen, either as it was
cited at the time, or as it is now identified. These are  often the same, 
but by no means always. 
(For an overview, click on the word &quot;citations&quot; 
in the description on the screen. </p>
Cited Scientific Name is the name applied to a specimen in a publication.
It may or may not be the same as the currently accepted name for the 
specimen or for the taxon.

<p>
	<a name="proj" class="infoLink" href="#top">Top</a><br>
  <font size="+1">Project Search</font></p>
<p>
	Projects are defined as endeavors that produce specimens, use specimens, 
	or both produce and use specimens. 
	Projects may:
<ul>
		<li>Contribute specimens via Accessions</li>
		<li>Use specimens via Loans</li>
		<li>Produce Publications (which may have specimen citations) </li>
</ul>
Because projects can be associated with accessions and loans, 
they can link projects to each other:<br/>
[Project&nbsp;A]-to-[Accession&nbsp;X]-to-[Specimen&nbsp;Catalog]-to-[Loan&nbsp;Y]-to-[Project&nbsp;B]<br/>
Querying through this loop is a useful mechanism for providing credit to projects
whose specimens contribute other projects, and it is useful
in documenting the historical context in which specimens have
been both acquired and used.
It is also useful for demonstrating to sponsors of collections how,
and how much, the collections are used.
</p>
<cfinclude template="/includes/_helpFooter.cfm">