<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Specimen Parts">
<font size="-2"><a href="index.cfm">Help</a> >> <a href="definitions_standards_index.cfm">Definitions and Standards</a> >> <strong>Specimen Parts</strong></font><br />
<font size="+2">Specimen Parts</font>
<p>
<table border="0" align="left" cellpadding="10">
<tr><td>
	<cfinclude template="includes/parts_idx.cfm">
</td></tr></table>
Parts are physical entities, in contrast to
Catalogued Items (an abstract entity) or binary objects (such as Images).
One or many parts may comprise a Catalogued Item, and parts may be defined
as the minimal units for which storage location, usage, and condition are tracked.
In many collections, parts are nearly always "whole organisms."
In vertebrate zoology, particularly paleontology, the variety of parts is huge.

<p>Embryos and parasites may be treated parts of the host organism.
Ideally, embryos should be treated as separate catalogued items
because they may have, or they may acquire, attributes distinct
from those of their mothers.
Nevertheless it is often practical to consider them as 
parts of the mother until such time as they do acquire
separate attributes.
Similarly, parasites are stored as parts of their hosts
until such time as they might be worked into a separate parasite collection.</p>

<p>
<div class="fldDef">
	Specimen_Part.Part_Name<br/>
	VARCHAR(70)  not null<br/>
	ctspecimen_part_name
</div>	
<a name="part_name" class="infoLink" href="#top">Top</a><br>
<strong>Part Names:</strong>
What we choose to name as a part depends on what we define as a part,
and while this is often obvious (<i>e.g.,</i> "whole organism"), organisms 
become separated into parts in ways both standardized and not.
Thus, it is difficult to standardize vocabulary for every 
fragment worthy of preservation.

<p>Vocabulary is controlled by a
<cfoutput>
	<a href="#Application.ServerRootUrl#/info/ctDocumentation.cfm?table=ctspecimen_part_name">code table</a>
</cfoutput>

and definitions are now being incoporated.
Part names should refer to specific anatomical parts or recognized
groups of parts (<i>e.g.</i>, "postcranial skeleton").
With rare exception, parts are the singular form of a noun.
In some cases, where the parts may be a batch of indefinite size,
the plural is included parenthetically (<i>e.g.,</i> &quot;endoparasite(s)&quot;). </p>
		  
Parts, when separable, 
        should be entered on individual lines of the parts grid as individual 
        collection objects. Distinct parts should be entered on separate lines, 
        <i>e.g</i>., <b><i>skull</i></b> and <b><i>postcranial skeleton</i></b>. 
        A <i><b>postcranial skeleton</b></i> is considered a single part. Parts 
        already contained in the <b><i>postcranial skeleton </i></b>may be entered 
        on separate lines for clarity. An acceptable entry might be: 
        <blockquote> <p>skull<br>
postcranial skeleton (partial)<br>
humerus (right) [broken]</p>
</blockquote>

<p>Such an entry would designate a postcranial skeleton that has a broken 
        right humerus. Situations like this are typically discovered during 
        loans, are almost always unique, and should be dealt with on a case by 
        case basis.</p>

<p> Some notes on the terminology of parts: 
<ul>
<li> An entry of <i><b>skin</b></i> is presumed to be traditional study 
          skin unless specified otherwise. 
<li> Part modifier <i><b>rug</b> <b>mount</b></i>, when applied to a skin, 
          refers to a taxidermy-mounted rug mount of an animal. Distal phalanges 
          (claws) are presumed to be present. <i><b>Tanned</b></i> should be entered 
          as a preservation method if appropriate. Flat skins, as of small mammals, 
          are not <i><b>rug</b></i> <i><b>mount</b></i>s. 
          <p> <li>A <i><b>skull</b></i> is not presumed to be part of a <i><b>skeleton</b></i>. 
          <i><b>Skeleton</b></i> is not a valid part and is being phased out. 
          Complete skeletons should be entered as <i><b>postcranial</b> <b>skeleton</b></i> and <i><b>skull</b></i>. </ul>

<p>
<div class="fldDef">
	Specimen_Part.Part_Modifier<br/>
	VARCHAR(60)  null<br/>
	ctspecimen_part_modifier
</div>
<a name="modifier" class="infoLink" href="#top">Top</a><br>
<strong>Modifier:</strong>
Useful Part Modifiers include "right" or "distal". 
Unacceptable Part Modifiers include "various" and "crushed". 
Parts with no Part Modifier or Condition are presumed to be complete and undamaged.
<p>
<div class="fldDef">
	Specimen_Part.Preserve_Method<br/>
	VARCHAR(25)  null<br/>
	ctspecimen_preserv_method
</div>	
<a name="pres_method" class="infoLink" href="#top">Top</a><br>	
<strong>Preservation Method</strong>
is not necessary for parts where the method is self evident such as bones or traditionally-prepared 
(<i>i.e.</i>, air dried) study skins. 
Preservation Method may refer to a preservation process (<i>e.g.,</i> "tanned") 
or a storage media (<i>e.g.,</i> "ethanol"), but information about present
storage (<i>e.g.,</i> "70% ethanol") is tracked by container.
Vocabulary is controlled by a
<cfoutput>
	<a href="#Application.ServerRootUrl#/info/ctDocumentation.cfm?table=ctspecimen_preserv_method">code table</a>.
</cfoutput>


<p>
<div class="fldDef">
	Coll_Object.Disposition<br/>
	VARCHAR(20)  not null<br/>
	ctcoll_obj_disp
</div>
<a name="disposition" class="infoLink" href="#top">Top</a><br>	
<strong>Disposition</strong>
describes the status of parts and, as an abstract generality,
the status of catalogued items.
Typical values are:
<ul>
<li>in collection</li>
<li>being processed</li>
<li>on loan</li>
<li>missing</li>
<li>destroyed</li>
</ul>

<p>
<div class="fldDef">
	Coll_Object.Condition<br/>
	VARCHAR(255)  not null
</div>
<a name="condition" class="infoLink" href="#top">Top</a><br>	
<strong>Condition</strong>
is used for entries such as &quot;broken&quot; or &quot;dissected&quot;.

<ul>
	<li> 5 - The best tissues. These have gone from a freshly killed 
                animal directly into liquid nitrogen. The animal should not have 
                been dead for more than thirty minutes.</li>

	<li>4 - These are tissues taken from animals only a few hours post 
                mortem at cool temperatures. Such tissues should not have been 
                previously frozen and thawed.</li>

	<li>3 - These are tissues taken from an animal that has been dead 
            less than sixteen hours at cool temperatures, or tissues taken 
            from an animal that was hard frozen soon after death and then 
            thawed for preparation. Fur is not slipping.</li>

	<li>2 - These tissues may be beginning to show signs of decomposition.</li>

	<li>1 - These tissues are flaccid and thoroughly autolyzed. 
			They probably stink. </li>
</ul>

<p>
<div class="fldDef">
	Coll_Object.Lot_Count<br/>
	NUMBER  not null
</div>
<a name="lot" class="infoLink" href="#top">Top</a><br>		
A <strong>Lot Count</strong>
is an integer that enumberates how many similar items comprise a part.
The value is frequently one (1), but collections of fish and invertebrates 
usually assign a single catalog number to all of the individual organisms
of one species from one collecting event.
Thus, 86 minnows of one species from one place, collected at the same time, and stored together
in one jar of alcohol would be a cataloged item with one part, 
and that part would have a lot count of 86 whole animals.

<p>
<table border="1" align="right" cellpadding="5">
<tr><td><div align="center">Catalog # </div></td><td><div align="center">Part Name</div></td><td><div align="center">Pres Method</div></td><td><div align="center">Lot Cnt</div></td></tr>
<tr><td><div align="center">123456</div></td><td><div align="center">whole animal</div></td><td><div align="center">alcohol</div></td><td><div align="center">85</div></td></tr>
<tr><td><div align="center">123456</div></td><td><div align="center">skeleton</div></td><td><div align="center">cleared and stained</div></td><td><div align="center">1</div></td></tr>
</table>
Lot counts are not static;
lots may be split into smaller lots by creating a separate part.
If one of those 86 minnows was prepared for skeletal study by clearing and staining,
it would be necessary to create a second "part" within the catalogued item

<p>A cryotube of embryos or a box of ribs should have a lot count.
In contrast, three tubes of muscle from an individual will be tracked separately; 
these should be entered as three collection objects with a lot count of one.</p>
<p>Examples of lot count usage:</p>
<table border="1" cellpadding="5">
<tr> <td height="18" width="50%"> <div align="center"><b>Material</b></div>
</td>
<td height="18" width="50%"> <div align="center"><b>Entry</b></div>
</td>
</tr>
<tr> <td height="18" width="50%">Two embryos stored in the same cryotube</td>
<td height="18" width="50%"> <p>embryo (lot count = 2)</p>
</td>
</tr>
<tr> <td height="18" width="50%">Two liver samples stored in individual tubes</td>
<td height="18" width="50%"> <p>liver (lot count = 1)<br>
liver (lot count = 1)</p>
</td>
</tr>
<tr> <td height="18" width="50%">Three tubes each containing five nematodes</td>
<td height="18" width="50%">nematode (lot count = 5)<br>
nematode (lot count = 5)<br>
nematode (lot count = 5)</td>
</tr>
<tr> <td height="18" width="50%">Ten vertebrae in a box</td>
<td height="18" width="50%">vertebra (lot count = 10)</td>
</tr>
<tr> <td height="18" width="50%">A jar of five salamanders of the same species from the same collecting event.</td>
<td height="18" width="50%">whole animal (lot count = 5)</td>
</tr>
</table>

<p>
<div class="fldDef">
	Specimen_Part.Sampled_From_Obj_Id<br/>
	NUMBER   null
</div>
<a name="sampled_from" class="infoLink" href="#top">Top</a><br>		
<strong>Sampled From</strong>
designates a part defived from another part.
This is intended to be a subsample supplied to an
investigator for destructive analysis.
Therefore it often applies to parts that are no longer
in the collection, but if the subsamples or extracts
thereof are returned, these can be tracked.
<cfinclude template="/includes/_helpFooter.cfm">