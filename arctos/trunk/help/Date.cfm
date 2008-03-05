te<cfinclude template="../includes/_pickHeader.cfm">
<b>Date</b>
<p></p>
	Dates for collecting events are recorded in three fields as a span of time where each
collecting event has a start date and an end date. For most
records, these dates are the same. For example: </P>
<UL>
        <LI>Verbatim Date: <b>1 July
        2000</b></li>
        <LI>Start Date: <b>1 July 2000</b></li>
        <LI>End Date: <b>1 July 2000</b></li>

</UL>
Nevertheless, many dates reflect the imprecision with
which the collecting event was recorded. For example: </li>
<UL>
        <LI>Verbatim Date: <b>summer
        2000</b> (presumably Northern Hemisphere)</li>
        <LI>Start Date: <b>1 June 2000</b></li>
        <LI>End Date: <b>31 August 2000</b></li>

</UL>

Another example:</p>
<ul>
<LI>Verbatim Date: <b>date unknown</b></li>
        <LI>Start Date: <b>1 Jan 1850</b> (A default assumption in the absence of better information.)</li>
        <LI>End Date: <b>15 Jun 2004</b> (Today's date; collection must have occurred before the present.)</li>

</ul>
With this paradigm, there is no such thing as "date unknown" and data retrieval is limited mostly by the quality of the data recorded.
Searches too can define a span, and will return
collecting events under three matching conditions: 
</P>
<UL>
        <LI>Search span is within
        the recorded span: 
        </P>
        <UL>
                <LI><font color="#C0C0C0">-----</font>|--Searched--|<font color="#C0C0C0">--------</font></P>
                <LI><font color="#C0C0C0">--</font>|------Recorded-------|<font color="#C0C0C0">--</font></P>

        </UL>

        <LI>Recorded span is within the
        searched span: 
        </P>
        <UL>
                <LI><font color="#C0C0C0">--</font>|------Searched------|<font color="#C0C0C0">--</font></li>
                <LI><font color="#C0C0C0">----</font>|--Recorded--|<font color="#C0C0C0">--------</font></li>

        </UL>

        <LI>Search span overlaps
        part of recorded span: 
        </P>
        <UL>
                <LI><font color="#C0C0C0">-----------</font>|--Searched--|<font color="#C0C0C0">--</font></li>
                <LI><font color="#C0C0C0">--</font>|--Recorded--|<font color="#C0C0C0">-----------</font></li>

        </UL>
</UL>

Notice that in the first condition above, imprecise dates (i.e., large recorded spans) will be returned even though the searched span is smaller.
In other words, the event <i>could have</i> occurred within the searched span.</p>

The following search fields are provided:</p>
<UL>
        <LI><b>Year Collected:</b> Specify
        a range of years. To specify a single year, enter only began year.
        Format is a 4-digit number, e.g., 1996. 
        </P>

        <LI><b>Month Collected:</b> Specify
        a range of months, e.g., all specimens from January-March. 
        </P>
        <LI><b>Day Collected:</b> A range
        of days of the month, e.g., 1-5. 
        </P>
        <LI><b>Full Date:</b> Specify a
        day, month, and year range. 'dd mmm yyyy' and various other formats
        are recognized. 
        </P>
        <LI><b>Month:</b> Select a (possibly discontinuous) range of
        months. For example, search for winter collecting events, irrespective of year, by
        selecting January, February, November, and December. 
        </P>

</UL>

Because arguments are joined with Boolean "AND"s, ranges must be in
chronological sequence. For example: 
</P>
<UL>
        <LI>Start month: March 
        </li>
        <LI>End month: January</li> 
		<blockquote>
			is not valid because March comes after January.
		</blockquote>
</UL>

<ul>
        <LI>Start Day: 4</li>

        <LI>Start Year: 1999 </li>
        <LI>Start Month: January </li>
        <LI>End Day: 3 </li>
        <LI>End Year: 1999 </li>
        <LI>End Month: January </li>
		<blockquote>
			is not valid because the query will contain &quot;AND day BETWEEN 4 and 3.&quot;
		</blockquote>
</ul>



<cfinclude template="../includes/_pickFooter.cfm">