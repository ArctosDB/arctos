<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Taxonomy">

<font size="-2"><a href="index.cfm">Help</a> >> <a href="definitions_standards_index.cfm">Definitions and Standards</a> >> <strong>Taxonomy</strong> </font><br />
<font size="+1">Taxonomy</font>
<p>
<table border="0" align="left" hspace="5" cellpadding="10">
<tr><td>
	<cfinclude template="includes/taxonomy_idx.cfm">
</td></tr></table>
Taxonomy is the formal hierarchical naming system applied to biological organisms.
In this database, each  taxon that might be used in a determination
is stored in its own row with its own hierarchy.
This is planned as a temporary measure until such time as an adequate taxonomic
authority is created as a web service. 
For now, we need to keep track of names as they are applied to specimens
and provide some capacity for searching by higher taxonomic categories and synonymies.</p>

<p>The names in the taxonomy table are therefore intended to match those
in a formal taxonomic authority.  
Constructions from formal names, such as interspecific hybrids, or vague
determinations (<i>e.g., &quot;Sorex sp.&quot;</i>) are not admissable. 
Such determinations are constructed outside of the taxonomy table.
Here we have formal names; elsewhere we have <a href="identification.cfm">
determinations</a>.</p>

<p>
<div class="fldDef">
	Taxonomy . Scientific_Name<br/>
	VARCHAR2 (110) null
</div>
<a name="scientific_name" class="infoLink" href="#top">Top</a><br>
<strong>Scientific Name</strong>
is usually a concatenation of the three values for genus, species, and subspecies 
(subspecies is often null).
For plants, trinomenal Scientific Names include the 
<a href="#infraspecific_rank">Infraspecific Rank</a> between
species and "subspecies."
For less explicit determinations such as identification to family, Scientific Name is the most explict single 
taxon of the determination, &quot;Canidae&quot; for example.</p>

<p>
<div class="fldDef">
	Taxomomy . Infraspecific_Rank<br/>
	VARCHAR2 (10) null<br/>
	ctinfraspecific_rank
</div>
<a name="infraspecific_rank" class="infoLink" href="#top">Top</a><br>
<strong>Infraspecific Ranks</strong>
are categories of description below the level of species.
In zoology, subspecies is the only infraspecific rank generally used.
In botany, "variety" (var.) and "forma" (fo.) are used in addition to subspecies (subsp.).
This field should always be null in zoological records, and it should
always be used in botanical trinomens.
<ul>
<li><i>Salix polaris</i> subsp. <i>pseudopolaris</i></li>
<li><i>Trichophorum pumilum</i> var. <i>Rollandii</i></li>
</ul>
<div class="fldDef">
	Taxonomy . Author_Text<br/>
	VARCHAR2 (60) null
</div>
<a name="author_text" class="infoLink" href="#top">Top</a><br>
<strong>Author Text</strong>
is the name of the author(s) of the scientific name, and sometimes the year of publication, as it
appears following the name. Some examples:
<ul>
<li><i>Balaena mysticetus</i> Linnaeus, 1758</li>
<li><i>Sibbaldus musculus</i> (Linnaeus, 1758)</li>
<li><i>Salix glauca</i> L.</li>
<li><i>Trichophorum pumilum</i> (M. Vahl) Schinz &amp; Thell<br/></li>

</ul>
<p>The format  follows  different conventions in
botany and zoology, but  the presence or absence of
parenthesis, is important and should be as it appears in the 
<a href="#source_authority">Source Authority</a> for the record.
Botanical names often use the Kew Abbreviation of the author's name.</p>
  
<p>
<a name="named_hybrid" class="infoLink" href="#top">Top</a><br>
<strong>Named Hybrids</strong>
are single botanical names that have been applied to interspecific hybrids.
For example, the hybrid offspring of sedges <i>Carex limosa</i> and 
<i>Carex salina</i> has been named <I>Carex &times;limosoides</I>&nbsp;J.Cay.
(This is distinct from a hybrid <a href="identification.cfm#id_formula">determination</a>,
which would be described with two names; <i>e.g.,</i>
"<i>Carex limosa</i> X <i>Carex salina</i>.")
The conventions &quot;x_limosoides&quot; &quot;X_limosoides&quot; 
are frequently seen. 
In fact, the character is not a conventional X, but rather the 
mathematical times sign, and the Taxonomy Editing screen
is equipped to insert this character into the Species field.</p>

Named Hybrids should have the 
<a href="#taxon_relations">relationship</a> 
"hybrid offspring of" to each of the parental species.

<p>
<a name="higher_taxonomy" class="infoLink" href="#top">Top</a><br>
<strong>Higher Taxonomy</strong>
is handled by having higher taxonomic categories in each record (row).
These include Class, Order, Suborder, Family, Subfamily, and Tribe.
Classes are defined and controlled in a
<cfoutput>
<a href="#Application.ServerRootUrl#/info/ctDocumentation.cfm?table=ctclass">code table</a>.
</cfoutput>
Subgenus is also available but so far unused.
Each record should include Class, Order, and Family except where an
inexplicit determination such as "Carnivora" precludes the use of lower taxa.
Use Suborder, Subfamily, and Tribe only where you can provide this information
in all records for the respective Orders, Families, or Subfamilies.
In other words, do not put in the Subfamily unless you do so for all records
of that Family.</p>
<p>Development of more than the minimal data described above might best await
an adequate shared web service.</p>
<p>
<div class="fldDef">
	Taxonomy . Full_Taxon_Name<br/>
	VARCHAR2 (240) not null
</div>
<a name="full_taxon_name" class="infoLink" href="#top">Top</a><br>	
<strong>Full Taxon Name</strong> is a concatenation
of all values from Higher Taxonomy plus Genus, Species and Subspecies. 
This value is machine generated, and used for broad searches where the 
user may not know the taxonomic rank of a search term. </p>

<div class="fldDef">
	Common_Name . Common_Name<br/>
	VARCHAR2 (20) null<br/>
	ctlat_long_units
</div>		
<a name="common_names" class="infoLink" href="#top">Top</a><br>	
<strong>Common Names</strong>
are intended to help users find what they are looking for,
and not to propegate any exclusive standard.
A taxon may have several common names, and they can all be included.
The same common name may apply to more than one taxon.
For example, the term "common shrew" has been published for
<i>Sorex cinereus</i> in North America and for <i>Sorex araneus</i> in Europe.
Common names have not been capitalized except when
they draw on a particular standard such as that of the American Ornithological Union (AOU Checklist).
Adjectival forms of proper names are capitalized (<i>e.g.</i>, "Alaska marmot"). 

<p>
<div class="fldDef">
	Taxonomy . Source_Authority<br/>
	VARCHAR2 (45) not null<br/>
	cttaxonomic_authority
</div>	
<a name="source_authority" class="infoLink" href="#top">Top</a><br>
<strong>Source Authority</strong> gives a source for the &quot;scientific-name&quot; parts of a taxonomic record. 
(The authority does not necessarily apply to the higher taxonomy included in the record.)
These authorities are mostly general taxonomic treatments broad scope.
Many, such as "UAM," "MVZ," or "MSB," are legacy data from those institutions.
So far, the most explicit value for this field is "original description," which
is intended to mean that the person creating record got it from the original
description of the taxon which should be referred to in the
<a href="#author_text">Author Text</a> field.</p>

<p>
<div class="fldDef">
	Taxonomy . Valid_Catalog_Term_fg<br/>
	NUMBER not null
</div>
<a name="valid_term" class="infoLink" href="#top">Top</a><br>				
<strong>Valid Catalog Term flag</strong>
is a toggle that controls the acceptability of a taxon for use in new determinations.
If the taxon is considered scientifically acceptable, the value should be "yes."
If the taxon is an invalid synonym for another name, the value should be "no."
Mostly, this flag prevents invalid names from being entered as new determinations.
Invalid synonyms are available in the database for historic determinations and
for use where the specimen has been cited in literature.</p>

<p>All "invalid" taxa should have a <a href="#taxon_relations">relationship</a> to a valid taxon.</p>

<p>
<a name="taxon_relations" class="infoLink" href="#top">Top</a><br>
<strong>Taxon Relations</strong>
are comprised of a relationship type, a related taxon, 
and an authority for the relationship.</p>
<ul>
	<li>
		<div class="fldDef">
			Taxon_Relations . Taxon_Relationship<br/>
			VARCHAR2 (30) not null<br/>
			cttaxon_relation
		</div>				
	There are currently five <strong>relationship types</strong> describe below.<br/></li>
	<li>The <strong>related taxon</strong> is another record in the taxonomy table.</li>
	<li>
		<div class="fldDef">
			Taxon_Relations . Relationship_Authority<br/>
			VARCHAR2 (45) null<br/>
			no code table
		</div>	
<a name="relationship_authority" class="infoLink" href="#top">Top</a><br>
<strong>Relationship Authority</strong> is an open text field, and it may be null.
	Presumably the <a href="#source_authority">Source Authority</a> for an accepted taxon is adequate
	documentation, but if not, then Relationship Authority could cite a publication
	or the name of an expert to whom the relationship is attributed.</li>
</ul>

<p>Most Taxon Relations represent synonomy among taxa.
As evolutionary relationships and nomenclature are revisited,
changes in taxonomy are suggested, and either accepted or rejected.
Which changes are accepted, and by whom, is a routine issue.
Therefore, keeping track of synonomy in the database can be
important to users.  
If they cannot find material they are seeking under one name,
they may find the name that they are using and its accepted synonym, or they
may use a query which returns records from unaccepted synonyms.</p>

<p>Any number of taxa may be synonymous, but only one of these should
have the value "accepted synonym of," 
and it should have this value for each of its synonyms.
Accepted synonyms should have a 
<a href="#valid_term">Valid Catalog Term</a> flag of "yes."
The other synonyms should have the value "synonym of,"
for each synonym, and their Valid Catalog Term flag should be "no."
</p>
<p><a href="#named_hybrid">Named hybrids</a> 
have a unique relationship to their parent taxa,
and this is expressed by "hybrid offspring of." 
Each named hybrid should have two such relationships.</p>

<p>Taxon relations may also represent hierarchical relationships between taxa.
So far, this is included only for the purpose of constructing botanical
trinomens with author text for both the species and the infraspecific category.
For example,<br />
<i>Trichophorum pumilum</i> (M. Vahl) Schinz &amp; Thell var.<i>Rollandii</i> (Fern.) Hult.<br/>
would be constructed from the "parent" binomen,<br/> 
<i>Trichophorum pumilum</i> (M. Vahl) Schinz &amp; Thell<br/>
plus the infraspecific rank, "subspecies," and author text from the "child" trinomen,<br/>
<i>Trichophorum pumilum</i> var. <i>Rollandii</i> (Fern.) Hult.<br/>

</p>


<cfinclude template="/includes/_helpFooter.cfm">