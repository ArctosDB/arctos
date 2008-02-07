<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Collecting Events">

<font size="-2"><a href="index.cfm">Help</a> >> <a href="definitions_standards_index.cfm">Definitions and Standards</a> >> <strong>Collecting Events</strong></font><br />
<font size="+2">Collecting Events </font>
<p>
<table border="0" align="left" cellpadding="10">
<tr><td>
	<cfinclude template="includes/collecting_event_idx.cfm">
</td></tr></table>
A collecting event is a place and time where collecting occurred. 
It may also include a collecting method, though this is most often unspecified or assumed.
A collecting event often applies to more than one catalogued specimen, so be careful that
changes you make to a collecting event apply to all of the specimens.
<strong>New Collecting Events</strong> are normally created
  when specimen records are bulkloaded. To manually create a collecting event:
<ul>
  	<li>Find a similar Collecting Event with Locality Search.</li>
    <li>Click the Clone button to clone (and edit) the event.</li>
    <li>Change Locality for the event if necessary.</li>
</ul>
Locality, time, and method are attributes of a collecting event:

<p><strong>Locality</strong> itself is really an identifying key to a separate table 
	because a locality may apply to more than one collecting event (See documentation
	of <a href="locality.cfm">Localities</a>).
	Nevertheless, the following are place-related components of Collecting Events:
		<ul>
			<li>
			<div class="fldDef">
				Collecting_Event . Verbatim_Locality<br/>
				VARCHAR(255) not null
			</div>
			<a name="verbatim_locality"></a>
			<strong>Verbatim Locality</strong> 
			is the locality description as provided by the collector and  is specific
			to the Collecting Event, not to the Locality. 
			The same Locality may have been described differently at different times, and this distinction
			allows us to incorporate assumptions about the locality into 
			Specific Locality while maintaining the original verbage in Verbatim Locality. 
			Verbatim Locality may include any locality descriptors as 
			written verbatim in field notes or on a specimen 
			tag - whatever the collector wrote, warts and all. 
			If the locality is outside of the U.S., include the higher 
			geography as given verbatim by the collector. 
			Verbatim Locality is not often displayed.</li>
			<li>
			<div class="fldDef">
				Collecting_Event . Habitat_Desc<br/>
				VARCHAR(255) null
			</div>
			<a name="habitat"></a>
			<strong>Habitat</strong> can describe the general habitat 
			(not the microhabitat) from which the specimen was collected.
			For example:
				<ul>
					<li>spruce forest</li><li>shrub tundra</li>
				</ul>
			Although consistent vocabulary is desirable, this is an uncontrolled text field. 
			This field is distinct from Microhabitat, which is associated with Collection Objects. 
			Thus, specimens may have been collected from a locality where the habitat is spruce forest,
			but individual specimens may have been collected from microhabitats such as 
			&quot;decayed spruce log,&quot;  &quot;viburnum leaves,&quot; and &quot;red-squirrel midden.&quot; </li>
			<li>
			<div class="fldDef">
				Collecting_Event . Valid_Distribution_fg<br/>
				TINY INTEGER not null
			</div>
			<a name="valid_distribution"></a>
			<strong>Valid Distribution:</strong> This is a flag to mark the collecting 
			event as being valid for use in determinations of natural distributions. 
			It should be "yes" if the specimens were collected 
			from the wild at the given date and location.
			It should be "no" if the locality refers to something &quot;unnatural&quot; like a zoo or garden.
			Usually this is obvious, but there is legitimate ambiguity in distinguishing a recent escape, such as
			a crocodile in the Yukon River, from an established introduction, such as
			Norway Rats in Juneau.</li>
		<li>
			<div class="fldDef">
				Collecting_Event . Collecting_Source<br/>
				VARCHAR(15) not null
			</div>
			<a name="collecting_source"></a>
			<strong><a name="">Collecting Source:</a></strong> This field keeps track of the 
			source for of the specimens from a collecting event.
			A Collecting Source of "wild caught" indicates a valid distribution record for the taxon. 
			For any other value of Collecting Source, the distribution is invalid or at least suspect.
			Accordingly, specimens with a Collecting Source other than "wild caught" will not map to BerkeleyMapper. 
			Other possible values in the controlled vocabulary for this field are include:
 			"aviary", "breeder", "captive", "customs", "lab", "market", "pet shop", 
 			"supply company", and "zoo".</li>
		</ul>
	<a name="time" class="infoLink" href="#top">Top</a><br>
	<strong>Time</strong>, in the context of collecting events, refers to when specimens were removed from the nature.
	In contrast, Verbatim Preservation Date refers to when an organism ceased to grow or change (<i>i.e.</i>, died), and is an 
	<a href="attributes.cfm">attribute</a> of the specimen, not an attribute of the collecting event.
	(In the absence of a value for Verbatim Preservation Date, it is assumed to be the same as the Verbatim Date.)</li>	
	<ul>
	<li>
		<div class="fldDef">
			Collecting_Event . Verbatim_Date<br/>
			VARCHAR(60) not null
		</div>
	<a name="verbatim_date"></a>
	<strong>Verbatim Date:</strong> is usually a transcription of the 
	date provided by the collector.  If it is an unambiguous date, then some editing for
	standardization may be justified.  (This is the value printed to labels and displayed
	in public interfaces to the data.) If the collection date is given as
 	&quot;unknown,&quot; then a value such as &quot;before 14 Jan 2005&quot; 
 	should be entered. (The time is never completely unknown. 
 	We always know that a specimen in hand was collected before the present.) 
	</li>
	<li>
		<div class="fldDef">
			Collecting_Event . Began_Date<br/>
			Collecting_Event . Ended_Date<br/>
			DATETIME not null
		</div>
	<a name="began_date"></a>
	<strong>Began Date</strong> and <strong>End Date:</strong>
	These delimit the range of dates encompassed by the Verbatim Date.
	For examples of how they are used, see the
	<cfoutput>
	<a href="#Application.ServerRootUrl#/info/help.cfm?content=date_collected"> user help document</a>.
	</cfoutput>
 	Unlike Verbatim Date, they are real date values, not an indeterminate character string. 
	If the Verbatim Date is a valid date, then both the Began Date and the End Date 
 	should be the same as the Verbatim Date. 
	If the Verbatim Date is unknown or vague,  put  the latest possible date in the End Date field 
 	(e.g., the date the specimen was received or accessioned), and the earliest  date on which the specimen could have been collected in Began Date. 
 	Often this can be assumed on basis of known history, such as the life span of the collector, etc. 
	</li></ul>
	<p>
 	The following examples are instructive:
	<table BORDER="2" CELLSPACING="2">
			<tr>
			  <th width="111">Verbatim Date</th> 
			  <th width="91">Began Date</th> 
			  <th width="86">End Date</th>
			  <th width="450">Comment</th>
			</tr>
			<tr>
			  <td>October 14, 1959 </td>
			  <td>14 Oct 1959 </td>
			  <td>14 Oct 1959 </td>
		      <td>&nbsp;</td>
		  </tr>
			<tr><td>1907</td> <td>01 Jan 1907</td> <td>31 Dec 1907</td>
			  <td>&nbsp;</td>
			</tr>
			<tr><td>Feb 2000</td> <td>01 Feb 2000</td> <td>29 Feb 2000</td>
			  <td>&nbsp;</td>
			</tr>
			<tr><td>early March 1999</td> <td>01 Mar 1999</td> <td>15 Mar 1999</td>
			  <td>&nbsp;</td>
			</tr>
			<tr><td>mid-April 1956</td> <td>11Apr 1956</td>
			<td>20 Apr 1956</td>
			<td>&nbsp;</td>
			</tr>
			<tr><td>late-May 1942</td> <td>15 May 1942</td>
			<td>31 May 1942</td>
			<td>&nbsp;</td>
			</tr>
			<tr><td>spring 1906</td> <td>21 Mar 1906</td> <td>20 Jun 1906 </td>
			  <td>Assumes temperate northern hemisphere.</td>
			</tr>
			<tr><td>summer 1910</td> <td>21 Jun 1910</td> <td>20 Sep 1910 </td>
			  <td>Assumes temperate northern hemisphere.</td>
			</tr>
			<tr><td>fall 1937</td> <td>21 Sep 1937</td> <td>20 Dec 1937 </td>
			  <td>Assumes temperate northern hemisphere.</td>
			</tr>
			<tr>
			  <td>winter 00/01 </td> <td>21 Dec 1899</td> <td>20 Mar 1900 </td>
			  <td>Assumes temperate northern hemisphere and beginning of 20th Century.</td>
		</tr>
			<tr>
			  <td>before 2003 </td>
			  <td>1 Jan 1900 </td>
			  <td>31 Dec 2002 </td>
		      <td>Assumes 20th Century or more recent.</td>
		  </tr>
		</table>
<p>
<div class="fldDef">
	Collecting_Even . Date_Interpreted_By_Agent_id<br/>
	INTEGER not null
</div>
<a name="date_determiner" class="infoLink" href="#top">Top</a><br>
<strong>Date Determiner</strong> is the agent who interpreted or determined began and ended dates.
</p>
<p>
<div class="fldDef">
	Collecting_Even . Collecting_Method<br/>
	VARCHAR(50) null
</div>
<a name="collecting_method"></a>
<strong>Collecting Method</strong> is not yet widely used. 
	It will be of particular importance in groups such as marine invertebrates. 
	If animals are sampled but not removed from the wild, then the method
	"biopsy" should be indicated.
	If the organism was not obtained from the wild, then methods such as
	"purchased," "cultivated," or "bred in captivity" should be indicated.

<cfinclude template="/includes/_helpFooter.cfm">