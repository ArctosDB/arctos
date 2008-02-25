<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Catalogued Items">
<font size="-2"><a href="index.cfm">Help</a> >> <a href="definitions_standards_index.cfm">Definitions and Standards</a> >> <strong>Cataloged Items</strong> </font><br />
<font size="+2">Cataloged Items</font>

<p>
<table border="0" align="left" cellpadding="10">
<tr><td>
	<cfinclude template="includes/cataloged_item_idx.cfm">
</td></tr></table>
Catalogs are administrative lists with 
inconsistent relationships to physical items.  
Therefore, a Cataloged Item is an abstraction, <i>i.e.</i>, it is an item that has been cataloged,
and hence defined, by the administrator of a catalog.</p>
<p>In a catalog of mammals or birds, a cataloged item usually
coincides with a biological individual. 
A large mammal will be given one catalog number even though 
it may be comprised of many specimen parts, <i>e.g.</i>, a skin,
a skull, frozen tissue samples, fluid-preserved soft parts.
In a catalog of fish or parasites, a cataloged item often
is numerous individuals of one species from the same collecting event.
There are also situations where parts of the same biological indivdiual
may occur in more than one catalog.
For example, some museums maintain one catalog for skins
and another for skeletal material, or separate parts of the same 
individual may have been cataloged at more than one institution.</p>

<p>
<div class="fldDef">
	Cataloged_Item . Cat_Num<br/>
	NUMBER not null
</div>
<a name="catalog_number" class="infoLink" href="#top">Top</a><br>
<strong>Catalog Number</strong>
is the integer assigned to a Cataloged Item.
It must be unique within the particular catalog.</p>
<p>
This is the value by which specimens are usually identified
when they are cited in publications.
Therefore, once a catalog number is assigned, it should 
not be changed.
Occasionally, when correcting legacy errors it is desirable
to consolidate two or more miscataloged items under a single
catalog number.
(This situation is encountered most often with large animals
that may have been sampled by two agencies which then
independently submit samples for archiving.)
In this situation, the old catalog numbers should be retained as Other Identifiers.
</p>

<p>
<div class="fldDef">
	Collection . Collection<br/>
	VARCHAR2(15) not null
</div>
<a name="collection" class="infoLink" href="#top">Top</a><br>
<strong>Collection:</strong> Items are cataloged in collections.</p>

<p>
<div class="fldDef">
	Collection . Collection_Cde<br/>
	VARCHAR2(4) not null
</div>
<a name="collection_code" class="infoLink" href="#top">Top</a><br>
<strong>Collection Code:</strong> 
This is a four-letter abbreviation for a collection type.
For example, &quot;MAMM,&quot; &quot;BIRD,&quot; etc. 
This field is most importantly used in code tables,
which determine the values provided to drop-downs in specimen-editting aplications.
Thus, if you are editting the record for a mammal specimen, you have the option
of using an attribute such as ear length, and you do not have to see irrelevant attributes
such as beak length.</p>

<p>
<div class="fldDef">
	Collection . Desc<br/>
	VARCHAR2(255) not null
</div>
<a name="description" class="infoLink" href="#top">Top</a><br>
<strong>Description:</strong>
A text description of the collection.
For example, &quot;UAM Bryozoan Collection.&quot;</p>

<p>
<div class="fldDef">
	Collection . Institution_Acronym<br/>
	VARCHAR2(20) not null
</div>
<a name="institution_acronym" class="infoLink" href="#top">Top</a><br>
<strong>Institution Acronym:</strong> 
Abbreviation of the institution that hosts the catalog.
For example, &quot;MVZ,&quot; &quot;UAM,&quot; &quot;MSB.&quot;
</p>


<p><font size="+2">Other Identifiers</font><br/>
These are generally some sort of other catalog numbers.
For example, a field number, or collector number is from 
the field catalog of the collector of the item. 
Other values include catalog numbers from other institutions
where the specimen may have also been cataloged.
Yet another category of Other Identifier results from
scientific usage of the specimens.
For example, GenBank accession numbers link specimen
records to DNA sequences derived from the specimen.
</p>
<p>
<div class="fldDef">
	Coll_Obj_Other_ID_Num . Other_ID_Type<br/>
	VARCHAR2(75) not null<br/>
	ctcoll_other_ID_type
</div>	
<a name="other_id_type" class="infoLink" href="#top">Top</a><br>
<strong>Other ID Type</strong> 
describes the kind of identifier.
This field uses values that are controlled by, and defined in, a
<cfoutput>
<a href="#Application.ServerRootUrl#/info/ctDocumentation.cfm?table=ctcoll_other_id_type">code table</a>.
</cfoutput>
</p>

<p>
<div class="fldDef">
	Coll_Obj_Other_ID_Num.Other_ID_Prefix VARCHAR2(60)<br/>
	Coll_Obj_Other_ID_Num.Other_ID_Number NUMBER<br/>
	Coll_Obj_Other_ID_Num.Other_ID_Suffix VARCHAR2(60)
</div>
<a name="other_id_number" class="infoLink" href="#top">Top</a><br>	
<strong>Other ID Number</strong> 
is a three-part identifying number. It is generally represented as a concatenation of the three parts, 
any of which may be NULL, using hyphens	as a separator.
Although it is called a number, it is a text string.
Some such &quot;numbers&quot; are used in inconsistent formats (<i>e.g.,</i>  
&quot;ABC 123,&quot; &quot;ABC123,&quot; ABC-123,&quot; &quot;ABC0123,&quot; etc.).
One of the Other ID Types (GenBank accession numbers) is used to build URLs
to another database.
Therefore, the character string must be identical to its representation in the remote database.
</p>
<p>
	<span style="font-size:larger;font-weight:bold;">Bulkloading Rules:</span>
	The bulkloader accepts a single string which is parsed out into three fields at runtime. Strangely-formatted 
	strings may be manually entered into the correct fields under Specimen Detail.
	<table border="1">
		<th>Input</th>
		<th>Prefix</th>
		<th>Number</th>
		<th>Suffix</th>
		<th>Explanation</th>
		<tr>
			<td>1234</td>
			<td>NULL</td>
			<td>1234</td>
			<td>NULL</td>
			<td>Integers are stored as other_id_number</td>
		</tr>
		<tr>
			<td>abcd</td>
			<td>abcd</td>
			<td>NULL</td>
			<td>NULL</td>
			<td>Non-integer strings are stored as other_id_prefix</td>
		</tr>
		<tr>
			<td>abcd-123-b-c</td>
			<td>abcd-123-b-c</td>
			<td>NULL</td>
			<td>NULL</td>
			<td>Too many hyphens; undecipherable strings are stored in other_id_prefix</td>
		</tr>
		<tr>
			<td>abcd 123</td>
			<td>abcd 123</td>
			<td>NULL</td>
			<td>NULL</td>
			<td>A hyphen is the only character that denotes a string split</td>
		</tr>
		<tr>
			<td>abcd-efg-h</td>
			<td>abcd-efg-h</td>
			<td>NULL</td>
			<td>NULL</td>
			<td>"Number" is not an integer; entire string stored as other_id_prefix</td>
		</tr>
		<tr>
			<td>abcd-123</td>
			<td>abcd</td>
			<td>123</td>
			<td>NULL</td>
			<td>Prefix and number</td>
		</tr>
		<tr>
			<td>123-abcd</td>
			<td>NULL</td>
			<td>123</td>
			<td>abcd</td>
			<td>Number and suffix</td>
		</tr>
	</table>
	
</p>

<cfinclude template="/includes/_helpFooter.cfm">