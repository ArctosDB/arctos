<cfif not isdefined("content")>
	<!---- probably a bot ---->
	<cfabort>
</cfif>
<cfinclude template="/includes/_pickHeader.cfm">
<cfoutput>
<div align="left">
<!-------------------------------                a              --------------------------------------->
<!-------------------------------                a              --------------------------------------->
<!-------------------------------                a              --------------------------------------->
<cfif #content# is "accepted_sci_name">
<cfset title="Accepted Scientific Name Help">
Accepted Scientific Name is the name now applied to a cited specimen.
It may or may not be the same as the name applied to the specimen in a 
publication.
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "af_number">
<cfset title="AF Number Help">
AF number is a catalog for the Alaska Frozen Tissue Collection. An individual animal will often have both an AF number and a catalog number. AF numbers have been used to specify UAM specimens in the GenBank database and in some publications.<P>The format for this field is an integer with no prefix.
<p>You may also enter a list of numbers separated by commas.
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "accn_number">
<cfset title="Accession Number Help">
Accession number usually refers to a group of (one or more) specimens received at one time from one source. Many specimens do not have an accession number.
<p>The format for this field is a year with a decimal fraction. For example, the first accession in 1998 would be 1998.001
</cfif>
<!----------------------------------------------------------------------------------------------------->

<!-------------------------------                b              --------------------------------------->
<!-------------------------------                b              --------------------------------------->
<!-------------------------------                b              --------------------------------------->
<cfif #content# is "bounding_box">
A bounding-box search will find georeferenced specimen records within a
user-defined geographic rectangle, or "box."  To define a box, indicate
the coordinates of the northwest and southeast corners in decimal degrees.
<p>
Note that in the decimal-degree format, degrees west and degrees south are
conventionally negative values.  For example, Fairbanks, Alaska is within
a box defined by:
<ul>
	<li>
		Northwest corner: Latitude 64.9 Longitude -148.5
	</li>
	<li>
		Southeast corner: Latitude 64.6 Longitude -147.2
	</li>
</ul>


<p>
Note also that this feature finds only the points defined in specimen
localities.  Records outside the box with a radius of precision (or error)
extending into the box will not be found.  Therefore, make appropriately
big boxes.
</cfif>
<!-------------------------------                c              --------------------------------------->
<!-------------------------------                c              --------------------------------------->
<!-------------------------------                c              --------------------------------------->
<cfif #content# is "cat_num">
	<cfset title="Catalog Number Help">
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
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "collecting_source">
<cfset title="Collecting Source Help">
Collecting Source keeps track of the source of the specimens from a collecting event.
A Collecting Source of "wild caught" indicates a valid distribution record for the taxon.
For any other value of Collecting Source, the distribution is invalid or at least suspect. Accordingly, 
specimens with a Collecting Source other than "wild caught" will not map to BerkeleyMapper.
</cfif>

<cfif #content# is "county">
<cfset title="County Help">
County refers to a division of a state or province such as a county, parish, or &quot;department.&quot; Although much of Alaska is incorporated as boroughs, these are not yet all-inclusive and are not used here. (See <a href="help.cfm?content=quad">USGS map names</a>.)
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "cited_sci_name">
<cfset title="Cited Scientific Name Help">
Cited Scientific Name is the name applied to a specimen in a publication.
It may or may not be the same as the currently accepted name for the 
specimen or for the taxon.
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "customOtherIdentifier">
	<cfset title="Your Other Identifier">
	You may choose one Other Identifier Type to:
	<ul>
		<li>
			Search for, separate from standard Other Identifier search fields, and
		</li>
		<li>
			Display, as a separate column, in your Specimen Results and Download data
		</li>
	</ul>
		<P>The format for searching this field is:
	<ul>
					<li>An integer (9234)</li>
					<li>A comma-delimited list of integers (1,456,7689)</li>
					<li>A hyphen-separated range of integers (1-6)</li>
					<ul>
						<li>
							If you get an error with this search, there is probably a non-numeric value somewhere in the 
							data. Please file a <a href="/info/bugs.cmf" target="_blank">bug report</a> if that is unexpected. 
						</li>
					</ul>
	</ul>
	You must set your search pattern in the dropdown before searching.
</cfif>
<!----------------------------------------------------------------------------------------------------->

<cfif #content# is "custom">
<cfset title="Customized Results Help">
The Detailed Matrix is user customizable. Some queries may fail to run if you have a large number of fields in your results set. Use this link to simplify your results set if you cannot view a detailed matrix.
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "common_name">
<cfset title="Common Name Help">
Common Names have been opportunistically entered into Arctos. Common Name entries should not be viewed as complete, authoritative, or necessarily common. There may be one, many, or no common names for any taxon name.
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "CollStats">
	<cfset title="Collection Stats">
	<cfquery name="stat" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			institution_acronym,
			collection.collection_cde,
			descr,
			count(collection_object_id) as cnt,
			web_link,
			web_link_text
		FROM
			cataloged_item,
			collection
		WHERE
			 collection.collection_id = cataloged_item.collection_id (+)
		GROUP BY 
			institution_acronym,
			collection.collection_cde,
			descr,
			web_link,
			web_link_text
		ORDER BY cnt DESC
	</cfquery>
	<cfquery name="cnt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) as cnt from cataloged_item
	</cfquery>
	<cfquery name="numColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(distinct(collection_id)) as cnt from collection
	</cfquery>
	Summary of specimens represented in Arctos:
	<blockquote>
	<table>
	
	<ul>
		<cfloop query="stat">
			<tr>
				
					<td><li></td>
					<td>#institution_acronym#</td>
					<td>#collection_cde#</td>
					<td>#cnt#</td>
				  <td nowrap><font size="-1">(
				  <cfif len(#web_link#) gt 0>
				  	<a href="#web_link#" target="_blank">#descr#</a>
				  <cfelse>
				  	#descr#
				  </cfif>)</font></td>
				
			</tr>
		</cfloop>
		<tr>
			<td>&nbsp;</td>
			<td colspan="2">
				<hr>
			</td>
			<td><hr></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td colspan="2" align="center">
				#numColl.cnt#
			</td>
			<td>#cnt.cnt#</td>
			<td>&nbsp;</td>
		</tr>
	</ul>
	</table>
	</blockquote>
	<p><a href="/CollectionStats.cfm" target="_blank">Detailed Database Statistics</a></p>
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "collector">
	<cfset title="Collector Help">
	Collector is the name of the person, group, or agency credited with collecting a specimen. 
	Most specimens have one or more names of people as their collector.
	<p>Some collector names are hidden and designated "anonymous," in contrast to those where the name is "unknown." Records in which the collector is screened (displayed as anonymous) cannot be located when a collector name is specified in a query.</p>
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "chronological_extent">
	<cfset title="Chronological Extent Help">
	<strong>Chronological Extent</strong> limits searches to those collecting events spanning 
	less than or equal to the specified number of days. Examples:
	<table border>
		<tr>
			<td><strong>Search Term</strong></td>
			<td><strong>Results</strong></td>
		</tr>
		<tr>
			<td>0</td>
			<td>Find specimens where began_date and ended_date are the same</td>
		</tr>
		<tr>
			<td>3</td>
			<td>Find specimens where the collecting event spans less than three days</td>
		</tr>
		<tr>
			<td>365</td>
			<td>Find specimens where the collecting event spans less than one year</td>
		</tr>
	</table>
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "Citation">
	<cfset title="Citation Statistics">
	<cfquery name="cit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			count(citation.collection_object_id) as cnt,
			taxonomy.scientific_name as scientific_name,
			citName.scientific_name as citName
		FROM
			citation,
			identification,
			taxonomy,
			taxonomy citName
		WHERE
			citation.collection_object_id = identification.collection_object_id AND
			identification.accepted_id_fg = 1 AND
			identification.taxon_name_id = taxonomy.taxon_name_id AND
			citation.cited_taxon_name_id = citName.taxon_name_id
		GROUP BY
			taxonomy.scientific_name,citName.scientific_name
		ORDER BY 
			scientific_name
	</cfquery>
	<table border>
		<tr>
			<td>Accepted Name</td>
			<td>Cited As</td>
			<td>Citations</td>
		</tr>
	
	Citations by Taxonomy:
	<cfloop query="cit">
		<tr>
			<td>#scientific_name#</td>
			<td>#CitName#</td>
			<td>#cnt#</td>
		</tr>
	</cfloop>
	</table>
	<br>Citations by Collection:
	<cfquery name="citColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			count(citation.collection_object_id) as cnt,
			collection.collection_cde,
			collection.institution_acronym
		FROM
			citation,
			cataloged_item,
			collection
		WHERE
			citation.collection_object_id = cataloged_item.collection_object_id AND
			cataloged_item.collection_id = collection.collection_id
		GROUP BY
			collection.collection_cde,
			collection.institution_acronym
		ORDER BY 
			collection.collection_cde,
			collection.institution_acronym
	</cfquery>
	<cfloop query="citColl">
		<br>#institution_acronym# #collection_cde# #cnt#
	</cfloop>
</cfif>
<!----------------------------------------------------------------------------------------------------->

<!-------------------------------                d              --------------------------------------->
<!-------------------------------                d              --------------------------------------->
<!-------------------------------                d              --------------------------------------->
<cfif #content# is "day_collected">
	<cfset title="Day Collected Help">
	A range of days of the month, e.g., 1-5.
	<p><a href="help.cfm?content=date_collected">More information about date searches</a></p>
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "download">
<cfset title="Download Help">
<h2>Download Help</h2>
<ul>
	<li>
		If you have not done so, follow the log-in link in the header to log in or create a user account.
	</li>
	<li>
		You must agree to the terms of usage before you can download data.
	</li>
	<li>
		The first line of the download file contains the column headings.
	</li>
	<li>
		Note that verbatim_date is a text string (datatype is not date) datatype and may contain values such as "Fall 2002.")
	</li>
</ul>

</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "date_collected">
<cfset title="Date Collected Help">
	<P ALIGN=LEFT>Dates for collecting events are recorded in three fields as a span of time where each
collecting event has a start date and an end date. For most
records, these dates are the same. For example: </P>
<UL>
        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm">Verbatim Date: <b>1 July
        2000</b></li>
        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm">Start Date: <b>1 July 2000</b></li>
        <LI><P ALIGN=LEFT>End Date: <b>1 July 2000</b></li>

</UL>
<P ALIGN=LEFT>Nevertheless, many dates reflect the imprecision with
which the collecting event was recorded. For example: </li>
<UL>
        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm">Verbatim Date: <b>summer
        2000</b> (presumably Northern Hemisphere)</li>
        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm">Start Date: <b>1 June 2000</b></li>
        <LI><P ALIGN=LEFT>End Date: <b>31 August 2000</b></li>

</UL>

<P ALIGN=LEFT>Another example:</p>
<ul>
<LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm">Verbatim Date: <b>date unknown</b></li>
        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm">Start Date: <b>1 Jan 1850</b> (A default assumption in the absence of better information.)</li>
        <LI><P ALIGN=LEFT>End Date: <b>15 Jun 2004</b> (Today's date; collection must have occurred before the present.)</li>

</ul>
<P ALIGN=LEFT>With this paradigm, there is no such thing as "date unknown" and data retrieval is limited mostly by the quality of the data recorded.
Searches too can define a span, and will return
collecting events under three matching conditions: 
</P>
<UL>
        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm">Search span is within
        the recorded span: 
        </P>
        <UL>
                <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm"><font color="##C0C0C0">-----</font>|--Searched--|<font color="##C0C0C0">--------</font></P>
                <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm"><font color="##C0C0C0">--</font>|------Recorded-------|<font color="##C0C0C0">--</font></P>

        </UL>

        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm">Recorded span is within the
        searched span: 
        </P>
        <UL>
                <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm"><font color="##C0C0C0">--</font>|------Searched------|<font color="##C0C0C0">--</font></li>
                <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm"><font color="##C0C0C0">----</font>|--Recorded--|<font color="##C0C0C0">--------</font></li>

        </UL>

        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm">Search span overlaps
        part of recorded span: 
        </P>
        <UL>
                <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm"><font color="##C0C0C0">-----------</font>|--Searched--|<font color="##C0C0C0">--</font></li>
                <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm"><font color="##C0C0C0">--</font>|--Recorded--|<font color="##C0C0C0">-----------</font></li>

        </UL>
</UL>

<P ALIGN=LEFT>Notice that in the first condition above, imprecise dates (i.e., large recorded spans) will be returned even though the searched span is smaller.
In other words, the event <i>could have</i> occurred within the searched span.</p>

<P ALIGN=LEFT>The following search fields are provided:</p>
<UL>
        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm"><b>Year Collected:</b> Specify
        a range of years. To specify a single year, enter only began year.
        Format is a 4-digit number, e.g., 1996. 
        </P>

        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm"><b>Month Collected:</b> Specify
        a range of months, e.g., all specimens from January-March. 
        </P>
        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm"><b>Day Collected:</b> A range
        of days of the month, e.g., 1-5. 
        </P>
        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm"><b>Full Date:</b> Specify a
        day, month, and year range. 'dd mmm yyyy' and various other formats
        are recognized. 
        </P>
        <LI><P ALIGN=LEFT><b>Month:</b> Select a (possibly discontinuous) range of
        months. For example, search for winter collecting events, irrespective of year, by
        selecting January, February, November, and December. 
        </P>

</UL>

<P ALIGN=LEFT>Because arguments are joined with Boolean "AND"s, ranges must be in
chronological sequence. For example: 
</P>
<UL>
        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm">Start month: March 
        </li>
        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm">End month: January</li> 
</UL>
<P ALIGN=LEFT>Not valid because March comes after January.</p>
<ul>
        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm">Start Day: 4</li>

        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm">Start Year: 1999 </li>
        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm">Start Month: January </li>
        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm">End Day: 3 </li>
        <LI><P ALIGN=LEFT STYLE="margin-bottom: 0cm">End Year: 1999 </li>
        <LI><P ALIGN=LEFT>End Month: January </li>
</ul>
<P ALIGN=LEFT>Not valid because the query will contain &quot;AND day BETWEEN 4 and 3.&quot; </p>

<P ALIGN=LEFT STYLE="margin-bottom: 0cm"><BR><A HREF="javascript: void(0);" ONCLICK="javascript: self.close()">Close
this window</A> 
</P>

</cfif>
<!----------------------------------------------------------------------------------------------------->


<cfif #content# is "detail_level">
	<cfset title="Specimen Results Help">
	There are four levels of detail available on the Specimen Results page. Level 1 is basic summary data, level 4 is most of the data available for a specimen.
	<p>You may temporarily customize detail level by clicking the buttons at the bottom of Specimen Results, or you may add Detail Level to your <a href="/login.cfm" target="_blank">user preferences.</a></p>
	<p>
		Level 1:
	<ul>
				<li>Catalog Number</li>
				<li>Scientific Name</li>
				<li>Country</li>
				<li>State</li>
				<li>Specific Locality</li>
				<li>Parts</li>
				<li>Sex</li>
	</ul>
	</p>
	<p>
		Level 2:
	<ul>
				<li>AF Number</li>
				<li>Other Identifiers</li>
				<li>Accession</li>
				<li>Collectors</li>
				<li>Latitude and Longitude</li>
				<li>Map Name</li>
				<li>Feature</li>
				<li>County</li>
				<li>Specimen Remarks</li>
				<li>Specimen Disposition</li>
	</ul>
	</p>
	<p>
		Level 3:
	<ul>
				<li>Attributes</li>
	</ul>
	</p>
	<p>
		Level 4:
	<ul>
				<li>Attribute Details</li>
				<li>Coordinate Details</li>
				<li>Decimal Latitude and Decimal Longitude</li>
				<li>Other Identifiers in individual columns</li>
	</ul>
	</p>
</cfif>

<!----------------------------------------------------------------------------------------------------->
<!-------------------------------                e              --------------------------------------->
<!-------------------------------                e              --------------------------------------->
<!-------------------------------                e              --------------------------------------->


<!-------------------------------                f              --------------------------------------->
<!-------------------------------                f              --------------------------------------->
<!-------------------------------                f              --------------------------------------->
<cfif #content# is "fulldate_collected">
	<cfset title="Date Collected Help">
	Specify a day, month, and year range. 'dd mmm yyyy' and various other formats are recognized.
	<p><a href="help.cfm?content=date_collected">More information about date searches</a></p>
</cfif>
<!----------------------------------------------------------------------------------------------------->


<!-------------------------------                g              --------------------------------------->
<!-------------------------------                g              --------------------------------------->
<!-------------------------------                g              --------------------------------------->
<cfif #content# is "geog">
<cfset title="Geographic Element Help">
	Search on any substring contained in geographic categories other than specific locality.
	<p>
	
	For example, the string "denali" would return records from:
	<ul>
				<li>Denali National Park</li>
				<li>Denali National Preserve</li>
				<li>Denali State Park</li>
	</ul>
			Arctos records the following fields:
	<ul>
		<li>Continent/Ocean</li>
		<li>Country</li>
		<li>State/Province</li>
		<li>County</li>
		<li>Quad (USGS Map Name)</li>
		<li>Feature</li>
		<li>Sea</li>
		<li>Island Group</li>
		<li>Island</li>
	</ul>
		
	</p>
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "get_proj_name">
	<cfset title="Find Project Name">
	<cfquery name="projName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select distinct(project_name) from project order by project_name
	</cfquery>
	Click a Project Name to select.
	<p></p>
	<cfloop query="projName">
		<a href="javascript: void(0);" onClick="opener.document.SpecData.project_name.value='#project_name#';self.close();"><div style="text-indent:-2em;padding-left:2em;">#project_name#</div></a>
	</cfloop>
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "get_permit_number">
	<cfset title="Find Permits">
	<cfparam name="permit_num" default="">
	<cfparam name="issuer" default="">
	<cfparam name="issuee" default="">
	Select a permit below or search here:
	<table cellspacing="0" cellpadding="0">
	<form name="perSch" method="post" action="help.cfm">
		<input type="hidden" name="content" value="get_permit_number">
		<tr>
			<td>Number:</td>
			<td><input type="text" name="permit_num"></td>
		</tr>
		<tr>
			<td>Issued To:</td>
			<td><input type="text" name="issuee"></td>
		</tr>
		<tr>
			<td>Issued By:</td>
			<td><input type="text" name="issuer"></td>
		</tr>
		<tr>
			<td colspan="2"><input type="submit"></td>
		</tr>
	</form>
	</table>
	<cfquery name="perm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			ISSUED_BY.agent_name issuer,
			ISSUED_DATE,
			ISSUED_TO.agent_name issuee,
			RENEWED_DATE, 
			EXP_DATE,
			PERMIT_NUM,
			PERMIT_TYPE
		FROM
			permit,
			preferred_agent_name ISSUED_BY,
			preferred_agent_name ISSUED_TO
		WHERE
			permit.ISSUED_TO_AGENT_ID = ISSUED_TO.agent_id (+) AND
			permit.ISSUED_BY_AGENT_ID = ISSUED_BY.agent_id (+)
		<cfif len(#permit_num#) gt 0>
			AND upper(permit_num) LIKE '%#ucase(permit_num)#%'
		</cfif>
		<cfif len(#issuer#) gt 0>
			AND upper(ISSUED_BY.agent_name) LIKE '%#ucase(issuee)#%'
		</cfif>
		<cfif len(#issuer#) gt 0>
			AND upper(ISSUED_TO.agent_name) LIKE '%#ucase(issuer)#%'
		</cfif>
	</cfquery>
	Click a Permit to select.
	<p></p>
	<cfloop query="perm">
		<cfset thisPerm="#permit_Num# (#permit_Type#) issued to #issuee# by #issuer# on #dateformat(issued_Date,"dd mmm yyyy")#">
		<a href="javascript: void(0);" onClick="opener.document.SpecData.permit_num.value='#PERMIT_NUM#';self.close();"><div style="text-indent:-2em;padding-left:2em;">#thisPerm#</div></a>
	</cfloop>
</cfif>
<!----------------------------------------------------------------------------------------------------->

<!-------------------------------                h              --------------------------------------->
<!-------------------------------                h              --------------------------------------->
<!-------------------------------                h              --------------------------------------->
<cfif #content# is "higher_taxa">
<cfset title="Taxonomy Help">
Search for any part of the full taxon name (ie, family or subspecies). Arctos taxonomy records:
<ul>
	<li>Class</li>
	<li>Order</li>
	<li>Suborder</li>
	<li>Family</li>
	<li>Subfamily</li>
	<li>Genus</li>
	<li>Subgenus</li>
	<li>Species</li>
	<li>Subspecies</li>
</ul>
Data are often incomplete.
</cfif>
<!----------------------------------------------------------------------------------------------------->

<!-------------------------------                i              --------------------------------------->
<!-------------------------------                i              --------------------------------------->
<!-------------------------------                i              --------------------------------------->
<cfif #content# is "island">
<cfset title="Island Help">
Many Alaska specimens were collected on an island and there are some duplicate (and even triplicate) island names among the thousands of islands in Alaska. You may therefore need to specify some other paramater in order to get a particular &quot;Green Island.&quot;
<p>You may find specimens for which island is not recorded by searching for "NULL" (without the quotes; this feature is<b></b> case sensitive) in Island.</p>
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "incl_date">
	<cfset title="Date Search Help">
	Restrict date searches to matches exclusively included within the time specified.
	For example, searching for Full Date Collected = 1 Jan 1999 -> 31 Jan 1999 will:
	<ul>
		<li>With Inclusive Date Search:</li>
		<ul>
			<li>
				Return only specimens with a Began Date on or after 1 Jan 1999 and an Ended Date on or before 31 Jan 1999
			</li>
		</ul>
		<li>Without Inclusive Date Search:</li>
		<ul>
			<li>
				Return specimens as described for normal date searches (see <a href="help.cfm?content=date_collected">Documentation</a>).
			</li>
		</ul>
	</ul>
	<p><a href="help.cfm?content=date_collected">More information about date searches</a></p>
</cfif>
<!----------------------------------------------------------------------------------------------------->

<!-------------------------------                j              --------------------------------------->
<!-------------------------------                j              --------------------------------------->
<!-------------------------------                j              --------------------------------------->

<!-------------------------------                k              --------------------------------------->
<!-------------------------------                k              --------------------------------------->
<!-------------------------------                k              --------------------------------------->
<cfif #content# is "kill_row">
	Add a column to the Specimen Results grid allowing you to remove
individual records from the result set.  Use the checkboxes on the
undesired rows, then click the scissors icon at the top of the column.
<p>
(Re-executes your query but includes the clause(s) "AND NOT
Collection_Object_id = 99999.")
</p>
</cfif>

<!-------------------------------                l              --------------------------------------->
<!-------------------------------                l              --------------------------------------->
<!-------------------------------                l              --------------------------------------->

<!-------------------------------                m              --------------------------------------->
<!-------------------------------                m              --------------------------------------->
<!-------------------------------                m              --------------------------------------->
<cfif #content# is "max_error_in_meters">
	<cfset title="Maximum Error Help">
	Maximum Error filters based on the maximum error recorded with the accepted coordinate
	determination. 
	<ul>
		<li>
			Maximum error describes the radius of a circle originating at the coordinates given. 
			This error is intended to be large enough to ensure that the specimen must have come
			from within it.
		</li>
		<li>
			Determinations with a maximum error of 0 are assumed to mean "maximum error not determined" 
			and not "perfectly precise" and will not match searches including a maximum error
			of greater than zero.
		</li>
		<li>
			Search for maximum error=0 to include those specimens with a recorded maximum error 
			of 0.
		</li>
		<li>
			Search for a very large maximum error (999999 should be sufficient) to find all georeferenced
			specimens.
		</li>
	</ul>
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "month_collected">
	<cfset title="Month Collected Help">
	Specify a range of months, e.g., all specimens from January-March.
	<p><a href="help.cfm?content=date_collected">More information about date searches</a></p>
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "month_in">
	<cfset title="Month Collected Help">
	Select a (possibly discontinuous) range of months. For example, search for winter-collected specimens by selecting January, February, November, and December.
	<p><a href="help.cfm?content=date_collected">More information about date searches</a></p>
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "map">
	<cfset title="Map Help">
	There are currently two mapping applications with which to map Arctos specimen records. Both are JAVA applications, and both are known to have problems with some browsers/platforms.
	<p>
		DLP is the Digital Library Project at the University of California Berkeley. A fast internet connection is recommended.
	</p>
	<p>
		CBIF is the Canadian Biological Information Facility. This application maps points only. No measure of imprecision is mapped.
	</p>
</cfif>
<!----------------------------------------------------------------------------------------------------->

<!-------------------------------                n              --------------------------------------->
<!-------------------------------                n              --------------------------------------->
<!-------------------------------                n              --------------------------------------->

<!-------------------------------                o              --------------------------------------->
<!-------------------------------                o              --------------------------------------->
<!-------------------------------                o              --------------------------------------->
<cfif #content# is "other_id_num">
<cfset title="Other Identifier Help">
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
</cfif>
<!----------------------------------------------------------------------------------------------------->

<cfif #content# is "other_id_type">
<cfset title="Other Identifier Help">
	All identifiers other than the Institutional Catalog Number are recorded as Other Identifiers. This includes:
	<ul>
		<li>AF Number</li>
		<li>GenBank sequence accession</li>
		<li>original field number (AKA collector's catalog number)</li>
		<li>other institution's catalog numbers</li>
	</ul>
	Data recorded at the time of collection are typically entered as original field number, regardless of the collector's terminology.
	
	<p>
		You may search for all specimens having a particular identifier by entering only the identifier type and not the actual identifier. For example, to find all marmots with GenBank sequence accessions, search for:
	<ul>
				<li>Scientific Name = "Marmota" (or Common Name="Marmot" or Full Taxonomy="Marmota")</li>
				<li>Other Identifier Type = "GenBank sequence accession"</li>
	</ul>
	</p>
</cfif>
<!----------------------------------------------------------------------------------------------------->

<cfif #content# is "onlyCited">
	<cfset title="Publication Search Help">
	Publications are associated with specimens in two ways: 
	<ol>
		<li>Citations explicitly link a particular specimen to a particular page.</li>
		<li>Some publications are associated only with a project. The project either used or contributed specimens; the publication is based (to some extent) on specimens associated with the project.</li>
	</ol>
	
	<p>Check <b>Cite specimens only?</b> to exclude publications that do not cite specimens from your search results.</p>
		
	</ul>
</cfif>
<!----------------------------------------------------------------------------------------------------->

<!-------------------------------                p              --------------------------------------->
<!-------------------------------                p              ---------------------------------------><!-------------------------------                p              --------------------------------------->
<cfif #content# is "parts">
<cfset title="Parts Help">
Search for specimens having the selected part. Most mammal specimens have multiple parts (ie, skin; skull). Note that parts includes frozen tissue samples.
<p>Frozen tissues of any type can be found by specifying a Preservation Method of "frozen" without specifying Parts.</p>
</cfif>
<!----------------------------------------------------------------------------------------------------->

<!-------------------------------                q              --------------------------------------->
<!-------------------------------                q              --------------------------------------->
<!-------------------------------                q              --------------------------------------->
<cfif #content# is "quad">
<cfset title="Quad Help">
USGS map
names are the names of the U.S. Geological Survey's 1:250,000 series maps. These
form a grid over the entire state and are often intuitive, e.g., Nome, Barrow,
Sitka, etc.
<p>Use the <img src="../images/info.gif" border="0"> button near the Map Name field to select names from a map.</p>

<p>You may find specimens for which map name is not recorded by searching for "NULL" (without the quotes; this feature is<b></b> case sensitive) in Map Name.</p>
</cfif>

<!----------------------------------------------------------------------------------------------------->


<!-------------------------------                r              --------------------------------------->
<!-------------------------------                r              --------------------------------------->
<!-------------------------------                r              --------------------------------------->

<!-------------------------------                s              --------------------------------------->
<!-------------------------------                s              --------------------------------------->
<!-------------------------------                s              --------------------------------------->
<cfif #content# is "show_observations">
<cfset title="Show Observations">
		Observations are events in which specimens were observed, presumably by reliable sources,
		but not collected. Any event is which biological material was collected is probably not an observation. Photographs are observations, as are sound recordings and other media documenting the presence of specimens. Observations may also be entirely deviod of documentation. It is up to the user to determine the credibility of observations.
</cfif>

<cfif #content# is "spec_locality">
<cfset title="Specific Locality Help">
		Specific Locality in the most explicit text description provided with a specimen.
		<p>For example: "14 Km W of Jonesville"</p>
		<p>Most useful when searched by substring. For example, "Jones."</p>
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "state_prov">
<cfset title="State or Province Help">
Examples: Alaska, British Columbia,  Chukotka
</cfif>
<!----------------------------------------------------------------------------------------------------->
<cfif #content# is "scientific_name">
<cfset title="Scientific Name Help">
The scientific name is generally the taxon name of an organism. Most specimens are identified to genus, species, 
	and occasionally subspecies. We have made exceptions, including:
	<ul>
		<li>Genus + "sp." (<i>Sorex sp.</i>)</li>
			<ul>
				<li>
					Note that Arctos does not consider "<i>Sorex sp.</i>" a species; 
					the identification is a concatenation of a valid genus and the string "sp."
				</li>
			</ul>
		<li>Species A or Species B (<em>Sorex cinereus</em> or <em>Sorex ugyunak</em>)</li>
		<li>Species + "?" (<em>Sorex cinereus</em> ?)</li>
		<li>Species A x Species B (<em>Bos grunniens</em> x <em>Bos taurus</em>)</li>
			<ul>
				<li>
					Hybrids in Arctos are an identification combining parent taxa, not new taxa. Any combination may be recorded, 
					although only "A x B" have been used as of this writing.
				</li>
			</ul>
	</ul>
Substrings will return records containing the specified substring in any of these three fields. 
(Turn on "Advanced Scientific Name" in your preferences to match exact strings or exclude taxa.)<br>For example, searching on &quot;mus&quot; would return records for the following taxa (among others):
<ul>
	<li><b>Mus</b> <b>mus</b>culus</li>
	<li><b>Mus</b>tela ...</li>
	<li>Arbori<b>mus</b> ...</li>
</ul>
<p>The "is/was/cited/related" option in Advanced Scientific Name will match specimens having:
	<ul>
		<li>Current accepted scientific names</li>
		<li>Unaccepted scientific names (resulting from re-identifications, taxon revisions, etc.)</li>
		<li>Cited scientific names, including erroneous citations</li>
		<li>Related scientific names, such as synonomies</li>
	</ul>
</p>
<p>For information on the taxonomy used here, including common names and synonomies, see <a href="/TaxonomySearch.cfm" target="_blank">Arctos Taxonomy</a>.
</cfif>
<!----------------------------------------------------------------------------------------------------->
<!-------------------------------                t              --------------------------------------->
<!-------------------------------                t              --------------------------------------->
<!-------------------------------                t              --------------------------------------->
<cfif #content# is "taxonomy_anything">
	Any Category searches against field Higher_Taxonomy, a concatenation of all known elements. For example,
	<ul>
		<li>
			Mammalia Chiroptera Vespertilionidae Myotis velifer grandis
		</li>
	</ul>
</cfif>
<cfif #content# is "taxonomy_scientific_name">
	Scientific Name, as used in Taxonomy (as opposed to <a href="help.cfm?content=scientific_name">Identification</a> scientific name) 
	is typically a concatenation of Genus, Species, and, if it exists, Subspecies. Taxonomy Scientific Name will never
	includes hybrids, ".sp," or other strings or combinations of taxa. Where any level above Subspecies does not exist, 
	Taxonomy Scientific Name will simply be the lowest term given. Valid Taxonomy Scientific Names include:
	<ul>
		<li>Chiroptera (an Order)</li>
		<li>Myotis (a Genus)</li>
		<li>Myotis velifer (a concatenation of Genus and Species)</li>
		<li>Myotis velifer grandis (a concatenation of Genus, Species, and Subspecies)</li>
	</ul>
</cfif>
<!-------------------------------                u              --------------------------------------->
<!-------------------------------                u              --------------------------------------->
<!-------------------------------                u              --------------------------------------->

<!-------------------------------                v              --------------------------------------->
<!-------------------------------                v              --------------------------------------->
<!-------------------------------                v              --------------------------------------->
<cfif #content# is "verbatim_date">
	<cfset title="Verbatim Date Collected Help">
	Verbatim Date is a text field that typically contains a single date. Date formats have not been consistent; 1 July 2000 could be represented as:
		<ul>
			<li>1 July 2000</li>
			<li>1 Jul 2000</li>
			<li>Jul 1 2000</li>
			<li>1/7/00</li>
		</ul>
		or any number of other formats.
		<p>
			Verbatim date is most useful to represent a range of dates, e.g.,
	<ul>
				<li>Summer 2002</li>
				<li>Before 1 July 2002</li>
				<li>1940s</li>
	</ul>
		</p>
	<p><a href="help.cfm?content=date_collected">More information about date searches</a></p>
</cfif>

<!-------------------------------                w              --------------------------------------->
<!-------------------------------                w              --------------------------------------->
<!-------------------------------                w              --------------------------------------->

<!-------------------------------                x              --------------------------------------->
<!-------------------------------                x              --------------------------------------->
<!-------------------------------                x              --------------------------------------->

<!-------------------------------                y              --------------------------------------->
<!-------------------------------                y              --------------------------------------->
<!-------------------------------                y              --------------------------------------->
<cfif #content# is "year_collected">
	<cfset title="Year Collected Help">
	Specify a range of years. To specify a single year, enter only began year. Format is a 4-digit number, e.g., 1996.
	<p><a href="help.cfm?content=date_collected">More information about date searches</a></p>
</cfif>
<!----------------------------------------------------------------------------------------------------->


<!-------------------------------                z              --------------------------------------->
<!-------------------------------                z              --------------------------------------->
<!-------------------------------                z              --------------------------------------->


<p align="right"><a href="javascript: void(0);" onClick="javascript: self.close()">Close this window</a>

</cfoutput>
</div>
<cfinclude template="/includes/_pickFooter.cfm">
