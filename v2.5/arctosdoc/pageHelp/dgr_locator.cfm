<!--#set var="title" value="Specimen Search" -->
<!--#include virtual="/includes/_header.shtml" -->
<font size="+2">DGR Locator Tool</font>
<p>
This form tracks tubes in the DGR freezers.
</p>
<a href="#findnk">Find by NK</a><br />
<a href="#boxbrowse">Browse by Box</a><br />
<a href="#makefreezer">Create Freezer</a><br />
<a href="#alterfreezer">Alter Freezer</a><br />
<a href="#makeloan">Create Loans</a><br />

<a name="findnk"></a>
<hr />
<strong>Locate Items by NK Number</strong>
<p>
Find items by the NK Number recorded in the DGR Locator table. Note that there is no direct relationship, other than by NK, between data in the NK table and data in the rest of the database. There may be NK numbers in the locator system that are not in the specimen database (e.g., freshly collected items that have not yet been entered), a one-to-one relationship (yea!), or a one-to-many relationship (e.g., duplicate NK numbers, or DGR/MSB duplicate specimens that have not yet been identified and merged).
</p>
<hr />
<a name="boxbrowse"></a>
<strong>Browse by freezer location</strong>


<hr />
<a name="makefreezer"></a>
<strong>Create a new freezer</strong>


<hr />
<a name="alterfreezer"></a>
<strong>Alter Existing Freezer</strong>

<hr />
<a name="makeloan"></a>
<strong>Create Loans</strong>
See --missing link-- Loan documentation for general Loan help. A loan must exist before specimens can be added to it. Once a loan exists in the system, you must add relevant parts to it. Basic steps are:
<ul>
	<li>Create or Edit a Loan (Transactions tab) </li>
	<li>Add Items</li>
	<li>Search for Items</li>
	<li>Add appropriate items to Loan</li>
</ul>

<!--#include virtual="/includes/_footer.shtml" -->