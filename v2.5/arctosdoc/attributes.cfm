<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Attributes">
<a name="top"></a>
<font size="-2"><a href="index.cfm">Help</a> >> <a href="definitions_standards_index.cfm">Definitions and Standards</a> >> <strong>Attributes</strong></font><br/>
<font size="+2">Attributes</font>
							
<p>
<table border="0" align="left" cellpadding="10">
<tr><td>
	<cfinclude template="includes/attributes_idx.cfm">
</td></tr></table>
Attributes are descriptive characteristics,
often of biological individuals, such as measurements, weight, age, and sex. 
Like other determinations, attributes have a determiner, a determination date, 
and a determination method.

Attributes always have a value, and sometimes have units.
<p>
<table align="right" border="1"><tr>
<th>Attribute</th><th>Value</th><th>Units</th>
</tr>
<tr>
<td>Total Length</td><td>123</td><td>millimeters</td></tr>
<tr>
<td>Age Class</td><td>adult (controlled values)</td><td>null</td></tr>
<tr>
<td>Colors</td><td>reddish feet (uncontrolled text)</td><td>null</td></tr>
</table>
<p>You may search for only attributes (leave Value and Units blank) to return specimens which match your other criteria and posess the specified attribute. 
Exercising this option unwisely (For example, searching for all specimens with attribute 'sex' and no other qualifiers.) can time-out your request.
<p>You can search for attributes by only value or by only units. For example:
<ul>
	<li>Attribute: Numeric Age</li>
	<li>Units  = &quot;years&quot; (Returns all specimens 
	with a numeric age recorded in years.)</li>
</ul>
<ul>
			<li>Attribute: Numeric Age</li>
			<li>Value = &quot;5&quot; (Returns all specimens 
			with a numeric age of 6  years, 6 days, etc.</li>
</ul>
<p>You may set the search operator for Attributes to:
<ul>
	<li><code>equals</code></li>
	<li><code>contains</code></li>
	<li><code>greater than</code></li>
	<li><code>less than</code></li>
</ul>
<code>Equals</code> will find only exact matches. 
<code>Contains</code> will find substring matches. 
For example, <span class="example">sex</span> <code>equals</code> 'male' will find only <i>male</i> specimens;
				sex <code>contains</code> 'male' will find both <i>male</i> 
and <i>fe<strong>male</strong></i>.
<p>Because Attributes are treated as determinations, a specimen may have any number of similar and even contradictory attributes.</p>

<p>
	<div class="fldDef">
		Attributes . Attribute_Type<br/>
		VARCHAR(60) not null<br/>
		ctAttribute_Type
	</div>
<a name="name" class="infoLink" href="#top">Top</a><br>
<strong>Attribute Name</strong> 
is the proper name of an attribute. 
These should be unambiguous and match their usage in scientific literature as closely as possible.
Attributes are defined in a column of the code table.

<p>
<div class="fldDef">
	Attributes . Attribute_Value<br/>
VARCHAR(255) not null<br/>
CTATTRIBUTE_CODE_TABLES
</div>	
<a name="value" class="infoLink" href="#top">Top</a><br>
<strong>Attribute Value:</strong>
All Attributes have a Value, but the nature of the Value
is either:
<ul>
	<li>
		<strong>numeric</strong> (with Units)  
		- These are  measurements and the values are 
		subject to numeric operators, such as &quot;greater than&quot; (&gt;) and &quot;less than&quot; (&lt;). 
	</li>
	<li>
		<strong>a controlled string</strong> 
		- These are attributes for which there are limited possible states, 
		<i>e.g.</i>, the sex of the individual.
	</li>
</ul>

	The possible values are restricted by look-up tables (code tables).
	Specific attributes are assigned appropriate look-up tables by a 
	&quot;code table of code tables&quot; (ctattribute_code_tables).
<ul>
	<li><strong>an uncontrolled string</strong>
	- These are often relatively subjective attributes, and the values
	are anything that can be expressed in text.
	Examples include the attributes "Colors" and "Body Condition."</li>
</ul>
<p>
<div class="fldDef">
	Attributes.Attribute_Units<br/>
	VARCHAR(60) null<br/>
	ctlength_units<br/>
	ctnumeric_age_units<br/>
	ctweight_units
</div>
<a name="units" class="infoLink" href="#top">Top</a><br>
<strong>Attribute Units:</strong> 
Numeric measurements have values expressed in units such as grams, millimeters, and years.
Therefore, different attributes have different vocabularies,
and are controlled by different code tables.
CTATTRIBUTE_CODE_TABLES ("The Control Table of Control Tables") is used 
to set which units are used to control a numeric attribute (and which code table is used to control an attribute comprised of controlled strings).
<p>
<div class="fldDef">
	Attributes.Determination_Method<br/>
	VARCHAR(255) null
</div>
<a name="method" class="infoLink" href="#top">Top</a><br>
<strong>Method</strong> 
is how the Attribute was determined.
If the Method can be logically inferred, it is usually unspecified.
Thus, Attributes such as length measurements are assumed to have 
been taken with rulers, calipers, or another standard tool.
In such cases, no value is recorded for Method.

<p>
	<div class="fldDef">
		Attributes.Attribute_Remark<br/>
		VARCHAR(255) null
	</div>
<a name="remark" class="infoLink" href="#top">Top</a><br>
<strong>Remark</strong> 
is a comment about the Attribute.
For example:
<ul>
	<li>Transcribed from collector's journal.</li>
	<li>Weighed after substantial loss of blood.</li>
</ul>
<p>

<div class="fldDef">
	Attributes.Determined_By_Agent_id<br/>
	integer, not null
</div>
<a name="determiner" class="infoLink" href="#top">Top</a><br>
<strong>Determiner</strong> 
is the agent that determined the Value of the Attribute.
Many attributes are determined by either the collector or preparator of the specimen, 
but often attributes are determined at a later time by an investigator using the specimen.
In the many specimen records for which this data was not recorded,
the institution contributing the record has been used as a default 
value for Determiner.

<p>
	<div class="fldDef">
		Attributes . Determined_Date<br/>
		datetime, null
	</div>
<a name="date" class="infoLink" href="#top">Top</a><br>
<strong>Determined Date</strong> 
is the day that the determination was made.
Where this is unknown, the date that the specimen record was
moved into the database has been used as a default value,
meaning essentially that the determination was made before 
this time.
For many such Attributes, it would be reasonable to record
the date of collection (or, if known, the date of preparation)
as a default.  
For Attributes which can be redetermined from the existing
specimen, even an imprecise date will provide a chronological
order to successive determinations.

<cfinclude template="/includes/_helpFooter.cfm">