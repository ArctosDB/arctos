<cfinclude template="/includes/_header.cfm">
<cfset title="Guide to troubleshooting Arctos data">
<h2>Suspect Data Reports</h2>
Arctos offers several methods by which users may investigate suspect data. None are perfect - black-and-white issues are
encoded as database rules, rather than after-the-fact reports.

<p>
	This is a static page, and may be incomplete, incorrect, or out of date. Please notify a developer if that seems 
	to be the case. Last updated 9 Feb 2010 by DLM.
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
	users, reporting results, and curatorial action. Several forms are provided, each of which may provide only 
	vague clues as to what might be missing.
</p>
<p>
	<strong>Reports-->Loan/Citation Stats</strong>
</p>
<p>
	This sortable form reports loans to agents, and citations attributed to those loaned items. Loans cannot directly
	produce citations, so this is a tenuous linkage at best. Additionally, not all loans may be expected to produce citations.
	Items of particular interest here may include:
	<ul>
		<li>
			Loans which have no specimens associated with them. These are often legacy loans imported from another system, or
			initated loans which never completed, but they may also be indicitave of poor curatorial practices.
		</li>
		<li>
			Old loans which are not "closed." These may reflect missing items or poor curatorial practices. All loans
			should eventually be closed.
		</li>
		<li>
			Trends among agents. Some agents simply do not properly cite specimens, and that trend should be present in this form.
		</li>
	</ul>
</p>
<p>
	<strong>Reports-->More Citation Stats</strong>
</p>
<p>
	This form provides a summary of citations per collection, and access to an additional form that compares cited taxonomy 
	with current identification. These terms are not always expected to match, but gross inconsistencies may point towards
	incorrect citations, incorrect identification, or identifier mixups.
</p>
<p>
	<strong>Reports-->Even More Citation Stats</strong>
</p>
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
			average item loaned is to become a citation.
		</li>
	</ol>
</p>
<h3>GenBank</h3>
<p>
	<strong>Reports-->GenBank MIA</strong>
</p>
<p>
	Several queries are executed against GenBank every night. This form reports the results of them. Specimens which are 
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
<p>
	<strong>Reports-->Funky Data-->Invalid Taxonomy</strong>
</p>
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
<cfinclude template="/includes/_footer.cfm">
