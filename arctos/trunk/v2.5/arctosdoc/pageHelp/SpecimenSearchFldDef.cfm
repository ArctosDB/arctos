<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Specimen Search Definitions">
<div class="breadcrumbs">
<a href="../index.cfm">Help</a> >> <a href="searching.cfm">Specimen Search</a> >> Field Definitions
</div>
<h1>Specimen Search Help</h1>

<a name="accession" class="infoLink" href="#top">Top</a><br>
<h2>Accession</h2>
Accession number usually refers to a group of (one or more) specimens received at 
one time from one source.
<br>The format for this field is institution acronym folowed by a space, then the accession number. 
The format of the accession number varies by collection. Examples:
<ul>
	<li>MVZ 12345</li>
	<li>UAM 1999.001.Mamm</li>
</ul>


<a name="cat_num" class="infoLink" href="#top">Top</a><br>
<h2>Catalog Number</h2>
Catalog number is the permanent number assigned by one of the collections to an item. 
It is not the collector's field catalog number.
<br>
Catalog Number is displayed prefixed by Institution Acronym and Collecton Code to avoid ambiguity. 
Searching Arctos for catalog number alone will return many specimens.
<p>
The format for searching this field is:
<ul>
	<li>An integer (9234)</li>
	<li>A comma-delimited list of integers (1,456,7689)</li>
	<li>A hyphen-separated range of integers (1-6)</li>
</ul>
</p>
See <a href="/home.cfm">Arctos Home</a> for more information about data providers and their catalog numbers. 

<a name="custom_identifier" class="infoLink" href="#top">Top</a><br>
<h2>Your Other Identifier</h2>
You may choose one Other Identifier Type in Advanced Features to:
	<ul>
		<li>Search for, separate from standard Other Identifier search fields, and</li>
		<li>Display, as a separate column, in your Specimen Results and Download data</li>
	</ul>
You must set your search pattern in the dropdown before searching.
	<ul>
		<li><strong>is</strong> matches only exact strings</li>
		<li><strong>contains</strong> matches any part of the identifier string, and it not case-sensitive</li>
		<li><strong>in list</strong> accepts a list of comma-separated values</li>
		<li>
			<strong>in range</strong> accepts a range of hyphen-separrated values and works only where all identifiers
			of your selected type are numeric
		</li>		
	</ul>
<cfinclude template="/includes/_helpFooter.cfm">