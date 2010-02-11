<cfinclude template="/includes/_header.cfm">
<cfset title="Guide to troubleshooting Arctos data">
<h2>Suspect Data Reports</h2>
Arctos offers several methods by which users may investigate suspect data. None are perfect - black-and-white issues are
encoded as database rules, rather than after-the-fact reports.

<p>
	This is a static page, and may be incomplete, incorrect, or out of date. Please notify a developer if that seems 
	to be the case. Last updated 11 Feb 2010 by DLM.
</p>

<h3>Agents</h3>
<p>
	<strong>Reports-->Funky Data-->Duplicate agents</strong>
</p>
<p>
	This form dynamically searches for agents which may be duplicates (that is, an individual with two or more agent_id entries).
	Curators are encouraged to inspect these reports regularly, track down any recently-created duplicates, and offer 
	additional training to operators who create duplicate agents.
</p>
<h3>Citations</h3>
<p>
	Citations are particularly messy, since a proper citation involves good loan practices, good publication practices by
	users, users reporting results, and curatorial staff recording those results. Several forms are provided to help find
	gaps in this process, each of which may provide only 
	vague clues as to what might be missing.
</p>
<p><strong>Reports-->Loan/Citation Stats</strong></p>
<p>
	This sortable form reports loans to agents and citations attributed to those loaned items. Loans do not directly
	produce citations, so this is a tenuous linkage at best. Not all loans may be expected to produce citations.
	Items of particular interest here may include:
	<ul>
		<li>
			Loans which have no specimens associated with them. These are often legacy loans imported from another system, or
			initated loans which never completed, but they may also be indicitave of poor curatorial practices.
		</li>
		<li>
			Old loans which are not "closed." All loans	should eventually be closed.
		</li>
		<li>
			Trends among agents. Some agents simply do not properly cite specimens, and that trend should be present in this form.
		</li>
	</ul>
</p>
<p><strong>Reports-->More Citation Stats</strong></p>
<p>
	This form provides a summary of citations per collection, and access to an additional form that compares cited taxonomy 
	with current identification. These terms are not always expected to match, but gross inconsistencies may indicate data problems.
</p>
<p><strong>Reports-->Even More Citation Stats</strong></p>
<p>
	This cleverly-named report has several sections.
	<ol>
		<li>
			<strong>Publications by type, reviewed status, and citations</strong> summarizes these statistics across all
			Arctos participants, and strives to provide a starting point for further investigation using the Publications and 
			Projects access point.
		</li>
		<li>
			<strong>Projects by activity</strong> and <strong>Results of projects which borrow specimens</strong> are
			again summaries across all collections, and may be further investigated
			by specifying a Project Type under the project search form.
		</li>
		<li>
			<strong>Usage and results by collection</strong> provides a summary, by collection, of how likely the 
			average item loaned is to become a citation. Note that items may be loaned or cited multiple times, so
			this value may be larger than one.
		</li>
	</ol>
</p>
<p><strong>Manage Data-->Tools-->Publication Staging</strong></p>
<p>
	This form provides a place to make a quick note of a publication which you do not have the time, resources, or access
	to fully capture. Curators are encouraged to periodically review data found here, and to update status as appropriate.
</p>
<h3>GenBank</h3>
<p>
	<strong>Reports-->GenBank MIA</strong>
</p>
<p>
	Several queries that attempt to find GenBank sequences that relate to Arctos specimens
	are executed against GenBank every night. This form reports the results of them. Specimens which are 
	already lined to GenBank are ignored.
	<ul>
		<li>
			<strong>specimen_voucher:collection</strong> queries find specimens which belong to registered collections
			and are cited properly. These are almost certainly accurate. The accuracy of all other query types 
			is highly variable. 
		</li>
		<li>
			<strong>wild1:collection</strong> and <strong>wild2:collection</strong> are whitespace variant queries
			that search GenBank for 
			"<em>specimen voucher {institution_acronym} {collection_cde}</em>".
		</li>
		<li>
			<strong>wild1:institution</strong> and <strong>wild2:institution</strong>  are whitespace variant queries
			that search GenBank for "<em>specimen voucher {institution_acronym}</em>," and are more likely to find 
			extraneous entries.
		</li>
	</ul>
</p>
<h3>Taxonomy</h3>
<p><strong>Reports-->Funky Data-->Invalid Taxonomy</strong></p>
<p>
	This report locates legacy taxonomy entries which do not meet current rules.
</p>
<p>
	<strong>Reports-->Funky Data-->Messy Taxonomy</strong>
</p>
<p>
	This report provides various ways to access variously potentially goofy or incomplete taxonomy. 
	Nothing in this report is necessarily incorrect.
</p>
<h3>User activity</h3>
<p>
	<strong>Reports-->Audit SQL</strong>
</p>
<p>
	This report provides access to the SQL auditing. Data are gathered through Oracle's Fine Grained Auditing and updated hourly.
</p>
<p>
	<strong>Reports-->Oracle Roles</strong>
</p>
<p>
	This report provides a summary of Oracle roles and the users assigned to them. Curators should periodically review this, 
	and revoke rights from any former users who should no longer have access or users who have extraneous access.
</p>
<h3>Identification</h3>
<p><strong>Manage Data-->Tools-->Sync Parent/Child Taxonomy</strong></p>
<p>
	This form locates specimens in Parent Of/Child Of relationships which do not share Identification.Scientific_Name.
</p>
<h3>Relationships</h3>
<p><strong>Manage Data-->Tools-->Pending Relationships</strong></p>
<p>
	Items in this form had a Relationship entered during initial data entry, and the automated scripts were unable to 
	reconcile the information provided to create relationships. Anything here requires further attention.
</p>
<h3>User Feedback</h3>
<p><strong>reports-->Annotations</strong></p>
<p>
	This form provides access to user annotations. Users may annotate specimens, taxonomy, projects, and publications.
	Annotations are also emailed to "data quality" curatorial contacts, which may be configured in the Manage Collection 
	interface. 
</p>
<cfinclude template="/includes/_footer.cfm">
