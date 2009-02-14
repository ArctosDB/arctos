<!--#set var="title" value="Accessions Documentation" -->
<!--#if expr="${QUERY_STRING} = 'accepted_sci_name'" -->
	Accepted Scientific Name is the name now applied to a cited specimen.
It may or may not be the same as the name applied to the specimen in a 
publication.
<!--#elif expr="${QUERY_STRING} = 'af_number'" -->
	AF number is a catalog for the Alaska Frozen Tissue Collection. An individual animal will often have both an AF number and a catalog number. AF numbers have been used to specify UAM specimens in the GenBank database and in some publications.<P>The format for this field is an integer with no prefix.
<p>You may also enter a list of numbers separated by commas.
<!--#elif expr="${QUERY_STRING} = 'accn_number'" -->
Accession number usually refers to a group of (one or more) specimens received at one time from one source. Many specimens do not have an accession number.
<p>The format for this field is a year with a decimal fraction. For example, the first accession in 1998 would be 1998.001
<!--#elif expr="${QUERY_STRING} = 'cat_num'" -->

Catalog number is the permanent number assigned by one of the collections to an item. It is not the collector's
	field catalog number. 
	<p>
	Catalog Number is often prefixed with Collecton Code, Institution Acronym, or some combination or expansion of these
	to avoid ambiguity. If you search Arctos for catalog number alone, you are likely to return many specimens. Add "<strong>Institution</strong>" to your preferences to filter by an individual collection.
	
	Catalog Number is most often given with Collection Code and Institution
	Acronym in the form of "UAM Mamm 1" in Arctos.
		
	
	<P>The format for searching this field is:
	<ul>
					<li>An integer (9234)</li>
					<li>A comma-delimited list of integers (1,456,7689)</li>
					<li>A hyphen-separated range of integers (1-6)</li>
	</ul>
	<p>
		See <a href="/Collections/index.cfm" target="_parent">Data Providers</a> for more information about data providers and their catalog numbers.
	</p>
<!--#elif expr="${QUERY_STRING} = 'other_id_num'" -->
	You can use Other ID even if you do not specify the Other ID Type. For example, Taxon Name = Microtus and Other ID = AF163890 will return the record with GenBank sequence accession = AF163890. You can also search on incomplete strings. Taxon Name = Microtus and Other ID = AF163 will return records that have GenBank sequence accessions beginning with AF163. Expect data inconsistencies.
<P>
	You may specify a string or a comma-separated list of strings. Examples:
	<ul>
		<li>123</li>
		<li>JJB 123</li>
		<li>JJB123</li>
		<li>JJB-123</li>
		<li>JJB-123,JJB-124,JJB-125</li>
	</ul>
</P>
<!--#else-->
	No documentation is available.
<!--#endif-->
