<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Accessions">

<font size="-2"><a href="index.cfm">Help</a> >> <a href="definitions_standards_index.cfm">Definitions and Standards</a> >> <strong>Accessions</strong></font><br />
<font size="+2">Accessions</font>
<p>
An accession is a transaction that conveys  a specimen, or (commonly) a group of specimens received
from one source at one time, to a collection.
As an administrative (rather than biological) entity, an accession
can be delimited by administrative criteria such as previous title,
applicable <a href="permit.cfm">permits</a>, or association with a particular project.
In general, accessioning is the first step of incorporating specimens
into a collection and indicates that the museum has accepted custody
of (if not title to) the accessioned material.</p>

<p>Accessioning generally precedes cataloguing. 
Therefore, it is unnecessary to have specimen data in order to create an accession.
Nevertheless, the nature and disposition of the specimen data should be recorded
in order to assure that the data can eventually be located for purposes of cataloging.</p>
<p>
<strong><a name="accession_number">Accession Number</a></strong>
A text string assigned to identify the specific accession.
This under revision at this writing.</p>
<p>
<strong><a name="accession_status">Status</a></strong>
is whether or not the accession is catalogued or not.
&quot;Complete&quot; indicates that the disposition of specimens can be determined from
individual specimen records.
&quot;In process&quot; indicates that at least some of the material is still being
stored and labeled by accession number.</p>

<p><strong><a name="nature_of_material">Nature of Material</a></strong>
is a brief textual description of the accession. 
Quantities can be approximate if the material is not being unpacked prior to storage.
For example, &quot;About 300 frozen small mammals collected during the summer of 2004 in Denali State Park.&quot;</p>

<p><strong><a name="how_obtained">How obtained?</a></strong>
This is a means of acquiring the specimens, such as "gift," "salvaged," and "purchased."
The field needs a more rigorous definition; several of the values in this field are really agents (agencies, organizations),
and should be reflected in "Received From" (below).</p>

<p><strong><a name="received_from">Received From</a></strong>
is the name of the agent who (or which) provided the described material to the museum.
Whenever possible, this should be name of a person, <i>i.e.,</i>
the person within an agency rather than the name of the agency.</p>

<p><strong><a name="received_date">Received Date</a></strong>
is the day that the accessioned material was received by the museum.
Must be a valid date. Default could be the system date when the record was created.</p>

<p><strong><a name="entry_date">Entry Date</a></strong>
is the day that the accession record was created.
Must be a valid date. Default could be the system date when the record was created.
Do we need this?  Should it be a stored system date, and not necessarily displayed in normal applications?</p>

<p><strong><a name="remarks">Remarks</a></strong>
is a place for expanding a description of the conditions of acceptance,
or for instructions in processing the material.
For example, &quot;Take 50 gram subsamples for fatty-acid analysis.&quot;</p>

<cfinclude template="/includes/_helpFooter.cfm">