<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Taxonomic Determinations">
<font size="-2"><a href="index.cfm">Help</a> >> <a href="definitions_standards_index.cfm">Definitions and Standards</a> >> <strong>Taxonomic Detreminations</strong> </font><br />
<font size="+1">Taxonomic Determinations</font>
<p>
<table border="0" align="left" cellpadding="10">
<tr><td>
<cfinclude template="includes/identification_idx.cfm">
</td></tr></table>
Determinations, or "identifications" (IDs), apply taxonomic terms to specimens. 
&quot;Taxonomic term&quot; is defined below.
Information about taxonomic names (which are used to compose terms)
is in <a href="taxonomy.cfm">Taxonomy</a>.
<p>The database maintains a history of  determinations for each specimen. 
  Specimens are therefore  reidentified by adding a new determination and retaining prior determination(s)
   as &quot;unaccepted.&quot; 
  This means that there can be only one accepted determination, and not necessarily that prior identifications
  are wrong.  In fact, complimentary IDs by experts or by alternative methods enhance the value of the specimen.</p>
<p>A taxonomic determination is comprised of:
<ul>
<li>the taxonomic term, or combination of terms</li>
<li>the name (or names) of the determiner(s)</li>
<li>the date of the determination</li>
<li>and the nature, or basis of the determination</li>
</ul>
<a name="id_formula" class="infoLink" href="#top">Top</a><br>
<strong>Taxonomic terms:</strong>
A determination can contain more than one taxon, possibly in conjunction with modifiers. Taxa are combined with each other, or with modifiers, according to a formula. For example: 
<table border>
		<tr>
	  	  <td><strong>Taxonomic term </strong></td>
			<td><strong>Formula</strong></td>
			<td><strong>Taxa</strong></td>
		</tr>
		<tr>
		  	<td><em>Sorex cinereus</em></td>
			<td>one taxon (A) </td>
			<td>A = <i>Sorex cinereus</i></td>
		</tr>
		<tr>
		  <td><i>Sorex cinereus</i> ?</td>
		  <td>taxon (A) + &quot;?&quot; </td>
		  <td>A = <i>Sorex cinereus</i></td>
  </tr>
		<tr>
		  <td><i>Sorex cinereus</i> or <i>Sorex ugyunak</i></td>
		  <td>A "or" B</td>
		  <td>A = <i>Sorex cinereus</i><br>
	      B = <i>Sorex ugyunak</i></td>
  </tr>
		<tr>
	  	  <td><em>Sorex sp.</em></td>
			<td>A + "sp."</td>
			<td>A= <i>Sorex</i></td>
		</tr>
		<tr>
		  <td><i>Canis latrans x Canis lupus familiaris</i></td>
			<td>A "X" B</td>
			<td>A = <i>Canis latrans</i> <br>
              	B = <i>Canis lupus familiaris</i></td>
		</tr>
</table>
<p>
<div class="fldDef">
	Identification . Made_By_Agent_id<br/>
	NUMBER  not null (FK)
</div>
<a name="id_by" class="infoLink" href="#top">Top</a><br>
<strong>Determiner:</strong> The determiner is the 
<a href="agent.cfm">agent</a> (usually a person) who identified the specimen.
More than one agent can be entered.
The order in which such co-determiners are displayed
is set in the form by the order in which they were added to the determination.
To change the displayed order, create a new copy of the determination
with the determiners in the desired order, then delete the old record.
<p>
<div class="fldDef">
	Identification . Made_Date<br/>
	DATE null
</div>
<a name="id_date" class="infoLink" href="#top">Top</a><br>
<strong>Determined Date:</strong> The date of the determination must be a valid day. 
In the absence of exact information, this can be approximate. 
The chronological order of determinations may be the most critical issue. 
<p>
<div class="fldDef">
	Identification . Nature_Of_ID<br/>
	VARCHAR2 (30) not null<br/>
	ctnature_of_id
</div>
<a name="nature_of_id" class="infoLink" href="#top">Top</a><br>
<strong>Nature of ID:</strong> 
The basis of the identification.
Values are defined in, and controlled by, a
<cfoutput>
<a href="#Application.ServerRootUrl#/info/ctDocumentation.cfm?table=ctnature_of_id">code table</a>.
</cfoutput>
 These include:
<ul>
	<li><strong>ID based on molecular data:</strong> 
	An identification made by a laboratory analysis comparing the specimen 
	to related taxa by molecular criteria, generally DNA sequences.</li>
	<li><strong>ID of kin:</strong> 
	An identification  based upon the identification of another related 
	individual, often the mother of an embryo.
	Such a specimen should have at least one 
	<!--need hyperlink to bio_indiv here-->individual relationship.</li>
	<li><strong>ID to species group:</strong> 
	The specimen has not been distinguished from cryptic species within 
	a closely related group of species.
	The name given is the name that represents the group.</li>
	<li><strong>erroneous citation:</strong> 
	The specimen has been cited in refereed scientific literature by this name
	but this name is clearly wrong.
	This situation arises mostly from typographical errors in catalog numbers.</li>
	<li><strong>expert ID:</strong> 
	The determiner is a person recognized by other experts 
	working with the taxa in question, or the regional biota.</li>
	<li><strong>field ID:</strong> A determination made by the collector 
	or preparator without access to specialized equipment or references.</li>
	<li><strong>legacy:</strong>
	The identification has been transposed from an earlier version of data
	that did not include identification metadata.
	In this case the date of the determination is the date that the data were transposed,
	and the determiner is unknown.</li>
	<li><strong>sp. based on geog.:</strong>
	Specimen has been identified to genus and is assumed, on the basis of
	known geographic ranges, to be the species expected at the collecting locality.
	Specimen has not been identified to species by comparing it to other species
	within the genus.</li>
	<li><strong>ssp. based on geog.:</strong>
	Specimen has been identified to species and is assumed, on the basis of
	known geographic ranges, to be the subspecies expected at the collecting locality.
	The specimen has not been identified to subspecies by comparing it to other subspecies
	within the species.</li>
	<li><strong>student ID:</strong>
	Specimen has been identified by a person using appropriate references, knowledge, and/or and tools, 
	but not by an expert.
	This is a broad use of the term student. (In the sense of Student's T-test.)</li>
	<li><strong>taxonomic revision:</strong>
	This designation is appropriate only in the presence of an earlier identification.
	It implies that the specimen has not been reexamined, and only that a revised taxonomic
	perspective is being applied.</li>
	<li><strong>type ID:</strong>
	This particular specimen has been described in the literature by this name.
	The specimen record should contain a 
	<a href="publication.cfm#citation">citation</a>
	of the appropriate literature.</li>
</ul>
<cfinclude template="/includes/_helpFooter.cfm">