<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Publications">
<font size="-2"><a href="index.cfm">Help</a> >> <a href="definitions_standards_index.cfm">Definitions and Standards</a> >> <strong>Publications</strong></font><br />
<font size="+2">Publications</font>
<p>
<table border="0" align="left" cellpadding="10">
<tr><td>
	<cfinclude template="includes/publication_idx.cfm">
</td></tr></table>
Publications are included when they are associated with a specimen through a
citation, or when they result from a <a href="project.cfm">Project</a>. 
Publications are permanent additions to the literature, and thus 
not all communications are publications.
This can be a vague distinction:
<ul>
<li>Only publications in their final form should be included in the database. 
Reports by governmental agencies that have not been externally reviewed constitute 
&quot;gray literature,&quot; and are not eligible for inclusion.</li>
<li>Reports of preliminary results in newsletters should not be included,
but a specimen-based observation in final form, albeit perhaps trivial, should be included.</li>
<li>A communication that is unavailable through a competent research librarian 
probably should not be included in publications.</li>
</ul>
There are four kinds of publication:
<ul>
		<li><strong>journals</strong></li>
		<li><strong>journal articles - </strong>
		To enter an article, the journal must already be in the database.</li>
		<li><strong>books</strong></li>
		<li><strong>book chapters - </strong>
		To enter a book chapter, the book must already be entered as separate publication.</li>
</ul>
All publications have:

<p>
<div class="fldDef">
	Publication . Publication_Title<br/>
	VARCHAR(255) not null
</div>
<a name="title" class="infoLink" href="#top">Top</a><br>
<strong>Titles</strong>
are formatted according to the type of publication.
The titles of journals and books have all major words capitalized.
				<ul>
				  <li>Example: <strong>The Small Mammals of the Great Plains.</strong></li>
				</ul>	    
For journal articles and book chapters, capitalize only the first letter of the title and proper names.
			Punctuate the end of the title with a period unless it is otherwise punctuated.
				<ul>
					<li>Example: <strong>The small mammals of the Great Plains.</strong></li>
					<li>Example: <strong>Naked mole-rats: why are they so weird?</strong></li>
				</ul>
Italic text in titles should be marked up with the HTML italic tags (&lt;i&gt; and &lt;/i&gt;).
		  	<ul>
				<li>Example: <strong>The rat, &lt;i&gt;Rattus rattus&lt;/i&gt;, in Alaska.</strong></li>
				<li>Renders as: <strong>The rat, <i>Rattus rattus</i>, in Alaska.</i></strong></li>
			</ul>
Special characters should be inserted in <a href="http://www.alanwood.net/unicode/index.html">Unicode</a> and 
(as above) formatting should be handled with HTML tags.</li>
		  	<ul>
			<li>Example:<strong> Temporal records of d&lt;sup&gt;13&lt;/sup&gt;C and d&lt;sup&gt;15&lt;/sup&gt;N in North Pacific 							             pinnipeds.</strong></li>
			<li>Renders as:<strong> Temporal records of d<sup>13</sup>C and d<sup>15</sup>N in North Pacific pinnipeds.</strong></li>
	    </ul></p>
		
<p>
<div class="fldDef">
	Publication_Author_Name . Agent_Name_id (FK)<br/>
	INTEGER not null
</div>
<a name="author" class="infoLink" href="#top">Top</a><br>
<strong>Authors</strong>
are agents	and may have more than one name.  
Choose or create an agent name that matches the form of the 
name on the author line of the publication.
Do not take author names from potentially reformatted
citations of a publication. 
Have the publication in your hand.
(<i>i.e.,</i> Do not enter data of which you do not have first-hand knowledge.)</p>		
		
<p>
<div class="fldDef">
	Publication_Year . Pub_Year<br/>
	INTEGER not null
</div>
<a name="published_year" class="infoLink" href="#top">Top</a><br>
<strong>Published Year</strong>
	is the year in which the publication occurred.
	It is a four-digit integer, <em>e.g</em>., 1985.</p>

<p>Some publications can be found on the Internet. 
For these, you can provide:
<ul>
	<li><a name="description"><strong>Description</strong></a>
	of the source for the electronic document.
		<ul>
			<li>Example: <strong>Blackwell Publishing</strong></li>
		</ul>
	</li>
	<li><a name="url"><strong>URL</strong></a>
	(Uniform Resource Locator) for the electronic document.
		<ul>
			<li>Example: <strong>http://blackwell.com/journal_of_stuff/Jones_et_al.pdf</strong></li>
		</ul>
	</li>
</ul></p>
	
<p>
<a name="citation" class="infoLink" href="#top">Top</a><br>
<font size="+2">Citations</font><br/>
If an unequivocal relationship exists between a particular specimen 
and a page in the publication, then it is  a Citation.
Ideally, a publication refers to specimens by their
catalog numbers and institutions, but data can be entered
for specimens that were cataloged after they were cited, 
or that were cited by some other identifier such as a field
number.
A citation includes:</p>
<p>
<div class="fldDef">
	Citation . Publication_ID (FK)<br/>
	INTEGER not null
</div>
<strong>Publication:</strong>
There cannot be a Citation until the Publication has been included in the database.
Because full citation requires a page number, the best practice is to enter citations
only when the publication is in its final form.</p>

<p>
<div class="fldDef">
	Citation . Collection_Object (FK)<br/>
	INTEGER not null
</div>
<strong>Specimen:</strong> This must be a catalogued item,
though the form for creating citations will allow you to find 
the specimen by Other Identifiers as well as by Catalog Number.</p>

<p>
<div class="fldDef">
	Citation . Occurs_Page_Number<br/>
	INTEGER null
</div>
<a name="cited_on_page_number" class="infoLink" href="#top">Top</a><br>
<strong>Publication Page Number </strong>
		is the number of the first page on which the specific specimen is mentioned. 
		Referrals to the specimen on subsequent pages within the 
		same publication are ignored.</p>

<p>
<div class="fldDef">
	Citation . Type_Status<br/>
	VARCHAR(20) not null<br/>
	<cfoutput>
		<a href="#Application.ServerRootUrl#/info/ctDocumentation.cfm?table=ctcitation_type_status">ctcitation_type_status</a>
	</cfoutput>
</div>	
<a name="citation_type" class="infoLink" href="#top">Top</a><br>
<strong>Citation Type</strong>
describes the context in which the specimen was cited.
It is possible that one specimen was cited in more than
one context within a single publication.
In this case, use either the first context in which the specimen is cited,
or the most important context in which the specimen is cited.
Vocabulary is controlled by a
<cfoutput>
<a href="#Application.ServerRootUrl#/info/ctDocumentation.cfm?table=ctcitation_type_status">code table</a>.</p>
</cfoutput>

<p>
<div class="fldDef">
	Citation . Cited_Taxon_Name_id (FK)<br/>
	INTEGER not null
</div>	
<a name="cited_as_taxon" class="infoLink" href="#top">Top</a><br>
<strong>Cited As</strong>
		(Cited Taxonomic Identification) is the scientific name which the 
		author(s) applied to the specimen in the publication.
		Sometimes this must be inferred from the publication because the
		author has not explicitly identified invdividual specimens.
		For example, the whole paper is about wolverines, <i>Gulo gulo</i>,
		and individual specimens are only listed by catalog number.
		In at least one case, an author has treated a whole family,
		listed the specimens examined, but not their identifications
		to species.  In this case, the cited taxonomic identification
		is the family.</p>
<cfinclude template="/includes/_helpFooter.cfm">