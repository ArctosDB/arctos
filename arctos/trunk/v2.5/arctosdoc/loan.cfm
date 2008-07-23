<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Arctos Help: Loans">

<font size="-2"><a href="index.cfm">Help</a> >> <a href="definitions_standards_index.cfm">Definitions and Standards</a> >> <strong>Loans</strong></font><br />
<font size="+2">Loans</font>
<p><b>Definition:</b><br/>
The concept of a specimen loan is broad and includes any removal
of specimens from a collection, temporary or permanent, with the exception of specimens
that are destroyed. 
("Discarded" is a specimen disposition.)
Specimens which are permanently transferred to another collection or institution 
are loans of the the type, "transfer of custody" (in place of the oxymoron, 
"permanent loan").
The type "transfer of title" could be added when and if we include collections
that are willing to release title to catalogued specimens.</p>

<p>In order to associate specimens with in-house projects or the projects of
visiting researchers, the concept of loans can be further extended to include
in-house usage.
When users of specimens fail to cite these specimens in their publications,
a degree of documentation, albeit indirect, exists in that the specimens are associated
with a loan, which is associated with a project, which can be associated with the 
publication.</p>

<p>A specimen "exchange" between collections is two transactions: 
A loan and an accession.  
This arrangement well reflects the reality of incompleted exchanges, 
and takes advantage of the fact that we are dealing with both 
outgoing specimens and incoming specimens.</p>


<p>
<div class="fldDef">
	Lat_Long . Loan_Number<br/>
	VARCHAR(20) not null
</div>	
<a name="loannum" class="infoLink" href="#top">Go to top...</a><br>
<strong>Loan Number</strong></p>
A Loan "number" is comprised of four parts:
<ul>
	<li>Institution: the institution controlling the loan</li>
	<li>Prefix: Typically, the year the loan was initiated. Character, not required.</li>
	<li>Number: Required, Integer.</li>
	<li>Suffix: Generally, the collection controlling the loan. Character, not required.</li>
</ul>
<a name="to" class="infoLink" href="#top">Go to top...</a><br>
<p><strong>To</strong></p>
The person responsible for the loan. Where a loan is made to a student, 
this should be the advisor.
<a name="auth" class="infoLink" href="#top">Go to top...</a><br>
<p><strong>Authorized By</strong></p>
The person responsible for initiating the loan. 
If multiple people must approve a loan, enter one 
(typically the senior curator) and record additional information in Remarks.

<a name="type" class="infoLink" href="#top">Go to top...</a><br>
<p><strong>Type</strong></p>
Loan type serves to categorize the loan. 
If multiple types apply, enter the most important one (<i>i.e.</i>, "returnable").</p>

<p>Initiated Date - not null</p>
<p>Due Date - null</p>
<p>Shipping Date - null</p>
<p>Receipt Acknowledged Date - null</p>
<p>Returned Date - null</p>


<cfinclude template="/includes/_helpFooter.cfm">





