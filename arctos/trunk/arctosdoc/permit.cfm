<cfinclude template="/includes/_helpHeader.cfm">
<cfset title = "Permits">
<font size="-2"><a href="index.cfm">Help</a> >> <a href="definitions_standards_index.cfm">Definitions and Standards</a> >> <strong>Permits</strong></font><br />
<font size="+2">Permits</font>
<p>
<table border="0" align="left" cellpadding="10">
<tr><td>
	<cfinclude template="includes/permit_idx.cfm">
</td></tr></table>
Permits are documentation authorizing transactions such as 
<a href="accession.cfm">Accessions</a> and <a href="loan.cfm">Loans</a>.
In general, permits are issued by governmental agencies, but letters authorizing 
collecting activities on private land can also be considered permits.
Some &quot;registrations&quot; may also constitute permits.
For example, museums can do international exchanges of specimens of endangered 
species if the museums are registered with their respective governments
under the Convention for International Trade in Endangered Species (CITES).
In this case, it is the institutional certificates of CITES registration
that constitute the authority.
Permits can can authorize any number of transactions, 
and  any number of permits may be required for a transaction.</p>
<p>
<div class="fldDef">
	Permit . Permit_Num<br/>
	VARCHAR(20) null
</div>
<strong><a name="permit_number">Permit Number</a></strong> 
is an identifying text string assigned by the agency issuing the permit.
Not all permits have such a number.
<p>
<div class="fldDef">
	Permit . Permit_Type<br/>
	VARCHAR(50) not null<br/>
	ctpermit_type
</div>
<strong><a name="original_units">Permit Type:</a></strong>
The kind of activity authorized by the permit.
Their are now four values are controlled by a look-up table.
These are:
<ul>
	<li>scientific collecting</li>
	<li>import/export</li>
	<li>import</li>
	<li>collector's hunt/fish/trap</li>
</ul>
There is room for improvement here.
In some cases, permits may authorize collecting, importation, and exportation.
<p>
<div class="fldDef">
	Permit . Issued_To_Agent_id<br/>
	INTEGER not null
</div>	
<strong><a name="issued_to">Issued To:</a></strong>
The agent to whom the permit was issued.  
This could be either a person or organization.</p>
<p>
<div class="fldDef">
	Permit . Issued_By_Agent_id<br/>
	INTEGER not null
</div>
<strong><a name="issued_by">Issued By:</a></strong>
The agent to who issued the permit.  
This could be either a person or organization.</p>
<p>
<div class="fldDef">
	Permit . Contact_Agent_id<br/>
	INTEGER not null
</div>
<strong><a name="contact">Contact Person:</a></strong>
Assuming that the Permit was issued by an organization,
this would be a person within the organization who administers the permit.  
This should always be a person, not an organization.</p>
<p>
<div class="fldDef">
	Permit . Issued_Date<br/>
	DATETIME null
</div>
<strong><a name="issued_date">Issued Date:</a></strong>
The day the permit was issued. 
(We assume this to be the same as the day
on which the permitted activities become legal.
This might not always be the case.
We might need a separate date to indicate
the time period for which the permit is effective.)
A valid date is required.</p>
<p>
<div class="fldDef">
	Permit . Renewed_Date<br/>
	DATETIME null
</div>
<strong><a name="renewed_date">Renewed Date:</a></strong>
Rather than expiring, and requiring a new permit for continued
activity, some permits may be renewed.</p>
<p>
<div class="fldDef">
	Permit . Exp_Date<br/>
	DATETIME null
</div>
<strong><a name="expiration_date">Expiration Date:</a></strong>
The day on which the permit is no longer valid.
This date might be used to automatically notify the permittees
of the approaching expiration.</p>
<p>
<div class="fldDef">
	Permit . Permit_Remarks<br/>
	VACHAR(255) null
</div>
<strong><a name="remarks">Remarks:</a></strong>
These can be anything that extends the definition of the 
permit or the conditions under which it applies.

<cfinclude template="/includes/_helpFooter.cfm">