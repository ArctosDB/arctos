<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Specimen Search">
<font size="-2"><a href="../index.cfm">Help</a> >> <strong>Specimen Search</strong> </font><br/>
<font size="+2">Specimen Search</font>

<p>This form locates specimen records in the database.
In its default format, there are seven search parameters available,
but the form can be expanded several fold by logging in and using the 
<a href="customize.cfm">Advanced Features tab.</a></p>

<p>Because so many features of Specimen Search are elective, the 
<a href="../search_examples_TOC.cfm">Examples</a>
offer a quick way to understand the functions of this form (and others).



<p>Except where otherwise noted, values entered in this form can be substrings
in which capitalization will be ignored.
The entered values are combined with Boolean "ANDs," and empty fields are ignored.</p>

<p>Output from queries can be displayed as a list of specimen records (by default),
as counts based on geographic categories, or as a data layer on the
the BerkeleyMapper GIS server.  Select an option from the "Return results as" 
dropdown at either the top or bottom of the form. </p>
<cfinclude template="/includes/_helpFooter.cfm">